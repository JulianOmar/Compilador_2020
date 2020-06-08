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
	__5_00	dd	5.00
	_PRIMERO	db	"PRIMERO", 7
	__3_00	dd	3.00
	_SEGUNDO	db	"SEGUNDO", 7
	_auxFiltro	dd	?
	@aux0	dd	?
	@aux1	dd	?
	@aux2	dd	?
	@aux3	dd	?
	@aux4	dd	?
	@aux5	dd	?
	@aux6	dd	?
	@aux7	dd	?
	@aux8	dd	?
	@aux9	dd	?
	@aux10	dd	?
	@aux11	dd	?

.CODE
START:
; ******* CODIGO PERMANENTE ********
		mov AX,@DATA
		mov DS,AX
		mov es,ax
; **********************************
ETQ_0:
		GetFloat	_b	
ETQ_1:
		GetFloat	_a	
ETQ_2:
		FLD	_b	
		FSTP	@aux2	
ETQ_3:
		FLD	__5_00	
		FSTP	@aux3	
ETQ_4:
		FLD	@aux2	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_5:
		JE	ETQ_12	
		JE	ETQ_12	
ETQ_6:
		displayString	_PRIMERO	
		newLine		
ETQ_7:
		FLD	_a	
		FSTP	@aux7	
ETQ_8:
		FLD	__3_00	
		FSTP	@aux8	
ETQ_9:
		FLD	@aux7	
		FCOMP	@aux8	
		FSTSW	ax	
		SAHF		
ETQ_10:
		JNE	ETQ_12	
		JNE	ETQ_12	
ETQ_11:
		displayString	_SEGUNDO	
		newLine		
ETQ_12:
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
