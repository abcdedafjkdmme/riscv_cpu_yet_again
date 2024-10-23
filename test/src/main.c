int fib(int n);
int mult(int a,int b);

int f[3] = {10,2,3};

int main(){
  //int ark = mult(2,3);
  //*((int*)1000) = ark;
  //int a = fib(10);
 // *((int*)(0x0)) = a;
  //*((int*)(0x4)) = f[0];
  *((int*)(0x8)) = mult(21,33);
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

int mult(int a, int b){
  return a*b;
}