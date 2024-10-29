/*
 * time_register.v
 * author: Samuel Ellicott
 * date:  10/25/23 
 * Register to hold time values, based on the basic_clock.v
 * code
 * We now add the ability to set the time of hours and minutes
 * along with clearing the seconds there are 4 modes
 * 0: COUNTING      - Overflows will incriment the subsequent registers, i_en
 *                    connected to the seconds register
 * 1: SET_MINUTES   - Overflows disconnected, i_en connected to minutes register
 * 2: SET_HOURS     - Overflows disconnected, i_en connected to hours register
 * 3: CLEAR_SECONDS - Overflows disconnected, clear the seconds register
 */

`timescale 1ns / 1ns
`default_nettype none

module time_register(
	i_clk,       // fast system clock (~50MHz)
	i_reset_n,   // syncronous reset (active low)
	i_en,        // enable counting 
	i_mode,      // Mode inputs

	o_seconds,
	o_minutes,
	o_hours
);
input  wire       i_clk;
input  wire       i_reset_n;
input  wire       i_en;
input  wire [1:0] i_mode;

output wire [5:0] o_seconds;
output wire [5:0] o_minutes;
output wire [4:0] o_hours;

reg seconds_count = 0;
reg hours_count   = 0;
reg minutes_count = 0;
reg seconds_reset = 0;

wire seconds_overflow;
wire minutes_overflow;
/* verilator lint_off UNUSED */
wire hours_overflow;
/* verilator lint_on UNUSED */

// make a small state machine for our modes
localparam COUNTING      = 2'd0;
localparam SET_MINUTES   = 2'd1;
localparam SET_HOURS     = 2'd2;
localparam CLEAR_SECONDS = 2'd3;

always @(posedge i_clk) begin
	case (i_mode)
		COUNTING: begin
			seconds_count <= i_en;
			minutes_count <= seconds_overflow;
			hours_count   <= minutes_overflow;
			seconds_reset <= 0;
		end
		SET_MINUTES: begin
			seconds_count <= 0;
			minutes_count <= i_en;
			hours_count   <= 0;
			seconds_reset <= 0;
		end
		SET_HOURS: begin 
			seconds_count <= 0;
			minutes_count <= 0;
			hours_count   <= i_en;
			seconds_reset <= 0;
		end
		CLEAR_SECONDS: begin 
			seconds_count <= 0;
			minutes_count <= 0;
			hours_count   <= 0;
			seconds_reset <= 1;
		end
	endcase
end

// reset the seconds register either when we get the global
// reset signal, or when we are in the SECONDS_RESET mode and there is a tick
wire seconds_reset_n = i_reset_n & !(seconds_reset & i_en);

overflow_counter #(
	.WIDTH(6),
	.OVERFLOW(60)
) seconds_count_inst (
	.i_sysclk(i_clk),
	.i_reset_n(seconds_reset_n),
	.i_en(seconds_count),
	.o_count(o_seconds),
	.o_overflow(seconds_overflow)
);

overflow_counter #(
	.WIDTH(6),
	.OVERFLOW(60)
) minutes_count_inst (
	.i_sysclk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(minutes_count),
	.o_count(o_minutes),
	.o_overflow(minutes_overflow)
);

overflow_counter #(
	.WIDTH(5),
	.OVERFLOW(24)
) hours_count_inst (
	.i_sysclk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(hours_count),
	.o_count(o_hours),
	.o_overflow(hours_overflow)
);
endmodule
