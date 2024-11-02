`default_nettype none
module bus (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    input wire [31:0] i_wb_addr,
    input wire i_wb_we,
    input wire [2:0] i_wb_sel,  //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits
    output reg [31:0] o_wb_data,  //'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
    output reg o_wb_ack,
    output wire o_wb_stall
);

  parameter MEM_ADDR_START = 'h0;
  parameter MEM_ADDR_END = 'hFFFF_FF00;

  
  wire mem_i_wb_stb;
  wire mem_i_wb_we;
  wire [31:0] mem_o_wb_data;
  wire [31:0] mem_i_wb_addr;
  wire [3:0] mem_i_wb_sel;
  wire mem_o_wb_ack;
  wire mem_o_wb_stall;

  reg mcntrl_i_wb_stb;
  wire mcntrl_o_wb_stall;
  wire mcntrl_o_wb_ack;
  wire [31:0] mcntrl_o_wb_data;

  cpu_mem_controller u_cpu_mem_controller(
    .i_clk         (i_clk         ),
    .i_reset       (i_reset       ),
    .i_wb_stb      (mcntrl_i_wb_stb),
    .i_wb_addr     (i_wb_addr     ),
    .i_wb_we       (i_wb_we       ),
    .i_wb_ack      (mem_o_wb_ack  ),
    .i_wb_stall    (mem_o_wb_stall),
    .i_sel         (i_wb_sel      ),
    .i_mem_wb_data (mem_o_wb_data ),
    .o_wb_stb      (mem_i_wb_stb  ),
    .o_wb_we       (mem_i_wb_we   ),
    .o_wb_addr     (mem_i_wb_addr ),
    .o_wb_data     (mcntrl_o_wb_data     ),
    .o_wb_ack      (mcntrl_o_wb_ack      ),
    .o_wb_sel      (mem_i_wb_sel  ),
    .o_wb_stall    (mcntrl_o_wb_stall    )
  );
  


  mem_bram  #(
    .MEM_SIZE(2**10),
    .MEM_DUMP_SIZE(200),
    .MEM_FILE("test/build/kernel.txt"),
    .HARDWIRE_X0(1'b0)
  ) u_mem_bram
  (
      .i_clk  (i_clk),
      .i_reset(i_reset),
      .i_wb_stb (mem_i_wb_stb),
      .i_wb_data (i_wb_data),
      .i_wb_addr (mem_i_wb_addr),
      .i_wb_sel  (mem_i_wb_sel),
      .i_wb_we   (mem_i_wb_we),
      .o_wb_data (mem_o_wb_data),
      .o_wb_ack  (mem_o_wb_ack),
      .o_wb_stall (mem_o_wb_stall)
  );

  

  parameter SLAVE_NONE = 0;
  parameter SLAVE_MEM = 1;
  reg [31:0] w_active_slave;

  always @(*) begin
    w_active_slave = SLAVE_NONE;
    if(i_wb_addr >= MEM_ADDR_START && i_wb_addr <= MEM_ADDR_END) begin
      w_active_slave = SLAVE_MEM;
    end
  end

  always @(*) begin
    mcntrl_i_wb_stb = 0;
    case (w_active_slave)
      SLAVE_NONE: ;
      SLAVE_MEM: mcntrl_i_wb_stb = i_wb_stb;
      default: $display("ERROR in bus");
    endcase
  end

  assign o_wb_stall = mcntrl_o_wb_stall;
  
  always @(*) begin
    o_wb_ack = 0;
    o_wb_data = 32'hFFFFFFFF;
    if(mcntrl_o_wb_ack) begin
      o_wb_data = mcntrl_o_wb_data;
      o_wb_ack = 1;
    end
  end


  
endmodule
