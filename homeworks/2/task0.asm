stack segment para stack
db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public
str db "Hello, asm!",0Dh,0Ah,"$"
data ends

code segment para public

assume cs:code, ds:data, ss:stack
; привязываем сегменты

start:
	; инициализируем сегменты
	mov ax, data
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	mov bx, offset str	; адрес, где начинается наша строчка записываем в bx
	lea bx, [bx + 8]	; хотим считать 8 символ
	
	; меняем его
	mov byte ptr [bx], "u"
	
	; выводим символ, лежащий за ним
	lea bx, [bx + 1]
	mov dl, [bx]
	mov ah, 02h
	int 21h

	; конец
	mov ah, 4ch
	int 21h
	
code ends
end start