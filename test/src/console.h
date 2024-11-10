#ifndef RISCV_CONSOLE_H
#define RISCV_CONSOLE_H

#include <stdint.h>
#include <stdio.h>
#include <string.h>


#define CON_ADDR 0xFFFFFFF1

void write_char_to_console(const char data)
{
  *((char *)CON_ADDR) = data;
}

void write_str_to_console(const char *data, const size_t len)
{
  
  for (int i = 0; i < len; i++)
  {
    write_char_to_console(data[i]);
  }
}

void write_strn_to_console(const char *data)
{
  write_str_to_console(data, strlen(data));
}

#endif
