`timescale 1ns / 1ps

module tb_cpu;
    reg clk = 0;
    reg rst = 1;
    integer errors = 0;
    integer checks = 0;
    integer cycle = 0;
    integer i;

    always #5 clk = ~clk;

    wire [3:0] pc_out, alu_out, wb_data_out;
    wire [11:0] instr_out;
    wire zero_out, carry_out;

    cpu_top #(.PROGRAM_FILE("program.mem")) CPU (
        .clk(clk), .rst(rst),
        .pc_out(pc_out), .instr_out(instr_out), .alu_out(alu_out),
        .wb_data_out(wb_data_out), .zero_out(zero_out), .carry_out(carry_out)
    );

    always @(posedge clk) begin
        if (rst) cycle <= 0;
        else cycle <= cycle + 1;
    end

    task reset_cpu;
        begin
            rst = 1;
            @(posedge clk); @(posedge clk); #1;
            rst = 0;
        end
    endtask

    task load_program;
        input [8*20:1] file_name;
        begin
            rst = 1;
            for (i = 0; i < 16; i = i + 1) begin
                CPU.IMEM.mem[i] = 12'hC00;
                CPU.DMEM.mem[i] = 4'b0000;
            end
            $readmemh(file_name, CPU.IMEM.mem);
        end
    endtask

    task finish;
        input [3:0] addr;
        begin
            @(negedge clk);
            while (!(CPU.ex_valid && CPU.ex_pc == addr))
                @(negedge clk);
            @(posedge clk); #1;
        end
    endtask

    task check;
        input [8*44:1] name;
        input [3:0] actual, expected;
        begin
            checks = checks + 1;
            if (actual === expected) begin
                $display("PASS %0s = %b", name, actual);
            end else begin
                $display("FAIL %0s = %b (expected %b)", name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    task check_bit;
        input [8*44:1] name;
        input actual, expected;
        begin
            checks = checks + 1;
            if (actual === expected) begin
                $display("PASS %0s = %b", name, actual);
            end else begin
                $display("FAIL %0s = %b (expected %b)", name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $display("\n===== CPU INTEGRATION & PIPELINE VERIFICATION TESTS =====");
        
        // TEST 1: Demonstration Program
        reset_cpu();
        finish(2);
        check("ADD R1,R2 (5+3)", CPU.RF.r1, 4'b1000);
        finish(4);
        check("XOR R1,R3", CPU.RF.r1, 4'b0010);

        // TEST 2: Arithmetic and Memory
        load_program("prog_arith.mem");
        reset_cpu();
        finish(2);
        check("ADD R1,R2 -> R1", CPU.RF.r1, 4'b1000);
        finish(3);
        check("STORE R1,0", CPU.DMEM.mem[0], 4'b1000);
        finish(5);
        check("SUB R1,R2 -> R1", CPU.RF.r1, 4'b0010);

        // TEST 3: Logic Operations
        load_program("prog_logic.mem");
        reset_cpu();
        finish(3);
        check("AND -> R3", CPU.RF.r3, 4'b1000);

        // TEST 4: Jumps & PC
        load_program("prog_jump.mem");
        reset_cpu();
        finish(1);
        check("JMP 4", pc_out, 4'b0100);

        // Summary
        if (errors == 0)
            $display("\nSUCCESS: tb_cpu PASSED all %0d checks!", checks);
        else
            $display("\nFAILED: tb_cpu failed %0d of %0d checks.", errors, checks);
        $finish;
    end
endmodule