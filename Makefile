MCU = at90usb1286
F_CPU = 16000000UL
PROGRAMMER = tinyusb
AVRDUDE_MCU = usb1286

# target files
TARGET = stepper
SRC = $(TARGET).asm

# toolchain
AS = avr-as
CC = avr-gcc
OBJCOPY = avr-objcopy
AVRDUDE = avrdude

# build rules

all: $(TARGET).hex

# assemble .asm to .o object file
%.o: %.asm
	$(AS) -mmcu=$(MCU) -o $@ $<

# link .o to .elf 
%.elf: %.o
	$(CC) -mmcu=$(MCU) -o $@ $<

# create hex programming file
%.hex: %.elf
	$(OBJCOPY) -O ihex -R .eeprom $< $@


# flash hex file
flash: all
	$(AVRDUDE) -c $(PROGRAMMER) -p $(AVRDUDE_MCU) -U flash:w:$(TARGET).hex:i

# clean
clean: 
	rm -f *.o *.elf *.hex

.PHONY: all flash clean