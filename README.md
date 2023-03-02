# Run 1802

![Timing Diagram](/docs/images/Breadboard_Wiring_20230301.jpg?raw=true "Timing Diagram")

This project contains the software needed to run an RCA 1802 processor under direct control of a Raspberry Pi computer. Some of the background from this project can be found on the [COSMAC ELF Group web site](https://groups.io/g/cosmacelf). The following links have current and/or historical relevance:

* [1802 in "Pi Land"](https://groups.io/g/cosmacelf/topic/1802_in_pi_land/97002181)
* [1802 version of Ben Eater's 6502 "Hello World" series?](https://groups.io/g/cosmacelf/topic/1802_version_of_ben_eater_s/96397039)
* [RCA 1802 future and beyond](https://groups.io/g/cosmacelf/topic/rca_1802_future_and_beyond/96804574)
* [Bob Kay's 1802pi GitHub Site](https://github.com/Bob-Kay/1802pi)

The standard configuration for this project has the Raspberry Pi's GPIO pins connected to various 1802 processor pins - especially the 1802's clock pin. This allows the Raspberry Pi to clock the 1802 and interact with the 1802 on a clock by clock basis. In some configurations, the Raspberry Pi might just observe and optionally store the 1802's pin values. In other configurations, the Raspberry Pi might control the entire environment of the 1802 (memory, I/O, interrupts, etc). There could also be configurations where the Raspberry Pi controls some portions of the 1802 environment but not all.

## Hardware Needed

This software should run on any modern Raspberry Pi computer containing the standard configuration of 40 pins supporting GPIO communications. This program was developed for a Raspberry Pi Zero, but should also work with the Raspberry Pi 3, 3A+, 3B, 3B+, and 4B. Of course, you'll also need an 1802 processor and a means to properly connect them together (breadboard, wire wrap board, printed circuit board, etc). The software only relies on the libraries that come pre-installed with the Raspberry Pi operating system.

## Use

This project can be used for a number of purposes. The most obvious use is to learn machine level programming on an actual 1802 within the convenient environment of a Raspberry Pi computer. Another use would be to test 1802 processors in a controlled environment (see "Testing" section below). The project might also be a useful aid in designing 1802 systems where some portions of the system are real hardware while others are being simulated until their design is finalized. This software is open source, so you may adapt it as needed.

## Running

The main program is run from the command line in Python with:

    python Run_1802.py [options]

Where "options" are:

    h=hex   to run plain hex code from the command line
    f=file  to run a hex program of several possible formats
    n=#     to specify number of half-clocks to run
    d       to dump every pin while running
    dm      to dump non-zero memory after the run
    js      to save output in specialized data.js file
    p       to drop into Python after running
    help    to print out helpful information and exit

For example, to run the classic blinking Q light program, enter this:

    python Run_1802.py h=7A7B3000

The Run_1802 program will read that hex input (following "h=") into the first 4 memory locations of its virtual 1802 RAM, reset the 1802, clock the 1802's CLK pin a few cycles while in reset, and then switch to "Run" mode and continue clocking the 1802 at a relatively constant (but currently very slow) rate for a designated number of cycles. As the 1802 attempts to fetch each instruction, the Run_1802 program will decode the address lines, look up the current value of "RAM" at that location, and serve up the proper byte to the shared data bus. The 1802 processor will be running the program as it is being "spoon fed" by the Pi. The Run_1802 program responds to memory reads by producing values from its 64K internal memory, and it similarly responds to memory writes by storing values into its 64K internal memory.

The Run_1802 program also supports an interactive mode through the Python interpreter when the "p" option is given on the command line. The command line Python interpreter will be entered when Run_1802 has finished executing the "n=#" of half clocks specified on the command line. To start the Python interpreter immediately, use both options: "n=0" and "p". This tells Run_1802 to execute 0 clocks and then enter the Python interpreter when done. The Python interpreter supports examination and modification of the 1802's "RAM" as well as running any number of clock cycles interactively. See the "Python" section below for more details.

## File Formats

While entering a small hex program on the command line can be very handy, it's much more common to have a program file available. A program file can be specified with the f=filename option. Run_1802 supports 3 different file formats. The easist format is a simple stream of hex bytes (as in the last example of "7A7B3000"). This is known as "plain hex" format and files in this format are named ".phx". This is also the most practical format to enter on the command line. The second easiest format is "address hex" format with files named ".ahx". This is a superset of the plain hex format that allows an address field at the start of any line or on a line by itself. The address field must be terminated with a colon character (:) to distinguish it from data fields. Address fields are not required anywhere in an "address hex" file, but they can be added as needed to specify the starting points of segments of data and instructions. The most complex file format is "Intel Hex" format with files usually named ".hex". Intel Hex format is a widely adopted format and is [well documented on the web](https://en.wikipedia.org/wiki/Intel_HEX). Run_1802 can also read Intel Hex format files.

One of the advantages of the plain-hex and address-hex formats is that they both support comments following a semi-colon. This is extremely helpful for anyone coding in machine language. Of course, the biggest advantage of the Intel hex format is that it is generally produced by a real assembler and doesn't need comments in the machine code because the comments are in the source code.

This is an example of a simple plain hex file:

    7a7b3000

That same program could also be recognized by Run_1802 as follows (comments and white space are ignored):

    ; Blink and Repeat

    7a     ; REQ Turn off the Q output
    7b     ; SEQ Turn on the Q output
    30 00  ; BR 00 Branch back and repeat

In both cases, no addresses were given. The file just specified a list of bytes starting at 0 and going upward. But sometimes that's not very convenient. That's when adding an address can be handy. This example shows a very similar "blinking Q" program, but it jumps back and forth between two relatively far addresses.

    ; Blink, Branch, and Repeat

    00: 7a 30 40   ; REQ Turn off the Q output and jump to 40
    40: 7b 30 00   ; SEQ Turn on the Q output and jump back to 0

That program could have been written without addresses by simply filling in zeros (or anything) between memory locations 3 and 3f. But that would be a lot of code and it would obscure the simplicity of this little program.

Here's another "plain hex" example. This program produces the first few numbers of the Fibonacci sequence without using any addresses:

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

While not required in that example, numeric addresses could still be added to show branch targets and data fields:

          F8 00 ; LDI 0
          BA    ; PHI A  ... zero A
          BB    ; PHI B  ... zero B
          BC    ; PHI C  ... zero C (which is never used)
          F8 1A ; LDI 1A ... load the 1st "ping pong" address
          AA    ; PLO A  ... A will be used to write to 1A
          F8 1B ; LDI 1B ... load the 2nd "ping pong" address
          AB    ; PLO B  ... B will be used to write to 1B
          F8 00 ; LDI 0  ... Load a zero in C
          AC    ; PLO C  ... However, C isn't used. Oops.
    0E:   EA    ; SEX A  ... Use X to add from 1A
          F4    ; ADD    ... Add from A to accumulator
          5A    ; STR A  ... Store the result in 1A
          64    ; OUT 4  ... Display the 1A value
          2A    ; DEC A  ... Decrement after the output (which incremented)
          EB    ; SEX B  ... Use X to add from 1B
          F4    ; ADD    ... Add from B1 to the accumulator already holding 1A
          5B    ; STR B  ... Store the value in 1B
          64    ; OUT 4  ... Display the 1B value
          2B    ; DEC B  ... Decrement after the output (which incremented)
          30 0E ; BR 0E  ... Branch back to start again
    1A:   00    ; Variable will hold 0 2 4 6 8 ...
    1B:   01    ; Variable will hold 1 3 5 7 9 ...

This makes the program easier to read and understand. The addresses still had to be counted, but only once. After that, they're documented in the program. Note that Run_1802 will place (force) the bytes at those explicitly defined address fields to actually be located at those addresses - even if they overwrite existing code or data. Each line is processed sequentially, and the data is placed in memory sequentially until an address is encountered. Then the sequential placement process continues from that new point forward.

Of course, almost all serious work will require a real assembler (such as the [A18 assembler](http://www.retrotechnology.com/memship/a18.html) written by William C. Colley and maintained and improved by Herbert R. Johnson). The A18 assembler produces standardized "Intel Hex" format files. Here's the output of the A18 assembler after processing a source code file for the previous Fibonacci examples:

    :1C000000F800BABBBCF81AAAF81BABF800ACEAF45A642AEBF45B642B300E0001CF
    :00001C01E3

This is a very compact form and includes both address information and a checksum. Here's the source code for that program:

    Ra          EQU    10
    Rb          EQU    11
    Rc          EQU    12

    START       ORG    0H
                LDI 0
                PHI Ra
                PHI Rb
                PHI Rc
                LDI 1AH
                PLO Ra
                LDI 1BH
                PLO Rb
                LDI 0
                PLO Rc

    LOOP        SEX Ra
                ADD
                STR Ra
                OUT 4
                DEC Ra
                SEX Rb
                ADD
                STR Rb
                OUT 4
                DEC Rb
                BR        LOOP
                BYTE        0        ; FIB 0 2 4 6 8 ...
                BYTE        1        ; FIB 1 3 5 7 9 ...

                END

Ultimately, the Run_1802 program isn't at all concerned with how the machine code was generated. It's only job is to make loading that code as easy as possible and to run it on a real 1802 with helpful features like pin logging and single stepping.

## Input / Output

As shown in the previous Fibonacci example, the Run_1802 program directly supports the "64" (OUT 4) instruction. When the 1802 writes a byte to port 4 with "64", the Run_1802 program prints that value (currently in decimal) to the terminal screen where the program was run. The current version will print whenever the N2 bit is set (N=4,5,6,7), but future versions may use different ports for different purposes.

## Duration of Run

When run without specifying the number of clock ticks, the current version will attempt to execute one million clock edges before stopping. This can be changed by specifying the number of clock edges with the "n=#" command line parameter. The program can also be stopped gracefully with Control-C at any time.

## Saving 1802 Pin State

In addition to just running the target program, Run_1802 can also save the state of most of the 1802's pin values as it runs. These outputs are specified with the "d" and "js" options. The "d" option stands for "debug" or "data", and it will cause Run_1802 to print both a header and a space-separated row of 0's and 1's to the terminal as it runs. The header will be printed once, but a row of data will be printed for each clock level value. So the CLK output will always alternate between 0 and 1. All of the other values should reflect each pin's state while the clock was either high or low. This output will normally scroll to the screen, but it can also be redirected to a file or other process through your operating system's or shell's mechanisms. The "js" option is a bit more specialized. It produces a Javascript file named "data.js" containing both the header and the data to be automatically copied into the HTML elements named "timing_header_area" and "timing_data_area". This allows them to be processed by a Javascript program for visualization and analysis. The stub file "data.html" shows how the "data.js" file is included, and it contains the text areas to accept the data.

## Display and Python

The final two options are "dm" and "p". The "dm" option causes Run_1802 to "display memory" after the run has completed. It will always show the first 16 bytes of memory followed by any other bytes that were non-zero after the run. This is helpful since Run_1802 starts with all memory set to 0, so any non-zero values at any location can be seen with the "dm" option. The "p" option causes Run_1802 to drop into a Python shell after the run has completed. This supports interactive exploration of the results as well as direct interaction with the 1802 - be careful!!

## Testing

The Run_1802 program can also be easily used for testing 1802 processors. Simply write a test program - any test program - and run it one time with a known good 1802 while redirecting the output to a file. That file will be a complete history of all the pins captured by Run_1802 while the program was running. To test another processor, just do the same thing, but direct the output to another file. Then compare the files. They should be bit-for-bit identical. You can write test case programs to be as simple or complex as you need. Note, however, that Run_1802 is currently very very slow. So long test cases will take a very long time to run. Also note that the very slow clock rate will not reveal any defects that are related to running at higher speeds.

## Connecting

![1802 and Pi Zero](/docs/images/CDP1802_Raspberry_Pi_Zero.jpg?raw=true "1802 and Pi Zero")

The Run_1802 program is just software and it relies on a properly configured and connected 1802 and Raspberry Pi. Ensure that you have the appropriate skills and background before attempting to connect real hardware. Also use appropriate precautions when making connections. For example, the previous photograph shows a number of yellow wires that also contain an embedded resistor to limit the potential current flow between the 1802 and the Raspberry Pi. While such resistors shouldn't be needed, they are used to provide some (minimal) protection against miswiring or other unexpected conditions. Be sure to use good judgement when building any hardware project.

The current version contains both comments and code that describe the expected environment as shown from these snippets from Run_1802.py (note that there was an earlier version in February of 2023 which is NOT compatible with the current pin mapping):

Raspberry Pi pin definitions:

    # ======= Raspberry Pi =======
    # GPIO/Pin numbering (note that GPIO0/P27 only works as GPIO0)
    # Outer 2 values are GPIO 0-27 (BCM numbering)
    # Inner 2 values are pin number on Raspberry Pi connector (Board numbering)
    # +3 |1    2| +5
    #  2 |3    4| +5
    #  3 |5    6| G
    #  4 |7    8| 14
    #  G |9   10| 15
    # 17 |11  12| 18
    # 27 |13  14| G
    # 22 |15  16| 23
    # +3 |17  18| 24
    # 10 |19  20| G
    #  9 |21  22| 25
    # 11 |23  24| 8
    #  G |25  26| 7
    #  0 |27  28| 1
    #  5 |29  30| G
    #  6 |31  32| 12
    # 13 |33  34| G
    # 19 |35  36| 16
    # 26 |37  38| 20
    #  G |39  40| 21

RCA 1802 pin configurations:

    # ======== RCA 1802 ========
    #  Clock  1      40 VDD
    #  /WAIT  2      39 /XTAL
    # /CLEAR  3      38 /DMA IN
    #      Q  4      37 /DMA OUT
    #    SC1  5      36 /INTERRUPT
    #    SC0  6      35 /MWR
    #   /MRD  7      34 TPA
    #  Bus 7  8      33 TPB
    #  Bus 6  9      32 MA7
    #  Bus 5 10      31 MA6
    #  Bus 4 11      30 MA5
    #  Bus 3 12      29 MA4
    #  Bus 2 13      28 MA3
    #  Bus 1 14      27 MA2
    #  Bus 0 15      26 MA1
    #    Vcc 16      25 MA0
    #     N2 17      24 /EF1
    #     N1 18      23 /EF2
    #     N0 19      22 /EF3
    #    Vss 20      21 /EF4

Python code that connects each pin to a variable used by Run_1802:

    ##### Set Up the Pins #####

    GPIO.setmode(GPIO.BCM) # Use the Broadcom numbering shown on Pi ribbon connector plug.

    # Set up the CLOCK and /CLEAR and /INT as outputs for the Pi to control
    clock  = gpio_pin(26, gpio_pin.OUT, False)
    nclear = gpio_pin(19, gpio_pin.OUT, True)
    ndmai  = gpio_pin(21, gpio_pin.OUT, True)
    nint   = gpio_pin(20, gpio_pin.OUT, True)

    # Set up various indicators as inputs for the Pi to read
    tpa    = gpio_pin(25, gpio_pin.IN)
    tpb    = gpio_pin(24, gpio_pin.IN)
    sc0    = gpio_pin(27, gpio_pin.IN)
    nmrd   = gpio_pin(17, gpio_pin.IN)
    nmwr   = gpio_pin(16, gpio_pin.IN)
    n2     = gpio_pin(18, gpio_pin.IN)

    # Set up the memory addresses as input for the Pi to read
    ma0    = gpio_pin( 8, gpio_pin.IN)
    ma1    = gpio_pin( 9, gpio_pin.IN)
    ma2    = gpio_pin(10, gpio_pin.IN)
    ma3    = gpio_pin(11, gpio_pin.IN)
    ma4    = gpio_pin(12, gpio_pin.IN)
    ma5    = gpio_pin(13, gpio_pin.IN)
    ma6    = gpio_pin(14, gpio_pin.IN)
    ma7    = gpio_pin(15, gpio_pin.IN)

    # Set up the data lines as bidirectional (default NOP)
    d7     = gpio_pin(7, gpio_pin.BOTH, True)
    d6     = gpio_pin(6, gpio_pin.BOTH, True)
    d5     = gpio_pin(5, gpio_pin.BOTH, False)
    d4     = gpio_pin(4, gpio_pin.BOTH, False)
    d3     = gpio_pin(3, gpio_pin.BOTH, False)
    d2     = gpio_pin(2, gpio_pin.BOTH, True)
    d1     = gpio_pin(1, gpio_pin.BOTH, False)
    d0     = gpio_pin(0, gpio_pin.BOTH, False)

    # Set up the Q line as an input to the Pi
    qout   = gpio_pin(22, gpio_pin.IN)

As shown in that last code snippet, Run_1802 currently expects the following 1802 signals to be connected to these GPIO pins:

    clock   connected to GPIO 26
    nclear  connected to GPIO 19
    ndmai   connected to GPIO 21
    nint    connected to GPIO 20
    tpa     connected to GPIO 25
    tpb     connected to GPIO 24
    sc0     connected to GPIO 27
    nmrd    connected to GPIO 17
    nmwr    connected to GPIO 16
    n2      connected to GPIO 18
    ma0     connected to GPIO 8
    ma1     connected to GPIO 9
    ma2     connected to GPIO 10
    ma3     connected to GPIO 11
    ma4     connected to GPIO 12
    ma5     connected to GPIO 13
    ma6     connected to GPIO 14
    ma7     connected to GPIO 15
    d7      connected to GPIO 7
    d6      connected to GPIO 6
    d5      connected to GPIO 5
    d4      connected to GPIO 4
    d3      connected to GPIO 3
    d2      connected to GPIO 2
    d1      connected to GPIO 1
    d0      connected to GPIO 0
    qout    connected to GPIO 22

Note that proper engineering practices for the configuration and connecting of hardware are beyond the scope of this documentation. The earlier picture shows a "breadboard", but other options are certainly available. Please ensure that you have the proper skills and background before attempting to build anything with real hardware. Also note that there have been two incompatible definitions for these pin mappings. The original definition is found in code prior to March 1st, 2023. This post-March2023 software should NOT be used with the pre-March2023 pin mapping, and similarly, the pre-March2023 software should NOT be used with this post-March2023 pin mapping.

## Python Power

Using the "p" command line option will start the Python command line interpreter (or Python console) after the program has run the requested number of clock ticks. At that point you will be presented with the standard Python ">>>" prompt. If you are familiar with Python, you can use all of the normal commands to examine data, change data, call functions, and even write and call new temporary functions in that session. In short, you can do pretty much anything.

To support more advanced control and debugging, Run_1802.py includes a number of functions designed to be helpful in the Python console. These functions are:

    h() to show this help text
    reset() to reset the 1802
    run(n) run the 1802 by n half-clocks
    mem() to show first 16 bytes plus all non-zero bytes
    ram(start[,num[,any]]) to show selected memory
    find(val,start,num,inv) to find values in memory

For example, to reset the 1802, call the reset() function (don't type the ">>>" prompt ... it should already be there):

    >>> reset()

To run the 1802 for 16 half-clock cycles (8 full clock cycles) enter:

    >>> run(16)

To get a feel for using these functions, run the simple blink program (7B first), but add the "n=0" and "p" options:

    $ python Run_1802.py h=7B7A3000 n=0 p

This will load the program, run 0 clock cycles, and drop into the Python console. At that point, you can run 40 "half-clock" steps with this function call:

    >>> run(40)

After 40 half-clocks, the Q output should still be off. Then run one more half-clock with this function call:

    >>> run(1)

The Q output should then go high. This is an example of running and stepping through a program while observing the state of the hardware.

You can also explore and modify the 1802 RAM using normal Python syntax. The "RAM" in Run_1802 is stored internally as a Python list, so you can display the first 10 bytes with this command:

    >>> memory[0:10]

You could also display the 32 bytes starting at address 256 using hex syntax:

    >>> memory[0x100:0x120]

You can assign a value to any address as well. These commands, for example, swap the first two bytes of memory:

    >>> temp = memory[0]
    >>> memory[0] = memory[1]
    >>> memory[1] = temp

The ability to use Python gives great power and control. But remember that with great power comes great responsbility. Use the power of Python carefully!
