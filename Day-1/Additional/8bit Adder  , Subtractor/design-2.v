module adder_sub (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       mode,
    output wire [7:0] result,
    output wire       cout,
    output wire       overflow
);

    wire [7:0] b_x = b ^ {8{mode}};
    wire [8:0] c;

    assign c[0] = mode;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : fa_chain
            full_adder fa (
                .a    (a[i]),
                .b    (b_x[i]),
                .cin  (c[i]),
                .sum  (result[i]),
                .cout (c[i+1])
            );
        end
    endgenerate

    assign cout     = c[8];
    assign overflow = c[7] ^ c[8];

endmodule