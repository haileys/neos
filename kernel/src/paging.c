#include "paging.h"
#include "types.h"

static phys_t allocatable_begin;

static phys_t next_free_page;

static uint32_t page_directory[1024] __attribute__((aligned(4096)));

void
reserve_phys_to(phys_t address)
{
    // round up to the nearest page
    address += PAGE_SIZE - (address % PAGE_SIZE);

    if(address > allocatable_begin) {
        allocatable_begin = address;
    }
}

void
register_phys_region(phys_t start, size_t size)
{
    for(size_t offset = 0; offset + PAGE_SIZE <= size; offset += PAGE_SIZE) {
        phys_t address = start + offset;

        if(address < allocatable_begin) {
            continue;
        }

        *(phys_t*)address = next_free_page;
        next_free_page = address;
    }
}

void
init_paging()
{
    // identity map kernel
    for(phys_t addr = 0; addr < allocatable_begin; addr += PAGE_SIZE) {
        size_t page_dir_i = (addr / PAGE_SIZE) / 1024;
        size_t page_tab_i = (addr / PAGE_SIZE) % 1024;

        uint32_t* page_table;

        if(!page_directory[page_dir_i]) {
            // allocate page table
            page_table = (uint32_t*)next_free_page;
            next_free_page = *(phys_t*)next_free_page;
            // add to page directory
            page_directory[page_dir_i] = (phys_t)page_table | PE_PRESENT | PE_READ_WRITE;
        } else {
            page_table = (uint32_t*)(page_directory[page_dir_i] & PE_ADDR_MASK);
        }

        page_table[page_tab_i] = addr | PE_PRESENT | PE_READ_WRITE;
    }

    // recursively map page directory
    page_directory[1023] = (phys_t)&page_directory | PE_PRESENT | PE_READ_WRITE;

    // load page directory
    __asm__("mov cr3, %0" :: "r"(page_directory));

    // enable paging
    uint32_t cr0;
    __asm__("mov %0, cr0" : "=r"(cr0));
    cr0 |= (1 << 31); // paging enabled
    __asm__("mov cr0, %0" :: "r"(cr0) : "memory");
}
