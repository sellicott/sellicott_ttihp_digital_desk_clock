`timescale 1ns / 1ns
`default_nettype none

module serial_7seg_out (
    i_write_stb,
    i_clk,
    i_reset_n,

    i_7seg,

    o_serial_data,
    o_serial_latch,
    o_serial_clk
);

input wire i_en;
input wire i_clk;
input wire i_reset_n;

input wire [3:0] i_hours_msb;
input wire [3:0] i_hours_lsb;
input wire [3:0] i_minutes_msb;
input wire [3:0] i_minutes_lsb;
input wire [3:0] i_seconds_msb;
input wire [3:0] i_seconds_lsb;

output wire o_serial_data;
output wire o_serial_latch;
output wire o_serial_clk;
