`timescale 1ns / 1ps
module controller (
    input wire clk,
    input wire reset,

    // connect to regfile
    output reg  [4:0]  rf_raddr_a,
    input  wire [15:0] rf_rdata_a,
    output reg  [4:0]  rf_raddr_b,
    input  wire [15:0] rf_rdata_b,
    output reg  [4:0]  rf_waddr,
    output reg  [15:0] rf_wdata,
    output reg  rf_we,

    // connect to alu
    output reg [15:0] alu_a,
    output reg [15:0] alu_b,
    output reg [ 3:0] alu_op,
    input  wire [15:0] alu_y,

    // control
    input  wire        step,    // btn
    input  wire [31:0] dip_sw,  // 32bit input
    output reg  [15:0] leds
);

  logic [31:0] inst_reg;

  logic is_rtype, is_itype, is_peek, is_poke;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  typedef enum logic [3:0] {
    ST_INIT,
    ST_DECODE,
    ST_CALC,
    ST_READ_REG,
    ST_WRITE_REG
  } state_t;
  state_t cur_state, next_state;

  always_comb begin
    is_rtype = (inst_reg[2:0] == 3'b001);
    is_itype = (inst_reg[2:0] == 3'b010);
    is_peek = is_itype && (inst_reg[6:3] == 4'b0010);
    is_poke = is_itype && (inst_reg[6:3] == 4'b0001);

    imm = inst_reg[31:16];
    rd = inst_reg[11:7];
    rs1 = inst_reg[19:15];
    rs2 = inst_reg[24:20];
    opcode = inst_reg[6:3];

    rf_raddr_a = is_peek ? rd : rs1;
    rf_raddr_b = rs2;
    alu_op = opcode;
    alu_a = rf_rdata_a;
    alu_b = rf_rdata_b;
    rf_waddr = rd;
    rf_wdata = is_rtype ? alu_y : imm; // will be peek if not calc
    rf_we = next_state == ST_WRITE_REG ? 1'b1 : 1'b0;
  end

  always_ff @(posedge clk) begin
    if (reset) cur_state <= ST_INIT;
    else cur_state <= next_state;
  end

  always_comb begin
    case(cur_state)
      ST_INIT: begin
        if (step)
          next_state = ST_DECODE;
        else
          next_state = ST_INIT;
      end
      ST_DECODE: begin
        if (is_rtype) // R-Type operation
          next_state = ST_CALC;
        else if (is_peek)
          next_state = ST_READ_REG;
        else if (is_poke)
          next_state = ST_WRITE_REG;
        else next_state = ST_INIT;  // illegal operation
      end
      ST_CALC: next_state = ST_WRITE_REG;
      ST_READ_REG: next_state = ST_INIT;
      ST_WRITE_REG: next_state = ST_INIT;
      default: next_state = ST_INIT;
    endcase
  end

  always_ff @(posedge clk) begin
    case(cur_state)
      ST_INIT: begin
        inst_reg <= dip_sw;
      end
      ST_DECODE: begin
        // do nothing
      end
      ST_CALC: begin
        // do nothing
      end
      ST_READ_REG: begin
        leds <= rf_rdata_a;
      end
      ST_WRITE_REG: begin
        
      end
      default: begin
      end
    endcase
  end

endmodule
