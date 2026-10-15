`timescale 1ns / 1ps

module tb_register_file;
    reg clk = 0;
    reg rst = 1;
    reg [1:0] ra = 0, rb = 0, wa = 0;
    reg [3:0] wd = 0;
    reg we = 0;
    wire [3:0] qa, qb;
    integer errors = 0;
    integer tests = 0;

    always #5 clk = ~clk;

    register_file DUT (.clk(clk), .rst(rst), .ra(ra), .rb(rb), .wa(wa), .wd(wd), .we(we), .qa(qa), .qb(qb));

    task check;
        input [8*35:1] name;
        input [3:0] actual, expected;
        begin
            tests = tests + 1;
            if (actual === expected) begin
                $display("PASS %0s = %b", name, actual);
            end else begin
                $display("FAIL %0s = %b (expected %b)", name, actual, expected);
                errors = errors + 1;
            end
        end
    endtask

    task write_reg;
        input [1:0] addr;
        input [3:0] data;
        begin
            wa = addr; wd = data; we = 1;
            @(posedge clk); #1;
            we = 0;
        end
    endtask

    initial begin
        $display("\n===== tb_register_file: register file test =====");
        @(posedge clk); #1;
        rst = 0;
        ra = 0; rb = 3; #1;
        check("after reset R0 (port A)", qa, 4'b0000);
        check("after reset R3 (port B)", qb, 4'b0000);

        write_reg(2'd0, 4'b0001);
        write_reg(2'd1, 4'b0101);
        write_reg(2'd2, 4'b1010);
        write_reg(2'd3, 4'b1111);

        ra = 0; rb = 1; #1;
        check("R0 on port A", qa, 4'b0001);
        check("R1 on port B", qb, 4'b0101);

        ra = 2; rb = 3; #1;
        check("R2 on port A", qa, 4'b1010);
        check("R3 on port B", qb, 4'b1111);

        if (errors == 0)
            $display("tb_register_file PASSED: %0d of %0d checks OK\n", tests, tests);
        else
            $display("tb_register_file FAILED: %0d of %0d checks failed\n", errors, tests);
        $finish;
    end
endmodule