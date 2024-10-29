`timescale 1ns / 1ns
`default_nettype none

module latch_shift_register (
    // control interface
    i_reset_n,   // syncronous reset
    i_clk,       // system clock
    i_clk_stb,   // slowed down "serial clock" pulse used to incriment state
    i_start_stb, // start transfer pulse
    o_busy,      // output to signal that we are processing a request

    // input data
    i_parallel_data,
    
    // output shift register
    o_serial_data,
    o_serial_latch,
    o_serial_clk
);
parameter WIDTH = 8;

input  wire i_reset_n;
input  wire i_clk;
input  wire i_clk_stb;
input  wire i_start_stb;
output wire o_busy;

input wire [WIDTH-1:0] i_parallel_data;

output wire o_serial_data;
output wire o_serial_clk;

shift_register #(
	.WIDTH(WIDTH)
) shift_out_inst (
    // control interface
    .i_reset_n(i_reset_n),
    .i_clk(i_clk),
    .i_clk_stb(shift_clk_stb),
    .i_start_stb(i_start_stb),
    .o_busy(o_busy),

    // input data
    .i_parallel_data(i_parallel_data),
    
    // output shift register
    .o_serial_data(o_serial_data),
    .o_serial_clk(o_serial_clk)
);

endmodule
