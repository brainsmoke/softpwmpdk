


TARGET13_8BIT=leddriver8bit-pms150c.ihx
TARGET14_8BIT=leddriver8bit-pfs154.ihx

TARGET13_12BIT=leddriver12bit-pms150c.ihx
TARGET14_12BIT=leddriver12bit-pfs154.ihx

TARGET13_16BIT=leddriver16bit-pms150c.ihx
TARGET14_16BIT=leddriver16bit-pfs154.ihx

TESTS=lowbits16_test-pdk14.ihx

TARGETS=$(TARGET13_8BIT) $(TARGET14_8BIT) \
        $(TARGET13_12BIT) $(TARGET14_12BIT) \
        $(TARGET13_16BIT) $(TARGET14_16BIT)

CLEAN=$(TARGETS)
DEPS=softpwm8.asm pdk.asm uart.asm softpwm12.asm uart2.asm delay.asm softpwm16.asm settings.asm

DEVICE=/dev/ttyACM0

AS13=sdaspdk13
AS14=sdaspdk14

PROG=easypdkprog

NAME13=PMS150C
NAME14=PFS154

INC13=-Idevice/pms150c
INC14=-Idevice/pfs154

ADDRESS=0

.PHONY: write13 erase13 write14 erase14

all: $(TARGETS)

clean:
	-rm $(CLEAN)
	-rm *.ihx *.cdb *.lst *.map *.rel *.rst *.sym

%-pms150c.rel: %.asm $(DEPS)
	$(AS13) $(INC13) -s -o -l $@ $<

%-pfs154.rel: %.asm $(DEPS)
	$(AS14) $(INC14) -s -o -l $@ $<

%.ihx: %.rel
	sdldpdk -muwx -g INDEX=$$(($(ADDRESS)*3)) -i $@ -Y $< -e
	-rm $(@:.ihx=.cdb) $(@:.ihx=.lst) $(@:.ihx=.map) $(@:.ihx=.rel) $(@:.ihx=.rst) $(@:.ihx=.sym)

erase13:
	$(PROG) -p $(DEVICE) -n $(NAME13) erase

erase14:
	$(PROG) -p $(DEVICE) -n $(NAME14) erase

write8_13: $(TARGET13_8BIT)
	$(PROG) -p $(DEVICE) -n $(NAME13) write $(TARGET13_8BIT)

write8_14: $(TARGET14_8BIT)
	$(PROG) -p $(DEVICE) -n $(NAME14) write $(TARGET14_8BIT)


write12_13: $(TARGET13_12BIT)
	$(PROG) -p $(DEVICE) -n $(NAME13) write $(TARGET13_12BIT)

write12_14: $(TARGET14_12BIT)
	$(PROG) -p $(DEVICE) -n $(NAME14) write $(TARGET14_12BIT)


write16_13: $(TARGET13_16BIT)
	$(PROG) -p $(DEVICE) -n $(NAME13) write $(TARGET13_16BIT)

write16_14: $(TARGET14_16BIT)
	$(PROG) -p $(DEVICE) -n $(NAME14) write $(TARGET14_16BIT)


