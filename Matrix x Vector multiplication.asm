.model small
.data

  N EQU 3
  MAT db 2h,3h,1h,0Ah,8h,1h,0Fh,5h,4h
  VEC db 7h,0Dh,6h
  RESULT  dw N dup(0)
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
mov bp, N
mov ah, 0h
mov sp, N

L1:
mov di, 0h
L2:
mov al, MAT[si]
imul VEC[di]
inc di
inc si
mov dx, ax
add RESULT[bx], dx
dec sp
JNZ L2
mov ax, RESULT[bx]
mov sp, N
add bx, 2
dec bp
JNZ L1

;return to OS
 mov ax, 4c00h
 int 21h
end START

;שאלה 1׃ כי כפל של 8 ביט ב8 ביט יכול להגיע עד 16 ביט לכן צריכים שמערך התוצאות יוכל להכיל מילים

;שאלה 2׃ חיפשתי בעזרת הדיבג איזה ערכים נמצאים בתוך מערך RESULT ובדקי שזה אכן הערכים הנכונים של תוצאת הכפל  

;שאלה 3׃ אם המטריצה N שווה 256 אם שומרים את כל הערכים בDS אין מספיק מקום בDS לשמור את כל זה כי הגודל המקסימלי שלו הוא 10000  ואם נחשב עם N 256 מגיעים ליותר מזה
