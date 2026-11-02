module Instruction_Decoder(input wire [15:0] instruction, output reg [9:0] result);

	always @(instruction)
	case(instruction[15])
	0'b0:result=instruction[14:10]+ instruction[9:5];
	0'b1:result=instruction[14:10]- instruction[9:5];
	endcase

endmodule
	


