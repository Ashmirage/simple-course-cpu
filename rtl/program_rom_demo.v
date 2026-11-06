`timescale 1ns / 1ps
module program_rom_demo (
    input  wire [31:0] addr,
    output reg  [31:0] inst
);

    always @(*) begin
        case (addr)
            // r1 = 12
            32'h0000_0000: inst = 32'h0280_3001;

            // r2 = 5
            32'h0000_0004: inst = 32'h0280_1402;

            // r3 = r1 + r2 = 17
            32'h0000_0008: inst = 32'h0010_0823;

            // r4 = r1 - r2 = 7
            32'h0000_000c: inst = 32'h0011_0824;

            // r5 = r1 AND r2 = 4
            32'h0000_0010: inst = 32'h0014_8825;

            // r6 = r1 OR r2 = 13
            32'h0000_0014: inst = 32'h0015_0826;

            // r7 = r1 XOR r2 = 9
            32'h0000_0018: inst = 32'h0015_8827;

            // Demo padding instruction: add.w r0,r0,r0.
            32'h0000001c: inst = 32'h00100020; // read back r1 via add.w r0,r1,r0
            32'h00000020: inst = 32'h00100040; // read back r2 via add.w r0,r2,r0
            32'h00000024: inst = 32'h00100060; // read back r3 via add.w r0,r3,r0
            32'h00000028: inst = 32'h00100080; // read back r4 via add.w r0,r4,r0
            32'h0000002c: inst = 32'h001000a0; // read back r5 via add.w r0,r5,r0
            32'h00000030: inst = 32'h001000c0; // read back r6 via add.w r0,r6,r0
            32'h00000034: inst = 32'h001000e0; // read back r7 via add.w r0,r7,r0
            default: inst = 32'h0010_0000;
        endcase
    end

endmodule

