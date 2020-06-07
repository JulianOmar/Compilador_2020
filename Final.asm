include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h

.386
MAXTEXTSIZE equ 50

.DATA
	_f1	dd	?
	_f2	dd	?
	_f3	dd	?
	_f4	dd	?
	_f5	dd	?
	_f6	dd	?
	_f7	dd	?
	_i1	dd	?
	_i2	dd	?
	_i3	dd	?
	_i4	dd	?
	_i5	dd	?
	_i6	dd	?
	_i7	dd	?
	_1	db	"1", 1
	_2	db	"2", 1
	__24_00	dd	24.00
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
	@aux12	dd	?
	@aux13	dd	?
	@aux14	dd	?
	@aux15	dd	?
	@aux16	dd	?
	@aux17	dd	?
	@aux18	dd	?
	@aux19	dd	?
	@aux20	dd	?
	@aux21	dd	?
	@aux22	dd	?
	@aux23	dd	?
	@aux24	dd	?
	@aux25	dd	?
	@aux26	dd	?
	@aux27	dd	?
	@aux28	dd	?
	@aux29	dd	?
	@aux30	dd	?
	@aux31	dd	?
	@aux32	dd	?

.CODE
START:
; ******* CODIGO PERMANENTE ********
		mov AX,@DATA
		mov DS,AX
		mov es,ax
; **********************************
ETQ_0:
		;ETQ_REPEAT		
ETQ_1:
		displayString	_1	
		newLine		
ETQ_2:
		displayString	_2	
		newLine		
ETQ_3:
		FLD	__24_00	
		FSTP	@aux3	
ETQ_4:
		FLD	_i1	
		FSTP	@aux4	
ETQ_5:
		FLD	@aux4	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_6:
		JNB	ETQ_9	
		JNB	ETQ_9	
ETQ_7:
		FLD	@aux4	
		FSTP	_auxFiltro	
ETQ_8:
		JMP	ETQ_29	
		JMP	ETQ_29	
ETQ_9:
		FLD	_i2	
		FSTP	@aux9	
ETQ_10:
		FLD	@aux9	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_11:
		JNB	ETQ_14	
		JNB	ETQ_14	
ETQ_12:
		FLD	@aux9	
		FSTP	_auxFiltro	
ETQ_13:
		JMP	ETQ_29	
		JMP	ETQ_29	
ETQ_14:
		FLD	_i3	
		FSTP	@aux14	
ETQ_15:
		FLD	@aux14	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_16:
		JNB	ETQ_19	
		JNB	ETQ_19	
ETQ_17:
		FLD	@aux14	
		FSTP	_auxFiltro	
ETQ_18:
		JMP	ETQ_29	
		JMP	ETQ_29	
ETQ_19:
		FLD	_i4	
		FSTP	@aux19	
ETQ_20:
		FLD	@aux19	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_21:
		JNB	ETQ_24	
		JNB	ETQ_24	
ETQ_22:
		FLD	@aux19	
		FSTP	_auxFiltro	
ETQ_23:
		JMP	ETQ_29	
		JMP	ETQ_29	
ETQ_24:
		FLD	_i5	
		FSTP	@aux24	
ETQ_25:
		FLD	@aux24	
		FCOMP	@aux3	
		FSTSW	ax	
		SAHF		
ETQ_26:
		JNB	ETQ_29	
		JNB	ETQ_29	
ETQ_27:
		FLD	@aux24	
		FSTP	_auxFiltro	
ETQ_28:
		JMP	ETQ_29	
		JMP	ETQ_29	
ETQ_29:
		FLD	_i6	
		FSTP	@aux29	
ETQ_30:
		FLD	_auxFiltro	
		FSTP	@aux30	
ETQ_31:
		FLD	@aux30	
		FCOMP	@aux29	
		FSTSW	ax	
		SAHF		
ETQ_32:
		JE	ETQ_1	
		JE	ETQ_1	
ETQ_33:
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
