OBJECTS = src/loader.o src/main.o src/paging.o

CFLAGS = \
	-Wall -Wextra -pedantic -Werror -nostdlib -nostdinc -fno-builtin \
	-nostartfiles -nodefaultlibs -fno-exceptions -ffreestanding \
	-fno-stack-protector -fno-pic -std=c99 -m32 -iquote inc -masm=intel

neos: linker.ld $(OBJECTS)
	ld -o $@ -T linker.ld $(OBJECTS)

.PHONY: clean
clean:
	rm -f neos $(OBJECTS)

%.o: %.asm
	nasm -felf -o $@ $<

%.o: %.c
	gcc $(CFLAGS) -o $@ -c $<
