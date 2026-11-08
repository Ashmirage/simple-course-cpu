`timescale 1ns/1ps
// Independent debounce per key; one pulse per press, release required to re-arm.
module button_events #(parameter STABLE_CYCLES=250000)(
 input wire clk,reset,input wire [4:0] raw,
 output reg [4:0] pulse);
 (* ASYNC_REG="TRUE" *) reg [4:0] meta,sync;
 reg [4:0] stable;
 reg [18:0] count[0:4];integer i;
 always @(posedge clk) begin
 if(reset) begin meta<=0;sync<=0;stable<=0;pulse<=0;for(i=0;i<5;i=i+1)count[i]<=0;end
 else begin
 meta<=raw;sync<=meta;pulse<=0;
 for(i=0;i<5;i=i+1) begin
 if(sync[i]==stable[i]) count[i]<=0;
 else if(count[i]==STABLE_CYCLES-1) begin
 count[i]<=0;stable[i]<=sync[i];pulse[i]<=sync[i];
 end else count[i]<=count[i]+1'b1;
 end end end
endmodule
