Ra          EQU    10
Rb          EQU    11
Rc          EQU    12

START       ORG    0H
            LDI 0
            PHI Ra
            PHI Rb
            PHI Rc
            LDI 1AH
            PLO Ra
            LDI 1BH
            PLO Rb
            LDI 0
            PLO Rc

LOOP        SEX Ra
            ADD
            STR Ra
            OUT 4
            DEC Ra
            SEX Rb
            ADD
            STR Rb
            OUT 4
            DEC Rb
            BR        LOOP
            BYTE        0        ; FIB 0 2 4 6 8 ...
            BYTE        1        ; FIB 1 3 5 7 9 ...

            END

