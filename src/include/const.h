/*
    * const.h
    * starryband
    * 02/17/2026
    * 
    * Defines constants and enums for the kernel.
*/

#pragma once
#include <stdint.h>

enum vga_color {
    VGA_COLOR_BLACK = 0,
    VGA_COLOR_BLUE = 1,
    VGA_COLOR_GREEN = 2,
    VGA_COLOR_CYAN = 3,
    VGA_COLOR_RED = 4,
    VGA_COLOR_MAGENTA = 5,
    VGA_COLOR_BROWN = 6,
    VGA_COLOR_LIGHT_GREY = 7,
    VGA_COLOR_DARK_GREY = 8,
    VGA_COLOR_LIGHT_BLUE = 9,
    VGA_COLOR_LIGHT_GREEN = 10,
    VGA_COLOR_LIGHT_CYAN = 11,
    VGA_COLOR_LIGHT_RED = 12,
    VGA_COLOR_LIGHT_MAGENTA = 13,
    VGA_COLOR_LIGHT_BROWN = 14,
    VGA_COLOR_WHITE = 15
};

#define SHIFT_PRESSED_LEFT 0x2A
#define SHIFT_PRESSED_RIGHT 0x36
#define SHIFT_RELEASED_LEFT 0xAA
#define SHIFT_RELEASED_RIGHT 0xB6

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_COLOR VGA_COLOR_WHITE