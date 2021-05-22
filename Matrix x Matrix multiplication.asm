.model small
.data

  N EQU 3
  MAT1 db 2h,3h,1h,0Ah,8h,1h,0Fh,5h,4h
  MAT2 db 7h,3h,9h,0h,0Dh,1h,6h,0Bh,2h
  RESULT  dw N*N dup(0)
.stack 100h
.code

START:
 
 ;setting data segment
 mov ax, @data
 mov ds, ax

;setting extra segment to screen memory
mov ax, 0b800h
mov es, ax 
mov si, 0h
mov bx, 0h
mov ax, 0h
mov dl, N
mov ch, N
mov di, 0h
mov cl, N
push si
push di


L1:

L2:
L3:

mov al, MAT1[si]
imul MAT2[di]
inc si
add di, N
add RESULT[bx], ax

dec ch
JNZ L3


add bx, 2
pop di
inc di
pop si
push si
push di

mov ch, 3h
dec dl
JNZ L2

pop di
mov di, 0h
pop si
add si, 3h
push si
push di

mov dl, 3h
dec cl
JNZ L1

;return to OS
 mov ax, 4c00h
 int 21h
end START