.PHONY: clean

OBJECTS = loader.o

neos: linker.ld $(OBJECTS)
	ld -o $@ -T linker.ld $(OBJECTS)

clean:
	rm -f neos $(OBJECTS)

%.o: %.asm
	nasm -felf -o $@ $<
