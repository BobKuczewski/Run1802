; 1802 program to draw a number "4"

START  ORG 00H
       LDI 00
       PHI 0FH
       PHI 0EH
       LDI DATA
       PLO 0FH
       SEX 0FH
       LDI EDATA-DATA  ; 13H
       PLO 0EH
SEND   OUT 4
       DEC 0EH
       GLO 0Eh
       BNZ SEND
       IDL

DATA   BYTE 03
       BYTE 0FFH 
       BYTE 00
       BYTE 00
       BYTE 01
       BYTE 01
       BYTE 01
       BYTE 02
       BYTE 0FFH
       BYTE 01
       BYTE 02
       BYTE 0FFH
       BYTE 0FFH
       BYTE 02
       BYTE 01
       BYTE 0FFH
       BYTE 02
       BYTE 01
       BYTE 01
EDATA

		   END



