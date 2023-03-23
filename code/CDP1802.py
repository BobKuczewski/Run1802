#!/usr/bin/python

# This program presents an interface to the 1802.

import os
import sys
import time
import getopt
import math
from signal import signal, SIGINT
import RPi.GPIO as GPIO

# Import the Raspberry Pi to 1802 pin definitions
import Pi_to_1802 as pins


def ctlc_handler ( sig, frame ):
  # print ( "\nExiting after Control-C\n" )
  exit ( 0 )
signal (SIGINT, ctlc_handler)

def get_input ( prompt=None ):
  cmd = None
  if sys.version_info[0] <= 2:
    cmd = raw_input('> ')
  else:
    cmd = input('> ')
  return ( cmd )

def hex2 ( v ):
  v = hex(v)[2:]
  if len(v) == 2: return ( v )
  return ( '0' + v )

def hex4 ( v ):
  v = hex(v)[2:]
  while len(v) < 4:
    v = '0' + v
  return ( v )

def bival ( val ):
  if val == False:
    return ( 0 )
  if val == True:
    return ( 1 )
  if val < 0.5:
    return ( 0 )
  return ( 1 )

# The settling time is intended to ensure that
# any GPIO changes are completed before moving
# on to subsequent operations. It may not be
# needed at all, but it was added to remove
# any timing concerns during development.

settling_sleep_time = 0.00001

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


#######################
# The pin_group class #
#######################
class pin_group:
  # Class to manage a group of pins as a single entity
  def __init__(self, pin_list=[]):
    self.pin_list = pin_list

####################
# The memory class #
####################
class memory:
  # Class to represent memory
  def __init__(self, size=65536):
    self.mem = [0 for i in range(size)]

  def split_code_text(self, s):
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

  def load ( self, src_txt ):
    # Automatically loads from: (1) plain hex, (2) hex with addresses, (3) Intel Hex
    if (src_txt != None) and (len(src_txt) > 0):

      # Remove any comments (which may include ':')
      dparts = src_txt.split("\n")
      for i in range(len(dparts)):
        if ';' in dparts[i]:
          dparts[i] = dparts[i].split(';')[0]
      src_txt = "\n".join(dparts)

      # Print the file
      print ( "Loading:\n" + (40*'=') + '\n' + src_txt + (40*'=') + '\n' )

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
              for i in range(int(len(checked_data)/2)):
                i2 = 2*i
                c = c + int(checked_data[i2:i2+2],16)
              if (c & 0xff) != 0:
                print ( "Checksum error on line " + ln )
                exit ( 3 )
              # Set the starting location to get this data
              next_mem_loc = addr;
              if rectyp == 0:
                # Store the data in RAM
                for i in range(int(len(dt)/2)):
                  self.mem[next_mem_loc] = int(dt[i*2:(i*2)+2],16)
                  next_mem_loc += 1
            elif ':' in ln:
              # This line should be in addr:data format (where data is optional)
              parts = [ p.strip() for p in ln.split(':') ]
              if len(parts[0]) > 0:
                next_mem_loc = int(parts[0],16)
              if len(parts[1]) > 0:
                # Split the remaining parts by spaces or pairs of hex digits
                newmem = self.split_code_text(parts[1])
                for i in range(len(newmem)):
                  self.mem[next_mem_loc] = newmem[i]
                  # print ( "mem[" + str(next_mem_loc) + "] = " + hex(self.mem[next_mem_loc]) )
                  next_mem_loc += 1
            else:
              # This line is in plain hex format
              newmem = self.split_code_text(ln)
              for i in range(len(newmem)):
                self.mem[next_mem_loc] = newmem[i]
                # print ( "mem[" + str(next_mem_loc) + "] = " + hex(self.mem[next_mem_loc]) )
                next_mem_loc += 1

      else:
        # Assume this entire text is plain hex format
        newmem = self.split_code_text(src_txt)
        for i in range(len(newmem)):
          self.mem[next_mem_loc] = newmem[i]
          # print ( "mem[" + str(next_mem_loc) + "] = " + hex(self.mem[next_mem_loc]) )
          next_mem_loc += 1


#####################
# The cdp1802 class #
#####################
class cdp1802:
  # Class to represent the 1802 microprocessor
  def __init__(self, clock_time):
    self.num_half_clocks = 0
    self.clock_time = clock_time
    self.mem = memory()
    self.instr_set = instruction_set()

    ##### Set Up the Pins #####
    GPIO.setmode(GPIO.BCM) # Use the Broadcom numbering shown on Pi ribbon connector plug.

    # Set up the CLOCK and /CLEAR as outputs for the Pi to control
    self.clock  = gpio_pin(pins.CLOCK,  gpio_pin.OUT, False)
    self.nclear = gpio_pin(pins.NCLEAR, gpio_pin.OUT, True)

    # Set up the /DMAin, /INT, and /EF1 as outputs for the Pi to control
    self.ndmai  = gpio_pin(pins.NDMAI,  gpio_pin.OUT, True)
    self.nint   = gpio_pin(pins.NINT,   gpio_pin.OUT, True)
    self.nef1   = gpio_pin(pins.NEF1,   gpio_pin.OUT, True)

    # Set up various indicators as inputs for the Pi to read
    self.tpa    = gpio_pin(pins.TPA,  gpio_pin.IN)
    self.tpb    = gpio_pin(pins.TPB,  gpio_pin.IN)
    self.sc0    = gpio_pin(pins.SC0,  gpio_pin.IN)
    self.nmrd   = gpio_pin(pins.NMRD, gpio_pin.IN)
    self.nmwr   = gpio_pin(pins.NMWR, gpio_pin.IN)
    self.n2     = gpio_pin(pins.N2,   gpio_pin.IN)
    self.qout   = gpio_pin(pins.QOUT, gpio_pin.IN)

    # Set up the memory addresses as input for the Pi to read
    self.ma0    = gpio_pin(pins.MA0, gpio_pin.IN)
    self.ma1    = gpio_pin(pins.MA1, gpio_pin.IN)
    self.ma2    = gpio_pin(pins.MA2, gpio_pin.IN)
    self.ma3    = gpio_pin(pins.MA3, gpio_pin.IN)
    self.ma4    = gpio_pin(pins.MA4, gpio_pin.IN)
    self.ma5    = gpio_pin(pins.MA5, gpio_pin.IN)
    self.ma6    = gpio_pin(pins.MA6, gpio_pin.IN)
    self.ma7    = gpio_pin(pins.MA7, gpio_pin.IN)
    self.addr = pin_group ( [self.ma7, self.ma6, self.ma5, self.ma4, self.ma3, self.ma2, self.ma1, self.ma0] )

    # Set up the data lines as bidirectional (with default NOP)
    self.d0     = gpio_pin(pins.D0, gpio_pin.BOTH, False)
    self.d1     = gpio_pin(pins.D1, gpio_pin.BOTH, False)
    self.d2     = gpio_pin(pins.D2, gpio_pin.BOTH, True)
    self.d3     = gpio_pin(pins.D3, gpio_pin.BOTH, False)
    self.d4     = gpio_pin(pins.D4, gpio_pin.BOTH, False)
    self.d5     = gpio_pin(pins.D5, gpio_pin.BOTH, False)
    self.d6     = gpio_pin(pins.D6, gpio_pin.BOTH, True)
    self.d7     = gpio_pin(pins.D7, gpio_pin.BOTH, True)
    self.data = pin_group ( [self.d7, self.d6, self.d5, self.d4, self.d3, self.d2, self.d1, self.d0] )

    self.ma_addr = 0
    self.addr_hi = 0
    self.addr_lo = 0
    self.cur_addr = 0
    self.n2_hi = 0
    self.n_mrd = 1
    self.n_mwr = 1
    self.tpb_now = 0
    self.tpb_hi = 0
    self.out4_val = None
    self.io_as_hex = False
    self.trace_exec = False
    self.stop_on_idle = False
    self.dump_mem = False

  def reset ( self ):
    # Assert the "Reset" line and pause
    self.nclear.set_val ( False )
    time.sleep ( 0.001 )

    # Run the clock while in reset
    self.full_clock(32)

    # Ensure that the clock starts off low
    self.clock.set_val ( False )

    # Release the "Reset" line to let the 1802 start running
    self.nclear.set_val ( True )
    self.num_half_clocks = 0
    time.sleep ( 0.001 )

  # Define a function to verify that all data lines are inputs
  def all_data_are_inputs(self):
    all_in = True
    if self.d7.cur_dir != self.d7.IN: all_in = False;
    if self.d6.cur_dir != self.d6.IN: all_in = False;
    if self.d5.cur_dir != self.d5.IN: all_in = False;
    if self.d4.cur_dir != self.d4.IN: all_in = False;
    if self.d3.cur_dir != self.d3.IN: all_in = False;
    if self.d1.cur_dir != self.d1.IN: all_in = False;
    if self.d0.cur_dir != self.d0.IN: all_in = False;
    return ( all_in )

  # Define a function to print a header for logged pins
  def get_header_string(self):
    s = "nCL CLK TPA TPB SC0 nRD nWR N2 ma7 ma6 ma5 ma4 ma3 ma2 ma1 ma0 aIN d7 d6 d5 d4 d3 d2 d1 d0 Q"
    return ( s )

  def get_vheader_string(self):
    s  = "C C T T S n n N m m m m m m m m a d d d d d d d d\n"
    s += "L L P P C R W   a a a a a a a a I\n"
    s += "# K A B 0 D R 2 7 6 5 4 3 2 1 0 N 7 6 5 4 3 2 1 0 Q"
    return ( s )

  def get_js_header_string(self):
    s = "document.getElementById('timing_header_area').value = \"" + self.get_header_string() + "\";\n"
    s += "document.getElementById('timing_data_area').value = \"\" \n"
    return ( s )

  # Define a function to log the pin values
  def get_data_string ( self ):
    s   =   str(str((int(self.num_half_clocks/2))%8) + ' ' +
            str(bival(self.clock.get_val())) + ' ' +
            str(self.tpa.get_val()) + ' ' +
            str(self.tpb.get_val()) + ' ' +
            str(self.sc0.get_val()) + ' ' +
            str(self.nmrd.get_val()) + ' ' +
            str(self.nmwr.get_val()) + ' ' +
            str(self.n2.get_val()) + ' ' +
            str(self.ma7.get_val()) + ' ' +
            str(self.ma6.get_val()) + ' ' +
            str(self.ma5.get_val()) + ' ' +
            str(self.ma4.get_val()) + ' ' +
            str(self.ma3.get_val()) + ' ' +
            str(self.ma2.get_val()) + ' ' +
            str(self.ma1.get_val()) + ' ' +
            str(self.ma0.get_val()) + ' ' +
            str(bival(self.all_data_are_inputs())) + ' ' +
            str(bival(self.d7.get_val_safe())) + ' ' +
            str(bival(self.d6.get_val_safe())) + ' ' +
            str(bival(self.d5.get_val_safe())) + ' ' +
            str(bival(self.d4.get_val_safe())) + ' ' +
            str(bival(self.d3.get_val_safe())) + ' ' +
            str(bival(self.d2.get_val_safe())) + ' ' +
            str(bival(self.d1.get_val_safe())) + ' ' +
            str(bival(self.d0.get_val_safe())) + ' ' +
            str(self.qout.get_val()))
    return ( s )

  def get_state ( self ):
    # Execute a fixed set of instructions to extract state and return to starting point
    print ( "Top of get_state" )

    # Start by continuing to execute the current program until TPA is high and SC0 is low
    while (not self.tpa.get_val()) and (not self.sc0.get_val()):
      self.clock.toggle()
      time.sleep ( self.clock_time )
      self.update()
      # time.sleep ( self.clock_time )
      self.num_half_clocks += 1

    print ( "TPA should be high and SC0 low" )

    # The 1802 is now preparing to fetch the next instruction
    # This is the return location after collecting the internal state information

    # Collect the high address while TPA is high
    hi_addr = 0
    while self.tpa.get_val():
      # Get the current address lines from the 1802
      a0 = self.ma0.get_val()
      a1 = self.ma1.get_val()
      a2 = self.ma2.get_val()
      a3 = self.ma3.get_val()
      a4 = self.ma4.get_val()
      a5 = self.ma5.get_val()
      a6 = self.ma6.get_val()
      a7 = self.ma7.get_val()
      hi_addr = (a7 << 7) | (a6 << 6) | (a5 << 5) | (a4 << 4) | (a3 << 3) | (a2 << 2) | (a1 << 1) | a0
      self.half_clock_only(1)

    print ( "Got the high address = " + hex2(hi_addr) )

    # TPA is now complete, so wait for the start of TPB
    while not self.tpb.get_val():
      self.half_clock_only(1)

    print ( "Got TPB" )

    # The Not Memory Read line should be low
    if not self.nmrd.get_val():
      print ( "Unexpected condition: nMRD is high but should be low" )
      return

    print ( "Memory Read is low" )

    # The Not Memory Read line is low, so present the next instruction on the data bus
    mem_out = 0x30
    # Put the instruction onto the data bus
    self.d7.set_val ( (mem_out>>7) & 0x01 )
    self.d6.set_val ( (mem_out>>6) & 0x01 )
    self.d5.set_val ( (mem_out>>5) & 0x01 )
    self.d4.set_val ( (mem_out>>4) & 0x01 )
    self.d3.set_val ( (mem_out>>3) & 0x01 )
    self.d2.set_val ( (mem_out>>2) & 0x01 )
    self.d1.set_val ( (mem_out>>1) & 0x01 )
    self.d0.set_val ( (mem_out>>0) & 0x01 )

    print ( "Present data on the data bus" )

    # Continue to present the data while Memory Read line is low and save the low address
    lo_addr = 0
    while not self.nmrd.get_val():
      # Get the current address lines from the 1802
      a0 = self.ma0.get_val()
      a1 = self.ma1.get_val()
      a2 = self.ma2.get_val()
      a3 = self.ma3.get_val()
      a4 = self.ma4.get_val()
      a5 = self.ma5.get_val()
      a6 = self.ma6.get_val()
      a7 = self.ma7.get_val()
      lo_addr = (a7 << 7) | (a6 << 6) | (a5 << 5) | (a4 << 4) | (a3 << 3) | (a2 << 2) | (a1 << 1) | a0
      self.half_clock_only(1)

    # The hi_addr and lo_addr should contain the return address
    # From here onward, there is no need to collect any more address information
    print ( "Return Addr: " + hex2(hi_addr) + " " + hex2(lo_addr) )

    # Convert the Raspberry Pi data lines to read mode with calls to get_val()
    self.d7.get_val()
    self.d6.get_val()
    self.d5.get_val()
    self.d4.get_val()
    self.d3.get_val()
    self.d2.get_val()
    self.d1.get_val()
    self.d0.get_val()

    # Wait for the next read to produce the jump address
    while self.nmrd.get_val():
      self.half_clock_only(1)

    # The Not Memory Read line is low, so present the jump address on the data bus
    mem_out = 0x00
    # Put the data onto the data bus
    self.d7.set_val ( (mem_out>>7) & 0x01 )
    self.d6.set_val ( (mem_out>>6) & 0x01 )
    self.d5.set_val ( (mem_out>>5) & 0x01 )
    self.d4.set_val ( (mem_out>>4) & 0x01 )
    self.d3.set_val ( (mem_out>>3) & 0x01 )
    self.d2.set_val ( (mem_out>>2) & 0x01 )
    self.d1.set_val ( (mem_out>>1) & 0x01 )
    self.d0.set_val ( (mem_out>>0) & 0x01 )

    # Continue to present the data while Memory Read line is low
    while not self.nmrd.get_val():
      self.half_clock_only(1)

    # Return to normal processing
    return


  def update ( self ):
    # Get the current address lines from the 1802
    a0 = self.ma0.get_val()
    a1 = self.ma1.get_val()
    a2 = self.ma2.get_val()
    a3 = self.ma3.get_val()
    a4 = self.ma4.get_val()
    a5 = self.ma5.get_val()
    a6 = self.ma6.get_val()
    a7 = self.ma7.get_val()
    self.ma_addr = (a7 << 7) | (a6 << 6) | (a5 << 5) | (a4 << 4) | (a3 << 3) | (a2 << 2) | (a1 << 1) | a0

    if self.tpa.get_val():
      # Keep saving the high address inside the TPA active region.
      self.addr_hi = self.ma_addr
      self.cur_addr = (self.addr_hi<<8)|self.addr_lo
      # print ( "Addr at TPA: " + str(self.cur_addr) + " = " + str(self.addr_hi) + " + " + str(self.addr_lo) )

    if True:  # or self.tpb.get_val():
      # Keep saving the low address always?
      self.addr_lo = self.ma_addr
      self.cur_addr = (self.addr_hi<<8)|self.addr_lo
      # print ( "Addr at TPB: " + str(self.cur_addr) + " = " + str(self.addr_hi) + " + " + str(self.addr_lo) )

    if self.n2.get_val():
      # Preserve the fact that n2 was high
      self.n2_hi = 1
      # Also preserve the last sample while high
      db7 = self.d7.get_val()
      db6 = self.d6.get_val()
      db5 = self.d5.get_val()
      db4 = self.d4.get_val()
      db3 = self.d3.get_val()
      db2 = self.d2.get_val()
      db1 = self.d1.get_val()
      db0 = self.d0.get_val()
      self.out4_val = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
    else:
      if self.n2_hi != 0:
        # n2 had been high, but just went low, so output
        if self.io_as_hex:
          xout = hex(self.out4_val).upper()[2:]
          if len(xout) < 2:
            xout = '0' + xout
          print ( xout )
        else:
          print ( str(self.out4_val) )
        # Reset  n2_hi and out4_val
        self.n2_hi = 0
        self.out4_val = None


    # Get /MRD and /MRW for later use
    self.n_mrd = self.nmrd.get_val()
    self.n_mwr = self.nmwr.get_val()

    if self.n_mrd:
        # Not Memory Read is high, so the 1802 isn't reading (and may be writing)
        # Convert the Raspberry Pi data lines to read mode with a call to get_val()
        db7 = self.d7.get_val()
        db6 = self.d6.get_val()
        db5 = self.d5.get_val()
        db4 = self.d4.get_val()
        db3 = self.d3.get_val()
        db2 = self.d2.get_val()
        db1 = self.d1.get_val()
        db0 = self.d0.get_val()

        if not self.n_mwr:
          # The 1802 wants to write to memory, so convert the data and write it to memory
          data_byte = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
          self.mem.mem[self.cur_addr] = data_byte
          # print ( "Setting mem[" + str(self.cur_addr) + "] to " + str(data_byte) )

    else:
        # The 1802 wants to read from memory (instruction or data)
        # Present the requested byte to the data bus
        mem_out = self.mem.mem[self.cur_addr]

        # Put the instruction onto the data bus
        self.d7.set_val ( (mem_out>>7) & 0x01 )
        self.d6.set_val ( (mem_out>>6) & 0x01 )
        self.d5.set_val ( (mem_out>>5) & 0x01 )
        self.d4.set_val ( (mem_out>>4) & 0x01 )
        self.d3.set_val ( (mem_out>>3) & 0x01 )
        self.d2.set_val ( (mem_out>>2) & 0x01 )
        self.d1.set_val ( (mem_out>>1) & 0x01 )
        self.d0.set_val ( (mem_out>>0) & 0x01 )

    self.tpb_now = self.tpb.get_val()
    if self.tpb_now:
      self.tpb_hi = 1
    else:
      if self.tpb_hi:
        self.tpb_hi = 0
        if self.trace_exec or self.stop_on_idle:
          if not self.sc0.get_val():
            # Get the value on the data bus
            db7 = self.d7.get_val()
            db6 = self.d6.get_val()
            db5 = self.d5.get_val()
            db4 = self.d4.get_val()
            db3 = self.d3.get_val()
            db2 = self.d2.get_val()
            db1 = self.d1.get_val()
            db0 = self.d0.get_val()
            data_byte = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
            if self.trace_exec:
              print ( "Fetch at addr " + hex4(self.cur_addr) + " got " + hex2(data_byte) + " = " + self.instr_set.get_instr(hex2(data_byte),self.cur_addr,self.mem.mem) )
            if self.stop_on_idle:
              if data_byte == 0:
                #break
                pass

    #if self.dump_data:
    #  print_data ( "1" ) # notCLEAR is 0
    #if self.dump_js and (js_data_file != None):
    #  js_data_file.write ( " + \"" + get_data_string ( "1" ) + "\\n\"\n" );


  def half_clock_only(self, n):
    # Just clock with no updates
    for i in range(n):
      self.clock.toggle()
      time.sleep ( self.clock_time )

  def half_clock(self, n):
    for i in range(n):
      self.clock.toggle()
      time.sleep ( self.clock_time )
      self.update()
      # time.sleep ( self.clock_time )
      self.num_half_clocks += 1

  def full_clock(self, n):
    for i in range(n):
      self.half_clock(1)
      self.half_clock(1)

  def ensure_clock(self, state):
    if self.clock.get_val() != state:
      self.half_clock(1)

  def ensure_sc0(self, state):
    while self.sc0.get_val() != state:
      self.half_clock(1)

  def cycle_sc0(self, n):
    initial_sc0 = self.sc0.get_val()
    self.ensure_sc0(not initial_sc0)
    self.ensure_sc0(initial_sc0)

  def machine_cycle(self, n):
    for i in range(n):
      # Start by moving to the next high value of TPB
      while not self.tpb.get_val():
        self.half_clock(1)
      # Look for the transition of TPB from high to low
      while self.tpb.get_val():
        self.half_clock(1)
      # Should be at the edge of next machine cycle

  def not_clear_low(self):
    self.nclear.set_val ( False )
    time.sleep ( 0.00001 )
    # It's not clear whether it makes sense to zero here
    self.num_half_clocks = 0

  def not_clear_high(self):
    self.nclear.set_val ( True )
    time.sleep ( 0.00001 )
    # It's not clear whether it makes sense to zero here
    self.num_half_clocks = 0


class instruction_set:
  def __init__ ( self ):
    self.inst_proc_table = [ # InstructionName, OpCode, NumAdditionalBytes
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

  def get_instr(self, hx, addr, memory):
    best_instr = ""
    best_instr_index = -1
    # Start by looking for an exact match
    for i in range(len(self.inst_proc_table)):
      if hx.upper() == self.inst_proc_table[i][1]:
        best_instr = self.inst_proc_table[i][0];
        best_instr_index = i;
    if best_instr_index < 0:
      # No exact match, so look for a match of first digit only
      for i in range(len(self.inst_proc_table)):
        if hx[0].upper() == self.inst_proc_table[i][1][0].upper():
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
          elif (self.inst_proc_table[i][1][1].upper() == 'N'):
            best_instr = self.inst_proc_table[i][0].upper() + " " + hx[1].upper();
            best_instr_index = i;
          else:
            best_instr = self.inst_proc_table[i][0].upper();
            best_instr_index = i;
    if best_instr_index >= 0:
      # Handle Immediate Operands of 1 or 2 bytes
      if self.inst_proc_table[best_instr_index][2] > 0:
        best_instr = best_instr + " " + hex2(memory[addr+1]);
        if self.inst_proc_table[best_instr_index][2] > 1:
          best_instr = best_instr + " " + hex2(memory[addr+2]);
    return ( best_instr );



##### Define the 1802 CPU #####
cpu = cdp1802(0.0001)  # This sets the clock time (not same as sleep settling time)

##### Process Command Line Parameters #####

def command_help():
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

if len(sys.argv) > 1:
  # print ( "Arguments: " + str(sys.argv) )
  for arg in sys.argv:
    # print ("  " + str(arg))

    if arg == "help":
      command_help()
      sys.exit ( 0 )

    #if arg == "d":
    #  dump_data = True

    if arg == "t":
      cpu.trace_exec = True

    #if arg == "p":
    #  open_console = True

    #if arg.startswith("c="):
    #  clock_time = float(arg[2:])
      # print ( "Arg sets clock_time = " + str(clock_time) )

    #if arg.startswith("n="):
    #  num_clocks = int(arg[2:])
    #  # print ( "Arg sets num_clocks = " + str(num_clocks) )

    #if arg == "js":
    #  dump_file = open ( "data.js", "w" )

    #if arg == "dm":
    #  dump_mem = True

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
      cpu.mem.load ( src_txt )


##### Begin Interactive Mode #####

cmd = ''
lastcmdline = ''
while (cmd.lower() != 'x') and (cmd.lower() != 'q'):
  cmdline = get_input ( "> " ).strip()
  if len(cmdline) <= 0:
    # print ( "Repeating last command" )
    cmdline = lastcmdline
  if len(cmdline) > 0:
    cmds = [c.strip() for c in cmdline.split(';')]
    for cmd in cmds:
      if (cmd[0].lower() == '?') or (cmd.split()[0].lower() == 'help'):
        print ( "Commands (exit with control-C):" )
        print ( "   - No input repeats previous command" )
        print ( " ? - Print help information" )
        print ( " p - Drop into Python (exit Python with Control-D)" )
        print ( " r - Reset the 1802" )
        print ( " d - Dump pin state of the 1802" )
        print ( " g - Get the internal state of the 1802" )
        print ( " t l - Toggle clock to low (only toggle if needed)" )
        print ( " t h - Toggle clock to high (only toggle if needed)" )
        print ( " t [n] - Toggle clock n times (essentially n half clocks)" )
        print ( " c [n] - Cycle clock n times (essentially n full clocks)" )
        print ( " s l - Toggle clock until State Code 0 is low (only as needed)" )
        print ( " s h - Toggle clock until State Code 0 is high (only as needed)" )
        print ( " s [n] - Cycle State Code 0 n times (essentially n instructions)" )
        print ( " m [n] - Execute next n machine cycles (based off of TPB)" )
        print ( " [addr] - Show memory at address addr" )
        print ( " [a1-a2] - Show memory from address a1 to address a2" )
        print ( " [addr] = # # ... # - Set memory starting at address addr" )
        print ( " [a1-a2] = # # ... # - Set memory from address a1 to address a2" )
        print ( " f name - Load file name into RAM" )

      elif cmd[0].lower() == 'p':
        __import__('code').interact(local={k: v for ns in (globals(), locals()) for k, v in ns.items()})

      elif cmd[0].lower() == 'r':
        cpu.reset()

      elif cmd[0].lower() == 'd':
        print ( cpu.get_vheader_string() )
        print ( cpu.get_data_string() )

      elif cmd[0].lower() == 'g':
        cpu.get_state()

      elif cmd[0].lower() == 't':
        if cmd.lower() == 't':
          # Force a t1 if t is entered without a parameter
          cmd = "t1"
        n = 1
        if len(cmd) > 1:
          subcmd = cmd[1:].strip()
          if subcmd.lower() == 'h':
            cpu.ensure_clock(True)
          elif subcmd.lower() == 'l':
            cpu.ensure_clock(False)
          else:
            n = int ( cmd[1:].strip() )
            cpu.half_clock(n)

      elif cmd[0].lower() == 'c':
        if cmd.lower() == 'c':
          # Force a c1 if c is entered without a parameter
          cmd = "c1"
        n = 1
        if len(cmd) > 1:
          n = int ( cmd[1:].strip() )
        cpu.full_clock(n)

      elif cmd[0].lower() == 's':
        if cmd.lower() == 's':
          # Force a s1 if s is entered without a parameter
          cmd = "s1"
        n = 1
        if len(cmd) > 1:
          subcmd = cmd[1:].strip()
          if subcmd.lower() == 'h':
            cpu.ensure_sc0(True)
          elif subcmd.lower() == 'l':
            cpu.ensure_sc0(False)
          else:
            n = int ( cmd[1:].strip() )
            cpu.cycle_sc0(n)

      elif cmd[0].lower() == 'm':
        if cmd.lower() == 'm':
          # Force an m1 if m is entered without a parameter
          cmd = "m1"
        n = 1
        if len(cmd) > 1:
          n = int ( cmd[1:].strip() )
          cpu.machine_cycle(n)

      elif cmd[0].lower() == 'f':
        fname = cmd[1:].strip()
        if len(fname) > 0:
          f = open(fname,"r")
          src_txt = f.read()
          f.close()
          if len(src_txt) > 0:
            cpu.mem.load ( src_txt )

      elif cmd[0] == '[':
        if "=" in cmd:
          # Assign values to memory
          parts = cmd.split('=')
          # First split the right side
          vals = [int(v,16) for v in parts[1].split()]
          # Now determine if the left side is a single address or a range
          if '-' in parts[0]:
            # A target range means copy repeatedly to fill range
            a1 = int ( parts[0].strip().split("-")[0][1:], 16 )
            a2 = int ( parts[0].strip().split("-")[1][0:-1], 16 )
            v = 0
            for a in range(a1,a2+1):
              cpu.mem.mem[a] = vals[(a-a1) % len(vals)]
          else:
            # A target address means copy once
            a = int ( parts[0].strip()[1:-1], 16 )
            for i in range(len(vals)):
              cpu.mem.mem[a+i] = vals[i]
        elif "-" in cmd:
          # Show a range of memory
          a1 = int ( cmd.strip().split("-")[0][1:], 16 )
          a2 = int ( cmd.strip().split("-")[1][0:-1], 16 )
          for a in range(a1,a2+1):
            print ( "  Mem[" + hex(a)[2:] + "] = " + hex(cpu.mem.mem[a])[2:] )
        else:
          # Show a single address
          a = int ( cmd.strip()[1:-1], 16 )
          print ( "  Mem[" + hex(a)[2:] + "] = " + hex(cpu.mem.mem[a])[2:] )

      else:
        if (cmd.lower() != 'x') and (cmd.lower() != 'q'):
          print ( "Unknown command: " + cmd )

    lastcmdline = cmdline


'''

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
      print ( "Loading:\n" + (40*'=') + '\n' + src_txt + (40*'=') + '\n' )

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
              for i in range(int(len(checked_data)/2)):
                i2 = 2*i
                c = c + int(checked_data[i2:i2+2],16)
              if (c & 0xff) != 0:
                print ( "Checksum error on line " + ln )
                exit ( 3 )
              # Set the starting location to get this data
              next_mem_loc = addr;
              if rectyp == 0:
                # Store the data in RAM
                for i in range(int(len(dt)/2)):
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


def print_data(ncl):
  s = cpu.get_data_string(ncl)
  if dump_file != None:
    dump_file.write ( " + \"" + s + "\\n\"\n" );
  print ( s )

addr_hi = 0
n2_hi = 0
out4_val = None
tpb_hi = 0


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
        # This is the falling edge of TPB
        tpb_hi = 0
        if trace_exec:
          if not sc0.get_val():
            # SC0 low means a fetch
            db7 = d7.get_val()
            db6 = d6.get_val()
            db5 = d5.get_val()
            db4 = d4.get_val()
            db3 = d3.get_val()
            db2 = d2.get_val()
            db1 = d1.get_val()
            db0 = d0.get_val()
            data_byte = (db7 << 7) | (db6 << 6) | (db5 << 5) | (db4 << 4) | (db3 << 3) | (db2 << 2) | (db1 << 1) | db0
            print ( "Fetch at addr " + hex4((addr_hi<<8) | addr) + " got " + hex2(data_byte) + " = " + get_instr(hex2(data_byte),addr) )

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
    print ( get_vheader_string() + "\n" )
  if dump_file != None:
    dump_file.write ( get_js_header_string() )

'''

'''
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
'''

