
/* clock_register_tb.v
 * Copyright (c) 2024 Samuel Ellicott
 * SPDX-License-Identifier: Apache-2.0
 *
 * Testbench for clock register, this tests the functionality of holding and
 * setting the time of the clock.
 */

`default_nettype none
`timescale 1ns / 1ns

module clock_register_tb ();

  // setup file dumping things
  localparam STARTUP_DELAY = 5;
  initial begin
    $dumpfile("clock_register_tb.fst");
    $dumpvars(0, clock_register_tb);
    #STARTUP_DELAY;

    $display("Test Clock Register");
    init();

    run_test();

    // exit the simulator
    close();
  end

  // setup global signals
  localparam CLK_PERIOD = 50;
  localparam CLK_HALF_PERIOD = CLK_PERIOD/2;

  reg clk   = 0;
  reg rst_n = 0;
  reg ena   = 1;

  always #(CLK_HALF_PERIOD) begin
    clk <= ~clk;
  end


  // model specific signals
  localparam REFCLK_PERIOD = 113;
  localparam REFCLK_HALF_PERIOD = REFCLK_PERIOD/2;
  reg refclk = 0;

  // sync register
  wire refclk_sync;

  // blocks used to generate signals for the button debouncer
  // clock strobe generator
  wire clk_1hz_stb;
  wire clk_slow_set_stb;
  wire clk_fast_set_stb;
  wire clk_debounce_stb;
 
  refclk_sync refclk_sync_inst (
    .i_reset_n     (rst_n),
    .i_clk         (clk),
    .i_refclk      (refclk),
    .o_refclk_sync (refclk_sync)
  );

  clk_gen clk_gen_inst (
    .i_reset_n      (rst_n),
    .i_clk          (clk),
    .i_refclk       (refclk_sync),
    .o_1hz_stb      (clk_1hz_stb),
    .o_slow_set_stb (clk_slow_set_stb),
    .o_fast_set_stb (clk_fast_set_stb),
    .o_debounce_stb (clk_debounce_stb)
  );

  // wires and registers needed to test clock setting inputs
  reg i_fast_set    = 0;
  reg i_set_hours   = 0;
  reg i_set_minutes = 0;

  wire clk_fast_set;
  wire clk_set_hours;
  wire clk_set_minutes;


  button_debounce input_debounce (
    .i_reset_n (rst_n),
    .i_clk     (clk),
    
    .i_debounce_stb (clk_debounce_stb),
    
    .i_fast_set    (i_fast_set),
    .i_set_hours   (i_set_hours),
    .i_set_minutes (i_set_minutes),
    
    .o_fast_set_db    (clk_fast_set),
    .o_set_hours_db   (clk_set_hours),
    .o_set_minutes_db (clk_set_minutes)
  );

  // Clock register
  wire [4:0] clk_hours;
  wire [5:0] clk_minutes;
  wire [5:0] clk_seconds;

  wire clk_set_stb = clk_fast_set ? clk_fast_set_stb : clk_slow_set_stb;

  clock_register clock_reg_inst (
    // global signals
    .i_reset_n (rst_n),
    .i_clk     (clk),

    // timing strobes
    .i_1hz_stb (clk_1hz_stb),
    .i_set_stb (clk_set_stb),

    // clock setting inputs
    .i_set_hours   (clk_set_hours),
    .i_set_minutes (clk_set_minutes),

    // time outputs
    .o_hours   (clk_hours),
    .o_minutes (clk_minutes),
    .o_seconds (clk_seconds)
  );

  always #(REFCLK_HALF_PERIOD) begin
    refclk <= ~refclk;
  end

  task clock_set_hours (
    input [4:0] hours_settime
  );
    begin
      i_set_hours = 1'h1;
      while (clk_hours != hours_settime)
        @(posedge clk);
      i_set_hours = 1'h0;
    end
  endtask

  task clock_set_minutes (
    input [5:0] minutes_settime
  );
    begin
      i_set_minutes = 1'h1;
      while (clk_minutes != minutes_settime)
        @(posedge clk);
      i_set_minutes = 1'h0;
    end
  endtask

  task clock_reset_seconds ();
    begin
      i_set_hours   = 1'h1;
      i_set_minutes = 1'h1;
      while (clk_seconds != 5'h0)
        @(posedge clk);
      i_set_hours   = 1'h0;
      i_set_minutes = 1'h0;
    end
  endtask

  task run_test();
    begin
      i_fast_set = 1'h1;
      // set the hours and minutes
      clock_set_hours(10);
      $display("Time Set: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);
      clock_set_minutes(59);
      $display("Time Set: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);
      clock_reset_seconds();
      $display("Time Set: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);
      repeat(61) @(posedge clk_1hz_stb);
      $display("Time: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);

      i_fast_set = 1'h0;

      // try rolling over the hours
      clock_set_hours(23);
      clock_set_minutes(59);
      clock_reset_seconds();
      $display("Time Set: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);
      repeat(61) @(posedge clk_1hz_stb);
      $display("Time: %d:%d.%d", clk_hours, clk_minutes, clk_seconds);
    end
  endtask

  task init();
    begin
      $display("Simulation Start");
      $display("Reset");

      repeat(2) @(posedge clk);
      rst_n = 1;
      $display("Run");
    end
  endtask

  task close();
    begin
      $display("Closing");
      repeat(10) @(posedge clk);
      $finish;
    end
  endtask

endmodule
