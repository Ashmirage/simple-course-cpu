`timescale 1ns/1ps
module tb_cpu_twelve #(parameter INJECT=0);
 reg clk=0,reset=1,enable=0;
 always #5 clk=~clk;
 wire [31:0] pc,inst,rom_inst,addr,wd,rd,status;
 wire en,err,fault;
 wire [3:0] strb;
 wire [15:0] led;
 program_rom rom(.pc(pc),.inst(rom_inst));
 // Replace add with sub to verify that the self-test detects bad arithmetic.
 assign inst=(INJECT && pc==56) ? 32'h00110c46 : rom_inst;
 cpu_core dut(.clk(clk),.reset(reset),.enable(enable),.imem_addr(pc),
 .imem_rdata(inst),.imem_error(pc[1:0]!=0 || pc>1023),.dmem_en(en),
 .dmem_wstrb(strb),.dmem_addr(addr),.dmem_wdata(wd),.dmem_rdata(rd),.dmem_error(err),.fault(fault));
 data_mem ram(.clk(clk),.reset(reset),.en(en),.wstrb(strb),.addr(addr),
 .wdata(wd),.rdata(rd),.error(err),.led_out(led),.display_out(),.status_out(status));
 integer i;
 initial begin
 repeat(2) @(negedge clk);reset=0;enable=1;
 for(i=0;i<300;i=i+1) begin
 @(negedge clk);
 if(INJECT && status==32'h80000003) begin
 $display("FAILURE DETECTION TEST PASS: error number 3");$finish;end
 if(fault || status[31]) $fatal(1,"TWELVE FAIL pc=%h status=%h",pc,status);
 if(status==1) begin
 @(negedge clk);
 if(led!==1 || ram.ram[0]!==2026 || ram.ram[1]!==7887 ||
 ram.ram[2]!==9913 || ram.ram[3]!==32'hffffe91b ||
 ram.ram[4]!==(32'd2026 & 32'd7887) ||
 ram.ram[5]!==(32'd2026 | 32'd7887) ||
 ram.ram[6]!==(32'd2026 ^ 32'd7887) || ram.ram[7]!==32'd8704 ||
 dut.u_regfile.regs[13]!==32'd10730) $fatal(1,"RESULT CHECK FAIL");
 $display("TWELVE INSTRUCTION TEST PASS: 2026, 7887, 8704");$finish;
 end
 end
 $fatal(1,"TIMEOUT");
 end
endmodule
module tb_cpu_twelve_injected;
 tb_cpu_twelve #(.INJECT(1)) test();
endmodule
