`define IS_MEM_READ_INSTR(instr) (instr[6:0] == 'b00000_11)
`define IS_MEM_WRITE_INSTR(instr) (instr[6:0] == 'b01000_11)
`define IS_JAL_INSTR(instr) (instr[6:0] == 'b11011_11)
`define IS_JALR_INSTR(instr) (instr[6:0] == 'b11001_11)
`define IS_BRANCH_INSTR(instr) (instr[6:0] == 'b11000_11)
`define IS_REG_ALU_INSTR(instr) (instr[6:0] == 'b01100_11)
`define IS_IMM_ALU_INSTR(instr) (instr[6:0] == 'b00100_11)
`define IS_LUI_INSTR(instr) (instr[6:0] == 'b01101_11)
`define IS_AUIPC_INSTR(instr) (instr[6:0] == 'b00101_11)
`define IS_PAUSE_INSTR(instr) (instr == 'b0000_0001_0000_00000_000_00000_0001111 )
