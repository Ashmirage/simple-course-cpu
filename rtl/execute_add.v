`timescale 1ns / 1ps
module execute_add (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [31:0] inst,

    output wire        valid,
    output wire        write_enable,
    output wire [4:0]  write_addr,
    output wire [31:0] alu_result
);

    wire [4:0] raddr1;
    wire [4:0] raddr2;

    wire       reg_we;
    wire [3:0] alu_op;
    wire       use_imm;
    wire [31:0] imm;

    wire [31:0] rdata1;
    wire [31:0] rdata2;
    wire [31:0] alu_b;

    decoder_add u_decoder (
        .inst(inst),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(write_addr),
        .reg_we(reg_we),
        .alu_op(alu_op),
        .use_imm(use_imm),
        .imm(imm),
        .valid(valid)
    );

    // Write only when enabled, requested by the decoder, and not in reset.
    assign write_enable = enable && reg_we && !reset;

    regfile u_regfile (
        .clk(clk),
        .reset(reset),

        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2),

        .we(write_enable),
        .waddr(write_addr),
        .wdata(alu_result)
    );

    // Select a register value or the extended immediate as operand B.
    assign alu_b = use_imm ? imm : rdata2;

    alu32 u_alu (
        .a(rdata1),
        .b(alu_b),
        .op(alu_op),
        .result(alu_result)
    );

endmodule

