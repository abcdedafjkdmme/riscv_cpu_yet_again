#include <stdint.h>

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


int main(){
  *((int*)0) = 0xDEADBEEF;
  int fib_result = fib(6);
  *((int*)0) = fib_result;
  while(1){;}

}

