; --- Multiboot 2 Header ---
section .multiboot
align 8
header_start:
    dd 0xe85250d6                ; Magic number
    dd 0                         ; Architecture 0 (protected mode i386)
    dd header_end - header_start ; Header length
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)) ; Checksum
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:

section .bss
align 4096
p4_table: resb 4096
p3_table: resb 4096
p2_table: resb 4096
stack_bottom:
    resb 16384
stack_top:

section .text
bits 32
global _start
extern kernel_main

_start:
    mov esp, stack_top

    ; 1. Setup Paging (Identity map first 1GB)
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax

    mov eax, p2_table
    or eax, 0b11 ; present + writable
    mov [p3_table], eax

    ; Map each P2 entry to a huge 2MB page
    mov ecx, 0         ; counter
.map_p2_table:
    mov eax, 0x200000  ; 2MiB
    mul ecx
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; 2. Enable Paging & Long Mode
    mov eax, p4_table
    mov cr3, eax       ; Load P4 into CR3

    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Set Long Mode bit in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Enable Paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; 3. Load 64-bit GDT
    lgdt [gdt64.pointer]
    jmp gdt64.code:long_mode_start

bits 64
long_mode_start:
    ; 4. Now in 64-bit mode!
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    
    call kernel_main
    hlt

section .rodata
gdt64:
    dq 0 ; null descriptor
.code: equ $ - gdt64
    ; The "L" bit (bit 53) defines 64-bit code segment
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) 
.pointer:
    dw $ - gdt64 - 1
    dq gdt64