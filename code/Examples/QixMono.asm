; 1802 program to draw moving lines

start   org $0

        ldi 0       ; Load 0
        phi $c      ; Set upper byte of $c to 0 for data in page 0
        phi $d      ; Set upper byte of $d to 0 for data in page 0
        phi $e      ; Set upper byte of $e to 0 for data in page 0
        phi $f      ; Set upper byte of $e to 0 for data in page 0

        ldi Count   ; Load the address of the Count subroutine
        plo $c      ; Put the Count subroutine address in $c
        
        ldi Out     ; Load the address of Out
        plo $f      ; Put Out address in $f
        
        ; Clear the screen with black
        sex $f    ; Use RF for output
        ldi 4     ; Clear Screen command
        str $f    ; Store 4 in temp
        out 4     ; Send 4 to port 4 (automatically increments RF)
        dec $f    ; Decrement after Out
        ldi $00   ; Red Color = 0
        str $f    ; Store 0 for output via X
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $f    ; Return RF to point at temp (still 0)
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $f    ; Return RF to point at temp (still 0)
        out 4     ; Send 0 to port 4 (automatically increments RF)
        dec $f    ; Return RF to point at temp (still 0)
        
Loop
        sex $f   ; Use $f for sending

        ; Move to x1,y1

        ldi 1    ; Move command
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out
        ldi x1   ; Load address of x1
        plo $e   ; $e holds address of x1
        ldn $e   ; Load actual value of x1
        str $f   ; Store in memory at Out
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out
        ldi y1   ; Load address of y1
        plo $e   ; $e holds address of y1
        ldn $e   ; Load actual value of y1
        str $f   ; Store in memory at Out
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out

        ; Draw to x2,y2

        ldi 2    ; Draw command
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out
        ldi x2   ; Load address of x2
        plo $e   ; $e holds address of x2
        ldn $e   ; Load actual value of x2
        str $f   ; Store in memory at Out
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out
        ldi y2   ; Load address of y2
        plo $e   ; $e holds address of y2
        ldn $e   ; Load actual value of y2
        str $f   ; Store in memory at Out
        out 4    ; Send it
        dec $f   ; Keep $f pointing at Out

        ; Move all the points

        ldi x1      ; Load x1
        plo $e      ; $e holds Value
        ldi dx1     ; Load dx1
        plo $d      ; $d holds Delta
        sep $c      ; Call the Count subroutine

        ldi y1      ; Load x1
        plo $e      ; $e holds Value
        ldi dy1     ; Load dx1
        plo $d      ; $d holds Delta
        sep $c      ; Call the Count subroutine

        ldi x2      ; Load x2
        plo $e      ; $e holds Value
        ldi dx2     ; Load dx2
        plo $d      ; $d holds Delta
        sep $c      ; Call the Count subroutine

        ldi y2      ; Load x2
        plo $e      ; $e holds Value
        ldi dy2     ; Load dx2
        plo $d      ; $d holds Delta
        sep $c      ; Call the Count subroutine

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
Count   ; Assumes Before: [$d->delta $e->value] After [RX = $d]
        seq
        ; Check the current direction
        ldn $d      ; Load delta via $d
        shlc        ; Shift the high bit into DF

        bdf CntDn   ; Branch to count down

CntUp   ; Count Up Value by one Delta reversing Delta above 255
        ldn $e      ; Value
        sex $d      ; Set X to point at Delta (now positive)
        add         ; D = Value + Delta (via $d as X)
        str $e      ; Value = Value + Delta
        bnf UpDone  ; Done if there's no overflow
        sm          ; Subtract to undo the overflow
        str $e      ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on $d: $d = 0-$d
        str $d      ; Store the changed value in $d
UpDone  req
        br Return   ; Return to Main

CntDn   ; Count Down Value by one Delta reversing Delta below 0
        ldn $e      ; Value
        sex $d      ; Set X to point at Delta (now negative)
        add         ; D = Value + Delta (via $d as X)
        str $e      ; Value = Value + Delta
        bdf DnDone  ; Done if there is an overflow
        sm          ; Subtract to undo the overflow
        str $e      ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on $d: $d = 0-$d
        str $d      ; Store the changed value in $d
DnDone  req
        br Return   ; Return to Main

		    end

