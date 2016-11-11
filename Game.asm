;***********************************************************
; Dots and Boxes
; EE 306 Fall 2004
; Lab 5
; Starter Code
;***********************************************************

                    .ORIG   x3000

;***********************************************************
; Main Program
;***********************************************************
                    JSR   DISPLAY_BOARD
PROMPT              JSR   DISPLAY_PROMPT
                    TRAP  x20                        ; get a character from keyboard into R0
                    TRAP  x21                        ; echo it to the screen
                    LD    R3, ASCII_Q_COMPLEMENT     ; load the 2's complement of ASCII 'Q'
                    ADD   R3, R0, R3                 ; compare the first character with 'Q'
                    BRz   EXIT                       ; if input was 'Q', exit
                    ADD   R1, R0, #0                 ; move R0 into R1, freeing R0 for another TRAP
                    TRAP  x20                        ; get another character into R0
                    TRAP  x21                        ; echo it to the screen
                    JSR   IS_INPUT_VALID      
                    JSR   TRANSLATE_MOVE             ; translate move into {0..6} coordinates
                    ADD   R3, R3, #0                 ; R3 will be zero if the move was valid
                    BRz   VALID_MOVE
                    LEA   R0, INVALID_MOVE_STRING    ; if the move was invalid, output corresponding
                    TRAP  x22                        ; message and go back to prompt
                    BR    PROMPT 
VALID_MOVE          JSR   IS_OCCUPIED         
                    ADD   R3, R3, #0                 ; R3 will be zero if the space was unoccupied
                    BRz   UNOCCUPIED
                    LEA   R0, OCCUPIED_STRING        ; if the place was occupied, output corresponding
                    TRAP  x22                        ; message and go back to prompt
                    BR    PROMPT
UNOCCUPIED          JSR   APPLY_MOVE                 ; apply the move 
                    JSR   BOXES_COMPLETED            ; returns the number of boxes completed by this move in R3
                    ADD   R0, R3, #0                 ; move the number of completed boxes to R0 where UPDATE_STATE expects it
                    JSR   UPDATE_STATE               ; change the score and the player as needed

                    JSR   DISPLAY_BOARD
                    JSR   IS_GAME_OVER      
                    ADD   R3, R3, #0                 ; R3 will be zero if there was a winner
                    BRnp  PROMPT                     ; otherwise, loop back
EXIT                LEA   R0, GOODBYE_STRING
                    TRAP  x22                        ; output a goodbye message
                    TRAP  x25                        ; halt

ASCII_Q_COMPLEMENT  .FILL  xFFAF                      ; two's complement of ASCII code for 'Q'
INVALID_MOVE_STRING .STRINGZ "\nInvalid move. Please try again.\n"
OCCUPIED_STRING     .STRINGZ "\nThis position is already occupied. Please try again.\n"
GOODBYE_STRING      .STRINGZ "\nThanks for playing! Goodbye!\n"

;***********************************************************
; DISPLAY_BOARD
;   Displays the game board and the score
;***********************************************************

DISPLAY_BOARD       ST    R0, DB_R0                  ; save registers
                    ST    R1, DB_R1
                    ST    R2, DB_R2
                    ST    R3, DB_R3
                    ST    R7, DB_R7

                    AND   R1, R1, #0                 ; R1 will be loop counter
                    ADD   R1, R1, #6
                    LEA   R2, ROW0                   ; R2 will be pointer to row
                    LEA   R3, ZERO                   ; R3 will be pointer to row number
                    LD    R0, ASCII_NEWLINE
                    OUT
                    OUT
                    LEA   R0, COL
                    PUTS
                    LD    R0, ASCII_NEWLINE
                    OUT
DB_ROWOUT           ADD   R0, R3, #0                 ; move address of row number to R0
                    PUTS
                    ADD   R0, R2, #0                 ; move address of row to R0
                    PUTS
                    LD    R0, ASCII_NEWLINE
                    OUT
                    ADD   R2, R2, #8                 ; increment R2 to point to next row
                    ADD   R3, R3, #3                 ; increment R3 to point to next row number
                    ADD   R1, R1, #-1
                    BRzp  DB_ROWOUT
                    JSR   DISPLAY_SCORE

                    LD    R0, DB_R0                  ; restore registers
                    LD    R1, DB_R1
                    LD    R2, DB_R2
                    LD    R3, DB_R3
                    LD    R7, DB_R7
                    RET

DB_R0               .BLKW #1
DB_R1               .BLKW #1
DB_R2               .BLKW #1
DB_R3               .BLKW #1
DB_R7               .BLKW #1

;***********************************************************
; DISPLAY_SCORE
;***********************************************************

DISPLAY_SCORE       ST    R0, DS_R0                   ; save registers
                    ST    R7, DS_R7

                    LEA   R0, DS_BEGIN_STRING
                    TRAP  x22                         ; print out the first part of the score string
                    LD    R0, SCORE_PLAYER_ONE
                    LD    R7, ASCII_OFFSET
                    ADD   R0, R0, R7                  ; create the ASCII for first player's score
                    TRAP  x21                         ; output it
                    LEA   R0, DS_OTHER_STRING
                    TRAP  x22                         ; print out the second part of the score string
                    LD    R0, SCORE_PLAYER_TWO
                    LD    R7, ASCII_OFFSET
                    ADD   R0, R0, R7                  ; create the ASCII for second player's score
                    TRAP  x21                         ; output it
                    LD    R0, ASCII_NEWLINE
                    TRAP  x21

                    LD    R0, DS_R0                   ; restore registers
                    LD    R7, DS_R7
                    RET

DS_R0              .BLKW   #1
DS_R7              .BLKW   #1
DS_BEGIN_STRING    .STRINGZ "SCORE Player 1: "
DS_OTHER_STRING    .STRINGZ " Player 2: "




;***********************************************************
; IS_BOX_COMPLETE
; Input      R1   the column number of the square center (0-6)
;      R0   the row number of the square center (0-6)
; Returns   R3   zero if the square is complete; -1 if not complete
;***********************************************************

IS_BOX_COMPLETE     ST    R0, IBC_R0                  ; save registers
                    ST    R1, IBC_R1         
                    ST    R2, IBC_R2         
                    ST    R4, IBC_R4         
                    ST    R7, IBC_R7

                    ADD   R0, R0, #-1                 ; check the top pipe
                    JSR   BOUNDS_CHECK
                    ADD   R3, R3, #0
                    BRnp  IBC_NON_COMPLETE
                    JSR   IS_OCCUPIED
                    ADD   R3, R3, #0
                    BRz   IBC_NON_COMPLETE

                    ADD   R0, R0, #2                  ; check the bottom pipe
                    JSR   BOUNDS_CHECK
                    ADD   R3, R3, #0
                    BRnp  IBC_NON_COMPLETE
                    JSR   IS_OCCUPIED
                    ADD   R3, R3, #0
                    BRz   IBC_NON_COMPLETE

                    ADD   R0, R0, #-1                 ; check the left pipe
                    ADD   R1, R1, #-1
                    JSR   BOUNDS_CHECK
                    ADD   R3, R3, #0
                    BRnp  IBC_NON_COMPLETE
                    JSR   IS_OCCUPIED
                    ADD   R3, R3, #0
                    BRz   IBC_NON_COMPLETE

                    ADD   R1, R1, #2                  ; check the right pipe
                    JSR   BOUNDS_CHECK
                    ADD   R3, R3, #0
                    BRnp  IBC_NON_COMPLETE
                    JSR   IS_OCCUPIED
                    ADD   R3, R3, #0
                    BRz   IBC_NON_COMPLETE

                    ADD   R1, R1, #-1                 ; back to original square

                    AND   R3, R3, #0
                    BR    IBC_EXIT

IBC_NON_COMPLETE    AND   R3, R3, #0
                    ADD   R3, R3, #-1   

IBC_EXIT            LD    R0, IBC_R0                  ; restore registers
                    LD    R1, IBC_R1         
                    LD    R2, IBC_R2         
                    LD    R4, IBC_R4         
                    LD    R7, IBC_R7
                    RET

IBC_R0             .BLKW  #1
IBC_R1             .BLKW  #1
IBC_R2             .BLKW  #1
IBC_R4             .BLKW  #1
IBC_R7             .BLKW  #1


;***********************************************************
; BOXES_COMPLETED 
; Input   R1   the column number (0-6)
;      R0   the row number (0-6)
; Returns
;       R3  the number of boxes this move completed
;***********************************************************

BOXES_COMPLETED    ST    R7, BC1_R7                 ; save registers
                   ST    R4, BC1_R4

                   JSR   GET_ADDRESS                ; get address in game board structure where line will be drawn
                   AND   R4,R1,#1
                   BRz   BC1_VERTICAL               ; true if the line drawn was vertical   

                   AND   R4, R4, #0                 ; R4 will hold the number of boxes completed
                   ADD   R0, R0, #-1                ; is the top square complete?
                   JSR   IS_BOX_COMPLETE
                   ADD   R3, R3, #0                 ; R3 will be zero if square is complete
                   BRnp  BC1_SKIP1
                   ADD   R4, R4, #1                 ; we have one complete
                   JSR   FILL_BOX
BC1_SKIP1          ADD   R0, R0, #2                 ; is the bottom square complete?
                   JSR   IS_BOX_COMPLETE
                   ADD   R3, R3, #0                 ; R3 will be zero if square is complete
                   BRnp  BC1_SKIP2
                   ADD   R4, R4, #1
                   JSR   FILL_BOX
BC1_SKIP2          ADD   R0, R0, #-1                ; restore R0
                   BRnzp BC1_EXIT

BC1_VERTICAL       AND   R4, R4, #0
                   ADD   R1, R1, #-1                ; is left square complete?
                   JSR   IS_BOX_COMPLETE
                   ADD   R3, R3, #0                 ; R3 will be zero if square is complete
                   BRnp  BC1_SKIP3
                   ADD   R4, R4, #1
                   JSR   FILL_BOX
BC1_SKIP3          ADD   R1, R1, #2                 ; is right square complete?
                   JSR   IS_BOX_COMPLETE
                   ADD   R3, R3, #0                 ; R3 will be zero if square is complete
                   BRnp  BC1_SKIP4
                   ADD   R4, R4, #1
                   JSR   FILL_BOX
BC1_SKIP4          ADD   R1, R1, #-1                ; restore R1

BC1_EXIT           ADD   R3, R4, #0                 ; move the number of completed squares to R3
                   LD    R7,BC1_R7                  ; restore registers
                   LD    R4,BC1_R4
                   RET

BC1_R7             .BLKW #1
BC1_R4             .BLKW #1

;***********************************************************
; BOUNDS_CHECK
; Input       R1    numeric column
;      R0    numeric row (either may be invalid)
; Returns   R3   zero if valid; -1 if invalid
;***********************************************************
 
BOUNDS_CHECK       ADD   R1, R1, #0                 ; Column Check
                   BRn   BC_HUGE_ERROR    
                   ADD   R3, R1, #-6
                   BRp   BC_HUGE_ERROR 
  
                   ADD   R0, R0, #0                 ; Row check
                   BRn   BC_HUGE_ERROR 
                   ADD   R3, R0, #-6
                   BRp   BC_HUGE_ERROR 

                   AND   R3, R3, #0                 ; valid move, return 0
                   BR    BC_DONE
BC_HUGE_ERROR      AND   R3, R3, #0
                   ADD   R3, R3, #-1                ; invalid move, return -1   

BC_DONE            RET

BC_NEGA            .FILL #-65
BC_NEGZERO         .FILL #-48

;***********************************************************
; Global constants used in program
;***********************************************************

COL                .STRINGZ "  ABCDEFG"
ZERO               .STRINGZ "0 "
ONE                .STRINGZ "1 "
TWO                .STRINGZ "2 "
THREE              .STRINGZ "3 "
FOUR               .STRINGZ "4 "
FIVE               .STRINGZ "5 "
SIX                .STRINGZ "6 "
ASCII_OFFSET       .FILL   x0030
ASCII_NEWLINE      .FILL   x000A

;***********************************************************
; This is the data structure for the game board
;***********************************************************
ROW0               .STRINGZ "* * * *"
ROW1               .STRINGZ "       "
ROW2               .STRINGZ "* * * *"
ROW3               .STRINGZ "       "
ROW4               .STRINGZ "* * * *"
ROW5               .STRINGZ "       "
ROW6               .STRINGZ "* * * *"
;***********************************************************
; this data stores the state for who's turn it is and what the score is
;***********************************************************
CURRENT_PLAYER     .FILL   #1 ; initially player 1 goes
SCORE_PLAYER_ONE   .FILL   #0
SCORE_PLAYER_TWO   .FILL   #0

;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
; The code above is provided for you. 
; DO NOT MODIFY THE CODE ABOVE THIS LINE.
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************


;***********************************************************
; IS_GAME_OVER
; Checks to see if there is a winner. If so, outputs winner
; Returns   R3   zero if there was a winner; -1 if no winner yet
;***********************************************************
  
IS_GAME_OVER       ST R0,Da_i_R0      ;保存寄存器的值
		   ST R2,Da_i_R2 
		   ST R4,Da_i_R4
		   ST R7,Da_i_R7     

                   LD  R2,SCORE_PLAYER_ONE
	           LD  R4,SCORE_PLAYER_TWO
	           ADD R2,R2,R4
	           ADD R2,R2,#-9
	           BRz Over          ;将两个玩家分数之和与9比较来判断是否结束
		   BR  Continue      

Over   	           LD  R2,SCORE_PLAYER_ONE  ;若结束则判断出胜者
	           LD  R4,SCORE_PLAYER_TWO
		   NOT R4,R4
	           ADD R2,R2,R4
	           ADD R2,R2,#1
	           BRp Win_P1
		   BR  Win_P2

Win_P1             LEA R0,tag1    ;输出提示
	           TRAP x22
	           BR  done

Win_P2             LEA R0,tag2    ;输出提示
	    	   TRAP x22

done		   AND R3,R3,#0      ;R3为0表示已结束
		   BR  done_ifover

Continue           AND R3,R3,#0    ;R3为1表示未结束
	           ADD R3,R3,#-1


done_ifover        LD R0,Da_i_R0   ;还原寄存器的值
		   LD R2,Da_i_R2  
		   LD R4,Da_i_R4 
	   	   LD R7,Da_i_R7

		   RET 
            
Da_i_R0    .BLKW  #1       ; .FILLS and other data for IS_GAME_OVER goes here
Da_i_R2    .BLKW  #1       
Da_i_R4    .BLKW  #1 
Da_i_R7    .BLKW  #1 
tag1       .STRINGZ  "Game over. Player 1 is the winner!"
tag2       .STRINGZ  "Game over. Player 2 is the winner!"

;***********************************************************
;Locate_ROW0 
;this subroutine is used to locate the address of ROW0,since 
;the 9 bit signed PC offset can't reach
;***********************************************************
Locate_ROW0        LEA  R4,ROW0
                   RET
;***********************************************************
;Locate_CurPlayer
;this subroutine is used to locate the address of CURRENT_PLAYER,since 
;the 9 bit signed PC offset can't reach 
;***********************************************************
Locate_CurPlayer   LEA  R2,CURRENT_PLAYER
		   RET
;***********************************************************
; DISPLAY_PROMPT
; Prompts the player, specified by location CURRENT_PLAYER, to input a move
;***********************************************************

DISPLAY_PROMPT     ST R0,Da_a_R0             ;保存寄存器的值
		   ST R1,Da_a_R1
		   ST R7,Da_a_R7

		   LD  R1,CURRENT_PLAYER
		   ADD R1,R1,#-1              ;判断当前玩家
		   BRz Prompt_play1
		   BR  Prompt_play2

Prompt_play1       LEA R0,Prompt_PLAY1     ;输出提示
		   TRAP x22
	           BR  Done_Prompt

Prompt_play2	   LEA R0,Prompt_PLAY2     ;输出提示
	      	   TRAP x22
	  	   BR  Done_Prompt

Done_Prompt        LD R0,Da_a_R0        ;还原寄存器的值
		   LD R1,Da_a_R1
		   LD R7,Da_a_R7
		   
		   RET	

Da_a_R0       .BLKW #1
Da_a_R1       .BLKW #1    
Da_a_R7       .BLKW #1  
Prompt_PLAY1  .STRINGZ   "Player 1, input a move <column><row> (or 'Q' to quit):"    ; .FILLS and other data for DISPLAY_PROMPT goes here
Prompt_PLAY2  .STRINGZ   "Player 2, input a move <column><row> (or 'Q' to quit):"    ;

;***********************************************************
; UPDATE_STATE
; Input      R0  number of boxes completed this turn
;   this function updates the score, and decides which player should go next 
;***********************************************************

UPDATE_STATE       ST R2,Da_h_R2          ;保存寄存器的值
		   ST R4,Da_h_R4
		   ST R7,Da_h_R7

                   LD  R2,CURRENT_PLAYER
	           ADD R2,R2,#-1             ;判断当前玩家
		   BRz Update_P1
		   BR  Update_P2

Update_P1          LEA R4,SCORE_PLAYER_ONE
	           LD  R2,SCORE_PLAYER_ONE
	           ADD R2,R2,R3            ;更新分数
	           STR R2,R4,#0
	           BR  Next

Update_P2          LEA R4,SCORE_PLAYER_TWO
		   LD  R2,SCORE_PLAYER_TWO
	           ADD R2,R2,R3
	           STR R2,R4,#0             ;更新分数

Next               ADD R2,R0,#0             ;判断是否要交换
	           BRz Player_change
	           BR  done_update

Player_change      JSR Locate_CurPlayer   ;return the address of CCURRENT_PLAYER to R2
	           ADD R4,R2,#0
		   LDR R2,R2,#0
		   ADD R2,R2,#-1
	           BRz Change_to2
	           BR  Change_to1

Change_to2         ADD R2,R2,#2           ;玩家由1变为2
		   STR R2,R4,#0
	           BR  done_update

Change_to1         STR R2,R4,#0           ;玩家由2变为1

done_update        LD  R2,Da_h_R2         ;还原寄存器的值
	           LD  R4,Da_h_R4
		   LD  R7,Da_h_R7

                   RET 
            
Da_h_R2    .BLKW  #1     ; .FILLS and other data for UPDATE_STATE goes here
Da_h_R4    .BLKW  #1 
Da_h_R7    .BLKW  #1

;***********************************************************
; GET_ADDRESS
; Input      R1   the column number (0-6)
;      R0   the row number (0-6)
; Returns   R3   the corresponding address in the data structure
;***********************************************************

GET_ADDRESS        ST R2,Da_e_R2    
		   ST R4,Da_e_R4
	           ST R7,Da_e_R7

     	           AND R3,R3,#0
	           ADD R2,R0,#0
	           BRz Add_column	    
Add_row		   ADD R3,R3,#8      ;行的计算
	           ADD R2,R2,#-1  
	           BRz Add_column
	           BR  Add_row	

Add_column	   ADD R3,R3,R1      ;列的计算
              
		   JSR Locate_ROW0 
	           ADD R3,R3,R4      ;前面算出的R3值加上ROW0的地址即为所得地址
	
		   LD  R2,Da_e_R2    ;还原寄存器的值
	           LD  R4,Da_e_R4
		   LD  R7,Da_e_R7
			
         	   RET 
            
Da_e_R2    .BLKW  #1      ; .FILLS and other data for GET_ADDRESS goes here
Da_e_R4    .BLKW  #1
Da_e_R7    .BLKW  #1

;***********************************************************
; FILL_BOX
; Input      R1   the column number of the square center (0-6)
;      R0   the row number of the square center (0-6)
;   fills in the box with the current player's number
;***********************************************************

FILL_BOX           ST R2,Da_g_R2      ;保存寄存器的值
	           ST R3,Da_g_R3
		   ST R7,Da_g_R7
                 
	           JSR GET_ADDRESS

		   JSR Locate_CurPlayer
	           LDR R2,R2,#0
		   ADD R7,R2,#0
	           AND R7,R7,#1       ;判断当前玩家
	           BRz Fill_P2
	           BR  Fill_P1

Fill_P1            LD  R2,Zero       ;填入1
		   ADD R2,R2,#1
		   STR R2,R3,#0
		   BR  done_fill

Fill_P2            LD  R2,Zero	     ;填入2
		   ADD R2,R2,#2
		   STR R2,R3,#0
	             		
done_fill          LD  R2,Da_g_R2    ;还原寄存器的值
		   LD  R3,Da_g_R3
		   LD  R7,Da_g_R7

                   RET 
            
Da_g_R2       .BLKW  #1     ; .FILLS and other data for FILL_BOX goes here
Da_g_R3       .BLKW  #1
Da_g_R7       .BLKW  #1
Zero          .FILL  x30

;***********************************************************
; APPLY_MOVE (write - or | in appropriate place)
; Input      R1   the column number (0-6)
;      R0   the row number (0-6)
;***********************************************************

APPLY_MOVE   	   ST R2,Da_f_R2     ;保存寄存器的值
		   ST R4,Da_f_R4
		   ST R7,Da_f_R7

		   JSR GET_ADDRESS
            	   AND R4,R0,#1
	           BRz Input_hyphen   ;判断应该是“|”还是“—”
	           BR  Input_pipe

Input_hyphen       LD  R2,ASCII_hyphen    
		   STR R2,R3,#0
	           BR  Done_move

Input_pipe	   LD  R2,ASCII_pipe   
		   STR R2,R3,#0

Done_move          LD  R2,Da_f_R2      ;还原寄存器的值
                   LD  R4,Da_f_R4 
		   LD  R7,Da_f_R7
  		   
                   RET 
            
Da_f_R2        .BLKW  #1       ; .FILLS and other data for APPLY_MOVE goes here
Da_f_R4        .BLKW  #1 
Da_f_R7        .BLKW  #1 
ASCII_hyphen   .FILL  x002D
ASCII_pipe     .FILL  x007C

;***********************************************************
; IS_OCCUPIED
; Input      R1   the column number (0-6)
;      R0   the row number (0-6)
; Returns   R3   zero if the place is unoccupied; -1 if occupied
;***********************************************************

IS_OCCUPIED        ST R2,Da_d_R2       ;保存寄存器的值
		   ST R4,Da_d_R4
		   ST R7,Da_d_R7

     	           JSR GET_ADDRESS
                 
	           LDR R2,R3,#0
	           LD  R3,ASCII_Space	 ;通过判断对应内存地址存放的字符是不是空格来判断          
		   ADD R2,R2,R3          ;是否该步骤已被占用
		   BRz Unoccupied
	           BR  Occupied

Unoccupied         AND R3,R3,#0          ;未被占用时R3返回0
	           BR Done_Ifoccupied

Occupied           AND R3,R3,#0          ;被占用时R3返回1
		   ADD R3,R3,#-1
                   
Done_Ifoccupied    LD R2,Da_d_R2  	;还原寄存器的值 	                
  		   LD R4,Da_d_R4 
		   LD R7,Da_d_R7

                   RET 
            
Da_d_R2      .BLKW  #1     ; .FILLS and other data for IS_OCCUPIED goes here
Da_d_R4      .BLKW  #1    
Da_d_R7      .BLKW  #1 
ASCII_Space  .FILL  x-0020

;***********************************************************
; TRANSLATE_MOVE
; Input      R1   the ASCII code for the column ('A'-'G')
;      R0   the ASCII code for the row ('0'-'6')
; Returns   R1   the column number (0-6)
;      R0   the row number (0-6)
;***********************************************************

TRANSLATE_MOVE     ST R2,Da_c_R2
		
 		   LD R2,ASCII_0    ;R0减去0的ASCII码，R1减去A的ASCII码即
	           ADD R0,R0,R2     ;得对应坐标
	           LD R2,ASCII_A
	           ADD R1,R1,R2	

 		   LD R2,Da_c_R2
	           RET

Da_c_R2        .BLKW  #1  ; .FILLS and other data for IS_INPUT_VALID goes here

;***********************************************************
; IS_INPUT_VALID
; Input      R1  ASCII character for column
;       R0  ASCII character for row 
; Returns   R3  zero if valid; -1 if invalid
;***********************************************************

IS_INPUT_VALID     ST R0,Da_b_R0      ;保存寄存器的值
		   ST R1,Da_b_R1
		   ST R2,Da_b_R2
		   ST R7,Da_b_R7

		   LD R2,ASCII_0
		   ADD R2,R2,R0
	           BRn Invalid

Check_range1       LD R2,ASCII_6      ;Check_range1-3用来判断输入是否在范围内
		   ADD R2,R2,R0	      ;若在，则进行进一步判断，否则返回无效
	           BRp Invalid
         
Check_range2	   LD R2,ASCII_A
		   ADD R2,R2,R1
	           BRn Invalid

Check_range3	   LD  R2,ASCII_G
		   ADD R2,R2,R1
	           BRp Invalid
	           
Check_site1        LD  R2,ASCII_0     ;用来判断输入对应的位置是否是字符“*”	
		   ADD R0,R0,R2	      ;若是，则返回无效，否则进行进一步判断
		   LD  R2,ASCII_A		
		   ADD R1,R1,R2
	           JSR GET_ADDRESS
	           LDR R2,R3,#0;
	           LD  R3,ASCII_asterisk
	           ADD R2,R2,R3
	           BRz Invalid
	           
Check_site2        LD  R0,Da_b_R0     ;通过横纵坐标相加的奇偶来判断该步骤输入是
	           LD  R1,Da_b_R1     ;在边上还是在框内
	           ADD R2,R1,R0	      ;相加为奇数是无效的，相加为偶数是有效的
	           AND R2,R2,#1
	           BRz Valid

Invalid		   AND R3,R3,#0       ;无效时R3返回-1
	           ADD R3,R3,#-1
	           BR Done_Ifvalid  

Valid		   AND R3,R3,#0       ;有效时R3返回0
		   BR Done_Ifvalid

Done_Ifvalid       LD R2,Da_b_R2      ;还原寄存器的值 
		   LD R7,Da_b_R7

	           RET

Da_b_R0         .BLKW  #1     ; .FILLS and other data for IS_INPUT_VALID goes here
Da_b_R1         .BLKW  #1  
Da_b_R2         .BLKW  #1  
Da_b_R7         .BLKW  #1  
ASCII_0		.FILL  x-0030
ASCII_6		.FILL  x-0036
ASCII_A		.FILL  x-0041
ASCII_G		.FILL  x-0047
ASCII_asterisk  .FILL  x-002A

;***********************************************************           
.END


