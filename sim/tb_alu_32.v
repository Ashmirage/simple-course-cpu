`timescale 1ns / 1ps

module tb_alu32;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  op;
    wire [31:0] result;

    alu32 dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    initial begin
        a = 32'd12;
        b = 32'd5;

        op = 3'b000;
        #10;
        if (result !== 32'd17)
            $fatal(1, "ADD failed");

        op = 3'b001;
        #10;
        if (result !== 32'd7)
            $fatal(1, "SUB failed");

        op = 3'b010;
        #10;
        if (result !== 32'd4)
            $fatal(1, "AND failed");

        op = 3'b011;
        #10;
        if (result !== 32'd13)
            $fatal(1, "OR failed");

        op = 3'b100;
        #10;
        if (result !== 32'd9)
            $fatal(1, "XOR failed");
            
                // Add one to the maximum unsigned value; retain the low 32 bits.
        a  = 32'hFFFF_FFFF;
        b  = 32'd1;
        op = 3'b000;
        #10;
        if (result !== 32'd0)
            $fatal(1, "ADD wraparound failed");
        
        // 5 - 12 = -7, represented as FFFF_FFF9 in 32-bit two's complement.
        a  = 32'd5;
        b  = 32'd12;
        op = 3'b001;
        #10;
        if (result !== 32'hFFFF_FFF9)
        $fatal(1, "SUB negative result failed");

        $display("PASS: all 5 basic ALU tests passed.");
        $finish;
    end

endmodule




