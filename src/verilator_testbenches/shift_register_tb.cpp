#include "VerilatorTBench.h"
#include "Vshift_register_tb.h"

#ifndef SYS_CLK_HZ
#define SYS_CLK_HZ 100000
#endif

int main(int nargs, char **args) {
  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vshift_register_tb>("shift_register.vcd");
  tb->core->i_reset_n = 0;
  tb->core->i_start_stb = 0;
  tb->tick();
  tb->core->i_reset_n = 1;

  for (int i = 0; i < 64; ++i) {
    tb->core->i_parallel_data = i & 0xff;
    tb->core->i_start_stb = 1;
    tb->tick();
    while (tb->core->o_busy) {
      tb->tick();
    }
    int parallel_out = tb->core->o_parallel_data;
    printf("input data: %d, output data: %d\n", (i & 0xff), parallel_out);
    assert(parallel_out == (i & 0xff));
  }
  tb->core->i_start_stb = 0;
  tb->tick();

  delete tb;
  return 0;
}
