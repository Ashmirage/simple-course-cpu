`timescale 1ns / 1ps

module tb_execute_add;

    reg clk;
    reg reset;
    reg enable;
    reg [31:0] inst;

    wire valid;
    wire write_enable;
    wire [4:0] write_addr;
    wire [31:0] alu_result;

    execute_add dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .inst(inst),
        .valid(valid),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .alu_result(alu_result)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        enable = 0;
        inst = 32'd0;

        // Reset the register file.
        @(posedge clk);
        #1;

        // addi.w r1, r0, 12
        @(negedge clk);
        reset = 0;
        enable = 1;
        inst = 32'h0280_3001;

        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[1] !== 32'd12)
            $fatal(1, "ADDI r1 failed");

        $display("PASS: r1 = 12");

        // addi.w r2, r0, 5
        @(negedge clk);
        inst = 32'h0280_1402;

        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[2] !== 32'd5)
            $fatal(1, "ADDI r2 failed");

        $display("PASS: r2 = 5");

        // add.w r3, r1, r2
        @(negedge clk);
        inst = 32'h0010_0823;

        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[3] !== 32'd17)
            $fatal(1, "ADD r3 failed");

        $display("PASS: r3 = 17");

        // addi.w r4, r1, -1
        @(negedge clk);
        inst = 32'h02bf_fc24;

        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[4] !== 32'd11)
            $fatal(1, "ADDI negative immediate failed");

        $display("PASS: r4 = 11");

        // Pause execution and verify that register contents are preserved.
        @(negedge clk);
        enable = 0;

        // If executed, this instruction would overwrite r1 with 99.
        // addi.w r1, r0, 99
        inst = 32'h0281_8c01;

        @(posedge clk);
        #1;
        if ((write_enable !== 1'b0) ||
            (dut.u_regfile.regs[1] !== 32'd12))
            $fatal(1, "ENABLE check failed");


            // sub.w r5, r1, r2
    // r1 = 12 and r2 = 5, so r5 must be 7.
        @(negedge clk);
        inst = 32'h0011_0825;
        enable = 1;
        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[5] !== 32'd7)
            $fatal(1, "SUB positive result failed");
        
        $display("PASS: r5 = 12 - 5 = 7");
        
        
        // sub.w r6, r2, r1
        // 5 - 12 = -7, represented as FFFFFFF9 in 32-bit two's complement.
        @(negedge clk);
        inst = 32'h0011_0446;
        
        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[6] !== 32'hffff_fff9)
            $fatal(1, "SUB negative result failed");
        
        $display("PASS: r6 = 5 - 12 = -7");
        $display("PASS: execution paused.");
        $display("PASS: instruction execution tests passed.");
        
        
        // and r7, r1, r2
        @(negedge clk);
        enable = 1;
        inst = 32'h0014_8827;
        
        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[7] !== 32'd4)
            $fatal(1, "AND failed");
        
        $display("PASS: r7 = 12 AND 5 = 4");
        
        
        // or r8, r1, r2
        @(negedge clk);
        enable = 1;
        inst = 32'h0015_0828;
        
        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[8] !== 32'd13)
            $fatal(1, "OR failed");
        
        $display("PASS: r8 = 12 OR 5 = 13");
        
        
        // xor r9, r1, r2
        @(negedge clk);
        enable = 1;
        inst = 32'h0015_8829;
        
        @(posedge clk);
        #1;
        if (dut.u_regfile.regs[9] !== 32'd9)
            $fatal(1, "XOR failed");
    
        $display("PASS: r9 = 12 XOR 5 = 9");
        $finish;
    end

endmodule