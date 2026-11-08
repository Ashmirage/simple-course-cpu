`timescale 1ns / 1ps






















`include "cpu_defs.vh"

module data_mem (
    input  wire        clk,
    input  wire        reset,

    input  wire        en,
    input  wire [3:0]  wstrb,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,

    output reg  [31:0] rdata,
    output wire        error,

    output reg  [15:0] led_out,
    output reg  [31:0] display_out,
    output reg  [31:0] status_out
);

    
    reg [31:0] ram [0:255];

    
    wire is_ram =
        (addr >= `DMEM_BASE) &&
        (addr <= `DMEM_LAST);

    wire is_led = (addr == `MMIO_LED);
    wire is_display = (addr == `MMIO_DISPLAY);
    wire is_status = (addr == `MMIO_STATUS);

    wire is_mapped =
        is_ram || is_led || is_display || is_status;

    
    wire valid_wstrb =
        (wstrb == 4'b0000) ||
        (wstrb == 4'b1111);

    
    wire aligned = (addr[1:0] == 2'b00);

    
    assign error =
        en && (!is_mapped || !aligned || !valid_wstrb);

    
    wire [31:0] ram_offset = addr - `DMEM_BASE;
    wire [7:0] ram_index = ram_offset[9:2];

    
    always @(*) begin
        rdata = 32'd0;

        if (en && !error && wstrb == 4'b0000) begin
            if (is_ram)
                rdata = ram[ram_index];
            else if (is_led)
                rdata = {16'd0, led_out};
            else if (is_display)
                rdata = display_out;
            else if (is_status)
                rdata = status_out;
        end
    end

    
    always @(posedge clk) begin
        if (reset) begin
            led_out <= 16'd0;
            display_out <= 32'd0;
            status_out <= 32'd0;
        end
        else if (en && wstrb == 4'b1111 && !error) begin
            if (is_ram)
                ram[ram_index] <= wdata;
            else if (is_led)
                led_out <= wdata[15:0];
            else if (is_display)
                display_out <= wdata;
            else if (is_status)
                status_out <= wdata;
        end
    end

endmodule

