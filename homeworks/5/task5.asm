.386

stack segment para stack
db 256 dup (?)
stack ends 

data segment para public
	num dw 4096					; 2-байтовое число
	hex_str db 4 dup(?), "$"
data ends

code segment para public use16
assume cs:code, ds:data, ss:stack

start:
	; инициализация сегментных регистров
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

	mov ax, num			; сохранили число
	mov cx, 4			; итераций по нашему числу (для loop)
	mov di, 0			; итераций по хекс строке
	
next_dig:
	rol ax, 4
	mov bx, ax			; сохранили копию

	and bx, 000Fh		; получим младшие 4 бита
	cmp bx, 10			; обрабатываем
	jb below_num
	
	; вывод
	add bx, 'A'
	sub bx, 10
	jmp insert_hexstr
	
below_num:
	add bx, '0'
	
insert_hexstr:
	; записали в строку
	mov dl, bl
	mov [hex_str + di], dl
	inc di

	; переход к следующей цифре
	loop next_dig
	
	mov dx, offset hex_str
	mov ah, 09h
	int 21h
	
exit:
	mov ah, 4ch
	int 21h
	
	
code ends
end start