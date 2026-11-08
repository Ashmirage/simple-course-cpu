`timescale 1ns/1ps
module tb_button_events;
 reg clk=0,reset=1;always #5 clk=~clk;
 reg [4:0] raw=0;wire [4:0] pulse;integer presses=0;
 button_events #(.STABLE_CYCLES(4)) dut(.clk(clk),.reset(reset),.raw(raw),.pulse(pulse));
 always @(negedge clk) if(pulse[0]) presses=presses+1;
 initial begin
 repeat(2) @(negedge clk);reset=0;
 raw=1;@(negedge clk);raw=0;repeat(2)@(negedge clk);raw=1;
 repeat(20)@(negedge clk);if(presses!=1)$fatal(1,"BOUNCE/HOLD FAIL");
 raw=0;repeat(10)@(negedge clk);raw=1;repeat(10)@(negedge clk);
 if(presses!=2)$fatal(1,"REARM FAIL");
 $display("BUTTON DEBOUNCE TEST PASS");$finish;
 end
endmodule
