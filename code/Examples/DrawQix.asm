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

; Set up all registers to be on the first page
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
        phi $c  ; Used for the red color address
        phi $d  ; Used for the green color address
        phi $e  ; Used for the blue color address
        phi $f  ; Used for temporary and output

        ldi out
        plo $f  ; Set RF to out
        sex $f

        ; Cycle through the colors as the stick moves
        ; First initialize the color registers
        ldi rstart
        plo $c
        ldi gstart
        plo $d
        ldi bstart
        plo $e

        ldi 150
cloop
        ldi 3   ; Load the color command (3)
        sex $f  ; Prepare to store
        str $f  ; Store in memory to output
        out 4   ; Output the vale of 3
        
        sex $c
        glo $c
        smi cend
        bnz rgood
        ldi cstart
        plo $c
rgood   out 4

        sex $d
        glo $d
        smi cend
        bnz ggood
        ldi cstart
        plo $d
ggood   out 4

        sex $e
        glo $e
        smi cend
        bnz bgood
        ldi cstart
        plo $e
bgood   out 4

        br cloop
cdone

        req         ; Q Off to signal end of program
        idl         ; Done

        byte $11
        byte $11
out     byte 0
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
cstart
bstart  byte   0,  0,  0,  0,  0,  0,  0,  0,  0,  0
gstart  byte   0,$33,$66,$99,$cc,$ff,$ff,$ff,$ff,$ff
rstart  byte $ff,$ff,$ff,$ff,$ff,$ff,$cc,$99,$66,$33
cend    byte $EE   ; cend and EE mark the end

		    end

