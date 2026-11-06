`timescale 1ns / 1ps
module cpu_arith_demo (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,

    output wire [31:0] pc,
    output wire [31:0] inst,
    output wire        valid,
    output wire [31:0] alu_result
);

    wire [31:0] next_pc;
    wire run_enable;

    wire write_enable;
    wire [4:0] write_addr;

    assign next_pc = pc + 32'd4;

    // Advance and execute only supported instructions.
    assign run_enable = enable && valid;

    pc_reg u_pc (
        .clk(clk),
        .reset(reset),
        .enable(run_enable),
        .next_pc(next_pc),
        .pc(pc)
    );

    program_rom_demo u_rom (
        .addr(pc),
        .inst(inst)
    );

    execute_add u_execute (
        .clk(clk),
        .reset(reset),
        .enable(run_enable),
        .inst(inst),
        .valid(valid),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .alu_result(alu_result)
    );

endmodule

