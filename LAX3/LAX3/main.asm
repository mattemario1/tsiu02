;
; LAX3.asm
;
; Created: 09/01/2020 12:31:14
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
	call	CHANGE
	rjmp	MAIN_LOOP
	
CHANGE:
	andi	r16, 0x0F
	cpi		r16, 0x0F
	breq	CHANGE_DISPLAY
	subi	r16, 10
	brmi	CHANGE_NR
	subi	r16, -10
	rjmp	CHANGE_DONE
CHANGE_DISPLAY:
	call	TOGGLE_T
	rjmp	CHANGE_DONE
CHANGE_NR:
	subi	r16, -10
	brts	DISPLAY_TWO
DISPLAY_ONE:
	out		PORTB, r16
	rjmp	CHANGE_DONE
DISPLAY_TWO:
	out		PORTD, r16
CHANGE_DONE:
	ret

HW_INIT:
	clr		r17
	clr		r16
	out		DDRA, r16
	ldi		r16, 0xFF
	out		DDRB, r16
	out		DDRD, r16
	ret


TOGGLE_T:
	brts TOGGLE_OFF
	set
	jmp DONE
TOGGLE_OFF:
	clt
DONE:
	ret
