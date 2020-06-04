include macros2.asm
include number.asm
 .MODEL LARGE
.386
.STACK 200h
MAXTEXTSIZE equ 50
 
.DATA









.CODE
;************************************************************
; devuelve en BX la cantidad de caracteres que tiene un string
; DS:SI apunta al string.
;
STRLEN PROC
    mov bx,0
STRL01:
    cmp BYTE PTR [SI+BX],'$'
    je STREND
    inc BX
    jmp STRL01
STREND:
    ret
STRLEN ENDP


;*********************************************************************8
; copia DS:SI a ES:DI; busca la cantidad de caracteres
;
COPIAR PROC
    call STRLEN
    cmp bx,MAXTEXTSIZE
    jle COPIARSIZEOK
    mov bx,MAXTEXTSIZE
COPIARSIZEOK:
    mov cx,bx
    cld
    rep movsb
    mov al,'$'
    mov BYTE PTR [DI],al
    ret
COPIAR ENDP


;*******************************************************
; concatena DS:SI al final de ES:DI.
;
; busco el size del primer string
; sumo el size del segundo string
; si la suma excede MAXTEXTSIZE, copio solamente MAXTEXTSIZE caracteres
; si la suma NO excede MAXTEXTSIZE, copio el total de caracteres que tiene el segundo string
;
CONCAT PROC
    push ds
    push si
    call STRLEN
    mov dx,bx
    mov si,di
    push es
    pop ds
    call STRLEN
    add di,bx
    add bx,dx
    cmp bx,MAXTEXTSIZE
    jg CONCATSIZEMAL
CONCATSIZEOK:
    mov cx,dx
    jmp CONCATSIGO
CONCATSIZEMAL:
    sub bx,MAXTEXTSIZE
    sub dx,bx
    mov cx,dx
CONCATSIGO:
    push ds
    pop es
    pop si
    pop ds
    cld
    rep movsb
    mov al,'$'
    mov BYTE PTR [DI],al
    ret
CONCAT ENDP




START:
; ******* CODIGO PERMANENTE ********
    mov AX,@DATA
    mov DS,AX
    mov es,ax   
; **********************************







END START
