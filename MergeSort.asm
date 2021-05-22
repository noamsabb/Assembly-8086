.model small
.data
S EQU 4
arr db 5h,4h,3h,2h
.stack 100h
.code

MergeSort PROC 

cmp dx, 1 ;check if array isnt 1
JZ finish 

mov ax, dx
mov bh,2
div bh
mov dx,ax
push dx  ;size of the array
push cx ;offset of the array 

CALL MergeSort
mov bp,sp
mov di,6
mov cx,[bp+di]
mov di, 8
mov dx ,[bp+di]

mov ax, dx
mov bh,2
div bh
mov dx,ax
inc cx
push dx
push cx 
CALL MergeSort
pop bx ;left offset
pop di ;left size
pop bp ;right offset
pop si ;right size

mov cx, di
add cx, si
push cx

CALL Merge 

finish:

RET
MergeSort endp

  
;Merge function  

Merge PROC 
mov cx,0 
mov ax,0

Next:
mov cl,[bx] ;move first number of left array to cx
mov al,DS:[bp] ;move first number of right array to ax
cmp al,cl
JAE RightsBigger

LeftsBigger:
pop dx
push ax ;pushing smallest to stack
push dx ;saving size
inc bp ;move head of right array
dec si
cmp si,0 ;if si = 0 , right array is empty
JZ RightZero
JMP Next

RightsBigger:
pop dx
push cx ;pushing smallest to stack
push dx ;saving size
inc bx ;move head of left array
dec di
cmp di,0 ;if di = 0 , left array is empty
JZ LeftZero
JMP Next

LeftZero:
;pushing what's left of right array to stack
mov ax, [bp]
pop dx
push ax ;pushing smallest to stack
push dx ;saving size
inc bp
dec si
cmp si, 0
JNZ LeftZero
JMP COPYBACK

RightZero:
;pushing what's left of left array to stack
mov cx, [bx]
pop dx 
push cx ;pushing smallest to stack
push dx ;saving size
inc bx
dec di
cmp di, 0
JNZ RightZero
JMP COPYBACK

COPYBACK:
;poping back what's in the stack to the correct place in the array 

pop si ;pop the size of the array
pop ax ;pop top number of stack
mov bx, offset arr
mov [bx+si],ax ;put top stack number at his place in he array
dec si
JNZ COPYBACK


RET
Merge ENDP


START:
 ;setting data segment
 mov ax, @data
 mov ds, ax
 
mov dx, S ;size of the array
mov cx, offset arr
CALL MergeSort

;return to OS
 mov ax, 4c00h
 int 21h
 
 
end START