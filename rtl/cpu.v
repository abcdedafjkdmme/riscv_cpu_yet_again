`include "macros.v"

`default_nettype none
module cpu (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire i_wb_ack,
    input wire i_wb_stall,
    input wire [31:0] i_wb_data,
    output reg [31:0] o_wb_data,
    output reg [31:0] o_wb_addr,
    output reg o_wb_we,
    output reg [2:0] o_wb_sel,
    output reg o_wb_stb,
    output reg o_wb_stall,
    output reg o_wb_ack
);


  parameter S_IDLE = 0;
  parameter S_REQ_MEM_READ = 1;
  parameter S_END_MEM_READ = 2;
  parameter S_FETCH_RS1 = 3;
  parameter S_END_RS1 = 4;
  parameter S_FETCH_RS2 = 5;
  parameter S_END_RS2 = 6;
  parameter S_EXEC = 7;
  parameter S_END_MEM_READ_INSTR = 8;
  parameter S_END_MEM_WRITE_INSTR = 9;
  parameter S_WRITE_RD = 10;
  parameter S_END_RD = 11;
  parameter S_INC = 12;
  parameter S_PAUSED = 13;
  parameter S_UNKNOWN_INSTR = 14;

  integer r_state = S_IDLE;

  reg [31:0] pc = 32'hFFFFFFFF;
  reg [31:0] instr = 32'hFFFFFFFF;


  reg reg_file_i_wb_stb = 0;
  reg reg_file_i_wb_we = 0;
  reg [31:0] reg_file_i_wb_addr = 32'hFFFFFFFF;
  reg [31:0] reg_file_i_wb_data = 32'hFFFFFFFF;
  wire [31:0] reg_file_o_wb_data;
  wire reg_file_o_wb_ack;
  wire reg_file_o_wb_stall;

  mem_bram #(.MEM_SIZE(32),.MEM_DUMP_SIZE(32),.MEM_FILE("reg_file.txt"),.HARDWIRE_X0(1'b1),.PRINT_INFO_EN(1'b0)) u_reg_file (
      .i_clk     (i_clk),
      .i_reset   (i_reset),
      .i_wb_stb  (reg_file_i_wb_stb),
      .i_wb_we   (reg_file_i_wb_we),
      .i_wb_addr (reg_file_i_wb_addr),
      .i_wb_data (reg_file_i_wb_data),
      .i_wb_sel  (4'b1111),
      .o_wb_data (reg_file_o_wb_data),
      .o_wb_ack  (reg_file_o_wb_ack),
      .o_wb_stall(reg_file_o_wb_stall)
  );

  reg [31:0] r_rs1 = 32'hFFFFFFFF;
  reg [31:0] r_rs2 = 32'hFFFFFFFF;
  reg [31:0] r_rd = 32'hFFFFFFFF;

  wire [31:0] rs1 = {{27{1'b0}},instr[19:15]};
  wire [31:0] rs2 = {{27{1'b0}},instr[24:20]};
  wire [31:0] rd =  {{27{1'b0}},instr[11:7]};
  wire [31:0] store_instr_offset = $signed({instr[31:25], instr[11:7]});
  wire [31:0] load_instr_offset = $signed(instr[31:20]);
  wire [31:0] jalr_instr_offset = $signed({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
  wire [31:0] branch_instr_offset = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
  wire [31:0] u_instr_offset = {instr[31:12], 12'b0};
  wire [2:0] instr_sel = instr[14:12];
  wire [2:0] branch_op = instr[14:12];
  wire [2:0] op = instr[14:12];



  wire is_alu_imm_instr = `IS_IMM_ALU_INSTR(instr);
  wire is_alu_reg_instr = `IS_REG_ALU_INSTR(instr);
  wire is_alu_instr = is_alu_imm_instr || is_alu_reg_instr;

  wire [31:0] alu_i_a = r_rs1;
  wire [31:0] alu_i_b = is_alu_imm_instr ? load_instr_offset : r_rs2;

  wire alu_sub_or_arith_shift = is_alu_imm_instr ? 0 : instr[30];
  wire alu_i_sub = alu_sub_or_arith_shift;
  wire alu_i_arith_shift = alu_sub_or_arith_shift;

  wire [2:0] alu_i_op = op;
  wire [2:0] alu_i_branch_op = branch_op;

  wire [31:0] alu_o_y;
  wire alu_o_will_branch;

  alu u_alu (
      .i_a          (alu_i_a),
      .i_b          (alu_i_b),
      .i_op         (alu_i_op),
      .i_sub        (alu_i_sub),
      .i_arith_shift(alu_i_arith_shift),
      .i_branch_op  (alu_i_branch_op),
      .o_y          (alu_o_y),
      .o_will_branch(alu_o_will_branch)
  );


  always @(posedge i_clk) begin
    if (i_reset) begin
      $display(("Resetting CPU \n"));
      pc <= 0;
      instr <= 0;
      o_wb_sel <= 3'b010;
      o_wb_stall <= 0;
      o_wb_ack <= 0;
      o_wb_addr <= 32'hFFFFFFFF;
      o_wb_data <= 32'hFFFFFFFF;
      reg_file_i_wb_stb <= 0;
      reg_file_i_wb_we <= 0;
      reg_file_i_wb_addr <= 32'hFFFFFFFF;
      reg_file_i_wb_data <= 32'hFFFFFFFF;
      r_rs1 <= 32'hFFFFFFFF;
      r_rs2 <= 32'hFFFFFFFF;
      r_rd <= 32'hFFFFFFFF;
      r_state <= S_IDLE;
    end else if (r_state == S_IDLE) begin
      o_wb_stall <= 0;
      o_wb_sel   <= 3'b010;
      o_wb_ack   <= 0;
      //o_wb_addr <= 32'hFFFFFFFF;
      //o_wb_data <= 32'hFFFFFFFF;
      if (i_wb_stb && !o_wb_stall) begin
        o_wb_stall <= 1;
        r_state <= S_REQ_MEM_READ;
      end
    end else if (r_state == S_REQ_MEM_READ) begin
      if (!i_wb_stall) begin
        o_wb_addr <= pc;
        o_wb_we   <= 0;
        o_wb_stb  <= 1;
        r_state   <= S_END_MEM_READ;
        $display("cpu requeseted read from mem");
      end
    end else if (r_state == S_END_MEM_READ) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        $display("cpu fetched instr %h at pc %h", i_wb_data, pc);
        instr   <= i_wb_data;
        r_state <= S_FETCH_RS1;
      end
    end else if (r_state == S_FETCH_RS1) begin
      if (!reg_file_o_wb_stall) begin
        reg_file_i_wb_addr <= rs1;
        reg_file_i_wb_we <= 0;
        reg_file_i_wb_stb <= 1;
        r_state <= S_END_RS1;
      end
    end else if (r_state == S_END_RS1) begin
      reg_file_i_wb_stb <= 0;
      if (reg_file_o_wb_ack) begin
        r_rs1   <= reg_file_o_wb_data;
        r_state <= S_FETCH_RS2;
      end
    end else if (r_state == S_FETCH_RS2) begin
      if (!reg_file_o_wb_stall) begin
        reg_file_i_wb_addr <= rs2;
        reg_file_i_wb_we <= 0;
        reg_file_i_wb_stb <= 1;
        r_state <= S_END_RS2;
      end
    end else if (r_state == S_END_RS2) begin
      reg_file_i_wb_stb <= 0;
      if (reg_file_o_wb_ack) begin
        r_rs2   <= reg_file_o_wb_data;
        r_state <= S_EXEC;
      end
    end else if (r_state == S_EXEC) begin
      // mem read instr
      if (`IS_MEM_READ_INSTR(instr)) begin
        if (!i_wb_stall) begin
          o_wb_addr <= r_rs1 + load_instr_offset;
          o_wb_we   <= 0;
          o_wb_sel  <= instr_sel;
          o_wb_stb  <= 1;
          r_state   <= S_END_MEM_READ_INSTR;
          $display("cpu requested read instr");
          $display("cpu will read from addr %h", r_rs1 + store_instr_offset);
        end
      end  //mem write instr
      else if (`IS_MEM_WRITE_INSTR(instr)) begin
        if (!i_wb_stall) begin
          o_wb_addr <= r_rs1 + store_instr_offset;
          o_wb_data <= r_rs2;
          o_wb_we   <= 1;
          o_wb_sel  <= instr_sel;
          o_wb_stb  <= 1;
          r_state   <= S_END_MEM_WRITE_INSTR;
          $display("cpu requested write instr");
          $display("cpu will write %h to addr %h", r_rs2, r_rs1 + store_instr_offset);
        end
      end  //jal instr
      else if (`IS_JAL_INSTR(instr)) begin
        $display("cpu executing jal instr");
        r_rd <= pc + 4;
        pc <= pc + jalr_instr_offset - 4;  // -4 because we add it  in S_INC
        r_state <= S_WRITE_RD;
      end  //jalr instr
      else if (`IS_JALR_INSTR(instr)) begin
        $display("cpu executing jalr instr");
        $display("next instr addr is %h", pc + 4);
        $display("calculated pc is %h", pc + r_rs1 + load_instr_offset);
        r_rd <= pc + 4;
        pc <= r_rs1 + load_instr_offset - 4;  // -4 because we add it  in S_INC
        r_state <= S_WRITE_RD;
      end  //branch instr
      else if (`IS_BRANCH_INSTR(instr)) begin
        $display("cpu executing branch instr");
        if (alu_o_will_branch) begin
          $display("cpu branch taken to addr %h", pc + branch_instr_offset);
          pc <= pc + branch_instr_offset - 4;  //-4 because we add it in S_INC
          r_state <= S_INC;
        end else begin
          $display("cpu branch not taken");
          r_state <= S_INC;
        end
      end else if(`IS_PAUSE_INSTR(instr)) begin 
        r_state <= S_PAUSED;
      end else if (is_alu_instr) begin
        if (is_alu_imm_instr) $display("cpu executing alu imm instr");
        else if (is_alu_reg_instr) $display("cpu executing alu reg instr");
        else $display("ERROR in alu instr");

        $display("cpu alu i_a is %h", alu_i_a);
        $display("cpu alu i_b is %h", alu_i_b);
        $display("alu op is %b", alu_i_op);
        $display("alu sub/arith shift is %b", alu_sub_or_arith_shift);
        $display("cpu alu output is %h", alu_o_y);
        $display("cpu stored result to rd x", rd);
        r_rd <= alu_o_y;
        r_state <= S_WRITE_RD;
      end else if (`IS_LUI_INSTR(instr)) begin
        $display("cpu executing lui instr");
        $display("stored %h to rd x", u_instr_offset, rd);
        r_rd <= u_instr_offset;
        r_state <= S_WRITE_RD;
      end else if (`IS_AUIPC_INSTR(instr)) begin
        $display("cpu executing auipc instr");
        $display("cpu wrote %h to reg %h", pc + $signed(u_instr_offset), rd);
        r_rd <= pc + $signed(u_instr_offset);
        r_state <= S_WRITE_RD;
      end else begin
        $display("ERROR UNKNOWN INSTR %b at addr %h", instr, pc);
        r_state <= S_UNKNOWN_INSTR;
        //$finish();
      end
    end else if (r_state == S_END_MEM_READ_INSTR) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin 
        $display("cpu finished mem read instr");
        $display("read %h to rd x", i_wb_data, rd);
        r_rd <= i_wb_data;
        r_state <= S_WRITE_RD;
      end
    end else if (r_state == S_END_MEM_WRITE_INSTR) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        $display("cpu finished mem write instr");
        //$display(("written %h to addr %h", o_wb_data, o_wb_addr);
        r_state <= S_INC;
      end
    end else if (r_state == S_WRITE_RD) begin
      if (!reg_file_o_wb_stall) begin
        reg_file_i_wb_stb  <= 1;
        reg_file_i_wb_we   <= 1;
        reg_file_i_wb_addr <= rd;
        reg_file_i_wb_data <= r_rd;
        r_state <= S_END_RD;
      end
    end else if (r_state == S_END_RD) begin
      reg_file_i_wb_stb <= 0;
      if (reg_file_o_wb_ack) begin
        r_state <= S_INC;
      end 
    end else if (r_state == S_INC) begin
      $display("cpu finished instr");
      $display("\n");
      pc <= pc + 4;
      o_wb_ack <= 1;
      o_wb_stall <= 0;
      r_state <= S_IDLE;
    end else if(r_state == S_PAUSED) begin
      $display("cpu is stalled");
    end else if(r_state == S_UNKNOWN_INSTR) begin 
      $display("ERR cpu unknwon instr");
      r_state <= S_UNKNOWN_INSTR;
    end else begin
      $display("ERR cpu in undefined state");
      //$finish();
    end
  end
endmodule
