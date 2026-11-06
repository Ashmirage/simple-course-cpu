`timescale 1ns / 1ps

module tb_decoder_add;

    reg [31:0] inst;

    wire [4:0] raddr1;
    wire [4:0] raddr2;
    wire [4:0] waddr;

    wire reg_we;
    wire [3:0] alu_op;
    wire use_imm;
    wire [31:0] imm;
    wire valid;

    decoder_add dut (
        .inst(inst),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr(waddr),
        .reg_we(reg_we),
        .alu_op(alu_op),
        .use_imm(use_imm),
        .imm(imm),
        .valid(valid)
    );

    initial begin
        // add.w r3, r1, r2
        inst = 32'h0010_0823;
        #10;

        if ((valid !== 1'b1) ||
            (reg_we !== 1'b1) ||
            (raddr1 !== 5'd1) ||
            (raddr2 !== 5'd2) ||
            (waddr !== 5'd3) ||
            (alu_op !== 3'b000) ||
            (use_imm !== 1'b0))
            $fatal(1, "ADD decode failed");

        // addi.w r1, r0, 12
        inst = 32'h0280_3001;
        #10;

        if ((valid !== 1'b1) ||
            (reg_we !== 1'b1) ||
            (raddr1 !== 5'd0) ||
            (raddr2 !== 5'd0) ||
            (waddr !== 5'd1) ||
            (alu_op !== 3'b000) ||
            (use_imm !== 1'b1) ||
            (imm !== 32'd12))
            $fatal(1, "ADDI positive decode failed");

        // addi.w r4, r1, -1
        inst = 32'h02bf_fc24;
        #10;

        if ((valid !== 1'b1) ||
            (reg_we !== 1'b1) ||
            (raddr1 !== 5'd1) ||
            (waddr !== 5'd4) ||
            (use_imm !== 1'b1) ||
            (imm !== 32'hffff_ffff))
            $fatal(1, "ADDI negative decode failed");

        // Encoding not supported by this decoder.
        inst = 32'hffff_ffff;
        #10;

        if ((valid !== 1'b0) ||
            (reg_we !== 1'b0))
            $fatal(1, "Unsupported instruction check failed");

        $display("PASS: ADD and ADDI decoder tests passed.");
        $finish;
    end

endmodule


