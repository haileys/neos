#include "multiboot.h"
#include "paging.h"
#include "types.h"

extern int end_of_image;

void
panic(const char* msg)
{
    char* vram = (char*)0xb8000;
    while(*msg) {
        *vram++ = *msg++;
        *vram++ = 0x4f; // white on red
    }
    __asm__("cli \n hlt");
}

void
kmain(multiboot_info_t* mb, uint32_t magic)
{
    if(magic != 0x2badb002) {
        panic("bad magic multiboot number");
    }

    reserve_phys_to((phys_t)&end_of_image);

    for(size_t i = 0; i < mb->mods_count; i++) {
        multiboot_module_t* mods = (void*)mb->mods_addr;
        reserve_phys_to(mods[i].mod_end);
    }

    init_paging();

    panic("ok!");
}
