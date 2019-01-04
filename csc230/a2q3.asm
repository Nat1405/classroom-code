;
; a2q3.asm
;
; Write a main program that increments a counter when the buttons are pressed
;
; Use the subroutine you wrote in a2q2.asm to solve this problem.
;

		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

; Your code here
; make sure your code is an infinite loop

; tested on lab machine A-BOAR

		clr r25	; COUNTER VARIABLE

		clr r0	; Value to display on LED variable

loop:	ldi r20, 0x10

		call check_button
		add r25, r24 
		mov r0, r25
		call display
		rjmp loop



done:		jmp done		; if you get here, you're doing it wrong

;
; the function tests to see if the button
; UP or SELECT has been pressed
;
; on return, r24 is set to be: 0 if not pressed, 1 if pressed
;
; this function uses registers:
;	r16
;	r17
;	r24
;
; This function could be made much better.  Notice that the a2d
; returns a 2 byte value (actually 12 bits).
; 
; if you consider the word:
;	 value = (ADCH << 8) +  ADCL
; then:
;
; value > 0x3E8 - no button pressed
;
; Otherwise:
; value < 0x032 - right button pressed
; value < 0x0C3 - up button pressed
; value < 0x17C - down button pressed
; value < 0x22B - left button pressed
; value < 0x316 - select button pressed
;
; This function 'cheats' because I observed
; that ADCH is 0 when the right or up button is
; pressed, and non-zero otherwise.
; 
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		;

		clr r24
		; Check adc high if less than three
		cpi r17, 0x03
		brlo pressed
		
		cpi r16, 0x10
		brlo pressed

		cpi r17, 0
		brne skip		
pressed:	ldi r24,1
		call delay
skip:	ret

;
; delay
;
; set r20 before calling this function
; r20 = 0x40 is approximately 1 second delay
;
; this function uses registers:
;
;	r20
;	r21
;	r22
;
delay:	
del1:		nop
		ldi r21,0xFF
del2:		nop
		ldi r22, 0xFF
del3:		nop
		dec r22
		brne del3
		dec r21
		brne del2
		dec r20
		brne del1	
		ret

;
; display
;
; copy your display subroutine from a2q2.asm here
 
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;	r17 - value to write to PORTL
;	r18 - value to write to PORTB
;
;   r16 - scratch
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



