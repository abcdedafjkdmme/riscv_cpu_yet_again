`default_nettype none
module console #(
    parameter O_FILE_NAME = "console_output.txt"
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    output reg o_wb_ack,
    output wire o_wb_stall
);

  integer fd;

  initial begin
    fd = $fopen(O_FILE_NAME, "w");
  end


  always @(posedge i_clk) begin
    if (i_reset) begin
      o_wb_ack <= 0;
    end else begin
      if (i_wb_stb && !o_wb_stall) begin
        $fwrite(fd,"%s", i_wb_data[7:0]);
        o_wb_ack <= 1;
      end else begin
        o_wb_ack <= 0;
      end
    end
  end

  assign o_wb_stall = 0;

endmodule
