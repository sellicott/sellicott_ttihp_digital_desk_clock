/*
 * upcounter.v
 * author: Samuel Ellicott
 * date:  10/13/23 
 * basic WIDTH-bit upcounter use en signal to enable the counting
 */

`timescale 1ns / 1ns
`default_nettype none

module upcounter (
    i_sysclk,       // fast system clock (~50MHz)
    i_reset_n,      // syncronous reset (active low)
    i_en,           // enable counting 
    o_count
);
parameter WIDTH = 8;

input  wire i_sysclk;
input  wire i_reset_n;
input  wire i_en;
output wire [WIDTH-1:0] o_count;

reg [WIDTH-1:0] counter = 0;

assign o_count = counter;

always @(posedge i_sysclk)
begin
	if (!i_reset_n)
        begin
		counter <= 0;
	end
	else if (i_en)
        begin
		counter <= counter + 1;
	end
end

endmodule
