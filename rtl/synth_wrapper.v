`default_nettype none
module synth_wrapper (
  input wire i_clk,
  input wire i_reset
);

reg mcntrl_i_wb_stb      ;
wire [31:0] mcntrl_i_wb_data     ;
wire [31:0] mcntrl_i_wb_addr     ;
wire mcntrl_i_wb_we       ;
wire mcntrl_i_wb_ack      ;
wire mcntrl_i_wb_stall    ;
wire [2:0] mcntrl_i_sel         ;
wire mcntrl_o_wb_stb      ;
wire mcntrl_o_wb_we       ;
wire [31:0] mcntrl_o_wb_addr     ;
wire [31:0] mcntrl_o_wb_data     ;
wire [31:0] mcntrl_o_mem_wb_data ;
wire [31:0] mcntrl_i_mem_wb_data ;
wire mcntrl_o_wb_ack      ;
wire [3:0] mcntrl_o_wb_sel      ;
wire mcntrl_o_wb_stall    ;

reg t = 0;
always @(posedge i_clk) begin
  t <= !t;
  mcntrl_i_wb_stb <= t;
end
cpu_mem_controller u_cpu_mem_controller(
  .i_clk         (i_clk         ),
  .i_reset       (i_reset       ),
  .i_wb_stb      (mcntrl_i_wb_stb      ),
  .i_wb_addr     (mcntrl_i_wb_addr     ),
  .i_wb_we       (mcntrl_i_wb_we       ),
  .i_wb_ack      (mcntrl_i_wb_ack      ),
  .i_wb_stall    (mcntrl_i_wb_stall    ),
  .i_sel         (mcntrl_i_sel         ),
  .o_wb_stb      (mcntrl_o_wb_stb      ),
  .o_wb_we       (mcntrl_o_wb_we       ),
  .o_wb_addr     (mcntrl_o_wb_addr     ),
  .o_wb_data     (mcntrl_o_wb_data     ),
  .i_mem_wb_data (mcntrl_i_mem_wb_data ),
  .o_wb_ack      (mcntrl_o_wb_ack      ),
  .o_wb_sel      (mcntrl_o_wb_sel      ),
  .o_wb_stall    (mcntrl_o_wb_stall    )
);

endmodule



