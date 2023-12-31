; �ணࠬ�� ����� � �뢮�� �᫠, � �ਬ������� �㭪樨 "������ �᫠",
; � ������������ 㪠����� ��⥬� ��᫥��� �� ����� � �뢮�� �� ��࠭

; --- ������� �⥪�
sta segment stack
	db 256 dup(?)
sta ends

; --- ������� ������
dan segment
	num				dw ?

	sCrLf			db 0Dh, 0Ah, "$"
	sInputRadix		db "������ ��⥬� ��᫥��� ��� ��ࠬ��� ���⮢ (2..16) [10]: $"
	sOutputRadix	db "������ ��⥬� ��᫥��� ��� �뢮�� १���� ���⮢ (2..16) [10]: $"
	sIncorrectRadix	db "������� �������ন������ ��⥬� ��᫥���. �������� ���祭��: �� 2 �� 16.$"
	sEnterNumber	db "������ �᫮: $"
	sResult1		db "                                           ���������������������ķ", 0Dh, 0Ah
					db "�㭪��: '������ �᫠'. ������� ࠢ��: � $"
	sResult2		db "                                           ���������������������Ľ$"
	sPressAnyKey	db "��� �த������� ������ ���� �������...$"

	charsTable		db "0123456789ABCDEF"
dan ends

; --- ������� ����
cod segment
			assume cs:cod,ds:dan,ss:sta
beg:
			mov dx, dan			 	; ����㦠�� ��砫� ᥣ���� ������
			mov ds, dx		 		; � ॣ���� dx
			mov es, dx

			call clearScr

; �롮� ��⥬� ��᫥��� �� �����
			mov dx, offset sInputRadix
			call getRadix
;-------------------------
; �뢮� ��ப� "������ �᫮"
			mov dx, offset sEnterNumber
			call printMsg
;-------------------------
			call getNumber

			call function			; �㭪�� ��� �᫠ (� ����ᨬ��� �� ��ਠ��), ��� ��ਠ�� - ������ �᫠

			mov num, ax				; ��࠭塞 �����⥫쭮� ���祭�� ������ �᫠ � ��६����� "num"
;--------------------------
; �롮� ��⥬� ��᫥��� �� �뢮��
			mov dx, offset sOutputRadix
			call getRadix

; �뢮� १���� �� ��࠭
;----------------------------
			mov dx, 1000h
			call setCursor
;----------------------------
			mov dx, offset sResult1
			call printMsg

			mov bx, ax
			mov ax, num
			call putNumber
			
			call closeTabRow

			call putNewLine
			mov dx, offset sResult2
			call printMsg

			call pressAnyKey
;----------------------------
; �����譨� �믮������ �ணࠬ��
			mov ax, 4C00h		; ��ࠡ�⪠ ����砭��
			int 21h				; �ணࠬ��


;----------------------------
; ����ணࠬ��
;----------------------------
; ---
; ����� ��⥬� ��᫥��� (�����頥� �� � AX), ᬥ饭�� ��ப� ����� ��।����� � DX
getRadix	proc near
			push dx
@@enter:	call putNewLine
			call printMsg
			call getDecimal
			cmp ax, 00h
			jne @@notDef		; ��-� ������, �㤥� �஢�����
			mov ax, 0Ah			; �᫮ �� ������� (��� ����� 0): �� 㬮�砭�� 10-�筠�
			jmp @@radixOk
@@notDef:	cmp ax, 02h
			jb @@wrong
			cmp ax, 10h
			ja @@wrong
			jmp @@radixOk
@@wrong:	push dx	
			mov dx, offset sIncorrectRadix
			call printMsg
			call pressAnyKey
			pop dx
			call clearScr
			jmp @@enter
@@radixOk:	pop dx
			retn
getRadix	endp

; ---
; �뢮� �᫠ (� AX) �� ��࠭ � ��।������� ��⥬� ��᫥��� (� BX)
; � AX �����頥� ���-�� �뢥������ ᨬ�����
putNumber	proc near
			push bx cx dx si
			mov si, bx
			mov bx, 1
			mov cx, 0
@@putNext1:	mov dx, 0
			div si
			push bx
			mov bx, dx
			mov dl, byte ptr charsTable[bx]
			pop bx
			;add dx, '0'
			push dx
			inc cx
			cmp ax, 0
			jnz @@putNext1
@@putNext2:	pop dx
			call putChar
			inc bx
			loop @@putNext2
			mov ax, bx
			pop si dx cx bx
			retn
putNumber	endp


; ---
; �㭪��, ������ ����室��� �믮����� ��� ���������� �᫠, ��������� � AX
function	proc near
			mul ax		; ���������� � ������
function 	endp

; ---
; ��⠭����� ����� � ������ �������� � ॣ���� ax
setCursor	proc near
			push ax bx
			mov bh, 00h
			mov ah, 02h
			int 10h
			pop bx ax
			retn
setCursor	endp

; ---
; ������ ��࠭
clearScr	proc near
			push ax bx cx dx
			mov ax, 0600h
			mov bh, 0Fh
			mov cx, 00h
			mov dx, 184Fh
			int 10h

; ��⠭���� ����樨 �����
			mov dx, 0000h
			call setCursor

			pop dx cx bx ax
			retn
clearScr	endp

; ---
; ��ॢ�� ����� �� ��࠭� �� ����� ��ப�
putNewLine	proc near
			push dx
			mov dx, offset sCrLf
			call printMsg
			pop dx
			retn
putNewLine	endp

; ---
; �뢮� �� ��࠭ ��ப�
printMsg	proc near
			push ax
			mov ah,09h			; ᮣ��᭮ ��⮪��� � ॣ���� ah ���뫠���� �㭪��
								; �뢮�� ��ப� �� ��࠭ �� '$'
			int 21h				; ᮣ��᭮ ��⮪��� � ���� ds:dx �㤥� �뢮�����
			pop ax
			retn
printMsg	endp

; ---
; �⮡ࠧ��� ᮮ�饭�� � ��������� ������ �� ������
pressAnyKey	proc near
			push ax dx
			call putNewLine
			mov dx, offset sPressAnyKey
			call printMsg

			mov ah, 01h			; �࣠���㥬 ����প� �믮������ �ணࠬ��
			int 21h				; �� ������ ������
			pop dx ax
			retn
pressAnyKey	endp


; ---
; ���� �᫠ � �����筮� ��⥬� ��᫥���
; �⢥� - � ॣ���� AX
getDecimal	proc near
			mov ax, 0Ah
			call getNumber
			retn
getDecimal	endp

; ---
; ���� �᫠ � ��।������� ��⥬� ��᫥���, �������� � AX
; �⢥� - � ॣ���� AX
getNumber	proc near
			push bx cx dx si di
			mov si, ax			; ࠡ�⠥� � �㦭�� ��⥬�� ��᫥���
			mov di, 00h
@@begin:	call getChar
			cmp al, 0Dh			; �஢��塞 ����⨥ ������ "����"
			je @@done			; �᫨ ������ �����, � ���室�� �� �����
; �஢�ઠ �� ���� �᫠
			cmp al, '0'
			jb @@wrongChr
			cmp al, 'F'
			jbe @@upper
			sub al, 20h			; �㪢� � ������ ॣ����
@@upper:	push di
			mov di, offset charsTable
			mov bx, 10h			; ���-�� ��������� ᨬ����� ��� �ᥫ
			mov cx, bx
			repne scasb
			pop di
			jne @@wrongChr
			sub bx, cx
			cmp bx, si
			ja @@wrongChr
			cmp al, '9'
			ja  @@next1
			sub al, '0'				; �� ���� ASCII ����砥� ����
			jmp @@correct
@@next1:	cmp al, 'F'
			ja  @@next2
			sub al, 55
			jmp @@correct
@@next2:	cmp al, 'f'
			ja @@wrongChr
			sub al, 87
			jmp @@correct
@@wrongChr:	call delLastChar
			jmp @@begin
@@correct:	xor ah, ah				; ⥯��� ���祭�� �� ࠢ�� ���祭�� al
			mov cx, ax				; �����㥬 �� � ��
			mov ax, di				; �����뢠�� � �� ��������� �� ⥪�饩 ���� �᫮
			mul si					; 㬭����� ��� �� 10, ���室� ⥬ ᠬ� � ⥪�騩 ࠧ��
			add ax, cx				; ������塞 � ��� ⥪���� ����
			mov di, ax				; ��࠭塞 ⥪�饥 �᫮ � di
			jmp @@begin				; ���室�� �� ��ࠡ��� ᫥���饣� ࠧ�鸞
@@done:		mov ax, di				; ��࠭塞 �����⥫쭮� ���祭�� ���������� �᫠ � ax
			pop di si dx cx bx
			retn
getNumber	endp

; ---
; ���� ᨬ���� � ����������, १���� � AL
getChar		proc near
			mov ah, 01h
			int 21h

			retn
getChar		endp

; ---
; �뢮� ᨬ���� �� ��࠭, ᨬ��� � DL
putChar		proc near
			push ax
			mov ah, 02h
			int 21h
			pop ax
			retn
putChar		endp

; ---
; �⮡ࠧ��� ᨬ��� "�������" �祩�� ⠡����
closeTabRow	proc near
			push ax cx dx
			mov cx, 21
			sub cx, ax
			mov dl, " "
@@nextChar:	call putChar
			loop @@nextChar
			mov dl, "�"
			call putChar
			pop dx cx ax
			retn
closeTabRow endp

; ---
; ������� �� ��࠭� ��᫥���� �������� ᨬ���
delLastChar	proc near
			push dx
			mov dl, 08h
			call putChar
			mov dl, 32
			call putChar
			mov dl, 08h
			call putChar
			pop dx
			retn
delLastChar	endp

cod ends
end beg
