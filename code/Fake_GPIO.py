#!/usr/bin/python

# This file provides definitions to replace the GPIO module
# This allows the code to run outside the Raspberry Pi

BCM = "FakeBCM"
IN = "FakeIn"
OUT = "FakeOut"
PUD_OFF = "FakePUD_OFF"

verbose = False

def setwarnings(val):
  if verbose:
    print ( "FakeGPIO: setwarnings called with " + str(val) )

def setmode(val):
  if verbose:
    print ( "FakeGPIO: setmode called with " + str(val) )

def setup(gpio, direction, initial=None, pull_up_down=None):
  if verbose:
    print ( "FakeGPIO: setup called for GPIO " + str(gpio) )

def input(gpio):
  if verbose:
    print ( "FakeGPIO: input called for GPIO " + str(gpio) )
  return 0

def output(gpio, val):
  if verbose:
    print ( "FakeGPIO: output called for GPIO " + str(gpio) +
            " with value of " + str(val) )

