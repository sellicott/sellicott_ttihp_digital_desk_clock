#include "Vclock_wrapper_tb.h"
#include "VerilatorTBench.h"

int display_to_bin(int disp);
void print_time(VerilatorTBench<Vclock_wrapper_tb> *tb);
void tick(VerilatorTBench<Vclock_wrapper_tb> *tb);

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
  auto tb = new VerilatorTBench<Vclock_wrapper_tb>("clock_wrapper.vcd");
  tb->core->i_reset_n = 0;
  tb->core->i_en = 0;
  tb->core->i_fast_set = 1;
  tb->core->i_mode = 0;
  tb->core->i_use_refclk = 0;
  tick(tb);
  tb->core->i_reset_n = 1;
  tb->core->i_en = 1;
  tick(tb);

  // count for 23 seconds
  long int NUM_SECONDS = 23;
  for (long int i = 0; i < NUM_SECONDS * SYS_CLK_HZ + 50; ++i) {
    tick(tb);
  }
  print_time(tb);

  // timeset the minutes register to 23 using the slow clock
  long int MINUTES_SET = 58;
  tb->core->i_mode = 1;
  tb->core->i_fast_set = 0;
  for (long int i = 0; i < MINUTES_SET * SYS_CLK_HZ / SLOW_CLK_HZ + 50; ++i) {
    tick(tb);
  }
  print_time(tb);
  // assert(tb->core->o_minutes == MINUTES_SET);

  // timeset the hours register to 13 using the fast clock
  long int HOURS_SET = 23;
  tb->core->i_mode = 2;
  tb->core->i_fast_set = 1;
  for (long int i = 0; i < HOURS_SET * SYS_CLK_HZ / FAST_CLK_HZ + 50; ++i) {
    tick(tb);
  }
  print_time(tb);
  // assert(tb->core->o_hours == HOURS_SET);

  // clear the seconds register
  tb->core->i_mode = 3;
  // wait until the register is cleared, by waiting for 1 second
  for (long int i = 0; i < 1 * SYS_CLK_HZ + 50; ++i) {
    tick(tb);
  }
  print_time(tb);
  // assert(tb->core->o_seconds == 0);

  // run until the time rolls over
  tb->core->i_mode = 0;
  for (long int i = 0; i < (long int)60 * 5 * SYS_CLK_HZ; ++i) {
    tick(tb);
  }
  print_time(tb);

  delete tb;
  return 0;
}

int display_to_bin(int disp) {
  switch (disp) {
  /*                      abcdefg */
  case 0b1111110:
    return 0; // 0
  case 0b0110000:
    return 1;     // 1
  case 0b1101101: // 2
    return 2;
  case 0b1111001: // 3
    return 3;
  case 0b0110011: // 4
    return 4;
  case 0b1011011: // 5
    return 5;
  case 0b1011111: // 6
    return 6;
  case 0b1110000: // 7
    return 7;
  case 0b1111111: // 8
    return 8;
  case 0b1111011: // 9
    return 9;
  default:
    return -1;
  }
}

void print_time(VerilatorTBench<Vclock_wrapper_tb> *tb) {
  uint64_t parallel_data = tb->core->o_parallel_data;

  uint8_t hours_msb_7seg = (parallel_data >> (5 * 8)) & 0x7F;
  uint8_t hours_lsb_7seg = (parallel_data >> (4 * 8)) & 0x7F;
  uint8_t minutes_msb_7seg = (parallel_data >> (3 * 8)) & 0x7F;
  uint8_t minutes_lsb_7seg = (parallel_data >> (2 * 8)) & 0x7F;
  uint8_t seconds_msb_7seg = (parallel_data >> (1 * 8)) & 0x7F;
  uint8_t seconds_lsb_7seg = (parallel_data >> (0 * 8)) & 0x7F;

  uint8_t hours_msb = display_to_bin(hours_msb_7seg);
  uint8_t hours_lsb = display_to_bin(hours_lsb_7seg);
  uint8_t minutes_msb = display_to_bin(minutes_msb_7seg);
  uint8_t minutes_lsb = display_to_bin(minutes_lsb_7seg);
  uint8_t seconds_msb = display_to_bin(seconds_msb_7seg);
  uint8_t seconds_lsb = display_to_bin(seconds_lsb_7seg);

  printf("%d%d:%d%d.%d%d\n", hours_msb, hours_lsb, minutes_msb, minutes_lsb,
         seconds_msb, seconds_lsb);
}

void tick(VerilatorTBench<Vclock_wrapper_tb> *tb) {
  static unsigned int refclk_tickcount = 0;
  const unsigned int MAX_REFCLK_TICK = SYS_CLK_HZ / (2 * REF_CLK_HZ);
  if (++refclk_tickcount > MAX_REFCLK_TICK) {
    tb->core->i_refclk = !tb->core->i_refclk;
    refclk_tickcount = 0;
  }
  tb->tick();
}
