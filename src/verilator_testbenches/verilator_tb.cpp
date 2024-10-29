#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "VTRNG_deserializer.h"
#include "verilated_vcd_c.h"
void tick(unsigned int tickcount, VTRNG_deserializer* tb, VerilatedVcdC* tfp);
uint64_t deserialize_data(unsigned int* tickcount, VTRNG_deserializer* tb, VerilatedVcdC* tfp, uint64_t data);

/*
module TRNG_deserializer(
	i_clk,        // input clock (stop signal)
	i_reset,      // reset signal
	i_en,         // enable the system

	i_bit,        // input bit
	o_data,       // parallel TRNG data
	o_data_ready  // new parallel data ready
);
*/

int main (int nargs, char** args) {
	Verilated::commandArgs(nargs, args);
	VTRNG_deserializer* tb = new VTRNG_deserializer;
	unsigned int tickcount = 0;
	uint64_t shift_data = 0;
	uint64_t prev_data = 0;

	// setup VCD trace output
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	tb->trace(tfp, 99);
	tfp->open("TRNG_deserializer.vcd");

	// start by reseting the shift register
	tb->i_reset = 1;
	tb->i_en    = 0;
	tick(++tickcount, tb, tfp);
	tb->i_reset = 0;
	tb->i_en    = 1;

	prev_data = deserialize_data(&tickcount, tb, tfp, 0xff);
	printf("loaded data: 0x%04lx\n", prev_data);
	prev_data = deserialize_data(&tickcount, tb, tfp, 0xA5);
	printf("loaded data: 0x%04lx\n", prev_data);
	prev_data = deserialize_data(&tickcount, tb, tfp, 0x5A);
	printf("loaded data: 0x%04lx\n", prev_data);
	prev_data = deserialize_data(&tickcount, tb, tfp, 0xD3);
	printf("loaded data: 0x%04lx\n", prev_data);
	
	return 0;
}

// Run the system for another clock cycle and update the dump file
void tick(unsigned int tickcount, VTRNG_deserializer* tb, VerilatedVcdC* tfp){
	tb->eval();
	if(tfp) {
		tfp->dump(tickcount * 10 - 2);
	}

	tb->i_clk = 1;

	tb->eval();
	if(tfp) {
		tfp->dump(tickcount * 10);
	}

	tb->i_clk = 0;
	tb->eval();
	if(tfp) {
		tfp->dump(tickcount * 10 + 5);
		tfp->flush();
	}

}

uint64_t deserialize_data(unsigned int* tickcount, VTRNG_deserializer* tb, VerilatedVcdC* tfp, uint64_t data) {
	uint64_t out_data = 0;
	uint8_t tmp_data = 0;
	uint8_t shift_in = 0;
	for(int i = 0; i < 8; ++i){
		shift_in = (data >> i) & 1;
		tb->i_bit = shift_in;
		if (tb->o_data_ready) {
			tmp_data = tb->o_data;
			out_data = tmp_data;
		}
		tick(++*tickcount, tb, tfp);
	}

	return out_data;
}
