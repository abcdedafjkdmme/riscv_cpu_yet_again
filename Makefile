PCF_FILE         =  test.pcf
VCD_FILE 		     =  tb_top.vcd
SBY_FILE 		     =  formal/test.sby
SYNTH_V_SRCS     =  rtl/soc.v rtl/bus.v rtl/mem_bram.v rtl/cpu_mem_controller.v rtl/cpu.v rtl/alu.v rtl/macros.v
SYNTH_TOP_MODULE =  soc

IVERILOG_SRCS	   =  rtl/soc.v rtl/cpu_mem_controller.v rtl/mem_bram.v rtl/macros.v rtl/top_tb.v rtl/cpu.v rtl/alu.v rtl/bus.v
IVERILOG_FLAGS   =  -Irtl -dCPU_SIM_DISPLAY_DISABLED
 
YOSYS_FLAGS      =  -p 'synth_ice40 -json $(OUTPUT_JSON)'
NEXTPNR_FLAGS    =  --hx8k --package ct256 --pcf-allow-unconstrained --placed-svg synth_build/place.svg --routed-svg synth_build/route.svg
 
SYNTH_BUILD_DIR  =  synth_build
OUTPUT_ASC       =  $(SYNTH_BUILD_DIR)/test.asc
OUTPUT_JSON      =  $(SYNTH_BUILD_DIR)/test.json
OUTPUT_BIN       =  $(SYNTH_BUILD_DIR)/test.bin

all: sim 
clean:
	rm a.out 
	rm tb_top.vcd
	rm -rf $(SYNTH_BUILD_DIR)

sim: $(IVERILOG_SRCS) test/Makefile
	cd test && make
	iverilog $(IVERILOG_SRCS) $(IVERILOG_FLAGS) -Irtl 
	./a.out > result.txt
	gtkwave tb_top.vcd

synth: $(SYNTH_V_SRCS)
	mkdir -p $(SYNTH_BUILD_DIR)
	yosys $(YOSYS_FLAGS) $(SYNTH_V_SRCS) > $(SYNTH_BUILD_DIR)/yosys_result.txt
	nextpnr-ice40 $(NEXTPNR_FLAGS) --top $(SYNTH_TOP_MODULE) --pcf $(PCF_FILE) --json $(OUTPUT_JSON) --asc $(OUTPUT_ASC) > $(SYNTH_BUILD_DIR)/nextpnr_result.txt
	icepack $(OUTPUT_ASC) $(OUTPUT_BIN) > $(SYNTH_BUILD_DIR)/icepack_result.txt

view_vcd:
	gtkwave $(VCD_FILE)

verify: 
	sby -f $(SBY_FILE)