#include <stdint.h>

uint16_t fib(uint16_t n){
  if(n == 0){
    return 0;
  }
  else if(n == 1){
    return 1;
  }
  else{
    return fib(n-1) + fib(n-2);
  }
}


int main(){
  *((uint32_t*)100) = 0xFFFFFFFF;
  uint16_t fib_result = fib(10);
  *((uint32_t*)100) = fib_result;
  while(1){;}

}

