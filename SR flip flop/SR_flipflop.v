
module SR_Flipflop(
    input wire S,
    input wire R,
    input wire rst,
    input wire clk,
    output reg Q
);

always @(posedge clk)
begin

   if(rst==1'b1)
	Q <=0;
   else

  begin
    case ({S,R})
        2'b00: Q <= 1;
        2'b01: Q <= 1'b0;
        2'b10: Q <= 1'b1;
        2'b11: Q <= 1'bx;
    endcase
    end

end

endmodule

