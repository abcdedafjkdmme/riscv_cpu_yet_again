`include "defines.v"

`default_nettype none
module soc (
  input wire i_clk,
  input wire i_reset,
  input wire i_stb,
  input wire i_close_file,
  output wire o_stall,
  output wire o_ack,
  output wire o_shutdown
);

  wire        bus_i_wb_stb;
  wire [31:0] bus_i_wb_data;
  wire [31:0] bus_i_wb_addr;
  wire        bus_i_wb_we;
  wire [31:0] bus_o_wb_data;
  wire        bus_o_wb_ack;
  wire [2:0]  bus_i_wb_sel;
  wire        bus_o_wb_stall;


  bus u_bus(
    .i_clk      (i_clk      ),
    .i_reset    (i_reset    ),
    .i_wb_stb   (bus_i_wb_stb   ),
    .i_wb_data  (bus_i_wb_data  ),
    .i_wb_addr  (bus_i_wb_addr  ),
    .i_wb_we    (bus_i_wb_we    ),
    .i_wb_sel   (bus_i_wb_sel   ),
    .o_wb_data  (bus_o_wb_data  ),
    .o_wb_ack   (bus_o_wb_ack   ),
    .o_wb_stall (bus_o_wb_stall ),
    .o_shutdown (o_shutdown),
    .i_close_file(i_close_file)
  );
  
  
  cpu #(
    .REG_FILE(`REG_FILE)
  )u_cpu(
      .i_clk     (i_clk),
      .i_reset   (i_reset),
      .i_wb_stb  (i_stb),
      .i_wb_ack  (bus_o_wb_ack),
      .i_wb_stall(bus_o_wb_stall),
      .i_wb_data (bus_o_wb_data),
      .o_wb_data (bus_i_wb_data),
      .o_wb_addr (bus_i_wb_addr),
      .o_wb_we   (bus_i_wb_we),
      .o_wb_stb  (bus_i_wb_stb),
      .o_wb_sel  (bus_i_wb_sel),
      .o_wb_ack  (o_ack),
      .o_wb_stall(o_stall)
  );
  
endmodule