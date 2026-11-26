#include <iostream>

#include "mmath.h"

int main() {
    std::cout << "add(2, 3) = " << add(2, 3) << std::endl;
#ifdef DEBUG
    std::cout << "DEBUG defined" << std::endl;
#endif
    return 0;
}
