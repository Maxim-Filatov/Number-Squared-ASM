; программа ввода и вывода числа, с применением функции "квадрат числа",
; с возможностью указания системы счисления при вводе и выводе на экран

; --- Сегмент стека
sta segment stack
	db 256 dup(?)
sta ends

; --- Сегмент данных
dan segment
	num				dw ?

	sCrLf			db 0Dh, 0Ah, "$"
	sInputRadix		db "Введите систему счисления для параметра расчетов (2..16) [10]: $"
	sOutputRadix	db "Введите систему счисления для вывода результата расчетов (2..16) [10]: $"
	sIncorrectRadix	db "Введена неподдерживаемая система счисления. Возможные значения: от 2 до 16.$"
	sEnterNumber	db "Введите число: $"
	sResult1		db "                                           ╓─────────────────────╖", 0Dh, 0Ah
					db "Функция: 'квадрат числа'. Результат равен: ║ $"
	sResult2		db "                                           ╙─────────────────────╜$"
	sPressAnyKey	db "Для продолжения нажмите любую клавишу...$"

	charsTable		db "0123456789ABCDEF"
dan ends

; --- Сегмент кода
cod segment
			assume cs:cod,ds:dan,ss:sta
beg:
			mov dx, dan			 	; загружаем начало сегмента данных
			mov ds, dx		 		; в регистр dx
			mov es, dx

			call clearScr

; выбор системы счисления при вводе
			mov dx, offset sInputRadix
			call getRadix
;-------------------------
; вывод строки "Введите число"
			mov dx, offset sEnterNumber
			call printMsg
;-------------------------
			call getNumber

			call function			; функция для числа (в зависимости от варианта), наш вариант - квадрат числа

			mov num, ax				; сохраняем окончательное значение квадрата числа в переменной "num"
;--------------------------
; выбор системы счисления при выводе
			mov dx, offset sOutputRadix
			call getRadix

; вывод результата на экран
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
; Заверешние выполнения программы
			mov ax, 4C00h		; обработка окончания
			int 21h				; программы


;----------------------------
; Подпрограммы
;----------------------------
; ---
; Запрос системы счисления (возвращает ее в AX), смещение строки запроса передается в DX
getRadix	proc near
			push dx
@@enter:	call putNewLine
			call printMsg
			call getDecimal
			cmp ax, 00h
			jne @@notDef		; что-то задали, будем проверять
			mov ax, 0Ah			; число не введено (или ввели 0): по умолчанию 10-ричная
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
; вывод числа (в AX) на экран в определенной системе счисления (в BX)
; в AX возвращает кол-во выведенных символов
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
; Функция, которую необходимо выполнить для введенного числа, заданного в AX
function	proc near
			mul ax		; возведение в квадрат
function 	endp

; ---
; Установить курсор в позицию заданную в регистре ax
setCursor	proc near
			push ax bx
			mov bh, 00h
			mov ah, 02h
			int 10h
			pop bx ax
			retn
setCursor	endp

; ---
; Очистить экран
clearScr	proc near
			push ax bx cx dx
			mov ax, 0600h
			mov bh, 0Fh
			mov cx, 00h
			mov dx, 184Fh
			int 10h

; установка позиции курсора
			mov dx, 0000h
			call setCursor

			pop dx cx bx ax
			retn
clearScr	endp

; ---
; Перевод курсора на экране на новую строку
putNewLine	proc near
			push dx
			mov dx, offset sCrLf
			call printMsg
			pop dx
			retn
putNewLine	endp

; ---
; Вывод на экран строки
printMsg	proc near
			push ax
			mov ah,09h			; согласно протоколу в регистр ah засылается функция
								; вывода строки на экран до '$'
			int 21h				; согласно протоколу с адреса ds:dx будет выводится
			pop ax
			retn
printMsg	endp

; ---
; Отобразить сообщение и дождаться нажатия любой клавиши
pressAnyKey	proc near
			push ax dx
			call putNewLine
			mov dx, offset sPressAnyKey
			call printMsg

			mov ah, 01h			; организуем задержку выполнения программы
			int 21h				; до нажатия клавиши
			pop dx ax
			retn
pressAnyKey	endp


; ---
; Ввод числа в десятичной системе счисления
; Ответ - в регистре AX
getDecimal	proc near
			mov ax, 0Ah
			call getNumber
			retn
getDecimal	endp

; ---
; Ввод числа в определенной системе счисления, заданной в AX
; Ответ - в регистре AX
getNumber	proc near
			push bx cx dx si di
			mov si, ax			; работаем с нужной системой счисления
			mov di, 00h
@@begin:	call getChar
			cmp al, 0Dh			; проверяем нажатие клавиши "ВВОД"
			je @@done			; если клавиша нажата, то переходим на конец
; проверка на ввод числа
			cmp al, '0'
			jb @@wrongChr
			cmp al, 'F'
			jbe @@upper
			sub al, 20h			; буквы в нижний регистр
@@upper:	push di
			mov di, offset charsTable
			mov bx, 10h			; кол-во возможных символов для чисел
			mov cx, bx
			repne scasb
			pop di
			jne @@wrongChr
			sub bx, cx
			cmp bx, si
			ja @@wrongChr
			cmp al, '9'
			ja  @@next1
			sub al, '0'				; из кода ASCII получаем цифру
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
@@correct:	xor ah, ah				; теперь значение ах равно значению al
			mov cx, ax				; копируем ах в сх
			mov ax, di				; записываем в ах введенное до текущей цифры число
			mul si					; умножаем его на 10, переходя тем самым в текущий разряд
			add ax, cx				; добавляем к числу текущую цифру
			mov di, ax				; сохраняем текущее число в di
			jmp @@begin				; переходим на обработку следующего разряда
@@done:		mov ax, di				; сохраняем окончательное значение введенного числа в ax
			pop di si dx cx bx
			retn
getNumber	endp

; ---
; Ввод символа с клавиатуры, результат в AL
getChar		proc near
			mov ah, 01h
			int 21h

			retn
getChar		endp

; ---
; Вывод символа на экран, символ в DL
putChar		proc near
			push ax
			mov ah, 02h
			int 21h
			pop ax
			retn
putChar		endp

; ---
; Отобразить символ "закрытия" ячейки таблицы
closeTabRow	proc near
			push ax cx dx
			mov cx, 21
			sub cx, ax
			mov dl, " "
@@nextChar:	call putChar
			loop @@nextChar
			mov dl, "║"
			call putChar
			pop dx cx ax
			retn
closeTabRow endp

; ---
; Удалить на экране последний введенный символ
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
