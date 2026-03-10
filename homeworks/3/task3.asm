stack segment para stack
db 256 dup(?)
stack ends

data segment para public	
	x dw 50
	y dw 20
	res_z dw ?
	
	a dw 3
	b dw 6
	res_c1 dw ?
	res_c2 dw ?

data ends

code segment para public 

assume cs:code,ds:data,ss:stack

start:
	mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax
	
	; z = (x * y) / (x + y)
	mov ax, [x]
	mov bx, [y]
	imul bx
	mov [res_z], ax
	
	mov ax, [x]
	mov bx, [y]
	add bx, ax			; в bx лежит сумма
	
	mov ax, [res_z]		; в ax лежит произведение
	idiv bx				; ax = 14, dx(остаток) = 20 
	mov [res_z], ax
	
	; с = (a + b)^2
	mov ax, [a]
	mov bx, [b]
	add ax, bx			; в ax лежит сумма
	imul ax				; в ax лежит произведение
	mov [res_c1], ax
	
	; c = (a + b)^3
	mov ax, [a]
	mov bx, [b]
	add ax, bx				; в ax лежит сумма		
	mov cx, ax				; запомнили сумму в cx
	imul ax
	imul cx
	mov [res_c2], ax
	
	
code ends
end start	

	
	