`timescale 1ns / 1ps

module program_counter (
    input clk,
    input rst,
    input pc_en,
    input [3:0] pc_next,
    output reg [3:0] pc_out
);
    always @(posedge clk) begin
        if (rst)
            pc_out <= 4'd0;
        else if (pc_en)
            pc_out <= pc_next;
    end
endmodule