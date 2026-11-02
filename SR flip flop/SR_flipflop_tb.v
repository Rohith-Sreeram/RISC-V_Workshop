`timescale 1ns/1ns
module sr_tb;
reg S, R,rst, clk;
wire Q;
assign Q= 1'b1;

SR_Flipflop sr(S, R, rst, clk, Q);

initial

clk=0;

always
#5 clk=~clk;



initial 
begin
$monitor("S=%b, R=%b, Q=%b", S, R, Q);
S=0;R=0;
#10 S=0;R=1;
#10 S=1;R=0;
#10 S=1;R=1;

#30;
$finish;

end

endmodule