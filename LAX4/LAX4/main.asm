;
; LAX4.asm
;
; Created: 09/01/2020 13:21:33
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
	sbic	PINA, 7
	call	DISPLAY
	rjmp	MAIN_LOOP
DISPLAY:
	in		r16, PINA
	andi	r16, 0x0F
	cpi		r16, 0
	breq	TRIGGER_T
	mov		r17, r16
	mov		r18, r16
MAKE_DISPLAY:
	brts	COMPLEMENT
CONTINUE_DISPLAY:
	lsl		r17
	lsl		r17
	lsl		r17
	lsl		r17
	clr		r16
	or		r16, r17
	or		r16, r18
	out		PORTB, r16
	rjmp	DISPLAY_DONE
COMPLEMENT:
	mov		r17, r18
	com		r18
	andi	r18, 0x0F
	rjmp	CONTINUE_DISPLAY
TRIGGER_T:
	brts	T_OFF
	set
	rjmp	T_DONE
T_OFF:
	clt
T_DONE:
	rjmp	MAKE_DISPLAY

DISPLAY_DONE:
	ret

HW_INIT:
	clr		r16
	out		DDRA, r16
	ldi		r16, 0xFF
	out		DDRB, r16
	ret

