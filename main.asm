;
; Assignment1.asm
;
; Created: 2/3/2020 6:14:38 PM
; Author : Theethawat Savastham
;



; Replace with your application code
; Suppose that PortB as Input and PortD as Output
; In must out DDR as 0, Out pust out DDR with 1 (FF)
; .def use with register , .equ use with value

.INCLUDE "m328Pdef.inc"
.equ PIN_OUT = 0b11111111 ; 0xFF
.equ PIN_IN  = 0b00000000 ; 0x00
.def TEMP = r16
.def DATA = r17
.def INTERVAL_LOOP = r18
.equ INTERVAL_VAR = 100

.CSEG

.ORG 0x00
; Port Input and Output Setting
	ldi TEMP,PIN_IN 
	out DDRB,TEMP
	ldi TEMP,PIN_OUT 
	out DDRD,TEMP

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

start:
    ldi DATA,0x09
	ldi TEMP,0x00
	ldi ZL,low(TABLE_7SEG*2)
	ldi ZH,high(TABLE_7SEG*2)

display:
	add ZL,DATA
	adc ZH,TEMP 
	lpm ; Value will keep to R0

	com r0 ; One Complement
	out PORTD, r0 ; Value of R0 Show at PortB
	cpi DATA,0x0A
	brge start
	brlt increment_group
	rjmp start

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