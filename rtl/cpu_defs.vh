`ifndef CPU_DEFS_VH
`define CPU_DEFS_VH

// Shared interface V1.0 -- see the companion Markdown specification.
`define ALU_ADD      4'h0
`define ALU_SUB      4'h1
`define ALU_AND      4'h2
`define ALU_OR       4'h3
`define ALU_XOR      4'h4
`define ALU_NOR      4'h5
`define ALU_SLT      4'h6
`define ALU_SLTU     4'h7
`define ALU_SLL      4'h8
`define ALU_SRL      4'h9
`define ALU_SRA      4'hA
`define ALU_PASS_B   4'hB

`define WB_ALU       2'd0
`define WB_MEM       2'd1
`define WB_PC4       2'd2

`define BR_NONE      3'd0
`define BR_BEQ       3'd1
`define BR_BNE       3'd2
`define BR_B        3'd3
`define BR_JIRL      3'd4
`define BR_BLT       3'd5
`define BR_BGE       3'd6

`define RESET_PC     32'h0000_0000
`define IMEM_BASE    32'h0000_0000
`define IMEM_LAST    32'h0000_03FF
`define DMEM_BASE    32'h1000_0000
`define DMEM_LAST    32'h1000_03FF
`define MMIO_LED     32'h1FFF_0000
`define MMIO_DISPLAY 32'h1FFF_0004
`define MMIO_STATUS  32'h1FFF_0008
`define TEST_RUNNING 32'h0000_0000
`define TEST_PASS    32'h0000_0001
`define TEST_FAIL    32'h8000_0000
`define SELF_LOOP    32'h5000_0000

`endif
