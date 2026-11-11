`timescale 1ns/1ps

module regfile_tb;

    reg         clk;
    reg         we;
    reg  [4:0]  waddr;
    reg  [31:0] wdata;
    reg  [4:0]  raddr1;
    reg  [4:0]  raddr2;
    wire [31:0] rdata1;
    wire [31:0] rdata2;

    reg [31:0] model [0:31];

    integer errors = 0;
    integer checks = 0;
    integer i;
    integer r1, r2;

    regfile dut (
        .clk    (clk),
        .we     (we),
        .waddr  (waddr),
        .wdata  (wdata),
        .raddr1 (raddr1),
        .raddr2 (raddr2),
        .rdata1 (rdata1),
        .rdata2 (rdata2)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check_reads(input [127:0] name);
        reg [31:0] exp1;
        reg [31:0] exp2;
        begin
            exp1 = (raddr1 == 5'd0)           ? 32'd0 :
                   (we && waddr == raddr1)    ? wdata :
                                                model[raddr1];
            exp2 = (raddr2 == 5'd0)           ? 32'd0 :
                   (we && waddr == raddr2)    ? wdata :
                                                model[raddr2];
            checks = checks + 2;
            if (rdata1 !== exp1) begin
                errors = errors + 1;
                $display("FAIL [%0s] t=%0t port1 raddr=%0d expected=%h got=%h",
                         name, $time, raddr1, exp1, rdata1);
            end
            if (rdata2 !== exp2) begin
                errors = errors + 1;
                $display("FAIL [%0s] t=%0t port2 raddr=%0d expected=%h got=%h",
                         name, $time, raddr2, exp2, rdata2);
            end
        end
    endtask

    task cycle(
        input        we_v,
        input [4:0]  wa_v,
        input [31:0] wd_v,
        input [4:0]  ra1_v,
        input [4:0]  ra2_v,
        input [127:0] name
    );
        begin
            @(negedge clk);
            we     = we_v;
            waddr  = wa_v;
            wdata  = wd_v;
            raddr1 = ra1_v;
            raddr2 = ra2_v;
            #1;
            check_reads(name);
            @(posedge clk);
            if (we_v && wa_v != 5'd0)
                model[wa_v] = wd_v;
            #1;
        end
    endtask

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, regfile_tb);

        we = 0; waddr = 0; wdata = 0; raddr1 = 0; raddr2 = 0;
        for (i = 0; i < 32; i = i + 1) model[i] = 32'd0;

        for (i = 1; i < 32; i = i + 1)
            cycle(1'b1, i[4:0], 32'd0, 5'd0, 5'd0, "init");

        cycle(1'b1, 5'd0, 32'hDEADBEEF, 5'd0, 5'd0, "x0 write");
        cycle(1'b0, 5'd0, 32'h0,        5'd0, 5'd0, "x0 readback");
        cycle(1'b1, 5'd0, 32'hFFFFFFFF, 5'd0, 5'd1, "x0 write bypass");

        cycle(1'b1, 5'd5, 32'h12345678, 5'd5, 5'd5, "bypass both ports");
        cycle(1'b0, 5'd0, 32'h0,        5'd5, 5'd6, "bypass readback");
        cycle(1'b1, 5'd6, 32'hCAFEF00D, 5'd5, 5'd6, "bypass port2 only");
        cycle(1'b1, 5'd9, 32'hA5A5A5A5, 5'd6, 5'd7, "no bypass diff addr");
        cycle(1'b0, 5'd0, 32'h0,        5'd9, 5'd6, "after write");

        cycle(1'b1, 5'd7, 32'h00000001, 5'd7, 5'd7, "b2b write 1");
        cycle(1'b1, 5'd7, 32'h00000002, 5'd7, 5'd7, "b2b write 2");
        cycle(1'b1, 5'd7, 32'h00000003, 5'd7, 5'd7, "b2b write 3");
        cycle(1'b0, 5'd0, 32'h0,        5'd7, 5'd7, "b2b final");

        cycle(1'b1, 5'd10, 32'h11111111, 5'd11, 5'd10, "b2b diff regs a");
        cycle(1'b1, 5'd11, 32'h22222222, 5'd11, 5'd10, "b2b diff regs b");
        cycle(1'b0, 5'd0,  32'h0,        5'd11, 5'd10, "b2b diff regs read");

        cycle(1'b1, 5'd31, 32'hFFFFFFFF, 5'd31, 5'd31, "x31 bypass");
        cycle(1'b1, 5'd1,  32'h80000000, 5'd1,  5'd31, "x1 bypass");

        cycle(1'b0, 5'd3, 32'hBADBAD00, 5'd3, 5'd3, "we low no bypass");
        cycle(1'b0, 5'd0, 32'h0,        5'd3, 5'd3, "we low no write");

        for (i = 0; i < 600; i = i + 1) begin
            r1 = ($random & 3) == 0 ? ($random & 31) : ($random & 7);
            r2 = ($random & 3) == 0 ? ($random & 31) : ($random & 7);
            cycle(($random & 1),
                  ($random & 3) == 0 ? ($random & 31) : ($random & 7),
                  $random,
                  ($random & 3) == 0 ? r1[4:0] : ($random & 7),
                  ($random & 3) == 0 ? r2[4:0] : ($random & 7),
                  "random");
        end

        for (i = 0; i < 32; i = i + 2)
            cycle(1'b0, 5'd0, 32'h0, i[4:0], i[4:0] + 5'd1, "final sweep");

        $display("Checks run: %0d", checks);
        if (errors == 0) $display("*** ALL TESTS PASSED ***");
        else             $display("*** %0d TEST(S) FAILED ***", errors);

        $finish;
    end

endmodule