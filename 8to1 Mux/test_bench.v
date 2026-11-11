`timescale 1ns/1ns
module mux_8_to_1_tb;
  reg [7:0] I;
  reg s2, s1, s0;
  wire Y;
  reg [2:0] t;
  mux_8_to_1 mux(I, s2, s1, s0, Y);
  
  initial 
    begin
      for(t=0;t<=7;t=t+1)
        begin
          {s2,s1,s0}=t;
      	   #10;
        end
         $finish;
    end
    
  	
  
endmodule
          
          
      