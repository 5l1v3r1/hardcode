;       KOLBASIT.ASM
;
;       Author: Glorija
;       Mailto: glorija@nm.ru
;
.model tiny
.code
.386
org 100h

start:

;	���樠�����㭣
finit
mov ax,13h
int 10h

m1:

; ���頥� ����ப...
push ds
pop es
mov di, offset buffer
xor ax,ax 	 
mov cx,320*200/4
rep stosd  ; ��९����� �����, �⢥�� ����...

fld t
fld st
fsin
fstp s
fcos
fstp c

mov ax,16
mov c1,ax
mov c0,ax

mov ax,zpr
neg ax
mov z,ax

m2:
mov ax,-100
mov y,ax
mov ax,160
mov x0,ax

; *** ���� �᪠����� (�����ᨬ ��) ***
fild z
fmul td
fld t
fmul k1
fsin
fld t
fmul k2
fcos
fadd
fmul
fsin
fld st
fadd k0
fstp k
fimul x0
fiadd x0
fistp x0 
; ******* ���� �������ᨫ�! ********

m3:     ; � 	
fild rk ;  �
fild y  ;   �
fmul c  ;    �
fild z  ;     �
fmul s  ;      �
fsub    ;       
fld st  ;        �
fmul    ;         �
fsub    ;          �
ftst    ;           �	
fstsw ax;            �
fstp u  ;             �
sahf    ;              � 	
jc m11  ;               �
        ;                �
fild z  ;                 �	
fmul c  ;                  �	
fild y  ;                   �
fmul s  ;                    �	
fadd    ;                     .	
fld st  ;                      .	
fmul    ;                       .	
fstp b  ;			
fld u   ;
fsqrt   ;                       � 
fst u   ;                      �
        ;                     �
fild r  ;                    �
fmul f2 ;
fadd    ;                  �
fld st  ;                 �
fmul    ;                �
fsub b  ;               �
ftst    ;              �
fstsw ax;             �
fstp d1 ;            �
sahf    ;           �
jc m11  ;          �
fld d1  ;         �
fsqrt   ;        �
fmul k  ;       �
fistp x1;      �
        ;     �
mov di,y0
add di,y
imul di,320
add di,offset buffer

fild r
fmul f2
fsub u
fld st
fmul
fsub b
ftst
fstsw ax
fstp d2
sahf
jnc m4

mov ax,x1
jmp m5

m4:
fld d2
fsqrt
fmul k
fistp x2
call line

mov ax,x2
neg ax
xchg ax,x1

m5:
neg ax
mov x2,ax
call line

m11:
mov ax,y
inc ax
mov y,ax
cmp ax,100
jle m3

; �����ࠥ��� � 梥⮬
mov ax,c1 
add ax,1
cmp ax,16+30
jl m9
mov ax,16
m9:
mov c1,ax
cmp ax,32
jl m10
neg ax
add ax,62
m10:
mov c0,ax
mov ax,z
add ax,dz
mov z,ax
cmp ax,zpr
jle m2

; �뢮��� �� ��࠭
xor di,di
push 0A000h
pop es
mov si, offset buffer
mov cx,320*200/4
rep movsd

fld t
fadd td
fstp t

; ������� �����襭��
in al,60h	
dec al
jnz m1        ; �� ������ �� ��� ESC ?	
mov ax,3
int 10h
retn	      ; �� � ᫠�� ⥡�, ��ᯮ��!

; ���㥬 �����
line proc near	      
push di
mov ax,x0
mov cx,ax
add ax,x2
jge m6
xor ax,ax
m6:
add cx,x1
cmp cx,320
jl m7
mov cx,319
m7:
sub cx,ax
jl m8 
add di,ax
mov ax,c0
rep stosb ; ��९��ᨫ�, � ��ᨫ�...	
m8:	
pop di
retn	
line endp

; ���, ������! 

; ********************************************************
; � ��� ��� 祣� �뫨 �㦭� �� �� ��६����-����ﭭ�:

f2 dd 2.0       ; ���⭮襭�� ࠤ��ᮢ � ��
r dw 32         ; ���� ࠤ��� ��	
rk dw 32*32	; ������ ������ ࠤ���
zpr dw 32*3	; �।�� ��������� ���न���� z	
dz dw 8     ; ��� �� z
t dd 0.0	; ����騩 㣮� ������
td dd 0.02	; ��������� 㣫� ������
x0 dw 160	; ���न����
y0 dw 100   ;            業�� 
k0 dd 1.2	; �᪠���騥 �����樥���
k1 dd 1.37	; ��� �ந���쭮�� 
k2 dd 1.83	; ���稢����

k dd ?		; ����殮��� �� x
s dd ?		; ����� t
c dd ?		; ��ᨭ�� t
u dd ?          ; ��
b dd ?          ;   ��	
d1 dd ?         ;     ��		
d2 dd ?         ;       ��
x1 dw ?         ;         ��	
x2 dw ?         ;           ��			
y dw ?		; ����騩 y
z dw ?		; ����騩 z
c0 dw ?		; ����
c1 dw ?		; ���稪 梥�

buffer db 320*200 dup (?) ; ����ப ��� ���⨭��

end start 

; *****************  �����!  ********************
