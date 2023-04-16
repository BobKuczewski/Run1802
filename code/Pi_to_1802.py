#!/usr/bin/python


# GPIO/Pin numbering (note that GPIO0/P27 only works as GPIO0)
# Outer 2 values are GPIO 0-27 (BCM numbering)
# Inner 2 values are pin number on connector (BRD numbering)
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

CLOCK   = 26
NCLEAR  = 22

NDMAI   = 21
NINT    = 20

TPA     = 25
TPB     = 24
SC0     = 27
NMRD    = 17
NMWR    = 16
N2      = 18

MA0     =  0
MA1     =  1
MA2     =  2
MA3     =  3
MA4     =  4
MA5     =  5
MA6     =  6
MA7     =  7

D0      =  8
D1      =  9
D2      = 10
D3      = 11
D4      = 12
D5      = 13
D6      = 14
D7      = 15

QOUT    = 19
