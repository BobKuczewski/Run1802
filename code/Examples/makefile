all: \
	blink.hex \
	Draw4.hex \
	DrawBox.hex \
	DrawStairs.hex \
	Subtraction.hex \
	QixMono.hex \
	QixColor.hex \
	DrawQix.hex \
	CountUpDown.hex \
	CountUpDownSub.hex \
	CountUpDownSubX4.hex \
	fib.hex

%.hex: %.asm makefile
	a18 $< -o $@ -l list.txt

clean:
	rm -f *.hex
	rm -f list.txt

