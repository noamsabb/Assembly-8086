;Noam Sabban 329897391
;Sarah Bitton 336443338
;26/06/2020


.model small
.data
arr1 db "you are fast$"
arr2 db"okay$"
arr3 db"that's slow$"
arr4 db "You Lost$"
Old_int_off dw 0
Old_int_seg dw 0
HELP dw 30d

.stack 100h
.code

ISR_NEW_Int8 proc near uses ax bx cx dx bp si ds es
pushf
CALL DWORD PTR [Old_int_off] 

cmp di, 0
JNZ fin
 

 
 mov cx, 5
 
 mov bx, 0
 mov al, ' '
 mov ah, 0h
 mov si, HELP
 
 L1:
 mov es:[bx+si], ax
 add bx, 160
 dec cx
 jnz L1


 cmp HELP, 0
 JZ LOOSE

 sub HELP, 2
 mov bx, 0
 mov di, 21

fin:
dec di

iret
ISR_NEW_Int8 endp

START:
	 						;setting data segment
mov ax, @data
mov ds, ax
mov ax, 0b800h
mov es, ax 
mov di, 30
push di
mov di, 20


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

							;print the square 
mov ah,06h
mov al,0
mov bh ,0E0h
mov ch,0
mov cl,0
mov dh,4
mov dl,14
int 10h


 
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
 
 mov cx, 00h
 mov cl,al
 push cx
 
 
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
 
 mov cx, 00h
 mov cl,al
 push cx
 
 
 
in al, 21h
or al, 02h
out 21h, al  

mov dl,40h 
mov dh,40h
mov bx, 2080d
mov si,80d                       ; Print @ middle screen 
mov es:[bx+si], dx

PollKeyboard:
IN AL, 64h
TEST AL, 01             		 ;Checking if we got a new letter
JZ PollKeyboard       			 ;if not, check again

IN AL, 60h             
          
up:
cmp al, 48h              		 ; if up arrow
JNZ down


cmp bx, 0						 ;checking border
JZ PollKeyboard


mov es:[bx+si], ' '   						
sub bx, 160d
mov dl,40h 
mov dh,40h
mov es:[bx+si], dx


cmp bx, 640d					  ;Entering yellow square by down side
JNZ PollKeyboard
cmp si, HELP
JBE FINISH

JMP PollKeyboard 
  
down:
cmp al,50h               		  ;If down arrow
JNZ right


cmp bx, 3840d					  ;checking border
JZ PollKeyboard

mov es:[bx+si], ' '         
add bx, 160
mov dl,40h 
mov dh,40h
mov es:[bx+si],dx

JMP PollKeyboard
 
right:
cmp al,4Dh                         ;if right arrow
JNZ left

cmp si, 158d					   ;checking border
JZ PollKeyboard

mov es:[bx+si], ' ' 
add si, 2      
mov dl,40h 
mov dh,40h
mov es:[bx+si],dx

JMP PollKeyboard 
 
left:    
   
cmp al, 4Bh 				    	;if left arrow
JNZ stop 

cmp si, 0d						    ;checking border
JZ PollKeyboard

mov es:[bx+si], ' '   
sub si, 2
mov dl,40h 
mov dh,40h
mov es:[bx+si],dx




cmp si, HELP 							;Entering yellow square by right side
JNZ PollKeyboard
cmp bx, 640d
JBE FINISH

JMP PollKeyboard 

stop:
cmp al, 01Fh
JNZ PollKeyboard 


FINISH:

mov ax, 0							; Get End time minutes
mov al,02h                             
out 70h,al
in al,71h

mov ch, 10h							;Conversion to hexa
div ch
mov dh, ah
mov ah, 0
mov ch, 10d
mul ch
add al, dh
 
 
 
pop cx
sub ax,cx
cmp ax, 1
JZ MinutesCheck
cmp ax, 2
JAE print3
cmp ax, 0
JMP TimeCheck


MinutesCheck:

mov ax, 0							; Get End time seconds
mov al,00h                             
out 70h,al
in al,71h

mov ch, 10h						;Conversion to hexa
div ch
mov dh, ah
mov ah, 0
mov ch, 10d
mul ch
add al, dh
 
pop cx
mov dx, 60d
sub dx, cx
add dx, ax
mov cx, dx
JMP SpeedTime


TimeCheck:

mov ax, 0							; Get End time seconds
mov al,00h                             
out 70h,al
in al,71h

mov ch, 10h							;Conversion to hexa
div ch
mov dh, ah
mov ah, 0
mov ch, 10d
mul ch
add al, dh
 
pop cx
sub ax,cx
mov cx, ax


SpeedTime:

cmp cx, 10d							;Check more than 10
JAE print3


cmp cx, 5d							;Check 0-5
JBE print1

JMP print2


print1:

mov ah, 09h
mov dx, offset arr1
int 21h
JMP SOF

print2:

mov ah, 09h
mov dx, offset arr2
int 21h
JMP SOF

print3:
mov ah, 09h
mov dx, offset arr3
int 21h
JMP SOF

LOOSE:
mov ah, 09h
mov dx, offset arr4
int 21h


SOF:

										;Back to otiginal 08 interuption
cli
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


;קליטת קלט מהמקלדת נעשה על ידי פסיקה אבל הזזה ה@ נעשה בפונקציות שכתבנו
לכן  אפילו אם אני באמצה פסיקה 08 ואני לוחץ על כפתור, הערך שלחצנו עליו הישמר בצד עד יציאה מהפסיקה 08 ואז ימשיך בקוד שלי עד למיקום בו מזיזים את ה@ לפי מה שנקלט מהמקלדת
לכן לפי סדר הקוד, פסיקה 08 מתחילה ותוך כדי נקלט מהמקלדת אבל אין הזזה עדיין, הפסיקה 08 מסתיימת ומקטינה ורק אז זה הול לbuffer ומזיז לפי מה שנקלט מקודם


;זה לא מקביליות אמיתית כי כמו שהסברנו בפועל זה קודם מקטין ואז מזיז 
אבל שתי הפסיקות 08 ו XX קורות באותו זמן ואז מהפונקציות כתבנו זה מזיז את ה@ למיקום הנכון

