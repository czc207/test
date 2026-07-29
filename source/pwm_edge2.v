module pwm_edge2(clk,Rst_n,pwm_in2,flag2_2,pwm2_11,pwm2_12);
   input clk;
	input Rst_n;
	input pwm_in2;
	input flag2_2;
	
	output reg pwm2_11;
	output reg pwm2_12;
	
	wire edge_pulse2;
	
	reg pwm_in2_sa,pwm_in2_sb;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)begin
	   pwm_in2_sa <= 1'b0;
		pwm_in2_sb <= 1'b0;
	end
	else begin
	   pwm_in2_sa <= pwm_in2;
		pwm_in2_sb <= pwm_in2_sa;
	end
	
	assign edge_pulse2 = pwm_in2_sa ^ pwm_in2_sb;
	
	reg [3:0]edge2_cnt;
	always@(posedge clk or negedge Rst_n)
	if(!Rst_n)
	   edge2_cnt <= 4'd0;
	else if(flag2_2 == 1'b0)
	   edge2_cnt <= 4'd0;
	else if(edge_pulse2)
	begin
	   if(edge2_cnt == 4'd4)
		   edge2_cnt <= 4'd1;
		else 
	      edge2_cnt <= edge2_cnt + 1'b1; 		
	end
	else
	   edge2_cnt <= edge2_cnt;
		
	always @(posedge clk or negedge Rst_n)
	if (!Rst_n) begin
	   pwm2_11 <= 1'b1;
		pwm2_12 <= 1'b1;
	end 
	else begin
	   case (edge2_cnt)
		   4'd1:begin pwm2_11 <= 1'b0;pwm2_12 <= 1'b1;end
			4'd2:begin pwm2_11 <= 1'b1;pwm2_12 <= 1'b1;end
			4'd3:begin pwm2_11 <= 1'b1;pwm2_12 <= 1'b0;end
			4'd4:begin pwm2_11 <= 1'b1;pwm2_12 <= 1'b1;end
			default:begin pwm2_11 <= 1'b1;pwm2_12 <= 1'b1;end
		endcase
	end   
endmodule 