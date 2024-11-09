#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <console.h>

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

int _write(int handle, char *data, int size)
{
  int count;

  handle = handle; // unused

  for (count = 0; count < size; count++)
  {
    write_char_to_console(data[count]); // Your low-level output function here.
  }

  return count;
}

const char *ascii_art = R""""(
$$$$$$$\   $$$$$$\   $$$$$$\ $$$$$$$$\ $$$$$$\ $$\   $$\  $$$$$$\  
$$  __$$\ $$  __$$\ $$  __$$\\__$$  __|\_$$  _|$$$\  $$ |$$  __$$\ 
$$ |  $$ |$$ /  $$ |$$ /  $$ |  $$ |     $$ |  $$$$\ $$ |$$ /  \__|
$$$$$$$\ |$$ |  $$ |$$ |  $$ |  $$ |     $$ |  $$ $$\$$ |$$ |$$$$\ 
$$  __$$\ $$ |  $$ |$$ |  $$ |  $$ |     $$ |  $$ \$$$$ |$$ |\_$$ |
$$ |  $$ |$$ |  $$ |$$ |  $$ |  $$ |     $$ |  $$ |\$$$ |$$ |  $$ |
$$$$$$$  | $$$$$$  | $$$$$$  |  $$ |   $$$$$$\ $$ | \$$ |\$$$$$$  |
\_______/  \______/  \______/   \__|   \______|\__|  \__| \______/   
                                                                                               
)"""";

const char *ascii_art_2 = R""""(
$$$$$$$\  $$$$$$\  $$$$$$\   $$$$$$\   $$\    $$\ 
$$  __$$\ \_$$  _|$$  __$$\ $$  __$$\  $$ |   $$ |
$$ |  $$ |  $$ |  $$ /  \__|$$ /  \__| $$ |   $$ |
$$$$$$$  |  $$ |  \$$$$$$\  $$ |$$$$$$\\$$\  $$  |
$$  __$$<   $$ |   \____$$\ $$ |\______|\$$\$$  / 
$$ |  $$ |  $$ |  $$\   $$ |$$ |  $$\    \$$$  /  
$$ |  $$ |$$$$$$\ \$$$$$$  |\$$$$$$  |    \$  /   
\__|  \__|\______| \______/  \______/      \_/    
                                                                                                                                                 
  )"""";


#define SHUTDOWN_ADDR 0xFFFFFFF2

int main()
{

  write_strn_to_console(ascii_art);
  write_strn_to_console("\n");
  write_strn_to_console(ascii_art_2);
  write_strn_to_console("\n");

  //*((int*)0) = 0xDEADBEEF;
  ////*((uint8_t*)0) = 0x04;
  //*((uint8_t*)0) = 0x35;
  //*((uint8_t*)1) = 0x11;
  //*((uint8_t*)2) = 0x99;
  // int fib_result = fib(4);
  *((int *)0) = 0x23DE;
  int fact_result = fib(7);
  *((int *)0) = fact_result;
  if (fact_result == 13)
  {
    write_strn_to_console("fib successful \n");
  }

  float a = 4.223;
  float b = 32.423;
  float res = b / a;
  *((float *)4) = res;

  write_strn_to_console("ark bark \n");

  *((uint8_t*)SHUTDOWN_ADDR) = 1;

  write_strn_to_console("ERR this shouldnt print \n");

  while (1)
  {
    ;
  }
}
