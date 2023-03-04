#!/usr/bin/python

# This program clocks the 1802 and feeds it a series of instructions.

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

#  /CLEAR   /WAIT   Mode
#     L       L     LOAD
#     L       H     RESET
#     H       L     PAUSE
#     H       H     RUN


# Board Numbering (BRD) is the Physical Pin number on the 40 pin connector alternating left then right for each row
# BRD  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40
# BCM +3 +5  2 +5  3  G  4 14  G 15 17 18 27  G 22 23 +3 24 10  G  9 25 11  8  G  7  0  1  5  G  6 12 13  G 19 16 26 20  G 21
# Broadcom Number (BCM) is the Broadcom GPIO pin number

# I/O: 3, 5, 7, 8, 10, 11, 12, 13, 15, 16, 18, 19, 21, 22, 23, 24, 26, 27, 28, 29, 31, 32, 33, 35, 36, 37, 38, 40
# Non I/O (Power, Ground, ...): 1, 2, 4, 6, 9, 14, 17, 20, 25, 30, 34, 39

# Initially all GPIO pins are configured as inputs


import os
import sys
import time
import getopt
import math
from signal import signal, SIGINT
import RPi.GPIO as GPIO

def ctlc_handler ( sig, frame ):
  # print ( "\nExiting after Control-C\n" )
  exit ( 0 )
signal (SIGINT, ctlc_handler)

# The settling time is intended to ensure that
# any GPIO changes are completed before moving
# on to subsequent operations. It may not be
# needed at all, but it was added to remove
# any timing concerns during development.

settling_sleep_time = 0.0001

def bival ( val ):
  if val == False:
    return ( 0 )
  if val == True:
    return ( 1 )
  if val < 0.5:
    return ( 0 )
  return ( 1 )

######################
# The gpio_pin class #
######################
class gpio_pin:
  # This class provides somewhat controlled access to GPIO pins
  IN = -1
  OUT = 1
  BOTH = 0

  def __init__(self, gpio, allowed_direction, value=False):
    self.gpio = gpio
    self.allowed_direction = allowed_direction
    self.value = value
    GPIO.setwarnings(False) # Disable when setting up this pin
    if self.allowed_direction == self.OUT:
      GPIO.setup(self.gpio, GPIO.OUT, initial=self.value)
      self.cur_dir = self.OUT
    elif self.allowed_direction == self.IN:
      GPIO.setup(self.gpio, GPIO.IN, pull_up_down=GPIO.PUD_OFF)
      self.value = GPIO.input(self.gpio)
      self.cur_dir = self.IN
    elif self.allowed_direction == self.BOTH:
      # Set BOTH as "IN" for now
      GPIO.setup(self.gpio, GPIO.IN, pull_up_down=GPIO.PUD_OFF)
      self.value = GPIO.input(self.gpio)
      self.cur_dir = self.IN
    else:
      # Set anything else as "IN"
      self.allowed_direction = self.IN
      GPIO.setup(self.gpio, GPIO.IN, pull_up_down=GPIO.PUD_OFF)
      self.value = GPIO.input(self.gpio)
      self.cur_dir = self.IN
    GPIO.setwarnings(True) # Enable after setting up this pin

  def get_val(self):
    if self.allowed_direction == self.OUT:
      # This pin was defined as output only
      return ( self.value )
    else:
      # This pin is either IN or BOTH, so it's OK to read
      if self.cur_dir != self.IN:
        # Change current direction to GPIO.IN
        GPIO.setwarnings(False) # Disable when setting up this pin
        GPIO.setup(self.gpio, GPIO.IN, pull_up_down=GPIO.PUD_OFF)
        GPIO.setwarnings(True) # Enable after setting up this pin
        self.cur_dir = self.IN
      self.value = GPIO.input(self.gpio)
      return ( self.value )

  def get_val_safe (self):
    if self.allowed_direction == self.OUT:
      # This pin was defined as output only
      return ( self.value )
    elif self.allowed_direction == self.IN:
      # This pin is an input pin so it should always be OK to read
      if self.cur_dir != self.IN:
        # Change current direction to GPIO.IN
        GPIO.setwarnings(False) # Disable when setting up this pin
        GPIO.setup(self.gpio, GPIO.IN, pull_up_down=GPIO.PUD_OFF)
        GPIO.setwarnings(True) # Enable after setting up this pin
        self.cur_dir = self.IN
      self.value = GPIO.input(self.gpio)
      return ( self.value )
    elif self.allowed_direction == self.BOTH:
      # This pin is BOTH, so check the current direction but don't change it
      if self.cur_dir == self.IN:
        # Read the current value
        self.value = GPIO.input(self.gpio)
        return ( self.value )
      else:
        # Just return the last self.value which would have been going out
        return ( self.value )

  def set_val(self, val):
    self.value = val
    if self.allowed_direction == self.IN:
      # This pin was defined as output only
      pass
    else:
      # This pin is either OUT or BOTH, so it's OK to write
      if self.cur_dir != self.OUT:
        # Change current direction to GPIO.OUT
        GPIO.setwarnings(False) # Disable when setting up this pin
        GPIO.setup(self.gpio, GPIO.OUT)
        GPIO.setwarnings(True) # Enable after setting up this pin
        self.cur_dir = self.OUT
      self.value = val
      GPIO.output ( self.gpio, self.value )
      self.value = val
      time.sleep ( settling_sleep_time )

  def toggle(self):
    self.set_val ( not self.value )


##### Define the memory #####

memory = [0 for i in range(2**16)]

##### Write the default program #####

memory[0] = 0x7a
memory[1] = 0x7b
memory[2] = 0x30
memory[3] = 0x00

# Another test program
# memory[ 0] = 0xf8  # LDI
# memory[ 1] = 0x00  # 0x00
# memory[ 2] = 0xb5  # PHI 5
# memory[ 3] = 0xf8  # LDI
# memory[ 4] = 0xff  # 0xff
# memory[ 5] = 0xa5  # PLO 5
# memory[ 6] = 0xf8  # LDI
# memory[ 7] = 0xaa  # 0xaa
# memory[ 8] = 0x55  # STO 5 (put aa into memory[ff])
# memory[ 9] = 0x55  # STO 5 (put aa into memory[ff])
# memory[10] = 0x55  # STO 5 (put aa into memory[ff])
# memory[11] = 0x7b  # SEQ
# memory[12] = 0x00  # IDL

# This would fill memory with NOPs
# for i in range(256):
#   memory[i] = 0xc4;

##### Process Command Line Parameters #####

dump_data = False
trace_exec = False
dump_mem = False
dump_file = None
num_clocks = 1000000
clock_time = 2 * settling_sleep_time
open_console = False

def h():
  print ( "Command Line Parameters:" )
  print ( "  h=hex  to run plain hex code from command" )
  print ( "  f=file to run a hex file of several formats" )
  print ( "  n=#    to specify number of half-clocks to run" )
  print ( "  d      to dump every pin while running" )
  print ( "  t      to trace execution while running" )
  print ( "  dm     to dump non-zero memory after run" )
  print ( "  js     to save output in data.js" )
  print ( "  p      to drop into Python after running" )
  print ( "  help   to print this help message and exit" )
  print ( "Useful functions from Python:" )
  print ( "  h()     to show this help text" )
  print ( "  help()  to get Python help" )
  print ( "  reset() to reset the 1802" )
  print ( "  run(n)  to run the 1802 by n half-clocks" )
  print ( "  mem()   to show first 16 plus all non-zero bytes" )
  print ( "  ram(start[,num[,any]]) to show selected memory" )
  print ( "  find(val,start,num,inv) to find values in memory" )
  print ( "Supported File Formats (autodetected from file):" )
  print ( "  .hex - Intel Hex Format (address and data)" )
  print ( "  .ahx - Address:Data Hex Format (address and data)" )
  print ( "  .phx - Plain Hex Format (loaded at address 0)" )
  print ( "Use up and down arrows in Python for history" )
  print ( "Use Control-D to exit Python" )
  print ( "Use Control-C to exit Run_1802" )

def split_code_text(s):
  # Parse a string of hex with possible embedded spaces
  # print ( "Newmem got " + str(s) )
  mem = []
  parts = s.strip().split()
  for part in parts:
    if len(part) <= 2:
      mem.append ( int(part,16) )
    else:
      if (len(part) % 2) != 0:
        # This string has an odd number of digits
        # Save the first digit as a byte value
        mem.append ( int(part[0],16) )
        # Remove the first digit to make it even
        part = part[1:]
      # The part string now has pairs of digits
      for i in range(len(part)/2):
        mem.append ( int(part[2*i:(2*i)+2],16) )
  # print ( "Newmem returning " + str(mem) )
  return ( mem )

if len(sys.argv) > 1:
  # print ( "Arguments: " + str(sys.argv) )
  for arg in sys.argv:
    # print ("  " + str(arg))

    if arg == "help":
      h()
      sys.exit ( 0 )

    if arg == "d":
      dump_data = True

    if arg == "t":
      trace_exec = True

    if arg == "p":
      open_console = True

    if arg.startswith("c="):
      clock_time = float(arg[2:])
      # print ( "Arg sets clock_time = " + str(clock_time) )

    if arg.startswith("n="):
      num_clocks = int(arg[2:])
      # print ( "Arg sets num_clocks = " + str(num_clocks) )

    if arg == "js":
      dump_file = open ( "data.js", "w" )

    if arg == "dm":
      dump_mem = True

    src_txt = None

    if arg.startswith("f="):
      # Read a program from a file
      f = open(arg[2:],"r")
      src_txt = f.read()
      f.close()
    elif arg.startswith("h="):
      # Read a program as hex a command option
      src_txt = arg[2:]

    if (src_txt != None) and (len(src_txt) > 0):

      # Remove any comments (which may include ':')
      dparts = src_txt.split("\n")
      for i in range(len(dparts)):
        if ';' in dparts[i]:
          dparts[i] = dparts[i].split(';')[0]
      src_txt = "\n".join(dparts)

      # Print the file
      print ( "Loading:\n" + src_txt )

      next_mem_loc = 0
      # Determine if the source text has address information or not
      if ':' in src_txt:
        # This file has some lines in either in Intel Hex Format or addr:data format
        lines = src_txt.split("\n")
        for ln in lines:
          # print ( "Processing line \"" + ln + "\"" )
          ln = ln.strip()
          if len(ln) > 0:
            if ln[0] == ':':
              # This line should be in Intel Hex Format
              bytecount = int(ln[1:3],16)
              addr      = int(ln[3:7],16)
              rectyp    = int(ln[7:9],16)
              dt = ln[9:9+(bytecount*2)]
              # Verify that the checksum is zero
              checked_data = ln[1:2*(1+2+1+bytecount+1)+2]
              c = 0
              for i in range(len(checked_data)/2):
                i2 = 2*i
                c = c + int(checked_data[i2:i2+2],16)
              if (c & 0xff) != 0:
                print ( "Checksum error on line " + ln )
                exit ( 3 )
              # Set the starting location to get this data
              next_mem_loc = addr;
              if rectyp == 0:
                # Store the data in RAM
                for i in range(len(dt)/2):
                  memory[next_mem_loc] = int(dt[i*2:(i*2)+2],16)
                  next_mem_loc += 1
            elif ':' in ln:
              # This line should be in addr:data format (where data is optional)
              parts = [ p.strip() for p in ln.split(':') ]
              if len(parts[0]) > 0:
                next_mem_loc = int(parts[0],16)
              if len(parts[1]) > 0:
                # Split the remaining parts by spaces or pairs of hex digits
                newmem = split_code_text(parts[1])
                for i in range(len(newmem)):
                  memory[next_mem_loc] = newmem[i]
                  # print ( "mem[" + str(next_mem_loc) + "] = " + hex(memory[next_mem_loc]) )
                  next_mem_loc += 1
            else:
              # This line is in plain hex format
              newmem = split_code_text(ln)
              for i in range(len(newmem)):
                memory[next_mem_loc] = newmem[i]
                # print ( "mem[" + str(next_mem_loc) + "] = " + hex(memory[next_mem_loc]) )
                next_mem_loc += 1

      else:
        # Assume this entire text is plain hex format
        newmem = split_code_text(src_txt)
        for i in range(len(newmem)):
          memory[next_mem_loc] = newmem[i]
          # print ( "mem[" + str(next_mem_loc) + "] = " + hex(memory[next_mem_loc]) )
          next_mem_loc += 1


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
ma0    = gpio_pin( 0, gpio_pin.IN)
ma1    = gpio_pin( 1, gpio_pin.IN)
ma2    = gpio_pin( 2, gpio_pin.IN)
ma3    = gpio_pin( 3, gpio_pin.IN)
ma4    = gpio_pin( 4, gpio_pin.IN)
ma5    = gpio_pin( 5, gpio_pin.IN)
ma6    = gpio_pin( 6, gpio_pin.IN)
ma7    = gpio_pin( 7, gpio_pin.IN)

# Set up the data lines as bidirectional (with default NOP)
d0     = gpio_pin( 8, gpio_pin.BOTH, False)
d1     = gpio_pin( 9, gpio_pin.BOTH, False)
d2     = gpio_pin(10, gpio_pin.BOTH, True)
d3     = gpio_pin(11, gpio_pin.BOTH, False)
d4     = gpio_pin(12, gpio_pin.BOTH, False)
d5     = gpio_pin(13, gpio_pin.BOTH, False)
d6     = gpio_pin(14, gpio_pin.BOTH, True)
d7     = gpio_pin(15, gpio_pin.BOTH, True)

# Set up the Q line as an input to the Pi
qout   = gpio_pin(22, gpio_pin.IN)


# Assert Reset and hold it to initialize and observe
nclear.set_val ( False )

# Define a function to verify that all data lines are inputs
def all_data_are_inputs():
  all_in = True
  if d7.cur_dir != d7.IN: all_in = False;
  if d6.cur_dir != d6.IN: all_in = False;
  if d5.cur_dir != d5.IN: all_in = False;
  if d4.cur_dir != d4.IN: all_in = False;
  if d3.cur_dir != d3.IN: all_in = False;
  if d1.cur_dir != d1.IN: all_in = False;
  if d0.cur_dir != d0.IN: all_in = False;
  return ( all_in )

# Define a function to print a header for logged pins
def get_header_string():
  s = "nCL CLK TPA TPB SC0 nRD nWR N2 ma7 ma6 ma5 ma4 ma3 ma2 ma1 ma0 aIN d7 d6 d5 d4 d3 d2 d1 d0 Q"
  return ( s )

def get_js_header_string():
  s = "document.getElementById('timing_header_area').value = \"" + get_header_string() + "\";\n"
  s += "document.getElementById('timing_data_area').value = \"\" \n"
  return ( s )

# Define a function to log the pin values
def get_data_string ( ncl ):
  s   =   str(str(ncl) + ' ' +
          str(bival(clock.get_val())) + ' ' +
          str(tpa.get_val()) + ' ' +
          str(tpb.get_val()) + ' ' +
          str(sc0.get_val()) + ' ' +
          str(nmrd.get_val()) + ' ' +
          str(nmwr.get_val()) + ' ' +
          str(n2.get_val()) + ' ' +
          str(ma7.get_val()) + ' ' +
          str(ma6.get_val()) + ' ' +
          str(ma5.get_val()) + ' ' +
          str(ma4.get_val()) + ' ' +
          str(ma3.get_val()) + ' ' +
          str(ma2.get_val()) + ' ' +
          str(ma1.get_val()) + ' ' +
          str(ma0.get_val()) + ' ' +
          str(bival(all_data_are_inputs())) + ' ' +
          str(bival(d7.get_val_safe())) + ' ' +
          str(bival(d6.get_val_safe())) + ' ' +
          str(bival(d5.get_val_safe())) + ' ' +
          str(bival(d4.get_val_safe())) + ' ' +
          str(bival(d3.get_val_safe())) + ' ' +
          str(bival(d2.get_val_safe())) + ' ' +
          str(bival(d1.get_val_safe())) + ' ' +
          str(bival(d0.get_val_safe())) + ' ' +
          str(qout.get_val()))
  return ( s )

def print_data(ncl):
  s = get_data_string(ncl)
  if dump_file != None:
    dump_file.write ( " + \"" + s + "\\n\"\n" );
  print ( s )

addr_hi = 0
n2_hi = 0
out4_val = None
tpb_hi = 0

def half_clock(n):
  global clock
  for i in range(n):
    clock.toggle()
    time.sleep ( clock_time )

def full_clock(n):
  global clock
  for i in range(n):
    clock.toggle()
    time.sleep ( clock_time )
    clock.toggle()
    time.sleep ( clock_time )

def not_clear_low():
  global nclear
  nclear.set_val ( False )
  time.sleep ( 0.01 )

def not_clear_high():
  global nclear
  nclear.set_val ( True )
  time.sleep ( 0.01 )

def reset():
  global nclear
  global clock

  # Assert the "Reset" line and pause
  nclear.set_val ( False )
  time.sleep ( 0.01 )

  # Run the clock while in reset
  full_clock(32)

  # Ensure that the clock starts off
  clock.set_val ( False )

  # Release the "Reset" line to let the 1802 start running
  nclear.set_val ( True )
  time.sleep ( 0.01 )


inst_proc_table = [ # InstructionName, OpCode, NumAdditionalBytes
	[ "IDL",  "00", 0 ],
	[ "LDN",  "0N", 0 ],
	[ "INC",  "1N", 0 ],
	[ "DEC",  "2N", 0 ],
	[ "BR",   "30", 1 ],
	[ "BQ",   "31", 1 ],
	[ "BZ",   "32", 1 ],
	[ "BPZ",  "33", 1 ],
	[ "BGE",  "33", 1 ],
	[ "BDF",  "33", 1 ],
	[ "B1",   "34", 1 ],
	[ "B2",   "35", 1 ],
	[ "B3",   "36", 1 ],
	[ "B4",   "37", 1 ],
	[ "NBR",  "38", 0 ],
	[ "SKP",  "38", 0 ],
	[ "BNQ",  "39", 1 ],
	[ "BNZ",  "3A", 1 ],
	[ "BL",   "3B", 1 ],
	[ "BM",   "3B", 1 ],
	[ "BNF",  "3B", 1 ],
	[ "BN1",  "3C", 1 ],
	[ "BN2",  "3D", 1 ],
	[ "BN3",  "3E", 1 ],
	[ "BN4",  "3F", 1 ],
	[ "LDA",  "4N", 0 ],
	[ "STR",  "5N", 0 ],
	[ "IRX",  "60", 0 ],
	[ "OUT",  "61", 0 ],
	[ "ILL",  "68", 0 ],
	[ "INP",  "69", 0 ],
	[ "RET",  "70", 0 ],
	[ "DIS",  "71", 0 ],
	[ "LDXA", "72", 0 ],
	[ "STXD", "73", 0 ],
	[ "ADC",  "74", 0 ],
	[ "SDB",  "75", 0 ],
	[ "RSHR", "76", 0 ],
	[ "SHRC", "76", 0 ],
	[ "SMB",  "77", 0 ],
	[ "SAV",  "78", 0 ],
	[ "MARK", "79", 0 ],
	[ "REQ",  "7A", 0 ],
	[ "SEQ",  "7B", 0 ],
	[ "ADCI", "7C", 1 ],
	[ "SDBI", "7D", 1 ],
	[ "RSHL", "7E", 0 ],
	[ "SHLC", "7E", 0 ],
	[ "SMBI", "7F", 1 ],
	[ "GLO",  "8N", 0 ],
	[ "GHI",  "9N", 0 ],
	[ "PLO",  "AN", 0 ],
	[ "PHI",  "BN", 0 ],
	[ "LBR",  "C0", 2 ],
	[ "LBQ",  "C1", 2 ],
	[ "LBZ",  "C2", 2 ],
	[ "LBDF", "C3", 2 ],
	[ "NOP",  "C4", 0 ],
	[ "LSNQ", "C5", 0 ],
	[ "LSNZ", "C6", 0 ],
	[ "LSNF", "C7", 0 ],
	[ "NLBR", "C8", 0 ],
	[ "LSKP", "C8", 0 ],
	[ "LBNQ", "C9", 2 ],
	[ "LBNZ", "CA", 2 ],
	[ "LBNF", "CB", 2 ],
	[ "LSIE", "CC", 0 ],
	[ "LSQ",  "CD", 0 ],
	[ "LSZ",  "CE", 0 ],
	[ "LSDF", "CF", 0 ],
	[ "SEP",  "DN", 0 ],
	[ "SEX",  "EN", 0 ],
	[ "LDX",  "F0", 0 ],
	[ "OR",   "F1", 0 ],
	[ "AND",  "F2", 0 ],
	[ "XOR",  "F3", 0 ],
	[ "ADD",  "F4", 0 ],
	[ "SD",   "F5", 0 ],
	[ "SHR",  "F6", 0 ],
	[ "SM",   "F7", 0 ],
	[ "LDI",  "F8", 1 ],
	[ "ORI",  "F9", 1 ],
	[ "ANI",  "FA", 1 ],
	[ "XRI",  "FB", 1 ],
	[ "ADI",  "FC", 1 ],
	[ "SDI",  "FD", 1 ],
	[ "SHL",  "FE", 0 ],
	[ "SMI",  "FF", 1 ]
]


def get_instr(hx):
  best_instr = ""
  best_instr_index = -1
  # Start by looking for an exact match
  for i in range(len(inst_proc_table)):
    if hx.upper() == inst_proc_table[i][1]:
      best_instr = inst_proc_table[i][0];
      best_instr_index = i;
  if best_instr_index < 0:
    # No exact match, so look for a match of first digit only
    for i in range(len(inst_proc_table)):
      if hx[0].upper() == inst_proc_table[i][1][0].upper():
        if ( (hx[0] == '6') and ((hx[1] != '0') or (hx[0] != '8')) ):
          # This is either an input or an output instruction
          if (hx == '61'): best_instr = 'OUT1'; best_instr_index = i;
          if (hx == '62'): best_instr = 'OUT2'; best_instr_index = i;
          if (hx == '63'): best_instr = 'OUT3'; best_instr_index = i;
          if (hx == '64'): best_instr = 'OUT4'; best_instr_index = i;
          if (hx == '65'): best_instr = 'OUT5'; best_instr_index = i;
          if (hx == '66'): best_instr = 'OUT6'; best_instr_index = i;
          if (hx == '67'): best_instr = 'OUT7'; best_instr_index = i;
          if (hx == '69'): best_instr = 'IN1'; best_instr_index = i;
          if (hx == '6A'): best_instr = 'IN2'; best_instr_index = i;
          if (hx == '6B'): best_instr = 'IN3'; best_instr_index = i;
          if (hx == '6C'): best_instr = 'IN4'; best_instr_index = i;
          if (hx == '6D'): best_instr = 'IN5'; best_instr_index = i;
          if (hx == '6E'): best_instr = 'IN6'; best_instr_index = i;
          if (hx == '6F'): best_instr = 'IN7'; best_instr_index = i;
        elif (inst_proc_table[i][1][1].upper() == 'N'):
          best_instr = inst_proc_table[i][0].upper() + " " + hx[1].upper();
        else:
          best_instr = inst_proc_table[i][0].upper();
  '''
  if (best_instr_index >= 0) {
    // Handle Immediate Operands of 1 or 2 bytes
    if (inst_proc_table[best_instr_index][2] > 0) {
      best_instr = best_instr + " " + hex2(mem[rr[rp]+1]);
      if (inst_proc_table[best_instr_index][2] > 1) {
        best_instr = best_instr + " " + hex2(mem[rr[rp]+2]);
      }
    }
  }
  '''
  return ( best_instr );


def hex2 ( v ):
  v = hex(v)[2:]
  if len(v) == 2: return ( v )
  return ( '0' + v )

def hex4 ( v ):
  v = hex(v)[2:]
  while len(v) < 4:
    v = '0' + v
  return ( v )

def run ( num_clocks ):
  # Run the 1802 by num_clocks clock edges
  global addr_hi
  global n2_hi
  global out4_val
  global tpb_hi

  for i in range(num_clocks):
    clock.toggle()
    time.sleep ( settling_sleep_time )

    # Get the current address lines from the 1802
    a0 = ma0.get_val()
    a1 = ma1.get_val()
    a2 = ma2.get_val()
    a3 = ma3.get_val()
    a4 = ma4.get_val()
    a5 = ma5.get_val()
    a6 = ma6.get_val()
    a7 = ma7.get_val()
    addr = (a7 << 7) | (a6 << 6) | (a5 << 5) | (a4 << 4) | (a3 << 3) | (a2 << 2) | (a1 << 1) | a0

    if tpa.get_val():
      # Keep saving the high address inside the TPA active region.
      addr_hi = addr + 0

    if n2.get_val():
      # Preserve the fact that n2 was high
      n2_hi = 1
      # Also preserve the last sample while high
      db7 = d7.get_val()
      db6 = d6.get_val()
      db5 = d5.get_val()
      db4 = d4.get_val()
      db3 = d3.get_val()
      db2 = d2.get_val()
      db1 = d1.get_val()
      db0 = d0.get_val()
      out4_val = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
    else:
      if n2_hi != 0:
        # n2 had been high, but just went low, so output
        print ( str(out4_val) )
        # Reset  n2_hi and out4_val
        n2_hi = 0
        out4_val = None


    # Get /MRD and /MRW for later use
    n_mrd = nmrd.get_val()
    n_mwr = nmwr.get_val()

    if n_mrd:
        # Not Memory Read is high, so the 1802 isn't reading (and may be writing)
        # Convert the Raspberry Pi data lines to read mode with a call to get_val()
        db7 = d7.get_val()
        db6 = d6.get_val()
        db5 = d5.get_val()
        db4 = d4.get_val()
        db3 = d3.get_val()
        db2 = d2.get_val()
        db1 = d1.get_val()
        db0 = d0.get_val()

        if not n_mwr:
          # The 1802 wants to write to memory, so convert the data and write it to memory
          data_byte = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
          memory[(addr_hi<<8) | addr] = data_byte
          # print ( "Setting mem[" + str((addr_hi<<8)|addr) + "] to " + str(data_byte) )

    else:
        # The 1802 wants to read from memory (instruction or data)
        # Present the requested byte to the data bus
        mem_out = memory[(addr_hi<<8) | addr]

        # Put the instruction onto the data bus
        d7.set_val ( (mem_out>>7) & 0x01 )
        d6.set_val ( (mem_out>>6) & 0x01 )
        d5.set_val ( (mem_out>>5) & 0x01 )
        d4.set_val ( (mem_out>>4) & 0x01 )
        d3.set_val ( (mem_out>>3) & 0x01 )
        d2.set_val ( (mem_out>>2) & 0x01 )
        d1.set_val ( (mem_out>>1) & 0x01 )
        d0.set_val ( (mem_out>>0) & 0x01 )

    tpb_now = tpb.get_val()
    if tpb_now:
      tpb_hi = 1
    else:
      if tpb_hi:
        tpb_hi = 0
        if trace_exec:
          if not sc0.get_val():
            db7 = d7.get_val()
            db6 = d6.get_val()
            db5 = d5.get_val()
            db4 = d4.get_val()
            db3 = d3.get_val()
            db2 = d2.get_val()
            db1 = d1.get_val()
            db0 = d0.get_val()
            data_byte = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
            print ( "Fetch at addr " + hex4((addr_hi<<8) | addr) + " got " + hex2(data_byte) + " = " + get_instr(hex2(data_byte)))

    if dump_data:
      print_data ( "1" ) # notCLEAR is 0
    if dump_file != None:
      dump_file.write ( " + \"" + get_data_string ( "1" ) + "\\n\"\n" );

    time.sleep ( clock_time )

def find (val=0, start=0, num=0x1000, inv=False):
  # Find val in RAM
  global memory
  print ( "-------------------" )
  print ( "RAM:" )
  print ( "-------------------" )
  for i in range(num):
    addr = start + i
    if ((not inv) and (memory[addr] == val)) or (inv and (memory[addr] != val)):
      print ( "M[" + hex(addr) + "] = " + hex(memory[addr]) + " = " + str(memory[addr]) )
  print ( "-------------------" )

def ram (start=0, num=16, any_val=True):
  # Show RAM
  global memory
  print ( "-------------------" )
  print ( "RAM:" )
  print ( "-------------------" )
  for i in range(num):
    addr = start + i
    if any_val or (memory[addr] != 0):
      print ( "M[" + hex(addr) + "] = " + hex(memory[addr]) + " = " + str(memory[addr]) )
  print ( "-------------------" )

def mem ():
  # Show the first 16 bytes of RAM followed by a scan for non-zero values
  global memory
  print ( "-------------------" )
  print ( "RAM:" )
  print ( "-------------------" )
  for addr in range(16):
    print ( "M[" + hex(addr) + "] = " + hex(memory[addr]) + " = " + str(memory[addr]) )
  print ( "-------------------" )
  for i in range(16,0x10000):
    if memory[i] != 0:
      print ( "M[" + hex(i) + "] = " + hex(memory[i]) + " = " + str(memory[i]) )
  print ( "-------------------" )


# Print the header as appropriate for this run
if dump_data or ( dump_file != None ):
  if dump_data:
    print ( get_header_string() + "\n" )
  if dump_file != None:
    dump_file.write ( get_js_header_string() )


# Toggle the clock to observe the processor in Reset
for i in range(32):
  clock.toggle()
  if dump_data:
    print_data ( "0" ) # notCLEAR is 0
  if dump_file != None:
    dump_file.write ( " + \"" + get_data_string ( "0" ) + "\\n\"\n" );
  time.sleep ( clock_time )

# Release the "Reset" line to let the 1802 start running
nclear.set_val ( True )
time.sleep ( 0.1 )

# Enter a loop to toggle the clock to run the program
print ( "Running " + str(num_clocks) + " clocks" )
run ( num_clocks )


if dump_mem:
  mem()

if open_console:
  # Allow exploration of the post-run RAM
  __import__('code').interact(local={k: v for ns in (globals(), locals()) for k, v in ns.items()})
