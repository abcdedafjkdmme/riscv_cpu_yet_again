module mem (
  input wire i_clk,
  input wire i_reset,
  input wire i_exec,
  input wire [31:0] i_data,
  input wire [31:0] i_addr,
  input wire i_we,
  input wire [2:0] i_sel,   //'b000- 8 bits 'b001- 16 bits 'b010- 32 bits
  output reg [31:0] o_data, //'b100 - 8 bits zero extend 'b101 - 16 bits zero extend
  output reg o_fin,
  output reg o_busy
);

reg [31:0] mem_array [2**8];

generate
  genvar idx;
  for(idx = 0; idx < 32; idx = idx+1) begin: test_mem
    wire [31:0] tmp_mem_array;
    assign tmp_mem_array = mem_array[idx];
  end
endgenerate

initial
 $readmemh("example_program.txt",mem_array); //Assuming name of txt is data.txt

parameter S_IDLE = 1;
parameter S_READ = 2;
parameter S_WRITE = 3;


integer r_state = S_IDLE;

wire [31:0] word_addr;
assign word_addr = i_addr >> 2; // division by 4


always @(posedge i_clk) begin
  if(i_reset) begin
    r_state <= S_IDLE;
    o_fin <= 0;
    o_data <= 0;
    o_busy <= 0;
  end
  if(!i_exec) begin
  end
  else begin
    if(r_state == S_IDLE) begin
      o_fin <= 0;
      o_busy <= 0;
      o_data <= 32'hF0F0F0F0;
      if(i_exec && !o_fin && i_we) begin
        o_busy <= 1;
        r_state <= S_WRITE;
        //$display("mem wil begin write");
      end
      else if(i_exec && !o_fin && !i_we) begin
        o_busy <= 1;
        r_state <= S_READ;
        //$display("mem will begin read");
      end
    end
    else if(r_state == S_WRITE) begin
      o_busy <= 1;
      if(i_sel == 'b000) begin
        mem_array[word_addr][7:0] <= i_data[7:0];
      end
      else if(i_sel == 'b001) begin
        mem_array[word_addr][15:0] <= i_data[15:0];
      end
      else if(i_sel == 'b010) begin
        mem_array[word_addr] <= i_data;
      end
      else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      o_data <= 32'hFFFFFFFF;
      o_fin <= 1;
      //o_busy <= 0;
      r_state <= S_IDLE;
      //$display("finished mem wrote %b to addr %d ",i_data,i_addr);
    end
    else if(r_state == S_READ) begin
      o_busy <= 1;
      if(i_sel == 'b000) begin
        o_data <= $signed(mem_array[word_addr][7:0]);
      end 
      else if(i_sel == 'b001) begin
        o_data <= $signed(mem_array[word_addr][15:0]);
      end
      else if(i_sel == 'b010) begin
        o_data <= mem_array[word_addr];
      end 
      else if(i_sel == 'b100) begin
        o_data <= {24'b0 , mem_array[word_addr][7:0]};
      end
      else if(i_sel == 'b101) begin
        o_data <= {16'b0, mem_array[word_addr][15:0]};
      end
      else begin
        $display("ERROR IN MEM, INVALID SEL");
      end
      //$display("finished mem outputted %b from addr %d",mem_array[word_addr],i_addr);
      o_fin <= 1;
      //o_busy <= 0;
      r_state <= S_IDLE;
    end
    else begin
      $display("ERROR INVALID STATE IN MEMORY");
    end
  end
end


endmodule