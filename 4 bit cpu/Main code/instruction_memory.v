`timescale 1ns / 1ps

module instruction_memory #(
    parameter PROGRAM_FILE = "prog_jump.mem"
)(
    input [3:0] address,
    output [11:0] instruction
);
    reg [11:0] mem [0:15];
    integer i;
    
    initial begin
        for (i = 0; i < 16; i = i + 1)
            mem[i] = 12'hC00; // NOP mặc định (opcode 1100)
        $readmemh(PROGRAM_FILE, mem);
    end

    assign instruction = mem[address];
endmodule