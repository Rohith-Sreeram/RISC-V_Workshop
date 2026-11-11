module mux_8_to_1(input wire [7:0] I,input wire s2, s1,s0, output reg Y);
  reg [2:0] t;
 
  
  always @(*)
    for(t=0;t<=7;t=t+1)
      begin
      
      
        if({s2,s1,s0}==t)
          Y=I[t];
      end
endmodule
  