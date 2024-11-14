`ifndef DEF_FILE_V
`define DEF_FILE_V

//`define SIM

`ifdef SIM 
  `define DEFAULT_BRAM_MEM_FILE "kernel.txt"
  `define MEM_FILE "kernel.txt"
  `define REG_FILE "reg_file.txt"
  `define MEM_SIZE 2**16
  `define MEM_DUMP_SIZE 2**4
`else 
  `define DEFAULT_BRAM_MEM_FILE "synth_build/kernel.txt"
  `define REG_FILE "synth_build/reg_file.txt"
  `define MEM_FILE "synth_build/kernel.txt"
  `define MEM_SIZE 2**3
  `define MEM_DUMP_SIZE 0
`endif

`endif