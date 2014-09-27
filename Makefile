.PHONY: all clean

ifeq ($(shell uname),Darwin)
$(error Cowardly refusing to run on Mac OS X)
endif

all: hdd.img

clean:
	rm -f hdd.img

hdd.base.img: hdd.base.img.gz
	gzip -dc $< > $@

hdd.img: hdd.base.img kernel/neos
	cp hdd.base.img hdd.img
	MTOOLSRC=mtoolsrc mcopy boot/grub/menu.lst C:/boot/grub/menu.lst
	MTOOLSRC=mtoolsrc mcopy kernel/neos C:/neos

.PHONY: kernel/neos
kernel/neos:
	make -C kernel neos
