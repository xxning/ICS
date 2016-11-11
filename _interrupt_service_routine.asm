.ORIG x2000
LD R3,count

Input   LDI R4,KBSR
	BRzp Input
	LDI R0,KBDR
L	LDI R5,DSR
	BRzp L
	STI R0,DDR       
	ADD R3,R3,#-1
	BRzp Input
	
RTI

KBSR  .FILL xFE00
KBDR  .FILL xFE02
DSR   .FILL xFE04
DDR   .FILL xFE06
count .FILL x000A

.END