; 1802 program to draw a series of lines

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b

; x1 = 50
; y1 = 250
; dx1 = -5
; dy1 = -6

; x2 = 10
; y2 = 0
; dx2 = 6
; dy2 = 8

; minx = 6
; maxx = 248
; miny = 7
; maxy = 247


; n = 5
; Color scale of 30 values where n is 5 and c is the color index
; b = [ 0 0 0 0 0 0 0 0 0 0 0 33 66 99 cc ff ff ff ff ff ff ff ff ff ff ff cc 99 66 33 
;       0 0 0 0 0 0 0 0 0 0 0 33 66 99 cc ff ff ff ff ff ff ff ff ff ff ff cc 99 66 33 ]
; rgb = [  b[(c+(4*n))],   b[(c+(2*n))],   b[c]   ]

; c = 0
; for i=0 to 150:   # 150 = x96
;   red = b[(c+20)]
;   grn = b[(c+10)]
;   blu = b[c]
;   send 3
;   send red
;   send grn
;   send blu
;   c = c + 1
;   if c > 30: c = 0
;   send 1
;   send x1
;   send y1
;   send 2
;   send x2
;   send y2
;   x1 = x1 + dx1
;   y1 = y1 + dy1
;   x2 = x2 + dx2
;   y2 = y2 + dy2
;   if (x1<minx) or (x1>maxx) dx1 = -dx1
;   if (y1<miny) or (y1>maxy) dy1 = -dy1
;   if (x2<minx) or (x2>maxx) dx2 = -dx2
;   if (y2<miny) or (y2>maxy) dy2 = -dy2
;   

; 1802 program draw moving lines

start   org $0

        seq         ; Q On to signal start of program

; Set up all registers to be on the first page (high byte 00)
        ldi 0
        phi $0
        phi $1
        phi $2
        phi $3
        phi $4
        phi $5
        phi $6
        phi $7
        phi $8
        phi $9
        phi $a
        phi $b
        phi $c    ; Used for the red color address
        phi $d    ; Used for the green color address
        phi $e    ; Used for the blue color address
        phi $f    ; Used for temporary and output

        ldi temp  ; Load address of temp as scratch
        plo $f    ; Set RF as a reference to temp
        sex $f    ; Use RF->temp as X

        ; Clear the screen with black
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

        ; Cycle through the colors as the stick moves

        ; First initialize the color registers
        ldi rstart ; Load address of Red Start
        plo $c     ; Put Red Start in RC as an index to Red
        ldi gstart ; Load address of Green Start
        plo $d     ; Put Green Start in RD as an index to Green
        ldi bstart ; Load address of Blue Start
        plo $e     ; Put Blue Start in RE as an index to Blue

        ldi 150    ; Run this many iterations
cloop
        ldi 3      ; Load the color command (3)
        sex $f     ; Prepare to store
        str $f     ; Store in memory to output
        out 4      ; Output the value of 3 as a color command
        dec $f     ; Return RF to point at temp
        
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

; Draw a line just to show the colors
        sex $f
        ldi 1    ; Move command
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f
        ldi 0    ; x
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f
        ldi 0    ; y
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f
        ldi 2    ; Draw command
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f
        ldi 51   ; x
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f
        ldi 51   ; y
        str $f   ; Store in memory
        out 4    ; Send it
        dec $f

        br cloop
cdone

        req         ; Q Off to signal end of program
        idl         ; Done

        byte $11    ; Marker to help find data area
        byte $11    ; Marker to help find data area
temp    byte 0      ; Used for multiple purposes
x1      byte 50
y1      byte 250
dx1     byte -5
dy1     byte -6
x2      byte 10
y2      byte 0
dx2     byte 6
dy2     byte 8
minx    byte 6
maxx    byte 248
miny    byte 7
maxy    byte 247
n       byte 5
c       byte 0
i       byte 0

        ; Blue color inicies (shared with Red and Green)
        ; Red and Green use the same table but start at
        ; different locations. The address of "cend" is
        ; used by the code to know when to go back to
        ; the front of the color table. The table is
        ; arranged to show the starts of all 3 colors.
cstart
bstart  byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
gstart  byte   0,$33,$66,$99,$cc,$ff,$ff,$ff,$ff,$ff
rstart  byte $ff,$ff,$ff,$ff,$ff,$ff,$cc,$99,$66,$33
cend    byte $EE   ; cend and EE mark the end

		    end

