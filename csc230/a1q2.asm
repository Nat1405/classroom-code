;
; CSc 230 Assignment 1 
; Question 2
;

; This program should calculate:
; R0 = R16 + R17
; if the sum of R16 and R17 is > 255 (ie. there was a carry)
; then R1 = 1, otherwise R1 = 0
;

;--*1 Do not change anything between here and the line starting with *--
.cseg
	ldi	r16, 0xF0
	ldi r17, 0x01
;*--1 Do not change anything above this line to the --*

;***
; Your code goes here:
;

		; initalize r0 to zero
		ldi r18, 0
		mov r0, r18
		add r0, r16
		add r0, r17
		; If carry flag not set, r1=0; else r1=1
		brcc else
		ldi r18, 1
		mov r1, r18
		rjmp done
else:	mov r1, r18
		rjmp done

;****
;--*2 Do not change anything between here and the line starting with *--
done:	rjmp done
;*--2 Do not change anything above this line to the --*


