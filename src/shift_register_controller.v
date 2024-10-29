/* shift_register_controller: module to generate clock and control signals for the shift register to
 * output digit segments over a serial connection and load them into a set of external shift registers.
 * author: Samuel Ellicott
 * date: 03-19-23
 */

module shift_register_controller (
    input wire en,
    input wire clk,

    output wire [2:0] bcd_select,
    output wire sr_load,

    output wire ext_latch,
    output wire ext_clk
);

reg digit_clk = 0;

reg [2:0] digit_count = 0;
reg [3:0] sr_count = 0;

assign bcd_select = digit_count;

// load data on the first clock
assign sr_load = sr_count == 4'h0;

// latch the external outputs when we are done with all digits 
// and we are loading data into the local register.
assign ext_latch = (digit_count == 3'h0) && sr_load;

// only output the external clock when we aren't loading data internally
assign ext_clk = clk & ~sr_load;

// count the number of clocks for loading and shifting on the shift register
always @(negedge clk) begin
    if (en)
    begin
        if (sr_count == 4'h8)
        begin
            sr_count <= 4'h0;
            digit_clk <= 1'h1;
        end
        else
        begin
            digit_clk <= 1'h0;
            sr_count <= sr_count + 1'h1;
        end
    end
end

// count the number of digits we have outputted
always @(negedge digit_clk) begin
    if (digit_count == 3'h5)
        digit_count <= 3'h0;
    else
        digit_count <= digit_count + 3'h1;
end

endmodule
