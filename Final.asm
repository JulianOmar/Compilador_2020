include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h

.386
MAXTEXTSIZE equ 50

.DATA
	_A	dd	?
	_B	dd	?
	_C	dd	?
	__44_00	dd	44.00
	__24_00	dd	24.00
	_auxFiltro	dd	?
	@aux0	dd	?
	@aux1	dd	?

.CODE
START:
; ******* CODIGO PERMANENTE ********
		mov AX,@DATA
		mov DS,AX
		mov es,ax
; **********************************
ETQ_0:
		FLD	__44_00	
		FSTP	_A	
ETQ_1:
		FLD	__24_00	
		FSTP	_B	
ETQ_2:
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
