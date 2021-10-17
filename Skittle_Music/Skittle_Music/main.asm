/*
 * AssemblerApplication3.asm
 *
 *  Created: 2019-12-11 18:31:43
 *   Author: matho019
 */ 
 .equ WAVEDELAYLENGTH = 0x03

 INIT:
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16

	ldi		r16, 0xFF
	out		DDRB, r16
	rjmp	START


NOTE_LENGTH:
	.db		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF

;SCALE:
	;.db		0xFC, 0xE0, 0xCA, 0xBA, 0xA3, 0x90, 0x7E, 0x7A

NOTES1:
	.db		0xFC, 0xE0, 0xCA, 0xBA, 0xA3, 0x90, 0x7E, 0x7A






START:
	ldi		r21, (START-NOTES1)*2
	ldi		ZH, HIGH(NOTES1*2)
	ldi		ZL, LOW(NOTES1*2)

	ldi		YH, HIGH(NOTE_LENGTH*2)
	ldi		YL, LOW(NOTE_LENGTH*2)

	call	SONG1
	rjmp	START

SONG1:
	lpm		r16, Z
	cpi		r16, 0
	breq	DELAY
	lpm		r17, Y
	call	WAVE
SONGCONTINUE:
	adiw	Z, 1
	adiw	Y, 1
	dec		r21
	brne	SONG1
	ret


WAVE:
	ldi		r16, 0xFF
	out		PORTB, r16
	call	WAVEDELAY
	clr		r16
	out		PORTB, r16
	call	WAVEDELAY
	dec		r17
	cpi		r17, 0
	breq	WAVE_DONE	
	rjmp	WAVE
WAVE_DONE:
	ldi		r17, 0xFF
	ret
	
WAVEDELAY:
	push	ZH
	push	ZL
	lpm		r18, Z
WINNER:
	dec		r18
	brne	WINNER
	pop		ZL
	pop		ZH
	ret


DELAY:

	ldi		r19, 0xFF
OUTER:
	dec		r19
	brne	OUTER
INNER:
	dec		r20
	brne	DELAY
	rjmp	SONGCONTINUE
