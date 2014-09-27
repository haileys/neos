global loader
global end_of_image

extern kmain
extern panic

section .multiboot_header
align 4
multiboot_header:
    dd 0x1badb002        ; magic
    dd 3                 ; flags
    dd -(0x1badb002 + 3) ; checksum = -(flags + magic)

section .text
align 4
loader:
    cli

    ; setup kernel stack and push args before dirtying registers
    mov esp, stack
    push eax ; multiboot magic number
    push ebx ; pointer to multiboot struct

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

    ; setup idt entries
%macro idt_ent 2
    lea ebx, [idt + %1 * 8]
    mov eax, %2
    mov [ebx], ax
    mov [ebx + 2], word 0x08 ; kernel code segment
    mov [ebx + 4], byte 0    ; zero
    mov [ebx + 5], byte 0x8e ; interrupt gate
    shr eax, 16
    mov [ebx + 6], ax
%endmacro
    idt_ent 0, isr_divide_by_zero
    idt_ent 1, isr_debug
    idt_ent 2, isr_nmi
    idt_ent 3, isr_breakpoint
    idt_ent 4, isr_overflow
    idt_ent 5, isr_bound_range_exceeded
    idt_ent 6, isr_invalid_opcode
    idt_ent 7, isr_device_not_available
    idt_ent 8, isr_double_fault
    ; exception 9 is not used anymore, apparently
    idt_ent 10, isr_invalid_tss
    idt_ent 11, isr_segment_not_present
    idt_ent 12, isr_stack_segment_fault
    idt_ent 13, isr_general_protection_fault
%unmacro idt_ent 2

    ; load idt
    lidt [idtr]

    ; setup fpu
    fninit
    mov eax, cr0
    or eax, 1 << 5  ; FPU NE bit
    mov cr0, eax

    ; call into c
    push dword 0
    jmp kmain

gdtr:
    dw (gdt.end - gdt) - 1
    dd gdt

gdt:
%macro gdt_ent 4 ; base, limit, access, flags
    dw %2 & 0xffff
    dw %1 & 0xffff
    db (%1 >> 16) & 0xff
    db %3
    db (%4 << 4) | ((%2 >> 16) & 0xf)
    db (%1 >> 24) & 0xf
%endmacro
    ; null entry:
    dq 0
    ; kernel code:
    gdt_ent 0x00000000, 0xffffff, 0b10011010, 0xc ; (32 bit | 4kb granularity)
    ; kernel data:
    gdt_ent 0x00000000, 0xffffff, 0b10010010, 0xc ; (32 bit | 4kb granularity)
    ; user code:
    gdt_ent 0x00000000, 0xffffff, 0b11111010, 0xc ; (32 bit | 4kb granularity)
    ; user data:
    gdt_ent 0x00000000, 0xffffff, 0b11110010, 0xc ; (32 bit | 4kb granularity)
%unmacro gdt_ent 4
.end:

idt:
    times 256 dq 0
.end:

idtr:
    dw (idt.end - idt) - 1
    dd idt

isr_divide_by_zero:
    push .msg
    call panic
    .msg db "exception: divide by zero"

isr_debug:
    push .msg
    call panic
    .msg db "exception: debug"

isr_nmi:
    push .msg
    call panic
    .msg db "exception: non-maskable interrupt"

isr_breakpoint:
    push .msg
    call panic
    .msg db "exception: breakpoint"

isr_overflow:
    push .msg
    call panic
    .msg db "exception: overflow"

isr_bound_range_exceeded:
    push .msg
    call panic
    .msg db "exception: bound range exceeded"

isr_invalid_opcode:
    push .msg
    call panic
    .msg db "exception: invalid opcode"

isr_device_not_available:
    push .msg
    call panic
    .msg db "exception: device not available"

isr_double_fault:
    push .msg
    call panic
    .msg db "exception: double fault"

isr_invalid_tss:
    push .msg
    call panic
    .msg db "exception: invalid tss"

isr_segment_not_present:
    push .msg
    call panic
    .msg db "exception: segment not present"

isr_stack_segment_fault:
    push .msg
    call panic
    .msg db "exception: stack segment fault"

isr_general_protection_fault:
    push .msg
    call panic
    .msg db "exception: general protection fault"

section .bss
align 4
resb 65536
stack:

section .end_of_image
end_of_image:
