/*
 * sysclk_divider.v
 * author: Samuel Ellicott
 * date:  10/13/23 
 * use a fractional divider to get an aproximate 1Hz clock output
 * from a SYS_CLK_HZ input clock (default is 50MHz)
 */

`timescale 1ns / 1ns
`default_nettype none

module sysclk_divider (
    i_sysclk,       // fast system clock (~50MHz)
    i_reset_n,      // syncronous reset
    i_en,           // enable output
    o_div,          // divided output signal 
    o_clk_overflow  // 1 sysclk period pulse on counter overflow
);
parameter        SYS_CLK_HZ = 50_000_000;
parameter        OUT_CLK_HZ = 1; 
parameter [31:0] INCRIMENT  = (1<<30)/((SYS_CLK_HZ/OUT_CLK_HZ)/4);

input  wire i_sysclk;
input  wire i_reset_n;
input  wire i_en;
output wire o_div;
output wire o_clk_overflow;

reg [31:0] counter = 0;

assign o_div = counter[31];

always @(posedge i_sysclk)
begin
	if (!i_reset_n)
        begin
		counter <= 0;
	end
	else if (i_en)
        begin
		counter <= counter + INCRIMENT;
	end
end

reg prev_out = 0;
always @(posedge i_sysclk)
begin
    if (!i_reset_n)
    begin
        prev_out <= 0;
    end
    else if (i_en)
    begin
        prev_out <= o_div;
    end
end

assign o_clk_overflow = o_div & !prev_out;

endmodule
