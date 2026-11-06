`timescale 1ns / 1ps
module arith_selftest (
    input wire clk, input wire reset,
    output reg passed, output reg failed,
    output wire running, output reg [3:0] fail_index
);
    wire [31:0] pc, inst, result;
    wire valid;
    reg [3:0] index;
    reg [31:0] expected;
    assign running = !reset && !passed && !failed;
    cpu_arith_demo u_cpu (.clk(clk), .reset(reset), .enable(running),
        .pc(pc), .inst(inst), .valid(valid), .alu_result(result));
    always @(*) begin
        case (index)
            0,7: expected=32'd12;
            1,8: expected=32'd5;
            2,9: expected=32'd17;
            3,10: expected=32'd7;
            4,11: expected=32'd4;
            5,12: expected=32'd13;
            6,13: expected=32'd9;
            default: expected=32'd0;
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
            passed<=0; failed<=0; index<=0; fail_index<=0;
        end else if (running) begin
            if (!valid || pc != {26'd0,index,2'b00} || result != expected) begin
                failed<=1; fail_index<=index;
            end else if (index==13) begin
                passed<=1;
            end else index<=index+1'b1;
        end
    end
endmodule
