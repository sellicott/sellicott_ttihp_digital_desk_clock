#include "VerilatorTBench.h"
#include "Vtimeset_divider.h"

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 100000
#endif

int main(int nargs, char **args) {
  const int freq1 = 5;
  const int freq2 = 2;

  const int inc1 = (1 << 30) / ((SYS_CLK_HZ / freq1) / 4) - 1;
  const int inc2 = (1 << 30) / ((SYS_CLK_HZ / freq2) / 4) - 1;

  printf("inc1: %d, inc2: %d\n", inc1, inc2);
  const long int NUM_SECONDS = 10;

  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vtimeset_divider>("timeset_divider.vcd", 1000);
  tb->core->i_reset_n = 0;
  tb->core->i_en = 0;
  tb->tick();
  tb->core->i_reset_n = 1;
  tb->core->i_en = 1;
  tb->core->i_fast_set = 1;

  for (long int i = 0; i < NUM_SECONDS / 2 * SYS_CLK_HZ; ++i) {
    tb->tick();
  }

  tb->core->i_fast_set = 0;
  for (long int i = 0; i < NUM_SECONDS / 2 * SYS_CLK_HZ; ++i) {
    tb->tick();
  }

  delete tb;
  return 0;
}
