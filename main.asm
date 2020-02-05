;
; Assignment1.asm
;
; Created: 2/3/2020 6:14:38 PM
; Author : Theethawat Savastham
;



; Replace with your application code
; Suppose that PortD as Input and PortC as Output
; In must out DDR as 0, Out pust out DDR with 1 (FF)
; .def use with register , .equ use with value

.INCLUDE "m328Pdef.inc"
.equ PIN_OUT = 0b11111111 ; 0xFF
.equ PIN_IN  = 0b00000000 ; 0x00
.equ KEYPAD_PIN = 0b11111000 ; bit 0,1,2 will be input another will be output
.equ INTERVAL_VAR = 100

.def TEMP = r16
.def DATA = r17
.def INTERVAL_LOOP = r18
.def DISTANCE = r19
.def READ_RESULT = r20


.macro BRANCH_IF_KEYPRESS
	ldi TEMP,0xFF
	cp  r0,TEMP ; Compare if Result (R0) is all 1 or not
	brne keypressed ; If not all one show that maybe somekey is pressed
.endmacro

.CSEG

.ORG 0x00
	rjmp start


TABLE_7SEG:
	;			hgfedcba     hgfedcba
	.db		   0b00111111,   0b00000110 ;0,1
	.db		   0b01011011,	 0b01001111 ;2,3
	.db		   0b01100110,   0b01101101 ;4,5
	.db		   0b01111101,	 0b01000111 ;6,7
	.db		   0b01111111,	 0b01101111 ;8,9
	.db		   0b01110111,	 0b01111100 ;A,B
	.db		   0b00111001,	 0b01011110 ;C,D
	.db		   0b01111001,	 0b00000000 ;E,F

TABLE_KEYPAD:
	.db		0x01,0xFF,0x02,0x03,0xFF,0x04,0xFF,0x05,0x06,0xFF
	.db		0x07,0xFF,0x08,0x09,0xFF,0x0A,0xFF,0x00,0x0B,0xFF

start:
; Port Input and Output Setting
	ldi TEMP,PIN_OUT 
	out DDRC,TEMP
	ldi TEMP,KEYPAD_PIN
	out DDRD,TEMP

    ldi DATA,0x00 ; Initial Data
	ldi TEMP,0x00
	rjmp keypad_read

keypad_read:
	;Load Row A (No press is 1)
	ldi TEMP,0b01110111 ; 3 first bit that's a input don't matter let 4th bit will 0
	ldi DISTANCE,0 
	call scan_keypad
	BRANCH_IF_KEYPRESS

	;Load Row B 
	ldi TEMP,0b01101111 ; 3 first bit that's a input don't matter let 5th bit will 0
	ldi DISTANCE,5 
	call scan_keypad
	BRANCH_IF_KEYPRESS

	;Load Row C
	ldi TEMP,0b01011111 ; 3 first bit that's a input don't matter let 6th bit will 0
	ldi DISTANCE,10 
	call scan_keypad
	BRANCH_IF_KEYPRESS

	;Load Row D
	ldi TEMP,0b00111111 ; 3 first bit that's a input don't matter let 7th bit will 0
	ldi DISTANCE,15 
	call scan_keypad
	BRANCH_IF_KEYPRESS

	rjmp keypad_read ; loop again

keypressed:
	call display_7seg ;Display IT
	rjmp keypad_read ; And loop of Read again

scan_keypad:
	ldi ZL,low(TABLE_KEYPAD*2)
	ldi ZH,high(TABLE_KEYPAD*2)
	out PORTD,TEMP ; Output the value of ROW to scan
	in  READ_RESULT,PIND ; Read the Result of Column at the same port/pin
	ldi TEMP,0b00000111  ; Filter use only 3 LSB
	and READ_RESULT,TEMP ; Filter Working
	add READ_RESULT,DISTANCE ; Add Distance 
	subi READ_RESULT,3 ; Subtract the ofset
	ldi TEMP,0x00 ; Clear and Prepare for adc
	add ZL,READ_RESULT ; the Result will follow Keypad table
	adc ZH,TEMP
	lpm ; So the Result will go to R0 and call macro
	mov DATA,r0 ; Let the R0 Value keep in variable Data
	ret


display_7seg:
	push ZL
	push ZH
	push r0  
	; keep the current value of variable to stack because we want to use them 
	; and it's value will be destroy

	rcall display
	pop r0
	pop ZH
	pop ZL
	ret

display:

	ldi ZL,low(TABLE_7SEG*2) ; Load Value of 7seg Table to Register
	ldi ZH,high(TABLE_7SEG*2)
	ldi TEMP, 0x0F ; Load 15 to Temp Variable
	and DATA,TEMP ; make sure value is not over than 15 	
	
	ldi TEMP,0x00 ;clear
	add ZL,DATA
	adc ZH,TEMP 
	
	lpm ; Value will keep to R0
	com r0 ; One Complement	
	;ldi TEMP,0xFF
	;out DDRC,TEMP
	out PORTC, r0 ; Value of R0 Show at PortB
	ret

	; Delay Method----------
increment_group:
	ldi INTERVAL_LOOP,INTERVAL_VAR
	inc DATA
	rcall delay10ms
	rjmp display
	
delay10ms:
	subi INTERVAL_LOOP,1
	cpi	INTERVAL_LOOP,0x00
	brne delay10ms
	rjmp increment_group

.DSEG ; data segment
.ESEG ; EEPROM segment