.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	min db ?
	max db ?

	error_msg db "Some character in the string is not within the specified range.", 0ah, 0dh, '$'
	success_msg db "All characters in a string within the specified range.", 0ah, 0dh, '$'
	error_input_set_msg db "Incorrectly specified range.", 0ah, 0dh, "$"
	
	new_line db 0ah, 0dh, "$"

	buffer db 240
		   db ?
		   db 240 dup (?)

data ends

code segment para public use16
assume cs:code,ds:data,ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
setting_range:
	; вводим диапазон, без enter
	mov ah, 01h	
	int 21h				
	mov byte ptr [min], al
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov ah, 01h
	int 21h
	mov byte ptr [max], al
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dl, byte ptr [max]
	mov al, byte ptr [min]
	cmp dl, al				; max - min, f0 если корректно, f1 если некорректно
	jb error_input_set 		; если max ниже min - ошибка диапазона
	
	; если дошли сюда - диапазон корректный
	
input_str:
	; вводим строчку
	mov dx, offset buffer
	mov ah, 0Ah
	int 21h		
	
	; перенос на новую строчку
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov bx, offset buffer
	mov cx, 0
	mov cl, [bx + 1]		; cx - хранит длину строка
	mov ch, 0

	inc bx					; bx стоит ПЕРЕД 1-ым символом строки
							; cx - по прежнему хранит длину строку
	
checking:	
	; проверка каждого символа
	inc bx
	mov dl, [bx]		; текущий символ
	
	mov al, byte ptr [min]
	cmp dl, al			; dl - al, если > то = f0, если < то f1
	jb error_set		; текущий - min
	
	mov al, byte ptr [max]
	cmp dl, al			; dl - al, если < то = f0, если > то f1
	ja error_set		; текущий - max, 
	
	; если дошли сюда, значит символ в нашем диапазоне
	loop checking		; пока не рассмотрели всю строку, т.е. cx!=0
	
	; если дошли сюда без ошибок - полное попадание в диапазон
	jmp success_set
	
error_input_set:
	mov dx, offset error_input_set_msg
	mov ah, 09h
	int 21h
	 
	; завершение с кодом -1
	mov al, -1
	jmp exit
	
error_set:
	; при первом несовпадении выводить сообщение
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset error_msg
	mov ah, 09h
	int 21h
	
	; завершение с кодом -1
	mov al, -1
	jmp exit
	
success_set:
	; при полном попадании выводить сообщение
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset success_msg
	mov ah, 09h
	int 21h
	
	; завершение с кодом 0
	mov al, 0
	jmp exit
	
exit:
	mov ah, 4ch
	int 21h
	
code ends

end start