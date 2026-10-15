`timescale 1ns / 1ps

module adder_subtractor (
    input [3:0] a,
    input [3:0] b,
    input do_sub,
    output reg [3:0] result,
    output reg carry
);
    reg [4:0] full_sum;
    always @(*) begin
        full_sum = 5'b0;
        if (do_sub == 1'b0) begin
            full_sum = a + b;
            result = full_sum[3:0];
            carry = full_sum[4];
        end else begin
            result = a - b;
            if (a >= b)
                carry = 1'b1; // No borrow (ARM convention)
            else
                carry = 1'b0; // Borrow
        end
    end
endmodule

module logic_unit (
    input [3:0] a,
    input [3:0] b,
    input [2:0] alu_ctrl,
    output reg [3:0] result
);
    always @(*) begin
        case (alu_ctrl)
            3'd2: result = a & b;
            3'd3: result = a | b;
            3'd4: result = a ^ b;
            3'd5: result = ~a;
            3'd6: result = b; // PASS
            default: result = 4'b0;
        endcase
    end
endmodule

module zero_detector (
    input [3:0] value,
    output zero
);
    assign zero = (value == 4'b0) ? 1'b1 : 1'b0;
endmodule

module alu (
    input [3:0] a,
    input [3:0] b,
    input [2:0] alu_ctrl,
    output reg [3:0] result,
    output reg carry,
    output zero
);
    wire [3:0] arith_result;
    wire arith_carry;
    wire [3:0] logic_result;
    wire do_sub = (alu_ctrl == 3'd1);

    adder_subtractor ADDSUB (
        .a(a), .b(b), .do_sub(do_sub),
        .result(arith_result), .carry(arith_carry)
    );

    logic_unit LOGIC (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .result(logic_result)
    );

    always @(*) begin
        if (alu_ctrl == 3'd0 || alu_ctrl == 3'd1) begin
            result = arith_result;
            carry = arith_carry;
        end else begin
            result = logic_result;
            carry = 1'b0;
        end
    end

    zero_detector ZERO (
        .value(result),
        .zero(zero)
    );
endmodule