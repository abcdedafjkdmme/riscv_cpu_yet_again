`default_nettype none
module mem_bram #(
    parameter MEM_SIZE = 2 ** 10,
    parameter MEM_DUMP_SIZE = 2 ** 10,
    parameter MEM_FILE = "reg_file.txt",
    parameter HARDWIRE_X0 = 1'b0,
    parameter PRINT_INFO_EN = 1'b0
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire i_wb_we,
    input wire [31:0] i_wb_addr,
    input wire [31:0] i_wb_data,
    input wire [3:0] i_wb_sel,
    output reg [31:0] o_wb_data,
    output reg o_wb_ack,
    output reg o_wb_stall
);

  localparam S_IDLE = 0;
  localparam S_READ = 1;
  localparam S_END_READ = 2;
  localparam S_WRITE = 3;
  localparam S_END_WRITE = 4;

  integer r_state = S_IDLE;

  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [31:0] local_addr = 32'hFFFFFFFF;
  reg [3:0] local_sel = 4'b0000;

  reg [31:0] bram[MEM_SIZE];

  reg [31:0] bram_o_data;

  initial begin
    $readmemh(MEM_FILE, bram);
  end

  generate
    genvar idx;
    for (idx = 0; idx < MEM_DUMP_SIZE; idx = idx + 1) begin
      wire [31:0] bram_tmp;
      assign bram_tmp = bram[idx];
    end
  endgenerate

  always @(posedge i_clk) begin

    if (i_reset) begin
      r_state <= S_IDLE;
      local_data <= 32'hFFFFFFFF;
      local_addr <= 32'hFFFFFFFF;
      local_sel <= 4'b1111;
      //bram_o_data <= 32'hFFFFFFFF;
      o_wb_ack <= 0;
      o_wb_stall <= 0;
      o_wb_data <= 32'hFFFFFFFF;
    end else if (r_state == S_IDLE) begin
      o_wb_ack   <= 0;
      o_wb_stall <= 0;
      if (i_wb_stb && !o_wb_stall) begin
        if (HARDWIRE_X0 == 1 && i_wb_addr == 0) begin
          o_wb_data  <= 32'h0;
          o_wb_stall <= 0;
          o_wb_ack   <= 1;
        end else begin
          local_addr <= i_wb_addr;
          local_data <= i_wb_data;
          local_sel <= i_wb_sel;
          o_wb_stall <= 1;
          r_state <= i_wb_we ? S_WRITE : S_READ;
        end
      end
    end else if(r_state == S_READ) begin
      r_state <= S_END_READ;
    end else if (r_state == S_END_READ) begin
      o_wb_data <= bram_o_data;
      o_wb_stall <= 0;
      o_wb_ack <= 1;
      r_state <= S_IDLE;
      if(PRINT_INFO_EN) begin
        $display("mem finished read");
        $display("mem read %h from addr %h", bram_o_data,local_addr);
      end
    end else if(r_state == S_WRITE) begin
      r_state <= S_END_WRITE;
    end else if (r_state == S_END_WRITE) begin
      o_wb_stall <= 0;
      o_wb_ack <= 1;
      r_state <= S_IDLE;
      if(PRINT_INFO_EN) begin
        $display("mem finished write");
        $display("mem wrote %h to addr %h", bram[local_addr], local_addr);
      end
    end
  end

  always @(posedge i_clk) begin
    if ((r_state == S_WRITE) && local_sel[3]) begin
      bram[local_addr][31:24] <= local_data[31:24];
    end
    if ((r_state == S_WRITE) && local_sel[2]) begin
      bram[local_addr][23:16] <= local_data[23:16];
    end
    if ((r_state == S_WRITE) && local_sel[1]) begin
      bram[local_addr][15:8] <= local_data[15:8];
    end
    if ((r_state == S_WRITE) && local_sel[0]) begin
      bram[local_addr][7:0] <= local_data[7:0];
    end
  end

  always @(posedge i_clk) begin
    if (r_state == S_READ) begin
      bram_o_data <= bram[local_addr];
    end
  end

endmodule
