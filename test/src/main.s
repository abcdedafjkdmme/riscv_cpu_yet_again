.section .text
.globl _start
_start:
  la sp, stack_top
  j _start