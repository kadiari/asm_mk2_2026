.386

stack segment para stack
	db 256 dup (?)
stack ends 

data segment para public
	mode db 0
	new_line db 0ah, 0dh, "$"
	num db 0
	count_str db 0
	count_col db 0
data ends

code segment para public use16
assume cs:code,ds:data,ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	; mode = 0 выравнивание по левому краю
	; mode = 1 выравнивание по правому краю
	
first_string:
	cmp mode, 0
	je left_shift		
	
	; иначе по правому краю
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	mov dl, num
	add dl, '0'
	mov ah, 02h
	int 21h
	
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	inc num
	cmp num, 10
	jne first_string
	
	;иначе переход на новую строчку
	inc count_str
	jmp other_strings


left_shift:
	; по левому краю
	mov dl, num
	add dl, '0'
	mov ah, 02h
	int 21h
	
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	inc num
	cmp num, 10
	jne first_string
	
	;иначе переход на новую строчку
	inc count_str
	jmp other_strings
	
other_strings:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	cmp count_str, 10
	je shift_mode
	
	; обнуляем счетчик для колонок
	mov count_col, 0
	
columns:
	mov al, num
	xor ah, ah
	mov bl, 10
	div bl				; AL - десятки, AH - единицы(остаток)
	
	; запомним ah и al
	mov dl, al			; dl - десятки
	mov bl, ah			; bl - единицы (остаток)
	
	; обработка десятков
	add dl, '0'
	mov ah, 02h
	int 21h
	
	; обработка единиц
	mov dl, bl
	add dl, '0'
	mov ah, 02h
	int 21h
	
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	inc num					; всегда прибавляется
	inc count_col			; количество элементов в каждой строке
	cmp count_col, 10
	jne columns				; если не дошли до 10 - выводим остальные в строки
							
	inc count_str			; записали +1 строчку, пометили
	jmp other_strings		; иначе переход на след строку
	
	
shift_mode:
	cmp mode, 1				; если мы уже вывели и по правому краю, то выход
	je exit
	
	; перенос для читабельности
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov mode, 1
	mov num, 0
	mov count_str, 0
	mov count_col, 0
	jmp first_string
	
exit:	
	mov ah, 4ch
	int 21h

	
code ends
end start
	