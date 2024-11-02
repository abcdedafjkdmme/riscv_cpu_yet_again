`default_nettype none
module alu (
    input wire [31:0] i_a,
    input wire [31:0] i_b,
    output reg [31:0] o_y,
    input wire [2:0] i_op,
    input wire i_sub,
    input wire i_arith_shift,
    input wire [2:0] i_branch_op,
    output reg o_will_branch
);

  always @(*) begin
    case (i_op)
      3'b000: begin
        if (i_sub) o_y = $signed(i_a) - $signed(i_b);
        else o_y = $signed(i_a) + $signed(i_b);
      end
      3'b001:  o_y = i_a << i_b[4:0];
      3'b010:  o_y = {{31{1'b0}},($signed(i_a) < $signed(i_b))};
      3'b011:  o_y = {{31{1'b0}}, i_a < i_b};
      3'b100:  o_y = i_a ^ i_b;
      3'b101: begin
        if(i_arith_shift) o_y = i_a >>> i_b[4:0];
        else o_y = i_a >> i_b[4:0];
      end
      3'b110: o_y = i_a | i_b ;
      3'b111: o_y = i_a & i_b;
      default: o_y = 0;
    endcase
  end

  always @(*) begin
    if (i_branch_op == 3'b000) begin
      o_will_branch = (i_a == i_b);
    end else if (i_branch_op == 3'b001) begin
      o_will_branch = !(i_a == i_b);
    end else if (i_branch_op == 3'b100) begin
      o_will_branch = ($signed(i_a) < $signed(i_b));
    end else if (i_branch_op == 3'b101) begin
      o_will_branch = ($signed(i_a) >= $signed(i_b));
    end else if (i_branch_op == 3'b110) begin
      o_will_branch = i_a < i_b;
    end else if (i_branch_op == 3'b111) begin
      o_will_branch = i_a >= i_b;
    end else begin
      o_will_branch = 0;
    end
  end

endmodule
