`timescale 1ns/1ps
// Uses the real Clocking Wizard simulation model; filter duration shortened only for simulation.
module tb_ego1_demo;
 reg clk=0;always #5 clk=~clk;
 reg reset_n=0;reg [4:0] buttons=0;reg [7:0] switches=0;
 wire [7:0] led,seg,seg_right,digit;
 ego1_top #(.FILTER_CYCLES(8),.TICK_CYCLES(1000)) dut(
 .clk(clk),.reset_n(reset_n),.buttons(buttons),.switches(switches),
 .led(led),.seg(seg),.seg_right(seg_right),.digit(digit));
 task settle;begin repeat(8000)@(negedge clk);
 if(dut.fault)$fatal(1,"BOARD FAULT");end endtask
 task press;input [4:0] key;begin
 @(negedge clk);buttons=key;settle;buttons=0;settle;end endtask
 initial begin
 #200;reset_n=1;settle;
 if(led!==1 || dut.right_value!==2026)$fatal(1,"BOARD STARTUP FAIL");
 switches=8'h80;settle;if(dut.display_value!==128)$fatal(1,"SWITCH INPUT FAIL");
 press(2);if(dut.right_value!==2027)$fatal(1,"RAW BUTTON ADD FAIL");
 press(8);press(2);press(1);
 if(dut.right_value!==2027)$fatal(1,"BOARD RAM READ FAIL");
 press(16);if(!dut.demo_mode || led[1]!==1 || digit[7:4]!==0)$fatal(1,"BOARD MODE FAIL");
 press(16);if(dut.demo_mode || dut.right_value!==2027)$fatal(1,"BOARD RETURN FAIL");
 reset_n=0;repeat(20)@(negedge clk);reset_n=1;settle;
 if(dut.right_value!==2026 || led!==1)$fatal(1,"S6 RESET FAIL");
 $display("BOARD IO TEST PASS: MMCM, S6 reset, switches, keys, memory, modes");$finish;
 end
 initial begin #3000000;$fatal(1,"BOARD TIMEOUT");end
endmodule
