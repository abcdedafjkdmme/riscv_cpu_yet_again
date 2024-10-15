`default_nettype none

module tb_top;

  reg clk = 0;
  reg reset = 1;
  wire mem_i_exec;
  wire [31:0] mem_i_data;
  wire [31:0] mem_i_addr;
  wire mem_i_we;
  wire [31:0] mem_o_data;
  wire mem_o_fin;
  wire [2:0] mem_i_sel;
  wire mem_o_busy;

  mem u_mem (
      .i_clk  (clk),
      .i_reset(reset),
      .i_exec (mem_i_exec),
      .i_data (mem_i_data),
      .i_addr (mem_i_addr),
      .i_sel  (mem_i_sel),
      .i_we   (mem_i_we),
      .o_data (mem_o_data),
      .o_fin  (mem_o_fin),
      .o_busy (mem_o_busy)
  );

  wire cpu_o_fin;
  wire cpu_i_exec;
  assign cpu_i_exec = 1;

  cpu u_cpu (
      .i_clk     (clk),
      .i_reset   (reset),
      .i_exec    (cpu_i_exec),
      .i_fin     (mem_o_fin),
      .i_busy    (mem_o_busy),
      .i_data    (mem_o_data),
      .o_data    (mem_i_data),
      .o_addr    (mem_i_addr),
      .o_we      (mem_i_we),
      .o_mem_exec(mem_i_exec),
      .o_sel     (mem_i_sel),
      .o_fin     (cpu_o_fin)
  );



  localparam CLK_PERIOD = 10;
  always #(CLK_PERIOD / 2) clk = ~clk;

  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
  end

  initial begin
    #10 reset <= 0;
    #500 $finish;
  end

endmodule
`default_nettype wire
