module mem (
    input wire i_clk,
    input wire i_reset,
    input wire i_wb_stb,
    input wire [31:0] i_wb_data,
    input wire [31:0] i_wb_addr,
    input wire i_wb_we,
    input wire [2:0] i_wb_sel,  //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits
    output reg [31:0] o_wb_data,  //'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
    output reg o_wb_ack,
    output reg o_wb_stall
);

  reg [31:0] mem_array[2**8];

  generate
    genvar idx;
    for (idx = 0; idx < 32; idx = idx + 1) begin : test_mem
      wire [31:0] tmp_mem_array;
      assign tmp_mem_array = mem_array[idx];
    end
  endgenerate

  initial $readmemh("example_program.txt", mem_array);  //Assuming name of txt is data.txt

  parameter S_IDLE = 1;
  parameter S_READ = 2;
  parameter S_WRITE = 3;


  integer r_state = S_IDLE;

  wire [31:0] word_addr;
  assign word_addr = i_wb_addr >> 2;  // division by 4


  always @(posedge i_clk) begin
    if (i_reset) begin
      r_state <= S_IDLE;
      o_wb_ack <= 0;
      o_wb_data <= 0;
      o_wb_stall <= 0;
    end
    if (r_state == S_IDLE) begin
      o_wb_ack  <= 0;
      o_wb_stall <= 0;
      o_wb_data <= 32'hFFFFFFFF;
      if (i_wb_stb && !o_wb_stall && i_wb_we) begin
        o_wb_stall  <= 1;
        r_state <= S_WRITE;
        $display("mem wil begin write");
      end else if (i_wb_stb && !o_wb_stall && !i_wb_we) begin
        o_wb_stall  <= 1;
        r_state <= S_READ;
        $display("mem will begin read");
      end
    end else if (r_state == S_WRITE) begin
      if (i_wb_sel == 'b000) begin
        mem_array[word_addr][7:0] <= i_wb_data[7:0];
      end else if (i_wb_sel == 'b001) begin
        mem_array[word_addr][15:0] <= i_wb_data[15:0];
      end else if (i_wb_sel == 'b010) begin
        mem_array[word_addr] <= i_wb_data;
      end else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      o_wb_data  <= 32'hFFFFFFFF;
      o_wb_ack   <= 1;
      //o_wb_stall <= 0;
      r_state <= S_IDLE;
      $display("finished mem wrote %h to addr %h ",i_wb_data,i_wb_addr);
    end else if (r_state == S_READ) begin
      if (i_wb_sel == 'b000) begin
        o_wb_data <= $signed(mem_array[word_addr][7:0]);
      end else if (i_wb_sel == 'b001) begin
        o_wb_data <= $signed(mem_array[word_addr][15:0]);
      end else if (i_wb_sel == 'b010) begin
        o_wb_data <= mem_array[word_addr];
      end else if (i_wb_sel == 'b100) begin
        o_wb_data <= {24'b0, mem_array[word_addr][7:0]};
      end else if (i_wb_sel == 'b101) begin
        o_wb_data <= {16'b0, mem_array[word_addr][15:0]};
      end else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      $display("finished mem outputted %h from addr %h",mem_array[word_addr],i_wb_addr);
      o_wb_ack   <= 1;
      //o_wb_stall <= 0;
      r_state <= S_IDLE;
    end else begin
      $display("ERROR INVALID STATE IN MEMORY");
    end
  end

endmodule
