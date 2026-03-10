stack segment para stack
db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public
	buffer db 240 dup(?)
data ends

code segment para public

assume cs:code, ds:data, ss:stack

start:
	mov ax, data	
	mov ds, ax
	mov ax, stack
	mov ss, ax
	
	; вводим строчку
	; ЧТЕНИЕ из файла(=консоль) в наш буфер
	mov dx, offset buffer
	mov bx, 0			; дескриптор для чтения из стандартного ввода
	mov cx, 240			; макс. кол-во считываемых символов
	mov ah, 3fH			; считываем через фс DOS строчку из консоли
	int 21h
	
	mov cx, ax 			; число действительно прочитанных байт
	
	; ЗАПИСЬ в файл(=консоль) из буфера
	mov dx, offset buffer	; адрес начала буффера
	mov bx, 1				; дескриптор для записи в стандартный вывод
	mov ah, 40H				; считает ровно (=cx) байтов 
	int 21h
	
	mov ah, 4ch
	int 21h
	
code ends
end start
