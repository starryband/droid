ENTRY(_start)

SECTIONS
{
    /* Traditional loading address for kernels */
    . = 1M;

    .text :
    {
        /* Ensure Multiboot header is at the very beginning */
        KEEP(*(.multiboot))
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.common)
        *(.bss)
    }
}