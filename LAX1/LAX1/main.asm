;
; LAX1.asm
;
; Created: 09/01/2020 11:31:09
; Author : Mattias
;
START:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	;
	call	HW_INIT
MAIN_LOOP:
	in		r16, PINA
	sbic	PINA, 7
	call	DISPLAY
	rjmp	MAIN_LOOP

DISPLAY:
	andi	r16, 0x0F
	subi	r16, 10
	brmi	DISPLAY_ONE
DISPLAY_TWO:
	out		PORTB, r16
	ldi		r16, 1
	out		PORTD, r16
	rjmp	DISPLAY_DONE
DISPLAY_ONE:
	subi	r16, -10
	out		PORTB, r16
DISPLAY_DONE:
	ret

HW_INIT:
	clr		r16
	out		DDRA, r16
	ldi		r16, 0xFF
	out		DDRB, r16	;ental
	out		DDRD, r16	;tiotal
	ret
	
