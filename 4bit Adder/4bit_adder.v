module adder(
    input wire [3:0] A,
    input wire [3:0] B,
    output wire [3:0] Sum,
    output wire Carry
);

wire [4:0] temp_sum;

assign temp_sum = A + B;

assign Sum   = temp_sum[3:0];
assign Carry = temp_sum[4];

endmodule
