`timescale 1ns/1ps

module ego1_top #(parameter FILTER_CYCLES=250000, parameter TICK_CYCLES=50000000)(
    input  wire clk,
    input  wire reset_n,
    input  wire [4:0] buttons,
    input  wire [7:0] switches,
    output wire [7:0] led,
    output wire [7:0] seg,
    output wire [7:0] seg_right,
    output wire [7:0] digit
);

    wire cpu_clk;
    wire locked;

    
    clk_wiz_0 u_clock (
        .clk_in1(clk),
        .reset(1'b0),
        .clk_out1(cpu_clk),
        .locked(locked)
    );

    
    
    (* ASYNC_REG = "TRUE" *)
    reg [1:0] reset_sync = 2'b11;

    wire reset_request = !reset_n || !locked;

    always @(posedge cpu_clk or posedge reset_request) begin
        if (reset_request)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    wire reset = reset_sync[1];

    
    // S6 asserts immediately; release must remain stable for about 10 ms.
    reg [18:0] release_count=0;
    reg reset_filtered=1;
    always @(posedge cpu_clk) begin
        if(reset) begin release_count<=0;reset_filtered<=1;end
        else if(release_count==FILTER_CYCLES-1) reset_filtered<=0;
        else release_count<=release_count+1'b1;
    end
    wire system_reset=reset || reset_filtered;
    wire enable=1'b1;
    wire [4:0] key_pulse;
    button_events #(.STABLE_CYCLES(FILTER_CYCLES)) keys(.clk(cpu_clk),.reset(system_reset),.raw(buttons),.pulse(key_pulse));
    (* ASYNC_REG="TRUE" *) reg [7:0] sw_meta,sw_sync;
    reg [7:0] sw_stable;reg [18:0] sw_count;
    always @(posedge cpu_clk) begin
        if(system_reset) begin sw_meta<=0;sw_sync<=0;sw_stable<=0;sw_count<=0;end
        else begin
            sw_meta<=switches;sw_sync<=sw_meta;
            if(sw_sync==sw_stable) sw_count<=0;
            else if(sw_count==FILTER_CYCLES-1) begin sw_stable<=sw_sync;sw_count<=0;end
            else sw_count<=sw_count+1'b1;
        end
    end

    wire [31:0] pc, inst;
    wire [31:0] addr, wd, rd;
    wire en, err, fault;
    wire [3:0] strb;
    wire [15:0] result;
    wire [31:0] test_status;
    wire [31:0] display_value;
    wire [31:0] right_value;
    wire demo_mode;
    sevenseg_display display_driver(.clk(cpu_clk),.reset(system_reset),
        .visible(test_status==1 && !fault),.value(display_value),
        .seg(seg),.digit(digit[3:0]));
    sevenseg_display right_driver(.clk(cpu_clk),.reset(system_reset),
        .visible(test_status==1 && !fault && !demo_mode),.value(right_value),
        .seg(seg_right),.digit(digit[7:4]));

    program_rom rom (
        .pc(pc),
        .inst(inst)
    );

    cpu_core cpu (
        .clk(cpu_clk),
        .reset(system_reset),
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

    demo_memory #(.TICK_CYCLES(TICK_CYCLES)) memory (
        .clk(cpu_clk),
        .reset(system_reset),
        .switches(sw_stable),.key_pulse(key_pulse),
        .en(en),
        .wstrb(strb),
        .addr(addr),
        .wdata(wd),
        .rdata(rd),
        .error(err),
        .led_out(result),
        .display_left(display_value),.display_right(right_value),.mode(demo_mode),
        .status_out(test_status)
    );

    
    assign led = {fault, test_status[31], (test_status[31] ? result[4:0] : {4'b0,demo_mode}), test_status == 32'd1};

endmodule
