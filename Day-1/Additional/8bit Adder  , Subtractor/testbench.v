`timescale 1ns/1ps

module adder_sub_tb;

    reg  [7:0] a;
    reg  [7:0] b;
    reg        mode;
    wire [7:0] result;
    wire       cout;
    wire       overflow;

    integer errors = 0;
    integer checks = 0;
    integer i;

    adder_sub dut (
        .a        (a),
        .b        (b),
        .mode     (mode),
        .result   (result),
        .cout     (cout),
        .overflow (overflow)
    );

    task check;
        reg [8:0] wide;
        reg [7:0] exp_result;
        reg       exp_cout;
        reg       exp_ovf;
        integer   sa, sb, sr;
        begin
            sa = a;
            sb = b;
            if (sa > 127) sa = sa - 256;
            if (sb > 127) sb = sb - 256;

            if (mode == 1'b0) begin
                wide     = {1'b0, a} + {1'b0, b};
                exp_cout = wide[8];
                sr       = sa + sb;
            end else begin
                wide     = {1'b0, a} - {1'b0, b};
                exp_cout = ~wide[8];
                sr       = sa - sb;
            end

            exp_result = wide[7:0];
            exp_ovf    = (sr > 127) || (sr < -128);

            checks = checks + 1;
            if (result !== exp_result || cout !== exp_cout || overflow !== exp_ovf) begin
                errors = errors + 1;
                if (errors <= 20)
                    $display("FAIL mode=%b a=%h b=%h : exp res=%h cout=%b ovf=%b, got res=%h cout=%b ovf=%b",
                             mode, a, b, exp_result, exp_cout, exp_ovf, result, cout, overflow);
            end
        end
    endtask

    task apply(input [7:0] a_v, input [7:0] b_v, input m_v);
        begin
            a    = a_v;
            b    = b_v;
            mode = m_v;
            #10;
            check;
        end
    endtask

    initial begin
        $dumpfile("adder_sub.vcd");
        $dumpvars(0, adder_sub_tb);

        a = 0; b = 0; mode = 0;
        #10;

        apply(8'd3,   8'd4,   1'b0);
        apply(8'd100, 8'd27,  1'b0);
        apply(8'd255, 8'd1,   1'b0);
        apply(8'd127, 8'd1,   1'b0);
        apply(8'h80,  8'h80,  1'b0);
        apply(8'hFF,  8'hFF,  1'b0);

        apply(8'd10,  8'd3,   1'b1);
        apply(8'd3,   8'd10,  1'b1);
        apply(8'd5,   8'd5,   1'b1);
        apply(8'h80,  8'd1,   1'b1);
        apply(8'd127, 8'hFF,  1'b1);
        apply(8'd0,   8'd1,   1'b1);

        $dumpoff;

        for (i = 0; i < 131072; i = i + 1) begin
            a    = i[7:0];
            b    = i[15:8];
            mode = i[16];
            #1;
            check;
        end

        $display("Checks run: %0d", checks);
        if (errors == 0) $display("*** ALL TESTS PASSED ***");
        else             $display("*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule