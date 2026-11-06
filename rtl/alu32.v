`timescale 1ns / 1ps
`include "cpu_defs.vh"

module alu32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  op,
    output reg  [31:0] result
);

    always @(*) begin 
        case (op)
            `ALU_ADD:    result = a + b;
            `ALU_SUB:    result = a - b;
            `ALU_AND:    result = a & b;
            `ALU_OR:     result = a | b;
            `ALU_XOR:    result = a ^ b;
            `ALU_PASS_B: result = b;
            default:    result = 32'd0;
        endcase
    end

endmodule

