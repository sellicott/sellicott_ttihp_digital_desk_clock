/* digit_shift_register: module to take a 7-segment digit in, in parallel, then shift it out over
 * a serial connection.
 * author: Samuel Ellicott
 * date: 03-19-23
 */

module digit_shift_register (
    input wire en,
    input wire load,
    input wire clk,

    input wire dp_in,
    input wire [6:0] led_in,

    output wire serial_out
);

reg [7:0] shift_reg = 0;

assign serial_out = shift_reg[0] && en;

always @(posedge clk)
begin
    if (en)
    begin
        if (load)
        begin
            shift_reg <= {dp_in, led_in};
        end
        else
        begin
            // shift data in the register 1 -> 0, 2 -> 1, etc 
            for(integer i = 0; i < 7; i = i + 1)
            begin
                shift_reg[i] <= shift_reg[i+1];
            end
            // load a 0 into the MSB of the register
            shift_reg[7] <= 0;
        end
    end
end

endmodule
