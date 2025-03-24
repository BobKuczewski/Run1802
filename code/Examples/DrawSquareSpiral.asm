; 1802 program to draw a square spiral

GPort  EQU $6    ; Graphics port number

RDel   EQU $D    ; Register to point to current Delta
RCmd   EQU $C    ; Register to point to Commands
Step   EQU $8    ; How many pixels to expand spiral

START  ORG 00H

       LDI 0     ; Load 0 (could save a byte here)
       PHI RDel  ; Set high byte of RDel register to 0
       PHI RCmd  ; Set high byte of RCmd register to 0
       PLO RCmd  ; Set low byte of RCmd register to 0
       LDI Delta ; Load address of the changing Delta
       PLO RDel  ; Set RDel register to point at Delta
       SEX RCmd  ; Reset RCmd to point at Cmd

       ; Clear screen to dark green
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Set RCmd to point at Cmd
       LDI $4    ; Clear with background command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Send command and advance X (RCmd)
       LDI $00   ; Red value = 0
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Send Red and advance X (RCmd)
       LDI $60   ; Green value = $60
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Send Green and advance X (RCmd)
       LDI $00   ; Blue value = 0
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Send Blue and advance X (RCmd)

       ; Set drawing color to green
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $3    ; Set Color command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)
       LDI $00   ; Red
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)
       LDI $FF   ; Green
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)
       LDI $00   ; Blue
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)

       ; Move to the Center
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $1    ; Move command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)
       LDI $80   ; x
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)
       LDI $80   ; y
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)

Draw

       ; Draw a Vertical Segment Up
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $2    ; Draw command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Output Command and Advance X (RCmd)
       OUT GPort ; Output x (same as last x) and Advance X (RCmd)
       LDN RCmd  ; Load y
       SEX RDel  ; Set X to point to Delta
       SM        ; Change y by current Delta
       SEX RCmd  ; Set X back to Cmd buffer
       STR RCmd  ; Store y in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)

       ; Draw a Horizontal Segment Right
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $2    ; Draw command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Output Command and Advance X (RCmd)
       LDN RCmd  ; Load x value
       SEX RDel  ; Set X to point to Delta
       ADD       ; Change x by current Delta
       SEX RCmd  ; Set X back to Cmd buffer
       STR RCmd  ; Store x in RCmd for output via X
       OUT GPort ; Output x and Advance X (RCmd)
       OUT GPort ; Output y (same as last y) and Advance X (RCmd)

       ; Increase the step size
       SEX RDel  ; Set X to be the Delta Register
       LDI Step  ; Load the step size
       ADD       ; Add Step to Delta
       BDF Done  ; If it causes an overflow, then we're done
       STR RDel  ; Store the new step in Delta
       SEX RCmd  ; Set X back to Rcmd

       ; Draw a Vertical Segment Down
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $2    ; Draw command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Output Command and Advance X (RCmd)
       OUT GPort ; Output x (same as last x) and Advance X (RCmd)
       LDN RCmd  ; Load y
       SEX RDel  ; Set X to point to Delta
       ADD       ; Change y by current Delta
       SEX RCmd  ; Set X back to Cmd buffer
       STR RCmd  ; Store y in RCmd for output via X
       OUT GPort ; Out and Advance X (RCmd)

       ; Draw a Horizontal Segment Left
       LDI Cmd   ; Load address of Cmd
       PLO RCmd  ; Reset RCmd to point at Cmd
       LDI $2    ; Draw command
       STR RCmd  ; Store in RCmd for output via X
       OUT GPort ; Output Command and Advance X (RCmd)
       LDN RCmd  ; Load x value
       SEX RDel  ; Set X to point to Delta
       SM        ; Change x by current Delta
       SEX RCmd  ; Set X back to Cmd buffer
       STR RCmd  ; Store x in RCmd for output via X
       OUT GPort ; Output x and Advance X (RCmd)
       OUT GPort ; Output y (same as last y) and Advance X (RCmd)

       ; Increase the step size
       SEX RDel  ; Set X to be the Delta Register
       LDI Step  ; Load the step size
       ADD       ; Add Step to Delta
       BDF Done  ; If it causes an overflow, then we're done
       STR RDel  ; Store the new step in Delta
       SEX RCmd  ; Set X back to Rcmd

       BR Draw   ; Branch back to continue drawing

Done   IDL

Delta  Byte Step   ; The current delta (grows further from center)
Cmd    Byte 0      ; First command byte for sending graphics commands
Data   Byte 1,2,3  ; Data bytes for sending graphics commands

		   END

