
`timescale 10ns/1ns

module Adder_Register_tb;

reg [3:0] A, B;
reg  clk;

wire [4:0] Sum;

// Module instantiation
Adder_Register uut(A, B, clk, Sum);

// Clock generation
initial
    clk = 0;

always
    #5 clk = ~clk;

// Test cases
initial
begin
    $monitor("Time=%0t | A=%b | B=%b | Sum=%b",
              $time, A, B, Sum);

    A=4'd3;  B=4'd2; 
    #10;

    A=4'd7;  B=4'd8;  
    #10;

    A=4'd15; B=4'd1;  
    #10;

    A=4'd10; B=4'd5; 
    #10;

    $finish;
end

endmodule

