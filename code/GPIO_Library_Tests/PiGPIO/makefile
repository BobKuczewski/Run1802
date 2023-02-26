all: blink pin20_to_pin21

blink: blink.c makefile
	gcc -o blink blink.c -lpigpio -lrt -lpthread

pin20_to_pin21: pin20_to_pin21.c makefile
	gcc -o pin20_to_pin21 pin20_to_pin21.c -lpigpio -lrt -lpthread

clean:
	rm -f blink      
	rm -f pin20_to_pin21
