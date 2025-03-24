; 1802 program to draw a number "4"

GPort  EQU 6

START  ORG 00H
       LDI 00
       PHI 0FH
       PHI 0EH
       LDI DATA
       PLO 0FH
       SEX 0FH
       LDI EDATA-DATA  ; 13H
       PLO 0EH
       SEQ
SEND   OUT 6
       DEC 0EH
       REQ
       GLO 0Eh
       SEQ
       BNZ SEND
       IDL

DATA   BYTE 4   ; Erase screen to black
       BYTE 255
       BYTE 255
       BYTE 255

       BYTE 3   ; Set Color to red
       BYTE 255
       BYTE 0
       BYTE 0

       BYTE 1   ; Move to 90,34
       BYTE 90
       BYTE 34

       BYTE 2   ; Draw to 60,106
       BYTE 60
       BYTE 106

       BYTE 03  ; Set Color to green
       BYTE 0
       BYTE 255
       BYTE 0

       BYTE 1   ; Move to 60,106
       BYTE 60
       BYTE 106

       BYTE 2   ; Draw to 153,106
       BYTE 153
       BYTE 106

       BYTE 03  ; Set Color to blue
       BYTE 0
       BYTE 0
       BYTE 255

       BYTE 1   ; Move to 116,58
       BYTE 116
       BYTE 58

       BYTE 2   ; Draw to 116,153
       BYTE 116
       BYTE 153

EDATA

		   END

