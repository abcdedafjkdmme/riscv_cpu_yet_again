#include <stdint.h>
#include <stdio.h>

int fib(int n){
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

// int fact(int n){
//   if(n == 1) return 1;
//   else return n * fact(n-1);
// }


int main(){
  //*((int*)0) = 0xDEADBEEF;
  ////*((uint8_t*)0) = 0x04;
  //*((uint8_t*)0) = 0x35;
  //*((uint8_t*)1) = 0x11;
  //*((uint8_t*)2) = 0x99;
  //int fib_result = fib(4);
  *((uint16_t*)0) = 0x23DE;
  int fact_result = fib(5);
  *((uint16_t*)0) = fact_result;
  float a = 4.223;
  float b = 32.423;
  float res = b / a;
  *((float*)4) = res;
  while(1){;}

}

