module mem #(
  parameter MEM_SIZE = 2**20
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    input wire [31:0] i_wb_addr,
    input wire i_wb_we,
    input wire [2:0] i_wb_sel,  //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits
    output reg [31:0] o_wb_data,  //'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
    output reg o_wb_ack,
    output reg o_wb_stall
);

  reg [31:0] mem_array[MEM_SIZE];
  initial $readmemh("test/build/kernel.txt", mem_array);  //Assuming name of txt is data.txt

  generate
    genvar idx;
    for (idx = 0; idx < 2**10; idx = idx + 1) begin
      wire [31:0] tmp_word;
      assign tmp_word = mem_array[idx];
    end
  endgenerate


  parameter S_IDLE = 1;
  parameter S_READ = 2;
  parameter S_END_READ = 3;
  parameter S_WRITE = 4;
  parameter S_END_WRITE = 5;


  integer r_state = S_IDLE;

  reg [31:0] local_addr = 32'hFFFFFFFF;
  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [2:0] local_sel = 3'b111;
  reg local_we = 1'h1;

  wire [31:0] local_word_addr = local_addr >> 2;  // division by 4
  wire [1:0] local_byte_offset = local_addr[1:0];

  reg [31:0] r_mem_read_data = 32'hFFFFFFFF;
  
  wire [31:0] tmp0 = mem_array[local_word_addr];
  wire [31:0] tmp1 = mem_array[local_word_addr+1];

  always @(posedge i_clk) begin
    if (i_reset) begin
      r_state <= S_IDLE;
    end
    if (r_state == S_IDLE) begin
      if (i_wb_stb && !o_wb_stall) begin
        if(i_wb_addr > MEM_SIZE*4) begin
          $display("ERR mem address is larger than mem size");
          $finish;
        end
        local_addr <= i_wb_addr;
        local_data <= i_wb_data;
        local_sel  <= i_wb_sel;
        local_we   <= i_wb_we;

        if (i_wb_we) begin
          r_state <= S_WRITE;
          //$display("mem wil begin write");
        end else begin
          r_state <= S_READ;
          //$display("mem will begin read");
        end
      end
    end else if (r_state == S_WRITE) begin
      if (local_sel == 'b000) begin
        case (local_byte_offset)
          2'b00: mem_array[local_word_addr][7:0] <= local_data[7:0];
          2'b01: mem_array[local_word_addr][15:8] <= local_data[7:0];
          2'b10: mem_array[local_word_addr][23:16] <= local_data[7:0];
          2'b11: mem_array[local_word_addr][31:24] <= local_data[7:0];
        endcase
      end else if (local_sel == 'b001) begin
        case (local_byte_offset)
          2'b00: mem_array[local_word_addr][15:0] <= local_data[15:0];
          2'b01: mem_array[local_word_addr][23:8] <= local_data[15:0];
          2'b10: mem_array[local_word_addr][31:16] <= local_data[15:0];
          2'b11:
          {mem_array[local_word_addr+1][7:0],mem_array[local_word_addr][31:24]} <= local_data[15:0];
        endcase
      end else if (local_sel == 'b010) begin
        mem_array[local_word_addr] <= local_data;
      end else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      r_state <= S_END_WRITE;
    end else if (r_state == S_END_WRITE) begin
      r_state <= S_IDLE;
      $display("mem finished write");
    end else if (r_state == S_READ) begin
      if (local_sel == 'b000) begin
        case (local_byte_offset)
          2'b00: r_mem_read_data <= {{24{tmp0[7]}}, tmp0[7:0]};
          2'b01: r_mem_read_data <= {{24{tmp0[15]}}, tmp0[15:8]};
          2'b10: r_mem_read_data <= {{24{tmp0[23]}}, tmp0[23:16]};
          2'b11: r_mem_read_data <= {{24{tmp0[31]}}, tmp0[31:24]};
        endcase
      end else if (local_sel == 'b001) begin
        case (local_byte_offset)
          2'b00: r_mem_read_data <= {{16{tmp0[15]}}, tmp0[15:0]};
          2'b01: r_mem_read_data <= {{16{tmp0[23]}}, tmp0[23:8]};
          2'b10: r_mem_read_data <= {{16{tmp0[31]}}, tmp0[31:16]};
          2'b11: r_mem_read_data <= {{16{tmp1[7]}}, tmp1[7:0], tmp0[31:24]};
        endcase
      end else if (local_sel == 'b010) begin
        r_mem_read_data <= mem_array[local_word_addr];
      end else if (local_sel == 'b100) begin
        case (local_byte_offset)
          2'b00: r_mem_read_data <= {{24{1'b0}}, tmp0[7:0]};
          2'b01: r_mem_read_data <= {{24{1'b0}}, tmp0[15:8]};
          2'b10: r_mem_read_data <= {{24{1'b0}}, tmp0[23:16]};
          2'b11: r_mem_read_data <= {{24{1'b0}}, tmp0[31:24]};
        endcase
      end else if (local_sel == 'b101) begin
        case (local_byte_offset)
          2'b00: r_mem_read_data <= {{16{1'b0}}, tmp0[15:0]};
          2'b01: r_mem_read_data <= {{16{1'b0}}, tmp0[23:8]};
          2'b10: r_mem_read_data <= {{16{1'b0}}, tmp0[31:16]};
          2'b11: r_mem_read_data <= {{16{1'b0}}, tmp1[7:0], tmp0[31:24]};
        endcase
      end else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      r_state <= S_END_READ;
    end else if (r_state == S_END_READ) begin
      r_state <= S_IDLE;
      //$display("mem finished read");
    end else begin
      $display("ERROR INVALID STATE IN MEMORY");
    end
  end

  always @(*) begin
    o_wb_ack   = 0;
    o_wb_data  = 32'hFFFFFFFF;
    o_wb_stall = 1;

    case (r_state)
      S_IDLE: o_wb_stall = 0;
      S_END_WRITE: begin
        o_wb_ack   = 1;
        o_wb_stall = 0;
      end
      S_END_READ: begin
        o_wb_data = r_mem_read_data;
        o_wb_ack   = 1;
        o_wb_stall = 0;
      end
    endcase
  end

endmodule
