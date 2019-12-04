;
; Digitalur.asm
;
; Created: 28/11/2019 12:05:03
; Author : Mattias

		.org	0x00
		rjmp	INIT
		.org	INT0addr	; =0x02
		rjmp	INTERRUPT0
		.org	INT1addr	; =0x04
		rjmp	INTERRUPT1
INIT:
		ldi		r16, HIGH(RAMEND)
		out		SPH, r16
		ldi		r16, LOW(RAMEND)
		out		SPL, r16
		;
		ldi		ZH, HIGH (NUMBERS*2)
		ldi		ZL, LOW (NUMBERS*2)

		;får interupten att aktivera till stigande strobe
		ldi		r16, (1 << ISC01)|(1 << ISC00)|(1 << ISC11)|(1 << ISC10)
		out		MCUCR, r16
		ldi		r16, (1 << INT0)|(1 << INT1)
		out		GICR, r16

		;Gör A till output och D till input
		ldi		r16, 0x00
		out		DDRD, r16
		ldi		r16, 0xFF
		out		DDRA, r16
		out		DDRB, r16
		;
		ldi		r16, 0b00000110	;0B skriver in binärt. Kan skriva hex med 0x istället för 0x
		out		PORTD, r16		;
		sei

		rjmp	START
		;

NUMBERS:
		.org	0x100	
		.db		0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

START:
		rjmp	START

INTERRUPT1:
		;Pushar allt som kan ha används i MAIN/START
		push	r16
		in		r16, SREG
		push	r16
		;
		lds		r16, 0x60
		inc		r16
		sts		0x60, r16
		out		PORTA, r16

		;Poppar allt som kan ha används i MAIN
		pop		r16
		out		SREG, r16
		pop		r16
		;
		reti
INTERRUPT0:
		;Pushar allt som kan ha används i MAIN/START
		push	r16
		in		r16, SREG
		push	r16
		;Poppar allt som kan ha används i MAIN
		pop		r16
		out		SREG, r16
		pop		r16
		;
		reti
