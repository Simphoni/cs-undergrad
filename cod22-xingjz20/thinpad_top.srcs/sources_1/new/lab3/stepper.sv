`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/18 12:14:46
// Design Name: 
// Module Name: stepper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stepper(
    input wire clk,
    input wire btn,
    output reg out
);
logic prevbtn_reg;
always_ff @ (posedge clk) begin
    if (prevbtn_reg == 0 && btn == 1) out <= 1;
    else out <= 0;
    prevbtn_reg <= btn;
end
endmodule
