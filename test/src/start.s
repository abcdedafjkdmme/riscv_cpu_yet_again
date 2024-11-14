.section .text
.globl _start
_start:
  la sp, stack_top
  j main
loop:
  j loop