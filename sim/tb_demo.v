`timescale 1ns/1ps
module tb_demo;
 reg clk=0,reset=1;always #5 clk=~clk;
 wire [31:0] pc,inst,addr,wd,rd,status,left,right;
 reg [7:0] switches=0;reg [4:0] pulse=0;
 wire en,err,fault,mode;wire [3:0] strb;wire [15:0] led;
 program_rom rom(.pc(pc),.inst(inst));
 cpu_core cpu(.clk(clk),.reset(reset),.enable(1'b1),.imem_addr(pc),.imem_rdata(inst),
 .imem_error(pc>1023 || pc[1:0]!=0),.dmem_en(en),.dmem_wstrb(strb),.dmem_addr(addr),
 .dmem_wdata(wd),.dmem_rdata(rd),.dmem_error(err),.fault(fault));
 demo_memory #(.TICK_CYCLES(1000)) memory(.clk(clk),.reset(reset),.en(en),.wstrb(strb),
 .addr(addr),.wdata(wd),.switches(switches),.key_pulse(pulse),.rdata(rd),.error(err),
 .led_out(led),.status_out(status),.display_left(left),.display_right(right),.mode(mode));
 task wait_cycles;input integer n;integer k;begin
 for(k=0;k<n;k=k+1) begin @(negedge clk);if(fault || status[31])$fatal(1,"CPU FAULT pc=%h status=%h",pc,status);end end endtask
 task press;input [4:0] key;begin
 @(negedge clk);pulse=key;@(negedge clk);pulse=0;wait_cycles(200);end endtask
 task expect_right;input [31:0] v;begin
 if(right!==v)$fatal(1,"EDITOR EXPECT %d GOT %d pc=%h",v,right,pc);end endtask
 reg [2:0] seen;integer i;
 initial begin
 repeat(2) @(negedge clk);reset=0;wait_cycles(1800);
 if(status!==1 || right!==2026 || left!==0 || mode) $fatal(1,"STARTUP FAIL");
 for(i=0;i<256;i=i+1)if(memory.base.ram[i]!==0)$fatal(1,"RAM INIT FAIL");
 // Writes are explicit: changing editor must not alter RAM before S3.
 press(2);expect_right(2027);if(memory.base.ram[0]!==0)$fatal(1,"EARLY STORE");press(8);
 switches=8'd128;wait_cycles(200);if(left!==128)$fatal(1,"SLOT128 DISPLAY FAIL");
 press(2);expect_right(2028);press(8);
 switches=8'd255;wait_cycles(200);if(left!==255)$fatal(1,"SLOT255 DISPLAY FAIL");
 press(2);expect_right(2029);press(8);
 if(memory.base.ram[0]!==2027 || memory.base.ram[128]!==2028 || memory.base.ram[255]!==2029)$fatal(1,"ADDRESS ALIAS FAIL");
 switches=0;wait_cycles(200);press(1);expect_right(2027);
 switches=128;wait_cycles(200);press(1);expect_right(2028);
 switches=255;wait_cycles(200);press(1);expect_right(2029);press(4);expect_right(2028);
 // Seed RAM fixtures, then use actual ld.w and arithmetic to test saturation.
 memory.base.ram[255]=9998;press(1);expect_right(9998);press(2);expect_right(9999);press(2);expect_right(9999);
 memory.base.ram[255]=1;press(1);expect_right(1);press(4);expect_right(0);press(4);expect_right(0);
 press(16);if(!mode)$fatal(1,"MODE SWITCH FAIL");
 seen=0;
 for(i=0;i<3500;i=i+1)begin wait_cycles(1);
 if(left==2026)seen[0]=1;if(left==7887)seen[1]=1;if(left==8704)seen[2]=1;end
 if(seen!==7)$fatal(1,"ROLLOVER MISSING NUMBERS");
 press(2);if(!mode)$fatal(1,"MODE LOST");
 press(16);if(mode)$fatal(1,"RETURN MODE FAIL");expect_right(0);
 @(negedge clk);reset=1;wait_cycles(2);reset=0;wait_cycles(1800);expect_right(2026);
 for(i=0;i<256;i=i+1)if(memory.base.ram[i]!==0)$fatal(1,"RESET INIT FAIL");
 $display("INTERACTIVE CPU TEST PASS: 256 slots, independent 0/128/255, +/-1, clamps, modes, reset");$finish;
 end
 initial begin #500000;$fatal(1,"TIMEOUT");end
endmodule
