module pwm_edge1(clk,Rst_n,pwm_in1,flag1_1,pwm1_11,pwm1_12);
   input clk;
	input Rst_n;
	input pwm_in1;//pwm1作为输入
	input flag1_1;//flag1
	
	output reg pwm1_11;//分频1路pwm波
	output reg pwm1_12;//分频2路pwm波
	
	wire edge_pulse1;//定义脉冲边沿信号用于检测pwm_in1的上升沿或者下降沿
	
	//采用打两拍方式将异步信号进行同步处理
	reg pwm_in1_sa,pwm_in1_sb;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)begin
	   pwm_in1_sa <= 1'b0;//上一时刻pwm信号
		pwm_in1_sb <= 1'b0;//现在时刻pwm信号
	end
	else begin
	   pwm_in1_sa <= pwm_in1;
		pwm_in1_sb <= pwm_in1_sa;
	end
	
	assign edge_pulse1 = pwm_in1_sa ^ pwm_in1_sb;//两时刻异或，则只要出现从高电平到低电平或者从低电平到高电平的变化时脉冲边沿信号便会有一个时钟信号周期的高电平脉冲
	
	reg [3:0]edge1_cnt;//定义一个对脉冲边沿信号进行计数的计数器
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)//复位或者flag1为0时，证明此时不需要此路信号发波，则将计数器清零
	   edge1_cnt <= 4'd0;
	else if(flag1_1 == 1'b0)
	   edge1_cnt <= 4'd0;
	else if(edge_pulse1)//根据脉冲边沿信号进行计数，本程序为2分频，则定义计数器最大计数到4，即4个状态
	begin
	   if(edge1_cnt == 4'd4)
		   edge1_cnt <= 4'd1;
		else 
	      edge1_cnt <= edge1_cnt + 1'b1; 		
	end
	else
	   edge1_cnt <= edge1_cnt;
	

	always @(posedge clk or negedge Rst_n)
	if (!Rst_n) begin
	   pwm1_11 <= 1'b1;
		pwm1_12 <= 1'b1;
	end 
	else begin
	   case (edge1_cnt)
		4'd1:begin pwm1_11 <= 1'b0;pwm1_12 <= 1'b1;end//第一个时钟边沿时，是1路pwm的第一个脉冲下降沿，此时第一路分频发第一个脉冲，第二路分频不发脉冲，所以1和2路状态为01
		4'd2:begin pwm1_11 <= 1'b1;pwm1_12 <= 1'b1;end//第二个时钟边沿时，是1路pwm的第一个脉冲上升沿，此时第一路分频发第一个脉冲结束，第二路分频不发脉冲，所以1和2路状态为11
			4'd3:begin pwm1_11 <= 1'b1;pwm1_12 <= 1'b0;end//第三个时钟边沿时，是1路pwm的第二个脉冲下降沿，此时第二路分频发第二个脉冲，第一路分频不发脉冲，所以1和2路状态为10
			4'd4:begin pwm1_11 <= 1'b1;pwm1_12 <= 1'b1;end//第四个时钟边沿时，是1路pwm的第二个脉冲上升沿，此时第二路分频发第二个脉冲结束，第一路分频不发脉冲，所以1和2路状态为11
			default:begin pwm1_11 <= 1'b1;pwm1_12 <= 1'b1;end
		endcase
	end   
endmodule 