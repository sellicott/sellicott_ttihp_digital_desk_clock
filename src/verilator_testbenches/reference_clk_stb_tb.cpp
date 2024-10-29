#include "VerilatorTBench.h"
#include "Vreference_clk_stb.h"

void tick(VerilatorTBench<Vreference_clk_stb> *tb);

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 100000
#endif

#ifndef REF_CLK_HZ
#define REF_CLK_HZ 32768
#endif

#define FAST_CLK_HZ 5
#define SLOW_CLK_HZ 2

int main(int nargs, char **args) {
  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vreference_clk_stb>("reference_clk.vcd");
  tb->core->i_reset_n = 0;
  tb->core->i_en = 0;
  tb->core->i_fast_set = 1;
  tick(tb);
  tb->core->i_reset_n = 1;
  tb->core->i_en = 1;
  tick(tb);

  // count for 23 seconds
  long int NUM_SECONDS = 5;
  for (long int i = 0; i < NUM_SECONDS * SYS_CLK_HZ; ++i) {
    tick(tb);
  }

  delete tb;
  return 0;
}

void tick(VerilatorTBench<Vreference_clk_stb> *tb) {
  static unsigned int refclk_tickcount = 0;
  const unsigned int MAX_REFCLK_TICK = SYS_CLK_HZ / (REF_CLK_HZ);
  if (++refclk_tickcount > MAX_REFCLK_TICK) {
    tb->core->i_refclk = !tb->core->i_refclk;
    refclk_tickcount = 0;
  }
  tb->tick();
}
