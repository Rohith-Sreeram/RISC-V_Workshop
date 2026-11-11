`timescale 1ns/1ps

module counter_tb;

    reg        clk;
    reg        reset;
    reg        enable;
    reg        up_down;
    reg        load;
    reg  [7:0] load_data;
    wire [7:0] count;

    integer errors = 0;

    // DUT
    counter dut (
        .clk       (clk),
        .reset     (reset),
        .enable    (enable),
        .up_down   (up_down),
        .load      (load),
        .load_data (load_data),
        .count     (count)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Advance n clock edges, then wait 1 ns so outputs settle
    task tick(input integer n);
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(posedge clk);
            #1;
        end
    endtask

    // Self-checking helper
    task check(input [7:0] expected, input [127:0] name);
        begin
            if (count !== expected) begin
                $display("FAIL [%0s] t=%0t : expected %h, got %h", name, $time, expected, count);
                errors = errors + 1;
            end else
                $display("PASS [%0s] t=%0t : count = %h", name, $time, count);
        end
    endtask

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        // Initial values
        reset = 0; enable = 0; up_down = 1; load = 0; load_data = 8'h00;
        #2;

        // 1. RESET
        reset = 1;                 tick(2);  check(8'h00, "reset");
        reset = 0;

        // 2. COUNT UP (5 clocks)
        enable = 1; up_down = 1;   tick(5);  check(8'h05, "count up");

        // 3. COUNT DOWN (3 clocks)
        up_down = 0;               tick(3);  check(8'h02, "count down");

        // 4. PARALLEL LOAD
        load = 1; load_data = 8'hA0; tick(1); check(8'hA0, "load");
        load = 0;

        // 5. COUNT UP from loaded value
        up_down = 1;               tick(2);  check(8'hA2, "up after load");

        // 6. HOLD (enable = 0)
        enable = 0;                tick(2);  check(8'hA2, "hold");

        // 7. COUNT DOWN again
        enable = 1; up_down = 0;   tick(2);  check(8'hA0, "down");

        // 8. RESET in the middle of counting
        reset = 1;                 tick(1);  check(8'h00, "reset mid-count");
        reset = 0;

        // 9. UNDERFLOW wrap-around (00 -> FF)
        up_down = 0;               tick(1);  check(8'hFF, "wrap down");

        // 10. OVERFLOW wrap-around (FF -> 00)
        up_down = 1;               tick(1);  check(8'h00, "wrap up");

        // 11. Load has priority over enable/count
        load = 1; load_data = 8'h55; tick(1); check(8'h55, "load priority");
        load = 0;

        // 12. Reset has priority over load
        reset = 1; load = 1; load_data = 8'hFF; tick(1); check(8'h00, "reset priority");
        reset = 0; load = 0;

        if (errors == 0) $display("\n*** ALL TESTS PASSED ***");
        else             $display("\n*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule