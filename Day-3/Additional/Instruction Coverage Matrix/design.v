
`timescale 1ns/1ps

module riscv_2stage(
    input wire clk,
    input wire reset
);

reg [31:0] pc;
reg [31:0] instruction_mem [0:63];
reg [31:0] data_mem [0:63];
reg [31:0] registers [0:31];

// Pipeline register
reg [31:0] if_id_instruction;
reg [31:0] if_id_pc;

// Instruction fields
wire [6:0] opcode = if_id_instruction[6:0];
wire [4:0] rd = if_id_instruction[11:7];
wire [2:0] funct3 = if_id_instruction[14:12];
wire [4:0] rs1 = if_id_instruction[19:15];
wire [4:0] rs2 = if_id_instruction[24:20];
wire [6:0] funct7 = if_id_instruction[31:25];

// Register read
wire [31:0] read_data1 =
    (rs1 == 0) ? 32'd0 : registers[rs1];

wire [31:0] read_data2 =
    (rs2 == 0) ? 32'd0 : registers[rs2];

// Immediate generation
wire [31:0] imm_i =
    {{20{if_id_instruction[31]}},
    if_id_instruction[31:20]};

wire [31:0] imm_s =
    {{20{if_id_instruction[31]}},
    if_id_instruction[31:25],
    if_id_instruction[11:7]};

wire [31:0] imm_b =
    {{19{if_id_instruction[31]}},
    if_id_instruction[31],
    if_id_instruction[7],
    if_id_instruction[30:25],
    if_id_instruction[11:8],
    1'b0};

reg [31:0] alu_result;
reg [31:0] write_data;

reg reg_write;
reg mem_write;
reg branch_taken;

reg [31:0] branch_target;

// Control unit and ALU
always @(*) begin

    alu_result = 32'd0;
    write_data = 32'd0;

    reg_write = 1'b0;
    mem_write = 1'b0;

    branch_taken = 1'b0;
    branch_target = if_id_pc + imm_b;

    case(opcode)

        // R-type instructions
        7'b0110011: begin

            reg_write = 1'b1;

            case(funct3)

                // ADD and SUB
                3'b000: begin
                    if(funct7 == 7'b0100000)
                        alu_result = read_data1 - read_data2;
                    else
                        alu_result = read_data1 + read_data2;
                end

                // AND
                3'b111:
                    alu_result = read_data1 & read_data2;

                // OR
                3'b110:
                    alu_result = read_data1 | read_data2;

                default: begin
                    alu_result = 32'd0;
                    reg_write = 1'b0;
                end

            endcase

            write_data = alu_result;
        end

        // ADDI
        7'b0010011: begin

            if(funct3 == 3'b000) begin
                alu_result = read_data1 + imm_i;
                write_data = alu_result;
                reg_write = 1'b1;
            end

        end

        // LW
        7'b0000011: begin

            if(funct3 == 3'b010) begin
                alu_result = read_data1 + imm_i;
                reg_write = 1'b1;
                write_data = data_mem[alu_result[7:2]];
            end

        end

        // SW
        7'b0100011: begin

            if(funct3 == 3'b010) begin
                alu_result = read_data1 + imm_s;
                mem_write = 1'b1;
            end

        end

        // BEQ
        7'b1100011: begin

            if(funct3 == 3'b000) begin
                branch_taken = (read_data1 == read_data2);
                branch_target = if_id_pc + imm_b;
            end

        end

        default: begin
            // NOP or unsupported instruction
        end

    endcase

end

integer i;

always @(posedge clk or posedge reset) begin

    if(reset) begin

        pc <= 32'd0;

        if_id_instruction <= 32'h00000013;
        if_id_pc <= 32'd0;

        for(i = 0; i < 32; i = i + 1)
            registers[i] <= 32'd0;

    end

    else begin

        // Store word
        if(mem_write)
            data_mem[alu_result[7:2]] <= read_data2;

        // Register writeback
        if(reg_write && rd != 0)
            registers[rd] <= write_data;

        registers[0] <= 32'd0;

        // Branch handling
        if(branch_taken) begin

            pc <= branch_target;

            // Flush wrong-path instruction
            if_id_instruction <= 32'h00000013;
            if_id_pc <= branch_target;

        end

        else begin

            // Normal instruction fetch
            if_id_instruction <= instruction_mem[pc[7:2]];
            if_id_pc <= pc;

            pc <= pc + 32'd4;

        end

    end

end

endmodule
