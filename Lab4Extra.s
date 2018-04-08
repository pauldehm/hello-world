	AREA |.text|, CODE, READONLY 
	EXPORT __main
	ENTRY

__main
	LDR R2, =0x2009C054 ;LPC_GPIO2->FIOPIN address, see LPC1768 manual
	LDR R0, =0x2009C040 ;LPC_GPIO2->FIODIR address, see LPC1768 manual
	MOV R1, #0xFF
	STR R1, [R0]		;Set direction of all 8 pins to OUT
	MOV R5, #0x1
	MOV R6, #0 		;Flashing mode parameter
	MOV R3, #0x800
	MOV R8, #0xFF
	MOV R9, #0
	B main_loop

delay
	MOV R4, #0			; int R4;
delay_loop	
	ADD R4, R4, #1		; for(R4 = 0; R4 < R1; R4++);
	CMP R4, R1	
	BLT delay_loop
	MOV PC, LR 			;return
	
mode1					;LEDs flash left to right
	STR R5, [R2] 		;turn on LED - write 1 to FIOPIN
	LDR R1, =1000000
	BL delay			;delay(6000000)		
	STR R5, [R2]		;turn off LED - write 0 to FIOPIN
	BL delay
	LSL R5,R5,#1
	CMP R5, #0x100
	MOVEQ R5,#0x1
	B main_loop
	
mode2					; LEDs flash from right to left
	STR R5, [R2] 		;turn on LED - write 1 to FIOPIN
	LDR R1, =1000000
	BL delay			;delay(6000000)		
	STR R5, [R2]		;turn off LED - write 0 to FIOPIN
	BL delay
	LSR R5,R5,#1
	CMP R5, #0x0
	MOVEQ R5,#0x80
	B main_loop
	
mode3
	STR R5, [R2] 		;turn on LED - write 1 to FIOPIN
	LDR R1, =1000000
	BL delay			;delay(6000000)		
	STR R5, [R2]		;turn off LED - write 0 to FIOPIN
	BL delay
	CMP R9, #0
	BEQ mode3_set1
	B mode3_set2
mode3_set1
	CMP R5, #0x2
	MOVEQ R9, #1
	LSR R5,R5,#1
	B mode3_end
mode3_set2
	CMP R5, #0x40
	MOVEQ R9, #0
	LSL R5,R5,#1
mode3_end
	B main_loop
	
mode4
	MOV R8, #0xFF
	STR R8, [R2] 		;turn on LED - write 1 to FIOPIN
	LDR R1, =1000000
	BL delay			;delay(6000000)		
	MOV R8, #0x00
	STR R8, [R2]		;turn off LED - write 0 to FIOPIN
	BL delay
	B main_loop

main_loop
	LDR R7, [R2]
	AND R7, R7, R3
	CMP R7, #0x0
	ADDEQ R6, R6, #1
	CMP R6, #4
	MOVEQ R6, #0
	CMP R6,#0
	BEQ mode1
	CMP R6, #1
	BEQ mode2
	CMP R6, #2
	BEQ mode3
	CMP R6, #3
	BEQ mode4
	B main_loop
	ALIGN
	END