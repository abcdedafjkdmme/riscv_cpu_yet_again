`default_nettype none

module tb_top;

  reg clk = 0;
  reg reset = 1;
  


  soc u_soc(
    .i_clk   (clk   ),
    .i_reset (reset ),
    .i_stb   (1'b1  )
  );
  
  localparam CLK_PERIOD = 2;
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
    #200000 $finish;
  end

endmodule
`default_nettype wire
