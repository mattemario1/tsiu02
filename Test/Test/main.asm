;
; Test.asm
;
; Created: 20/11/2019 12:54:58
; Author : Mattias
;


; Replace with your application code
start:
		.org	"A"
		.db		$60
		.org	"B"
		.db		$88
		.org	"C"
		.db		$A2
		.org	"D"
		.db		$90
		.org	"E"
		.db		$40

TEST:
		.org	$0150
		.db		"BCD", 0
WORD:
		