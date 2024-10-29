`timescale 1ns / 1ns
`default_nettype none

module button_debounce (
	i_reset_n,
	i_clk,
	i_en,
	i_sample_stb,

	i_button,
	o_button_state
);
parameter NUM_SAMPLES = 5;

input  wire i_reset_n;
input  wire i_clk;
input  wire i_en;
input  wire i_sample_stb;
input  wire i_button;
output wire o_button_state;

// we need to start by doing a clock domain crossing for the refclk signal
reg sample_pipe;
reg sample_ext;

always @(posedge i_clk) begin 
	if (!i_reset_n) begin 
		sample_pipe <= 0;
		sample_ext  <= 0;
	end
	else if (i_en) begin 
		{sample_pipe, sample_ext} <= {sample_ext, i_button};
	end
end


// shift register for storing the samples
reg [NUM_SAMPLES-1:0] samples;
always @(posedge i_clk) begin 
	if (!i_reset_n) begin
		samples <= 0;
	end
	else if (i_en && i_sample_stb) begin 
		samples <= {samples[NUM_SAMPLES-2:0], sample_pipe};
	end
end

// our state is steady when all the samples in our buffer are the same
assign o_button_state = &samples;

endmodule
