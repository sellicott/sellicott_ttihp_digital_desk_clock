/*
 * shift_register.v
 * author: Samuel Ellicott
 * date:  11/03/23 
 * general purpose shift register for outputing data serialy
 */

`timescale 1ns / 1ns
`default_nettype none

module shift_register (
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
    o_serial_clk
);
parameter WIDTH = 8;

input  wire i_reset_n;
input  wire i_clk;
input  wire i_clk_stb;
input  wire i_write_stb;
output wire o_busy;

input wire [WIDTH-1:0] i_parallel_data;

output wire o_serial_data;
output wire o_serial_clk;

localparam IDLE     = 0;
localparam LOAD     = 1;
localparam TRANSFER = 2;
reg [2:0] state;

reg [2*WIDTH:0] transfer_state;

// we need to update our data output on the falling edge of the clock for
// maximum setup/hold time for the external latch. To do this, we will make
// our state register have 2x the number of states as our data (8-bits), then
// we will update our data on the odd pulses, and the data on the even ones.

// Our system clock is probably too fast for the output shift registers, so we
// will have to slow it down a bit by using the "i_clk_stb" signal, which is
// a pulse at a slower clock rate for the serial output.

always @(posedge i_clk) begin
    if (!i_reset_n) begin 
	state <= IDLE;
    end
    // start the transfer sequence if we get a start signal and we aren't busy
    else if ((i_start_stb) && (!o_busy)) begin
	state <= LOAD;
    end
    // immediately go to the transfer state after loading the data
    else if (state == LOAD) begin 
	state <= TRANSFER;
    end
    // if we are currently transfering the last bit go back to the idle state
    else if ((transfer_state >= 2*WIDTH-1) && o_serial_clk && i_clk_stb) begin
	state <= IDLE;
    end
end

always @(posedge i_clk) begin 
    if (!i_reset_n) begin 
	transfer_state <= 0;
    end
    else if (state == IDLE) begin 
	transfer_state <= 0;
    end
    else if(i_clk_stb) begin
	transfer_state <= transfer_state + 1;
    end
end

reg serial_clk;
reg [WIDTH-1:0] serial_data;

always @(posedge i_clk) begin 
    if (!i_reset_n) begin 
	serial_clk <= 0;
	serial_data < = 0;
    end
    else if (state == IDLE) begin
	serial_data <= 0;
	serial_clk <= 0;
    end
    else if (state == LOAD) begin 
	serial_data <= i_parallel_data;
	serial_clk <= 0;
    end
    else if (state == TRANSFER) begin 
	if ((transfer_state & 1) == 1) begin 
	    serial_clk = ~serial_clk;
	end
	else begin 
	    // shift data out MSB first
	    serial_data <= {serial_data[WIDTH-2:0], 1'b0};
	end

    end
end

assign o_busy = state != IDLE;
assign o_serial_data = serial_data[WIDTH-1];
assign o_serial_clk = serial_clk;

endmodule
