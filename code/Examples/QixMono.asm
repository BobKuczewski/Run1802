; 1802 program to draw moving lines

AdvAdd  equ	$8
Delta   equ $9
Coord   equ $a
TempQ   equ $b
OPort   equ $4

MOVCMD  equ $1
DRWCMD  equ $2
COLCMD  equ $3
CLRCMD  equ $4


start   org $0

        ldi 0       ; Load 0
        phi AdvAdd  ; Set upper byte of AdvAdd to 0 for data in page 0
        phi Delta   ; Set upper byte of Delta to 0 for data in page 0
        phi Coord   ; Set upper byte of Coord to 0 for data in page 0
        phi TempQ   ; Set upper byte of TempQ to 0 for data in page 0

        ldi Count   ; Load the address of the Count subroutine
        plo AdvAdd  ; Put the Count subroutine address in AdvAdd
        
        ldi Out     ; Load the address of Out
        plo TempQ   ; Put Out address in TempQ
        
        ; Clear the screen with black
        sex TempQ   ; Use RF for output
        ldi CLRCMD  ; Clear Screen command
        str TempQ   ; Store CLRCMD in temp
        out OPort   ; Send CLRCMD to port OPort (automatically increments X)
        dec TempQ   ; Decrement after Out
        ldi $00     ; Red,Grn,Blu Color = 0
        str TempQ   ; Store 0 for output via X
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)

        ; Set the drawing color to green
        sex TempQ   ; Use RF for output
        ldi COLCMD  ; Clear Screen command
        str TempQ   ; Store COLCMD in temp
        out OPort   ; Send COLCMD to port OPort (automatically increments X)
        dec TempQ   ; Decrement after Out
        ldi $00     ; Red Color
        str TempQ   ; Store 0 for output via X
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)
        ldi $FF     ; Green Color
        str TempQ   ; Store 0 for output via X
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)
        ldi $00     ; Blue Color
        str TempQ   ; Store 0 for output via X
        out OPort   ; Send 0 to port OPort (automatically increments X)
        dec TempQ   ; Return RF to point at temp (still 0)
        
Loop
        sex TempQ   ; Use TempQ for sending

        ; Move to x1,y1

        ldi MOVCMD  ; Move command
        str TempQ   ; Store in memory
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out
        ldi x1      ; Load address of x1
        plo Coord   ; Coord holds address of x1
        ldn Coord   ; Load actual value of x1
        str TempQ   ; Store in memory at Out
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out
        ldi y1      ; Load address of y1
        plo Coord   ; Coord holds address of y1
        ldn Coord   ; Load actual value of y1
        str TempQ   ; Store in memory at Out
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out

        ; Draw to x2,y2

        ldi DRWCMD  ; Draw command
        str TempQ   ; Store in memory
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out
        ldi x2      ; Load address of x2
        plo Coord   ; Coord holds address of x2
        ldn Coord   ; Load actual value of x2
        str TempQ   ; Store in memory at Out
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out
        ldi y2      ; Load address of y2
        plo Coord   ; Coord holds address of y2
        ldn Coord   ; Load actual value of y2
        str TempQ   ; Store in memory at Out
        out OPort   ; Send it
        dec TempQ   ; Keep TempQ pointing at Out

        ; Move all the points

        ldi x1      ; Load x1
        plo Coord   ; Coord holds Value
        ldi dx1     ; Load dx1
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Count subroutine

        ldi y1      ; Load x1
        plo Coord   ; Coord holds Value
        ldi dy1     ; Load dx1
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Count subroutine

        ldi x2      ; Load x2
        plo Coord   ; Coord holds Value
        ldi dx2     ; Load dx2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Count subroutine

        ldi y2      ; Load x2
        plo Coord   ; Coord holds Value
        ldi dy2     ; Load dx2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Count subroutine

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
Count   ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]
        seq
        ; Check the current direction
        ldn Delta   ; Load delta via Delta
        shlc        ; Shift the high bit into DF

        bdf CntDn   ; Branch to count down

CntUp   ; Count Up Value by one Delta reversing Delta above 255
        ldn Coord   ; Value
        sex Delta   ; Set X to point at Delta (now positive)
        add         ; D = Value + Delta (via Delta as X)
        str Coord   ; Value = Value + Delta
        bnf UpDone  ; Done if there's no overflow
        sm          ; Subtract to undo the overflow
        str Coord   ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on Delta: Delta = 0-Delta
        str Delta   ; Store the changed value in Delta
UpDone  req
        br Return   ; Return to Main

CntDn   ; Count Down Value by one Delta reversing Delta below 0
        ldn Coord   ; Value
        sex Delta   ; Set X to point at Delta (now negative)
        add         ; D = Value + Delta (via Delta as X)
        str Coord   ; Value = Value + Delta
        bdf DnDone  ; Done if there is an overflow
        sm          ; Subtract to undo the overflow
        str Coord   ; Update the Value
        ldi 0       ; Load Zero
        sm          ; Change sign on Delta: Delta = 0-Delta
        str Delta   ; Store the changed value in Delta
DnDone  req
        br Return   ; Return to Main

		    end

