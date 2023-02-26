/*
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
# 19 |35  36| 16  w27
# 26 |37  38| 20  w28
#  G |39  40| 21  w29
*/

#include <stdio.h>
#include <wiringPi.h>


// Initially all GPIO pins are configured as inputs

int main ( void ) {
  printf ( "Raspberry Pi using WiringPi library\n" );
  if (wiringPiSetup() == -1)
    return 1;

  int PIN = 29;
  for (PIN=0; PIN<=40; PIN++) {
    printf ( "Setting pin number to %d.\n", PIN );
    pinMode ( PIN, OUTPUT );
    int i;
    for (i=0; i<2; i++) {
      digitalWrite ( PIN, 1 );
      delay(250);
      digitalWrite ( PIN, 0 );
      delay(250);
      digitalWrite ( PIN, 1 );
      delay(250);
      digitalWrite ( PIN, 0 );
      delay(250);
    }
  }
  return ( 0 );
}
