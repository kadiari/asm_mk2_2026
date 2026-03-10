.386

stack segment para stack
	db 256 dup (?)
stack ends 

data segment para public
	count_str db 0			; всего 32
	count_col db 0			; всего 8
	num db 0
	
	new_line db 0dh, 0ah, "$"
	alph db "0123456789ABCDEF"

	cup db ":", "$"
	
	bell_str db '\a', '$'
	bs_str   db '\b', '$'		
	tab_str  db '\t', '$'
	lf_str   db '\n', '$'
	vt_str   db '\v', '$'
	ff_str   db '\f', '$'
	cr_str   db '\r', '$'
	
data ends

code segment para public use16
assume cs:code,ds:data,ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
other_strings:
	mov dx, offset new_line
	mov ah, 09h
	int 21h
	
	cmp count_str, 32
	je exit	
	; обнуляем счетчик для колонок
	mov count_col, 0
	
columns:
	; запоминаем символ
	mov al, num
	
	; проверяем на специальные
	cmp al, 07h
	je show_a

	cmp al, 08h
	je show_b

	cmp al, 09h
	je show_tab

	cmp al, 0Ah
	je show_lf

	cmp al, 0Bh
	je show_vt

	cmp al, 0Ch
	je show_ff

	cmp al, 0Dh
	je show_cr


	; если простой символ
	mov dl, al
	mov ah, 02h
	int 21h
	
	; пробел для ширины
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	jmp char_done	
	
	
char_done:
	; двоеточие и пробел
	mov dx, offset cup
	mov ah, 09h
	int 21h
	
	; обработка хекса
	xor ax, ax
	mov al, num
	mov bl, 16
	div bl				; AL - целая часть, AH - остаток

	; запомнили ah
	mov cl, ah
	
	; старшая цифра
	mov si, ax        ; AX после div
	and si, 0Fh       ; оставляем только AL
	mov bx, offset alph
	mov dl, [bx + si] 
	; вывели
	mov ah, 02h
	int 21h

	; младшая цифра   
	movzx si, cl
	mov bx, offset alph
	mov dl, [bx + si] 
	; вывели
	mov ah, 02h
	int 21h
	
	; пробелы
	mov dl, ' '
	mov ah, 02h
	int 21h
	mov dl, ' '
	mov ah, 02h
	int 21h
	
	
	; обработка ветвлений
	inc num					; всегда(!) прибавляется
	inc count_col			; количество элементов в каждой строке
	cmp count_col, 8
	jne columns				; если не дошли до 10 - выводим остальные в строки
							
	inc count_str			; записали +1 строчку, пометили
	jmp other_strings		; иначе переход на след строку
	

show_a:
	mov dx, offset bell_str
	mov ah, 09h
	int 21h
	jmp char_done

show_b:
	mov dx, offset bs_str
	mov ah, 09h
	int 21h
	jmp char_done

show_tab:
	mov dx, offset tab_str
	mov ah, 09h
	int 21h
	jmp char_done

show_lf:
	mov dx, offset lf_str
	mov ah, 09h
	int 21h
	jmp char_done

show_vt:
	mov dx,offset vt_str
	mov ah, 09h
	int 21h
	jmp char_done

show_ff:
	mov dx, offset ff_str
	mov ah, 09h
	int 21h
	jmp char_done

show_cr:
	mov dx, offset cr_str
	mov ah, 09h
	int 21h
	jmp char_done

exit:	
	mov ah, 4ch
	int 21h
	
code ends
end start
