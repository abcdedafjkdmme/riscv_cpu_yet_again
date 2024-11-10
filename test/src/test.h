#ifndef RISCV_TEST_H
#define RISCV_TEST_H


#include <stdint.h>
#include <string.h>
#include "console.h"
#include "shutdown.h"

int fib(int n)
{
  if (n == 0)
  {
    return 0;
  }
  else if (n == 1)
  {
    return 1;
  }
  else
  {
    return fib(n - 1) + fib(n - 2);
  }
}

int test_write_16b(size_t addr,uint16_t write_val){
  *((uint16_t*)addr) = write_val;
  uint16_t read = *((uint16_t*)addr);
  if(read != write_val){
    *((uint32_t*)0) = 0xFFFFFFFF;
    return -1;
  }
  return 0;
}

int riscv_test()
{
  uint16_t err = 0;

  *((int *)0) = 0x23DE;
  int fact_result = fib(7);
  *((int *)0) = fact_result;
  if (fact_result != 13){
    write_strn_to_console("ERROR fib unsuccessful \n");
    err = 1;
  }

  *((uint32_t*)0) = 0xDEADBEEF;

  int write_err = test_write_16b(3,0xA211);
  if(write_err != 0){
    *((uint32_t*)0) = 0xFFFFFFFF;
    write_strn_to_console("ERROR 16 bit write unsuccessful \n");
    err = 1;
  }
  return err;
}

#endif