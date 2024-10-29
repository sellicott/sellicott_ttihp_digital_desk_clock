/* 
 * sellicott_digital_clock.v
 * Top level module for the digital clock deisgn
 * Wraps the actual design for use with the TinyTapeout4 template
 */
`default_nettype none

module tt_um_digital_clock_sellicott (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock ~ 10MHz
    input  wire       rst_n     // reset_n - low to reset
);
  parameter SYS_CLK_HZ = 5_000_000;
  parameter SHIFT_CLK_HZ = 1_000_000;
  parameter REF_CLK_HZ = 32768;
  parameter DEBOUNCE_COUNT = 2047;
  parameter FAST_SET_HZ = 5;
  parameter SLOW_SET_HZ = 2;
  parameter DEBOUNCE_SAMPLES = 5;

  wire       refclk = ui_in[0];
  wire       use_refclk = ui_in[1];

  wire       fast_set = ui_in[2];
  wire       hours_set = ui_in[3];
  wire       minutes_set = ui_in[4];
  wire [1:0] mode = {hours_set, minutes_set};

  wire       serial_data;
  wire       serial_latch;
  wire       serial_clk;

  assign uo_out[0] = serial_data;
  assign uo_out[1] = serial_latch;
  assign uo_out[2] = serial_clk;

  // deal with the pins we aren't using currently
  assign uo_out[7:3] = 5'h0;
  assign uio_oe[7:0] = 8'h0;
  assign uio_out[7:0] = 8'h0;

  clock_wrapper #(
      .SYS_CLK_HZ(SYS_CLK_HZ),
      .REF_CLK_HZ(REF_CLK_HZ),
      .SHIFT_CLK_HZ(SHIFT_CLK_HZ),
      .DEBOUNCE_COUNT(DEBOUNCE_COUNT),
      .FAST_SET_HZ(FAST_SET_HZ),
      .SLOW_SET_HZ(SLOW_SET_HZ),
      .DEBOUNCE_SAMPLES(DEBOUNCE_SAMPLES)
  ) clock_inst (
      .i_clk(clk),
      .i_refclk(refclk),
      .i_reset_n(rst_n),
      .i_en(ena),
      .i_use_refclk(use_refclk),
      .i_fast_set(fast_set),
      .i_mode(mode),

      .o_serial_data (serial_data),
      .o_serial_latch(serial_latch),
      .o_serial_clk  (serial_clk)
  );
endmodule
