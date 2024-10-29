`timescale 1ns / 1ns
`default_nettype none

module reference_clk_stb (
	i_reset_n,
	i_clk,
	i_en,
	
	i_refclk,

	o_refclk_stb,
	o_refclk_1hz_stb
);
parameter REF_CLK_HZ  = 32_768;

input  wire i_reset_n;
input  wire i_clk;
input  wire i_en;
input  wire i_refclk;
output wire o_refclk_stb;
output wire o_refclk_1hz_stb;

// we need to start by doing a clock domain crossing for the refclk signal
reg refclk_pipe0;
reg refclk_pipe1;
reg refclk_ext;

always @(posedge i_clk) begin 
	if (!i_reset_n) begin 
		refclk_pipe0 <= 0;
		refclk_pipe1 <= 0;
		refclk_ext   <= 0;
	end
	else if (i_en) begin 
		{refclk_pipe1, refclk_pipe0, refclk_ext} <= {refclk_pipe0, refclk_ext, i_refclk};
	end
end

// generate a strobe signal on the rising edge of refclk
assign o_refclk_stb = (refclk_pipe1) && (!refclk_pipe0);

/* verilator lint_off UNUSED */
wire div;
wire [15:0] div_count;
/* verilator lint_on UNUSED */

overflow_counter #(
	.WIDTH(16),
	.OVERFLOW(REF_CLK_HZ)
) refclk_div_inst (
	.i_sysclk(i_clk),
	.i_reset_n(i_reset_n),
	.i_en(o_refclk_stb),
	.o_count(div_count),
	.o_overflow(o_refclk_1hz_stb)
);


endmodule
