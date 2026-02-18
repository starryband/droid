/*
    * const.h
    * starryband
    * 02/17/2026
    * 
    * Declares functions for VGA text-mode output.
*/

#pragma once
#include <stdint.h>
#include <stdbool.h>

void cls();
void print_char(char c, int color);
void print_string(const char *str, int color);