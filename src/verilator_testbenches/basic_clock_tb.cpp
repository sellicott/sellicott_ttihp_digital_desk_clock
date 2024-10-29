#include "Vbasic_clock.h"
#include "VerilatorTBench.h"

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 100000
#endif

#define FAST_CLK_HZ 5
#define SLOW_CLK_HZ 2

int main(int nargs, char **args) {
  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vbasic_clock>("basic_clock.vcd");
  tb->core->i_reset_n = 0;
  tb->core->i_en = 0;
  tb->core->i_fast_set = 1;
  tb->core->i_mode = 0;
  tb->tick();
  tb->core->i_reset_n = 1;
  tb->core->i_en = 1;
  tb->tick();

  // count for 23 seconds
  long int NUM_SECONDS = 23;
  for (long int i = 0; i < NUM_SECONDS * SYS_CLK_HZ; ++i) {
    tb->tick();
  }

  // timeset the minutes register to 23 using the slow clock
  long int MINUTES_SET = 58;
  tb->core->i_mode = 1;
  tb->core->i_fast_set = 0;
  for (long int i = 0; i < MINUTES_SET * SYS_CLK_HZ / SLOW_CLK_HZ; ++i) {
    tb->tick();
  }
  assert(tb->core->o_minutes == MINUTES_SET);

  // timeset the hours register to 13 using the fast clock
  long int HOURS_SET = 23;
  tb->core->i_mode = 2;
  tb->core->i_fast_set = 1;
  for (long int i = 0; i < HOURS_SET * SYS_CLK_HZ / FAST_CLK_HZ; ++i) {
    tb->tick();
  }
  assert(tb->core->o_hours == HOURS_SET);

  // clear the seconds register
  tb->core->i_mode = 3;
  // wait until the register is cleared, by waiting for 1 second
  for (long int i = 0; i < 1 * SYS_CLK_HZ; ++i) {
    tb->tick();
  }
  assert(tb->core->o_seconds == 0);

  // run until the time rolls over
  tb->core->i_mode = 0;
  for (long int i = 0; i < (long int)60 * 5 * SYS_CLK_HZ; ++i) {
    tb->tick();
  }

  delete tb;
  return 0;
}
