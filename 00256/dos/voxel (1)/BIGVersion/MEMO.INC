;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;갚�  Ajusta, prepara y pide memoria
;갚�  para las pantallas virtuales.
;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
Memoria PROC
        ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        ;갚�    Ajusta la memoria asignada al programa
        ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        MOV BX,300                      ;갚� Reserva 256*16 = 4 Kb
        MOV AH,4Ah                      ;갚� Modifica el tama쨚 del bloque reservado
        INT 21h                         ;갚� al segmento indicado en ES.Ahora ES = Seg.Programa
        PUSH CS                         ;갚� DS = Segmento de datos
        POP  DS

        ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        ;갚�    Pide memoria para guardar imagen 1
        ;컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
        MOV BX,8096                     ;갚� N즡ero de p쟲rafos. 64k/16 bytes por p쟲rafo
        MOV AH,48h
        INT 21h                         ;갚� Reserva memoria
        MOV WORD PTR [SegImagen],AX

        RET
Memoria ENDP
