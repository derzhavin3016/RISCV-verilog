//#include <iostream>
int fib(int n)
{
  int fst = 0, sec = 1;
  for (int i = 2; i < n; ++i)
  {
    int tmp = fst;
    fst = sec;
    sec = tmp + fst;
  }
  return sec;
}

int main()
{
  int res = fib(5);
  //std::cout << res << std::endl;
  asm("nop");
  asm("nop");
  asm("ecall");
}
