#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include "console.h"
#include "shutdown.h"
#include "test.h"


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




int main()
{

  write_str_to_con(ascii_art);
  write_str_to_con("\n");
  write_str_to_con(ascii_art_2);
  write_str_to_con("\n");


  
  uint16_t arr[3] = {1,3,0};

  
  riscv_test();

  char str[20];
  sprintf(str, "%d", 42);
  write_str_to_con("\n");
  write_str_to_con(str);
  write_str_to_con("\n");

  write_str_to_con("Cpu Ended Successfully\n");
  riscv_shutdown();
  write_str_to_con("ERR this shouldnt print \n");
  while (1)
  {
    ;
  }
}
