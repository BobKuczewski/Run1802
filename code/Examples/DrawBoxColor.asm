; 1802 program to draw a box with different colors
; Should produce this:

;  01 50 50
;  03 FF 00 00
;  02 B0 50
;  03 00 FF 00
;  02 B0 B0
;  03 00 00 FF
;  02 50 B0
;  03 FF FF 00
;  02 50 50

GPort  EQU 6

START  ORG $00
       LDI 00     ; Load 0 for upper address registers
       PHI $0F    ; Zero high byte of F
       PHI $0E    ; Zero high byte of E
       LDI DATA   ; Load the address of the graphics commands
       PLO $0F    ; Point F at the graphics commands
       SEX $0F    ; Use F as X to send the graphics commands
       LDI EDATA-DATA  ; Load the size of the graphics commands
       PLO $0E    ; Use E to count down while sending commands
SEND   OUT GPort  ; Output the next byte of graphics commands
       DEC $0E    ; Decrement the count down register
       GLO $0E    ; Get the current count
       BNZ SEND   ; Branch to send more as needed
       IDL        ; Done!!

; Graphics commands to send
DATA   BYTE $01   ; Move to ...
       BYTE $50   ; x: 50x
       BYTE $50   ; y: 50x
       BYTE $03   ; Set Color Red
       BYTE $FF   ; Red: FF
       BYTE $00   ; Green: 00
       BYTE $00   ; Blue: 00
       BYTE $02   ; Draw to ...
       BYTE $B0   ; x: B0x
       BYTE $50   ; y: 50x
       BYTE $03   ; Set Color Green
       BYTE $00   ; Red: 00
       BYTE $FF   ; Green: FF
       BYTE $00   ; Blue: 00
       BYTE $02   ; Draw to ...
       BYTE $B0   ; x: B0x
       BYTE $B0   ; y: B0x
       BYTE $03   ; Set Color Blue
       BYTE $00   ; Red: 00
       BYTE $00   ; Green: 00
       BYTE $FF   ; Blue: FF
       BYTE $02   ; Draw to ...
       BYTE $50   ; x: 50x
       BYTE $B0   ; y: B0x
       BYTE $03   ; Set Color Yellow
       BYTE $FF   ; Red: FF
       BYTE $FF   ; Green: FF
       BYTE $00   ; Blue: 00
       BYTE $02   ; Draw to ...
       BYTE $50   ; x: 50x
       BYTE $50   ; y: B0x
EDATA             ; Label to measure number of graphics commands
		   END

