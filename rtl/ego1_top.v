`timescale 1ns/1ps

module ego1_top(
    input  wire clk,
    input  wire btn_reset,
    output wire [7:0] led
);

    wire cpu_clk;
    wire locked;

    
    clk_wiz_0 u_clock (
        .clk_in1(clk),
        .reset(btn_reset),
        .clk_out1(cpu_clk),
        .locked(locked)
    );

    
    
    (* ASYNC_REG = "TRUE" *)
    reg [1:0] reset_sync = 2'b11;

    wire reset_request = btn_reset || !locked;

    always @(posedge cpu_clk or posedge reset_request) begin
        if (reset_request)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    wire reset = reset_sync[1];

    
    reg [19:0] divider = 0;

    always @(posedge cpu_clk) begin
        if (reset)
            divider <= 0;
        else
            divider <= divider + 1'b1;
    end

    wire enable = (divider == 0);

    wire [31:0] pc, inst;
    wire [31:0] addr, wd, rd;
    wire en, err, fault;
    wire [3:0] strb;
    wire [15:0] result;
    wire [31:0] test_status;

    program_rom rom (
        .pc(pc),
        .inst(inst)
    );

    cpu_core cpu (
        .clk(cpu_clk),
        .reset(reset),
        .enable(enable),
        .imem_addr(pc),
        .imem_rdata(inst),
        .imem_error((pc[1:0] != 0) || (pc > 1023)),
        .dmem_en(en),
        .dmem_wstrb(strb),
        .dmem_addr(addr),
        .dmem_wdata(wd),
        .dmem_rdata(rd),
        .dmem_error(err),
        .fault(fault)
    );

    data_mem memory (
        .clk(cpu_clk),
        .reset(reset),
        .en(en),
        .wstrb(strb),
        .addr(addr),
        .wdata(wd),
        .rdata(rd),
        .error(err),
        .led_out(result),
        .display_out(),
        .status_out(test_status)
    );

    
    assign led = {fault, test_status[31], (test_status[31] ? result[4:0] : 5'b0), test_status == 32'd1};

endmodule