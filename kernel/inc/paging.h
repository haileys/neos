#ifndef PAGING_H
#define PAGING_H

#include "types.h"

#define PAGE_SIZE 4096
#define PE_FLAG_MASK (PAGE_SIZE - 1)
#define PE_ADDR_MASK (~PE_FLAG_MASK)

typedef enum {
    PE_PRESENT    = 1 << 0,
    PE_READ_WRITE = 1 << 1,
    PE_USER       = 1 << 2,
}
page_flags_t;

void
reserve_phys_to(phys_t address);

void
register_phys_region(phys_t start, size_t size);

void
init_paging();

#endif
