
module Adder_Register(
    input wire [3:0] A,
    input wire [3:0] B,
    input wire clk,
    output wire [4:0] Sum
);

wire [4:0] temp_sum;
wire carry; 

assign {temp_sum, carry} = A + B;

// Five D flip-flops to store the sum
genvar i;

generate
    for(i = 0; i < 5; i = i + 1)
    begin : FF
        D_Flipflop dff(
            .D(temp_sum[i]),
            .clk(clk),
            .Q(Sum[i])
        );
    end
endgenerate

endmodule

