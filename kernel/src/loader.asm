global loader
global end_of_image

extern kmain

section .multiboot_header
align 4
multiboot_header:
    dd 0x1badb002        ; magic
    dd 3                 ; flags
    dd -(0x1badb002 + 3) ; checksum = -(flags + magic)

section .text
align 4
loader:
    ; load gdt
    lgdt [gdtr]
    jmp 0x08:.flush_cs
.flush_cs:
    mov eax, 0x10
    mov ds, eax
    mov es, eax
    mov fs, eax
    mov gs, eax
    mov ss, eax

    ; remap IRQs to interrupts 0x20+
%macro outb 2
    mov al, %2
    out %1, al
%endmacro
    outb 0x20, 0x11
    outb 0xa0, 0x11
    outb 0x21, 0x20
    outb 0xa1, 0x28
    outb 0x21, 0x04
    outb 0xa1, 0x02
    outb 0x21, 0x01
    outb 0xa1, 0x01
    outb 0x21, 0x00
    outb 0xa1, 0x00
%unmacro outb 2

    mov esp, stack
    push eax ; multiboot magic number
    push ebx ; pointer to multiboot struct

    fninit
    mov eax, cr0
    or eax, 1 << 5  ; FPU NE bit
    mov cr0, eax

    push dword 0
    jmp kmain

gdtr:
    dw (gdt.end - gdt) - 1
    dd gdt

gdt:
    ; null entry:
    dq 0
    ; kernel code:
    dw 0xffff     ; limit 0-15
    dw 0x0000     ; base 0-15
    db 0x00       ; base 16-23
    db 0b10011010 ; access
    db 0xcf       ; flags (32 bit | 4kb granularity), limit 16-19
    db 0x00       ; base 24-31
    ; kernel data:
    dw 0xffff     ; limit 0-15
    dw 0x0000     ; base 0-15
    db 0x00       ; base 16-23
    db 0b10010010 ; access
    db 0xcf       ; flags (32 bit | 4kb granularity), limit 16-19
    db 0x00       ; base 24-31
    ; user code:
    dw 0xffff     ; limit 0-15
    dw 0x0000     ; base 0-15
    db 0x00       ; base 16-23
    db 0b11111010 ; access
    db 0xcf       ; flags (32 bit | 4kb granularity), limit 16-19
    db 0x00       ; base 24-31
    ; user data:
    dw 0xffff     ; limit 0-15
    dw 0x0000     ; base 0-15
    db 0x00       ; base 16-23
    db 0b11110010 ; access
    db 0xcf       ; flags (32 bit | 4kb granularity), limit 16-19
    db 0x00       ; base 24-31
.end:

idt:


section .bss
align 4
resb 65536
stack:

section .end_of_image
end_of_image:
