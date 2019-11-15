;
; Lab_1.asm
;
; Created: 12/11/2019 14:36:41
; Author : Mattias
;

;
; AssemblerApplication2.asm
;
; Created: 12/11/2019 12:13:17
; Author : Mattias
;


ldi		r16, HIGH(RAMEND)
out		SPH, r16
ldi		r17, LOW(RAMEND)
out		SPL, r16

clr		r16
out		DDRA, r16
ldi		r16, $FF
out		DDRB, r16

clr		r16
Idle:
		call	GET_KEY
Loop:
		cpi		r20, 0
		breq	Idle
		jmp		Check_1


Get_KEY:
		clr		r20
		sbic	PINA, 0
		dec		r20	; r20, $FF
		ret


Check_1:
		ldi		r16, 5	; Halv DELAY
		;call	DELAY
		call	Get_KEY
		cpi		r20, 0
		breq	Idle
		ldi		r21, 4
		clr		r22
		jmp		Data

Data:
		ldi		r16, 10 ; Hel DELAY ;kan va en 8
		;call	DELAY
		call	Check_Data
		dec		r21
		cpi		r21, 0
		breq	Send
		lsr		r22
		jmp		Data


		

Check_Data:
		clr		r20
		sbic	PINA, 0
		ldi		r20, 1
		lsl		r20
		lsl		r20
		lsl		r20
		or		r22, r20
		ret

Send:
		out		PORTB, r22
		jmp		Idle


DELAY:
		sbi		PORTB, 7
dalayYttreLoop:
		ldi		r17, $1F; kan va en 1
dalayInreLoop:
		dec		r17
		brne	dalayInreLoop
		dec		r16
		brne	dalayYttreLoop
		cbi		PORTB, 7
		ret
