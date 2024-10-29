/*
 * timeset_divider.v
 * author: Samuel Ellicott
 * date:  10/25/23 
 * Fractional divider with loadable incriment value.
 * generates a strobe output at either FAST_SET_HZ or SLOW_SET_HZ depending on
 * the value of i_fast_set. (1 for fast, 0 for slow).
 * incriment = (1<<30)/((SYS_CLK_HZ/OUT_CLK_HZ)/4) -1 
 */

`timescale 1ns / 1ns
`default_nettype none

module timeset_divider (
    i_clk,       // fast system clock (~50MHz)
    i_reset_n,      // syncronous reset
    i_en,           // enable output
    i_fast_set,     // select strobe speed (1 for fast, 0 for slow)
    o_timeset_stb   // 1 sysclk period pulse on counter overflow
);
parameter SYS_CLK_HZ  = 50_000_000;
parameter FAST_SET_HZ = 5;
parameter SLOW_SET_HZ = 2;

localparam FAST_INC   = (1<<23)/((SYS_CLK_HZ/FAST_SET_HZ)/4) - 1;
localparam SLOW_INC   = (1<<23)/((SYS_CLK_HZ/SLOW_SET_HZ)/4) - 1;

input  wire i_clk;
input  wire i_reset_n;
input  wire i_en;
input  wire i_fast_set;
output wire o_timeset_stb;

wire [24:0] incriment = i_fast_set ? FAST_INC[24:0] : SLOW_INC[24:0];

/* verilator lint_off UNUSED */
wire div;
/* verilator lint_on UNUSED */

load_divider divider_inst (
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_en(i_en),
    .i_load(1'b1),
    .i_incriment(incriment),
    .o_div(div),
    .o_clk_overflow(o_timeset_stb)
);


endmodule
