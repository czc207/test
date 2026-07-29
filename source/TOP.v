module TOP(
    input               sys_clk,    //system clock
    input               sys_rst_n,
    input               emif_clk,			// emif clock
    input               emif_cs_n,		// Active-low chip enable pin for SDRAM devices
    input               emif_oe_n,		// Active-low pin enable for asynchronous devices
    input               emif_we_n,		// Active-low write enable
    input    [9:0]      emif_addr,		// BRAM size: 1024 * 16bit, used 10bit address
    inout    [15:0]     emif_data,

    output  pwm1_11,pwm1_12,pwm2_11,pwm2_12,pwm3_11,pwm3_12,pwm4_11,pwm4_12,
    output  pwm1,pwm2,pwm3,pwm4
);
reg [15:0]t_z,n_z,d_z,s_z,t_f,n_f,d_f,s_f;
    // --- 地址映射定义 (可根据实际需求修改) ---
    //localparam ADDR_T_Z = 10'd0;
    //localparam ADDR_N_Z = 10'd1;
    //localparam ADDR_D_Z = 10'd2;
    //localparam ADDR_S_Z = 10'd3;
    //localparam ADDR_T_F = 10'd4;
    //localparam ADDR_N_F = 10'd5;
    //localparam ADDR_D_F = 10'd6;
    //localparam ADDR_S_F = 10'd7;

wire    [15:0]  dram_dout;
wire            write_en;
wire            read_en;
// 写使能有效信号：当片选和写使能同时为低时
assign write_en = (~emif_cs_n) && (~emif_we_n);
assign read_en = (~emif_cs_n) && (~emif_oe_n);

    // --- 写操作逻辑：接收来自处理器的参数 ---
    always @(posedge emif_clk) begin
        if (write_en) begin
            case (emif_addr[9:0])
                8'd0: t_z <= emif_data;
                8'd1: n_z <= emif_data;
                8'd2: d_z <= emif_data;
                8'd3: s_z <= emif_data;
                8'd4: t_f <= emif_data;
                8'd5: n_f <= emif_data;
                8'd6: d_f <= emif_data;
                8'd7: s_f <= emif_data;
                default: ; // 其他地址不处理
            endcase
        end
    end

    // --- 读操作逻辑：处理双向数据线 (三态控制) ---
    // 如果处理器需要读回这些参数，可以启用以下逻辑
    // 如果不需要读回功能，可直接 assign emif_data = 16'bz;
    reg [15:0] data_out;
    always @(posedge emif_clk) begin
        if (read_en) begin
            case (emif_addr[9:0])
                8'd0: data_out = t_z;
                8'd1: data_out = n_z;
                8'd2: data_out = d_z;
                8'd3: data_out = s_z;
                8'd4: data_out = t_f;
                8'd5: data_out = n_f;
                8'd6: data_out = d_f;
                8'd7: data_out = s_f;
                default:  data_out = 16'h0000;
            endcase
        end
    end

    // 当 CS 和 OE 同时为低时，驱动数据线输出（FPGA -> 处理器）
    // 否则，保持高阻态，释放总线给处理器驱动（处理器 -> FPGA）
    assign emif_data = read_en ? data_out : 16'bz;

wire pwm1,pwm2,pwm3,pwm4;
wire pwm_in1,pwm_in2,pwm_in3,pwm_in4;
wire lock;
assign pwm_in1 = pwm1 && pwm_in1;
assign pwm_in2 = pwm2 && pwm_in2;
assign pwm_in3 = pwm3 && pwm_in3;
assign pwm_in4 = pwm4 && pwm_in4;


PWM_div PWM_div(
  .clkin1       (sys_clk),                  // 24MHz
  .pll_lock     (),
  .clkout0      (pwm_clk),                  // 5MHz
  .clkout1      (clk)          		    // 150MHz
);

single single(
  .emif_clk     (emif_clk),
  .pwm_clk      (pwm_clk),                    
  .clk          (clk),                    
  .t_z          (t_z),                        //
  .n_z          (n_z),          			  // 
  .d_z          (d_z),                        //
  .s_z          (s_z),                        // 
  .t_f          (t_f),
  .n_f          (n_f),
  .d_f          (d_f),
  .s_f          (s_f),
  .lock         (lock),
  .flag1        (flag1),
  .flag2        (flag2),
  .pwm1         (pwm1), 
  .pwm2         (pwm2),
  .pwm3         (pwm3),
  .pwm4         (pwm4)
);

pwm_edge1 pwm_edge1(
  .clk          (clk),
  .Rst_n        (sys_rst_n),
  .flag1_1      (flag1),
  .pwm_in1      (pwm1),
  .pwm1_11      (pwm1_11), 
  .pwm1_12      (pwm1_12)
);

pwm_edge2 pwm_edge2(
  .clk          (clk),
  .Rst_n        (sys_rst_n),
  .flag2_2      (flag2),
  .pwm_in2      (pwm2),
  .pwm2_11      (pwm2_11), 
  .pwm2_12      (pwm2_12)
);

pwm_edge3 pwm_edge3(
  .clk          (clk),
  .Rst_n        (sys_rst_n),
  .flag2_2      (flag2),
  .pwm_in3      (pwm3),
  .pwm3_11      (pwm3_11), 
  .pwm3_12      (pwm3_12)
);

pwm_edge4 pwm_edge4(
  .clk          (clk),
  .Rst_n        (sys_rst_n),
  .flag1_1      (flag1),
  .pwm_in4      (pwm4),
  .pwm4_11      (pwm4_11), 
  .pwm4_12      (pwm4_12)
);

endmodule
