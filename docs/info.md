<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

Simple digital clock, displays hours, minutes, and seconds in either a 24h format.
Since there are not enough output pins to directly drive a 6x
7-segment displays, the data is shifted out serially using an internal 8-bit shift register.
The shift register drives 6-external 74xx596 shift registers to the displays. Clock and control
signals (`serial_clk`, `serial_latch`) are also used to shift and latch the data into the external 
shift registers respectively. The time can be set using the `hours_set` and `minutes_set` inputs.
If `set_fast` is high, then the the hours or minutes will be incremented at a rate of 5Hz, 
otherwise it will be set at a rate of 2Hz. Note that when setting either the minutes, rolling-over
will not affect the hours setting. If both `hours_set` and `minutes_set` are presssed at the same time
the seconds will be cleared to zero.

## How to test

Connect serial output to a 6x 8-bit shift registers to display the output on 6x 7-segment displays (using custom PCB)
Apply a 5MHz clock to the clock pin and 32.786Khz signal to the refclk pin. Use the `hours_set` and `minutes_set`
pins to set the time.

## External hardware

A custom PCB is attached to the Pmod interfaces. See: [](https://github.com/sellicott/sellicott_tt5_digital_clock/blob/main/pcb/docs/tt5_led_clock.pdf)
