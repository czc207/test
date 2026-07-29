module pwm_edge4(clk,Rst_n,pwm_in4,flag1_1,pwm4_11,pwm4_12);
   input clk;
	input Rst_n;
	input pwm_in4;
	input flag1_1;
	
	output reg pwm4_11;
	output reg pwm4_12;
	
	wire edge_pulse4;
	
	reg pwm_in4_sa,pwm_in4_sb;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)begin
	   pwm_in4_sa <= 1'b0;
		pwm_in4_sb <= 1'b0;
	end
	else begin
	   pwm_in4_sa <= pwm_in4;
		pwm_in4_sb <= pwm_in4_sa;
	end
	
	assign edge_pulse4 = pwm_in4_sa ^ pwm_in4_sb;
	
	reg [3:0]edge4_cnt;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)
	   edge4_cnt <= 4'd0;
	else if(flag1_1 == 1'b0)
	   edge4_cnt <= 4'd0;
	else if(edge_pulse4)
	begin
	   if(edge4_cnt == 4'd4)
		   edge4_cnt <= 4'd1;
		else 
	      edge4_cnt <= edge4_cnt + 1'b1; 		
	end
	else
	   edge4_cnt <= edge4_cnt;
		
	always @(posedge clk or negedge Rst_n)
	if (!Rst_n) begin
	   pwm4_11 <= 1'b1;
		pwm4_12 <= 1'b1;
	end 
	else begin
	   case (edge4_cnt)
		   4'd1:begin pwm4_11 <= 1'b0;pwm4_12 <= 1'b1;end
			4'd2:begin pwm4_11 <= 1'b1;pwm4_12 <= 1'b1;end
			4'd3:begin pwm4_11 <= 1'b1;pwm4_12 <= 1'b0;end
			4'd4:begin pwm4_11 <= 1'b1;pwm4_12 <= 1'b1;end
			default:begin pwm4_11 <= 1'b1;pwm4_12 <= 1'b1;end
		endcase
	end   
endmodule 