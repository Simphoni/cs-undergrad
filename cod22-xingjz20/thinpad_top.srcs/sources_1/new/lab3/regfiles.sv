`timescale 1ns / 1ps
module regfiles(
  input wire clk,
  input wire [4:0] raddr_a,
  output reg [15:0] rdata_a,
  input wire [4:0] raddr_b,
  output reg [15:0] rdata_b,
  input wire [4:0]  waddr,
  input wire [15:0] wdata,
  input wire we
);
  reg [15:0] files [31:0];
  always_comb begin
    if (raddr_a == 5'b0)
      rdata_a = 16'b0;
    else
      rdata_a = files[raddr_a];
    if (raddr_b == 5'b0)
      rdata_b = 16'b0;
    else
      rdata_b = files[raddr_b];
  end
  always_ff @(posedge clk) begin
    if (we == 1'b1)
      files[waddr] <= wdata;
  end
endmodule
