#!/usr/bin/python

# This file provides definitions to replace the GPIO module
# This allows the code to run outside the Raspberry Pi

BCM = None
IN = None
OUT = None
PUD_OFF = None

def setwarnings(val):
  pass

def setmode(val):
  pass

def setup(gpio, direction, initial=None, pull_up_down=None):
  pass

def input(gpio):
  return 0
  pass

def output(gpio, val):
  pass

