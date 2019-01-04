
.cseg
.org 0x0000
		jmp setup

.org 0x0028
		jmp timer1_isr
    
.org 0x0050

setup:
	; initialize the Analog to Digital conversion
	ldi r16, 0x87
	sts ADCSRA, r16
	ldi r16, 0x40
	sts ADMUX, r16
	; Initialize the stack pointer
	ldi r16, high(0x21FF)
	out SPH, r16
	ldi r16, low(0x21FF)
	out SPL, r16
	; Initialize the timer
	call timer_init

	call lcd_init			; call lcd_init to Initialize the LCD
	call lcd_clr
	call init_strings		; copy the strings from program memory to data memory
	
	call init_line_ptrs		; set l1ptr and l2ptr to point to start of display strings
	call init_flags			; set scroll flag to one
	call init_scrollspeed	; set scrollspeed to 0x20


loop:
	; clear line1 and line2
	; copy up to 16 chars from l1ptr and l2ptr to line1 and line2
	call copy_chunks
	; display line1 and line2
	call display_strings
	; move the pointers forward (wrapping around when appropriate)
	call inc_pointers
	; delay
	call delay

	rjmp loop




done: jmp done


timer_init:
		push r16

		; reset timer counter to 0
		ldi r16, 0x00
		sts TCNT1H, r16 	; must WRITE high byte first 
		sts TCNT1L, r16		; low byte
		; timer mode
		
		sts TCCR1A, r16
		; prescale 
		; Our clock is 16 MHz, which is 16,000,000 per second
		;
		; scale values are the last 3 bits of TCCR1B:
		;
		; 000 - timer disabled
		; 001 - clock (no scaling)
		; 010 - clock / 8
		; 011 - clock / 64
		; 100 - clock / 256
		; 101 - clock / 1024
		; 110 - external pin Tx falling edge
		; 111 - external pin Tx rising edge

		ldi r16, 0b00000011	; clock / 64
		sts TCCR1B, r16

		; Write your code here: enable timer interrupts
		ldi r16, 0x01
		sts TIMSK1, r16
		sei
		pop r16
		ret

timer1_isr:
	; set flag to: 0 if UP pressed, 1 if DOWN pressed
	push r24
	push r16
	lds r16, SREG
	push r16
	push ZH
	push ZL

	; check what button is pressed; values returned in r24
	call check_button
	; Returns in r24:
	;	0 - no button pressed
	;	1 - right button pressed
	;	2 - up button pressed
	;	4 - down button pressed
	;	8 - left button pressed
	;	16- select button pressed
	
	; check for start and stop commands
	cpi r24, 2
	breq load_zero
	cpi r24, 4
	breq load_one

	; check for increase and decrease scroll speed commands
	cpi r24, 1			;right button pressed
	breq decrease_speed
	cpi r24, 16			;select button pressed
	breq increase_speed

	rjmp exit

load_zero:
	ldi ZH, high(flag)
	ldi ZL, low(flag)
	ldi r16, 0
	st Z, r16
	rjmp exit

load_one:
	ldi ZH, high(flag)
	ldi ZL, low(flag)
	ldi r16, 1
	st Z, r16
	rjmp exit

decrease_speed:
	ldi ZH, high(scrollspeed)
	ldi ZL, low(scrollspeed)
	ld r16, Z
	ldi r24, 0x05
	sub r16, r24
	st Z, r16
	rjmp exit

increase_speed:
	ldi ZH, high(scrollspeed)
	ldi ZL, low(scrollspeed)
	ld r16, Z
	ldi r24, 0x05
	add r16, r24
	st Z, r16
	rjmp exit

exit:
	pop ZL
	pop ZH
	pop r16
	sts SREG, r16
	pop r16
	pop r24
	reti


init_flags:
	; put 1 in flags
	push r16
	push ZH
	push ZL
	
	ldi ZH, high(flag)
	ldi ZL, low(flag)
	ldi r16, 1
	st Z, r16

	pop ZL
	pop ZH
	pop r16
	ret


init_scrollspeed:
	; put XX in scroll speed
	push r16
	push ZH
	push ZL
	
	ldi ZH, high(scrollspeed)
	ldi ZL, low(scrollspeed)
	ldi r16, 0x20
	st Z, r16

	pop ZL
	pop ZH
	pop r16
	ret


init_strings:
	push r16
	; copy strings from program memory to data memory
	ldi r16, high(msg1)		; this the destination
	push r16
	ldi r16, low(msg1)
	push r16
	ldi r16, high(msg1_p << 1) ; this is the source
	push r16
	ldi r16, low(msg1_p << 1)
	push r16
	call str_init			; copy from program to data
	pop r16					; remove the parameters from the stack
	pop r16
	pop r16
	pop r16

	ldi r16, high(msg2)
	push r16
	ldi r16, low(msg2)
	push r16
	ldi r16, high(msg2_p << 1)
	push r16
	ldi r16, low(msg2_p << 1)
	push r16
	call str_init
	pop r16
	pop r16
	pop r16
	pop r16

	pop r16
	ret

display_strings:

	; This subroutine sets the position the next
	; character will be output on the lcd
	;
	; The first parameter pushed on the stack is the Y position
	; 
	; The second parameter pushed on the stack is the X position
	; 
	; This call moves the cursor to the top left (ie. 0,0)

	push r16
	push ZH
	push ZL

	call lcd_clr

	ldi r16, 0x00
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display the value in l1ptr on the first line
	ldi r16, high(line1)
	push r16
	ldi r16, low(line1)
	push r16

	;ldi r16, high(msg1)
	;push r16
	;ldi r16, low(msg1)
	;push r16
	call lcd_puts
	pop r16
	pop r16

	; Now move the cursor to the second line (ie. 0,1)
	ldi r16, 0x01
	push r16
	ldi r16, 0x00
	push r16
	call lcd_gotoxy
	pop r16
	pop r16

	; Now display the value in l2ptr on the second line
	ldi r16, high(line2)
	push r16
	ldi r16, low(line2)
	push r16

	;ldi r16, high(msg1)
	;push r16
	;ldi r16, low(msg1)
	;push r16
	call lcd_puts
	pop r16
	pop r16

	pop ZL
	pop ZH
	pop r16
	ret

init_line_ptrs:
	; Initializes l1ptr and l2ptr to point to msg1 and msg2
	push r16
	push ZH
	push ZL
	; make Z point to l1ptr
	ldi ZH, high(l1ptr)
	ldi ZL, low(l1ptr)
	; Make l1ptr into a copy of msg1
	ldi r16, high(msg1)
	st Z+, r16
	ldi r16, low(msg1)
	st Z, r16

	; make Z point to l2ptr
	ldi ZH, high(l2ptr)
	ldi ZL, low(l2ptr)
	; Make l2ptr into a copy of msg2
	ldi r16, high(msg2)
	st Z+, r16
	ldi r16, low(msg2)
	st Z, r16

	pop ZL
	pop ZH
	pop r16
	ret

copy_chunks:
	; Copies 16 bits of msg1 starting at l1ptr and msg2 starting at l2ptr to line1 and line2
	push XH
	push XL
	push YH
	push YL
	push ZH
	push ZL
	push r16	; r16 = bytes counted
	push r17	; r17 = working register

	; Copy 16 bytes to line 1
	ldi r16, 16	; counter = 16

	; Use X to make Y point into msg1, by getting the pointer stored in l1ptr

	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	ld YH, X+
	ld YL, X

	; Wrap around 2; check if the value in l1ptr is 0. If so, set l1ptr to msg1[0]
	ld r17, Y
	tst r17
	breq wrap_l1ptr
	rjmp continue1

wrap_l1ptr:
	; set l1ptr to msg1 and set Y to point to same value
	; Set Y to point to msg1 and put Y in l1ptr using X
	ldi YH, high(msg1)
	ldi YL, low(msg1)
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	; put msg1 in l1ptr via X
	st X+, YH
	st X, YL
	rjmp continue1


continue1:
	; Make Z point to line1; this is easy because line1 is a static memory location
	ldi ZH, high(line1)
	ldi ZL, low(line1)

copy_loop1:
	; Copy 16 chars from msg1 to line1
	tst r16
	breq copy_null1
	ld r17, Y+
	; First wrap around; check if we got to end of msg1. If so, move Y to msg1[0].
	tst r17
	breq wrap_end1

	st Z+, r17
	dec r16
	rjmp copy_loop1

wrap_end1:
	ldi YH, high(msg1)
	ldi YL, low(msg1)
	rjmp copy_loop1

copy_null1:
	; Copy a null terminator over
	ldi r17, 0
	st Z, r17

	; Copy 16 bytes to line2
	ldi r16, 16	; counter = 16

	; Use X to make Y point into msg1, by getting the pointer stored in l1ptr

	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	ld YH, X+
	ld YL, X
	; Wrap around 2; check if the value in l1ptr is 0. If so, set l1ptr to msg1[0]
	ld r17, Y
	tst r17
	breq wrap_l2ptr
	rjmp continue2

wrap_l2ptr:
	; set l1ptr to msg1 and set Y to point to same value
	; Set Y to point to msg1 and put Y in l1ptr using X
	ldi YH, high(msg2)
	ldi YL, low(msg2)
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	; put msg2 in l2ptr via X
	st X+, YH
	st X, YL
	rjmp continue2


continue2:

	; Make Z point to line2; this is easy because line2 is a static memory location
	ldi ZH, high(line2)
	ldi ZL, low(line2)

copy_loop2:
	; Copy 16 chars from msg1 to line1
	tst r16
	breq copy_null2
	ld r17, Y+
	; First wrap around; check if we got to end of msg2. If so, move Y to msg2[0].
	tst r17
	breq wrap_end2
	st Z+, r17
	dec r16
	rjmp copy_loop2

wrap_end2:
	ldi YH, high(msg2)
	ldi YL, low(msg2)
	rjmp copy_loop2

copy_null2:
	; Copy a null terminator over
	ldi r17, 0
	st Z, r17

	pop r17
	pop r16
	pop ZL
	pop ZH
	pop YL
	pop YH
	pop XL
	pop XH
	ret


delay:
		push r17
		push r18
		push r19
		push ZH
		push ZL

		; get delay time from scrollspeed
		ldi ZH, high(scrollspeed)
		ldi ZL, low(scrollspeed)
		
		ld r17, Z
x1:		ldi r18, 0xFF
x2:		ldi r19, 0xFF
x3:		nop
		dec r19
		brne x3
		dec r18
		brne x2
		dec r17
		brne x1 
		
		pop ZL
		pop ZH
		pop r19
		pop r18
		pop r17	
	ret


inc_pointers:
	push XH
	push XL
	push ZH
	push ZL
	push r25
	push r24
	
	; Check if flag is 1. If it is, increment. If it isn't, do nothing.
	ldi ZH, high(flag)
	ldi ZL, low(flag)
	ld r24, Z
	andi r24, 1
	breq increment_flag_false


	; increment l1ptr
	; Make X point to l1ptr high
	ldi XH, high(l1ptr)
	ldi XL, low(l1ptr)
	; Make r25:r24 == l1ptr
	ld r25, X+
	ld r24, X
	; increment r25:r24
	adiw r24, 1
	; store r25:r24 back in l1ptr
	st X, r24
	st -X, r25

	; Make X point to l2ptr high
	ldi XH, high(l2ptr)
	ldi XL, low(l2ptr)
	; Make r25:r24 == l2ptr
	ld r25, X+
	ld r24, X
	; increment r25:r24
	adiw r24, 1
	; store r25:r24 back in l2ptr
	st X, r24
	st -X, r25

increment_flag_false:
	pop r24
	pop r25
	pop ZL
	pop ZH
	pop XL
	pop XH
	ret



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
;	r24, r16, r17
check_button:
		push r16
		push r17
		; start a2d
		lds	r16, ADCSRA	
		ori r16, 0x40
		sts	ADCSRA, r16

		; wait for it to complete
wait:		lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		; read the value
		lds r16, ADCL	; r16==ADCL
		lds r17, ADCH	; r17==ADCH

		; put your new logic here:
		clr r24
		
		; 4 possible values for high byte
		cpi r17, 0
		breq ZERO
		cpi r17, 1
		breq ONE
		cpi r17, 2
		breq TWO
		cpi r17, 3
		breq THREE

		; If you get here no buttons were pressed
		rjmp none_pressed

ZERO:
	; was either right or up
	cpi r16, 0x32
	brlo right_pressed
	cpi r16, 0xC3
	brlo up_pressed
	rjmp down_pressed

ONE:
	; was either down or left
	cpi r16, 0x7C
	brlo down_pressed
	rjmp left_pressed
	
TWO:
	; was either left or select
	cpi r16, 0x2B
	brlo left_pressed
	rjmp select_pressed

THREE:
	; was either select or none
	cpi r16, 0x16
	brlo select_pressed
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

skip:			pop r17
				pop r16
				ret

msg1_p:	.db "We are the Borg. Lower your shields and surrender your ships. We will add your biological and technological distinctiveness to our own. Your culture will adapt to service us. Resistance is futile. ", 0	
msg2_p: .db "<#ERROR#> --- <#ERROR#> --- <#ERROR#> --- <#ERROR#> --- ", 0

#define LCD_LIBONLY
.include "lcd.asm"

.dseg
; *****  !!!!WARNING!!!!  *****
; Do NOT put a .org directive here.  The
; LCD library does that for you.
; *****  !!!!WARNING!!!!  *****
;
; The program copies the strings from program memory
; into data memory.  These are the strings
; that are actually displayed on the lcd
;
msg1:	.byte 200
msg2:	.byte 200

; Strings to contain the 16 characters of each line to diplay on the lcd.
line1:	.byte 17
line2:	.byte 17

; These keep track of where in the string each line currently is
l1ptr:	.byte 2
l2ptr:	.byte 2

; Flag (8 bits) to track things like if button was pressed
flag:	.byte 1

; Scroll Speed to change length of delay loop with button presses
scrollspeed: .byte 1
