#include <iostream>

#include "my_math.h"

int main() {
    std::cout << "2 + 3 = " << add(2, 3) << std::endl;
#ifdef DEBUG
    std::cout << "built with -DDEBUG" << std::endl;
#endif
    return 0;
}
