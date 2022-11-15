`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/18 11:14:37
// Design Name: 
// Module Name: counter
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


module counter(
    input wire clk,
    input wire reset,
    input wire trigger,
    output wire [3:0] count
    );
    logic [3:0] count_reg;
    always_ff @ (posedge trigger or posedge reset) begin
        if (reset) begin
            count_reg <= 4'd0;
        end else begin
            case (count_reg)
                4'b1111: count_reg <= count_reg;
                default: count_reg <= count_reg + 4'b1;
            endcase
        end
    end
    assign count = count_reg;
endmodule