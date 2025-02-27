; 1802 program to explore subtraction in the 1802

START  ORG 00H

        seq

        ldi 0    ; Zero F upper
        phi 0fh  
        ldi out  ; Load address of "out"
        plo 0fh  ; Put in F lower
        sex 0fh  ; Set F as X

        ldi 5    ; Put 5 in D
        sdi 0    ; Subtract D from immediate: 0 - 5  =>  D
        str 0fh  ; Store D in M[R[X=F]] or "out"
        out 4    ; Print the value of M[R[X=F]] (should be -5 or FB)

        sdi 0    ; Subtract D from immediate: 0 - (-5)  =>  D
        str 0fh  ; Store D in M[R[X=F]] or "out"
        out 4    ; Print the value of M[R[X=F]] (should be 5)

        ; Adding across the sign bit
        ldi 125     ; D = 125
        adi   1     ; D = 126
        str 0fh
        out 4       ; Should print 7E (126)
        adi   1     ; D = 127
        str 0fh
        out 4       ; Should print 7F (127)
        adi   1     ; D = 128
        str 0fh
        out 4       ; Should print 80 (128)
        adi   1     ; D = 129
        str 0fh
        out 4       ; Should print 81 (129)

        ; Subtracting across the sign bit
        smi   1     ; D = 128
        str 0fh
        out 4       ; Should print 80 (128)
        smi   1     ; D = 127
        str 0fh
        out 4       ; Should print 7F (127)
        smi   1     ; D = 126
        str 0fh
        out 4       ; Should print 7E (126)

        req
        idl

out     byte 0

        end

