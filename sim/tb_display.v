`timescale 1ns/1ps
module tb_display;
 reg clk=0,reset=1;always #5 clk=~clk;
 reg [31:0] value=0;
 wire [7:0] seg;wire [3:0] digit;
 sevenseg_display #(.SCAN_CYCLES(4)) dut(.clk(clk),.reset(reset),.visible(1'b1),.value(value),.seg(seg),.digit(digit));
 function [7:0] code;input [3:0] n;begin
 case(n) 0:code=8'h3f;1:code=8'h06;2:code=8'h5b;3:code=8'h4f;
 4:code=8'h66;5:code=8'h6d;6:code=8'h7d;7:code=8'h07;8:code=8'h7f;9:code=8'h6f;default:code=0;endcase end endfunction
 task check;input [31:0] v;input [15:0] b;
 integer j,k;reg [3:0] seen;
 begin
 @(negedge clk);value=v;repeat(17) @(negedge clk);
 if(dut.bcd!==b) $fatal(1,"DECIMAL CONVERSION FAIL %d",v);
 seen=0;
 for(j=0;j<20;j=j+1) begin
 @(negedge clk);
 for(k=0;k<4;k=k+1) if(digit[k]) begin
 seen[k]=1;if(digit!==(4'b1<<k) || seg!==code((b>>((3-k)*4))&15)) $fatal(1,"SCAN FAIL");end
 end
 if(seen!==15) $fatal(1,"MISSING DIGIT");
 end endtask
 initial begin
 repeat(2) @(negedge clk);reset=0;
 check(2026,16'h2026);check(7887,16'h7887);check(8704,16'h8704);
 $display("DISPLAY DECIMAL AND SCAN TEST PASS");$finish;end
endmodule
