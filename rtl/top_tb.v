`default_nettype none

module tb_top;

  reg clk = 0;
  reg reset = 1;
  wire        bus_i_wb_stb;
  wire [31:0] bus_i_wb_data;
  wire [31:0] bus_i_wb_addr;
  wire        bus_i_wb_we;
  wire [31:0] bus_o_wb_data;
  wire        bus_o_wb_ack;
  wire [2:0]  bus_i_wb_sel;
  wire        bus_o_wb_stall;

  // mem u_mem (
  //     .i_clk  (clk),
  //     .i_reset(reset),
  //     .i_wb_stb (mem_i_wb_stb),
  //     .i_wb_data (mem_i_wb_data),
  //     .i_wb_addr (mem_i_wb_addr),
  //     .i_wb_sel  (mem_i_wb_sel),
  //     .i_wb_we   (mem_i_wb_we),
  //     .o_wb_data (mem_o_wb_data),
  //     .o_wb_ack  (mem_o_wb_ack),
  //     .o_wb_stall (mem_o_wb_stall)
  // );

  bus u_bus(
    .i_clk      (clk      ),
    .i_reset    (reset    ),
    .i_wb_stb   (bus_i_wb_stb   ),
    .i_wb_data  (bus_i_wb_data  ),
    .i_wb_addr  (bus_i_wb_addr  ),
    .i_wb_we    (bus_i_wb_we    ),
    .i_wb_sel   (bus_i_wb_sel   ),
    .o_wb_data  (bus_o_wb_data  ),
    .o_wb_ack   (bus_o_wb_ack   ),
    .o_wb_stall (bus_o_wb_stall )
  );
  
  wire cpu_o_wb_ack;
  wire cpu_i_wb_stb = 1;
  wire cpu_o_wb_stall;

  cpu u_cpu (
      .i_clk     (clk),
      .i_reset   (reset),
      .i_wb_stb  (cpu_i_wb_stb),
      .i_wb_ack  (bus_o_wb_ack),
      .i_wb_stall(bus_o_wb_stall),
      .i_wb_data (bus_o_wb_data),
      .o_wb_data (bus_i_wb_data),
      .o_wb_addr (bus_i_wb_addr),
      .o_wb_we   (bus_i_wb_we),
      .o_wb_stb  (bus_i_wb_stb),
      .o_wb_sel  (bus_i_wb_sel),
      .o_wb_ack  (cpu_o_wb_ack),
      .o_wb_stall(cpu_o_wb_stall)
  );



  localparam CLK_PERIOD = 10;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
  end

  // always @(posedge clk) begin
  //   $display("cpu mem ack %b at time %t", mem_o_wb_ack, $time);
  // end
  initial begin
    #10 reset <= 0;
    #20000 $finish;
  end

endmodule
`default_nettype wire
