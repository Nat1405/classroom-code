;
; a2q1.asm
;
; Write a program that displays the binary value in r16
; on the LEDs.
;
; See the assignment PDF for details on the pin numbers and ports.
;


		ldi r16, 0xFF
		out DDRB, r16		; PORTB all output
		sts DDRL, r16		; PORTL all output

		ldi r16, 0x33		; display the value
		mov r0, r16			; in r0 on the LEDs

; Your code here
; tested on lab machine A-BOAR

		ldi r20, 0			; Eventually written to PORTL
		ldi r21, 0			; Eventually written to PORTB

		; check least significant bit
		mov r16, r0			; Copy r0 to r16 so we can ANDI and ORI with the value in it
		andi r16, 0b00000001
		brne or1
		jmp test2
or1:	ori r20, 0b10000000

test2:	mov r16, r0
		andi r16, 0b00000010
		brne or2
		jmp test3
or2:	ori r20, 0b00100000

test3:	mov r16, r0
		andi r16, 0b00000100
		brne or3
		jmp test4
or3:	ori r20, 0b00001000

test4:	mov r16, r0
		andi r16, 0b00001000
		brne or4
		jmp test5
or4:	ori r20, 0b00000010

test5:	mov r16, r0
		andi r16, 0b00010000
		brne or5
		jmp test6
or5:	ori r21, 0b00001000

test6:	mov r16, r0
		andi r16, 0b00100000
		brne or6
		jmp load
or6:	ori r21, 0b00000010

load:	sts PORTL, r20
		out PORTB, r21

;
; Don't change anything below here
;
done:	jmp done
