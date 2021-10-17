;
; LAX2.asm
;
; Created: 09/01/2020 12:12:22
; Author : Mattias
;

START:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, HIGH(RAMEND)
	out		SPL, r16
	;
	call	HW_INIT
MAIN_LOOP:
	sbic	PINA, 0
	call	INCREASE
	sbic	PINA, 1
	call	DISPLAY
	rjmp	MAIN_LOOP
	;
INCREASE:
	cpi		r17, 0x0F
	breq	LIMIT
	inc		r17
LIMIT:
	ret
	;
DISPLAY:
	out		PORTB, r17
	clr		r17
	ret

HW_INIT:
	clr		r16
	out		DDRA, r16
	ldi		r16, 0xFF
	out		DDRB, r16
	ret
