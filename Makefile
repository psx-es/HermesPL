PPU_CC = ppu-gcc
PPU_OBJCOPY = ppu-objcopy

FIRMWARES = 3.55 3.41

PAYLOADS = hermes.bin

FIRMWARES_EXT=$(FIRMWARES:3.%=3_%)
PAYLOADS_EXT = $(foreach fw,$(FIRMWARES_EXT), \
	$(foreach pl,$(PAYLOADS),$(pl:%.bin=%_$(fw).bin)))

ALL_PAYLOADS = $(PAYLOADS_EXT)

all: $(ALL_PAYLOADS)
	echo "Payloads: $(PAYLOADS_EXT)"

%_3_41.o : %.S
	$(PPU_CC) $(PPU_CFLAGS) -DFW_341 -c $< -o $@
%_3_55.o : %.S
	$(PPU_CC) $(PPU_CFLAGS) -DFW_355 -c $< -o $@

%.o : %.S
	$(PPU_CC) -c $< -o $@

%.bin : %.o
	$(PPU_OBJCOPY) -O binary $< $@

clean:
	rm -f *.o *.bin
