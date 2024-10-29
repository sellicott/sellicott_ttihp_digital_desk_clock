verilog_SRCS = clock_wrapper_tb.v clock_wrapper.v \
	       basic_clock.v time_register.v overflow_counter.v sysclk_divider.v upcounter.v timeset_divider.v load_divider.v \
	       output_wrapper.v digit_shift_register.v shift_register_controller.v \
	       bin_to_bcd.v bcd_segment_mux.v bcd_to_7seg.v clock_to_7seg.v \
	       shift_register.v clock_stb_gen.v \
	       reference_clk_stb.v \
	       button_debounce.v
testbench = clock_wrapper_tb.cpp
top_module = clock_wrapper_tb
#verilog_SRCS = reference_clk_stb.v overflow_counter.v sysclk_divider.v upcounter.v timeset_divider.v load_divider.v
#testbench = reference_clk_stb_tb.cpp
#top_module = reference_clk_stb

SRC_DIR = ../

SYS_CLK_HZ = 100000
REF_CLK_HZ = 32768
SHIFT_CLK_HZ = 1000
DEBOUNCE_COUNT = 2500 

PARAMS = -GSYS_CLK_HZ=$(SYS_CLK_HZ) -GSHIFT_CLK_HZ=$(SHIFT_CLK_HZ) -GREF_CLK_HZ=$(REF_CLK_HZ) -GDEBOUNCE_COUNT=$(DEBOUNCE_COUNT)
DEFINES = -DSYS_CLK_HZ=$(SYS_CLK_HZ) -DREF_CLK_HZ$(REF_CLK_HZ) -DDEBOUNCE_COUNT=$(DEBOUNCE_HZ)
#PARAMS = -GWIDTH=8
#PARAMS = -GREF_CLK_HZ=$(REF_CLK_HZ)

#verilator_include = $(HOME)/.local/extra_packages/verilator/usr/share/verilator/include
verilator_include = /usr/share/verilator/include

EXPANDED_SRC = $(verilog_SRCS:%.v=$(SRC_DIR)/%.v)

.PHONY: all verilator build clean

all: verilator build
	
verilator:
	verilator -Wall --trace $(PARAMS) --top-module $(top_module) -cc $(EXPANDED_SRC) 
	$(MAKE) -C obj_dir -f V$(top_module).mk

build: 
	g++ -std=c++14 \
	$(DEFINES) \
	-I $(verilator_include) \
	-I obj_dir/ \
	$(verilator_include)/verilated.cpp \
	$(verilator_include)/verilated_vcd_c.cpp \
	$(verilator_include)/verilated_threads.cpp \
	$(testbench) obj_dir/V$(top_module)__ALL.a \
	-latomic \
	-o $(top_module) 

clean:
	-rm -r obj_dir
	-rm *.vcd
	-rm $(top_module)

