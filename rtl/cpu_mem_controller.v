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

  localparam S_IDLE = 0;
  localparam S_BEGIN_WRITE = 1;
  localparam S_BEGIN_READ = 2;
  localparam S_END_READ = 3;
  localparam S_END_WRITE = 4;
  reg [4:0] r_state = S_IDLE;

  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [31:0] local_addr = 32'hFFFFFFFF;
  reg local_we = 1;
  reg [2:0] local_sel = 'b000;


  assign o_wb_we = local_we;


  wire [31:0] local_word_addr;
  assign local_word_addr = local_addr >> 2;
  wire [1:0] byte_offset = local_addr[1:0];

  always @(*) begin
    o_wb_addr = 32'hFFFFFFFF;
    if (local_sel == 'b001 || local_sel == 'b101 && byte_offset == 'b11) begin
      o_wb_addr = local_word_addr + 1;
    end else begin
      o_wb_addr = local_word_addr;
    end
  end

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
        o_mem_wb_data = {{16{1'b1}}, local_data[15:0]};
        o_wb_sel = 4'b0011;
      end
    end
  end

  reg [31:0] r_wb_data;
  always @(*) begin
    r_wb_data = 32'hFFFFFFFF;
    if (local_sel == 3'b000) begin
      if (byte_offset == 2'b00) r_wb_data = {{24{i_mem_wb_data[7]}}, i_mem_wb_data[7:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{24{i_mem_wb_data[15]}}, i_mem_wb_data[15:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{24{i_mem_wb_data[23]}}, i_mem_wb_data[23:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{24{i_mem_wb_data[31]}}, i_mem_wb_data[31:24]};
    end else if (local_sel == 3'b100) begin
      if (byte_offset == 2'b00) r_wb_data = {{24{1'b0}}, i_mem_wb_data[7:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{24{1'b0}}, i_mem_wb_data[15:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{24{1'b0}}, i_mem_wb_data[23:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{24{1'b0}}, i_mem_wb_data[31:24]};
    end else if (local_sel == 3'b001) begin
      if (byte_offset == 2'b00) r_wb_data = {{16{i_mem_wb_data[15]}}, i_mem_wb_data[15:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{16{i_mem_wb_data[23]}}, i_mem_wb_data[23:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{16{i_mem_wb_data[31]}}, i_mem_wb_data[31:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{16{i_mem_wb_data[15]}}, i_mem_wb_data[15:0]};
    end else if (local_sel == 3'b101) begin
      if (byte_offset == 2'b00) r_wb_data = {{16{1'b0}}, i_mem_wb_data[15:0]};
      else if (byte_offset == 2'b01) r_wb_data = {{16{1'b0}}, i_mem_wb_data[23:8]};
      else if (byte_offset == 2'b10) r_wb_data = {{16{1'b0}}, i_mem_wb_data[31:16]};
      else if (byte_offset == 2'b11) r_wb_data = {{16{1'b0}}, i_mem_wb_data[15:0]};
    end else if (local_sel == 'b010) begin
      r_wb_data = i_mem_wb_data;
    end
  end

  always @(posedge i_clk) begin
    if (i_reset) begin
      o_wb_ack <= 0;
      o_wb_stall <= 0;
      o_wb_stb <= 0;
      o_wb_data <= 32'hFFFFFFFF;
      r_state <= S_IDLE;
    end
    if (r_state == S_IDLE) begin
      o_wb_ack <= 0;
      if (i_wb_stb && !o_wb_stall) begin
        local_addr <= i_wb_addr;
        local_data <= i_wb_data;
        local_we <= i_wb_we;
        local_sel <= i_sel;
        o_wb_stall <= 1;
        r_state <= i_wb_we ? S_BEGIN_WRITE : S_BEGIN_READ;
      end
    end else if (r_state == S_BEGIN_READ) begin
      if (!i_wb_stall) begin
        o_wb_stb <= 1;
        r_state  <= S_END_READ;
      end
    end else if (r_state == S_END_READ) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        o_wb_ack <= 1;
        o_wb_stall <= 0;
        o_wb_data <= r_wb_data;
        r_state <= S_IDLE;
      end
    end else if (r_state == S_BEGIN_WRITE) begin
      if (!i_wb_stall) begin
        o_wb_stb <= 1;
        r_state  <= S_END_WRITE;
      end
    end else if (r_state == S_END_WRITE) begin
      o_wb_stb <= 0;
      if (i_wb_ack) begin
        o_wb_ack <= 1;
        o_wb_stall <= 0;
        r_state <= S_IDLE;
      end
    end
  end

endmodule
