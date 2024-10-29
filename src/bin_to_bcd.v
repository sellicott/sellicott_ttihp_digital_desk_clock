/*
 * bin_to_bcd.v
 * author: Samuel Ellicott
 * date:  11/02/23 
 * convert a 6-bit binary value to two 4-bit BCD values 
 */

`timescale 1ns / 1ns
`default_nettype none

module bin_to_bcd (
    i_clk,
    i_bin,
    o_bcd_lsb,
    o_bcd_msb
);

/* verilator lint_off UNUSED */
input  wire       i_clk;
/* verilator lint_on  UNUSED */
input  wire [5:0] i_bin;
output wire [3:0] o_bcd_lsb;
output wire [3:0] o_bcd_msb;

// our input is in the range [0, 63] meaning, we have 7 possible outputs for
// the msb
wire msb_0 =                     (i_bin < 6'd10);
wire msb_1 = (i_bin >= 6'd10) && (i_bin < 6'd20);
wire msb_2 = (i_bin >= 6'd20) && (i_bin < 6'd30);
wire msb_3 = (i_bin >= 6'd30) && (i_bin < 6'd40);
wire msb_4 = (i_bin >= 6'd40) && (i_bin < 6'd50);
wire msb_5 = (i_bin >= 6'd50) && (i_bin < 6'd60);
/* verilator lint_off CMPCONST */
wire msb_6 = (i_bin >= 6'd60) && (i_bin <= 6'd63);
/* verilator lint_on CMPCONST */

wire [6:0] msb_one_hot = {msb_6, msb_5, msb_4, msb_3, msb_2, msb_1, msb_0};
reg [3:0] bcd_msb;
/* verilator lint_off UNUSED */
reg [5:0] bcd_lsb;
/* verilator lint_on  UNUSED */


always @(*) begin
   case(msb_one_hot)
       7'h40: bcd_msb   = 4'd6;
       7'h20: bcd_msb   = 4'd5;
       7'h10: bcd_msb   = 4'd4;
       7'h08: bcd_msb   = 4'd3;
       7'h04: bcd_msb   = 4'd2;
       7'h02: bcd_msb   = 4'd1;
       7'h01: bcd_msb   = 4'd0;
       default: bcd_msb = 4'hF;
   endcase
end

always @(*) begin
   case(bcd_msb)
       4'h6: bcd_lsb    = i_bin - 6'd60;
       4'h5: bcd_lsb    = i_bin - 6'd50;
       4'h4: bcd_lsb    = i_bin - 6'd40;
       4'h3: bcd_lsb    = i_bin - 6'd30;
       4'h2: bcd_lsb    = i_bin - 6'd20;
       4'h1: bcd_lsb    = i_bin - 6'd10;
       4'h0: bcd_lsb    = i_bin - 6'd00;
       default: bcd_lsb = 6'h0;
   endcase
end

assign o_bcd_msb = bcd_msb;
assign o_bcd_lsb = bcd_lsb[3:0];
endmodule
