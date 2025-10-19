PCF_FILE         =  test.pcf
VCD_FILE 		     =  tb_top.vcd
SBY_FILE 		     =  formal/test.sby
SYNTH_V_SRCS     =  rtl/soc.v rtl/defines.v rtl/bus.v rtl/mem_bram.v  rtl/cpu_mem_controller.v rtl/cpu.v rtl/alu.v rtl/macros.v
SYNTH_TOP_MODULE =  soc

IVERILOG_SRCS	   =  rtl/soc.v rtl/cpu_mem_controller.v rtl/mem_bram.v rtl/macros.v rtl/tb_top.v rtl/cpu.v rtl/alu.v rtl/bus.v rtl/console.v
IVERILOG_FLAGS   =  -DSIM -Irtl
 
YOSYS_FLAGS      =  -p 'synth_ice40 -json $(OUTPUT_JSON)'
NEXTPNR_FLAGS    =  --hx8k --package ct256 --pcf-allow-unconstrained --placed-svg synth_build/place.svg --routed-svg synth_build/route.svg
 
SYNTH_BDIR  		 =  synth_build
OUTPUT_ASC       =  $(SYNTH_BDIR)/test.asc
OUTPUT_JSON      =  $(SYNTH_BDIR)/test.json
OUTPUT_BIN       =  $(SYNTH_BDIR)/test.bin

SIM_OUT_FILE     = /dev/null 
SIM_BDIR    		 = sim_build

all: sim_display_console 

clean:
	rm -rf $(SIM_BDIR)
	rm -rf $(SYNTH_BDIR)
	cd test && make clean

view_vcd:
	gtkwave $(VCD_FILE)

lint: rtl/soc.v 
	verilator --lint-only -Wall -Wno-fatal rtl/soc.v -Irtl

sim_display_console: sim
	cat $(SIM_BDIR)/console_output.txt

sim: test/Makefile $(IVERILOG_SRCS) 
	mkdir -p $(SIM_BDIR)
	cd test && make
	make -C test
	cp test/build/kernel.txt $(SIM_BDIR)/kernel.txt
	cp res/reg_file.txt $(SIM_BDIR)/reg_file.txt
	iverilog $(IVERILOG_FLAGS) $(IVERILOG_SRCS) -o $(SIM_BDIR)/a.out
	cd $(SIM_BDIR) && ./a.out

synth: $(SYNTH_V_SRCS) 
	mkdir -p $(SYNTH_BDIR)
	make -C test
	cp test/build/kernel.txt $(SYNTH_BDIR)/kernel.txt
	cp res/reg_file.txt $(SYNTH_BDIR)/reg_file.txt
	yosys $(YOSYS_FLAGS) $(SYNTH_V_SRCS) > $(SYNTH_BDIR)/yosys_result.txt
	nextpnr-ice40 $(NEXTPNR_FLAGS) --top $(SYNTH_TOP_MODULE) --pcf $(PCF_FILE) --json $(OUTPUT_JSON) --asc $(OUTPUT_ASC) > $(SYNTH_BDIR)/nextpnr_result.txt
	icepack $(OUTPUT_ASC) $(OUTPUT_BIN) > $(SYNTH_BDIR)/icepack_result.txt

