// Included Libraries
#include <stdint.h>
#include <avr/io.h>

// NEW LINE
#include "library_a.h"

// Function Definitions (where we tell it what the function does)
uint32_t add_cool_number(uint32_t num) {
    uint32_t new_num = num + COOL_NUMBER;
    return new_num;
}
