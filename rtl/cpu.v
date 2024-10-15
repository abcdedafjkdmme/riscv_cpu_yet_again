module cpu (
    input wire i_clk,
    input wire i_reset,
    input wire i_exec,
    input wire i_fin,
    input wire i_busy,
    input wire [31:0] i_data,
    output reg [31:0] o_data,
    output reg [31:0] o_addr,
    output reg o_we,
    output reg [2:0] o_sel,
    output reg o_mem_exec,
    output reg o_fin

);

  parameter S_IDLE = 0;
  parameter S_REQ_MEM_READ = 1;
  parameter S_END_MEM_READ = 2;
  parameter S_EXEC = 3;
  parameter S_END_MEM_READ_INSTR = 4;
  parameter S_END_MEM_WRITE_INSTR = 5;
  parameter S_INC = 6;


  integer r_state = S_IDLE;

  reg [31:0] pc = 0;
  reg [31:0] instr = 0;

  reg [31:0] reg_file[32];

  wire [31:0] rs1 = instr[19:15];
  wire [31:0] rs2 = instr[24:20];
  wire [31:0] rd = instr[11:7];
  wire [31:0] store_instr_offset = $signed({instr[31:25], instr[11:7]});
  wire [31:0] load_instr_offset = $signed(instr[31:20]);
  wire [31:0] jalr_instr_offset = $signed({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
  wire [31:0] branch_instr_offset = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
  wire [31:0] u_instr_offset = {instr[31:12],12'b0};
  wire [2:0] instr_sel = instr[14:12];
  wire [2:0] branch_op = instr[14:12];
  wire [2:0] op = instr[14:12];

  wire is_alu_imm_instr = `IS_IMM_ALU_INSTR(instr);
  wire is_alu_reg_instr = `IS_REG_ALU_INSTR(instr);
  wire is_alu_instr = is_alu_imm_instr || is_alu_reg_instr;

  wire [31:0] alu_i_a = reg_file[rs1];
  wire [31:0] alu_i_b = is_alu_imm_instr ? load_instr_offset : reg_file[rs2] ;

  wire alu_sub_or_arith_shift = is_alu_imm_instr ? 0 : instr[30];
  wire alu_i_sub  = alu_sub_or_arith_shift;
  wire alu_i_arith_shift = alu_sub_or_arith_shift;

  wire [2:0] alu_i_op = op;
  wire [2:0] alu_i_branch_op = branch_op;

  wire [31:0] alu_o_y;
  wire alu_o_will_branch;

  alu u_alu(
   .i_a           (alu_i_a           ),
   .i_b           (alu_i_b           ),
   .i_op          (alu_i_op          ),
   .i_sub         (alu_i_sub         ),
   .i_arith_shift (alu_i_arith_shift ),
   .i_branch_op   (alu_i_branch_op   ),
   .o_y           (alu_o_y           ),
   .o_will_branch (alu_o_will_branch )
  );
 

  initial begin
    $readmemh("reg_file.txt", reg_file);
  end

  generate
    genvar idx;
    for (idx = 0; idx < 32; idx = idx + 1) begin
      wire [31:0] reg_file_tmp;
      assign reg_file_tmp = reg_file[idx];
    end
  endgenerate



  always @(posedge i_clk) begin
    if (i_reset) begin
      $display("Resetting CPU \n");
      pc <= 0;
      instr <= 0;
      o_sel <= 'b010;
      o_we <= 0;
      o_fin <= 0;
      o_mem_exec <= 0;
      o_data <= 0;
      o_addr <= 0;
      r_state <= S_IDLE;
    end else begin
      if (r_state == S_IDLE) begin
        o_fin <= 0;
        if (i_exec && !i_busy) begin
          r_state <= S_REQ_MEM_READ;
        end
      end else if (r_state == S_REQ_MEM_READ) begin
        if (!i_busy) begin
          //$display("cpu requeseted read from mem");
          o_addr <= pc;
          o_we <= 0;
          o_mem_exec <= 1;
          r_state <= S_END_MEM_READ;
        end
      end else if (r_state == S_END_MEM_READ) begin
        if (i_fin) begin
          $display("cpu fetched instr %h from addr %h", i_data, o_addr);
          o_addr <= 0;
          o_we <= 0;
          o_mem_exec <= 0;
          instr <= i_data;
          r_state <= S_EXEC;
        end

      end else if (r_state == S_EXEC) begin
        // mem read instr
        if (`IS_MEM_READ_INSTR(instr)) begin
          if (!i_busy) begin
            //$display("cpu requested read instr");
            o_addr <= reg_file[rs1] + load_instr_offset;
            o_we <= 0;
            o_sel <= instr_sel;
            o_mem_exec <= 1;
            r_state <= S_END_MEM_READ_INSTR;
          end
        end  //mem write instr
        else if (`IS_MEM_WRITE_INSTR(instr)) begin
          if (!i_busy) begin
            //$display("cpu requested write instr");
            o_addr <= reg_file[rs1] + store_instr_offset;
            o_data <= reg_file[rs2];
            o_we <= 1;
            o_sel <= instr_sel;
            o_mem_exec <= 1;
            r_state <= S_END_MEM_WRITE_INSTR;
          end
        end  //jal instr
        else if (`IS_JAL_INSTR(instr)) begin
          $display("cpu executing jal instr");
          reg_file[rd] <= pc + 4;
          pc <= pc + jalr_instr_offset - 4;  // -4 because we add it  in S_INC
          r_state <= S_INC;
        end  //jalr instr
        else if (`IS_JALR_INSTR(instr)) begin
          $display("cpu executing jalr instr");
          $display("next instr addr is %h", pc + 4);
          $display("calculated pc is %h", pc + reg_file[rs1] + load_instr_offset);
          reg_file[rd] <= pc + 4;
          pc <= pc + reg_file[rs1] + load_instr_offset - 4;  // -4 because we add it  in S_INC
          r_state <= S_INC;
        end  //branch instr
        else if (`IS_BRANCH_INSTR(instr)) begin
          $display("cpu executing branch instr");
          if (alu_o_will_branch) begin
            $display("cpu branch taken to addr %h", pc + branch_instr_offset);
            pc <= pc + branch_instr_offset - 4;  //-4 because we add it in S_INC
            r_state <= S_INC;
          end
          else begin
            $display("cpu branch not taken");
            r_state <= S_INC;
          end
        end else if(is_alu_instr) begin
          if(is_alu_imm_instr) $display("cpu executing alu imm instr");
          else if(is_alu_reg_instr) $display("cpu executing alu reg instr");
          else $display("ERROR");

          $display("cpu alu i_a is %h",alu_i_a);
          $display("cpu alu i_b is %h",alu_i_b);
          $display("alu op is %b",alu_i_op);
          $display("alu sub/arith shift is %b",alu_sub_or_arith_shift);
          $display("cpu alu output is %h",alu_o_y);
          $display("cpu stored result to rd %d",rd);
          reg_file[rd] <= alu_o_y;
          r_state <= S_INC;
        end else if(`IS_LUI_INSTR(instr)) begin
          $display("cpu executing lui instr");
          $display("stored %h to rd %d",u_instr_offset,rd);
          reg_file[rd] <= u_instr_offset;
          r_state <= S_INC;
        end else if (`IS_AUIPC_INSTR(instr)) begin
          $display("cpu executing auipc instr");
          $display("cpu new pc is %h",pc + $signed(u_instr_offset));
          pc <= pc + $signed(u_instr_offset) - 4;
          r_state <= S_INC;
        end else begin
          $display("ERROR UNKNOWN INSTR %b at addr %h", instr, pc);
        end

      end else if (r_state == S_END_MEM_READ_INSTR) begin
        if (i_fin) begin
          $display("cpu finished mem read instr");
          $display("read %h from addr %h to rd %d", i_data, o_addr, rd);
          reg_file[rd] <= i_data;
          o_addr <= 0;
          o_we <= 0;
          o_sel <= 'b010;
          o_mem_exec <= 0;
          r_state <= S_INC;
        end
      end else if (r_state == S_END_MEM_WRITE_INSTR) begin
        if (i_fin) begin
          $display("cpu finished mem write instr");
          $display("written %h to addr %h", o_data, o_addr);
          o_addr <= 0;
          o_data <= 0;
          o_we <= 0;
          o_sel <= 'b010;
          o_mem_exec <= 0;
          r_state <= S_INC;
        end
      end else if (r_state == S_INC) begin
        $display("finished instr");
        $display("next pc is %h", pc + 4);
        $display("\n");
        pc <= pc + 4;
        o_fin <= 1;
        r_state <= S_IDLE;
      end

    end
  end
endmodule
