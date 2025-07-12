; 1802 program to draw the Enterprise

; Four Drawing Commands:
; 1,x,y = Move to x,y
; 2,x,y = Draw to x,y
; 3,r,g,b = Set Color to r,g,b
; 4,r,g,b = Erase Screen to r,g,b


; Should produce this:

; F=Full, T=Top, B=Bottom

; Enterprise drawing is about 62 pixels wide
; 256 / 62 => 4, so use 4 pixels per block
; 62 * 4 => 248
; 256 - 248 => 8, so leave 4 pixels unused on either side

; Enterprise drawing (with COSMAC) is about 24 pixels tall
; 24 * 4 => 96
; 256 - 96 = 160 so leave 80 pixels unused on top and bottom
;
;T 0000 0000 0000 00 00 0000 0000
;B 0  0 0  0 0    00 00 0  0 0  0
;T 0    0  0 0000 0 0 0 0000 0
;B 0  0 0  0    0 0   0 0  0 0  0
;T 0000 0000 0000 0   0 0  0 0000
;B
;T                                                    000000
;B                                0000000000000000000000000000000
;T             00                0                              0
;B         0000000000            0                             0
;T 000000000        000000000     000000  0000000000000000000000
;B0           0000           0         0  0
;T 000000000        000000000          0  0
;B          00000000 0      0          0  0
;T            0000    0      0         0  0
;B                     00000  0        0  0        0000 0    0000
;T                   00     000000000000  0000     0    0    0
;B                  00                       0     000  0    000
;T                 000  00000000             0     0    0    0
;B                  00              0000000000     0000 0000 0
;T                   000       00000
;B                     00000000
;
;  FTTF FTTF FTTT FF FF FTTF FTTF',                                  # Line 40
;  F  B F  F TTTF F T F FTTF F  B',                                  # Line 50
;  TTTT TTTT TTTT T   T T  T TTTT',                                  # Line 60
;',                                                                 # Line 70
;                                BBBBBBBBBBBBBBBBBBBBFFFFFFBBBBB',  # Lines 70 80
;          BBBBFFBBBB            F                             BT',  # Lines 90 100
;  FTTTTTTTT  BBBB  TTTTTTTTTB    TTTTTF  FTTTTTTTTTTTTTTTTTTTTT',   # Lines 110 120 130
;  TTTTTTTTTBBBBBBBBTFTTTTTFT          F  F',                        # Lines 140 150
;             TTTT    TBBBB TB         F  F        BBBB B    BBBB',  # Lines 160 170
;                   BFT    TTTTTTTTTTTTT  TTTF     FBB  F    FBB',   # Lines 180 190
;                  TFF  TTTTTTTT    BBBBBBBBBF     FBBB FBBB F',     # Lines 200 210
;                    TTFBBBBBBBTTTTT'                                # Lines 220 230
;             ]
;

;
;
;

GPort  EQU 6

START  ORG $00



       LDI 00     ; Load 0 for upper address registers
       PHI $0F    ; Zero high byte of F
       PHI $0E    ; Zero high byte of E
       LDI DATA   ; Load the address of the graphics commands
       PLO $0F    ; Point F at the graphics commands
       SEX $0F    ; Use F as X to send the graphics commands
       LDI HIGH (EDATA-DATA)  ; Load the size of the graphics commands
       PHI $0E    ; Use E to count down while sending commands
       LDI LOW (EDATA-DATA)  ; Load the size of the graphics commands
       PLO $0E    ; Use E to count down while sending commands
SEND   OUT GPort  ; Output the next byte of graphics commands
       DEC $0E    ; Decrement the count down register
       GLO $0E    ; Get the current count
       BNZ SEND   ; Branch to send more as needed
       GHI $0E    ; Get the current count
       BNZ SEND   ; Branch to send more as needed
       IDL        ; Done!!


; Graphics commands to send
DATA   BYTE $04,0,0,60   ; Clear Background Dark Blue
       BYTE 3,66,66,66   ; Set Color Gray
       ; BYTE $05,4,80,248,96   ; Full Enterprise area

       BYTE 3,200,200,200   ; Set Color Light Gray
       BYTE $05, 0*4,0*4,1*4,1*4  ; Upper Left
       BYTE $05, 1*4,1*4,1*4,1*4  ; Upper Left
       BYTE $05, 2*4,2*4,1*4,1*4  ; Upper Left
       BYTE $05, 3*4,3*4,1*4,1*4  ; Upper Left
       BYTE $05, 4*4,4*4,1*4,1*4  ; Upper Left
       BYTE $05, 5*4,5*4,1*4,1*4  ; Upper Left
       BYTE $05, 6*4,6*4,1*4,1*4  ; Upper Left


;       BYTE 1,8,0      ; Move to top of vertical grid line
;       BYTE 2,8,255    ; Draw to bottom of vertical grid line
;       BYTE 1,16,0      ; Move to top of vertical grid line
;       BYTE 2,16,255    ; Draw to bottom of vertical grid line
;       BYTE 1,24,0      ; Move to top of vertical grid line
;       BYTE 2,24,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,32,0      ; Move to top of vertical grid line
       BYTE 2,32,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,40,0      ; Move to top of vertical grid line
;       BYTE 2,40,255    ; Draw to bottom of vertical grid line
;       BYTE 1,48,0      ; Move to top of vertical grid line
;       BYTE 2,48,255    ; Draw to bottom of vertical grid line
;       BYTE 1,56,0      ; Move to top of vertical grid line
;       BYTE 2,56,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,64,0      ; Move to top of vertical grid line
       BYTE 2,64,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,72,0      ; Move to top of vertical grid line
;       BYTE 2,72,255    ; Draw to bottom of vertical grid line
;       BYTE 1,80,0      ; Move to top of vertical grid line
;       BYTE 2,80,255    ; Draw to bottom of vertical grid line
;       BYTE 1,88,0      ; Move to top of vertical grid line
;       BYTE 2,88,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,96,0      ; Move to top of vertical grid line
       BYTE 2,96,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,104,0      ; Move to top of vertical grid line
;       BYTE 2,104,255    ; Draw to bottom of vertical grid line
;       BYTE 1,112,0      ; Move to top of vertical grid line
;       BYTE 2,112,255    ; Draw to bottom of vertical grid line
;       BYTE 1,120,0      ; Move to top of vertical grid line
;       BYTE 2,120,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,128,0      ; Move to top of vertical grid line
       BYTE 2,128,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,136,0      ; Move to top of vertical grid line
;       BYTE 2,136,255    ; Draw to bottom of vertical grid line
;       BYTE 1,144,0      ; Move to top of vertical grid line
;       BYTE 2,144,255    ; Draw to bottom of vertical grid line
;       BYTE 1,152,0      ; Move to top of vertical grid line
;       BYTE 2,152,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,160,0      ; Move to top of vertical grid line
       BYTE 2,160,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,168,0      ; Move to top of vertical grid line
;       BYTE 2,168,255    ; Draw to bottom of vertical grid line
;       BYTE 1,176,0      ; Move to top of vertical grid line
;       BYTE 2,176,255    ; Draw to bottom of vertical grid line
;       BYTE 1,184,0      ; Move to top of vertical grid line
;       BYTE 2,184,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,192,0      ; Move to top of vertical grid line
       BYTE 2,192,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,200,0      ; Move to top of vertical grid line
;       BYTE 2,200,255    ; Draw to bottom of vertical grid line
;       BYTE 1,208,0      ; Move to top of vertical grid line
;       BYTE 2,208,255    ; Draw to bottom of vertical grid line
;       BYTE 1,216,0      ; Move to top of vertical grid line
;       BYTE 2,216,255    ; Draw to bottom of vertical grid line
       BYTE 3,255,0,0   ; Red
       BYTE 1,224,0      ; Move to top of vertical grid line
       BYTE 2,224,255    ; Draw to bottom of vertical grid line
;       BYTE 3,66,66,66  ; Gray
;       BYTE 1,232,0      ; Move to top of vertical grid line
;       BYTE 2,232,255    ; Draw to bottom of vertical grid line
;       BYTE 1,240,0      ; Move to top of vertical grid line
;       BYTE 2,240,255    ; Draw to bottom of vertical grid line
;       BYTE 1,248,0      ; Move to top of vertical grid line
;       BYTE 2,248,255    ; Draw to bottom of vertical grid line;

       BYTE $03,$FF,$FF,$FF   ; Set Color White

;       BYTE $05, 4,80,14,3    ; Top of C
;       BYTE $05, 4,80,3,18    ; Left of C
;       BYTE $05, 4,96,14,3    ; Bottom of C

;       BYTE $05,24,80,14,3    ; Top of O
;       BYTE $05,24,80,3,18    ; Left of O
;       BYTE $05,35,80,3,19    ; Right of O
;       BYTE $05,24,96,14,3    ; Bottom of O

;       BYTE $05,44,80,14,3    ; Top of S
;       BYTE $05,44,80,3,11    ; Left of S
;       BYTE $05,44,88,14,3    ; Middle of S
;       BYTE $05,55,88,3,11    ; Right of S
;       BYTE $05,44,96,14,3    ; Bottom of S

;       BYTE $05,64,80,7,7     ; Top of M
;       BYTE $05,76,80,7,7     ; Top of M
;       BYTE $05,72,88,3,3     ; Middle of M
;       BYTE $05,64,80,3,18    ; Left of M
;       BYTE $05,80,80,3,18    ; Right of M

;       BYTE $05,88,80,14,3    ; Top of A
;       BYTE $05,88,80,3,18    ; Left of A
;       BYTE $05,99,80,3,18    ; Right of A
;       BYTE $05,88,88,14,3    ; Middle of A

;       BYTE $05,108,80,14,3   ; Top of C
;       BYTE $05,108,80,3,18   ; Left of C
;       BYTE $05,108,96,14,3   ; Bottom of C

       BYTE $05,  4,120,35,3   ; Top front
       BYTE $05, 36,115,37,3   ; Top
       BYTE $05, 51,110,8,3    ; Top light
       BYTE $05, 72,120,35,3   ; Top rear
       BYTE $05,  4,120,3,7    ; Front

       BYTE $05, 47,125,16,3    ; Mid Deck

       BYTE $05,  4,129,35,3   ; Bot front
       BYTE $05, 36,134,37,3   ; Bot
       BYTE $05, 51,138,8,3    ; Bot light
       BYTE $05, 72,129,35,3   ; Bot rear
       BYTE $05, 105,120,3,12  ; Rear

       BYTE $05, 79,134,3,3   ; Neck 1 front
       BYTE $05, 84,139,3,3   ; Neck 2 front
       BYTE $05, 89,144,3*4,3   ; Neck 2 front

       BYTE $05, 103,134,3,3   ; Neck 1 rear
       BYTE $05, 108,139,3,3   ; Neck 2 rear
       BYTE $05, 113,144,3,3   ; Neck 3 rear

       BYTE $03,$0,$0,$0   ; Set Color Black

EDATA             ; Label to measure number of graphics commands

		   END

