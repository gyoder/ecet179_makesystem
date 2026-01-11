#include <avr/io.h> // Includes AVR functions for the MCU
#include <stdint.h>

#include "library_a.h"


int main() {
  uint32_t num = 5;
  uint32_t cooler_num = add_cool_number(num);
}
