# Requirements

### For building the firmware
- riscv gnu toolchain (march=rv32i mabi=ilp32)
- xxd 
### For viewing waveforms
- gtkwave 
### For simulating with iverilog
- iverilog
### For simulating with verilator
- verilator
### For synthesizing for lattice ice40 fpgas
- yosys
- nextpnr-ice40
- icepack

## Synthesize for lattice ic40 fpgas
```sh
make synth
```

## Simulate using iverilog

```sh
make
```

## Simulate using verilator

```sh 
mkdir build
cd build
cmake ..
cmake --build .
./fpga_playground
```