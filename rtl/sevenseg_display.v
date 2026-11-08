`timescale 1ns/1ps
// Active-high EGO1 group 0. seg={dp,g,f,e,d,c,b,a}.
module sevenseg_display #(parameter SCAN_CYCLES=6250)(
 input wire clk,reset,visible,input wire [31:0] value,
 output reg [7:0] seg,output reg [3:0] digit);
 reg [31:0] previous;
 reg [13:0] binary;
 reg [15:0] work,bcd,adjusted;
 reg [4:0] remaining;
 integer i;
 always @* begin
 adjusted=work;
 for(i=0;i<4;i=i+1)
 if(work[i*4+:4]>=5) adjusted[i*4+:4]=work[i*4+:4]+4'd3;
 end
 always @(posedge clk) begin
 if(reset) begin previous<=32'hffffffff;binary<=0;work<=0;bcd<=0;remaining<=0;end
 else if(value!=previous) begin previous<=value;binary<=value[13:0];work<=0;remaining<=14;end
 else if(remaining!=0) begin
 work<={adjusted[14:0],binary[13]};binary<={binary[12:0],1'b0};remaining<=remaining-1'b1;
 if(remaining==1) bcd<={adjusted[14:0],binary[13]};end
 end
 reg [15:0] scan_count;
 reg [1:0] position;
 always @(posedge clk) begin
 if(reset) begin scan_count<=0;position<=0;end
 else if(scan_count==SCAN_CYCLES-1) begin scan_count<=0;position<=position+1'b1;end
 else scan_count<=scan_count+1'b1;
 end
 reg [3:0] numeral;
 always @* begin
 numeral=(bcd>>(position*4)) & 4'hf;digit=0;seg=0;
 if(visible && !reset && scan_count!=0) begin
 digit=4'b1000>>position;
 case(numeral)
 0:seg=8'h3f;1:seg=8'h06;2:seg=8'h5b;3:seg=8'h4f;4:seg=8'h66;
 5:seg=8'h6d;6:seg=8'h7d;7:seg=8'h07;8:seg=8'h7f;9:seg=8'h6f;
 default:seg=0;
 endcase end end
endmodule
