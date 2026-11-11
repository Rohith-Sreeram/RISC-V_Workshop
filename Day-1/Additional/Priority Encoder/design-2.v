module decoder_3to8 (
    input  wire       en,
    input  wire [2:0] a,
    output wire [7:0] y
);

    assign y = en ? (8'b00000001 << a) : 8'b00000000;

endmodule