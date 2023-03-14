; Set Q, double address, Reset Q, double address

	ORG 0000H  ; Locate this code at 0000
	SEQ
	LBR 0004H


	ORG 0004H  ; Locate this code at 0004
	REQ
	LBR 0008H

	ORG 0008H  ; Locate this code at 0008
	SEQ
	LBR 0010H

	ORG 0010H  ; Locate this code at 0010
	REQ
	LBR 0020H

	ORG 0020H  ; Locate this code at 0020
	SEQ
	LBR 0040H

	ORG 0040H  ; Locate this code at 0040
	REQ
	LBR 0080H

	ORG 0080H  ; Locate this code at 0080
	SEQ
	LBR 0100H

	ORG 0100H ; Locate this code at 0100
	REQ
	LBR 0200H

	ORG 0200H  ; Locate this code at 0200
	SEQ
	LBR 0400H

	ORG 0400H  ; Locate this code at 0400
	REQ
	LBR 0800H

	ORG 0800H  ; Locate this code at 0800
	SEQ
	LBR 1000H

	ORG 1000H  ; Locate this code at 1000
	REQ
	LBR 2000H

	ORG 2000H  ; Locate this code at 2000
	SEQ
	LBR 4000H

	ORG 4000H  ; Locate this code at 4000
	REQ
	LBR 8000H

	ORG 8000H  ; Locate this code at 8000
	SEQ
	LBR 0FFFCH

	ORG 0FFFCH  ; Locate this code at FFFC
	REQ
	LBR 0000

	END
