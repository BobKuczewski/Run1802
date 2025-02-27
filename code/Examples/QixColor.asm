; 1802 program to draw moving colored lines

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b

start   org $0

; Set up all registers to be on the first page (high byte 00)
        ghi $0    ; Load 0 into D (save a byte by assuming page 0)
        phi $8    ; Holds the address of the Advance subroutine
        phi $9    ; Holds address of Delta during the Advance subroutine
        phi $a    ; Holds address of Value during the Advance subroutine
        phi $b    ; Holds address of temporary for output
        phi $c    ; Used for the red color address
        phi $d    ; Used for the green color address
        phi $e    ; Used for the blue color address
        phi $f    ; Used for temporary and output

        ; Initialize the color registers
        ldi rstart  ; Load address of Red Start
        plo $c      ; Put Red Start in RC as an index to Red
        ldi gstart  ; Load address of Green Start
        plo $d      ; Put Green Start in RD as an index to Green
        ldi bstart  ; Load address of Blue Start
        plo $e      ; Put Blue Start in RE as an index to Blue

        ldi Temp1   ; Load the address of Temp1
        plo $b      ; Put Temp1 address in $b
        
        ldi Advance ; Load the address of the Advance subroutine
        plo $8      ; Put the Advance subroutine address in $8

        ; Clear the screen with black
        sex $b    ; Use $b (Temp1) for output
        ldi 4     ; Clear Screen command
        str $b    ; Store 4 in Temp2
        out 4     ; Send 4 to port 4 (automatically increments $b)
        dec $b    ; Decrement after out
        ldi $00   ; Red Color = 0
        str $b    ; Store 0 for output via X
        out 4     ; Send 0 to port 4 (automatically increments $b)
        dec $b    ; Return RF to point at Temp2 (still 0)
        out 4     ; Send 0 to port 4 (automatically increments $b)
        dec $b    ; Return RF to point at Temp2 (still 0)
        out 4     ; Send 0 to port 4 (automatically increments $b)
        dec $b    ; Return RF to point at Temp2 (still 0)

        ldi Temp2 ; Load address of Temp2 as scratch
        plo $f    ; Set RF as a reference to Temp2
        sex $f    ; Use RF->Temp2 as X

        ; Cycle through the colors as the line moves

        ; ldi 150    ; Run this many iterations? Left over?
Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;
        br Move  ; Skip the color stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldi 3      ; Load the color command (3)
        sex $f     ; Prepare to store
        str $f     ; Store in memory to output
        out 4      ; Output the value of 3 as a color command
        dec $f     ; Return RF to point at Temp2
        
        sex $c     ; X = RC as address into the Red table
        glo $c     ; Get current Red address (RC.0)
        smi cend   ; Subtract: RedAddr - ColorEnd
        bnz rgood  ; Non-zero means not at end of table
        ldi cstart ; End of table reached, go back to table start
        plo $c     ; Set Red color index to start of color table
rgood   out 4      ; Output the value from the Red color table

        sex $d     ; X = RD as address into the Green table
        glo $d     ; Get current Green address (RD.0)
        smi cend   ; Subtract: GreenAddr - ColorEnd
        bnz ggood  ; Non-zero means not at end of table
        ldi cstart ; End of table reached, go back to table start
        plo $d     ; Set Green color index to start of color table
ggood   out 4      ; Output the value from the Green color table

        sex $e     ; X = RD as address into the Green table
        glo $e     ; Get current Green address (RD.0)
        smi cend   ; Subtract: GreenAddr - ColorEnd
        bnz bgood  ; Non-zero means not at end of table
        ldi cstart ; End of table reached, go back to table start
        plo $e     ; Set Green color index to start of color table
bgood   out 4      ; Output the value from the Green color table

        ; Draw a line in the current color

        sex $b   ; X = $b for this section of the code

Move    ; Move to x1,y1

        ldi 1    ; Move command
        str $b   ; Store in memory
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1
        ldi x1   ; Load address of x1
        plo $a   ; $a holds address of x1
        ldn $a   ; Load actual value of x1
        str $b   ; Store in memory at Temp1
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1
        ldi y1   ; Load address of y1
        plo $a   ; $a holds address of y1
        ldn $a   ; Load actual value of y1
        str $b   ; Store in memory at Temp1
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1

Draw    ; Draw to x2,y2

        ldi 2    ; Draw command
        str $b   ; Store in memory
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1
        ldi x2   ; Load address of x2
        plo $a   ; $a holds address of x2
        ldn $a   ; Load actual value of x2
        str $b   ; Store in memory at Temp1
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1
        ldi y2   ; Load address of y2
        plo $a   ; $a holds address of y2
        ldn $a   ; Load actual value of y2
        str $b   ; Store in memory at Temp1
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Temp1

Adv     ; Advance all the points

        ldi x1      ; Load x1
        plo $a      ; $a holds Value
        ldi dx1     ; Load dx1
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Advance subroutine

        ldi y1      ; Load x1
        plo $a      ; $a holds Value
        ldi dy1     ; Load dx1
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Advance subroutine

        ldi x2      ; Load x2
        plo $a      ; $a holds Value
        ldi dx2     ; Load dx2
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Advance subroutine

        ldi y2      ; Load x2
        plo $a      ; $a holds Value
        ldi dy2     ; Load dx2
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Advance subroutine

        br Loop
        idl         ; Done

x1      byte 50     ; x1 value to count up and down
y1      byte 250    ; y1 value to count up and down
x2      byte 10     ; x2 value to count up and down
y2      byte 0      ; y2 value to count up and down
dx1     byte -5     ; dx1 will switch between + and -
dy1     byte -6     ; dy1 will switch between + and -
dx2     byte 6      ; dx2 will switch between + and -
dy2     byte 8      ; dy2 will switch between + and -
Temp1   byte 0      ; Used for sending a byte
Temp2   byte 0      ; Used for multiple purposes

        ; Blue color table (shared with Red and Green)
        ; Red and Green use the same table but start at
        ; different locations. The address of "cend" is
        ; used by the code to know when to go back to
        ; the front of the color table. The table is
        ; arranged to give the starts of all 3 colors.
cstart
bstart  byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
gstart  byte   0,$33,$66,$99,$cc,$ff,$ff,$ff,$ff,$ff
rstart  byte $ff,$ff,$ff,$ff,$ff,$ff,$cc,$99,$66,$33
cend    byte $EE   ; cend and EE mark the end (may not be used any more)

Return  sep $0
Advance ; Advance a coordinate value by delta reversing as needed
        ; Assumes Before: [$9->delta $a->value] After [RX = $9]
        seq
        ; Check the current direction
        ldn $9      ; Load delta via $9
        shlc        ; Shift the high bit into DF

        bdf CntDn   ; Branch to count down

CntUp   ; Advance the Value by one Delta reversing Delta above 255
        ldn $a      ; Value
        sex $9      ; Set X to point at Delta (now positive)
        add         ; D = Value + Delta (via $9 as X)
        str $a      ; Value = Value + Delta
        bnf UpDone  ; Done if there's no overflow
        sm          ; Subtract to undo the overflow
        str $a      ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on $9: $9 = 0-$9
        str $9      ; Store the changed value in $9
UpDone  req
        br Return   ; Return to Main

CntDn   ; Advance the Value by one Delta reversing Delta below 0
        ldn $a      ; Value
        sex $9      ; Set X to point at Delta (now negative)
        add         ; D = Value + Delta (via $9 as X)
        str $a      ; Value = Value + Delta
        bdf DnDone  ; Done if there is an overflow
        sm          ; Subtract to undo the overflow
        str $a      ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on $9: $9 = 0-$9
        str $9      ; Store the changed value in $9
DnDone  req
        br Return   ; Return to Main

		    end

