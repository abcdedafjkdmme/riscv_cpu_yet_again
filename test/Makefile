SHELL = /bin/sh
ARCH = riscv32-unknown-elf
CC = $(ARCH)-gcc
LD = $(ARCH)-ld
OBJCOPY = $(ARCH)-objcopy
IDIR = inc
SDIR = src
BDIR = build
CFLAGS = -Wall -march=rv32i -mabi=ilp32 -g -I $(IDIR) -O0
SFLAGS = $(CFLAGS)
LDFLAGS = 
OBJCOPY	=  $(ARCH)-objcopy
S_SRCS 	=  $(wildcard $(SDIR)/*.s)
C_SRCS 	=  $(wildcard $(SDIR)/*.c)
S_OBJS 	=  $(S_SRCS:$(SDIR)/%.s=$(BDIR)/%_asm.o)
C_OBJS 	=  $(C_SRCS:$(SDIR)/%.c=$(BDIR)/%.o)

all: clean kernel.txt

kernel.txt : kernel.hex 
	$(OBJCOPY) -I binary -O binary --reverse-bytes=4  kernel.hex kernel_big_endian.hex
	xxd -ps -c 4 kernel_big_endian.hex > kernel.txt 

kernel.hex: kernel.elf
	$(OBJCOPY) kernel.elf -O binary kernel.hex

kernel.elf: $(S_OBJS) link.ld $(C_OBJS)
	$(LD) $(LDFLAGS) -T link.ld -o kernel.elf $(S_OBJS) $(C_OBJS)

$(BDIR)/%.o: $(SDIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BDIR)/%_asm.o: $(SDIR)/%.s
	$(CC) $(SFLAGS) -c $< -o $@

clean:
	rm -f $(BDIR)/*_asm.o $(BDIR)/*.o kernel.elf kernel.img
