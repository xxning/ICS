.ORIG x3000
LEA R0,Begin1
TRAP x22 ;������ʾ
LD R3,Des1 ;R3�����������ID

LD R1,LFn ;��س���ASCII�븺ֵ

InputID TRAP x20
	TRAP x21 ;���벢����
	ADD R2,R0,R1;
	BRz Initial
	STR R0,R3,#0
	ADD R3,R3,#1
	BRnzp InputID

Initial AND R5,R5,#0 ;R5������¼ID���
	BRnzp Compare
	
Compare LD R1,Start  
	LDR R1,R1,#0
Compare2 LD R3 Des1 ;R3��ʼΪID�����ַ
Compare1 LDR R0,R3,#0
	BRz Test1
	LDR R2,R1,#0
	BRz CompareNextID
Return	NOT R6,R2
	ADD R6,R0,R6
	ADD R6,R6,#1 ;R6<-R0-R2
	BRz CompareNext
	BRnzp CompareNextID

Test1 	LDR R2,R1,#0
	BRz Login
	BRnzp Return

CompareNext ADD R1,R1,#1
	    ADD R3,R3,#1
	    BRnzp Compare1

CompareNextID ADD R5,R5,#1
	      LD R1,Start
	      ADD R1,R5,R1
	      LDR R1,R1,#0
	      BRz FAIL ;ʧ��
	      BRnzp Compare2
	
Login   LEA R0,Begin2
	TRAP x22 ;����������ʾ
	LD R3,Des2 ;R3���������������
	LD R2,LFn
InputPW TRAP x20
	ADD R6,R0,R2;
	BRz Check
	STR R0,R3,#0
	ADD R3,R3,#1
	LD R0,Secret
	TRAP x21 ;���#��ʾ������һ������	
	BRnzp InputPW

Check	LD R7,Encrypt
	ADD R1,R1,#1
	LD R6,Des2
check	LDR R2,R1,#0
	BRz Test2
	LDR R3,R6,#0
	BRz FAIL
	ADD R0,R3,R7
	NOT R2,R2
	ADD R0,R0,R2
	ADD R0,R0,#1
	BRz Next
	BRnzp FAIL
	
Test2   LDR R3,R6,#0
	BRz SUCCESS
	BRnzp FAIL	 

Next	ADD R1,R1,#1
	ADD R6,R6,#1
 	BRnzp check

FAIL 	LD R0,LF
	TRAP x21
	LEA R0,Fail
	TRAP x22
	BRnzp STOP

SUCCESS LD R0,LF
	TRAP x21
	LD R0,Start
	ADD R0,R0,R5
	LDR R0,R0,#0
	TRAP x22
	LEA R0,Success
	TRAP x22
	BRnzp STOP

STOP  	HALT
	
Des1   .FILL x3500
Des2   .FILL x3600
Begin1 .STRINGZ "Login ID:"
Begin2 .STRINGZ "Password:"
Start  .FILL x4000
LFn    .FILL x-000A
LF     .FILL x000A
Secret .FILL x0023
Encrypt .FILL x-000C
Fail   .STRINGZ "Invalid UserID/Password. Your login failed."
Success .STRINGZ ", you have successfully logged in."
.END
