#include <iostream>
#include <curses.h>
#include <Vsoc.h>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <cassert>
#include <cstdint>
#include <bitset>
#include <curses.h>
#include <filesystem>
#include <fstream>
#include <string>

template <typename TimeType, typename ModuleType>
void tick_module(TimeType &time, ModuleType &tb, VerilatedVcdC &tfp)
{


	tb.eval();
	tfp.dump(time); // dump 2ns before tick
	time++;

	tb.i_clk = 1;
	tb.eval();
	tfp.dump(time); // tick every 10ns
	time++;

	tb.i_clk = 0;
	tb.eval();
	tfp.dump(time); // trailing edge dump
	time++;

	tfp.flush();
}

template <typename TimeType, typename ModuleType>
void tick_module_comb(TimeType &ticks, ModuleType &tb, VerilatedVcdC &tfp){
	tb.eval();
	tfp.dump(ticks);
	tfp.flush();
	ticks++;
}


int main(int argc, char const *argv[]){

	std::cout << std::filesystem::current_path();
	
  Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	VerilatedVcdC tfp{};
	Vsoc tb{};
	tb.trace(&tfp, 99);
	tfp.open("test.vcd");
	int ticks{};
	
	tb.i_stb = 1;
	tb.i_reset = 1;
	tick_module(ticks, tb, tfp);
	tb.i_reset = 0;
	tick_module(ticks, tb, tfp);

  for (size_t i = 0; i < 1E8; i++)
  {
		//std::cout << "cpu \n";
		tick_module(ticks, tb, tfp);
		if(tb.o_shutdown) {
			break;
		}
  }

	tb.i_close_file = 1;
	tick_module(ticks, tb, tfp);
	tb.i_close_file = 0;
	tick_module(ticks, tb, tfp);
	

	std::ifstream con_file("console_output.txt");
    if (con_file.is_open()){
				std::stringstream buffer;
				buffer << con_file.rdbuf();
				std::string buffer_str = buffer.str();
        std::cout << buffer_str << std::endl;
		} else {
			std::cout << "\n Verilator Simulation: console output file not found" << std::endl;
			return -1;
		}

	std::cout << "\n Verilator Simulation: finished" << std::endl;

  
  
  return 0;
}