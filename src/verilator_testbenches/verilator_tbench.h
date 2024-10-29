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

  VerilatorTBench(const std::string &filename) {
    // setup memory
    core = std::make_unique<VerilatorType>;
    trace = std::make_unique<VerilatedVcdC>;
    tickcount = 0;

    // Save the simulator ouput
    Verilated::traceEverOn(true);
    trace->open(filename.c_str());
    core->trace(trace, 99);

    // initilize testbench
    core->i_clk = 0;
    eval();
  }

  ~VerilatorTBench() { trace->close(); }

  virtual void eval(void) { core->eval(); }

  virtual void tick() {
    eval();
    trace->dump(tickcount * 10 - 2);

    core->i_clk = 1;
    eval();
    trace->dump(tickcount * 10);

    core->i_clk = 0;
    eval();
    trace->dump(tickcount * 10 + 5);
    trace->flush();
  }
};
#endif
