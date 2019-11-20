;
; Morseändre.asm
;
; Created: 19/11/2019 10:12:16
; Author : Mattias
;

INIT:
		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16
WORD:
		.db		"HEJ DO", 0

.org	$0150
BTAB:
		.db		" ", $20
		.db		"A", $60
		.db		"B", $88
		.db		"C", $A8
		.db		"D", $90
		.db		"E", $40
		.db		"F", $28
		.db		"G", $D0
		.db		"H", $08
		.db		"I", $20
		.db		"J", $78
		.db		"K", $B0
		.db		"L", $48
		.db		"M", $E0
		.db		"N", $A0
		.db		"O", $F0
		.db		"P", $68
		.db		"Q", $D8
		.db		"R", $50
		.db		"S", $10
		.db		"T", $C0
		.db		"U", $30
		.db		"V", $18
		.db		"W", $70
		.db		"X", $98
		.db		"Y", $B8
		.db		"Z", $C8



COUNTER:
		ldi		r18, 0
LOOKUP:
		ldi		ZH, HIGH (WORD*2)
		ldi		ZL, LOW (WORD*2)
		brne	END
		add		ZL, r18
		lpm		r16, Z
		inc		r18
		ldi		ZH, HIGH (BTAB*2)
		ldi		ZL, LOW (BTAB*2)
INNRELOOP:
		lpm		r17, Z
		adiw	Z, 2
		cp		r16, r17
		breq	SEND
		rjmp	INNRELOOP

SEND:	
		rjmp	LOOKUP
		
END:
		rjmp	END

		


