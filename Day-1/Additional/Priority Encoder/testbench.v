`timescale 1ns/1ps

module encoder_decoder_tb;

    reg  [7:0] in;
    wire [2:0] y_casez, y_if;
    wire       valid_casez, valid_if;

    reg        en;
    reg  [2:0] a;
    wire [7:0] dec_y;

    integer errors      = 0;
    integer checks      = 0;
    integer mismatches  = 0;
    integer i, j;

    reg [2:0] exp_y;
    reg       exp_valid;
    reg [7:0] exp_dec;

    priority_encoder_casez enc_casez (
        .in    (in),
        .y     (y_casez),
        .valid (valid_casez)
    );

    priority_encoder_if enc_if (
        .in    (in),
        .y     (y_if),
        .valid (valid_if)
    );

    decoder_3to8 dec (
        .en (en),
        .a  (a),
        .y  (dec_y)
    );

    initial begin
        $dumpfile("encoder_decoder.vcd");
        $dumpvars(0, encoder_decoder_tb);

        en = 0;
        a  = 0;

        for (i = 0; i < 256; i = i + 1) begin
            in = i[7:0];
            #5;

            exp_y     = 3'd0;
            exp_valid = 1'b0;
            for (j = 0; j < 8; j = j + 1)
                if (in[j]) begin
                    exp_y     = j[2:0];
                    exp_valid = 1'b1;
                end

            checks = checks + 2;

            if (y_casez !== exp_y || valid_casez !== exp_valid) begin
                errors = errors + 1;
                $display("FAIL casez in=%b : exp y=%0d valid=%b, got y=%0d valid=%b",
                         in, exp_y, exp_valid, y_casez, valid_casez);
            end

            if (y_if !== exp_y || valid_if !== exp_valid) begin
                errors = errors + 1;
                $display("FAIL if    in=%b : exp y=%0d valid=%b, got y=%0d valid=%b",
                         in, exp_y, exp_valid, y_if, valid_if);
            end

            if (y_casez !== y_if || valid_casez !== valid_if) begin
                mismatches = mismatches + 1;
                $display("DIFF in=%b : casez y=%0d valid=%b, if y=%0d valid=%b",
                         in, y_casez, valid_casez, y_if, valid_if);
            end
        end

        for (i = 0; i < 16; i = i + 1) begin
            {en, a} = i[3:0];
            #5;

            exp_dec = 8'b0;
            for (j = 0; j < 8; j = j + 1)
                exp_dec[j] = en && (a == j[2:0]);

            checks = checks + 1;
            if (dec_y !== exp_dec) begin
                errors = errors + 1;
                $display("FAIL decoder en=%b a=%0d : exp %b, got %b", en, a, exp_dec, dec_y);
            end
        end

        $display("Checks run: %0d", checks);
        $display("Casez vs if-else mismatches: %0d", mismatches);
        if (errors == 0 && mismatches == 0) $display("*** ALL TESTS PASSED ***");
        else $display("*** %0d TEST(S) FAILED, %0d MISMATCH(ES) ***", errors, mismatches);

        $finish;
    end

endmodule