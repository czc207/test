module pwm_edge3(clk,Rst_n,pwm_in3,flag2_2,pwm3_11,pwm3_12);
   input clk;
	input Rst_n;
	input pwm_in3;
	input flag2_2;
	
	output reg pwm3_11;
	output reg pwm3_12;
	
	wire edge_pulse3;
	
	reg pwm_in3_sa,pwm_in3_sb;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)begin
	   pwm_in3_sa <= 1'b0;
		pwm_in3_sb <= 1'b0;
	end
	else begin
	   pwm_in3_sa <= pwm_in3;
		pwm_in3_sb <= pwm_in3_sa;
	end
	
	assign edge_pulse3 = pwm_in3_sa ^ pwm_in3_sb;
	
	reg [3:0]edge3_cnt;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)
	   edge3_cnt <= 4'd0;
	else if(flag2_2 == 1'b0)
	   edge3_cnt <= 4'd0;
	else if(edge_pulse3)
	begin
	   if(edge3_cnt == 4'd4)
		   edge3_cnt <= 4'd1;
		else 
	      edge3_cnt <= edge3_cnt + 1'b1; 		
	end
	else
	   edge3_cnt <= edge3_cnt;
		
	always @(posedge clk or negedge Rst_n)
	if (!Rst_n) begin
	   pwm3_11 <= 1'b1;
		pwm3_12 <= 1'b1;
	end 
	else begin
	   case (edge3_cnt)
		   4'd1:begin pwm3_11 <= 1'b0;pwm3_12 <= 1'b1;end
			4'd2:begin pwm3_11 <= 1'b1;pwm3_12 <= 1'b1;end
			4'd3:begin pwm3_11 <= 1'b1;pwm3_12 <= 1'b0;end
			4'd4:begin pwm3_11 <= 1'b1;pwm3_12 <= 1'b1;end
			default:begin pwm3_11 <= 1'b1;pwm3_12 <= 1'b1;end
		endcase
	end   
endmodule 