all: \
	blink.hex \
	Draw4.hex \
	DrawBox.hex \
	DrawBoxColor.hex \
	DrawStairs.hex \
	Subtraction.hex \
	QixMono.hex \
	QixColor.hex \
	QixColorFull.hex \
	DrawColorLine.hex \
	DrawSquareSpiral.hex \
	DrawEnterprisePix.hex \
	DrawEnterprisePixBits.hex \
	CountUpDown.hex \
	CountUpDownSub.hex \
	CountUpDownSubX4.hex \
	fib.hex \
	fib_ROM.hex

%.hex: %.asm makefile
	a18 $< -o $@ -l list.txt

clean:
	rm -f *.hex
	rm -f list.txt

