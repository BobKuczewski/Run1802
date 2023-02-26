/*
# This program clocks the 1802 to see how fast it can go

# ======= Raspberry Pi =======
# GPIO/Pin numbering (note that GPIO0/P27 only works as GPIO0)
# Outer  2 values are wiringPi GPIO numbers (wiring numbering)
# Middle 2 values are BroadCom (BCM) numbering GPIO 0-27 (BCM numbering)
# Inner  2 values are pin number on Raspberry Pi connector (Board numbering)
#         SDCard
#     +3 |1    2| +5
#  w8  2 |3    4| +5
#  w9  3 |5    6| G
#  w7  4 |7    8| 14 15w
#      G |9   10| 15 16w
#  w0 17 |11  12| 18  1w
#  w2 27 |13  14| G
#  w3 22 |15  16| 23  4w
#     +3 |17  18| 24  5w
# w12 10 |19  20| G
# w13  9 |21  22| 25  6w
# w14 11 |23  24| 8  10w
#      G |25  26| 7  11w
# w30  0 |27  28| 1  31w
# w21  5 |29  30| G
# w22  6 |31  32| 12 26w
# w23 13 |33  34| G
# w24 19 |35  36| 16 27w
# w25 26 |37  38| 20 28w
#      G |39  40| 21 29w
*/

#include <stdio.h>
#include <wiringPi.h>


// Initially all GPIO pins are configured as inputs

int main ( void ) {
  printf ( "Raspberry Pi using WiringPi library\n" );
  if (wiringPiSetup() == -1)
    return 1;

  int PIN = 29;
  int i;

  for (i=0; i<1000000; i++) {
    for (PIN=0; PIN<=40; PIN++) {
      digitalWrite ( PIN, i%2 );
      delay(1);
    }
    delay(100);
  }
  return ( 0 );
}
