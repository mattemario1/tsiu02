;
; Lab_4.asm
;
; Created: 13/12/2019 15:32:54
; Author : Mattias
	
	; --- lab4spel.asm

	.equ	VMEM_SZ     = 5		; #rows on display
	.equ	AD_CHAN_X   = 0		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = 1		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 70	; inter-run delay (millisecs)
	.equ	PRESCALE    = 7		; AD-prescaler value
	.equ	BEEP_PITCH  = 20	; Victory beep pitch
	.equ	BEEP_LENGTH = 100	; Victory beep length
	; ---------------------------------------


	; --- Memory layout in SRAM
	.dseg
	.org	SRAM_START
POSX:	.byte	1	; Own position
POSY:	.byte 	1
TPOSX:	.byte	1	; Target position
TPOSY:	.byte	1
LINE:	.byte	1	; Current line	
VMEM:	.byte	VMEM_SZ ; Video MEMory
SEED:	.byte	1	; Seed for Random
	; ---------------------------------------


	; --- Macros for inc/dec-rementing
	; --- a byte in SRAM
	.macro INCSRAM	; inc byte in SRAM
		lds	r16,@0
		inc	r16
		sts	@0,r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16,@0
		dec	r16
		sts	@0,r16
	.endmacro
; ---------------------------------------



	; --- Code
	.cseg
	.org 	0x0
	jmp	START
	.org	INT0addr
	jmp	MUX


START:
;	***			; s�tt stackpekaren
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	;	
	call	HW_INIT	
	call	WARM
RUN:
	call	JOYSTICK
	call	ERASE_VMEM
	call	UPDATE

;*** 	V�nta en stund s� inte spelet g�r f�r fort 	***
	
;*** 	Avg�r om tr�ff				 	***

	brne	NO_HIT	
	call	BEEP
	call	WARM
NO_HIT:
	jmp	RUN
; ---------------------------------------



	; --- Multiplex display
MUX:	
	;Pushar allt som kan ha anv�nds i START
	push	r16
	in		r16, SREG
	push	r16
	push	r17
	;

	;*** 	skriv rutin som handhar multiplexningen och ***
	;*** 	utskriften till diodmatrisen. �ka SEED.		***

	;
	INCSRAM	SEED	
	;Poppar allt som kan ha anv�nds i START
	pop		r16
	out		SREG, r16
	pop		r16
	pop		r17
	reti
; ---------------------------------------



	; --- JOYSTICK Sense stick and update POSX, POSY
	; --- Uses r16
JOYSTICK:	

	;*** 	skriv kod som �kar eller minskar POSX beroende 	***
	;*** 	p� insignalen fr�n A/D-omvandlaren i X-led...	***
CONV:
	sbi		ADCSRA, ADSC
WAIT:
	sbic	ADCSRA, ADSC
	jmp		WAIT
	in		r16, ADCH
CHANGEXY:
	
	;*** 	...och samma f�r Y-led 				***

JOY_LIM:
	call	LIMITS		; don't fall off world!
	ret
; ---------------------------------------



	; --- LIMITS Limit POSX,POSY coordinates	
	; --- Uses r16,r17
LIMITS:
	lds		r16,POSX	; variable
	ldi		r17,7		; upper limit+1
	call	POS_LIM		; actual work
	sts		POSX,r16
	lds		r16,POSY	; variable
	ldi		r17,5		; upper limit+1
	call	POS_LIM		; actual work
	sts		POSY,r16
	ret

POS_LIM:
	ori		r16, 0		; negative?
	brmi	POS_LESS	; POSX neg => add 1
	cp		r16, r17		; past edge
	brne	POS_OK
	subi	r16, 2
POS_LESS:
	inc		r16	
POS_OK:
	ret
; ---------------------------------------



	; --- UPDATE VMEM
	; --- with POSX/Y, TPOSX/Y
	; --- Uses r16, r17
UPDATE:	
	clr		ZH 
	ldi		ZL, LOW(POSX)
	call 	SETPOS
	clr		ZH
	ldi		ZL, LOW(TPOSX)
	call	SETPOS
	ret

	; --- SETPOS Set bit pattern of r16 into *Z
	; --- Uses r16, r17
	; --- 1st call Z points to POSX at entry and POSY at exit
	; --- 2nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld		r17, Z+  	; r17=POSX
	call	SETBIT		; r16=bitpattern for VMEM+POSY
	ld		r17, Z		; r17=POSY Z to POSY
	ldi		ZL, LOW(VMEM)
	add		ZL, r17		; *(VMEM+T/POSY) ZL=VMEM+0..4
	ld		r17, Z		; current line in VMEM
	or		r17, r16		; OR on place
	st		Z, r17		; put back into VMEM
	ret
	
	; --- SETBIT Set bit r17 on r16
	; --- Uses r16, r17
SETBIT:
	ldi		r16, 0x01		; bit to shift
SETBIT_LOOP:
	dec 	r17			
	brmi 	SETBIT_END	; til done
	lsl 	r16		; shift
	jmp 	SETBIT_LOOP
SETBIT_END:
	ret
; ---------------------------------------



	; --- Hardware init
	; --- Uses r16
HW_INIT:

	;*** 	Konfigurera h�rdvara och MUX-avbrott enligt ***
	;*** 	ditt elektriska schema. Konfigurera 		***
	;*** 	flanktriggat avbrott p� INT0 (PD2).			***
	ldi		r16, 0x00|(1 << ADLAR)
	out		ADMUX, r16	;A is joystick input with only 8-bit in ADCH
	ldi		r16, (1 << ADEN)
	out		ADCSRA, r16	;A/D enable

	;
	ldi		r16, 0xFF
	out		DDRB, r16	;B is horizontal display output and speaker output
	out		DDRD, r16	;D is vertical display output
	;;;;;;;;;;INT0 och horizontal display output kanske krockar med varandra?;;;;;;;
	ldi		r16, (1 << ISC00)|(1 << ISC01)	
	out		MCUCR, r16		;INT0 interupt at rising strobe
	ldi		r16, (1 << INT0)	
	out		GICR, r16		;activate INT0
	ldi		r16, 0x04
	out		PORTD, r16		;get INT0 to light up?	
	;
	sei			; display on
	ret
; ---------------------------------------



	; --- WARM start. Set up a new game
WARM:

	;*** 	S�tt startposition (POSX,POSY)=(0,2)		***
	clr		r16
	sts		POSX, r16	;set your X to 0
	ldi		r16, 2
	sts		POSY, r16	;set your Y to 2
	;
	;push	r0		
	;push	r0		
	call	RANDOM		; RANDOM returns x,y on stack

	;*** 	S�tt startposition (TPOSX,POSY)				***

	call	ERASE_VMEM
	ret
; ---------------------------------------



	; --- RANDOM generate TPOSX, TPOSY
	; --- in variables passed on stack.
	; --- Usage as:
	; ---	push r0 
	; ---	push r0 
	; ---	call RANDOM
	; ---	pop TPOSX 
	; ---	pop TPOSY
	; --- Uses r16
RANDOM:
	;in		r16, SPH	;;;;har ingen aning vad detta �r till f�r?;;;;
	;mov	ZH, r16		;	
	;in		r16, SPL	;
	;mov	ZL, r16		;
	;
	lds		r16, SEED
	andi	r16, 0x07
	subi	r16, 3
	brpl	OVERLIMIT
	subi	r16, -3
OVERLIMIT:
	sts		TPOSY, r16
	subi	r16, -2
	sts		TPOSX, r16
	ret		
	
	;*** 	Anv�nd SEED f�r att ber�kna TPOSX		***
	;*** 	Anv�nd SEED f�r att ber�kna TPOSX		***

	;	***		; store TPOSX	2..6
	;	***		; store TPOSY   0..4
; ---------------------------------------




	; --- Erase Videomemory bytes
	; --- Clears VMEM..VMEM+4
	; --- uses r16, r17
	
ERASE_VMEM:
	;*** 	Radera videominnet						***
	clr		ZH
	ldi		ZL, LOW(VMEM)
	clr		r16
	ldi		r17, VMEM_SZ
ZERO_VMEM:
	st		Z+, r16
	dec		r17
	brne	ZERO_VMEM
	ret
; ---------------------------------------





; --- BEEP
; --- uses r16, r17, r18, r19, r20, r21

;SCALE:
	;.db		0xFC, 0xE0, 0xCA, 0xBA, 0xA3, 0x90, 0x7E, 0x7A
NOTES:
	.db		0xFC, 0, 0xE0, 0, 0xCA, 0, 0xBA, 0xA3, 0x90, 0x7E, 0x7A

BEEP:	

;*** skriv kod f�r ett ljud som ska markera tr�ff 	***
	ldi		r17, 0xFF
	ldi		r21, (BEEP-NOTES)*2
	ldi		ZH, HIGH(NOTES*2)
	ldi		ZL, LOW(NOTES*2)
	call	SONG
	jmp		START

SONG:
	lpm		r16, Z
	cpi		r16, 0
	breq	PAUSEMUSIC
	call	WAVE
SONGCONTINUE:
	adiw	Z, 1
	dec		r21
	brne	SONG
PAUSEMUSIC:
	ldi		r19, 0xFF
OUTER:
	dec		r19
	brne	OUTER
INNER:
	dec		r20
	brne	PAUSEMUSIC
	rjmp	SONGCONTINUE
	ret


WAVE:
	ldi		r16, 0xFF
	out		PORTB, r16
	call	WAVEDELAY
	clr		r16
	out		PORTB, r16
	call	WAVEDELAY
	dec		r17
	cpi		r17, 0x00
	breq	RETURN	
	rjmp	WAVE
RETURN:
	ldi		r17, 0xFF
	ret
	
WAVEDELAY:
	lpm		r18, Z
WINNER:
	dec		r18
	brne	WINNER
	ret





			
