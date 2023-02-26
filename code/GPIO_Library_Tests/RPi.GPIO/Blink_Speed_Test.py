#!/usr/bin/python

# This program clocks the 1802 to see how fast it can go

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

# Initially all GPIO pins are configured as inputs

import time
import RPi.GPIO as GPIO

# Use the Broadcom numbering shown on Pi ribbon connector plug.
GPIO.setmode(GPIO.BCM)

GPIO.setwarnings(False) # Disable when setting up
GPIO.setup(21, GPIO.OUT)
GPIO.setwarnings(True)  # Enable after setting up

GPIO.output ( 21, 1 ) # Show a brief flash
time.sleep ( 0.5 )
GPIO.output ( 21, 0 ) # Turn back off
time.sleep ( 0.5 )

# Start running
nrun = 1000000
ts = time.time()
for i in range(nrun):
  GPIO.output ( 21, i % 2 )
te = time.time()
GPIO.output ( 21, 0 ) # Turn back off

print ( "Ran " + str(nrun) + " cycles in " + str(te-ts) + " seconds at " + str(nrun/(te-ts)) + " cycles per second" )

#__import__('code').interact(local={k: v for ns in (globals(), locals()) for k, v in ns.items()})

'''
$ python Blink_Speed_Test.py 
Ran 1000000 cycles in 8.8112847805 seconds at 113490.827378 cycles per second
$ python Blink_Speed_Test.py 
Ran 1000000 cycles in 8.53957390785 seconds at 117101.86138 cycles per second
$ python Blink_Speed_Test.py 
Ran 1000000 cycles in 9.41733694077 seconds at 106187.131913 cycles per second
$
'''
