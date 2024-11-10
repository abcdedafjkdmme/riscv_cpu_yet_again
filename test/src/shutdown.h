#ifndef RISCV_SHUTDOWN_H
#define RISCV_SHUTDOWN_H


#include <stdint.h>

#define SHUTDOWN_ADDR 0xFFFFFFF2

void riscv_shutdown(){
  *((uint16_t*)SHUTDOWN_ADDR) = 1;
}

#endif 