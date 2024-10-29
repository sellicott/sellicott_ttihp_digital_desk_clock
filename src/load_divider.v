/*
 * load_divider.v
 * author: Samuel Ellicott
 * date:  10/25/23 
 * Fractional divider with loadable incriment value.
 * The incriment used will always be 1 greater than the loaded value
 * this prevents a case where we never overflow.
 * The incriment value is loaded when i_load is high
 *
 * To set the frequency of the output overflow use the formula
 * incriment = (1<<30)/((SYS_CLK_HZ/OUT_CLK_HZ)/4) -1 
 */

`timescale 1ns / 1ns
`default_nettype none

module load_divider (
    i_clk,       // fast system clock (~50MHz)
    i_reset_n,      // syncronous reset
    i_en,           // enable output
    i_load,         // load new value for incriment
    i_incriment,    // incriment = i_incriment + 1
    o_div,          // divided output signal 
    o_clk_overflow  // 1 sysclk period pulse on counter overflow
);

input  wire        i_clk;
input  wire        i_reset_n;
input  wire        i_en;
input  wire        i_load;
input  wire [24:0] i_incriment;
output wire        o_div;
output wire        o_clk_overflow;

reg [24:0] counter   = 0;
reg [24:0] incriment = 1;

assign o_div = counter[24];

always @(posedge i_clk)
begin
    if (!i_reset_n)
    begin
	counter <= 0;
    end
    else if (i_en)
    begin
	counter <= counter + incriment;
    end
end

always @(posedge i_clk) begin 
    if (!i_reset_n) begin 
	incriment <= 1;
    end
    else if (i_load) begin 
	incriment <= i_incriment + 1;
    end
end

reg prev_out = 0;
always @(posedge i_clk)
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
