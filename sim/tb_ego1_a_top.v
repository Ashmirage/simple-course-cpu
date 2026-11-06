`timescale 1ns / 1ps
module tb_ego1_a_top;
    reg clk=0;
    reg btn_reset=0;
    wire [7:0] led;
    ego1_a_top dut(.clk(clk),.btn_reset(btn_reset),.led(led));
    always #5 clk=~clk;
    initial begin
        #10000;
        if (led[2:0] !== 3'b001) $fatal(1,"Power-on selftest failed");
        $display("PASS: power-on calculation and register readback");
        btn_reset=1;
        #1000;
        if (led[1:0] !== 2'b00) $fatal(1,"Reset failed");
        btn_reset=0;
        #10000;
        if (led[2:0] !== 3'b001) $fatal(1,"Restart selftest failed");
        $display("PASS: board wrapper clock/reset/restart");
        // Inject an unsupported instruction and check the failure indicator.
        btn_reset=1;
        #1000;
        force dut.u_test.u_cpu.inst=32'hffff_ffff;
        btn_reset=0;
        #1000;
        if (led[2:0] !== 3'b010) $fatal(1,"Failure indicator failed");
        release dut.u_test.u_cpu.inst;
        #1000;
        if (led[2:0] !== 3'b010) $fatal(1,"Failure was not latched");
        $display("PASS: injected error is detected and held");
        $finish;
    end
endmodule
