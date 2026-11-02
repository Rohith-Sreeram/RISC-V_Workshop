`timescale 1ns/1ps

module d_ff_tb;

reg clk;
reg reset;
reg D;

wire Q;

// DUT instantiation
d_ff uut(
    .clk(clk),
    .reset(reset),
    .D(D),
    .Q(Q)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test inputs
initial begin

    $monitor("Time=%0t | CLK=%b | RESET=%b | D=%b | Q=%b",
              $time, clk, reset, D, Q);

    reset = 1;
    D = 0;

    #10;

    reset = 0;
    D = 1;

    #10;

    D = 0;

    #10;

    D = 1;

    #10;

    reset = 1;
    D = 1;

    #10;

    reset = 0;
    D = 0;

    #10;

    $finish;

end

endmodule