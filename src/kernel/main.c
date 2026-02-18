/*
    * main.c
    * starryband
    * 02/17/2026
    * 
    * Entry point for the kernel.
*/

#include "print.h"

void kernel_main() {
    cls();
    print_string("Droid loading", 0x0F);
}