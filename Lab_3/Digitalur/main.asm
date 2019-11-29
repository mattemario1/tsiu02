;
; Digitalur.asm
;
; Created: 28/11/2019 12:05:03
; Author : Mattias

		.org	0
		rjmp	INIT
		.org	INT0addr
		rjmp	INTERRUPT0
		.org	INT1addr
		rjmp	INTERRUPT1
INIT:
		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16

		;får interupten att aktivera till stigande strobe
		ldi		r16, (1 << ISC01)|(0 << ISC00)|(1 << ISC11)|(0 << ISC10)
		out		MCUCR, r16
		ldi		r16, (1 << INT0)|(1 << INT1)
		out		GICR, r16
		sei

		;Gör D till output och B till input
		ldi		r16, $00
		out		DDRD, r16
		ldi		r16, $FF
		out		DDRB, r16
		rjmp	START
		;

START:
		rjmp	START

INTERRUPT1:
		ldi		r16, 80
		ldi		r16, 100
		rjmp	START
INTERRUPT0:
		rjmp	START