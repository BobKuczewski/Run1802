#!/usr/bin/python

# This file provides definitions to replace the GPIO module
# This allows the code to run outside the Raspberry Pi

BCM = "FakeBCM"
IN = "FakeIn"
OUT = "FakeOut"
PUD_OFF = "FakePUD_OFF"

verbose = False

import Pi_to_1802 as pins
from inspect import getmembers

def get_name_of_pin ( pin_num ):
  pins_members = getmembers(pins)
  for i in range(len(pins_members)):
    if pins_members[i][1] == pin_num:
      return ( pins_members[i][0] )
  return ( None )

def setwarnings(val):
  if verbose:
    #print ( "FakeGPIO: setwarnings called with " + str(val) )
    pass

def setmode(val):
  if verbose:
    print ( "FakeGPIO: setmode called with " + str(val) )

def setup(gpio, direction, initial=None, pull_up_down=None):
  if verbose:
    print ( "FakeGPIO: setup called for pin " + str(gpio) + " defined as " + str(get_name_of_pin(gpio)) )

def input(gpio):
  if verbose:
    print ( "FakeGPIO: input called for GPIO " + str(gpio) + " returning 0" )
  return 0

def output(gpio, val):
  if verbose:
    print ( "FakeGPIO: output called for GPIO " + str(gpio) +
            " with value of " + str(val) )

