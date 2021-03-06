; The double buffer segment is in GS.
; The frame counter is in DI.
; Preserve FS and GS
; 29 bytes max

; dx = x - 160
; dy = y - 108 
; buffer[x + y * 320] = frame + 30000/((dx*dx)|(dy*dy)+1);
effect3:
        sub ax, 108
        sub dx, 160
        push dx
        mul ax
        mov bx, ax
        pop ax
        mul ax
        or bx, ax
        inc bx
        mov ax, 31337
        xor dx, dx
        div bx
        add ax, di
