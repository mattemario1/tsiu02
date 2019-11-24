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
		;
		ldi		r17, $FF
		out		DDRB, r17
START:
		ldi		ZH, HIGH (WORD*2)
		ldi		ZL, LOW (WORD*2)
LOOKUP:
		lpm		r16, Z+
		cpi		r16, 0
		breq	START
		cpi		r16, $20
		breq	SPACE
		subi	r16, $41
		push	ZH
		push	ZL
		ldi		ZH, HIGH (BTAB*2)
		ldi		ZL, LOW (BTAB*2)
		add		ZL, r16
		lpm		r16, Z
		pop		ZL
		pop		ZH
		call	SEND
		rjmp	LOOKUP

SPACE:
		rjmp	LOOKUP


;--------------------------;
SEND:
		cpi		r16, $80
		breq	RETURN
		lsl		r16
		brcc	SHORT_BEEP
		call	SOUND
SHORT_BEEP:
		call	SOUND
		rjmp	SEND

SOUND:
		ldi		r17, 1	//hur långt beepet ska va
WAVE:
		ldi		r18, $FF
		out		PORTB, r18
		;call	DELAY
		ldi		r18, $00
		out		PORTB, r18
		;call	DELAY
		dec		r17
		brne	WAVE
RETURN:
		ret
;--------------------------;
DELAY:
		ldi		r20, 10
YTTRE:
		ldi		r21, $1F
INNRE:
		dec		r21
		brne	INNRE
		dec		r20
		brne	YTTRE
		ret

;--------------------------;	
		.org	$100
WORD:
		.db		"B", 0

		.org	$150
BTAB:
		
		.db		$60, $88, $A8, $90, $40, $28, $D0, $08, $20, $78, $B0, $48,$E0, $A0, $F0, $68, $D8, $50, $10, $C0, $30, $18, $70, $98, $B8, $C8, $00
		//inget mellanslag