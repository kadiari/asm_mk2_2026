stack segment para stack
db 256 dup(?)
stack ends

code segment para public 

assume cs:code, ss:stack

start:
	; инициализируем сегменты
	mov ax, stack
	mov ss, ax
	
	mov ah, 01h		; здесь в al запишется введенный с консоли символ
	int 21h
	mov bl, al		; сохранили
	
	; перенос на новую строку
	mov dl, 0Dh
	mov ah, 02h
	int 21h
	mov dl, 0Ah
	mov ah, 02h
	int 21h
	
	mov dl, bl		; поместили в dl для вывода в консоль
	mov ah, 02h		; вывели в консоль
	int 21h
	
	mov ah, 4ch		; конец
	int 21h
	
code ends
end start