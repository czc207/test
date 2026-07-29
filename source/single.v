
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:11:31 06/17/2023 
// Design Name: 
// Module Name:    single 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module single(emif_clk,pwm_clk,clk,t_z,d_z,n_z,s_z,t_f,d_f,n_f,s_f,lock,flag1,flag2,pwm1,pwm2,pwm3,pwm4); 

input  clk;         //时钟信号150Mhz
input  pwm_clk;     //pwm分频时钟 5MKhz 
input  emif_clk;
//input  data_change; //数据帧更新信号
input  [15:0]t_z,n_z,d_z,s_z,t_f,n_f,d_f,s_f;//数据帧数据

output reg pwm1,pwm2,pwm3,pwm4; //输出4路pwm  Pwm1对应1管；Pwm2对应2管；Pwm4对应4管；
output reg flag1;           //正向脉宽有效标志位  
output reg flag2;           //负向脉宽有效标志位
output wire lock;     //故障锁定信号
//输入校验寄存器
reg [15:0]t1;         
reg [15:0]t2;
reg [15:0]d1;
reg [15:0]d2;
reg [15:0]n1;       //正脉冲个数1-50
reg [15:0]n2;       //负脉冲个数0-50
reg [15:0]s1;
reg [15:0]s2;

reg [31:0]counter;  //整帧数据计数寄存器
reg [15:0]counter1; //正向数据计数寄存器
reg [15:0]counter2; //负向数据计数寄存器
reg [31:0]period;   //全周期寄存器
reg [15:0]period1;  //正周期寄存器  100-3000Hz
reg [15:0]period2;  //负周期寄存器  100-3000Hz
reg [15:0]dd1;      //正占空比脉宽  3%-60%
reg [15:0]dd2;      //负占空比脉宽  3%-60%
reg [15:0]ss1;      //正向换相脉宽，最大130ms  每5000个单位量化为1ms   精度为0.2us
reg [15:0]ss2;      //负向换相脉宽，最大130ms  每5000个单位量化为1ms

parameter start1=1;
parameter deadtime=90;//换相死区为18us
//initial 
//begin
// flag1<=1;
// flag2<=0;
// t1<=5000;
// t2<=2500;
// d1<=2500;
// d2<=1000;
// n1<=5;
// n2<=3;
// s1<=50;
// s2<=50;
// pwm1<=0;
// pwm2<=0;
// pwm3<=0;
// pwm4<=0;
//end

always@(posedge clk)
begin
  if(t_z<=1666) t1<=1666;
  else if(t_z>1666 && t_z<50000) t1<=t_z;
  else t1<=50000;
 
  if(t_f<=1666) t2<=1666;
  else if(t_f>1666 && t_f<50000) t2<=t_f;
  else t2<=50000;
 
if(d_z<100)  d1<=100;  
else if(d_z<t1-666 && d_z>=100) d1<=d_z;   
else d1<=t1-666;

if(d_f<100)  d2<=100;
else if(d_f<t2-666 && d_f>=100) d2<=d_f;
else d2<=t2-666;

  if(n_z<=50 && n_z>0)  n1<=n_z;//n1
  else n1<=10;
  
  if(n_f<=51 && n_f>1)  n2<=n_f;//n2
  else n2<=1;
  s1<=5*s_z;
  if(s_f<=0) s2<=0;
   else  s2<=5*s_f;
end
always@(posedge clk)  //计数器数据配置 
begin
 if(flag1==1)	
	begin
	 period1<=t1;
	 period2<=t2;
	 dd1<=d1;
	 dd2<=d2;
	 ss1<=s1;
	 ss2<=s2;
     period<=period1*n1+period2*(n2-1)+ss1+ss2;//总计数长度
	 end
  else
     begin
      period1<=period1;
      period2<=period2;
      dd1<=dd1;
      dd2<=dd2;
      ss1<=ss1;
      ss2<=ss2;
      period<=period;
     end
end

always @(posedge pwm_clk) //全周期计数器
begin
 if(start1==0)// counter
   begin
    counter<=0;
   end
 else 
   begin
    if (counter>=period) 
         counter <= 1;
    else counter <= counter + 1;
   end
end
always@(posedge clk)   //分周期计数器控制标志位
begin
 if(n2==1) 
   begin 
     flag1<=1;  //flag1控制正向脉冲计数器
     flag2<=0;  //flag2控制负向脉冲计数器
   end
 else                
   begin  
    case(counter)
             1         : begin flag1<=1;flag2<=0;end
      (period1*n1-1)   : begin flag1<=0;end
      (period1*n1+ss1) : begin flag2<=1;end
      (period-ss2)     : begin flag2<=0;end
      default          : begin flag1<=flag1;flag2<=flag2;end
    endcase
  end
end
always @(posedge pwm_clk) //正向周期计数器
begin
 if(flag1==0 || flag2==1)
    counter1<=0;
 else 
  begin
   if (counter1>=period1) 
        counter1<=1;
   else counter1<=counter1+1;
  end
end

always @(posedge pwm_clk) //负向周期计数器
begin
 if(flag1==1 || flag2==0) 
   counter2<=0;
 else 
  begin
    if (counter2>=period2) 
         counter2<=1;
    else counter2<=counter2+1;
  end
end

always@(posedge clk) //pwm调节输出
begin
 if(flag1==1 && flag2==0) //正向pwm1,pwm4输出
   begin
    if(dd1==0 || dd1>=period1)
      begin
       pwm1<=0;         
//       pwm2<=0;
//       pwm3<=0;
       pwm4<=0;          
      end
    else
     case(counter1)
        1                   : begin pwm1<=1;pwm4<=1;end
        (period1*9+dd1)/10  : begin pwm4<=0; end
        dd1                 : begin pwm1<=0;end
        period1             : begin pwm1<=0;pwm4<=0;end
        default             : begin pwm1<=pwm1;pwm4<=pwm4;end
     endcase 
  end
 if(flag1==0 && flag2==1)  //负向pwm2输出
   begin
    if(dd2==0 || dd2>=period2 || n2==0)
      begin
//       pwm1<=0;         
       pwm2<=0;
       pwm3<=0;
//       pwm4<=0;             
      end
    else
     case(counter2)
//        1       : pwm2<=1;
//        dd2     : pwm2<=0;
//        period2 : pwm2<=0;
//        default : pwm2<=pwm2;
        1                  : begin pwm2<=1;pwm3<=1;end
        (period2/2+dd2/2)  : begin pwm2<=0; end
        dd2                : begin pwm3<=0; end
        period2            : begin pwm2<=0;pwm3<=0;end
        default            : begin pwm2<=pwm2;pwm3<=pwm3;end
     endcase 
 end
end

assign lock = (((n1==0)&&(n2==0))||(dd1>=period1) || (dd2>=period2))? 1'b0 : 1'b1;//错误数据传输故障锁定
//always@(posedge clk) begin
//    if(((n1==0)&&(n2==0))||(dd1>=period1) || (dd2>=period2))
//        lock <= 0;
//    else
//        lock <= 1;
//end

endmodule
