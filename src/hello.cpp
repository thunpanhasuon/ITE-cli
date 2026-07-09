#include <iostream>

extern "C" void cpp_hello() {
    std::cout << "Hello from C++" << std::endl;
}
