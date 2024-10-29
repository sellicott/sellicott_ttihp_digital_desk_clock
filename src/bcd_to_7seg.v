/* bcd_to_7seg: module to convert a bcd coded number into the output for a 7-segment display
 * author: Samuel Ellicott
 * date: 03-04-23
 */

`define default_netname none
module bcd_to_7seg (
    input  wire [3:0] bcd,
    input  wire       en,
    output reg  [6:0] led_out
);

/* 
 *   aaa
 *  f   b
 *  f   b
 *   ggg
 *  e   c
 *  e   c
 *   ddd  
 */

// when not enabled, put the internal bcd wire into an "invalid" state so that all the
// lights are turned off.
wire [3:0] bcd_internal = en ? bcd : 4'hA;

always @*
begin
    case(bcd_internal)
        /*                      abcdefg */
        4'h0    : led_out = 7'b1111110;  // 0
        4'h1    : led_out = 7'b0110000;  // 1
        4'h2    : led_out = 7'b1101101;  // 2
        4'h3    : led_out = 7'b1111001;  // 3
        4'h4    : led_out = 7'b0110011;  // 4
        4'h5    : led_out = 7'b1011011;  // 5
        4'h6    : led_out = 7'b1011111;  // 6
        4'h7    : led_out = 7'b1110000;  // 7
        4'h8    : led_out = 7'b1111111;  // 8
        4'h9    : led_out = 7'b1111011;  // 9
        default : led_out = 7'b0000000;  // default is to output nothing
    endcase
end
    
endmodule
