`default_nettype none

module tb_top;

  reg clk = 0;
  reg reset = 1;
  wire shutdown;

  soc u_soc(
    .i_clk   (clk   ),
    .i_reset (reset ),
    .i_stb   (1'b1  ),
    .o_shutdown(shutdown)
  );
  
  localparam CLK_PERIOD = 2;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
  end


  localparam MAX_SIM_TIME = 20000000;

  initial begin
    #10 reset <= 0;
    #MAX_SIM_TIME $finish;
  end

  always @(posedge clk) begin
    if(shutdown) $finish;
  end

endmodule
`default_nettype wire
