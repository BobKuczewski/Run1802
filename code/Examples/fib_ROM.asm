; Print the Fibonacci series without RAM

START		ORG	0H

        ; Use RA and RB as FIB 1 and FIB 2
		    ; Set their upper address to use the table
		    LDI 1
		    PHI $A
		    PHI $B

		    LDI 0       ; Initialize RA as FIB1
		    PLO $A      ; RA
		    SEX $A
		    OUT 4
		    DEC $A
		    LDI 01      ; Initialize RB as FIB2
		    PLO $B      ; RB
		    SEX $B
		    OUT 4
		    DEC $B

        SEQ

		    LDI 0       ; Initialize the Fib sequence with 0
Loop
        GLO $A      ; D = 0 1 3
        SEX $B      ; X = B
        ADD         ; D = 1 3 8
        PLO $A      ; A = 1 3 8
        SEX $A      ; X = A
        OUT 4       ; OUT: 1 3 8
        DEC $A      ; Undo the increment from OUT
        GLO $B      ; D = 1 2 5
        SEX $A      ; A = 1 3 8
        ADD         ; D = 2 5
        PLO $B      ; B = 2 5
        SEX $B      ; X = B
        OUT 4       ; OUT: 2 5
        DEC $B      ; Undo the increment from OUT
        BR Loop

        IDL

Table   ORG $100
        byte $00, $01, $02, $03, $04, $05, $06, $07
        byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
        byte $10, $11, $12, $13, $14, $15, $16, $17
        byte $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
        byte $20, $21, $22, $23, $24, $25, $26, $27
        byte $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
        byte $30, $31, $32, $33, $34, $35, $36, $37
        byte $38, $39, $3a, $3b, $3c, $3d, $3e, $3f
        byte $40, $41, $42, $43, $44, $45, $46, $47
        byte $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
        byte $50, $51, $52, $53, $54, $55, $56, $57
        byte $58, $59, $5a, $5b, $5c, $5d, $5e, $5f
        byte $60, $61, $62, $63, $64, $65, $66, $67
        byte $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
        byte $70, $71, $72, $73, $74, $75, $76, $77
        byte $78, $79, $7a, $7b, $7c, $7d, $7e, $7f
        byte $80, $81, $82, $83, $84, $85, $86, $87
        byte $88, $89, $8a, $8b, $8c, $8d, $8e, $8f
        byte $90, $91, $92, $93, $94, $95, $96, $97
        byte $98, $99, $9a, $9b, $9c, $9d, $9e, $9f
        byte $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7
        byte $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af
        byte $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7
        byte $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf
        byte $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7
        byte $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
        byte $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7
        byte $d8, $d9, $da, $db, $dc, $dd, $de, $df
        byte $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7
        byte $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef
        byte $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7
        byte $f8, $f9, $fa, $fb, $fc, $fd, $fe, $ff

        END

