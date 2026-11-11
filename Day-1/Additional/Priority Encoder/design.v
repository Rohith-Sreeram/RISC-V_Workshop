module priority_encoder_casez (
    input  wire [7:0] in,
    output reg  [2:0] y,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        casez (in)
            8'b1???????: y = 3'd7;
            8'b01??????: y = 3'd6;
            8'b001?????: y = 3'd5;
            8'b0001????: y = 3'd4;
            8'b00001???: y = 3'd3;
            8'b000001??: y = 3'd2;
            8'b0000001?: y = 3'd1;
            8'b00000001: y = 3'd0;
            default: begin
                y     = 3'd0;
                valid = 1'b0;
            end
        endcase
    end

endmodule

module priority_encoder_if (
    input  wire [7:0] in,
    output reg  [2:0] y,
    output reg        valid
);

    always @(*) begin
        valid = 1'b1;
        if      (in[7]) y = 3'd7;
        else if (in[6]) y = 3'd6;
        else if (in[5]) y = 3'd5;
        else if (in[4]) y = 3'd4;
        else if (in[3]) y = 3'd3;
        else if (in[2]) y = 3'd2;
        else if (in[1]) y = 3'd1;
        else if (in[0]) y = 3'd0;
        else begin
            y     = 3'd0;
            valid = 1'b0;
        end
    end

endmodule