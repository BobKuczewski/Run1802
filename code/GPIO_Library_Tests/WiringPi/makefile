all: all_blink all_off all_on blink blink_pin find_pin_w29 find_pins pin20_to_pin21

all_blink: all_blink.c makefile
	gcc -o all_blink all_blink.c -lwiringPi

all_off: all_off.c makefile
	gcc -o all_off all_off.c -lwiringPi

all_on: all_on.c makefile
	gcc -o all_on all_on.c -lwiringPi

blink: blink.c makefile
	gcc -o blink blink.c -lwiringPi

blink_pin: blink_pin.c makefile
	gcc -o blink_pin blink_pin.c -lwiringPi

find_pin_w29: find_pin_w29.c makefile
	gcc -o find_pin_w29 find_pin_w29.c -lwiringPi

find_pins: find_pins.c makefile
	gcc -o find_pins find_pins.c -lwiringPi

pin20_to_pin21: pin20_to_pin21.c makefile
	gcc -o pin20_to_pin21 pin20_to_pin21.c -lwiringPi

clean:
	rm -f all_blink      
	rm -f all_off
	rm -f all_on
	rm -f blink
	rm -f blink_pin
	rm -f find_pin_w29
	rm -f find_pins
	rm -f pin20_to_pin21
