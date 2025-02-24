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
    self.pin_dict = {"NMRD":1,"NMWR":1}
    self.output_data = [ 18, 02 ]
    self.output_index = -3;

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
      print ( "Clock tick val=" + str(val) + ", count=" + str(self.clock_count) )
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

