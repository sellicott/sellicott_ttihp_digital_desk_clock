`timescale 1ns / 1ns
`default_nettype none

module clock_wrapper_tb (
	i_reset_n,      // syncronous reset (active low)
	i_clk,          // fast system clock (~50MHz)
	i_refclk,       // 32.768 kHz clock
	i_en,           // enable the clock 
	i_fast_set,     // select the timeset speed (1 for fast, 0 for slow)
	i_use_refclk,   // select between the system clock and an external reference
	i_mode,         // select the mode for the clock to be in
	
	o_serial_data,
	o_serial_latch,
	o_serial_clk,

	// testbench outputs
	o_parallel_data
);
parameter SYS_CLK_HZ   =  5_000_000;
parameter SHIFT_CLK_HZ =  1_000_000;
parameter REF_CLK_HZ   =      32768;
parameter DEBOUNCE_COUNT =     2500;
parameter FAST_SET_HZ  = 5;
parameter SLOW_SET_HZ  = 2;
parameter SHIFT_WIDTH  = 6*8;
parameter DEBOUNCE_SAMPLES = 5;

input wire       i_reset_n;
input wire       i_clk;
input wire       i_refclk;
input wire       i_en;
input wire       i_fast_set;
input wire       i_use_refclk;
input wire [1:0] i_mode;

output wire o_serial_data;
output wire o_serial_clk;
output wire o_serial_latch;

output wire [SHIFT_WIDTH-1:0] o_parallel_data;

clock_wrapper #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.REF_CLK_HZ(REF_CLK_HZ),
	.SHIFT_CLK_HZ(SHIFT_CLK_HZ),
	.DEBOUNCE_COUNT(DEBOUNCE_COUNT),
	.FAST_SET_HZ(FAST_SET_HZ),
	.SLOW_SET_HZ(SLOW_SET_HZ),
	.DEBOUNCE_SAMPLES(DEBOUNCE_SAMPLES)
) clock_inst (
	.i_clk(i_clk),          // fast system clock (~50MHz)
	.i_refclk(i_refclk),
	.i_reset_n(i_reset_n),      // syncronous reset (active low)
	.i_en(i_en),           // enable the clock 
	.i_use_refclk(i_use_refclk),
	.i_fast_set(i_fast_set),     // select the timeset speed (1 for fast, 0 for slow)
	.i_mode(i_mode),         // select the mode for the clock to be in

	.o_serial_data(o_serial_data),
	.o_serial_latch(o_serial_latch),
	.o_serial_clk(o_serial_clk)
);

reg [SHIFT_WIDTH-1:0] shift_in_reg = 0;
reg [SHIFT_WIDTH-1:0] parallel_out_reg = 0;

always @(posedge o_serial_clk) begin
	if (!i_reset_n) begin 
		shift_in_reg <= 0;
	end
	else begin
		shift_in_reg <= {shift_in_reg[SHIFT_WIDTH-2:0], o_serial_data};
	end
end

always @(posedge o_serial_latch) begin 
	if (!i_reset_n) begin 
		parallel_out_reg <= 0;
	end
	else begin
		parallel_out_reg <= shift_in_reg;
	end
end

assign o_parallel_data = parallel_out_reg;

endmodule

