.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	min db ?
	max db ?

	error_msg db "Some character in the string is not within the specified range: ", 0ah, 0dh, "$"
	success_msg db "All characters in a string within the specified range.", "$"
	error_input_set_msg db "Incorrectly specified range.", 0ah, 0dh, "$"
	
	new_line db 0ah, 0dh, "$"

	buffer db 240
		   db ?
		   db 240 dup (?)
		   
	incorrect db 100 dup (0)	; [индекс1][символ1][индекс2][символ2]...
	count_incorrect db 0		; счетчик несовпадений
	cup_err db "[", 2 dup (?), " - ", ?, "]", "$"

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
	mov cl, [bx + 1]		; cx - хранит длину строки
	mov ch, 0

	inc bx					; bx стоит ПЕРЕД 1-ым символом строки
							; cx - по прежнему хранит длину строку
	
checking:
	; проверка каждого символа
	inc bx
	mov dl, [bx]		; текущий символ
	
	; отбиваемся от enter
	cmp dl, 0dh
	je finish_check
	
	
	; MIN-граница
	mov al, byte ptr [min]
	cmp dl, al			; dl - al, если > то = f0, если < то f1	
	jb mismatches
	
	; MAX-граница
	mov al, byte ptr [max]
	cmp dl, al			; dl - al, если < то = f0, если > то f1
	ja mismatches

	; если дошли сюда - символ в диапазоне
	dec cx
    jnz checking
	jmp finish_check
	
	
mismatches:
	; обработка несовпадений
	mov bp, bx					; сохранили 
	
	; вычисление позиции записи
	mov al, count_incorrect		; количество несовпадений
	xor ah, ah
	shl ax, 1					; умножили счётчик на 2 = "начало новой записи"
	
	; ax - начало новой записи
	
	; вычисление индекса
	mov di, offset buffer
	lea di, [di + 2]			; di хранит АДРЕС начала строки, bp - адрес текущего символа
	sub bp, di					
	inc bp						; bp = индекс текущего = чиселко
	
	; адрес для записи
	mov di, offset incorrect
	add di, ax					; di хранит адрес для записи
	 
	mov ax, bp
	; запись индекса
	mov [di], al 				; индекс для читабельности
	
	; запись символа
	xor ax, ax
	mov al, [bx]
	mov [di + 1], al 			; текущий символ из dl

	inc byte ptr [count_incorrect]	; только сейчас после добавления в массив
	dec cx	;;;!!!!
	;; проверка на остановку при cx=0
	jnz checking					; и снова отправились обрабатывать след символ
	jmp finish_check
	
finish_check:
	cmp byte ptr [count_incorrect], 0
	je success_set
	jmp error_set
	
error_input_set:
	mov dx, offset error_input_set_msg
	mov ah, 09h
	int 21h
	 
	; завершение с кодом -1
	mov al, -1
	jmp exit
	
error_set:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	mov dx, offset error_msg
	mov ah, 09h
	int 21h
	
	xor cx, cx
	mov cl, [count_incorrect]	; cx = количество пар(ошибок)
	xor ch, ch
	xor si, si					; смещение по incorrect
	
print_mismatches:

    mov di, offset incorrect
    add di, si

    mov al, [di]        		; индекс
	xor ah, ah
	mov bl, 10
	div bl              		; AL = десятки, AH = единицы

	add al, '0'
	mov [cup_err + 1], al  		; десятки
	
	mov al, ah
	add al, '0'
	mov [cup_err + 2], al   	; единицы	

    mov al, [di+1]
    mov [cup_err + 6], al

    mov dx, offset cup_err
    mov ah, 09h
    int 21h

	mov dl, ','
	mov ah, 02h
	int 21h

    add si, 2
    loop print_mismatches		; до тех пор, пока cx!=0
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