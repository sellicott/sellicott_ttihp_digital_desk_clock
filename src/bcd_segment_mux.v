/* bcd_segment_mux: module to select the outputs from a time_register to a 7-segment output to a 
 * shift register. 
 * author: Samuel Ellicott
 * date: 03-19-23
 */
`timescale 1ns / 1ns
`default_nettype none

module bcd_segment_mux (
    i_reset_n,
    i_clk,
    i_en,

    i_hours_msb,
    i_hours_lsb,
    i_minutes_msb,
    i_minutes_lsb,
    i_seconds_msb,
    i_seconds_lsb,
    i_segment_select,
    o_led_out
);

input wire i_reset_n;
input wire i_clk;
input wire i_en;
input wire [3:0] i_hours_msb;
input wire [3:0] i_hours_lsb;
input wire [3:0] i_minutes_msb;
input wire [3:0] i_minutes_lsb;
input wire [3:0] i_seconds_msb;
input wire [3:0] i_seconds_lsb;
input wire [2:0] i_segment_select;

output wire [6:0] o_led_out;

reg [3:0] bcd_int;

bcd_to_7seg inst (
    .en(i_en),
    .bcd(bcd_int),
    .led_out(o_led_out)
);

// select between the various time_register segments starting from the least-significant-digit of
// the seconds and working up to the hours most-significant-digit.
always @(posedge i_clk) begin
    if (!i_reset_n) begin
    	bcd_int <= 0;
    end
    else begin
	case(i_segment_select)
	3'h0: bcd_int <= i_seconds_lsb;
	3'h1: bcd_int <= i_seconds_msb;
	3'h2: bcd_int <= i_minutes_lsb;
	3'h3: bcd_int <= i_minutes_msb;
	3'h4: bcd_int <= i_hours_lsb;
	3'h5: bcd_int <= i_hours_msb;
	// if we aren't one of the predefined outputs, put converter into an "invalid" state so we turn
	// the outputs off. 
	default: bcd_int <= 4'hA;
	endcase
    end
end

endmodule
