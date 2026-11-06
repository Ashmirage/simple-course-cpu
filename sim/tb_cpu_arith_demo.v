`timescale 1ns / 1ps

module tb_cpu_arith_demo;

    reg clk;
    reg reset;
    reg enable;

    wire [31:0] pc;
    wire [31:0] inst;
    wire valid;
    wire [31:0] alu_result;

    cpu_arith_demo dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .pc(pc),
        .inst(inst),
        .valid(valid),
        .alu_result(alu_result)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        enable = 0;

        @(posedge clk);
        #1;

        @(negedge clk);
        reset = 0;
        enable = 1;

        // Execute seven consecutive instructions.
        repeat (7) begin
            @(posedge clk);

            // Observe the current instruction before sequential state updates.
            $display(
                "Execute: PC=%h inst=%h result=%h",
                pc, inst, alu_result
            );

            // Wait for the current writeback to complete.
            #1;
        end

        @(negedge clk);
        enable = 0;

        if (pc !== 32'h0000_001c)
            $fatal(1, "PC progression failed");

        if (dut.u_execute.u_regfile.regs[1] !== 32'd12)
            $fatal(1, "r1 failed");

        if (dut.u_execute.u_regfile.regs[2] !== 32'd5)
            $fatal(1, "r2 failed");

        if (dut.u_execute.u_regfile.regs[3] !== 32'd17)
            $fatal(1, "r3 failed");

        if (dut.u_execute.u_regfile.regs[4] !== 32'd7)
            $fatal(1, "r4 failed");

        if (dut.u_execute.u_regfile.regs[5] !== 32'd4)
            $fatal(1, "r5 failed");

        if (dut.u_execute.u_regfile.regs[6] !== 32'd13)
            $fatal(1, "r6 failed");

        if (dut.u_execute.u_regfile.regs[7] !== 32'd9)
            $fatal(1, "r7 failed");

        $display("PASS: automatic instruction execution.");
        $finish;
    end

endmodule


