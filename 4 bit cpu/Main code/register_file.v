`timescale 1ns / 1ps

module register_file (
    input clk,
    input rst,
    input [1:0] ra,
    input [1:0] rb,
    input [1:0] wa,
    input [3:0] wd,
    input we,
    output reg [3:0] qa,
    output reg [3:0] qb
);
    reg [3:0] r0, r1, r2, r3;

    always @(posedge clk) begin
        if (rst) begin
            r0 <= 4'd0;
            r1 <= 4'd0;
            r2 <= 4'd0;
            r3 <= 4'd0;
        end else if (we) begin
            case (wa)
                2'd0: r0 <= wd;
                2'd1: r1 <= wd;
                2'd2: r2 <= wd;
                2'd3: r3 <= wd;
            endcase
        end
    end

    always @(*) begin
        case (ra)
            2'd0: qa = r0;
            2'd1: qa = r1;
            2'd2: qa = r2;
            2'd3: qa = r3;
        endcase
    end

    always @(*) begin
        case (rb)
            2'd0: qb = r0;
            2'd1: qb = r1;
            2'd2: qb = r2;
            2'd3: qb = r3;
        endcase
    end
endmodule