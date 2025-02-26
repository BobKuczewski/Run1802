#!/usr/bin/python

# This file provides definitions to replace the GPIO module
# This allows the code to run outside the Raspberry Pi
# This module also provides a simple "Fake 1802"

import Pi_to_1802 as pins
from inspect import getmembers

BCM = "FakeBCM"
IN = "FakeIn"
OUT = "FakeOut"
PUD_OFF = "FakePUD_OFF"

verbose = False

class fake_1802_sim:
  def __init__ (self):
    self.clock_val = 0
    self.clock_count = 0
    self.memory = None
    self.end_of_loaded_code = 0
    self.pin_dict = {"NMRD":1,"NMWR":1}
    self.output_data = [ 10,10, 50,10, 50,50, 10,50, 10,10 ] # Continuous Square
    self.output_data = [ 2, 10,50, 50,50, 4, 100,10, 100,20, 110,20, 110,30 ] # PolyLines Steps
    self.output_data = [ 1,1,1, 2,255,1, 2,255,255, 2,1,255, 2,1,1 ] # MoveDraw Box
    # Draw a red box near the borders of the screen: 03 ff0000 01 0101 02 ff01 02 ffff 02 01ff 02 0101
    self.output_data = [ 4,0,0,0, 1,90,34, 3,255,0,0, 2,60,106, 3,0,255,0, 2,153,106, 3,0,0,255, 1,116,58, 2,116,153 ] # MoveDraw 4
    self.output_index = -3 # Allows time before drawing starts

  def load_output_from_RAM ( self, end_of_loaded_code ):
    # Use the values in memory
    print ( "Loading output data from memory up to " + str(end_of_loaded_code) )
    if self.memory != None:
      self.output_data = [m for m in self.memory[0:end_of_loaded_code]]
      print ( "Program:" )
      print ( str(self.output_data) )

  def get_name_of_pin ( self, pin_num ):
    pins_members = getmembers(pins)
    for i in range(len(pins_members)):
      if pins_members[i][1] == pin_num:
        return ( pins_members[i][0] )
    return ( None )

  def input(self, gpio):
    pin_name = str(fake_1802.get_name_of_pin(gpio))
    val = 0
    if pin_name in self.pin_dict:
      val = self.pin_dict[pin_name]
    if verbose:
      print ( "FakeGPIO: input  called at clock " + str(self.clock_count) +
              " for GPIO " + str(gpio) +
              " defined as " + pin_name + " returning " + str(val) )
    return val

  def output(self, gpio, val):
    pin_name = str(fake_1802.get_name_of_pin(gpio))
    self.pin_dict[pin_name] = val
    if verbose:
      print ( "FakeGPIO: output called at clock " + str(self.clock_count) +
              " for GPIO " + str(gpio) +
              " defined as " + pin_name + " with value of " + str(val) )
    if pin_name == "CLOCK":
      if self.clock_val == 0:
        self.clock_count += 1
      self.clock_val = val
      # print ( "Clock tick val=" + str(val) + ", count=" + str(self.clock_count) )
      if (self.clock_count % 8) == 7:
        if self.clock_val == 0:
          # Output the next value in the list
          self.output_index += 1
          print ( "\nIncremented output_index to " + str(self.output_index) + "\n" )
        if self.output_index >= 0:
          # Produce the output for this clock
          self.pin_dict['N2'] = 1
          out_val = self.output_data[self.output_index % len(self.output_data)]
          for i in range(8):
            self.pin_dict['D'+str(i)] = (out_val >> i) & 0x01;
      else:
        self.pin_dict['N2'] = 0
        for i in range(8):
          self.pin_dict['D'+str(i)] = 0;


fake_1802 = fake_1802_sim()

def setwarnings(val):
  if verbose:
    #print ( "FakeGPIO: setwarnings called with " + str(val) )
    pass

def setmode(val):
  if verbose:
    print ( "FakeGPIO: setmode called with " + str(val) )

def setup(gpio, direction, initial=None, pull_up_down=None):
  pin_name = str(fake_1802.get_name_of_pin(gpio))
  if verbose:
    print ( "FakeGPIO: setup  called for pin  " + str(gpio) +
            " defined as " + pin_name )

def input(gpio):
  return ( fake_1802.input(gpio) )

def output(gpio, val):
  return ( fake_1802.output(gpio,val) )

