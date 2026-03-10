.386

stack segment para stack
	db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public

	buffer db 240, ?, 240 dup(?)
	reverse_msg db "a)Reverse line output:", 0dh, 0ah, "$"
	cycle_msg db "b)Output n times in a cycle", 0dh, 0ah, "$"
	new_line db 0dh, 0ah, "$"
	
	count_n db 4

data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

start:
	; инициализируем сегменты
	mov ax, data	
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; вводим строчку
	mov dx, offset buffer
	mov ah, 0Ah
	int 21h
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	; еще перенос для читабельности
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	; а) вывод строки в обратном порядке
	mov dx, offset reverse_msg
	mov ah, 09h
	int 21h
	
	mov bx, offset buffer	; адрес начала буффера
	inc bx					; адрес 1-го индекса, хранит реальную длину строки
	
	mov cx, 0			
	mov cl, [bx]			; в cl записали реальную длину строки
	
	add bx, cx				; bx = адрес последнего символа строки
							; cx = количество символов в строке
	;;
	inc bx
	jmp reverse_print
	
reverse_print:
	dec bx
	
	mov dl, byte ptr[bx]
	mov ah, 02h
	int 21h
	
	dec cx
	jnz reverse_print
	
	
	; после вывода пункта а) переходим в пункту b)
	
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	jmp cycle_print
	
cycle_print:
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset cycle_msg
	mov ah, 09h
	int 21h

	; подготовка к выводу строки
	mov bx, offset buffer
	inc bx					; bx - адрес ячейки, хранящей длину строку
	
	mov cx, 0
	mov cl, [bx]			; cx - хранит длину строки
	add bx, cx				; bx - адрес последнего символа строки
	mov byte ptr [bx + 1], "$"
	
	mov cl, [count_n]
	
	jmp repeat_print
	
repeat_print:
	
	mov bx, offset buffer		
	lea dx, [bx + 2]			; dx - адрес начала строки
	mov ah, 09h	
	int 21h
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	dec cx
	jnz repeat_print
	
	; завершение
	mov ah, 4ch
	int 21h
	
code ends
end start
