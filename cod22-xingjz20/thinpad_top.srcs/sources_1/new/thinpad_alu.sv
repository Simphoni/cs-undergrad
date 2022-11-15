`timescale 1ns / 1ps
module thinpad_alu(
  input wire [31:0] data_a,
  input wire [31:0] data_b,
  input wire [2:0] op,
  output reg [31:0] data_y
);

always_comb begin
  case(op)
    3'b000: data_y = data_a + data_b;
    3'b111: data_y = data_a & data_b;
    default: data_y = 32'b0;
  endcase
end

endmodule
