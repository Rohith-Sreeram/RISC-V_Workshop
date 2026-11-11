`timescale 1ns/1ps

module seq_tb;

    reg  clk;
    reg  reset;
    reg  din;
    wire det_moore;
    wire det_mealy;

    reg [3:0] hist;
    integer errors    = 0;
    integer checks    = 0;
    integer moore_cnt = 0;
    integer mealy_cnt = 0;

    seq_moore u_moore (.clk(clk), .reset(reset), .din(din), .detected(det_moore));
    seq_mealy u_mealy (.clk(clk), .reset(reset), .din(din), .detected(det_mealy));

    initial clk = 0;
    always #5 clk = ~clk;

    task send_bit(input b);
        begin
            @(negedge clk);
            din = b;
            #1;
            checks = checks + 1;
            if (det_mealy !== ((hist[2:0] == 3'b101) && b)) begin
                errors = errors + 1;
                $display("FAIL mealy t=%0t din=%b hist=%b got=%b", $time, b, hist, det_mealy);
            end
            if (det_mealy) mealy_cnt = mealy_cnt + 1;

            @(posedge clk);
            hist = {hist[2:0], b};
            #1;
            checks = checks + 1;
            if (det_moore !== (hist == 4'b1011)) begin
                errors = errors + 1;
                $display("FAIL moore t=%0t hist=%b got=%b", $time, hist, det_moore);
            end
            if (det_moore) moore_cnt = moore_cnt + 1;
        end
    endtask

    task do_reset;
        begin
            @(negedge clk);
            reset = 1;
            din   = 0;
            @(posedge clk);
            @(posedge clk);
            #1;
            reset = 0;
            hist  = 4'b0000;
            checks = checks + 2;
            if (det_moore !== 1'b0 || det_mealy !== 1'b0) begin
                errors = errors + 1;
                $display("FAIL outputs not cleared by reset");
            end
        end
    endtask

    task run_stream(input [31:0] bits, input integer n, input [127:0] name);
        integer k;
        begin
            mealy_cnt = 0;
            moore_cnt = 0;
            do_reset;
            for (k = n - 1; k >= 0; k = k - 1)
                send_bit(bits[k]);
            send_bit(1'b0);
            $display("%0s : n=%0d moore detections=%0d mealy detections=%0d",
                     name, n, moore_cnt, mealy_cnt);
            if (moore_cnt !== mealy_cnt) begin
                errors = errors + 1;
                $display("FAIL detection counts differ");
            end
        end
    endtask

    initial begin
        $dumpfile("seq.vcd");
        $dumpvars(0, seq_tb);

        reset = 0; din = 0; hist = 4'b0000;

        run_stream(32'b1011011,          7,  "stream A (overlap)    ");
        run_stream(32'b110101101011,     12, "stream B (mixed)      ");
        run_stream(32'b11100100,         8,  "stream C (no match)   ");
        run_stream(32'b101110111011,     12, "stream D (3 matches)  ");
        run_stream($random,              32, "stream E (random)     ");

        $display("Checks run: %0d", checks);
        if (errors == 0) $display("*** ALL TESTS PASSED ***");
        else             $display("*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule