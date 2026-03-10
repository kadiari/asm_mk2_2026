.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	input_string db "[Enter symbol (or press 'ENTER' to exit)] ", 0dh, 0ah, "$"
	string db "Try find symbol!", 0dh, 0ah, "$"
	
	src_string db "Try find symbol!"
	new_line db 0dh, 0ah, "$"
	
	success_str db " - Found!", 0dh, 0ah, "$"
	error_str db " - Not Found!", 0dh, 0ah, "$"
	
	src_len dw ?
	reserved db 256 dup (?)
	
	count_requests db 0
	count_enters db 0
	
data ends

code segment para public use16
assume cs:code,ds:data,ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	mov byte ptr [count_requests], 0
	mov byte ptr [count_enters], 0
	nop

input_loop:	
	; проверка на вывод исходной строки каждые 5 запросов
	cmp byte ptr [count_requests], 5
	jne not_five_input

	; если достигли 5 запроса
	; вывод строки
	mov dx, offset string
	mov ah, 09h
	int 21h
	
	mov byte ptr [count_requests], 0
	
not_five_input:
	; вывод приглашения
	mov dx, offset input_string
	mov ah, 09h
	int 21h

	mov ah, 01h					 ; считываем символ
	int 21h
	
	; проверка на ввод пустого символа (1 или 2 раза)
	cmp al, 0Dh          		 ; 0Dh = 13 = код Enter
	jne not_enter
	
	inc byte ptr [count_enters]
	cmp byte ptr [count_enters], 2
	je exit
	
	; если enter введён 1-ый раз
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	inc byte ptr [count_requests]
	jmp input_loop
	
not_enter:
	; сбрасываем счётчик
	mov byte ptr [count_enters], 0
	
	; запоминаем введённый символ
	mov byte ptr [reserved], al

	mov dx, offset new_line		; перенос на новую строчку
	mov ah, 09h
	int 21h
	
	mov al, byte ptr [reserved]
	mov cx, offset new_line
	mov bx, offset src_string
	sub cx, bx					; cx = длина строки
	mov word ptr [src_len], cx
	
	dec bx		; перед циклом заходим за начало строки

search:
	inc bx		; интерация по символам строки
	cmp al, byte ptr [bx]
	loopne search			
		; cx--; завершение цикла, если cx == 0 или al == byte ptr [bx] (ZF==1)
	
	je found
	
	mov dl, byte ptr [reserved]
	mov ah, 02h
	int 21h
	mov dx, offset error_str
	jmp print
	
found:
	mov dl, byte ptr [reserved]
	mov ah, 02h
	int 21h
	mov dx, offset success_str
	
print:
	mov ah, 09h
	int 21h
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	inc byte ptr [count_requests]
	jmp input_loop
	
exit:
	mov ax, 4c00h
	int 21h
	
code ends

end start