/*
 * clock_wrapper.v
 * author: Samuel Ellicott
 * date:  11/03/23 
 * Wrap all the important bits of the clock for tiny tapeout
 * This includes the
 * - button debouncing
 * - time register
 * - binary to BCD converter
 * - BCD to 7-segment display
 * - 7-segment serializer
 */
`timescale 1ns / 1ns
`default_nettype none

module clock_wrapper (
	i_reset_n,      // syncronous reset (active low)
	i_clk,          // fast system clock (~50MHz)
	i_refclk,       // 32.768 kHz clock
	i_en,           // enable the clock 
	i_fast_set,     // select the timeset speed (1 for fast, 0 for slow)
	i_use_refclk,   // select between the system clock and an external reference
	i_mode,         // select the mode for the clock to be in

	o_serial_data,
	o_serial_latch,
	o_serial_clk
);
parameter SYS_CLK_HZ   =  5_000_000;
parameter SHIFT_CLK_HZ =  1_000_000;
parameter REF_CLK_HZ   =     32_768;
parameter DEBOUNCE_COUNT  =    2047;
parameter FAST_SET_HZ  = 5;
parameter SLOW_SET_HZ  = 2;
parameter DEBOUNCE_SAMPLES = 4;

input wire       i_reset_n;
input wire       i_clk;
input wire       i_refclk;
input wire       i_en;
input wire       i_fast_set;
input wire       i_use_refclk;
input wire [1:0] i_mode;

output wire o_serial_data;
output wire o_serial_latch;
output wire o_serial_clk;

wire [5:0] clock_seconds;
wire [5:0] clock_minutes;
wire [4:0] clock_hours;

// BCD outputs for the display
wire [3:0] hours_msb;
wire [3:0] hours_lsb;
wire [3:0] minutes_msb;
wire [3:0] minutes_lsb;
wire [3:0] seconds_msb;
wire [3:0] seconds_lsb;

/* verilator lint_off UNUSED */
wire clk_1hz;
wire refclk_stb;
wire debounce_clk;
/* verilator lint_on  UNUSED */

wire clk_1hz_stb;
wire refclk_1hz_stb;
wire debounce_stb;

wire timeset_stb;
wire clk_update_stb;

// debounced inputs
wire fast_set_db;
wire use_refclk_db;
wire [1:0] mode_db;

clock_stb_gen #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.FAST_SET_HZ(FAST_SET_HZ),
	.SLOW_SET_HZ(SLOW_SET_HZ)
) clock_gen_inst (
	.i_clk(i_clk),
	.i_en(i_en),
	.i_reset_n(i_reset_n),
	.i_fast_set(fast_set_db),

	.o_1hz_clk(clk_1hz),
	.o_1hz_stb(clk_1hz_stb),
	.o_timeset_stb(timeset_stb)
);

reference_clk_stb #(
	.REF_CLK_HZ(REF_CLK_HZ)
) refclk_gen_inst (
	.i_reset_n(i_reset_n),
	.i_clk(i_clk),
	.i_en(i_en),
	
	.i_refclk(i_refclk),

	.o_refclk_stb(refclk_stb),
	.o_refclk_1hz_stb(refclk_1hz_stb)
);

/* verilator lint_off UNUSED */
wire [10:0] debounce_div_count;
/* verilator lint_on UNUSED */

overflow_counter #(
	.WIDTH(11),
	.OVERFLOW(DEBOUNCE_COUNT)
) refclk_div_inst (
	.i_sysclk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(refclk_stb),
	.o_count(debounce_div_count),
	.o_overflow(debounce_stb)
);

// debounce the button inputs
// remove debouncing on switch inputs to save area
assign fast_set_db = i_fast_set;
assign use_refclk_db = i_use_refclk;

button_debounce #(
	.NUM_SAMPLES(DEBOUNCE_SAMPLES)
) mode0_db_inst (
	.i_reset_n(i_reset_n),
	.i_clk(i_clk),
	.i_en(i_en),
	.i_sample_stb(debounce_stb),

	.i_button(i_mode[0]),
	.o_button_state(mode_db[0])
);
button_debounce #(
	.NUM_SAMPLES(DEBOUNCE_SAMPLES)
) mode1_db_inst (
	.i_reset_n(i_reset_n),
	.i_clk(i_clk),
	.i_en(i_en),
	.i_sample_stb(debounce_stb),

	.i_button(i_mode[1]),
	.o_button_state(mode_db[1])
);


// select between the two timebases
wire clock_in_1hz_stb     = use_refclk_db ? refclk_1hz_stb : clk_1hz_stb;
wire clock_in_timeset_stb = timeset_stb;

basic_clock clock_inst (
	.i_clk(i_clk),
	.i_reset_n(i_reset_n),
	.i_1hz_stb(clock_in_1hz_stb),
	.i_timeset_stb(clock_in_timeset_stb),
	.o_clk_stb(clk_update_stb),
	.i_mode(mode_db),

	.o_seconds(clock_seconds),
	.o_minutes(clock_minutes),
	.o_hours(clock_hours)
);

clock_to_7seg disp_out (
	.i_clk(i_clk),
	.i_reset_n(i_reset_n),

	.i_seconds(clock_seconds),
	.i_minutes(clock_minutes),
	.i_hours(clock_hours),

    .o_hours_msb(hours_msb),
    .o_hours_lsb(hours_lsb),
    .o_minutes_msb(minutes_msb),
    .o_minutes_lsb(minutes_lsb),
    .o_seconds_msb(seconds_msb),
    .o_seconds_lsb(seconds_lsb)
);

// delay the 1hz strobe by a few clock cycles to generate the shift out strobe
// signal
reg [3:0] shift_out_stb_delay;
always @(posedge i_clk) begin
	if (!i_reset_n) begin
		shift_out_stb_delay <= 0;
	end
	else begin 
		shift_out_stb_delay <= {shift_out_stb_delay[2:0], clk_update_stb};
	end
end

reg colon_blink;
always @(posedge i_clk) begin 
	if (!i_reset_n) begin
		colon_blink <= 0;
	end
	else if (clk_1hz_stb) begin 
		colon_blink <= ~colon_blink;
	end
end


/* verilator lint_off UNUSED */
wire serial_busy;
/* verilator lint_on  UNUSED */

output_wrapper #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.SHIFT_CLK_HZ(SHIFT_CLK_HZ)
) shift_out_inst (
	.i_clk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(i_en),
	.i_start_stb(shift_out_stb_delay[3]),
	.o_busy(serial_busy),

	.i_hours_msb(hours_msb),
	.i_hours_lsb(hours_lsb),
	.i_minutes_msb(minutes_msb),
	.i_minutes_lsb(minutes_lsb),
	.i_seconds_msb(seconds_msb),
	.i_seconds_lsb(seconds_lsb),
	.i_dp_hours1(1'b0),
	.i_dp_hours2(1'b0),
	.i_dp_minutes1(colon_blink),
	.i_dp_minutes2(colon_blink),
	.i_dp_seconds1(1'b0),
	.i_dp_seconds2(1'b0),

	.o_serial_data(o_serial_data),
	.o_serial_latch(o_serial_latch),
	.o_serial_clk(o_serial_clk)
);

endmodule
