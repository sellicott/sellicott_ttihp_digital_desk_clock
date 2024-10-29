#ifndef VERILATOR_TBENCH_H
#define VERILATOR_TBENCH_H

#include <memory>
#include <stdint.h>
#include <string>

#include "verilated_vcd_c.h"

template <class VerilatorType> class VerilatorTBench {
public:
  std::unique_ptr<VerilatorType> core;
  std::unique_ptr<VerilatedVcdC> trace;
  uint64_t tickcount;
  int32_t clk_period;

  VerilatorTBench(std::string const &filename, int period = 10)
      : core(new VerilatorType()), trace(new VerilatedVcdC()) {
    tickcount = 0;
    clk_period = period;

    // Save the simulator ouput
    Verilated::traceEverOn(true);
    core->trace(trace.get(), 99);
    trace->open(filename.c_str());

    // initilize testbench
    core->i_clk = 0;
    eval();
    trace->dump(tickcount);
  }

  virtual ~VerilatorTBench() { trace->close(); }

  virtual void eval(void) { core->eval(); }

  virtual void tick() {
    ++tickcount;
    eval();
    trace->dump(tickcount * clk_period - 2);

    core->i_clk = 1;
    eval();
    trace->dump(tickcount * clk_period);

    core->i_clk = 0;
    eval();
    trace->dump(tickcount * clk_period + clk_period / 2);
    trace->flush();
  }
};
#endif
