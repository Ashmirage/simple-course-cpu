`timescale 1ns / 1ps





















`include "cpu_defs.vh"

module pc_reg (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);

    always @(posedge clk) begin
        if (reset)
            pc <= `RESET_PC;
        else if (enable)
            pc <= next_pc;
    end

endmodule
