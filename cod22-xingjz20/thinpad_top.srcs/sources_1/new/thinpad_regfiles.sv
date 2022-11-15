`timescale 1ns / 1ps
module thinpad_regfiles(
  input wire clk,
  input wire [4:0] addr_a,
  output reg [31:0] data_a,
  input wire [4:0] addr_b,
  output reg [31:0] data_b,
  input wire [4:0] addr_d,
  input wire [31:0] data_d,
  input wire we
);
  reg [31:0] files [31:0];
  always_comb begin
    if (addr_a == 5'b0)
      data_a = 32'b0;
    else
      data_a = files[addr_a];
    if (addr_b == 5'b0)
      data_b = 32'b0;
    else
      data_b = files[addr_b];
  end
  always_ff @(posedge clk) begin
    if (we == 1'b1)
      files[addr_d] <= data_d;
  end
endmodule
