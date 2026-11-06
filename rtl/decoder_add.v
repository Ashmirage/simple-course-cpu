`timescale 1ns / 1ps
`include "cpu_defs.vh"

module decoder_add (
    input  wire [31:0] inst,

    output wire [4:0]  raddr1,
    output wire [4:0]  raddr2,
    output wire [4:0]  waddr,

    output wire        reg_we,
    output wire [3:0]  alu_op,
    output wire        use_imm,
    output wire [31:0] imm,
    output wire        valid
);


    wire is_add_w;
    wire is_addi_w;
    wire is_sub_w;
    wire is_reg_reg;
    
    wire is_and;
    wire is_or;
    wire is_xor;
    
    assign is_and = (inst[31:15] == 17'h00029);
    assign is_or  = (inst[31:15] == 17'h0002a);
    assign is_xor = (inst[31:15] == 17'h0002b);

    assign is_add_w  = (inst[31:15] == 17'h00020);
    assign is_addi_w = (inst[31:22] == 10'h00a);
    assign is_sub_w  = (inst[31:15] == 17'h00022);

    // Register-register instructions use both read ports.
// Instructions with two source registers.
    assign is_reg_reg = is_add_w | is_sub_w | is_and | is_or | is_xor;
    
    // All six currently supported instructions.
    assign valid = is_reg_reg | is_addi_w;

    assign raddr1 = valid ? inst[9:5] : 5'd0;
    assign raddr2 = is_reg_reg ? inst[14:10] : 5'd0;
    assign waddr  = valid ? inst[4:0] : 5'd0;

    // Select the ALU operation for each supported instruction.
    assign alu_op =
    is_sub_w ? `ALU_SUB :
    is_and   ? `ALU_AND :
    is_or    ? `ALU_OR  :
    is_xor   ? `ALU_XOR :
               `ALU_ADD;

    assign use_imm = is_addi_w;

    assign imm = is_addi_w
               ? {{20{inst[21]}}, inst[21:10]}
               : 32'd0;

    assign reg_we = valid;

endmodule