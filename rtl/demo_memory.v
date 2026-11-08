`timescale 1ns/1ps
// Existing RAM/MMIO plus input events, timer and two decimal display registers.
module demo_memory #(parameter TICK_CYCLES=50000000)(
 input wire clk,reset,en,input wire [3:0] wstrb,
 input wire [31:0] addr,wdata,input wire [7:0] switches,
 input wire [4:0] key_pulse,
 output reg [31:0] rdata,output wire error,
 output wire [15:0] led_out,output wire [31:0] status_out,
 output wire [31:0] display_left,
 output reg [31:0] display_right,output reg mode);
 wire extra=(addr>=32'h1fff0010 && addr<=32'h1fff0028);
 wire aligned=addr[1:0]==0;
 wire write_ok=(wstrb==0 || wstrb==15);
 wire readonly=addr<=32'h1fff001c;
 wire extra_error=extra && (!aligned || !write_ok || addr==32'h1fff0014 || addr==32'h1fff0024 || (readonly && wstrb!=0));
 wire [31:0] base_data;wire base_error;
 data_mem base(.clk(clk),.reset(reset),.en(en && !extra),.wstrb(wstrb),
 .addr(addr),.wdata(wdata),.rdata(base_data),.error(base_error),
 .led_out(led_out),.display_out(display_left),.status_out(status_out));
 assign error=extra ? (en && extra_error) : base_error;
 reg [4:0] pending;
 reg [25:0] timer_count;reg [31:0] ticks;
 wire consume=en && extra && !error && wstrb==0 && addr==32'h1fff0018;
 always @(posedge clk) begin
 if(reset) begin pending<=0;timer_count<=0;ticks<=0;display_right<=0;mode<=0;end
 else begin
 // New edge wins over simultaneous read-to-clear.
 pending<=(consume ? 5'b0 : pending) | key_pulse;
 if(timer_count==TICK_CYCLES-1) begin timer_count<=0;ticks<=ticks+1'b1;end
 else timer_count<=timer_count+1'b1;
 if(en && extra && !error && wstrb==15) begin
 if(addr==32'h1fff0020) display_right<=wdata;
 if(addr==32'h1fff0028) mode<=wdata[0];
 end end end
 always @* begin
 rdata=base_data;
 if(extra) begin rdata=0;
 if(en && !error && wstrb==0) case(addr)
 32'h1fff0010:rdata={24'b0,switches};
 32'h1fff0018:rdata={27'b0,pending};
 32'h1fff001c:rdata=ticks;
 32'h1fff0020:rdata=display_right;
 32'h1fff0028:rdata={31'b0,mode};
 default:rdata=0;
 endcase end end
endmodule
