# target files
MCU = at90usb1286
TARGET = stepper
F_CPU = 16000000UL

# Toolchain (assumes it's in your system's PATH)
CC = avr-gcc
OBJCOPY = avr-objcopy

# Flags
CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Wall -Os
ASFLAGS = -x assembler-with-cpp # This is the crucial flag

# build rules
all: $(TARGET).hex

# Link .o to .elf
$(TARGET).elf: $(TARGET).o
	$(CC) $(CFLAGS) -o $@ $<

# Assemble .S to .o object file
$(TARGET).o: $(TARGET).S
	$(CC) $(CFLAGS) $(ASFLAGS) -c -o $@ $<

# Create hex programming file from .elf
%.hex: %.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@

# Clean build artifacts
clean:
	rm -f *.o *.elf *.hex

.PHONY: all clean
