/*
    * print.c
    * starryband
    * 02/17/2026
    * 
    * Handles VGA text-mode functions for the kernel.
*/

#include "print.h"
#include "const.h"
#include "io.h"

volatile uint16_t *vga_buffer = (uint16_t *)0xB8000;

static uint16_t cursor_x = 0;
static uint16_t cursor_y = 0;

static void scroll() {
    if (cursor_y < VGA_HEIGHT)
        return;

    for (uint16_t y = 1; y < VGA_HEIGHT; y++) {
        for (uint16_t x = 0; x < VGA_WIDTH; x++) {
            vga_buffer[(y - 1) * VGA_WIDTH + x] =
                vga_buffer[y * VGA_WIDTH + x];
        }
    }

    for (uint16_t x = 0; x < VGA_WIDTH; x++) {
        vga_buffer[(VGA_HEIGHT - 1) * VGA_WIDTH + x] =
            (0x0F << 8) | ' ';
    }

    cursor_y = VGA_HEIGHT - 1;
}

void move_hardware_cursor(uint16_t pos) {
    outb(0x3D4, 0x0F);
    outb(0x3D5, (uint8_t)(pos & 0xFF));
    outb(0x3D4, 0x0E);
    outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

void set_cursor_shape(uint8_t start, uint8_t end) {
    outb(0x3D4, 0x0A);
    outb(0x3D5, start & 0x1F);
    outb(0x3D4, 0x0B);
    outb(0x3D5, end & 0x1F);
}

void cls() {
    for (uint16_t i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i] = (0x0F << 8) | ' ';
    }

    cursor_x = 0;
    cursor_y = 0;
}

void print_char(char c, int color) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        scroll();
        return;
    } else {
        uint16_t index = cursor_y * VGA_WIDTH + cursor_x;
        vga_buffer[index] = ((uint16_t)color << 8) | c;

        cursor_x++;

        if (cursor_x >= VGA_WIDTH) {
            cursor_x = 0;
            cursor_y++;
        }

        scroll();
    }

    move_hardware_cursor(cursor_y * VGA_WIDTH + cursor_x);
}

void print_string(const char *str, int color) {
    while (*str) {
        print_char(*str, color);
        str++;
    }
}