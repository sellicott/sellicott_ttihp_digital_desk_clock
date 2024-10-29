`timescale 1ns / 1ns
`default_nettype none

module clock_wrapper_tb (

    // testbench outputs
    o_parallel_data
);
parameter SYS_CLK_HZ = 50_000_000;
parameter SHIFT_CLK_HZ = 1_000_000;
parameter WIDTH = 8;

input  wire i_reset_n;
input  wire i_clk;
input  wire i_start_stb;
output wire o_busy;

input  wire [WIDTH-1:0] i_parallel_data;

output wire o_serial_data;
output wire o_serial_clk;
output wire o_serial_latch;

output wire [WIDTH-1:0] o_parallel_data;

/* verilator lint_off UNUSED */
wire clk_div;
/* verilator lint_on UNUSED */
wire shift_clk_stb;

sysclk_divider #(
	.SYS_CLK_HZ(SYS_CLK_HZ),
	.OUT_CLK_HZ(SHIFT_CLK_HZ)
) shift_reg_div_inst (
    .i_reset_n(i_reset_n),
    .i_sysclk(i_clk),
    .i_en(1),
    .o_div(clk_div),
    .o_clk_overflow(shift_clk_stb)
);

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
    .o_serial_clk(o_serial_clk),
    .o_serial_latch(o_serial_latch)
);

reg [WIDTH-1:0] shift_in_reg = 0;
reg [WIDTH-1:0] parallel_out_reg = 0;

always @(posedge o_serial_clk) begin
	if (!i_reset_n) begin 
		shift_in_reg <= 0;
	end
	else begin
		shift_in_reg <= {shift_in_reg[WIDTH-2:0], o_serial_data};
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

