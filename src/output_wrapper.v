/* output_wrapper: module to take a time register input and generate serialized output data
 * enable signal will blank the led outputs (shift register will always shift out 0's)
 * author: Samuel Ellicott
 * date: 03-20-23
 */
`timescale 1ns / 1ns
`default_nettype none

module output_wrapper (
    i_reset_n,
    i_clk,
    i_en,
    i_start_stb,
    o_busy,

    i_hours_msb,
    i_hours_lsb,
    i_minutes_msb,
    i_minutes_lsb,
    i_seconds_msb,
    i_seconds_lsb,
    i_dp_hours1,
    i_dp_hours2,
    i_dp_minutes1,
    i_dp_minutes2,
    i_dp_seconds1,
    i_dp_seconds2,

    o_serial_data,
    o_serial_latch,
    o_serial_clk
);
parameter  SYS_CLK_HZ   = 50_000_000;
parameter  SHIFT_CLK_HZ = 1_000_000;
localparam SHIFT_WIDTH  = 6*8;

input  wire i_en;
input  wire i_clk;
input  wire i_reset_n;
input  wire i_start_stb;
output wire o_busy;

input wire [3:0] i_hours_msb;
input wire [3:0] i_hours_lsb;
input wire [3:0] i_minutes_msb;
input wire [3:0] i_minutes_lsb;
input wire [3:0] i_seconds_msb;
input wire [3:0] i_seconds_lsb;
input wire       i_dp_hours1;
input wire       i_dp_hours2;
input wire       i_dp_minutes1;
input wire       i_dp_minutes2;
input wire       i_dp_seconds1;
input wire       i_dp_seconds2;

output wire o_serial_data;
output wire o_serial_latch;
output wire o_serial_clk;

// generate the 7-segment outputs for the hours, minutes and seconds
wire [6:0] hours_msb_7seg;
wire [6:0] hours_lsb_7seg;
wire [6:0] minutes_msb_7seg;
wire [6:0] minutes_lsb_7seg;
wire [6:0] seconds_msb_7seg;
wire [6:0] seconds_lsb_7seg;

bcd_to_7seg hours_msb_conv_inst (
    .bcd(i_hours_msb),
    .en(i_en),
    .led_out(hours_msb_7seg)
);
bcd_to_7seg hours_lsb_conv_inst (
    .bcd(i_hours_lsb),
    .en(i_en),
    .led_out(hours_lsb_7seg)
);
bcd_to_7seg minutes_msb_conv_inst (
    .bcd(i_minutes_msb),
    .en(i_en),
    .led_out(minutes_msb_7seg)
);
bcd_to_7seg minutes_lsb_conv_inst (
    .bcd(i_minutes_lsb),
    .en(i_en),
    .led_out(minutes_lsb_7seg)
);
bcd_to_7seg seconds_msb_conv_inst (
    .bcd(i_seconds_msb),
    .en(i_en),
    .led_out(seconds_msb_7seg)
);
bcd_to_7seg seconds_lsb_conv_inst (
    .bcd(i_seconds_lsb),
    .en(i_en),
    .led_out(seconds_lsb_7seg)
);

// we need a wire to hold the input data and convert it from the 7-segment
// display format.
wire [SHIFT_WIDTH-1:0] parallel_data = {
    i_dp_hours1,   hours_msb_7seg,   i_dp_hours2,   hours_lsb_7seg,
    i_dp_minutes1, minutes_msb_7seg, i_dp_minutes2, minutes_lsb_7seg,
    i_dp_seconds1, seconds_msb_7seg, i_dp_seconds2, seconds_lsb_7seg
};

// generate a slower clock for outputting the serial data
/* verilator lint_off UNUSED */
wire clk_div;
/* verilator lint_on UNUSED */
wire shift_clk_stb;

sysclk_divider #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.OUT_CLK_HZ(SHIFT_CLK_HZ)
) shift_reg_div_inst (
    .i_reset_n(i_reset_n),
    .i_sysclk(i_clk),
    .i_en(1'b1),
    .o_div(clk_div),
    .o_clk_overflow(shift_clk_stb)
);

shift_register #(
	.WIDTH(SHIFT_WIDTH)
) shift_out_inst (
    // control interface
    .i_reset_n(i_reset_n),
    .i_clk(i_clk),
    .i_clk_stb(shift_clk_stb),
    .i_start_stb(i_start_stb),
    .o_busy(o_busy),

    // input data
    .i_parallel_data(parallel_data),
    
    // output shift register
    .o_serial_data(o_serial_data),
    .o_serial_clk(o_serial_clk),
    .o_serial_latch(o_serial_latch)
);

endmodule
