`timescale 1ns / 1ns
`default_nettype none

module clock_stb_gen (
	i_clk,          // fast system clock (~50MHz)
	i_en,
	i_reset_n,      // syncronous reset (active low)
	i_fast_set,     // select the speed for the timeset signal

	o_1hz_clk,
	o_1hz_stb,      // 1hz clock strobe signal 
	o_timeset_stb   // timeset strobe signal (faster than 1hz)
);
parameter SYS_CLK_HZ = 50_000_000;
parameter FAST_SET_HZ = 5;
parameter SLOW_SET_HZ = 2;

input  wire i_clk;
input  wire i_reset_n;
input  wire i_en;
input  wire i_fast_set;

output wire o_1hz_clk;
output wire o_1hz_stb;
output wire o_timeset_stb;

// handle time inputs to generate our 1hz clock for the clock and our time set
// pulses for adjusting the time
sysclk_divider #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.OUT_CLK_HZ(1) 
) sysclk_div_inst (
    .i_sysclk(i_clk),
    .i_reset_n(i_reset_n),
    .i_en(i_en),
    .o_div(o_1hz_clk),
    .o_clk_overflow(o_1hz_stb)
);

timeset_divider #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.FAST_SET_HZ(FAST_SET_HZ),
	.SLOW_SET_HZ(SLOW_SET_HZ)
) timeset_div_inst (
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_en(i_en),
    .i_fast_set(i_fast_set),
    .o_timeset_stb(o_timeset_stb)
);

endmodule
