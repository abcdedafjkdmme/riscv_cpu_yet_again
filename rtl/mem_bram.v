module mem_bram #(
    parameter MEM_SIZE = 2 ** 10,
    parameter MEM_DUMP_SIZE = 2 ** 10,
    parameter MEM_FILE = "reg_file.txt",
    parameter HARDWIRE_X0 = 1'b0
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
  localparam S_WRITE = 2;

  integer r_state = S_IDLE;

  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [31:0] local_addr = 32'hFFFFFFFF;

  reg [31:0] mem_bram[MEM_SIZE];

  initial begin
    $readmemh(MEM_FILE, mem_bram);
  end

  generate
    genvar idx;
    for (idx = 0; idx < MEM_DUMP_SIZE; idx = idx + 1) begin
      wire [31:0] mem_bram_tmp;
      assign mem_bram_tmp = mem_bram[idx];
    end
  endgenerate

  always @(posedge i_clk) begin

    if (i_reset) begin
      r_state <= S_IDLE;
      local_data <= 32'hFFFFFFFF;
      local_addr <= 32'hFFFFFFFF;
      o_wb_ack <= 0;
      o_wb_stall <= 0;
      o_wb_data <= 32'hFFFFFFFF;
    end
    if (r_state == S_IDLE) begin
      o_wb_ack   <= 0;
      o_wb_stall <= 0;
      if (i_wb_stb && !o_wb_stall) begin
        if (HARDWIRE_X0 && i_wb_addr == 0) begin
          o_wb_data  <= 32'h0;
          o_wb_stall <= 0;
          o_wb_ack   <= 1;
        end else begin
          local_addr <= i_wb_addr;
          local_data <= i_wb_data;
          o_wb_stall <= 1;
          r_state <= i_wb_we ? S_WRITE : S_READ;
        end
      end
    end else if (r_state == S_READ) begin
      o_wb_stall <= 0;
      o_wb_ack <= 1;
      r_state <= S_IDLE;
    end else if (r_state == S_WRITE) begin
      o_wb_stall <= 0;
      o_wb_ack <= 1;
      r_state <= S_IDLE;
    end
  end

  always @(posedge i_clk) begin
    if ((r_state == S_WRITE) && i_wb_sel[3]) begin
      mem_bram[local_addr][31:24] <= local_data[31:24];
    end
    if ((r_state == S_WRITE) && i_wb_sel[2]) begin
      mem_bram[local_addr][23:16] <= local_data[23:16];
    end
    if ((r_state == S_WRITE) && i_wb_sel[1]) begin
      mem_bram[local_addr][15:8] <= local_data[15:8];
    end
    if ((r_state == S_WRITE) && i_wb_sel[0]) begin
      mem_bram[local_addr][7:0] <= local_data[7:0];
    end

  end


  always @(posedge i_clk) begin
    if (r_state == S_READ) begin
      o_wb_data <= mem_bram[local_addr];
    end
  end

endmodule
