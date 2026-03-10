stack segment para stack
db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public
buffer db 240, ?, 240 dup(?)
data ends

code segment para public

assume cs:code, ds:data, ss:stack

start:
	mov ax, data	
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; вводим строчку
	mov dx, offset buffer
	mov ah, 0Ah
	int 21h
	
	; перенос на новую строчку
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h
	
	mov bx, offset buffer	; адрес начала буффера
	lea bx, [bx + 1]		; адрес 1-го индекса, хранит реальную длину строки
	
	mov cx, 0
	mov cl, [bx]			; сохраняем 1-байтное число = кол-во символов в строке
							; cl = число = длина строка
	
	add bx, cx				; теперь bx адрес последнего символа
	mov byte ptr [bx + 1], "$"
	sub bx, cx
	
	lea bx, [bx + 1]		; адрес 2-го индекса, истинное начало строчки 
	mov dx, bx
	mov ah, 09h
	int 21h
	
	mov ah, 4ch
	int 21h
	
code ends
end start
