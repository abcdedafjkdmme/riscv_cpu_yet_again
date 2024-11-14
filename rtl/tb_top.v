`default_nettype none

module tb_top;

  reg clk = 0;
  reg reset = 1;
  wire shutdown;

  soc u_soc(
    .i_clk   (clk   ),
    .i_reset (reset ),
    .i_stb   (1'b1  ),
    .o_shutdown(shutdown),
    .i_close_file(1'b0)
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

  integer count = 0;

  always @(posedge clk) begin
    if(shutdown) begin
      count <= count + 1;
      if(count >= 1) 
        $finish();
      else if(!reset) begin
        reset <= 1;
      end else begin
        reset <= 0;
      end
    end
  end

endmodule
`default_nettype wire
