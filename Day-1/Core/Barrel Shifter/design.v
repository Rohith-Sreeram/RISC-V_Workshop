module shifter (
    input  wire [31:0] data_in,
    input  wire [4:0]  shamt,
    input  wire [1:0]  mode,
    output reg  [31:0] data_out
);

    wire signed [31:0] signed_in = data_in;

    always @(*) begin
        case (mode)
            2'b00:   data_out = data_in << shamt;
            2'b01:   data_out = data_in >> shamt;
            2'b10:   data_out = signed_in >>> shamt;
            default: data_out = data_in;
        endcase
    end

endmodule