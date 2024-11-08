`default_nettype none

module tb_console;
reg clk = 0;
reg reset;

reg stb;
reg [31:0] data;
wire ack;
wire stall;

console uut
(
    .i_clk           (clk),
    .i_reset         (reset),
    .i_wb_stb        (stb),
    .i_wb_data       (data),
    .o_wb_ack        (ack),
    .o_wb_stall      (stall)
);

localparam CLK_PERIOD = 2;
always #(CLK_PERIOD/2) clk=~clk;

initial begin
  $dumpfile("tb_console.vcd");
  $dumpvars(0, tb_console);
end

localparam S_IDLE = 0;
localparam S_END = 1;

integer r_state = S_IDLE;;

initial begin
  reset = 1;
  #4 reset = 0;
  #100 $finish();
end


always @(posedge clk) begin
  if(reset) begin
    r_state <= S_IDLE;
    stb <= 0;
  end
  else if(r_state == S_IDLE) begin
    if(!stall) begin
      stb <= 1;
      data <= $urandom_range(32,126);
      r_state <= S_END;
    end
  end else if(r_state == S_END) begin
    stb <= 0;
    if(ack) begin
      r_state <= S_IDLE;
    end
  end
end

endmodule