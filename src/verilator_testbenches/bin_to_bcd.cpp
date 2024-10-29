#include "Vbin_to_bcd.h"
#include "VerilatorTBench.h"

int main(int nargs, char **args) {
  Verilated::commandArgs(nargs, args);
  auto tb = new VerilatorTBench<Vbin_to_bcd>("bin_to_bcd.vcd");

  int binary_in = 0;

  for (int i = 0; i < 64; ++i) {
    tb->core->i_bin = i;
    tb->tick();
    int msb = tb->core->o_bcd_msb;
    int lsb = tb->core->o_bcd_lsb;
    printf("0x%02x -> %d%d\n", i, msb, lsb);
    assert(lsb == i % 10);
    assert(msb == i / 10);
  }

  tb->core->i_bin = 0x3F & 64;
  tb->tick();
  int msb = tb->core->o_bcd_msb;
  int lsb = tb->core->o_bcd_lsb;
  printf("0x%02x -> %d%d\n", 64, msb, lsb);
  // assert(lsb == 0);
  // assert(msb == 0);

  tb->core->i_bin = 0x3F & 65;
  tb->tick();
  msb = tb->core->o_bcd_msb;
  lsb = tb->core->o_bcd_lsb;
  printf("0x%02x -> %d%d\n", 65, msb, lsb);
  assert(lsb == 1);
  assert(msb == 0);

  delete tb;
  return 0;
}
