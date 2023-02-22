# Run 1802

![Screen Shot](/docs/images/Run_1802.png?raw=true "Timing Diagram")

This project contains the software needed to run an RCA 1802 processor under direct control of a Raspberry Pi computer.

The standard configuration has the Raspberry Pi's GPIO pins connected to various 1802 processor pins - especially the 1802's clock pin. This allows the Raspberry Pi to clock the 1802 and interact with the 1802 on a clock by clock basis. In some configurations, the Raspberry Pi might just observe and optionally store the 1802's pin values. In other configurations, the Raspberry Pi might control the entire environment of the 1802 (memory, I/O, interrupts, etc). There could also be configurations where the Raspberry Pi controls some portions of the interface but not all.

## Hardware Needed

This software should run on any modern Raspberry Pi computer containing the standard configuration of 40 pins supporting GPIO communications. 

## Use
This project can be used for a number of purposes. The most obvious use is to learn programming on an actual 1802. Another use would be to test 1802 processors in a controlled environment. The project might also be used to aid in designing 1802 systems where some portions of the system are real hardware while others are being simulated until their design is finalized.

## Running
The main program is run from the command line in Python with:

    python Run_1802.py [options]

Where "options" are:

    h=hex   to run raw hex code from command
    f=file  to run a file (in plain hex format)
    n=#     to specify number of clocks to run
    d       to dump every pin while running
    dm      to dump non-zero memory after run
    p       to drop into Python after running
    js      to save output in data.js

For example, to run the classic blinking Q light program, enter this:

    python Run_1802.py h=7A7B3000

The Run_1802 program will read that input into the first 4 memory locations of its virtual 1802 RAM, reset the 1802, and then begin clocking the 1802's CLK pin at a relatively constant (but currently very slow) rate. As the 1802 fetches each instruction, the Run_1802 program will decode the address lines, look up the current value of RAM at that location, and serve up the proper byte to the shared data bus. The 1802 processor will literally be running that program. The Run_1802 program responds to memory reads by producing values from its 64K internal memory, and it similarly responds to memory writes by storing values into its 64K internal memory.

While typing in a hex program on the command line can be very handy, it's much more common to have a program file available. The file is specified with the f=filename option. The format of the file is a simple stream of 2 digit hex characters per byte of 1802 memory. Spaces and carriage returns are ignored, and semicolons begin comments. So the following file should be recognized:

    ; Blink and repeat
    
    7a     ; REQ Turn on the Q output
    7b     ; SEQ Turn on the Q output
    30 00  ; BR 00 Branch back and repeat

Here's another example that produces the first few numbers of the Fibonacci sequence:

    F8 00 ; LDI 0
    BA    ; PHI A
    BB    ; PHI B
    BC    ; PHI C
    F8 1A ; LDI 1A
    AA    ; PLO A
    F8 1B ; LDI 1B
    AB    ; PLO B
    F8 00 ; LDI 0
    AC    ; PLO C
    EA    ; SEX A
    F4    ; ADD
    5A    ; STR A
    64    ; OUT 4
    2A    ; DEC A
    EB    ; SEX B
    F4    ; ADD
    5B    ; STR B
    64    ; OUT 4
    2B    ; DEC B
    30 0E ; BR 0E
    00    ; FIB 0 2 4 6 8 ...
    01    ; FIB 1 3 5 7 9 ...

As shown in the Fibonacci example, the Run_1802 program directly supports the "64" (OUT 4) instruction. When the 1802 writes a byte to port 4 with "64", the Run_1802 program prints that value (currently in decimal) to the terminal screen where the program was run. The current version will print whenever the N2 bit set (4,5,6,7), but future versions may use different ports for different purposes.

