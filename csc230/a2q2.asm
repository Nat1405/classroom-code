;
; a2q2.asm
;
;
; Turn the code you wrote in a2q1.asm into a subroutine
; and then use that subroutine with the delay subroutine
; to have the LEDs count up in binary.

; tested on lab machine A-BOAR

		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

; Your code here
; Be sure that your code is an infite loop

		clr r0
loop:	ldi r20, 0x10

		call display
		call delay
		inc r0
		rjmp loop




done:		jmp done	; if you get here, you're doing it wrong

;
; display
; 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		ldi r17, 0			; Eventually written to PORTL
		ldi r18, 0			; Eventually written to PORTB

		; check least significant bit
		mov r16, r0			; Copy r0 to r16 so we can ANDI and ORI with the value in it
		andi r16, 0b00000001
		brne or1
		jmp test2
or1:	ori r17, 0b10000000

test2:	mov r16, r0
		andi r16, 0b00000010
		brne or2
		jmp test3
or2:	ori r17, 0b00100000

test3:	mov r16, r0
		andi r16, 0b00000100
		brne or3
		jmp test4
or3:	ori r17, 0b00001000

test4:	mov r16, r0
		andi r16, 0b00001000
		brne or4
		jmp test5
or4:	ori r17, 0b00000010

test5:	mov r16, r0
		andi r16, 0b00010000
		brne or5
		jmp test6
or5:	ori r18, 0b00001000

test6:	mov r16, r0
		andi r16, 0b00100000
		brne or6
		jmp load
or6:	ori r18, 0b00000010

load:	sts PORTL, r17
		out PORTB, r18
		ret
;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; registers used:
;	r20
;	r21
;	r22
;
delay:	
del1:	nop
		ldi r21,0xFF
del2:	nop
		ldi r22, 0xFF
del3:	nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret
