`default_nettype none
module console #(
    parameter O_FILE_NAME = "console_output.txt"
) (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
`ifdef SIM
    input wire i_close_file,
`endif
    output reg o_wb_ack,
    output wire o_wb_stall

);

  integer fd;

  always @(posedge i_clk) begin
    if (i_reset) begin
    fd = $fopen(O_FILE_NAME, "w");
    o_wb_ack <= 0;
    end 
    else if(i_close_file) begin
      $fclose(fd);
    end 
    else if (i_wb_stb && !o_wb_stall) begin      
        // $display("%s",i_wb_data[7:0]);
        $fwrite(fd, "%s", i_wb_data[7:0]);
        o_wb_ack <= 1;
      end else begin
        o_wb_ack <= 0;
      end
  end

  assign o_wb_stall = 0;

endmodule
