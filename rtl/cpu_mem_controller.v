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
    output wire [31:0] o_wb_addr,
    output reg [31:0] o_wb_data,
    output wire o_wb_ack,
    output reg [3:0] o_wb_sel,
    output reg o_wb_stall
);

  localparam S_IDLE = 0;
  localparam S_WRITE = 1;
  localparam S_READ = 2;
  integer r_state = S_IDLE;

  reg [31:0] local_data = 32'hFFFFFFFF;
  reg [31:0] local_addr = 32'hFFFFFFFF;
  reg local_we = 1;
  reg [1:0] local_sel = 'b000;
  wire [31:0] local_word_addr;
  assign local_word_addr = local_addr >> 2;
  wire [1:0] byte_offset = local_addr[1:0];

  assign o_wb_we = local_we;

  always @(*) begin
    if(local_sel == 'b001 || local_sel == 'b101 && byte_offset == 'b11) begin
      o_wb_addr = local_addr + 1; 
    end else begin
      o_wb_addr = local_addr;
    end
  end

  always @(*) begin
    if(local_sel == 'b010) begin
      o_wb_sel = 4'b1111;
    end else if()
  end

  always @(posedge i_clk) begin
    if (i_reset) begin
      r_state <= S_IDLE;
    end
    if (r_state == S_IDLE) begin
      if (i_wb_stb && !o_wb_stall) begin  
        local_addr <= i_wb_addr;
        local_data <= i_wb_data;
        local_we <= i_wb_we;
        local_sel <= i_sel;
        r_state <= i_wb_we ? S_WRITE : S_READ;
      end
    end else if(r_state == S_WRITE) begin
      if(i_sel == 'b010) begin
        o_wb_stb <= 1;
        o_wb_data <= local_data;
        o_wb_addr <= local_word_addr;
        o_wb_we <= 1;
        o_wb_sel <= 4'b1111;
      end 
      else if(i_sel == 'b000) begin
        o_wb_stb <= 1;
        o_wb_data <= local_data;
        o_wb_addr <= local_word_addr;
        o_wb_we <= 1;
        o_wb_sel <= (1 << byte_offset);
      end else if(i_sel == 'b001) begin
        o_wb_stb <= 1;
        o_wb_data <= local_data;
        o_wb_addr <= (byte_offset == 'b11) ? local_word_addr + 1: local_word_addr;
        o_wb_we <= 1;
        o_wb_sel <= 1 << byte_offset;
      end
    end
  end


endmodule
