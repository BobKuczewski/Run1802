; 1802 program to draw the Enterprise
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
       IDL        ; Done!!


; Graphics commands to send
;DATA   BYTE $04,0,0,60   ; Clear Background Dark Blue
;       BYTE $03,$44,$44,$44   ; Set Color Gray
;       BYTE $05,4,80,248,96   ; Full Enterprise area
;       BYTE $03,$FF,$FF,$FF   ; Set Color White;
;
;       BYTE $05, 4,80,14,3    ; Top of C
;       BYTE $05, 4,80,3,18    ; Left of C
;       BYTE $05, 4,96,14,3    ; Bottom of C
;
;       BYTE $05,24,80,14,3    ; Top of O
;       BYTE $05,24,80,3,18    ; Left of O
;       BYTE $05,35,80,3,19    ; Right of O
;       BYTE $05,24,96,14,3    ; Bottom of O
;
;       BYTE $05,44,80,14,3    ; Top of S
;       BYTE $05,44,80,3,11    ; Left of S
;       BYTE $05,44,88,14,3    ; Middle of S
;       BYTE $05,55,88,3,11    ; Right of S
;       BYTE $05,44,96,14,3    ; Bottom of S
;
;       BYTE $05,64,80,7,7     ; Top of M
;       BYTE $05,76,80,7,7     ; Top of M
;       BYTE $05,64,80,3,18     ; Bottom of M
;       BYTE $05,80,80,3,18     ; Bottom of M
;
;       BYTE $05,88,80,14,3    ; Top of A
;       BYTE $05,88,96,14,3    ; Bottom of A
;
;       BYTE $05,108,80,14,3   ; Top of C
;       BYTE $05,108,96,14,3   ; Bottom of C

;       BYTE $03,$0,$0,$0   ; Set Color Black

DATA   BYTE 3, 255,255,255, 3, $ff,$80,$17
       BYTE 6, 0, 80, 22, 64, 4
       BYTE $7B, $DE, $DB, $DE, $00, $00, $00, $00
       BYTE $4A, $50, $DA, $52, $00, $00, $00, $00
       BYTE $42, $5E, $AB, $D0, $00, $00, $00, $00
       BYTE $4A, $42, $8A, $52, $00, $00, $00, $00
       BYTE $7B, $DE, $8A, $5E, $00, $00, $00, $00
       BYTE $00, $00, $00, $00, $00, $00, $00, $00
       BYTE $00, $00, $00, $00, $00, $00, $07, $E0
       BYTE $00, $00, $00, $00, $FF, $FF, $FF, $FF
       BYTE $00, $06, $00, $01, $00, $00, $00, $01
       BYTE $00, $7F, $E0, $01, $00, $00, $00, $02
       BYTE $7F, $C0, $3F, $E0, $FC, $FF, $FF, $FE
       BYTE $40, $0F, $00, $10, $04, $80, $00, $00
       BYTE $7F, $C0, $3F, $E0, $04, $80, $00, $00
       BYTE $00, $3F, $D0, $40, $04, $80, $00, $00
       BYTE $00, $0F, $08, $20, $04, $80, $7A, $1E
       BYTE $00, $00, $07, $90, $04, $80, $42, $10
       BYTE $00, $00, $18, $7F, $FC, $F0, $72, $1C
       BYTE $00, $00, $30, $00, $00, $10, $42, $10
       BYTE $00, $00, $73, $FC, $00, $10, $7B, $D0
       BYTE $00, $00, $30, $00, $3F, $F0, $00, $00
       BYTE $00, $00, $18, $0F, $C0, $00, $00, $00
       BYTE $00, $00, $07, $F0, $00, $00, $00, $00

EDATA             ; Label to measure number of graphics commands


; Enterprise in bits
;           C     O      S      M     A     C
;ent BYTE %01111011,%11011110,%11011011,%11011110,%00000000,%00000000,%00000000,%00000000
;    BYTE %01001010,%01010000,%11011010,%01010010,%00000000,%00000000,%00000000,%00000000
;    BYTE %01000010,%01011110,%10101011,%11010000,%00000000,%00000000,%00000000,%00000000
;    BYTE %01001010,%01000010,%10001010,%01010010,%00000000,%00000000,%00000000,%00000000
;    BYTE %01111011,%11011110,%10001010,%01011110,%00000000,%00000000,%00000000,%00000000
;    BYTE %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00000000
;    BYTE %00000000,%00000000,%00000000,%00000000,%00000000,%00000000,%00001111,%11000000
;    BYTE %00000000,%00000000,%00000000,%00000001,%11111111,%11111111,%11111111,%11111110
;    BYTE %00000000,%00001100,%00000000,%00000010,%00000000,%00000000,%00000000,%00000010
;    BYTE %00000000,%11111111,%11000000,%00000010,%00000000,%00000000,%00000000,%00000100
;    BYTE %01111111,%10000000,%01111111,%11000001,%11111001,%11111111,%11111111,%11111100
;    BYTE %01000000,%00011110,%00000000,%00100000,%00001001,%00000000,%00000000,%00000000
;    BYTE %01111111,%10000000,%01111111,%11000000,%00001001,%00000000,%00000000,%00000000
;    BYTE %00000000,%11111111,%11010000,%01000000,%00001001,%00000000,%00000000,%00000000
;    BYTE %00000000,%00001100,%00001000,%00100000,%00001001,%00000000,%11110100,%00111100
;    BYTE %00000000,%00000000,%00000111,%10010000,%00001001,%00000000,%10000100,%00100000
;    BYTE %00000000,%00000000,%00011000,%01111111,%11111001,%11100000,%11100100,%00111000
;    BYTE %00000000,%00000000,%00110000,%00000000,%00000000,%00100000,%10000100,%00100000
;    BYTE %00000000,%00000000,%01110011,%11111100,%01111111,%11100000,%11110111,%10100000
;    BYTE %00000000,%00000000,%00110000,%00011111,%10000000,%00000000,%00000000,%00000000
;    BYTE %00000000,%00000000,%00001111,%11100000,%00000000,%00000000,%00000000,%00000000

		   END

