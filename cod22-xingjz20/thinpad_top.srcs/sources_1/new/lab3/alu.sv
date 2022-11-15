`timescale 1ns / 1ps
// combinatory logic
module alu(
  input wire [15:0] data_a,
  input wire [15:0] data_b,
  input wire [3:0] op,
  output reg [15:0] data_y
);

always_comb begin
  case(op)
    4'd1: data_y = data_a + data_b;
    4'd2: data_y = data_a - data_b;
    4'd3: data_y = data_a & data_b;
    4'd4: data_y = data_a | data_b;
    4'd5: data_y = data_a ^ data_b;
    4'd6: data_y = ~data_a;
    4'd7: data_y = data_a << (data_b & 16'b1111);
    4'd8: data_y = data_a >> (data_b & 16'b1111);
    4'd9: data_y = $signed(data_a) >>> (data_b & 16'b1111);
    4'd10: data_y = (data_a >> (16 - (data_b & 16'b1111))) + (data_a << (data_b & 16'b1111)); // {000111} -> {110001}, n = 4
    default: data_y = 16'b0;
  endcase
end

endmodule
