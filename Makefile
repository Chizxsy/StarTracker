# target files
MCU = at90usb1286
TARGET = stepper

TOOLCHAIN_DIR := $(HOME)/toolchains/avr8-gnu-toolchain-darwin_x86_64

# toolchain
CC = $(TOOLCHAIN_DIR)/bin/avr-gcc
OBJCOPY = $(TOOLCHAIN_DIR)/bin/avr-objcopy
AVR_INCLUDE_PATH = $(TOOLCHAIN_DIR)/avr/include
# build rules

all: $(TARGET).hex

# assemble .asm to .o object file
%.o: %.S
	$(CC) -mmcu=$(MCU) -I $(AVR_INCLUDE_PATH) -c -o $@ $<

# link .o to .elf 
%.elf: %.o
	$(CC) -mmcu=$(MCU) -nostartfiles -o $@ $<

# create hex programming file
%.hex: %.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

# clean
clean: 
	rm -f *.o *.elf *.hex

.PHONY: all clean