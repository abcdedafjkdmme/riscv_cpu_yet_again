SHELL = /bin/sh
ARCH = /opt/riscv/bin/riscv32-unknown-elf
CC = $(ARCH)-gcc
LD = $(ARCH)-ld
OBJDUMP = $(ARCH)-objdump
OBJCOPY = $(ARCH)-objcopy
IDIR = src
SDIR = src
BDIR = build
CFLAGS = -Wall -march=rv32i -mabi=ilp32 -g -I $(IDIR) -O0
SFLAGS = $(CFLAGS)
LDFLAGS = -lgcc -nostartfiles
OBJDUMPFLAGS = -D
OBJCOPY	=  $(ARCH)-objcopy
S_SRCS 	=  $(wildcard $(SDIR)/*.s)
C_SRCS 	=  $(wildcard $(SDIR)/*.c)
S_OBJS 	=  $(S_SRCS:$(SDIR)/%.s=$(BDIR)/%_asm.o)
C_OBJS 	=  $(C_SRCS:$(SDIR)/%.c=$(BDIR)/%.o)
S_OBJ_DUMPS = $(S_OBJS:$(BDIR)/%.o=$(BDIR)/%.o.dis)
C_OBJ_DUMPS = $(C_OBJS:$(BDIR)/%.o=$(BDIR)/%.o.dis)

all: kernel.txt

kernel.txt : kernel.hex 
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4 build/kernel.hex build/kernel_big_endian.hex
	xxd -ps -c 4 build/kernel_big_endian.hex > build/kernel.txt 

kernel.hex: kernel.elf kernel.elf.dis
	$(OBJCOPY) build/kernel.elf -O binary build/kernel.hex

kernel.elf.dis: kernel.elf
	$(OBJDUMP) $(OBJDUMPFLAGS) $(BDIR)/kernel.elf > $(BDIR)/kernel.elf.dis 

kernel.elf: link.ld $(S_OBJS) $(C_OBJS)  $(S_OBJ_DUMPS) $(C_OBJ_DUMPS) 
	$(CC) -T link.ld -o build/kernel.elf $(S_OBJS) $(C_OBJS)  $(LDFLAGS) 

$(BDIR)/%.o: $(SDIR)/%.c 
	$(CC) $(CFLAGS) -c $< -o $@

$(SDIR)/%.c : $(SDIR)/%.h 

$(BDIR)/%_asm.o: $(SDIR)/%.s
	$(CC) $(SFLAGS) -c $< -o $@

$(BDIR)/%.o.dis: $(BDIR)/%.o
	$(OBJDUMP) $(OBJDUMPFLAGS) $< > $@

clean:
	rm -f $(BDIR)/*
