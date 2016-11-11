.ORIG x3000
LD R6 Stack_Pointer
LD R1 vector
LD R2 Entry
STR R2 R1,#0
	 
Set1  LD R2 A
      STI R2 KBSR
      BRnzp Output1

Set2  LD R2 A
      STI R2 KBSR
      BRnzp Output2

Output1 LD R2,COUNT
REP1	ADD R2,R2,#-1
	BRp REP1
	LEA R0 OUT1
	TRAP x22
	LD R0 NEWLINE
	TRAP x21
	BRnzp Set2

Output2 LD R2,COUNT
REP2	ADD R2,R2,#-1
	BRp REP2
	LEA R0 OUT2
	TRAP x22
	LD R0 NEWLINE
	TRAP x21
	BRnzp Set1


Stack_Pointer .FILL x3000
vector .FILL x180
Entry  .FILL x2000
KBSR   .FILL xFE00	
KBDR   .FILL xFE02 
DSR    .FILL xFE04	
DDR    .FILL xFE06
COUNT  .FILL x2500
A      .FILL x4000
NEWLINE .FILL x000A
OUT1   .STRINGZ  "ICS   ICS   ICS   ICS   ICS   ICS"
OUT2   .STRINGZ  "   ICS   ICS   ICS   ICS   ICS"

.END