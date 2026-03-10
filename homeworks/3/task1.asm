stack segment para stack
db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public
	array_string db 240, ?, 240 dup(?)
			  	 db 240, ?, 240 dup(?)
			  	 db 240, ?, 240 dup(?)
data ends

code segment para public

assume cs:code, ds:data, ss:stack

start:
	mov ax, data	
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; ВВОД 1-ОЙ СТРОЧКИ
	mov dx, offset array_string
	mov ah, 0Ah
	int 21h
	
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	mov bx, offset array_string		; адрес начала буффера
	lea bx, [bx + 1]				; адрес 1-го индекса, хранит реальную длину строки
	mov cx, 0
	mov cl, [bx]					; cl = число = длина строка
	add bx, cx						; теперь bx адрес последнего символа
	mov byte ptr [bx + 1], "$"
	
	; ВВОД 2-ОЙ СТРОЧКИ
	mov bx, offset array_string
	lea bx, [bx + 242]				; адрес начала 2-го блока (2 строка)
	mov dx, bx	
	mov ah, 0Ah
	int 21h

	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	mov bx, offset array_string	;
	lea bx, [bx + 242]			; адрес начала 2-го блока (2 строка)
	lea bx, [bx + 1]			; адрес, хранящий реальную длину строки
	mov cx, 0
	mov cl, [bx]				; cl = число = длина строка	
	add bx, cx			
	mov byte ptr [bx + 1], "$"	; записали
	
	; ВВОД 3-ЕЙ СТРОЧКИ
	mov bx, offset array_string
	lea bx, [bx + 484]			; адрес начала 3-го блока (3 строка)
	mov dx, bx	
	mov ah, 0Ah
	int 21h

	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	mov bx, offset array_string	;
	lea bx, [bx + 484]			; адрес начала 3-го блока (3 строка)
	lea bx, [bx + 1]			; адрес, хранящий реальную длину строки
	mov cx, 0
	mov cl, [bx]				; cl = число = длина строка	
	add bx, cx			
	mov byte ptr [bx + 1], "$"	; записали
	
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	; ВЫВОД 1-ОЙ СТРОКИ
	mov bx, offset array_string
	lea dx, [bx + 2]		; начало 1-ой строчки 
	mov ah, 09h
	int 21h
	
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	; ВЫВОД 2-ОЙ СТРОКИ
	mov bx, offset array_string
	lea dx, [bx + 244]
	mov ah, 09h
	int 21h
	
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h	
	
	; ВЫВОД 3-ЕЙ СТРОКИ
	mov bx, offset array_string
	lea dx, [bx + 486]
	mov ah, 09h
	int 21h
	
	mov ah, 4ch
	int 21h
	
code ends
end start
