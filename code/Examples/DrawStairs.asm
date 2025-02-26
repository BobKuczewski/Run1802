; 1802 program to draw a series of stairs

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b

; python Run_1802.py f=DrawStairs.hex n=12000 c=0.0001 o gui

START  ORG 00H
       LDI 0    ; Set upper part of each Register
       PHI 09H
       PHI 0AH
       PHI 0BH
       PHI 0CH
       PHI 0DH
       PHI 0EH
       PHI 0FH

       LDI Zero ; Set Lower part of each Register
       PLO 09H
       LDI X
       PLO 0AH
       LDI Y
       PLO 0BH
       LDI Move
       PLO 0CH
       LDI Draw
       PLO 0DH
       LDI Delta
       PLO 0EH
       LDI 11   ; Number of steps (counts down)
       PLO 0FH

       ; Clear with Black
       SEX 09H     ; Temp
       LDI 4       ; Clear command
       STR 09H     ; Store in X
       OUT 4       ; Send Clear
       DEC 09H     ; Decrement after auto increment
       LDI 0       ; Value of black
       STR 09H     ; Store in X
       OUT 4       ; Send Red
       DEC 09H     ; Decrement after auto increment
       OUT 4       ; Send Green
       DEC 09H     ; Decrement after auto increment
       OUT 4       ; Send Blue
       DEC 09H     ; Decrement after auto increment

       ; Move to Start
       SEX 0CH     ; RX = MOVE
       OUT 4       ; Send MOVE
       DEC 0CH     ; Decrement after auto increment
       SEX 0AH     ; RX = X
       OUT 4       ; Send X
       DEC 0AH     ; Decrement after auto increment
       SEX 0BH     ; RX = Y
       OUT 4       ; Send Y
       DEC 0BH     ; Decrement after auto increment

LOOP
       ; Increment X
       SEX 0EH     ; Point at Delta
       LDN 0AH     ; Load X
       ADD         ; D = X + Delta
       STR 0AH     ; Store Updated X

       ; Draw Horizontal Step
       SEX 0DH     ; RX = DRAW
       OUT 4       ; Send DRAW
       DEC 0DH     ; Decrement after auto increment
       SEX 0AH     ; RX = X
       OUT 4       ; Send X
       DEC 0AH     ; Decrement after auto increment
       SEX 0BH     ; RX = Y
       OUT 4       ; Send Y
       DEC 0BH     ; Decrement after auto increment

       ; Increment Y
       SEX 0EH     ; Point at Delta
       LDN 0BH     ; Load Y
       ADD         ; D = Y + Delta
       STR 0BH     ; Store Updated Y

       ; Draw Vertical Step
       SEX 0DH     ; RX = DRAW
       OUT 4       ; Send DRAW
       DEC 0DH     ; Decrement after auto increment
       SEX 0AH     ; RX = X
       OUT 4       ; Send X
       DEC 0AH     ; Decrement after auto increment
       SEX 0BH     ; RX = Y
       OUT 4       ; Send Y
       DEC 0BH     ; Decrement after auto increment

       ; Decrement the Count and Loop back until done
       DEC 0FH     ; Decrement Count in F
       GLO 0FH     ;
       BNZ LOOP    ; Continue to Loop
       IDL         ; Done

Zero   BYTE 0      ; Zero value
X      BYTE 20     ; RA stores X
Y      Byte 20     ; RB stores Y
Move   BYTE 1      ; RC stores Move Command
Draw   BYTE 2      ; RD stores Draw Command
Delta  BYTE 20     ; RE stores Delta (step size)

		   END

