`timescale 1ns/1ps

module adder_tb;

reg [3:0] A;
reg [3:0] B;

wire [3:0] Sum;
wire Carry;

integer i, j;

// DUT instantiation
adder uut(
    .A(A),
    .B(B),
    .Sum(Sum),
    .Carry(Carry)
);

initial begin

    $display("A\tB\tCarry\tSum");
    $display("-----------------------------");

    for(i = 0; i < 16; i = i + 1)
    begin
        for(j = 0; j < 16; j = j + 1)
        begin

            A = i;
            B = j;

            #10;

            $display("%d\t%d\t%b\t%b",
                      A, B, Carry, Sum);

        end
    end

    $finish;

end

endmodule
