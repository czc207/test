/**
 * Copyright (C) 2013 Guangzhou Tronlong Electronic Technology Co., Ltd. - www.tronlong.com
 *
 * @file dram_emif.v
 *
 * @brief save emif bus data to fpga dram, send fpga dram data to emif bus.
 *
 * @author Tronlong <support@tronlong.com>
 *
 * @version V1.0
 *
 * @date 2022-06-09
 *
 **/

module dram_emif(
    input               emif_clk,			// emif clock
    input               emif_cs_n,		// Active-low chip enable pin for SDRAM devices
    input               emif_oe_n,		// Active-low pin enable for asynchronous devices
    input               emif_we_n,		// Active-low write enable
    input    [9:0]      emif_addr,		// BRAM size: 1024 * 16bit, used 10bit address
    inout    [15:0]     emif_data,

    // 增加 8 个参数的输出端口，供 FPGA 内部逻辑使用
    output reg [15:0]   t_z,
    output reg [15:0]   n_z,
    output reg [15:0]   d_z,
    output reg [15:0]   s_z,
    output reg [15:0]   t_f,
    output reg [15:0]   n_f,
    output reg [15:0]   d_f,
    output reg [15:0]   s_f
);

wire    [15:0]  dram_dout;
wire            write_en;

// 写使能有效信号：当片选和写使能同时为低时
assign write_en = (~emif_cs_n) && (~emif_we_n);

/**
 * 参数锁存逻辑
 * 对应 DSP 端的 write_buffer[0] - write_buffer[7]
 */
always @(posedge emif_clk) begin
    if (write_en) begin
        case (emif_addr)
            10'd0 : t_z <= emif_data;
            10'd1 : n_z <= emif_data;
            10'd2 : d_z <= emif_data;
            10'd3 : s_z <= emif_data;
            10'd4 : t_f <= emif_data;
            10'd5 : n_f <= emif_data;
            10'd6 : d_f <= emif_data;
            10'd7 : s_f <= emif_data;
            default: ; // 其他地址不处理
        endcase
    end
end

single_port_ram single_port_ram(
  .wr_data      (emif_data),                        // input [15:0]
  .addr         (emif_addr),                        // input [9:0]
  .clk          (emif_clk),                         // input
  .wr_en        (~emif_we_n),          				// input
  .rst          (1'b0),                             // input
  .rd_data      (dram_dout)                         // output [15:0]
);

// Asynchronous Read Operations: emif_cs_n & emif_oe_n
assign emif_data = ((emif_cs_n == 1'b0) && (emif_oe_n == 1'b0)) ? dram_dout : 16'bZ;

endmodule