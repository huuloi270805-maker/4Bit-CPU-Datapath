`timescale 1ns / 1ps

module mux2 #(
    parameter WIDTH = 4
)(
    input [WIDTH-1:0] d0,
    input [WIDTH-1:0] d1,
    input sel,
    output [WIDTH-1:0] y
);
    assign y = (sel == 1'b1) ? d1 : d0;
endmodule