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
	_D	dd	?
	__107_00	dd	107.00
	__42_00	dd	42.00
	__8_00	dd	8.00
	_auxFiltro	dd	?
	@aux0	dd	?
	@aux1	dd	?
	@aux2	dd	?
	@aux3	dd	?

.CODE
START:
; ******* CODIGO PERMANENTE ********
		mov AX,@DATA
		mov DS,AX
		mov es,ax
; **********************************
ETQ_0:
		FLD	__107_00	
		FSTP	_A	
ETQ_1:
		FLD	__42_00	
		FSTP	_B	
ETQ_2:
		FLD	__8_00	
		FSTP	_C	
ETQ_3:
		FLD	_C	
		FSTP	_D	
ETQ_4:
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
