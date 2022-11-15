module lab5_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,

    // TODO: 添加�?要的控制信号，例如按键开关？
    input wire [31:0] dip_sw,

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);
  // TODO: 实现实验 5 的内�?+串口 Master
  typedef enum logic [3:0] {
    READ_WAIT_ACTION, // reading status reg
    READ_WAIT_CHECK,  // got status reg, examine it
    READ_DATA_ACTION, // reading data reg
    READ_DATA_DONE,   // done reading
    WRITE_SRAM_ACTION,
    WRITE_SRAM_DONE,
    WRITE_WAIT_ACTION,
    WRITE_WAIT_CHECK,
    WRITE_DATA_ACTION,
    WRITE_DATA_DONE
  } state_t;
  state_t state, nxt_state;

  reg [31:0] preset_addr;
  reg [31:0] uart_dat;
  reg [31:0] wb_tmp;

  always_comb begin
    nxt_state <= state;
    case(state)
      READ_WAIT_ACTION: begin
        if (wb_ack_i) nxt_state <= READ_WAIT_CHECK;
      end
      READ_WAIT_CHECK: begin
        if (wb_tmp[8] == 1'b1) // uart recv
          nxt_state <= READ_DATA_ACTION;
        else nxt_state <= READ_WAIT_ACTION;
      end
      READ_DATA_ACTION: begin
        if (wb_ack_i) nxt_state <= READ_DATA_DONE;
      end
      READ_DATA_DONE: begin
        nxt_state <= WRITE_SRAM_ACTION;
      end
      WRITE_SRAM_ACTION: begin
        if (wb_ack_i) nxt_state <= WRITE_SRAM_DONE;
      end
      WRITE_SRAM_DONE: begin
        nxt_state <= WRITE_WAIT_ACTION;
      end
      WRITE_WAIT_ACTION: begin
        if (wb_ack_i) nxt_state <= WRITE_WAIT_CHECK;
      end
      WRITE_WAIT_CHECK: begin
        if (wb_tmp[13] == 1'b1) nxt_state <= WRITE_DATA_ACTION;
        else nxt_state <= WRITE_WAIT_ACTION;
      end
      WRITE_DATA_ACTION: begin
        if (wb_ack_i) nxt_state <= WRITE_DATA_DONE;
      end
      WRITE_DATA_DONE: begin
        nxt_state <= READ_WAIT_ACTION;
      end
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      state <= READ_WAIT_ACTION;
      preset_addr <= {dip_sw[31:2], 2'b00};
    end
    else begin
      state <= nxt_state;
      if (wb_ack_i) begin
        wb_tmp <= wb_dat_i;
        if (state == READ_DATA_ACTION)
          uart_dat[7:0] <= wb_dat_i[7:0];
      end
      if (nxt_state == WRITE_SRAM_DONE)
        preset_addr <= preset_addr + 4;
    end
  end

  always_comb begin
    wb_adr_o = 32'b0;
    wb_dat_o = 32'b0;
    wb_cyc_o = 1'b0;
    wb_stb_o = 1'b0;
    wb_sel_o = 4'b0000;
    wb_we_o = 1'b0;
    case(state)
      READ_WAIT_ACTION: begin
        wb_adr_o = 32'h1000_0005;
        wb_sel_o = 4'b0010;
        wb_cyc_o = 1'b1;
        wb_stb_o = 1'b1;
      end
      READ_WAIT_CHECK: begin
      end
      READ_DATA_ACTION: begin
        wb_adr_o = 32'h1000_0000;
        wb_sel_o = 4'b0001;
        wb_cyc_o = 1'b1;
        wb_stb_o = 1'b1;
      end
      READ_DATA_DONE: begin
      end
      WRITE_SRAM_ACTION: begin
        wb_adr_o = preset_addr;
        wb_dat_o = uart_dat;
        wb_we_o = 1;
        wb_sel_o = 4'b0001;
        wb_cyc_o = 1'b1;
        wb_stb_o = 1'b1;
      end
      WRITE_SRAM_DONE: begin
      end
      WRITE_WAIT_ACTION: begin
        wb_adr_o = 32'h1000_0005;
        wb_sel_o = 4'b0010;
        wb_cyc_o = 1'b1;
        wb_stb_o = 1'b1;
      end
      WRITE_WAIT_CHECK: begin
      end
      WRITE_DATA_ACTION: begin
        wb_adr_o = 32'h1000_0000;
        wb_dat_o = uart_dat;
        wb_sel_o = 4'b0001;
        wb_cyc_o = 1'b1;
        wb_stb_o = 1'b1;
        wb_we_o = 1;
      end
      WRITE_DATA_DONE: begin
      end
    endcase
  end
  
  
endmodule
