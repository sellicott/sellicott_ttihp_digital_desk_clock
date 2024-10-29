/*
 * basic_clock.v
 * author: Samuel Ellicott
 * date:  11/02/23 
 * A simple clock that implements the basic features we want, like the ability
 * to set the time. Provides a working base for us to build up features
 *
 * There are 4 modes for the clock
 * 0: COUNTING      - Normal mode, update the clock every second
 * 1: SET_MINUTES   - Set the minutes based on the overflow of the timeset
 *                    clock (FAST_SET_HZ, or SLOW_SET_HZ)
 * 2: SET_HOURS     - Set the minutes based on the overflow of the timeset 
 *                    clock (FAST_SET_HZ, or SLOW_SET_HZ)
 * 3: CLEAR_SECONDS - Clear the seconds register
 */

`timescale 1ns / 1ns
`default_nettype none

module basic_clock (
	i_clk,          // fast system clock (~50MHz)
	i_reset_n,      // syncronous reset (active low)

	i_1hz_stb,      // 1hz clock strobe signal 
	i_timeset_stb,  // timeset strobe signal (faster than 1hz)
	o_clk_stb,
	i_mode,         // select the mode for the clock to be in

	o_seconds,
	o_minutes,
	o_hours
);

input  wire       i_clk;
input  wire       i_reset_n;
input  wire       i_1hz_stb;
input  wire       i_timeset_stb;
output wire       o_clk_stb;
input  wire [1:0] i_mode;

output wire [5:0] o_seconds;
output wire [5:0] o_minutes;
output wire [4:0] o_hours;

// We need to set the clock stb input based on whether we are in the timeset
// mode or in the free running mode
wire [1:0] timeset_mode = i_mode;
wire is_timeset_mode = |timeset_mode;
wire time_reg_stb = is_timeset_mode ? i_timeset_stb : i_1hz_stb;
assign o_clk_stb = time_reg_stb;

time_register time_reg_inst (
	.i_clk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(time_reg_stb),
	.i_mode(timeset_mode),
	.o_seconds(o_seconds),
	.o_minutes(o_minutes),
	.o_hours(o_hours)
);

endmodule
