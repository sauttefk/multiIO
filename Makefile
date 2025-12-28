# Makefile - use gpasm/gplink (gputils) to assemble PIC16F946 project
# Replace NetBeans/MPASM workflow with gpasm/gplink.
#
# Note: Initial "multiIO.o: No such file or directory" error is cosmetic -
# make evaluates dependencies before executing rules. Build completes successfully.

AS := gpasm
LD := gplink
PART ?= 16F946
DEVICE_ID ?= 0x01
LKR_PATH ?= /usr/local/share/gputils/lkr
LKR_FILE ?= $(LKR_PATH)/16f946_g.lkr
ASM := src/main.asm
OBJ := $(ASM:.asm=.o)
HEX := build/multiIO.device$(DEVICE_ID).hex
LST := $(ASM:.asm=.lst)

.PHONY: all build clean lst help
.NOTPARALLEL:

all: build

build: $(HEX)

$(HEX): $(ASM)
	@mkdir -p build
	$(AS) -p $(PART) -w 2 -D device=$(DEVICE_ID) -I inc -I src -o build/multiIO $<
	@mv build/multiIO.hex $(HEX)

lst: $(LST)

%.lst: %.asm
	$(AS) -p $(PART) -l -I inc -I src -o /dev/null $< -L $@

clean:
	rm -rf build
	rm -f *.o *.hex *.cof *.cod *.lst *.map *.sym *.eep

help:
	@echo "Makefile - builds with gpasm/gplink"
	@echo "Usage: make                    - Build device 0x01 (default)"
	@echo "       make DEVICE_ID=0x05   - Build specific device ID"
	@echo "Override LKR_PATH for different installations:"
	@echo "  make LKR_PATH=/path/to/gputils/lkr"
	@echo ""
	@echo "Additional targets:"
	@echo "  make all-devices  - Build hex files for all device IDs"

all-devices:
	@./build-all.sh
