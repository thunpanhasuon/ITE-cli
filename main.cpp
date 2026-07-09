#include <iostream> 


extern "C" {
  void connect(); 
}

int 
main(void) {
  std::cout << "Hello, World! from C++" ;
  return 0;
}
