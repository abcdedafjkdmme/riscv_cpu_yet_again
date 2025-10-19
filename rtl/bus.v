`include "defines.v"

`default_nettype none
module bus (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    input wire [31:0] i_wb_addr,
    input wire i_wb_we,
    input wire i_close_file,
    input wire [2:0] i_wb_sel,  //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits
    output reg [31:0] o_wb_data,  //'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
    output reg o_wb_ack,
    output wire o_wb_stall,
    output wire o_shutdown
);




  wire mem_i_wb_stb;
  wire mem_i_wb_we;
  wire [31:0] mem_o_wb_data;
  wire [31:0] mem_i_wb_addr;
  wire [31:0] mem_i_wb_data;
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
    .i_wb_data     (i_wb_data     ),
    .i_wb_addr     (i_wb_addr     ),
    .i_wb_we       (i_wb_we       ),
    .i_wb_ack      (mem_o_wb_ack  ),
    .i_wb_stall    (mem_o_wb_stall),
    .i_sel         (i_wb_sel      ),
    .i_mem_wb_data (mem_o_wb_data ),
    .o_mem_wb_data (mem_i_wb_data ),
    .o_wb_stb      (mem_i_wb_stb  ),
    .o_wb_we       (mem_i_wb_we   ),
    .o_wb_addr     (mem_i_wb_addr ),
    .o_wb_data     (mcntrl_o_wb_data     ),
    .o_wb_ack      (mcntrl_o_wb_ack      ),
    .o_wb_sel      (mem_i_wb_sel  ),
    .o_wb_stall    (mcntrl_o_wb_stall    )
  );
  


  mem_bram  #(
    .MEM_FILE(`MEM_FILE),
    .MEM_SIZE(`MEM_SIZE),
    .MEM_DUMP_SIZE(`MEM_DUMP_SIZE),
    .HARDWIRE_X0(1'b0),
    .PRINT_INFO_EN(1'b1)
  ) u_mem_bram
  (
      .i_clk  (i_clk),
      .i_reset(i_reset),
      .i_wb_stb (mem_i_wb_stb),
      .i_wb_data (mem_i_wb_data),
      .i_wb_addr (mem_i_wb_addr),
      .i_wb_sel  (mem_i_wb_sel),
      .i_wb_we   (mem_i_wb_we),
      .o_wb_data (mem_o_wb_data),
      .o_wb_ack  (mem_o_wb_ack),
      .o_wb_stall (mem_o_wb_stall)
  );

`ifdef SIM
  reg con_i_wb_stb;
  wire con_o_wb_ack;
  wire con_o_wb_stall;

  console u_console(
    .i_clk      (i_clk      ),
    .i_reset    (i_reset    ),
    .i_wb_stb   (con_i_wb_stb   ),
    .i_wb_data  (i_wb_data  ),
    .o_wb_ack   (con_o_wb_ack   ),
    .o_wb_stall (con_o_wb_stall ),
    .i_close_file(i_close_file)
  );

  parameter CON_ADDR= 32'hFFFF_FFF1;

`endif

  

  parameter MEM_ADDR_START = 'h0;
  parameter MEM_ADDR_END = 32'hFFFF_FF00;

 

  parameter SHUTDOWN_ADDR = 32'hFFFF_FFF2;

  parameter SLAVE_NONE = 0;
  parameter SLAVE_MEM = 1;
  parameter SLAVE_CON = 2;
  parameter SLAVE_SHUTDOWN = 3;
  reg [31:0] w_active_slave;

  assign o_shutdown = (w_active_slave == SLAVE_SHUTDOWN) && i_wb_we && (i_wb_data == 1);

  always @(*) begin
    w_active_slave = SLAVE_NONE;
    if(i_wb_addr >= MEM_ADDR_START && i_wb_addr <= MEM_ADDR_END) begin
      w_active_slave = SLAVE_MEM;
    end 
`ifdef SIM
    else if (i_wb_addr == CON_ADDR) begin
      w_active_slave = SLAVE_CON;
    end 
`endif
    else if (i_wb_addr == SHUTDOWN_ADDR) begin
      w_active_slave = SLAVE_SHUTDOWN;
    end
  end

  always @(*) begin
    mcntrl_i_wb_stb = 0;
`ifdef SIM
    con_i_wb_stb = 0;
`endif
    case (w_active_slave)
      SLAVE_NONE: ;
      SLAVE_MEM: mcntrl_i_wb_stb = i_wb_stb;
`ifdef SIM
      SLAVE_CON: con_i_wb_stb = i_wb_stb;
`endif
      SLAVE_SHUTDOWN: ;
      default: ;// $display("ERROR in bus");
    endcase
  end

  assign o_wb_stall = mcntrl_o_wb_stall 
`ifdef SIM
  | con_o_wb_stall
`endif
  ;
  
  always @(*) begin
    o_wb_ack = 0;
    o_wb_data = 32'hFFFFFFFF;
    if(mcntrl_o_wb_ack) begin
      o_wb_data = mcntrl_o_wb_data;
      o_wb_ack = 1;
    end 
`ifdef SIM
    else if(con_o_wb_ack) begin
      o_wb_data = 32'hFFFFFFFF;
      o_wb_ack = 1;
    end
`endif
    else if(w_active_slave == SLAVE_SHUTDOWN) begin
      o_wb_ack = 1;
    end
  end


  
endmodule
