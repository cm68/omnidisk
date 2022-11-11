#
# this makefile will break horribly if you have a case-insensitive file system.
#
all: BIOS.HEX MONITOR.HEX

clean: 
	rm -f bios.asm bios.hex bios.prn monitor.hex monitor.prn monitor.asm

clobber: clean
	rm -f BIOS.HEX MONITOR.HEX

BIOS.HEX: BIOS.ASM
	cp BIOS.ASM bios.asm
	zxcc ASM bios
	mv bios.hex BIOS.HEX
	rm -f monitor.asm

MONITOR.HEX: MONITOR.ASM
	cp MONITOR.ASM monitor.asm
	zxcc ASM monitor
	mv monitor.hex MONITOR.HEX
	rm -f monitor.asm
