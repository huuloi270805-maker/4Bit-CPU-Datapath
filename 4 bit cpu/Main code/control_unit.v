`timescale 1ns / 1ps

module instruction_decoder (
    input [3:0] opcode,
    output reg [2:0] alu_ctrl,
    output reg alu_src_sel,
    output reg wb_sel,
    output reg reg_we,
    output reg mem_we,
    output reg zero_we,
    output reg carry_we,
    output reg is_jmp,
    output reg is_jz
);
    always @(*) begin
        alu_ctrl    = 3'd0;
        alu_src_sel = 1'b0;
        wb_sel      = 1'b0;
        reg_we      = 1'b0;
        mem_we      = 1'b0;
        zero_we     = 1'b0;
        carry_we    = 1'b0;
        is_jmp      = 1'b0;
        is_jz       = 1'b0;

        case (opcode)
            4'b0000: begin // ADD
                alu_ctrl = 3'd0; reg_we = 1'b1; zero_we = 1'b1; carry_we = 1'b1;
            end
            4'b0001: begin // SUB
                alu_ctrl = 3'd1; reg_we = 1'b1; zero_we = 1'b1; carry_we = 1'b1;
            end
            4'b0010: begin // AND
                alu_ctrl = 3'd2; reg_we = 1'b1; zero_we = 1'b1;
            end
            4'b0011: begin // OR
                alu_ctrl = 3'd3; reg_we = 1'b1; zero_we = 1'b1;
            end
            4'b0100: begin // XOR
                alu_ctrl = 3'd4; reg_we = 1'b1; zero_we = 1'b1;
            end
            4'b0101: begin // NOT
                alu_ctrl = 3'd5; reg_we = 1'b1; zero_we = 1'b1;
            end
            4'b0110: begin // LDI
                alu_ctrl = 3'd6; alu_src_sel = 1'b1; reg_we = 1'b1;
            end
            4'b0111: begin // MOV
                alu_ctrl = 3'd6; reg_we = 1'b1;
            end
            4'b1000: begin // LOAD
                alu_ctrl = 3'd6; alu_src_sel = 1'b1; wb_sel = 1'b1; reg_we = 1'b1;
            end
            4'b1001: begin // STORE
                alu_ctrl = 3'd6; alu_src_sel = 1'b1; mem_we = 1'b1;
            end
            4'b1010: begin // JMP
                is_jmp = 1'b1;
            end
            4'b1011: begin // JZ
                is_jz = 1'b1;
            end
            default: ; // NOP cho reserved opcodes
        endcase
    end
endmodule

module branch_unit (
    input is_jmp,
    input is_jz,
    input zero_flag,
    output reg pc_sel,
    output flush
);
    always @(*) begin
        if (is_jmp)
            pc_sel = 1'b1;
        else if (is_jz && zero_flag)
            pc_sel = 1'b1;
        else
            pc_sel = 1'b0;
    end
    assign flush = pc_sel;
endmodule

module control_unit (
    input [3:0] opcode,
    output [2:0] alu_ctrl,
    output alu_src_sel,
    output wb_sel,
    output reg_we,
    output mem_we,
    output zero_we,
    output carry_we,
    output is_jmp,
    output is_jz,
    input ex_is_jmp,
    input ex_is_jz,
    input zero_flag,
    output pc_sel,
    output flush
);
    instruction_decoder DECODER (
        .opcode(opcode), .alu_ctrl(alu_ctrl), .alu_src_sel(alu_src_sel),
        .wb_sel(wb_sel), .reg_we(reg_we), .mem_we(mem_we),
        .zero_we(zero_we), .carry_we(carry_we), .is_jmp(is_jmp), .is_jz(is_jz)
    );

    branch_unit BRANCH (
        .is_jmp(ex_is_jmp), .is_jz(ex_is_jz), .zero_flag(zero_flag),
        .pc_sel(pc_sel), .flush(flush)
    );
endmodule