#include <iostream> 


extern "C" {
  void connect(); 
}

int 
main(void) {
  std::cout << "Hello, World! from C++" << std::endl;
  /* zig function */
  connect();

  return 0;
}
