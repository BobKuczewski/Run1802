; 1802 program to draw a moving line with changing colors

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b

FULLCOLOR equ 1
GREENCOLOR equ 0

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

RedReg  equ $c
GrnReg  equ $d
BluReg  equ $e
ColTemp equ $f

OPort   equ $4

start   org $0

        ldi 0       ; Load 0
        ; ghi 0       ; Load 0 (saves a byte, but less clear)
        phi AdvAdd  ; Set upper byte of AdvAdd to 0 for data in page 0
        phi Delta   ; Set upper byte of Delta to 0 for data in page 0
        phi Coord   ; Set upper byte of Coord to 0 for data in page 0
        phi TempQ   ; Set upper byte of TempQ to 0 for data in page 0

        phi RedReg  ; Used for the red color address
        phi GrnReg  ; Used for the green color address
        phi BluReg  ; Used for the blue color address
        phi ColTemp ; Used for temporary and output

        ldi rstart  ; Load start of the red table
        plo RedReg  ; Initialize the Red Register
        ldi gstart  ; Load start of the green table
        plo GrnReg  ; Initialize the Green Register
        ldi bstart  ; Load start of the blue table
        plo BluReg  ; Initialize the Blue Register

        ldi Advance ; Load the address of the Advance subroutine
        plo AdvAdd  ; Put the Advance subroutine address in AdvAdd

        IF FULLCOLOR
        ldi SndColr ; Load the address of the Send Color subroutine
        plo SnCoAdd ; Put the Send Color subroutine address in SnCoAdd
        ENDI

        ldi Out     ; Load the address of Out
        plo TempQ   ; Put Out address in TempQ

        ldi temp
        plo ColTemp  ; Set RF to temp

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

        IF GREENCOLOR
        ; Send the Color Command just once before the loop
        sex ColTemp  ; Prepare to store
        ldi COLCMD   ; Load the color command
        str ColTemp  ; Store in memory to output
        out OPort    ; Output the color command
        dec ColTemp  ;

        ldi 0        ; Load the color component
        str ColTemp  ; Store in memory to output
        out OPort    ; Output the color component
        dec ColTemp  ;

        ldi 255      ; Load the color component
        str ColTemp  ; Store in memory to output
        out OPort    ; Output the color component
        dec ColTemp  ;

        ldi 0        ; Load the color component
        str ColTemp  ; Store in memory to output
        out OPort    ; Output the color component
        dec ColTemp  ;
        ENDI

Loop
        seq

        sex TempQ   ; Use TempQ for sending

        IF FULLCOLOR
        ; Send the next color each time through the loop
        sep SnCoAdd
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

        ; Move all the points based on their deltas
        ; Reflect as needed (all handled in "Advance")

        req

        ldi x1      ; Load x1
        plo Coord   ; Coord holds Value
        ldi dx1     ; Load dx1
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        ldi y1      ; Load y1
        plo Coord   ; Coord holds Value
        ldi dy1     ; Load dy1
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        ldi x2      ; Load x2
        plo Coord   ; Coord holds Value
        ldi dx2     ; Load dx2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        ldi y2      ; Load y2
        plo Coord   ; Coord holds Value
        ldi dy2     ; Load dy2
        plo Delta   ; Delta holds Delta
        sep AdvAdd  ; Call the Advance subroutine

        br Loop     ; Branch back to continue counting
        idl

;========= Variables =========

x1      byte 50     ; x1 value to count up and down
y1      byte 250    ; y1 value to count up and down
x2      byte 10     ; x2 value to count up and down
y2      byte 0      ; y2 value to count up and down
dx1     byte -5     ; dx1 will switch between + and -
dy1     byte -6     ; dy1 will switch between + and -
dx2     byte 6      ; dx2 will switch between + and -
dy2     byte 8      ; dy2 will switch between + and -
Out     byte 0      ; Used for sending a byte
temp    byte 0      ; Used for temporary storage

        IF FULLCOLOR
; Color Table: Blue color inicies (shared with Red and Green)
cstart
bstart  byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
gstart  byte   0,$33,$66,$99,$cc,$ff,$ff,$ff,$ff,$ff
rstart  byte $ff,$ff,$ff,$ff,$ff,$ff,$cc,$99,$66,$33
cend    byte $EE   ; cend and EE mark the end
        ENDI

;========= Advance Routine =========

RetCnt  sep $0
Advance ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]
        ;;;seq      ; Used for debugging
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
UpDone  ;;;req      ; Used for debugging
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
DnDone  ;;;req      ; Used for debugging
        br RetCnt   ; Return to Main

        IF FULLCOLOR

;========= SndColr Routine =========

RetSnd  sep $0
SndColr ; Assumes Before: [Delta->delta Coord->value] After [RX = Delta]

        ; Send the next color

        ldi COLCMD   ; Load the color command
        sex ColTemp  ; Prepare to store
        str ColTemp  ; Store in memory to output
        out OPort    ; Output the color command
        dec ColTemp  ; May not be needed ????

        sex RedReg   ; Use the Red Register to output Red value
        glo RedReg   ; Get the low byte of the Red address
        smi cend     ; Check to see if it's past the end of the table
        bnz rgood    ; If it's not past the end, then Red is good
        ldi cstart   ; Otherwise, load the start of the table
        plo RedReg   ; Reset the Red Register to the start of the table
rgood   out OPort    ; Output the Red value and allow RedReg to increment

        sex GrnReg   ; Use the Green Register to output Green value
        glo GrnReg   ; Get the low byte of the Green address
        smi cend     ; Check to see if it's past the end of the table
        bnz ggood    ; If it's not past the end, then Green is good
        ldi cstart   ; Otherwise, load the start of the table
        plo GrnReg   ; Reset the Green Register to the start of the table
ggood   out OPort    ; Output the Green value and allow GrnReg to increment

        sex BluReg   ; Use the Blue Register to output Blue value
        glo BluReg   ; Get the low byte of the Blue address
        smi cend     ; Check to see if it's past the end of the table
        bnz bgood    ; If it's not past the end, then Blue is good
        ldi cstart   ; Otherwise, load the start of the table
        plo BluReg   ; Reset the Blue Register to the start of the table
bgood   out OPort    ; Output the Blue value and allow GrnReg to increment

        br RetSnd    ; Return to Main

        ENDI

		    end

