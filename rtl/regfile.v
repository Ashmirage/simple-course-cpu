`timescale 1ns / 1ps
module regfile (
    input  wire        clk,
    input  wire        reset,

    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,

    input  wire        we,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata
);

    reg [31:0] regs [0:31];

    integer i;

    // Synchronous reset and write.
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end
        else if (we && (waddr != 5'd0)) begin
            regs[waddr] <= wdata;
        end
    end

    // Two combinational read ports; register zero always reads as zero.
    assign rdata1 =
        (raddr1 == 5'd0) ? 32'd0 : regs[raddr1];

    assign rdata2 =
        (raddr2 == 5'd0) ? 32'd0 : regs[raddr2];

endmodule

