`timescale 1ns / 1ps
module ego1_a_top (
    input wire clk, input wire btn_reset,
    output wire [7:0] led
);
    // 100 MHz / 10 = 10 MHz, routed through a dedicated global buffer.
    reg [2:0] div_count=0;
    reg div_clk=0;
    always @(posedge clk) begin
        if (div_count==4) begin
            div_count<=0; div_clk<=~div_clk;
        end else div_count<=div_count+1'b1;
    end
    wire cpu_clk;
    BUFG u_clkbuf (.I(div_clk),.O(cpu_clk));
    reg [7:0] startup=8'hff;
    (* ASYNC_REG="TRUE" *) reg [1:0] reset_sync=0;
    always @(posedge cpu_clk) begin
        startup<={startup[6:0],1'b0};
        reset_sync<={reset_sync[0],btn_reset};
    end
    wire reset=(|startup) || reset_sync[1];
    wire passed,failed,running;
    wire [3:0] fail_index;
    arith_selftest u_test (.clk(cpu_clk),.reset(reset),.passed(passed),
        .failed(failed),.running(running),.fail_index(fail_index));
    reg [23:0] heartbeat=0;
    always @(posedge cpu_clk) heartbeat<=heartbeat+1'b1;
    assign led={fail_index,heartbeat[22],running,failed,passed};
endmodule
