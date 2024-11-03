SRC_DIR = $(PWD)/../src


SRC_TESTBENCHES := clk_gen_tb.v
SRC_TESTBENCHES += button_debounce_tb.v
SRC_TESTBENCHES += clock_register_tb.v
SRC_TESTBENCHES += binary_to_bcd_tb.v
SRC_TESTBENCHES += bcd_to_7seg_tb.v
SRC_TESTBENCHES += clock_to_bcd_tb.v
SRC_TESTBENCHES += max7219_tb.v
SRC_TESTBENCHES += max7219_settings_tb.v
SRC_TESTBENCHES += output_wrapper_tb.v
SRC_TESTBENCHES += display_controller_tb.v
SRC_TESTBENCHES += clock_wrapper_tb.v

TESTBENCH_FST = $(SRC_TESTBENCHES:.v=.fst)
TESTBENCH_LOG = $(SRC_TESTBENCHES:.v=.log)
TESTBENCH_SIM = $(basename $(SRC_TESTBENCHES))

.PHONY: $(TESTBENCH_SIM) all clean

all: $(TESTBENCH_FST)
	cat $(TESTBENCH_LOG) > logfile.txt

clock_wrapper_tb.vvp: clock_wrapper_tb.v \
  $(SRC_DIR)/clock_wrapper.v \
  $(SRC_DIR)/clk_gen.v \
  $(SRC_DIR)/button_debounce.v \
  $(SRC_DIR)/clock_register.v \
  $(SRC_DIR)/decimal_point_controller.v \
  $(SRC_DIR)/display_controller.v \
  $(SRC_DIR)/output_wrapper.v \
  $(SRC_DIR)/clock_to_bcd.v $(SRC_DIR)/binary_to_bcd.v \
  $(SRC_DIR)/max7219_settings.v $(SRC_DIR)/max7219.v \
  $(SRC_DIR)/bcd_to_7seg.v \
  test_max7219_moc.v test_7seg_to_bcd.v
	iverilog -o $@ $^

display_controller_tb.vvp: display_controller_tb.v \
  $(SRC_DIR)/display_controller.v \
  $(SRC_DIR)/clk_gen.v \
  $(SRC_DIR)/output_wrapper.v \
  $(SRC_DIR)/clock_to_bcd.v $(SRC_DIR)/binary_to_bcd.v \
  $(SRC_DIR)/max7219_settings.v $(SRC_DIR)/max7219.v
	iverilog -o $@ $^

output_wrapper_tb.vvp: output_wrapper_tb.v \
  $(SRC_DIR)/output_wrapper.v \
  $(SRC_DIR)/clock_to_bcd.v $(SRC_DIR)/binary_to_bcd.v \
  $(SRC_DIR)/max7219_settings.v $(SRC_DIR)/max7219.v \
  $(SRC_DIR)/bcd_to_7seg.v \
  test_max7219_moc.v test_7seg_to_bcd.v
	iverilog -o $@ $^

max7219_settings_tb.vvp: max7219_settings_tb.v $(SRC_DIR)/max7219_settings.v $(SRC_DIR)/max7219.v
	iverilog -o $@ $^

max7219_tb.vvp: max7219_tb.v $(SRC_DIR)/max7219.v test_max7219_moc.v test_7seg_to_bcd.v  $(SRC_DIR)/bcd_to_7seg.v
	iverilog -o $@ $^

clock_to_bcd_tb.vvp: clock_to_bcd_tb.v $(SRC_DIR)/clock_to_bcd.v $(SRC_DIR)/binary_to_bcd.v
	iverilog -o $@ $^

bcd_to_7seg_tb.vvp: bcd_to_7seg_tb.v $(SRC_DIR)/bcd_to_7seg.v
	iverilog -o $@ $^

binary_to_bcd_tb.vvp: binary_to_bcd_tb.v $(SRC_DIR)/binary_to_bcd.v
	iverilog -o $@ $^

clock_register_tb.vvp: clock_register_tb.v $(SRC_DIR)/clock_register.v $(SRC_DIR)/button_debounce.v $(SRC_DIR)/clk_gen.v
	iverilog -o $@ $^

button_debounce_tb.vvp: button_debounce_tb.v $(SRC_DIR)/button_debounce.v $(SRC_DIR)/clk_gen.v
	iverilog -o $@ $^

clk_gen_tb.vvp: clk_gen_tb.v $(SRC_DIR)/clk_gen.v
	iverilog -o $@ $^

# Generate output files from elaborated simulation
%.vcd: %.vvp
	vvp $^

%.fst : %.vvp
	vvp $^ -fst | tee $*.log

# run gtkwave on a simulation output file
% : %.fst
	-gtkwave -o $< $@.gtkw &

clean:
	-rm *.vcd
	-rm *.vvp
	-rm *.fst
