`timescale 1ns / 1ps

module tb_regfile;

    reg clk;
    reg reset;
    reg we;

    reg [4:0] raddr1;
    reg [4:0] raddr2;
    reg [4:0] waddr;
    reg [31:0] wdata;

    wire [31:0] rdata1;
    wire [31:0] rdata2;

    regfile dut (
        .clk(clk),
        .reset(reset),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .we(we),
        .waddr(waddr),
        .wdata(wdata)
    );

    // 10 ns 5ns
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        we = 0;
        raddr1 = 5'd1;
        raddr2 = 5'd2;
        waddr = 0;
        wdata = 0;

        // Reset: wait for a rising edge before checking.
        @(posedge clk);
        #1;
        if ((rdata1 !== 32'd0) ||
            (rdata2 !== 32'd0))
            $fatal(1, "RESET failed");

        // Prepare the write r1 = 12 on a falling edge.
        @(negedge clk);
        reset = 0;
        we = 1;
        waddr = 5'd1;
        wdata = 32'd12;

        // The register must not change before the rising edge.
        #1;
        if (rdata1 !== 32'd0)
            $fatal(1, "Write happened before clock edge");

        @(posedge clk);
        #1;
        if (rdata1 !== 32'd12)
            $fatal(1, "WRITE r1 failed");

        // Write r2 = 5.
        @(negedge clk);
        waddr = 5'd2;
        wdata = 32'd5;

        @(posedge clk);
        #1;
        if ((rdata1 !== 32'd12) ||
            (rdata2 !== 32'd5))
            $fatal(1, "TWO READ PORTS failed");

        // Disable writes and attempt to overwrite r1 with 99.
        @(negedge clk);
        we = 0;
        waddr = 5'd1;
        wdata = 32'd99;

        @(posedge clk);
        #1;
        if (rdata1 !== 32'd12)
            $fatal(1, "WRITE ENABLE failed");

        // Attempt to write register zero.
        @(negedge clk);
        we = 1;
        waddr = 5'd0;
        wdata = 32'd99;
        raddr1 = 5'd0;

        @(posedge clk);
        #1;
        if (rdata1 !== 32'd0)
            $fatal(1, "ZERO REGISTER failed");

        // Change read addresses and check without waiting for a rising edge.
        @(negedge clk);
        we = 0;
        raddr1 = 5'd1;
        raddr2 = 5'd2;

        #1;
        if ((rdata1 !== 32'd12) ||
            (rdata2 !== 32'd5))
            $fatal(1, "COMBINATIONAL READ failed");

        $display("PASS: basic register file tests passed.");
        $finish;
    end

endmodule


