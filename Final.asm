include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h

.386
MAXTEXTSIZE equ 50

.DATA
	_aa	dd	?
	_b	dd	?
	_a	dd	?
	_d	dd	?
	_p1	dd	?
	_p2	dd	?
	_p3	dd	?
	_p4	dd	?
	_h1	dd	?
	_h2	dd	?
	_HOLA	db	"HOLA", "$"
	__2_00	dd	2.00
	__3_00	dd	3.00

.CODE
START:
; ******* CODIGO PERMANENTE ********
	mov AX,@DATA
	mov DS,AX
; **********************************
	mov es,ax
		FLD 	_3_00	
		FSTP	_aa	
mov ah,4ch
mov al,0
int 21h

STRLEN PROC NEAR
	mov BX,0

STRL01:
	cmp BYTE PTR [SI+BX],'$'
	je STREND
	inc BX
	jmp STRL01

STREND:
	ret

STRLEN ENDP

COPIAR PROC NEAR
	call STRLEN
	cmp BX,MAXTEXTSIZE
	jle COPIARSIZEOK
	mov BX,MAXTEXTSIZE

COPIARSIZEOK:
	mov CX,BX
	cld
	rep movsb
	mov al,'$'
	mov BYTE PTR [DI],al
	ret

COPIAR ENDP

END START
