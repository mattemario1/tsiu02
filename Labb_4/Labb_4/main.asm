;
; Labb_4.asm
;
; Created: 10/12/2019 20:56:01
; Author : Mattias

; --- lab4_skal . asm
.equ VMEM_SZ = 5		; # rows on display
.equ AD_CHAN_X = 0		; ADC0 = PA0 , PORTA bit 0 X - led
.equ AD_CHAN_Y = 1		; ADC1 = PA1 , PORTA bit 1 Y - led
.equ GAME_SPEED = 70	; inter - run delay ( millisecs )
.equ PRESCALE = 7		; AD - prescaler value
.equ BEEP_PITCH = 20	; Victory beep pitch
.equ BEEP_LENGTH = 100	; Victory beep length
; ---------------------------------------


; --- Memory layout in SRAM
.dseg
.org SRAM_START
POSX:	.byte 1		; Own position
POSY:	.byte 1
TPOSX:	.byte 1		; Target position
TPOSY:	.byte 1
LINE:	.byte 1		; Current line
VMEM:	.byte VMEM_SZ ; Video MEMory
SEED:	.byte 1		; Seed for Random
; ---------------------------------------


; --- Macros for inc / dec - rementing
; --- a byte in SRAM
.macro INCSRAM ; inc byte in SRAM
	lds		r16, @0
	inc		r16
	sts		@0, r16
.endmacro

.macro DECSRAM ; dec byte in SRAM
	lds		r16, @0
	dec		r16
	sts		@0, r16
.endmacro
; ---------------------------------------


; --- Code
.cseg
.org	$0
jmp		START
.org	INT0addr
jmp		MUX
;


START:
	; satt stackpekaren
	call	HW_INIT
	call	WARM
RUN:
	call	JOYSTICK
	call	ERASE
	call	UPDATE
	;*** Vanta en stund sa inte spelet gar for fort ***
	;*** Avgor om traff ***
	brne	NO_HIT
	ldi		r16, BEEP_LENGTH
	call	BEEP
	call	WARM
NO_HIT:
	jmp		RUN
; ---------------------------------------


; --- Multiplex display
; --- Uses : r16
MUX:
	;*** skriv rutin som handhar multiplexningen och ***
	;*** utskriften till diodmatrisen . Oka SEED . ***
	reti
; ---------------------------------------



; --- JOYSTICK Sense stick and update POSX , POSY
; --- Uses :
JOYSTICK:
	;*** skriv kod som okar eller minskar POSX beroende ***
	;*** pa insignalen fran A/D - omvandlaren i X - led ... ***
	;*** ... och samma for Y - led ***

JOY_LIM:
	call LIMITS ; don � t fall off world !
	ret
; ---------------------------------------



; --- LIMITS Limit POSX , POSY coordinates
; --- Uses : r16 , r17
LIMITS:
	lds		r16, POSX	; variable
	ldi		r17, 7		; upper limit +1
	call	POS_LIM	; actual work
	sts		POSX, r16
	lds		r16, POSY	; variable
	ldi		r17, 5		; upper limit +1
	call	POS_LIM	; actual work
	sts		POSY, r16
	ret
POS_LIM:
	ori		r16, 0 ; negative ?
	brmi	POS_LESS ; POSX neg = > add 1
	cp		r16, r17 ; past edge
	brne	POS_OK
	subi	r16, 2
POS_LESS:
	inc		r16
POS_OK:
	ret
; ---------------------------------------



; --- UPDATE VMEM
; --- with POSX /Y , TPOSX /Y
; --- Uses : r16 , r17 , Z
UPDATE:
	clr		ZH
	ldi		ZL, LOW (POSX)
	call	SETPOS
	clr		ZH
	ldi		ZL, LOW (TPOSX)
	call	SETPOS
	ret
	; --- SETPOS Set bit pattern of r16 into * Z
	; --- Uses : r16 , r17 , Z
	; --- 1 st call Z points to POSX at entry and POSY at exit
	; --- 2 nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld		r17, Z+ ; r17 = POSX
	call	SETBIT	; r16 = bitpattern for VMEM + POSY
	ld		r17, Z	; r17 = POSY Z to POSY
	ldi		ZL, LOW (VMEM)
	add		ZL, r17 ; Z= VMEM + POSY , ZL = VMEM +0..4
	ld		r17, Z	; current line in VMEM
	or		r17, r16 ; OR on place
	st		Z, r17	; put back into VMEM
	ret
	; --- SETBIT Set bit r17 on r16
	; --- Uses : r16 , r17
SETBIT:
	ldi		r16 , $01 ; bit to shift
SETBIT_LOOP:
	dec		r17
	brmi	SETBIT_END ; til done
	lsl		r16 ; shift
	jmp		SETBIT_LOOP
SETBIT_END:
	ret
; ---------------------------------------




; --- Hardware init
; --- Uses :
HW_INIT:
	;*** Konfigurera hardvara och MUX - avbrott enligt ***
	;*** ditt elektriska schema . Konfigurera ***
	;*** flanktriggat avbrott pa INT0 ( PD2 ). ***
	sei ; display on
	ret
; ---------------------------------------



; --- WARM start . Set up a new game .
; --- Uses :
WARM:
	;*** Satt startposition ( POSX , POSY )=(0 ,2) ***
	push	r0
	push	r0
	call	RANDOM ; RANDOM returns TPOSX , TPOSY on stack
	;*** Satt startposition ( TPOSX , TPOSY ) ***
	call	ERASE
	ret


; ---------------------------------------
; --- RANDOM generate TPOSX , TPOSY
; --- in variables passed on stack .
; --- Usage as :
; --- push r0
; --- push r0
; --- call RANDOM
; --- pop TPOSX
; --- pop TPOSY
; --- Uses : r16
RANDOM:
	in		r16, SPH
	mov		ZH, r16
	in		r16, SPL
	mov		ZL, r16
	lds		r16, SEED
	;*** Anvand SEED for att berakna TPOSX ***
	;*** Anvand SEED for att berakna TPOSY ***
	;*** ; store TPOSX 2..6
	;*** ; store TPOSY 0..4
	ret
; ---------------------------------------



; --- ERASE videomemory
; --- Clears VMEM .. VMEM +4
; --- Uses :
ERASE:
	;*** Radera videominnet ***
	ret
; ---------------------------------------


; --- BEEP ( r16 ) r16 half cycles of BEEP - PITCH
; --- Uses :
BEEP:
	;*** skriv kod for ett ljud som ska markera traff ***
	ldi		r17, BEEP_LENGTH
	ldi		r18, BEEP_PITCH
	call	WAVE
	ldi		r18, BEEP_PITCH*2
	call	WAVE
	ret
WAVE:
	ldi		r16, 0xFF
	out		PORTB, r16
	call	DELAY
	clr		r16
	out		PORTB, r16
	call	DELAY
	dec		r17
	brne	RETURN	;branch if minus?
	rjmp	WAVE
RETURN:
	ret
	
DELAY:
OUTER:
	ldi		r19, 0xFF
	dec		r19
	brne	OUTER
INNER:
	dec		r18
	brne	OUTER
	ret