#include "VerilatorTBench.h"
#include "Vsimple_clock.h"

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 100000
#endif

int main(int nargs, char **args) {
  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vbasic_clock>("basic_clock.vcd");
  tb->core->i_reset_n = 0;
  tb->core->i_en = 0;
  tb->tick();
  tb->core->i_reset_n = 1;
  tb->core->i_en = 1;
  tb->tick();

  const long int NUM_SECONDS = 60 * 60 * 25;

  for (long int i = 0; i < NUM_SECONDS * SYS_CLK_HZ; ++i) {
    tb->tick();
  }

  delete tb;
  return 0;
}
