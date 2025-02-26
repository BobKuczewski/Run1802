all: \
	blink.hex \
	Draw4.hex \
	DrawBox.hex \
	DrawStairs.hex \
	Subtraction.hex \
	DrawQix.hex \
	fib.hex

%.hex: %.asm makefile
	a18 $< -o $@ -l list.txt

clean:
	rm -f *.hex
	rm -f list.txt

