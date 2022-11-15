module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n
);

  // TODO: 实现 SRAM 控制�?
  typedef enum logic [3:0] {
    ST_IDLE,
    ST_READ,
    ST_READ_2,
    ST_DONE,
    ST_WRITE,
    ST_WRITE_2,
    ST_WRITE_3
  } state_t;
  state_t state;

  wire [31:0] sram_data_i_comb;
  reg [31:0] sram_data_o_comb;
  reg sram_data_t_comb;

  assign sram_data = sram_data_t_comb ? 32'bz : sram_data_o_comb;
  assign sram_data_i_comb = sram_data;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      state <= ST_IDLE;
      wb_ack_o <= 1'b0;
      sram_ce_n <= 1'b1;
      sram_oe_n <= 1'b1;
      sram_we_n <= 1'b1;
      sram_data_t_comb <= 1'b1;
    end
    else if (state == ST_IDLE) begin
      wb_ack_o <= 1'b0;
      sram_ce_n <= 1'b1;
      if (wb_stb_i && wb_cyc_i) begin // STB==CYC
        sram_ce_n <= 1'b0;
        sram_be_n <= ~wb_sel_i;
        sram_addr <= wb_adr_i[21:2];
        if (wb_we_i) begin // write
          sram_data_t_comb <= 1'b0; // output mode
          sram_data_o_comb <= wb_dat_i;
          state <= ST_WRITE;
        end
        else begin // read
          sram_oe_n <= 1'b0;
          state <= ST_READ;
        end
      end
    end
    else if (state == ST_READ) begin // controller get the signal
      state <= ST_READ_2;
    end
    else if (state == ST_READ_2) begin
      wb_ack_o <= 1'b1;
      wb_dat_o <= sram_data_i_comb;
      //if (wb_sel_i[0])
      //  wb_dat_o[7:0] <= sram_data_i_comb[7:0];
      //if (wb_sel_i[1])
      //  wb_dat_o[15:8] <= sram_data_i_comb[15:8];
      //if (wb_sel_i[2])
      //  wb_dat_o[23:16] <= sram_data_i_comb[23:16];
      //if (wb_sel_i[3])
      //  wb_dat_o[31:24] <= sram_data_i_comb[31:24];
      state <= ST_DONE;
      sram_ce_n <= 1'b1;
    end
    else if (state == ST_WRITE) begin // SRAM get the signal, calls read
      sram_we_n <= 1'b0;
      state <= ST_WRITE_2;
    end
    else if (state == ST_WRITE_2) begin // SRAM gets the signal, calls write
      sram_we_n <= 1'b1;
      state <= ST_WRITE_3;
    end
    else if (state == ST_WRITE_3) begin // done writing
      wb_ack_o <= 1'b1;
      sram_ce_n <= 1'b1;
      state <= ST_DONE;
    end
    else if (state == ST_DONE) begin
      sram_data_t_comb <= 1'b1; // input mode
      sram_oe_n <= 1'b1;
      sram_we_n <= 1'b1;
      wb_ack_o <= 1'b0;
      state <= ST_IDLE;
    end
  end
endmodule
