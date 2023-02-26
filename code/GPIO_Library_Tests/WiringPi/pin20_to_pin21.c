/*
# This program tests the speed of sending data between two GPIO pins.

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
*/

// Initially all GPIO pins are configured as inputs

#include <time.h>
#include <stdio.h>
#include <wiringPi.h>

int main ( void ) {
  double start, end;
  int i, temp;
  int PIN_OUT = 28;
  int PIN_IN = 29;

  printf ( "Raspberry Pi using WiringPi library\n" );
  if (wiringPiSetup() == -1) {
    printf ( "WiringPi initialization failed\n" );
    return 1;
  }

  printf ( "Testing direct transfer speed from GPIO 20 to GPIO 21.\n" );

  printf ( "Setting output pin to %d.\n", PIN_OUT );
  pinMode ( PIN_OUT, OUTPUT );
  printf ( "Setting input pin to %d.\n", PIN_IN );
  pinMode ( PIN_IN, INPUT );

  start = clock();
  for (i=0; i<1000000; i++) {
    digitalWrite ( PIN_OUT, 1 );
    do {} while (digitalRead(PIN_IN) == 0);
    digitalWrite ( PIN_OUT, 0 );
    do {} while (digitalRead(PIN_IN) != 0);
  }
  end = clock();
  printf ( "Direct transfer result: dt = %f\n", (end-start)/CLOCKS_PER_SEC );

  printf ( "Testing alternating transfer speed between GPIO 20 and GPIO 21.\n" );

  start = clock();
  for (i=0; i<1000000; i++) {
    digitalWrite ( PIN_OUT, 1 );
    do {} while (digitalRead(PIN_IN) == 0);
    digitalWrite ( PIN_OUT, 0 );
    do {} while (digitalRead(PIN_IN) != 0);
    // Swap the roles
    temp = PIN_IN;
    PIN_IN = PIN_OUT;
    PIN_OUT = temp;
    pinMode ( PIN_OUT, OUTPUT );
    pinMode ( PIN_IN, INPUT );
  }
  end = clock();
  printf ( "Alternating transfer result: dt = %f\n", (end-start)/CLOCKS_PER_SEC );
  return ( 0 );
}

/* Results:

Raspberry Pi using WiringPi library
Testing direct transfer speed from GPIO 20 to GPIO 21.
Setting output pin to 28.
Setting input pin to 29.
Direct transfer result: dt = 0.403502
Testing alternating transfer speed between GPIO 20 and GPIO 21.
Alternating transfer result: dt = 0.873182

*/
