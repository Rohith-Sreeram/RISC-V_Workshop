`timescale 1ns/1ps

module shifter_tb;

    reg  [31:0] data_in;
    reg  [4:0]  shamt;
    reg  [1:0]  mode;
    wire [31:0] data_out;

    integer errors = 0;
    integer checks = 0;
    integer m, s, k;

    shifter dut (
        .data_in  (data_in),
        .shamt    (shamt),
        .mode     (mode),
        .data_out (data_out)
    );

    function [31:0] ref_shift;
        input [31:0] d;
        input [4:0]  n;
        input [1:0]  md;
        integer i;
        reg [31:0] r;
        reg        sign;
        begin
            r    = d;
            sign = d[31];
            for (i = 0; i < n; i = i + 1) begin
                case (md)
                    2'b00:   r = {r[30:0], 1'b0};
                    2'b01:   r = {1'b0, r[31:1]};
                    2'b10:   r = {sign, r[31:1]};
                    default: r = r;
                endcase
            end
            ref_shift = r;
        end
    endfunction

    task apply_and_check(input [31:0] d, input [4:0] n, input [1:0] md);
        reg [31:0] expected;
        begin
            data_in = d;
            shamt   = n;
            mode    = md;
            #1;
            expected = ref_shift(d, n, md);
            checks = checks + 1;
            if (data_out !== expected) begin
                errors = errors + 1;
                $display("FAIL mode=%0d shamt=%0d in=%h expected=%h got=%h",
                         md, n, d, expected, data_out);
            end
        end
    endtask

    reg [31:0] patterns [0:7];

    initial begin
        $dumpfile("shifter.vcd");
        $dumpvars(0, shifter_tb);

        patterns[0] = 32'h00000001;
        patterns[1] = 32'h80000000;
        patterns[2] = 32'hFFFFFFFF;
        patterns[3] = 32'h00000000;
        patterns[4] = 32'h12345678;
        patterns[5] = 32'h87654321;
        patterns[6] = 32'hAAAAAAAA;
        patterns[7] = 32'h55555555;

        for (m = 0; m < 3; m = m + 1)
            for (s = 0; s < 32; s = s + 1)
                for (k = 0; k < 8; k = k + 1)
                    apply_and_check(patterns[k], s[4:0], m[1:0]);

        for (m = 0; m < 3; m = m + 1)
            for (s = 0; s < 32; s = s + 1)
                for (k = 0; k < 200; k = k + 1)
                    apply_and_check($random, s[4:0], m[1:0]);

        $display("Checks run: %0d", checks);
        if (errors == 0) $display("*** ALL TESTS PASSED ***");
        else             $display("*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule