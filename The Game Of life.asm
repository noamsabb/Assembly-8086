; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Ex5q2.asm
; 27/6/2021
; SABBAN Noam  329897391
; ;Ori Lavi    316492685
; Description: GAME OF LIFE
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.model small
.data

tab1 db '0','1','2','3','4','5','6','7','8','9'
arr1 db "ST1 TIME:$"
arr2 db "[sec]$"
arr3 db "p - Pause$"
arr4 db "e - Exit$"
arr5 db "GAME$"
arr6 db "OF$"
arr7 db "LIFE!$"


x db 0h
tFlag dw 0h
oldColor dw 0h
startMin dw 0h
startSec dw 0h
startHour dw 0h
timeFlag dw 0h
counter dw 0h
SUM dw 0h
Old_int_off dw 0
Old_int_seg dw 0
gameStarted db 0
TimeChecked dw 0
pause dw 0

.stack 100h
.code

;------------------------------------------------------;  New int 8
ISR_NEW_Int8 proc near uses ax bx cx dx bp si ds es
pushf
CALL DWORD PTR [Old_int_off] 

cmp gameStarted, 0					;check if the game started, if not jump to the end
JZ sof

cmp pause, 0						;check if pause button is pressed, if yes jump to the end
JNZ sof

cmp di, 0							;check if di == 0 if yes it means 1 second past 
JNZ notYet

																													
mov di, 21	 						;set di back to 21 for next seconde												 	
																						 								
mov bx, 0h																			 									
mov si, 0h
	LL2:
		push bx
		push si	
			
		sub si, 2							;Neighbor 4
		cmp es:[bx+si],' '					;Check if neighbor is alive
		JNZ A1
		inc counter							;if yes inc counter of neighbors
		JMP next1
		A1:
		cmp es:[bx+si], 7720h				;Check if neighbor is alive (7720h mean is gonna get kill in next gen)
		JNZ next1
		inc counter	
		next1:								;Neighbor 1
		sub bx, 160d				
		cmp es:[bx+si],' '			
		JNZ A2						
		inc counter																				;X and his 8 neighbors 
		JMP next2																							; 1 2 3	
		A2:																									; 4 X 5		
		cmp es:[bx+si], 7720h																				; 6 7 8 
		JNZ next2
		inc counter
		next2:								;Neighbor 2
		add si, 2	
		cmp es:[bx+si],' '
		JNZ A3
		inc counter
		JMP next3
		A3:
		cmp es:[bx+si], 7720h
		JNZ next3
		inc counter
		next3:								;Neighbor 3
		add si, 2
		cmp es:[bx+si],' '
		JNZ A4
		inc counter
		JMP next4
		A4:
		cmp es:[bx+si], 7720h
		JNZ next4
		inc counter
		next4:								;Neighbor 5
		add bx, 160d
		cmp es:[bx+si],' '
		JNZ A5
		inc counter
		JMP next5
		A5:
		cmp es:[bx+si], 7720h
		JNZ next5
		inc counter
		next5:								;Neighbor 8
		add bx, 160d
		cmp es:[bx+si],' '
		JNZ A6
		inc counter
		JMP next6
		A6:
		cmp es:[bx+si], 7720h
		JNZ next6
		inc counter
		next6:								;Neighbor 7
		sub si, 2
		cmp es:[bx+si],' '
		JNZ A7
		inc counter
		JMP next7
		A7:
		cmp es:[bx+si], 7720h
		JNZ next7
		inc counter
		next7:								;Neighbor 6
		sub si, 2
		cmp es:[bx+si],' '	
		JNZ A8
		inc counter
		JMP check
		A8:
		cmp es:[bx+si], 7720h
		JNZ check
		inc counter

		check:		
		pop si 								;get bx and si back from stack to present position
		pop bx
		cmp es:[bx+si], ' '					;check if the point is dead or alive
		JNZ isDead

		isAlive:
		cmp counter, 2h						;if alive check if have 2 or 3 neighbors, if yes color stay the same move to next point
		JZ endLoop
		cmp counter, 3h
		JZ endLoop

		Kill:
		mov dh, 77h							;kill position (set to going to die Color)
		mov dl, 20h	
		mov es:[bx+si], dx	
		JMP endLoop

		isDead:								;if it was dead, check if 3 neighbors
		cmp counter, 3h
		JNZ endLoop							;if no, stay dead
		mov dh, 33h
		mov dl, 20h
		mov es:[bx+si], dx					;if yes, become alive (Set to going to live color)

		endLoop:
		mov counter, 0h						;go to next position on screen
		cmp si, 116d						;check borders
		JZ nextLigne
		add si, 2
		JMP LL2

		nextLigne:
		cmp bx, 3840d 						;check borders
		JZ nextGen
		mov si, 0h
		add bx, 160d
		JMP LL2
			

		nextGen:							;run over the entire game screen
			mov bx, 0h
			mov cx, 116d
		LL1:	
			cmp es:[bx], 7720h				;if color is 'going to die'
			JZ killIt
			cmp es:[bx], 3320h				;if color is 'going to live'
			JZ born
			JMP nextOne
	
			killIt:	
			mov es:[bx], 0F120h				;set to white
			JMP nextOne
			born:
			mov es:[bx], ' '				;set to black
	
			nextOne:
			cmp bx, cx						;check borders and go to next position
			JNZ nex
			add cx, 160d
			add bx, 42d
			nex:
			add bx, 2
			cmp bx, 3956d
			JNZ LL1 		
			
			JMP sof
notYet:										;while didn't past 1 sec, decrease di 
	dec di
			
sof:
	mov al, 20h
	out 20h, al

iret
ISR_NEW_Int8 endp

;-----------------------------------;

START:
	 						;setting data segment
mov ax, @data
mov ds, ax
mov ax, 0b800h
mov es, ax 
	
mov di, 20					;set di to 20 to count 1seconde
mov ax, 0h

push bx 
push es
							;keep the number of the old interuption 
cli
mov ah,35h
mov al,08
int 21h                
mov Old_int_seg,es
mov Old_int_off,bx  
pop es
pop bx
push ds   

							;moving ISR_NEW_Int8 into IVT[8]

mov ah,25h
mov al,08
mov dx , offset ISR_NEW_Int8
push cs
pop ds
int 21h
pop ds
sti
	

							;Set game part of screen to white 
MOV AX, 1003h       
MOV BL, 00
INT 10h
	
mov ah, 06h    
xor al,al     
xor cx, cx
mov dx, 183Bh  
mov bh, 0F1h    
INT 10h		

							;Set menu part of screen to red
mov ah, 06h    
xor al,al     
mov cx, 003Bh 
mov dx, 184Fh  
mov bh, 60h    
INT 10h		


								;Move pointer to right place
MOV DH, 1h     	
MOV DL, 3Ch    		
MOV AH,02h      
MOV BH,0        
INT 10h        
								;Print arr3 to screen
mov ah, 09h
mov dx, offset arr3
int 21h		

MOV DH, 3h     					;Move pointer to right place
MOV DL, 3Ch    		
MOV AH,02h      
MOV BH,0        
INT 10h        
								;Print arr4 to screen
mov ah, 09h
mov dx, offset arr4
int 21h		


MOV DH, 0Ah    					;Move pointer to right place 	
MOV DL, 43h    		
MOV AH,02h      
MOV BH,0        
INT 10h        
								;Print arr5 to screen
mov ah, 09h
mov dx, offset arr5
int 21h		


MOV DH, 0Bh     				;Move pointer to right place
MOV DL, 44h    		
MOV AH,02h      
MOV BH,0        
INT 10h        
								;Print arr6 to screen
mov ah, 09h
mov dx, offset arr6
int 21h		

MOV DH, 0Ch     				;Move pointer to right place
MOV DL, 43h    		
MOV AH,02h      
MOV BH,0        
INT 10h        
								;Print arr7 to screen
mov ah, 09h
mov dx, offset arr7
int 21h		

								;Move pointer back to his place (Down Left)
MOV DH, 24  ;ligne   
MOV DL, 0 ;colonne  
MOV AH,02h      
MOV BH,0        
INT 10h

mov dh, 0F1h 					;initialize 
mov dl, 20h
mov oldColor, dx

in al, 21h
or al, 02h
out 21h, al  


mov dl,20h 
mov dh,40h
mov bx, 1920d
mov si,58d                      ; Print red square middle screen 
mov es:[bx+si], dx


mov ax, 0
mov al, 00h           		    ; Get start time Seconds
out 70h,al 
in al,71h

mov ch, 10h
div ch
mov dh, ah						;Conversion to hexa
mov ah, 0
mov ch, 10d
mul ch
add al, dh


add startSec, ax

mov ax, 0
mov al, 02h           		    ; Get start time Minutes
out 70h,al 
in al,71h

mov ch, 10h
div ch
mov dh, ah						;Conversion to hexa
mov ah, 0
mov ch, 10d
mul ch
add al, dh

add startMin, ax

mov ax, 0
mov al, 04h           		    ; Get start time Minutes
out 70h,al 
in al,71h

mov ch, 10h
div ch
mov dh, ah						;Conversion to hexa
mov ah, 0
mov ch, 10d
mul ch
add al, dh

add startHour, ax


PollKeyboard:
IN AL, 64h
TEST AL, 01             		 ;Checking if we got a new letter
JZ PollKeyboard       			 ;if not, check again

IN AL, 60h             

cmp gameStarted, 0				;check if the game already started, if yes no action for wasd buttons
JNZ pauseGame
			  			
								
cmp al, 14h						;check if t was press
JNZ up
								;if yes
inc tFlag


;----------------------;
								
up:
cmp al, 11h              		;check if w was pressed
JNZ down


cmp bx, 0						;checking border
JZ PollKeyboard

mov cx, oldColor

sub bx, 160d	
mov dx, es:[bx+si]				;save color of this point for next move 
mov oldColor, dx
add bx, 160d

cmp tFlag, 0					;check if t was pressed
JZ noPress

cmp cx, ' '
JNZ diff						;if yes, check color

mov dh, 0F1h					;if black set to white
mov dl, 20h
mov es:[bx+si], dx   
JMP goUp

diff:
mov es:[bx+si], ' '				;if white set to black 
JMP goUp

noPress:						;if t wasn't pressed color stay the same (kept in oldColor)
mov es:[bx+si], cx 

goUp:			
mov tFlag, 0h				
sub bx, 160d
mov dl,20h 
mov dh,40h
mov es:[bx+si], dx				;move red square Up
JMP PollKeyboard 


;----------------------;  

down:
cmp al,01Fh               		  ;check if s was pressed
JNZ right


cmp bx, 3840d					  	;checking border
JZ PollKeyboard

mov cx, oldColor

add bx, 160d
mov dx, es:[bx+si]					;save color of this point for next move 
mov oldColor, dx
sub bx, 160d

cmp tFlag, 0						;check if t was pressed
JZ noPress2	

cmp cx, ' '
JNZ diff2							;if yes, check color


mov dh, 0F1h						;if black set to white
mov dl, 20h
mov es:[bx+si], dx   
JMP goDown

diff2:
mov es:[bx+si], ' '					;if white set to black 
JMP goDown

noPress2:							
mov es:[bx+si], cx 					;if t wasn't pressed color stay the same (kept in oldColor)

goDown:  							
mov tFlag, 0h    					
add bx, 160
mov dl,20h 
mov dh,40h
mov es:[bx+si],dx					;move red square Down

JMP PollKeyboard
 
 
;----------------------;

right:
cmp al,20h                         ;check if d pressed
JNZ left

cmp si, 116d					   ;checking border
JZ PollKeyboard

mov cx, oldColor

add si, 2 
mov dx, es:[bx+si]					;save color of this point for next move 
mov oldColor, dx
sub si, 2 

cmp tFlag, 0						;check if t was pressed
JZ noPress3

cmp cx, ' '
JNZ diff3							;if yes, check color

mov dh, 0F1h						;if black set to white
mov dl, 20h
mov es:[bx+si], dx   
JMP goRight

diff3:
mov es:[bx+si], ' '					;if white set to black 
JMP goRight

noPress3:							;if t wasn't pressed color stay the same (kept in oldColor)
mov es:[bx+si], cx 

goRight:							;move red square to the right
mov tFlag, 0h
add si, 2      
mov dl,20h 
mov dh,40h
mov es:[bx+si],dx

JMP PollKeyboard 
 
 
;----------------------; 

left:    
   
cmp al, 01Eh 				    	;check if a pressed
JNZ pauseGame

cmp si, 0d						    ;checking border
JZ PollKeyboard

mov cx, oldColor

sub si, 2							;save color of this point for next move 
mov dx, es:[bx+si]
mov oldColor, dx
add si, 2 

cmp tFlag, 0						;check if t was pressed
JZ noPress4

cmp cx, ' '							;if yes, check color
JNZ diff4

mov dh, 0F1h 						;if black set to white
mov dl, 20h
mov es:[bx+si], dx   
JMP goLeft

diff4:
mov es:[bx+si], ' '					;if white set to black 
JMP goLeft

noPress4:
mov es:[bx+si], cx 					;if t wasn't pressed color stay the same (kept in oldColor)		


goLeft:								;move red square to the left
mov tFlag, 0h
sub si, 2
mov dl,20h 
mov dh,40h
mov es:[bx+si],dx

JMP PollKeyboard 

pauseGame: 
	cmp al, 19h						;check if p pressed
	JNZ stop						;if not keep going
	xor pause, 1d					;if yes, flip pause (0 to 1 or 1 to 0)
	JMP PollKeyboard

stop:
cmp al, 39h				;if Press space anytime exit to Dosbox
JZ SOFF
	
cmp al, 12h				;if Press e 
JNZ PollKeyboard

cmp timeChecked, 0		;check if first time
JZ TimeCheck			;if yes JUMP to TimeCheck calculate time and start game
JMP SOFF				;if not JUMP to SOFF and exit the game
	

	

TimeCheck:
	mov TimeChecked, 1
							;Set red square to black or white depend if t pressed or not
	cmp tFlag, 0
	JNZ black
	white:
	mov es:[bx+si], 0F120h
	JMP time
	black:
	mov es:[bx+si], ' '	
	
							;Start Time Check
	time:
	push bx
	push si
	
	mov ax, 0
	mov al, 00h           		    ; Get start time Seconds
	out 70h,al 
	in al,71h
	
    mov ch, 10h
    div ch
    mov dh, ah						;Conversion to hexa
    mov ah, 0
    mov ch, 10d
    mul ch
    add al, dh


	cmp ax, startSec			
	JG endBigger
	add ax,60d
	inc timeFlag
	sub ax, startSec
	add SUM, ax
	JMP Minutes
	
	endBigger:
	mov timeFlag,0h
	sub ax, startSec
	add SUM, ax
	
	Minutes:
	mov ax, 0
	mov al, 02h           		    ; Get start time Minutes
	out 70h,al 
	in al,71h
	
    mov ch, 10h
    div ch
    mov dh, ah						;Conversion to hexa
    mov ah, 0
    mov ch, 10d
    mul ch
    add al, dh
	
	
	cmp timeFlag, 0h
	JZ flagoff
	
	
	flagon:
	cmp ax, 0
	JZ zero
	dec ax
	mov timeFlag, 0h
	
	flagoff:
	cmp ax, startMin
	JG endBigger2
	add ax,60d
	mov timeFlag, 1h
	sub ax, startMin
	mov dx, 60d
	mul dx
	add SUM, ax
	JMP Hour
	
	endBigger2:
	mov timeFlag,0h
	sub ax, startMin
	mov dx, 60d
	mul dx
	add SUM, ax
	JMP Hour
	
	zero:
	mov ax, 59d
	mov timeFlag, 1h
	sub ax, startMin
	mov dx, 60d
	mul dx
	add SUM, ax
	
	Hour:
		
	mov ax, 0
	mov al, 04h           		    ; Get start time Seconds
	out 70h,al 
	in al,71h
	
    mov ch, 10h
    div ch
    mov dh, ah						;Conversion to hexa
    mov ah, 0
    mov ch, 10d
    mul ch
    add al, dh
		
	cmp timeFlag, 0h
	JZ hourOff
		
	hourOn:
	dec ax
	mov timeFlag, 0h
	sub ax, startHour
	mov dx, 3600d
	mul dx
	add SUM, ax
	JMP printTime
		
	hourOff:
	sub ax, startHour
	mov dx, 3600d
	mul dx
	add SUM, ax	
	
	
printTime:	
	
	
							;Move pointer to right place
MOV DH, 16h    
MOV DL, 3Ch    
MOV AH,02h      
MOV BH,0        
INT 10h        
							;Print arr1
mov ah, 09h
mov dx, offset arr1
int 21h		


MOV DH, 17h  ;ligne   
MOV DL, 41h  ;colonne  
MOV AH,02h      
MOV BH,0        
INT 10h        
							;Print arr2
mov ah, 09h
mov dx, offset arr2
int 21h		
	

	
	mov ax, SUM				;Convert time from hexa to Decimal
	
	mov bx, 10d
	mov dx, 0
	div bx
	push dx
	mov dx, 0
	div bx
	push dx
	mov dx, 0
	div bx
	push dx
	mov dx, 0
	div bx
	push dx
		
	
;print the decimal value on screen

mov cx, 4
mov x, 3Ch
L1:
MOV DH, 17h  ;ligne   
MOV DL, x ;colonne  
MOV AH,02h      
MOV BH,0        
INT 10h 

pop bx
mov ah, 0Eh
mov al, tab1[bx]	
mov bh, 0h
mov bl, 60h
int 10h

inc x
dec cx
cmp cx, 0h
JNZ L1


MOV DH, 24  ;ligne   
MOV DL, 0 ;colonne  
MOV AH,02h      
MOV BH,0        
INT 10h 


mov gameStarted, 1   			;Set started Game flag to 1 

	pop si
	pop bx
JMP PollKeyboard	

SOFF:
	cli							;Back to otiginal 08 interuption
	mov ah,25h
	mov al,08
	mov dx , Old_int_off
	mov ds, Old_int_seg
	int 21h
	sti
										
in al, 21h
and al, 0FDh
out 21h, al  

;return to OS
mov ax, 4c00h
int 21h

end START
