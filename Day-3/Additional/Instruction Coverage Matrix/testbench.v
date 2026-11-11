
`timescale 1ns/1ps

module tb_riscv_2stage;

reg clk;
reg reset;

integer k;
integer errors;

riscv_2stage dut(
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;


// =====================================
// I-TYPE INSTRUCTION ENCODER
// =====================================

function [31:0] enc_i;
input integer imm;
input integer rs1;
input integer funct3;
input integer rd;
input [6:0] opcode;

begin
    enc_i = {
        imm[11:0],
        rs1[4:0],
        funct3[2:0],
        rd[4:0],
        opcode
    };
end
endfunction


// =====================================
// R-TYPE INSTRUCTION ENCODER
// =====================================

function [31:0] enc_r;
input integer funct7;
input integer rs2;
input integer rs1;
input integer funct3;
input integer rd;
input [6:0] opcode;

begin
    enc_r = {
        funct7[6:0],
        rs2[4:0],
        rs1[4:0],
        funct3[2:0],
        rd[4:0],
        opcode
    };
end
endfunction


// =====================================
// S-TYPE INSTRUCTION ENCODER
// =====================================

function [31:0] enc_s;
input integer imm;
input integer rs2;
input integer rs1;
input integer funct3;
input [6:0] opcode;

begin
    enc_s = {
        imm[11:5],
        rs2[4:0],
        rs1[4:0],
        funct3[2:0],
        imm[4:0],
        opcode
    };
end
endfunction


// =====================================
// B-TYPE INSTRUCTION ENCODER
// =====================================

function [31:0] enc_b;
input integer offset;
input integer rs2;
input integer rs1;
input integer funct3;
input [6:0] opcode;

reg [12:0] b;

begin
    b = offset;

    enc_b = {
        b[12],
        b[10:5],
        rs2[4:0],
        rs1[4:0],
        funct3[2:0],
        b[4:1],
        b[11],
        opcode
    };
end
endfunction


// =====================================
// MAIN TEST PROGRAM
// =====================================

initial begin

    clk = 0;
    reset = 1;
    errors = 0;

    // Initialize instruction and data memories
    for(k = 0; k < 64; k = k + 1) begin
        dut.instruction_mem[k] = 32'h00000013;
        dut.data_mem[k] = 0;
    end


    // ---------------------------------
    // TEST 1: ADDI
    // ---------------------------------

    // x1 = 5
    dut.instruction_mem[0] =
        enc_i(5,0,0,1,7'b0010011);

    // x2 = 7
    dut.instruction_mem[1] =
        enc_i(7,0,0,2,7'b0010011);


    // ---------------------------------
    // TEST 2: ADD
    // ---------------------------------

    // x3 = x1 + x2 = 12
    dut.instruction_mem[2] =
        enc_r(0,2,1,0,3,7'b0110011);


    // ---------------------------------
    // TEST 3: SUB
    // ---------------------------------

    // x4 = x3 - x1 = 7
    dut.instruction_mem[3] =
        enc_r(32,1,3,0,4,7'b0110011);


    // ---------------------------------
    // TEST 4: AND
    // ---------------------------------

    // x8 = x1 AND x2 = 5
    dut.instruction_mem[4] =
        enc_r(0,2,1,7,8,7'b0110011);


    // ---------------------------------
    // TEST 5: OR
    // ---------------------------------

    // x9 = x1 OR x2 = 7
    dut.instruction_mem[5] =
        enc_r(0,2,1,6,9,7'b0110011);


    // ---------------------------------
    // TEST 6: SW
    // ---------------------------------

    // MEM[0] = x3 = 12
    dut.instruction_mem[6] =
        enc_s(0,3,0,2,7'b0100011);


    // ---------------------------------
    // TEST 7: LW
    // ---------------------------------

    // x5 = MEM[0] = 12
    dut.instruction_mem[7] =
        enc_i(0,0,2,5,7'b0000011);


    // ---------------------------------
    // TEST 8: BEQ
    // ---------------------------------

    // x4 == x2, therefore branch is taken
    // Branch target = PC + 8
    dut.instruction_mem[8] =
        enc_b(8,2,4,0,7'b1100011);

    // Wrong-path instruction: must be flushed
    // x6 must remain 0
    dut.instruction_mem[9] =
        enc_i(99,0,0,6,7'b0010011);

    // Branch target: x7 = 11
    dut.instruction_mem[10] =
        enc_i(11,0,0,7,7'b0010011);


    // ---------------------------------
    // RELEASE RESET AND RUN CPU
    // ---------------------------------

    #12;
    reset = 0;

    repeat(18)
        @(posedge clk);

    #1;


    // =================================
    // CHECK INSTRUCTION RESULTS
    // =================================

    $display("");
    $display("==================================");
    $display(" RISC-V INSTRUCTION COVERAGE");
    $display("==================================");


    // ADD
    if(dut.registers[3] == 12) begin
        $display("ADD  : PASS");
    end
    else begin
        $display("ADD  : FAIL, Expected 12, Got %d",
                 dut.registers[3]);
        errors = errors + 1;
    end


    // SUB
    if(dut.registers[4] == 7) begin
        $display("SUB  : PASS");
    end
    else begin
        $display("SUB  : FAIL, Expected 7, Got %d",
                 dut.registers[4]);
        errors = errors + 1;
    end


    // AND
    if(dut.registers[8] == 5) begin
        $display("AND  : PASS");
    end
    else begin
        $display("AND  : FAIL, Expected 5, Got %d",
                 dut.registers[8]);
        errors = errors + 1;
    end


    // OR
    if(dut.registers[9] == 7) begin
        $display("OR   : PASS");
    end
    else begin
        $display("OR   : FAIL, Expected 7, Got %d",
                 dut.registers[9]);
        errors = errors + 1;
    end


    // ADDI
    if(dut.registers[1] == 5 &&
       dut.registers[2] == 7) begin
        $display("ADDI : PASS");
    end
    else begin
        $display("ADDI : FAIL");
        errors = errors + 1;
    end


    // SW
    if(dut.data_mem[0] == 12) begin
        $display("SW   : PASS");
    end
    else begin
        $display("SW   : FAIL, Expected 12, Got %d",
                 dut.data_mem[0]);
        errors = errors + 1;
    end


    // LW
    if(dut.registers[5] == 12) begin
        $display("LW   : PASS");
    end
    else begin
        $display("LW   : FAIL, Expected 12, Got %d",
                 dut.registers[5]);
        errors = errors + 1;
    end


    // BEQ
    if(dut.registers[6] == 0 &&
       dut.registers[7] == 11) begin
        $display("BEQ  : PASS");
    end
    else begin
        $display("BEQ  : FAIL");
        errors = errors + 1;
    end


    // =================================
    // FINAL COVERAGE RESULT
    // =================================

    $display("----------------------------------");

    if(errors == 0)
        $display("OVERALL RESULT: PASS (8/8)");
    else
        $display("OVERALL RESULT: FAIL (%0d errors)",
                 errors);

    $display("==================================");

    $finish;

end

endmodule
