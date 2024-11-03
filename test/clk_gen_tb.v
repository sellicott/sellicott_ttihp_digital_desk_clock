
/* clk_gen_tb.v
 * Copyright (c) 2024 Samuel Ellicott
 * SPDX-License-Identifier: Apache-2.0
 *
 * Testbench for clk_gen.v file
 */

`default_nettype none

module clk_gen_tb ();

  // setup file dumping things
  localparam STARTUP_DELAY = 5;
  initial begin
    $dumpfile("clk_gen_tb.fst");
    $dumpvars(0, clk_gen_tb);
    #STARTUP_DELAY;

    $display("Test Clock Strobe Generation");
    init();

    run_test();

    // exit the simulator
    close();
  end

  // setup global signals
  localparam CLK_PERIOD = 80;
  localparam CLK_HALF_PERIOD = CLK_PERIOD/2;

  reg clk   = 0;
  reg rst_n = 0;
  reg ena   = 1;

  always #(CLK_HALF_PERIOD) begin
    clk <= ~clk;
  end


  // model specific signals
  localparam REFCLK_PERIOD = 3051;
  localparam REFCLK_HALF_PERIOD = REFCLK_PERIOD/2;
  reg refclk = 0;

  // sync register
  wire refclk_sync;

  // clock strobe generator
  wire clk_1hz_stb;
  wire clk_slow_set_stb;
  wire clk_fast_set_stb;
 
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
    .o_fast_set_stb (clk_fast_set_stb)
  );

  always #(REFCLK_HALF_PERIOD) begin
    refclk <= ~refclk;
  end

  task run_test();
    begin
      repeat(2) @(posedge clk_1hz_stb);
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
