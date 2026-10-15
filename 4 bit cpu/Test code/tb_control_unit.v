`timescale 1ns / 1ps

module tb_control_unit;
    reg [3:0] opcode = 4'b0000;
    reg ex_is_jmp = 0, ex_is_jz = 0, zero_flag = 0;
    wire [2:0] alu_ctrl;
    wire alu_src_sel, wb_sel, reg_we, mem_we, zero_we, carry_we, is_jmp, is_jz;
    wire pc_sel, flush;
    integer errors = 0;
    integer tests = 0;

    control_unit DUT (
        .opcode(opcode), .alu_ctrl(alu_ctrl), .alu_src_sel(alu_src_sel),
        .wb_sel(wb_sel), .reg_we(reg_we), .mem_we(mem_we),
        .zero_we(zero_we), .carry_we(carry_we), .is_jmp(is_jmp), .is_jz(is_jz),
        .ex_is_jmp(ex_is_jmp), .ex_is_jz(ex_is_jz), .zero_flag(zero_flag),
        .pc_sel(pc_sel), .flush(flush)
    );

    wire [10:0] signals = {alu_ctrl, alu_src_sel, wb_sel, reg_we, mem_we, zero_we, carry_we, is_jmp, is_jz};

    task check_op;
        input [8*6:1] name;
        input [3:0] op;
        input [10:0] expected;
        begin
            opcode = op; #1;
            tests = tests + 1;
            if (signals === expected) begin
                $display("PASS %0s", name);
            end else begin
                $display("FAIL %0s got %b, expected %b", name, signals, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== tb_control_unit: control unit test =====");
        check_op("ADD", 4'b0000, {3'd0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0});
        check_op("SUB", 4'b0001, {3'd1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0});
        check_op("LDI", 4'b0110, {3'd6, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0});
        check_op("JMP", 4'b1010, {3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0});
        check_op("JZ",  4'b1011, {3'd0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1});

        if (errors == 0)
            $display("tb_control_unit PASSED: %0d checks OK\n", tests);
        else
            $display("tb_control_unit FAILED: %0d checks failed\n", errors);
        $finish;
    end
endmodule