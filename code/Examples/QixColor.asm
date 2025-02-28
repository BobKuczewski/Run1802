; 1802 program to draw a moving line with changing colors

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b

COLORON equ 1
ONLYGRN equ 0

MOVCMD  equ $1
DRWCMD  equ $2
COLCMD  equ $3
CLRCMD  equ $4

OPort   equ $4
X1      equ $0
Y1      equ $80
X2      equ $FF
Y2      equ $80

SnCoAdd equ $7
AdvAdd  equ	$8
Delta   equ $9
Coord   equ $a
TempQ   equ $b

REDREG  equ $c
GRNREG  equ $d
BLUREG  equ $e
COLTEMP equ $f

OPort   equ $4

start   org $0

        ldi 0       ; Load 0
        ; ghi 0       ; Load 0 (saves a byte, but less clear)
        phi AdvAdd  ; Set upper byte of AdvAdd to 0 for data in page 0
        phi Delta   ; Set upper byte of Delta to 0 for data in page 0
        phi Coord   ; Set upper byte of Coord to 0 for data in page 0
        phi TempQ   ; Set upper byte of TempQ to 0 for data in page 0

        phi REDREG  ; Used for the red color address
        phi GRNREG  ; Used for the green color address
        phi BLUREG  ; Used for the blue color address
        phi COLTEMP ; Used for temporary and output

        ldi rstart  ; Load start of the red table
        plo REDREG  ; Initialize the Red Register
        ldi gstart  ; Load start of the green table
        plo GRNREG  ; Initialize the Green Register
        ldi bstart  ; Load start of the blue table
        plo BLUREG  ; Initialize the Blue Register

        ldi Advance ; Load the address of the Advance subroutine
        plo AdvAdd  ; Put the Advance subroutine address in AdvAdd

        IF COLORON
        IF ONLYGRN
        ldi SGreen  ; Try using the simpler SGreen instead of SnCoAdd
        ELSE
        ldi SndColr ; Load the address of the Send Color subroutine
        ENDI
        plo SnCoAdd ; Put the Send Color subroutine address in SnCoAdd
        ENDI

        ldi Out     ; Load the address of Out
        plo TempQ   ; Put Out address in TempQ

        ldi temp
        plo COLTEMP  ; Set RF to temp

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

        IF COLORON
        ELSE
        ; This code works here
        sex COLTEMP  ; Prepare to store
        ldi COLCMD   ; Load the color command
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color command
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 255      ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;
        ENDI

Loop
        sex TempQ   ; Use TempQ for sending

        IF COLORON
        ; Send the next color
        sep SnCoAdd
        ELSE
        ; Does this code works here??? NOOOOOOOO!!!

        sex COLTEMP  ; Prepare to store
        ldi COLCMD   ; Load the color command
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color command
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 255      ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;
        ENDI

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
        sep AdvAdd  ; Call the Advance subroutine

        ldi y1      ; Load x1
        plo Coord   ; Coord holds Value
        ldi dy1     ; Load dx1
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        ldi x2      ; Load x2
        plo Coord   ; Coord holds Value
        ldi dx2     ; Load dx2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        ldi y2      ; Load x2
        plo Coord   ; Coord holds Value
        ldi dy2     ; Load dx2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

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
temp    byte 0      ; Temp?
; Color Table: Blue color inicies (shared with Red and Green)
cstart
bstart  byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
gstart  byte   0,$33,$66,$99,$cc,$ff,$ff,$ff,$ff,$ff
rstart  byte $ff,$ff,$ff,$ff,$ff,$ff,$cc,$99,$66,$33
cend    byte $EE   ; cend and EE mark the end

;========= Advance Routine =========

RetCnt  sep $0
Advance ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]
        ;;;seq
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
UpDone  ;;;req
        br RetCnt   ; Return to Main

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
DnDone  ;;;req
        br RetCnt   ; Return to Main

        IF ONLYGRN

;========= SGreen Routine =========

RetGrn  sep $0
SGreen  ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]

        ; Send the color Green

        sex COLTEMP  ; Prepare to store
        ldi COLCMD   ; Load the color command
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color command
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 255      ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        ldi 0        ; Load the color component
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color component
        dec COLTEMP  ;

        br RetGrn    ; Return to Main

        ELSE

;========= SndColr Routine =========

RetSnd  sep $0
SndColr ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]

        ; Send the next color

        ldi COLCMD   ; Load the color command
        sex COLTEMP  ; Prepare to store
        str COLTEMP  ; Store in memory to output
        out OPort    ; Output the color command
        dec COLTEMP  ; ????

        sex REDREG   ; Use the Red Register to output Red value
        glo REDREG   ; Get the low byte of the Red address
        smi cend     ; Check to see if it's past the end of the table
        bnz rgood    ; If it's not past the end, then Red is good
        ldi cstart   ; Otherwise, load the start of the table
        plo REDREG   ; Reset the Red Register to the start of the table
rgood   out OPort    ; Output the Red value and allow REDREG to increment

        sex GRNREG   ; Use the Green Register to output Green value
        glo GRNREG   ; Get the low byte of the Green address
        smi cend     ; Check to see if it's past the end of the table
        bnz ggood    ; If it's not past the end, then Green is good
        ldi cstart   ; Otherwise, load the start of the table
        plo GRNREG   ; Reset the Green Register to the start of the table
ggood   out OPort    ; Output the Green value and allow GRNREG to increment

        sex BLUREG   ; Use the Green Register to output Green value
        glo BLUREG   ; Get the low byte of the Green address
        smi cend     ; Check to see if it's past the end of the table
        bnz bgood    ; If it's not past the end, then Green is good
        ldi cstart   ; Otherwise, load the start of the table
        plo BLUREG   ; Reset the Green Register to the start of the table
bgood   out OPort    ; Output the Green value and allow GRNREG to increment

        br RetSnd    ; Return to Main

        ENDI

;; Draw a line just to show the colors
;        sex COLTEMP
;        ldi MOVCMD    ; Move command
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP
;        ldi X1    ; x
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP
;        ldi Y1    ; y
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP
;        ldi DRWCMD    ; Draw command
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP
;        ldi X2  ; x
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP
;        ldi Y2  ; y
;        str COLTEMP   ; Store in memory
;        out OPort    ; Send it
;        dec COLTEMP

		    end

