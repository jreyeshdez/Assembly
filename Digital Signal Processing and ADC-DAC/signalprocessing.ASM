COM	EQU	00H	
PA	EQU	01H
PB	EQU	02H
PC	EQU	03H
;Stack Declaration
	ORG 8F01H
	LXI SP,FEFFH
	LXI D,0000H
;System Initialization	
	MVI A,0DH 	;Setting Configuration Word
	OUT COM		;Writing on control port   
	LXI H,9000H	;Buffer initialization
;Checking 
START:
	MVI C,0AH	;Service Routine to check 
	CALL 1000H	;the switch bank
	MOV A,L		;Storage into L register
	CPI 00H		;Check to go to
	JZ RAMP		;sample the signal and storage data
	CPI 01H		;or show the re-built signal.
	JZ SIGNAL
	JMP START
;Building the ramp up
RAMP:	
	MVI C,11H		;calling the internal routine 
	MVI E,01110111B	;in order to show through the Primer-85´s led-display
	MVI D,5			;the desired letters by the desired led-display.
	CALL 1000H
	MVI E,11100101B
	MVI D,4
	CALL 1000H
	MVI E,10010011B
	MVI D,3
	CALL 1000H
	MVI E,00000100B
	MVI D,2
	CALL 1000H
	MVI E,11110011B
	MVI D,1
	CALL 1000H
	MVI E,01000101B
	MVI D,0
	CALL 1000H
	MVI C,00H
L1:					;creation of a loop that creates 
	MOV A,C			;a sawtooth wave as input signal.
	OUT PC			;when the maximum amplitude is reached, the SID signal will be active 
	RIM				;giving a logic level "1" when the checking is equal.
	ANI 80H			;will filter.
	JNZ STORING		;calling a routine that stores the last value that has been read.
	INR C			;in case of the the comparison fails, will increment the initial value,
	MOV A,C
	CPI 3FH			;until compare the sawtooth wave reaches the 5 voltios.
	JNZ L1
	JMP RAMP
;Storing data into circular buffer
STORING:
	MVI A,00H		;will put the C port to zero in order to the sawtooth wave goes down into zero.
	OUT PC			;will load into the circular buffer, whose direction comes pointing by the H-L register
	MOV M,C			;the datum that has been read in the comparasion.
	CALL SAMPLING	;will wait a sampling time in order to store the next datum.
	INR L			;will increment the circular buffer to avoid deleting the last datum.
	MOV A,L			;will compare if the circular buffer got to the end.
	CPI FFH			;will check if the switch bank has been modified
	JZ START		;either to show the signal or to store new data.
	JMP RAMP		
;Sampling Time Generation 
SAMPLING:
	LXI D,226H 
L2: DCX D
	MOV A,E
	ORA D
	JNZ L2
	NOP
	RET
;Signal Reproduction
SIGNAL:
	MVI L,00H		;will put the circular buffer at the beginning in order to get the first datum stored.
LIZ:				
	MOV A,M			;then will load the value into memory, whose direction is pointed by H-L register.
	INR L			;next, will increment the L register in order to get the next datum.
	OUT PC			;will show the first datum that has been read.
	CALL SAMPLING	;will wait a sampling time in order to get and show the next datum.
	MOV A,L			
	CPI FFH			;will check if the circular buffer has reached the end.
	MVI C,11H		;will call the intern routine that show through the led-displays, 
	MVI E,11010110B	;the desired letters by the  desired led-display.
	MVI D,5			
	CALL 1000H		
	MVI E,10010111B
	MVI D,4
	CALL 1000H
	MVI E,01010101B
	MVI D,3
	CALL 1000H
	MVI E,01110111B
	MVI D,2
	CALL 1000H
	MVI E,10000011B
	MVI D,1
	CALL 1000H
	MVI E,00000000B
	MVI D,0
	CALL 1000H
	JNZ LIZ			;while the end of the circular buffer is not reached 
	MVI C,0AH		;will not check if the the switch bank has been modified.
	CALL 1000H		;will be done with the corresponding internal routine 
	MOV A,L			;depending on the modification of the switch bank 
	CPI 00H			;will go to either show the signal or sample the signal again.
	JZ RAMP			
	JMP SIGNAL		
	END

	
	

	