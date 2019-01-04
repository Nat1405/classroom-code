;
; a2q4.asm
;
; Fix the button subroutine program so that it returns
; a different value for each button
;
		; initialize the Analog to Digital conversion

		ldi r16, 0x87
		sts ADCSRA, r16
		ldi r16, 0x40
		sts ADMUX, r16

		; initialize PORTB and PORTL for ouput
		; tested on lab machine A-BOAR
		ldi	r16, 0xFF
		out DDRB,r16
		sts DDRL,r16

		clr r0
		call display
lp:
		call check_button
		tst r24
		breq lp
		mov	r0, r24

		call display
		ldi r20, 99
		call delay
		ldi r20, 0
		mov r0, r20
		call display
		rjmp lp

;
; An improved version of the button test subroutine
;
; Returns in r24:
;	0 - no button pressed
;	1 - right button pressed
;	2 - up button pressed
;	4 - down button pressed
;	8 - left button pressed
;	16- select button pressed
;
; this function uses registers:
;	r24
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
check_button:
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:		lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL
		lds r17, ADCH

		; put your new logic here:
		clr r24
		
		; check right button
		; ADH == 0x00 and ACD low < 0x32
		cpi r17, 0x00
		brne UP
		cpi r16, 0x32
		brlo right_pressed


		; check up button

UP:		cpi r17, 0x00
		brne DOWN
		cpi r16, 0xC3
		brlo up_pressed

		; check down button
DOWN:	cpi r17, 0x01
		brne LEFT
		cpi r16, 0x7C
		brlo down_pressed

		; check left button
LEFT:	cpi r17, 0x01
		brne SELECT
		cpi r16, 0xFF
		brlo left_pressed

		; check select button
SELECT:	cpi r17, 0x02
		brne none_pressed
		cpi r16, 0xFF
		brlo select_pressed

		; If you get here no buttons were pressed
		rjmp none_pressed


right_pressed:	ldi r24, 1
				rjmp skip
				
up_pressed:		ldi r24, 2
				rjmp skip

down_pressed:	ldi r24, 4
				rjmp skip

left_pressed:	ldi r24, 8
				rjmp skip

select_pressed:	ldi r24, 16
				rjmp skip

none_pressed:	ldi r24, 0
				rjmp skip

skip:			ret

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
; display the value in r0 on the 6 bit LED strip
;
; registers used:
;	r0 - value to display
;
display:
		; copy your code from a2q2.asm here
		ldi r25, 0			; Eventually written to PORTL
		ldi r26, 0			; Eventually written to PORTB
		mov r27, r0
		; check least significant bit
		andi r27, 0b00000001
		brne or1
		jmp test2
or1:	ori r25, 0b10000000

test2:	mov r27, r0
		andi r27, 0b00000010
		brne or2
		jmp test3
or2:	ori r25, 0b00100000

test3:	mov r27, r0
		andi r27, 0b00000100
		brne or3
		jmp test4
or3:	ori r25, 0b00001000

test4:	mov r27, r0
		andi r27, 0b00001000
		brne or4
		jmp test5
or4:	ori r25, 0b00000010

test5:	mov r27, r0
		andi r27, 0b00010000
		brne or5
		jmp test6
or5:	ori r26, 0b00001000

test6:	mov r27, r0
		andi r27, 0b00100000
		brne or6
		jmp load
or6:	ori r26, 0b00000010

load:	sts PORTL, r25
		out PORTB, r26
		ret
