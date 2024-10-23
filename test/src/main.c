int fib(int n);

int main(){
  int a = fib(10);
  *((int*)0x0) = a;
  while(1==1){
    ;
  }
}

int fib(int n){
  if(n%2 == 0){
    return 1;
  }
  else return 0;
}