`default_nettype none

module thinpad_top (
    input wire clk_50M,     // 50MHz 时钟输入
    input wire clk_11M0592, // 11.0592MHz 时钟输入（备用，可不用）

    input wire push_btn,  // BTN5 按钮??关，带消抖电路，按下时为 1
    input wire reset_btn, // BTN6 复位按钮，带消抖电路，按下时?? 1

    input  wire [ 3:0] touch_btn,  // BTN1~BTN4，按钮开关，按下时为 1
    input  wire [31:0] dip_sw,     // 32 位拨码开关，拨到“ON”时?? 1
    output wire [15:0] leds,       // 16  LED，输出时 1 点亮
    output wire [ 7:0] dpy0,       // 数码管低位信号，包括小数点，输出 1 点亮
    output wire [ 7:0] dpy1,       // 数码管高位信号，包括小数点，输出 1 点亮

    // CPLD 串口控制器信�???
    output wire uart_rdn,        // 读串口信号，低有??
    output wire uart_wrn,        // 写串口信号，低有??
    input  wire uart_dataready,  // 串口数据准备??
    input  wire uart_tbre,       // 发数据标
    input  wire uart_tsre,       // 数据发完毕标

    // BaseRAM 信号
    inout wire [31:0] base_ram_data,  // BaseRAM 数据，低 8 位与 CPLD 串口控制器共?
    output wire [19:0] base_ram_addr,  // BaseRAM 地址
    output wire [3:0] base_ram_be_n,  // BaseRAM 字节使能，低有效。如果不使用字节使能，请保持 0
    output wire base_ram_ce_n,  // BaseRAM 片，低有
    output wire base_ram_oe_n,  // BaseRAM 读使能，低有
    output wire base_ram_we_n,  // BaseRAM 写使能，低有

    // ExtRAM 信号
    inout wire [31:0] ext_ram_data,  // ExtRAM 数据
    output wire [19:0] ext_ram_addr,  // ExtRAM 地址
    output wire [3:0] ext_ram_be_n,  // ExtRAM 字节使能，低有效。如果不使用字节使能，请保持
    output wire ext_ram_ce_n,  // ExtRAM 片，低有
    output wire ext_ram_oe_n,  // ExtRAM 读使能，低有
    output wire ext_ram_we_n,  // ExtRAM 写使能，低有

    // 直连串口信号
    output wire txd,  // 直连串口发端
    input  wire rxd,  // 直连串口接收

    // Flash 存储器信号，�? JS28F640 芯片�?
    output wire [22:0] flash_a,  // Flash 地址，a0 仅在 8bit 模式有效16bit 模式无意
    inout wire [15:0] flash_d,  // Flash 数据
    output wire flash_rp_n,  // Flash 复位信号，低有效
    output wire flash_vpen,  // Flash 写保护信号，低电平时不能擦除、烧
    output wire flash_ce_n,  // Flash 片�?�信号，低有
    output wire flash_oe_n,  // Flash 读使能信号，低有
    output wire flash_we_n,  // Flash 写使能信号，低有
    output wire flash_byte_n, // Flash 8bit 模式选择，低有效。在使用 flash 16 位模式时请设 1

    // USB 控制器信号，�? SL811 芯片手册
    output wire sl811_a0,
    // inout  wire [7:0] sl811_d,     // USB 数据线与网络控制器的 dm9k_sd[7:0] 共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    // 网络控制器信号，�? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout wire [15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input wire dm9k_int,

    // 图像输出信号
    output wire [2:0] video_red,    // 红色像素
    output wire [2:0] video_green,  // 绿色像素
    output wire [1:0] video_blue,   // 蓝色像素
    output wire       video_hsync,  // 行同步（水平同步）信
    output wire       video_vsync,  // 场同步（垂直同步）信
    output wire       video_clk,    // 像素时钟输出
    output wire       video_de      // 行数据有效信号，用于区分消隐
);
  // 本实验不使用 CPLD 串口，禁用防止线冲突
  assign uart_rdn = 1'b1;
  assign uart_wrn = 1'b1;

  typedef enum logic [3:0] {
    ST_IF, ST_ID, ST_EXE, ST_DM, ST_WB 
  } state_t;
  state_t state, nxt_state;

  typedef enum logic[3:0] {
    R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE
  } instr_t;
  instr_t instr_type, instr_type_comb;

  logic [2:0] funct3;
  logic [31:0] pc;
  logic [31:0] pc_a4;
  logic [31:0] pc_nxt;
  logic [31:0] instr;
  logic [4:0] addr_a;
  logic [4:0] rs1;
  logic [31:0] data_a;
  logic [4:0] addr_b;
  logic [4:0] rs2;
  logic [31:0] data_b;
  logic [4:0] addr_d;
  logic [31:0] data_d;
  logic [31:0] imm_out_comb;
  logic [31:0] imm_out;
  logic [31:0] mux_a_out;
  logic [31:0] mux_b_out;
  logic [31:0] alu_out;
  logic [31:0] alu_out_i;
  logic [31:0] dm_out;
  logic [2:0] alu_sel;
  logic [6:0] opcode;
  logic pc_sel;
  logic rf_we;
  logic imm_sel;
  logic brun;
  logic breq;
  logic brlt;
  logic b_sel;
  logic a_sel;
  // logic dm_we;
  logic reg_wb_sel;

  
  /* =========== Lab5 MUX begin =========== */
  // Wishbone MUX (Masters) => bus slaves
  logic sys_clk;
  logic sys_rst;

  assign sys_clk = clk_50M;
  assign sys_rst = reset_btn;

  logic        wbm_cyc_o;
  logic        wbm_stb_o;
  logic        wbm_ack_i;
  logic [31:0] wbm_adr_o;
  logic [31:0] wbm_dat_o;
  logic [31:0] wbm_dat_i;
  logic [ 3:0] wbm_sel_o;
  logic        wbm_we_o;

  logic wbs0_cyc_o;
  logic wbs0_stb_o;
  logic wbs0_ack_i;
  logic [31:0] wbs0_adr_o;
  logic [31:0] wbs0_dat_o;
  logic [31:0] wbs0_dat_i;
  logic [3:0] wbs0_sel_o;
  logic wbs0_we_o;

  logic wbs1_cyc_o;
  logic wbs1_stb_o;
  logic wbs1_ack_i;
  logic [31:0] wbs1_adr_o;
  logic [31:0] wbs1_dat_o;
  logic [31:0] wbs1_dat_i;
  logic [3:0] wbs1_sel_o;
  logic wbs1_we_o;

  logic wbs2_cyc_o;
  logic wbs2_stb_o;
  logic wbs2_ack_i;
  logic [31:0] wbs2_adr_o;
  logic [31:0] wbs2_dat_o;
  logic [31:0] wbs2_dat_i;
  logic [3:0] wbs2_sel_o;
  logic wbs2_we_o;

  wb_mux_3 wb_mux (
      .clk(sys_clk),
      .rst(sys_rst),

      // Master interface (to Lab5 master)
      .wbm_adr_i(wbm_adr_o),
      .wbm_dat_i(wbm_dat_o),
      .wbm_dat_o(wbm_dat_i),
      .wbm_we_i (wbm_we_o),
      .wbm_sel_i(wbm_sel_o),
      .wbm_stb_i(wbm_stb_o),
      .wbm_ack_o(wbm_ack_i),
      .wbm_err_o(),
      .wbm_rty_o(),
      .wbm_cyc_i(wbm_cyc_o),

      // Slave interface 0 (to BaseRAM controller)
      // Address range: 0x8000_0000 ~ 0x803F_FFFF
      .wbs0_addr    (32'h8000_0000),
      .wbs0_addr_msk(32'hFFC0_0000),

      .wbs0_adr_o(wbs0_adr_o),
      .wbs0_dat_i(wbs0_dat_i),
      .wbs0_dat_o(wbs0_dat_o),
      .wbs0_we_o (wbs0_we_o),
      .wbs0_sel_o(wbs0_sel_o),
      .wbs0_stb_o(wbs0_stb_o),
      .wbs0_ack_i(wbs0_ack_i),
      .wbs0_err_i('0),
      .wbs0_rty_i('0),
      .wbs0_cyc_o(wbs0_cyc_o),

      // Slave interface 1 (to ExtRAM controller)
      // Address range: 0x8040_0000 ~ 0x807F_FFFF
      .wbs1_addr    (32'h8040_0000),
      .wbs1_addr_msk(32'hFFC0_0000),

      .wbs1_adr_o(wbs1_adr_o),
      .wbs1_dat_i(wbs1_dat_i),
      .wbs1_dat_o(wbs1_dat_o),
      .wbs1_we_o (wbs1_we_o),
      .wbs1_sel_o(wbs1_sel_o),
      .wbs1_stb_o(wbs1_stb_o),
      .wbs1_ack_i(wbs1_ack_i),
      .wbs1_err_i('0),
      .wbs1_rty_i('0),
      .wbs1_cyc_o(wbs1_cyc_o),

      // Slave interface 2 (to UART controller)
      // Address range: 0x1000_0000 ~ 0x1000_FFFF
      .wbs2_addr    (32'h1000_0000),
      .wbs2_addr_msk(32'hFFFF_0000),

      .wbs2_adr_o(wbs2_adr_o),
      .wbs2_dat_i(wbs2_dat_i),
      .wbs2_dat_o(wbs2_dat_o),
      .wbs2_we_o (wbs2_we_o),
      .wbs2_sel_o(wbs2_sel_o),
      .wbs2_stb_o(wbs2_stb_o),
      .wbs2_ack_i(wbs2_ack_i),
      .wbs2_err_i('0),
      .wbs2_rty_i('0),
      .wbs2_cyc_o(wbs2_cyc_o)
  );

  /* =========== Lab5 MUX end =========== */

  /* =========== Lab5 Slaves begin =========== */
  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_base (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs0_cyc_o),
      .wb_stb_i(wbs0_stb_o),
      .wb_ack_o(wbs0_ack_i),
      .wb_adr_i(wbs0_adr_o),
      .wb_dat_i(wbs0_dat_o),
      .wb_dat_o(wbs0_dat_i),
      .wb_sel_i(wbs0_sel_o),
      .wb_we_i (wbs0_we_o),

      // To SRAM chip
      .sram_addr(base_ram_addr),
      .sram_data(base_ram_data),
      .sram_ce_n(base_ram_ce_n),
      .sram_oe_n(base_ram_oe_n),
      .sram_we_n(base_ram_we_n),
      .sram_be_n(base_ram_be_n)
  );

  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_ext (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs1_cyc_o),
      .wb_stb_i(wbs1_stb_o),
      .wb_ack_o(wbs1_ack_i),
      .wb_adr_i(wbs1_adr_o),
      .wb_dat_i(wbs1_dat_o),
      .wb_dat_o(wbs1_dat_i),
      .wb_sel_i(wbs1_sel_o),
      .wb_we_i (wbs1_we_o),

      // To SRAM chip
      .sram_addr(ext_ram_addr),
      .sram_data(ext_ram_data),
      .sram_ce_n(ext_ram_ce_n),
      .sram_oe_n(ext_ram_oe_n),
      .sram_we_n(ext_ram_we_n),
      .sram_be_n(ext_ram_be_n)
  );

  // 串口控制器模�???
  // NOTE: 如果修改系统时钟频率，也�???要修改此处的时钟频率参数
  uart_controller #(
      .CLK_FREQ(50_000_000),
      .BAUD    (115200)
  ) uart_controller (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      .wb_cyc_i(wbs2_cyc_o),
      .wb_stb_i(wbs2_stb_o),
      .wb_ack_o(wbs2_ack_i),
      .wb_adr_i(wbs2_adr_o),
      .wb_dat_i(wbs2_dat_o),
      .wb_dat_o(wbs2_dat_i),
      .wb_sel_i(wbs2_sel_o),
      .wb_we_i (wbs2_we_o),

      // to UART pins
      .uart_txd_o(txd),
      .uart_rxd_i(rxd)
  );

  /* =========== Lab5 Slaves end =========== */

  assign rs1 = instr[19:15];
  assign rs2 = instr[24:20];
  assign addr_d = instr[11: 7];
  assign funct3 = instr[14:12];
  assign opcode = instr[6:0];

  // eval state & pc
  always_ff @(posedge clk_50M) begin
    if (reset_btn) begin
      pc <= 32'h8000_0000;
      state <= ST_IF;
    end
    else begin
      if (state != ST_IF && nxt_state == ST_IF)
        pc <= pc_nxt;
      state <= nxt_state;
    end
  end

  // a_sel: 0 = pc, 1 = data_a
  always_comb begin
    a_sel = 1'b1; // default: data_a
    if (instr_type == B_TYPE) a_sel = 1'b0;
  end
  assign mux_a_out = a_sel ? data_a : pc;

  // b_sel: 0 = imm, 1 = data_b
  always_comb begin
    b_sel = 1'b0; // default: imm
    if (instr_type == R_TYPE) b_sel = 1'b1;
  end
  assign mux_b_out = b_sel ? data_b : imm_out;

  // reg_wb_mux
  // reg_wb_sel: 0 = pc_a4, 1 = dm_out, 2 = alu_out
  always_ff @(posedge clk_50M) begin
    if (nxt_state == ST_WB) begin
      if (opcode == 7'b011_0111) data_d <= imm_out;
      else if (opcode == 7'b000_0011) data_d <= wbm_dat_i;
      else data_d <= alu_out_i;
    end
  end

  // eval pc_nxt
  always_comb begin
    pc_nxt = pc_a4;
    if (opcode == 7'b110_0011) begin
      if (breq) pc_nxt = alu_out;
    end
  end

  // eval nxt_state
  always_comb begin
    case(state)
      ST_IF: begin
        nxt_state = wbm_ack_i ? ST_ID : ST_IF;
      end
      ST_ID: begin
        nxt_state = ST_EXE;
      end
      ST_EXE: begin
        case(opcode)
          7'b000_0011: nxt_state = ST_DM;
          7'b010_0011: nxt_state = ST_DM;
          default: nxt_state = ST_WB;
        endcase
      end
      ST_DM: begin
        if (wbm_ack_i) begin
          case(opcode)
            7'b000_0011: nxt_state = ST_WB;
            default: nxt_state = ST_IF;
          endcase
        end
        else nxt_state = ST_DM;
      end
      ST_WB: begin
        nxt_state = ST_IF;
      end
      default: nxt_state = ST_IF;
    endcase
  end

  // eval pc_a4, instr, instr_type, dm_out
  always_ff @(posedge clk_50M) begin
    case(state)
      ST_IF: begin
        pc_a4 <= pc + 4;
        if (wbm_ack_i == 1'b1) instr <= wbm_dat_i;
      end
      ST_ID: begin
        instr_type <= instr_type_comb;
        imm_out <= imm_out_comb;
        addr_a <= rs1;
        addr_b <= rs2;
      end
      ST_EXE: begin
        alu_out <= alu_out_i;
      end
      ST_DM: begin
        if (wbm_ack_i == 1'b1) dm_out <= wbm_dat_i;
      end
    endcase
  end

  // branch mod
  assign breq = (data_a == data_b);
  assign brlt = (data_a < data_b);


  // instr_type
  always_comb begin
    instr_type_comb = R_TYPE;
    if (state == ST_ID) begin
      case (opcode)
        7'b0110111: instr_type_comb = U_TYPE; // LUI
        7'b1100011: instr_type_comb = B_TYPE; // BEQ
        7'b0000011: instr_type_comb = I_TYPE; // LB
        7'b0100011: instr_type_comb = S_TYPE; // SB, WB
        7'b0010011: instr_type_comb = I_TYPE; // ADDI, ANDI
        7'b0110011: instr_type_comb = R_TYPE; // ADD
        default: instr_type_comb = R_TYPE;
      endcase
    end
  end
  // immgen
  always_comb begin
    imm_out_comb = 32'b0;
    if (state == ST_ID) begin
      case(instr_type_comb)
        I_TYPE: imm_out_comb = { {20{instr[31]}}, instr[31:20] }; // 20 + 12
        S_TYPE: imm_out_comb = { {20{instr[31]}}, instr[31:25], instr[11:7] }; // 15 + 7 + 5
        B_TYPE: imm_out_comb = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 }; // 19 + 1 + 1 + 6 + 4 + 1
        U_TYPE: imm_out_comb = { instr[31:12], 12'b0 }; // 12 + 20
        default: imm_out_comb = 32'b0;
      endcase
    end
  end

  // mem control
  always_comb begin
    wbm_adr_o = 32'b0;
    wbm_dat_o = 32'b0;
    wbm_cyc_o = 1'b0;
    wbm_stb_o = 1'b0;
    wbm_sel_o = 4'b0000;
    wbm_we_o = 1'b0;
    rf_we = 1'b0;
    case (state)
      ST_IF: begin
        wbm_adr_o = pc;
        wbm_cyc_o = 1'b1;
        wbm_stb_o = 1'b1;
        wbm_sel_o = 4'b1111;
        wbm_we_o = 1'b0;
      end
      ST_DM: begin
        wbm_adr_o = alu_out;
        wbm_dat_o = data_b;
        wbm_cyc_o = 1'b1;
        wbm_stb_o = 1'b1;
        case (funct3)
          3'b000: wbm_sel_o = 4'b0001;
          default: wbm_sel_o = 4'b1111;
        endcase
        if (opcode == 7'b010_0011) wbm_we_o = 1'b1;
        else wbm_we_o = 1'b0;
      end
      ST_WB: begin
        rf_we = 1'b1;
      end
    endcase
  end

  thinpad_regfiles rf (
    .clk(clk_50M),
    .addr_a(addr_a),
    .data_a(data_a),
    .addr_b(addr_b),
    .data_b(data_b),
    .addr_d(addr_d),
    .data_d(data_d),
    .we(rf_we)
  );

  always_ff @(posedge clk_50M) begin
    if (state == ST_ID) begin
      if (opcode == 7'b0010011 || opcode == 7'b0110011)
        alu_sel <= funct3;
      else alu_sel <= 3'b000;
    end
  end
  thinpad_alu alu(
    .data_a(mux_a_out),
    .data_b(mux_b_out),
    .op(alu_sel),
    .data_y(alu_out_i)
  );

/*

  lab5_master #(
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32)
  ) u_lab5_master (
      .clk_i(sys_clk),
      .rst_i(sys_rst),
      .dip_sw(dip_sw),
      // wishbone master
      .wb_cyc_o(wbm_cyc_o),
      .wb_stb_o(wbm_stb_o),
      .wb_ack_i(wbm_ack_i),
      .wb_adr_o(wbm_adr_o),
      .wb_dat_o(wbm_dat_o),
      .wb_dat_i(wbm_dat_i),
      .wb_sel_o(wbm_sel_o),
      .wb_we_o (wbm_we_o)
  );
*/

endmodule
