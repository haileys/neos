#include "multiboot.h"
#include "types.h"

static void
panic(const char* msg)
{
    char* vram = (char*)0xb8000;
    while(*msg) {
        *vram++ = *msg++;
        *vram++ = 0x4f; // white on red
    }
    for(;;);
}

void
kmain(multiboot_info_t* mb, uint32_t magic)
{
    if(magic != 0x2badb002) {
        panic("bad magic multiboot number");
    }

    (void)mb;

    for(;;);
}
