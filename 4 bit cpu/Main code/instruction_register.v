`timescale 1ns / 1ps

module instruction_register (
    input clk,
    input rst,
    input ir_load,
    input flush,
    input [3:0] pc_in,
    input [11:0] instruction_in,
    output reg [11:0] instruction_out,
    output reg [3:0] pc_out,
    output reg valid_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            instruction_out <= 12'hC00; // NOP
            pc_out <= 4'd0;
            valid_out <= 1'b0;
        end else if (ir_load) begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
            valid_out <= 1'b1;
        end
    end
endmodule