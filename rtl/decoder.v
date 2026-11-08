`timescale 1ns / 1ps






















`include "cpu_defs.vh"

module decoder (
    input wire [31:0] inst,

    
    output reg valid,

    
    output reg [4:0] raddr1,
    output reg [4:0] raddr2,
    output reg src1_used,
    output reg src2_used,

    
    output reg [4:0] waddr,
    output reg reg_we,

    
    output reg [3:0] alu_op,
    output reg use_imm,
    output reg [31:0] imm,

    
    output reg mem_en,
    output reg mem_we,

    
    output reg [1:0] wb_sel,

    
    output reg [2:0] br_type,
    output reg [31:0] br_offset
);

    always @(*) begin

        
        valid = 1'b0;

        raddr1 = 5'd0;
        raddr2 = 5'd0;
        src1_used = 1'b0;
        src2_used = 1'b0;

        waddr = 5'd0;
        reg_we = 1'b0;

        alu_op = `ALU_ADD;
        use_imm = 1'b0;
        imm = 32'd0;

        mem_en = 1'b0;
        mem_we = 1'b0;

        wb_sel = `WB_ALU;

        br_type = `BR_NONE;
        br_offset = 32'd0;

        
        if (inst[31:15]==17'h20 || inst[31:15]==17'h22 ||
 inst[31:15]==17'h29 || inst[31:15]==17'h2a || inst[31:15]==17'h2b || inst[31:22]==10'h00a) begin
 valid=1; raddr1=inst[9:5]; src1_used=1; waddr=inst[4:0]; reg_we=1;
 if(inst[31:22]==10'h00a) begin use_imm=1; imm={{20{inst[21]}},inst[21:10]}; end
 else begin raddr2=inst[14:10]; src2_used=1; end
 case(inst[31:15])
 17'h22: alu_op=`ALU_SUB;
 17'h29: alu_op=`ALU_AND;
 17'h2a: alu_op=`ALU_OR;
 17'h2b: alu_op=`ALU_XOR;
 default: alu_op=`ALU_ADD;
 endcase
 end else if (inst[31:26] == 6'b010100) begin
 valid=1; br_type=`BR_B;
 br_offset={{4{inst[9]}},inst[9:0],inst[25:10],2'b00};
 end else if (inst[31:26] == 6'b010110 || inst[31:26] == 6'b010111) begin
 valid=1; raddr1=inst[9:5]; raddr2=inst[4:0]; src1_used=1; src2_used=1;
 br_type=(inst[31:26]==6'b010110)?`BR_BEQ:`BR_BNE;
 br_offset={{14{inst[25]}},inst[25:10],2'b00};
 end else if (inst[31:25] == 7'b0001010) begin
            valid = 1'b1;

            waddr = inst[4:0];
            reg_we = 1'b1;

            alu_op = `ALU_PASS_B;
            use_imm = 1'b1;
            imm = {inst[24:5], 12'b0};

            wb_sel = `WB_ALU;
        end
        

    else if (inst[31:22] == 10'b0010100110) begin
        
        valid = 1'b1;
    
        
        raddr1 = inst[9:5];
        src1_used = 1'b1;
    
        
        raddr2 = inst[4:0];
        src2_used = 1'b1;
    
        
        waddr = 5'd0;
        reg_we = 1'b0;
    
        
        alu_op = `ALU_ADD;
        use_imm = 1'b1;
    
        
        imm = {{20{inst[21]}}, inst[21:10]};
    
        
        mem_en = 1'b1;
        mem_we = 1'b1;
    end
    
    else if (inst[31:22] == 10'b0010100010) begin
        
        valid = 1'b1;
    
        
        raddr1 = inst[9:5];
        src1_used = 1'b1;
    
        
        raddr2 = 5'd0;
        src2_used = 1'b0;
    
        
        waddr = inst[4:0];
        reg_we = 1'b1;
    
        
        alu_op = `ALU_ADD;
        use_imm = 1'b1;
    
        
        imm = {{20{inst[21]}}, inst[21:10]};
    
        
        mem_en = 1'b1;
        mem_we = 1'b0;
    
        
        wb_sel = `WB_MEM;
    end
    
end

endmodule

