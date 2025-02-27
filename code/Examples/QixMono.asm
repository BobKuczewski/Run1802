; 1802 program to draw moving lines

start   org $0

        ldi 0       ; Load 0
        phi $8      ; Set upper byte of $8 to 0 for data in page 0
        phi $9      ; Set upper byte of $9 to 0 for data in page 0
        phi $a      ; Set upper byte of $a to 0 for data in page 0
        phi $b      ; Set upper byte of $a to 0 for data in page 0

        ldi Count   ; Load the address of the Count subroutine
        plo $8      ; Put the Count subroutine address in $8
        
        ldi Out     ; Load the address of Out
        plo $b      ; Put Out address in $b
        
        ; Clear the screen with black
        sex $b    ; Use RF for output
        ldi 4     ; Clear Screen command
        str $b    ; Store 4 in temp
        out 4     ; Send 4 to port 4 (automatically increments RF)
        dec $b    ; Decrement after Out
        ldi $00   ; Red Color = 0
        str $b    ; Store 0 for output via X
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $b    ; Return RF to point at temp (still 0)
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $b    ; Return RF to point at temp (still 0)
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $b    ; Return RF to point at temp (still 0)
        
Loop
        sex $b   ; Use $b for sending

        ; Move to x1,y1

        ldi 1    ; Move command
        str $b   ; Store in memory
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out
        ldi x1   ; Load address of x1
        plo $a   ; $a holds address of x1
        ldn $a   ; Load actual value of x1
        str $b   ; Store in memory at Out
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out
        ldi y1   ; Load address of y1
        plo $a   ; $a holds address of y1
        ldn $a   ; Load actual value of y1
        str $b   ; Store in memory at Out
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out

        ; Draw to x2,y2

        ldi 2    ; Draw command
        str $b   ; Store in memory
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out
        ldi x2   ; Load address of x2
        plo $a   ; $a holds address of x2
        ldn $a   ; Load actual value of x2
        str $b   ; Store in memory at Out
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out
        ldi y2   ; Load address of y2
        plo $a   ; $a holds address of y2
        ldn $a   ; Load actual value of y2
        str $b   ; Store in memory at Out
        out 4    ; Send it
        dec $b   ; Keep $b pointing at Out

        ; Move all the points

        ldi x1      ; Load x1
        plo $a      ; $a holds Value
        ldi dx1     ; Load dx1
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Count subroutine

        ldi y1      ; Load x1
        plo $a      ; $a holds Value
        ldi dy1     ; Load dx1
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Count subroutine

        ldi x2      ; Load x2
        plo $a      ; $a holds Value
        ldi dx2     ; Load dx2
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Count subroutine

        ldi y2      ; Load x2
        plo $a      ; $a holds Value
        ldi dy2     ; Load dx2
        plo $9      ; $9 holds Delta
        sep $8      ; Call the Count subroutine

        br Loop     ; Branch back to continue counting
        idl

x1      byte 50     ; x1 value to count up and down
y1      byte 250    ; y1 value to count up and down
x2      byte 10     ; x2 value to count up and down
y2      byte 0      ; y2 value to count up and down
dx1     byte -5     ; dx1 will switch between + and -
dy1     byte -6     ; dy1 will switch between + and -
dx2     byte 6      ; dx2 will switch between + and -
dy2     byte 8      ; dy2 will switch between + and -
Out     byte 0      ; Used for sending a byte

Return  sep $0
Count   ; Assumes Before: [$9->delta $a->value] After [RX = $9]
        seq
        ; Check the current direction
        ldn $9      ; Load delta via $9
        shlc        ; Shift the high bit into DF

        bdf CntDn   ; Branch to count down

CntUp   ; Count Up Value by one Delta reversing Delta above 255
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

CntDn   ; Count Down Value by one Delta reversing Delta below 0
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

