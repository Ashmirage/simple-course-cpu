`timescale 1ns/1ps
`include "cpu_defs.vh"
module cpu_core(
 input wire clk, reset, enable,
 output wire [31:0] imem_addr,
 input wire [31:0] imem_rdata,
 input wire imem_error,
 output wire dmem_en,
 output wire [3:0] dmem_wstrb,
 output wire [31:0] dmem_addr, dmem_wdata,
 input wire [31:0] dmem_rdata,
 input wire dmem_error,
 output reg fault,
 output wire debug_commit,
 output wire [31:0] debug_pc, debug_inst,
 output wire debug_wen,
 output wire [4:0] debug_wnum,
 output wire [31:0] debug_wdata
);
 wire valid, reg_we, use_imm, mem_en, mem_we;
 wire [4:0] raddr1,raddr2,waddr;
 wire [3:0] alu_op;
 wire [1:0] wb_sel;
 wire [2:0] br_type;
 wire [31:0] imm,br_offset,rdata1,rdata2,alu_result,pc;
 wire running=enable && !reset && !fault;
 wire bad=imem_error || !valid || (mem_en && dmem_error);
 wire commit=running && !bad;
 wire taken=(br_type==`BR_B) ||
             ((br_type==`BR_BEQ) && (rdata1==rdata2)) ||
             ((br_type==`BR_BNE) && (rdata1!=rdata2));
 wire [31:0] next_pc=taken ? pc+br_offset : pc+32'd4;
 wire [31:0] wb_data=(wb_sel==`WB_MEM) ? dmem_rdata :
                          (wb_sel==`WB_PC4) ? pc+32'd4 : alu_result;
 always @(posedge clk)
   if(reset) fault<=0;
   else if(running && bad) fault<=1;
 pc_reg u_pc(.clk(clk),.reset(reset),.enable(commit),.next_pc(next_pc),.pc(pc));
 decoder u_decoder(.inst(imem_rdata),.valid(valid),.raddr1(raddr1),.raddr2(raddr2),
 .src1_used(),.src2_used(),.waddr(waddr),.reg_we(reg_we),.alu_op(alu_op),
 .use_imm(use_imm),.imm(imm),.mem_en(mem_en),.mem_we(mem_we),
 .wb_sel(wb_sel),.br_type(br_type),.br_offset(br_offset));
 regfile u_regfile(.clk(clk),.reset(reset),.raddr1(raddr1),.raddr2(raddr2),
 .rdata1(rdata1),.rdata2(rdata2),.we(commit && reg_we),.waddr(waddr),.wdata(wb_data));
 alu32 u_alu(.a(rdata1),.b(use_imm?imm:rdata2),.op(alu_op),.result(alu_result));
 
 assign dmem_en=running && valid && !imem_error && mem_en;
 assign dmem_wstrb=(dmem_en && mem_we)?4'b1111:4'b0000;
 assign dmem_addr=alu_result;
 assign dmem_wdata=rdata2;
 assign imem_addr=pc;
 assign debug_commit=commit;
 assign debug_pc=pc;
 assign debug_inst=imem_rdata;
 assign debug_wen=commit && reg_we && (waddr!=0);
 assign debug_wnum=waddr;
 assign debug_wdata=wb_data;
endmodule
