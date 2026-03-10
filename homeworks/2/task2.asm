stack segment para stack
db 256 dup(?) 	; выделяем память под стек
stack ends

data segment para public
str db "Testing the output of a line in task#2",0Dh,0Ah,"$"
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
	
	mov dx, offset str	; помещаем в dx - адрес начала строки из сегмента данных
	mov ah, 09h			; вызов выдачи строки
	int 21h
	
	mov ah, 4ch
	int 21h

code ends
end start