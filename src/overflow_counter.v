/*
 * overflow_counter.v
 * author: Samuel Ellicott
 * date:  10/13/23 
 * basic WIDTH-bit upcounter use en signal to enable the counting
 */

`timescale 1ns / 1ns
`default_nettype none

module overflow_counter (
    i_sysclk,       // fast system clock (~50MHz)
    i_reset_n,      // syncronous reset (active low)
    i_en,           // enable counting 
    o_count,        // output count
    o_overflow      // output overflow (generates a sysclk length pulse)
);
parameter WIDTH = 8;
parameter OVERFLOW = 60;

input  wire i_sysclk;
input  wire i_reset_n;
input  wire i_en;
output wire [WIDTH-1:0] o_count;
output wire o_overflow;

reg [WIDTH-1:0] counter = 0;
assign o_count = counter;
assign o_overflow = (o_count >= OVERFLOW[WIDTH-1:0]-1) & i_en;

always @(posedge i_sysclk)
begin
	if (!i_reset_n)
        begin
		counter <= 0;
	end
	else if (i_en)
        begin
		if (o_overflow) begin
			counter <= 0;
		end
		else begin
			counter <= counter + 1;
		end
	end
end

endmodule
