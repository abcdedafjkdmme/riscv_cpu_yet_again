`default_nettype none
module cpu_mem_controller (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    input wire [31:0] i_wb_addr,
    input wire i_wb_we,
    input wire i_wb_ack,
    input wire i_wb_stall,
    input wire [2:0] i_sel,  //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits 'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
    output reg o_wb_stb,
    output wire o_wb_we,
    output reg [31:0] o_wb_addr,
    output reg [31:0] o_wb_data,
    output reg [31:0] o_mem_wb_data,
    input wire [31:0] i_mem_wb_data,
    output reg o_wb_ack,
    output reg [3:0] o_wb_sel,
    output reg o_wb_stall
);



  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [31:0] local_addr = 32'hFFFFFFFF;
  reg local_we = 1;
  reg [2:0] local_sel = 'b000;


  assign o_wb_we = local_we;


  wire [31:0] local_word_addr;
  assign local_word_addr = local_addr >> 2;
  wire [1:0] byte_offset = local_addr[1:0];






  localparam S_IDLE = 0;

  localparam S_BEGIN_READ_0 = 1;
  localparam S_END_READ_0 = 2;
  localparam S_BEGIN_READ_1 = 3;
  localparam S_END_READ_1 = 4;
  localparam S_FIN_READ_COMP = 5;

  localparam S_BEGIN_WRITE_0 = 6;
  localparam S_END_WRITE_0 = 7;
  localparam S_BEGIN_WRITE_1 = 8;
  localparam S_END_WRITE_1 = 9;

  integer r_state = S_IDLE;

  //for mem writes 

  always @(*) begin
    o_wb_sel = 4'b000;
    o_mem_wb_data = 32'hFFFFFFFF;

    if (local_sel == 'b010) begin
      o_mem_wb_data = local_data;
      o_wb_sel = 4'b1111;
    end else if (local_sel == 3'b000 || local_sel == 3'b100) begin
      if (byte_offset == 2'b00) begin
        o_mem_wb_data = {{24{1'b1}}, local_data[7:0]};
        o_wb_sel = 4'b0001;
      end else if (byte_offset == 2'b01) begin
        o_mem_wb_data = {{16{1'b1}}, local_data[7:0], {8{1'b1}}};
        o_wb_sel = 4'b0010;
      end else if (byte_offset == 2'b10) begin
        o_mem_wb_data = {{8{1'b1}}, local_data[7:0], {16{1'b1}}};
        o_wb_sel = 4'b0100;
      end else if (byte_offset == 2'b11) begin
        o_mem_wb_data = {local_data[7:0], {24{1'b1}}};
        o_wb_sel = 4'b1000;
      end
    end else if (local_sel == 3'b001 || local_sel == 3'b101) begin
      if (byte_offset == 2'b00) begin
        o_mem_wb_data = {{16{1'b1}}, local_data[15:0]};
        o_wb_sel = 4'b0011;
      end else if (byte_offset == 2'b01) begin
        o_mem_wb_data = {{8{1'b1}}, local_data[15:0], {8{1'b1}}};
        o_wb_sel = 4'b0110;
      end else if (byte_offset == 2'b10) begin
        o_mem_wb_data = {local_data[15:0], {16{1'b1}}};
        o_wb_sel = 4'b1100;
      end else if (byte_offset == 2'b11) begin
        if (r_state == S_BEGIN_WRITE_0 || r_state == S_END_WRITE_0) begin
          o_mem_wb_data = {local_data[7:0], {24{1'b1}}};
          o_wb_sel = 4'b1000;
        end else if (r_state == S_BEGIN_WRITE_1 || r_state == S_END_WRITE_1) begin
          o_mem_wb_data = {{24{1'b1}}, local_data[15:8]};
          o_wb_sel = 4'b0001;
        end
      end
    end
  end

  // for mem reads 

  reg [31:0] r_data_0;
  reg [31:0] r_data_1;

  reg [31:0] r_wb_data;
  always @(*) begin
    r_wb_data = 32'hFFFFFFFF;
    if (local_sel == 3'b000) begin
      if (byte_offset == 2'b00) r_wb_data = {{24{r_data_0[7]}}, r_data_0[7:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{24{r_data_0[15]}}, r_data_0[15:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{24{r_data_0[23]}}, r_data_0[23:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{24{r_data_0[31]}}, r_data_0[31:24]};
    end else if (local_sel == 3'b100) begin
      if (byte_offset == 2'b00) r_wb_data = {{24{1'b0}}, r_data_0[7:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{24{1'b0}}, r_data_0[15:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{24{1'b0}}, r_data_0[23:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{24{1'b0}}, r_data_0[31:24]};
    end else if (local_sel == 3'b001) begin
      if (byte_offset == 2'b00) r_wb_data = {{16{r_data_0[15]}}, r_data_0[15:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{16{r_data_0[23]}}, r_data_0[23:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{16{r_data_0[31]}}, r_data_0[31:16]};
      else if (byte_offset == 2'b11)
        r_wb_data = {{16{r_data_1[7]}}, r_data_1[7:0], r_data_0[31:24]};
    end else if (local_sel == 3'b101) begin
      if (byte_offset == 2'b00) r_wb_data = {{16{1'b0}}, r_data_0[15:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{16{1'b0}}, r_data_0[23:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{16{1'b0}}, r_data_0[31:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{16{1'b0}}, r_data_1[7:0], r_data_0[31:24]};
    end else if (local_sel == 'b010) begin
      r_wb_data = r_data_0;
    end
  end


  always @(posedge i_clk) begin
    if (i_reset) begin
      o_wb_ack <= 0;
      o_wb_stall <= 0;
      o_wb_stb <= 0;
      o_wb_data <= 32'hFFFFFFFF;
      o_wb_addr <= 32'hFFFFFFFF;
      r_state <= S_IDLE;
    end else if (r_state == S_IDLE) begin
      o_wb_ack  <= 0;
      o_wb_data <= 32'hFFFFFFFF;
      o_wb_addr <= 32'hFFFFFFFF;
      if (i_wb_stb && !o_wb_stall) begin
        local_addr <= i_wb_addr;
        local_data <= i_wb_data;
        local_we <= i_wb_we;
        local_sel <= i_sel;
        o_wb_stall <= 1;
        r_state <= i_wb_we ? S_BEGIN_WRITE_0 : S_BEGIN_READ_0;
      end
    end else if (r_state == S_BEGIN_READ_0) begin
      if (!i_wb_stall) begin
        o_wb_stb  <= 1;
        o_wb_addr <= local_word_addr;
        r_state   <= S_END_READ_0;
      end
    end else if (r_state == S_END_READ_0) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        r_data_0 <= i_mem_wb_data;
        if ((local_sel == 'b001 || local_sel == 'b101) && byte_offset == 'b11) begin
          r_state <= S_BEGIN_READ_1;
        end else begin
          r_state <= S_FIN_READ_COMP;
        end
      end
    end else if (r_state == S_BEGIN_READ_1) begin
      if (!i_wb_stall) begin
        o_wb_stb  <= 1;
        o_wb_addr <= local_word_addr + 1;
        r_state   <= S_END_READ_1;
      end
    end else if (r_state == S_END_READ_1) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        r_data_1 <= i_mem_wb_data;
        r_state  <= S_FIN_READ_COMP;
      end
    end else if (r_state == S_FIN_READ_COMP) begin
      o_wb_ack <= 1;
      o_wb_stall <= 0;
      o_wb_data <= r_wb_data;
      r_state <= S_IDLE;
    end else if (r_state == S_BEGIN_WRITE_0) begin
      if (!i_wb_stall) begin
        o_wb_addr <= local_word_addr;
        o_wb_stb  <= 1;
        r_state   <= S_END_WRITE_0;
      end
    end else if (r_state == S_END_WRITE_0) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        if ((local_sel == 'b001 || local_sel == 'b101) && byte_offset == 'b11) begin
          r_state <= S_BEGIN_WRITE_1;
        end else begin
          o_wb_ack <= 1;
          o_wb_stall <= 0;
          r_state <= S_IDLE;
        end
      end
    end else if (r_state == S_BEGIN_WRITE_1) begin
      if (!i_wb_stall) begin
        o_wb_addr <= local_word_addr + 1;
        o_wb_stb  <= 1;
        r_state   <= S_END_WRITE_1;
      end
    end else if (r_state == S_END_WRITE_1) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        o_wb_ack <= 1;
        o_wb_stall <= 0;
        r_state <= S_IDLE;
      end
    end
  end

endmodule
