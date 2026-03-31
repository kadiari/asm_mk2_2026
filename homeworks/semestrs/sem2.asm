.386

arg1 equ 4
arg2 equ 6
arg3 equ 8
arg4 equ 10

max_len equ 20

var1 equ -2
var2 equ -4
var3 equ -6
var4 equ -8

ERR_DIV_ZERO    equ 1
ERR_OVERFLOW    equ 2
ERR_FORMAT		equ 3

stack segment para stack
db 65530 dup(?)
stack ends

data segment para public
	str1 db 256 dup(?)
	input_str db 20 dup(?)
	
	welcome_base_msg db 0Dh, 0Ah, "Enter notation (h | d): ", 0
	welcome_msg db 0Dh, 0Ah, "Enter expression (10 + 17): ", 0
	result_dec_msg db 0Dh, 0Ah, "Result (dec): ", 0
	result_hex_msg db 0Dh, 0Ah, "Result (hex): 0x", 0
	
	error_msg_format db 0Dh, 0Ah, "Incorrect expression format!", 0
	error_msg_div_0 db 0Dh, 0Ah, "Division by zero error!", 0
	error_msg_overflow db 0Dh, 0Ah, "There was an overflow!", 0

	base db ?
	operator db ?
	res_str db 6 dup(?)		
	res_str_dw db 20 dup(?)
	
data ends

code segment para public use16
assume cs:code,ds:data,ss:stack

; void putchar(int c)
; displays a character on the screen (the low byte of the passed argument)
_putchar:
    push bp
    mov bp, sp
    
    mov dx, word ptr [bp + arg1]
    mov ah, 02h
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
; int getchar()
; reads a character from the keyboard and returns it (the character read is the ax)
_getchar:
    push bp
    mov bp, sp
    
    mov ah, 01h
    int 21h
    
    mov sp, bp
    pop bp
    ret
	
; function for determining the correctness of the SS
_notation:
	push bp
    mov bp, sp
    
    push cx
	xor cx, cx
	mov cl, byte ptr [bp + arg1]
	cmp cl, 'h'
	je save_ok
	cmp cl, 'd'
	je save_ok
	
error_notation:
	stc
	mov ah, 3
	jmp end_notation
	
save_ok:
	mov byte ptr [base], cl
	clc
	
end_notation:
	pop cx
    mov sp, bp
    pop bp
    ret
	

; int strlen(const char *str)
; finds the length of the string (up to the terminating null) whose address is the argument
_strlen: 
    push bp
    mov bp, sp
    
    mov bx, word ptr [bp + arg1] 
    xor ax, ax 						; counter (ax)

lencyc:    
    cmp byte ptr [bx], 0
    je lenret
    inc ax
    inc bx
    jmp lencyc
    
lenret:    
    mov sp, bp
    pop bp
    ret	
    
; void putstr(const char *str)
; prints a string to the screen (until the terminating null) whose address is passed as an argument
_putstr: 
    push bp
    mov bp, sp
    
    push word ptr [bp + arg1] 
    call _strlen
    add sp, 2				
    
    mov cx, ax
    mov dx, word ptr [bp + arg1]
    mov ah, 40h
    mov bx, 1
    int 21h
    
    mov sp, bp
    pop bp
    ret
    
; void getstr(const char *str, int max_len)
; reads, stores (either max_len or until line feed)
; adds a final 0
_getstr:
    push bp
    mov bp, sp
    
    ; read string
    mov cx, word ptr [bp + arg2]
    mov dx, word ptr [bp + arg1]
    mov ah, 3fh
    mov bx, 0
    int 21h
    
    ; adds a final 0
    mov bx, word ptr [bp + arg1]
    add bx, ax 		
    sub bx, 2 			
    mov byte ptr [bx], 0

    mov sp, bp
    pop bp
    ret

	
; void putnewline()
_putnewline:
    push bp
    mov bp, sp
    
    mov dx, 10
    push dx
    call _putchar
    add sp, 2
    
    mov dx, 13
    push dx
    call _putchar
    add sp, 2
    
    mov sp, bp
    pop bp
    ret

; void exit(int code)
; terminates the program with the code passed as an argument
_exit:
    push bp
    mov bp, sp
    
    mov ax, word ptr [bp + arg1]
    mov ah, 4ch
	int 21h
    
    mov sp, bp
    pop bp
    ret
  
; void exit0()
_exit0:
    push bp
    mov bp, sp
    
    mov dx, 0
    push dx
    call _exit
    add sp, 2
    
    mov sp, bp
    pop bp
    ret
    

; int atoi_hex(const char *str)
; string to number conversion function
_atoi_hex:
	push bp
    mov bp, sp
	
    push bx
    push cx
    push si					 ; flag for a sign

    mov bx, [bp + arg1]
    xor ax, ax       		 ; result
    xor si, si       		 ; 0 = +, 1 = -

    ; sign check
    cmp byte ptr [bx], '-'
    jne hex_iter
	
    mov si, 1				; negative number flag
    inc bx					; moved to "numbers"

hex_iter:
    cmp byte ptr [bx], ' '
    je hex_end
    cmp byte ptr [bx], 0
    je hex_end

	; get a number
	xor cx, cx
    mov cl, byte ptr [bx]

    ; define it
    cmp cl, '0'
    jb hex_error
    cmp cl, '9'
    jbe digit_09

    cmp cl, 'A'
    jb hex_error
    cmp cl, 'F'
    jbe digit_AF

    jmp hex_error

digit_09:
    sub cl, '0'
    jmp apply_digit

digit_AF:
    sub cl, 'A'
    add cl, 10
    jmp apply_digit

apply_digit:
	; overflow check BEFORE multiplication
	cmp si, 0
	jne check_neg_hex
	
check_pos_hex:
	cmp ax,  2048				; 32768 / 16 = 2048
	jae overflow_common_hex		; if ax>=2048 overflow
								
    jmp safe_mul_hex     	    

check_neg_hex:
	cmp ax, 2048
    ja overflow_common_hex     
    jb safe_mul_hex

    ; ax == 2048
    cmp cl, 0
    ja overflow_common_hex

safe_mul_hex:
    ; result = result * 16 + digit
    shl ax, 4
	xor ch, ch
    add ax, cx

    inc bx
    jmp hex_iter

overflow_common_hex:
	stc
	jmp hex_ret
	
hex_end:
    cmp si, 0
    je hex_success
    neg ax

hex_success:
    clc
    jmp hex_ret

hex_error:
    stc
    mov ah, 2			; overflow

hex_ret:
    pop si
    pop cx
    pop bx
    mov sp, bp
    pop bp
    ret
	
	
; int atoi(const char *str)
; string to number conversion function
_atoi: 
    push bp
    mov bp, sp
	
    push cx
    push si					; flag for a sign
    push bx
	
    mov bx, [bp + arg1]
    xor ax, ax      		; result
    xor cx, cx
    xor si, si        		; 0 = +, 1 = -

    ; minus check
    cmp byte ptr [bx], '-'
    jne _iteration
	
    mov si, 1				; negative number flag
    inc bx					; moved to numbers

_iteration:
    cmp byte ptr [bx], ' '
    je atoi_end
	
    cmp byte ptr [bx], 0
    je atoi_end

    ; get number
    xor cx, cx
    mov cl, byte ptr [bx]
    sub cl, '0'

    ; overflow check BEFORE multiplication 
    cmp si, 0
    jne check_neg

; = positive
check_pos:
    cmp ax, 3276				; maximum for consideration
    ja overflow_common			; if strictly greater - overflow

    jne safe_mul				; if strictly less, we safely multiply

    cmp cl, 7
    ja overflow_common			; if more - overflow
    jmp safe_mul				; otherwise, we multiply safely

; = negative
check_neg:
    cmp ax, 3276
    ja overflow_common			; similarly

    jne safe_mul

    ; ax == 3276 , check number
    cmp cl, 8
    ja overflow_common

safe_mul:
    imul ax, 10
    add ax, cx          	   ; + number

    inc bx				       ; iterate further by number
    jmp _iteration

; = 
overflow_common:
    stc
	jmp atoi_ret

atoi_end:
	cmp si, 0
	je success
	neg ax
success:
	clc				; if everything is good, the number is in ax
	jmp atoi_ret
	
atoi_ret:
	pop bx
	pop si
	pop cx
	mov sp, bp
	pop bp
	ret


; void itoa16_hex(int num, char * str)
; function to convert a number ax to a hex string
_itoa16_hex:
	push bp
	mov bp, sp
	
	push si
	
	mov ax, [bp + arg1]			; AX
	mov si, [bp + arg2]			; start of buffer


	; number
	push ax
	push si						; changed 
	call word_to_hex
	
	add si, 4
	mov byte ptr [si], 0
	
	pop si
	mov sp, bp
	pop bp
	ret

	
; void itoa32_hex(int num1, int num2, char * str)
; function to convert the number dx:ax to a hex string
_itoa32_hex:
	push bp
	mov bp, sp
	
	push si
	
	mov ax, [bp + arg1]			; AX
	mov dx, [bp + arg2]			; DX
	mov si, [bp + arg3]			; start of buffer

	; first number
	push ax 					
	
	; senior word
	push dx
	push si
	call word_to_hex
	add sp, 4
	
	add si, 4					; on the next word
	
	; second number
	pop ax
	push ax
	push si						; changed 
	call word_to_hex
	add sp, 4
	
	add si, 4					
	
	mov byte ptr [si], 0
	pop si
	mov sp, bp
	pop bp
	ret

; void word_to_hex(char *buffer, int num);
; convert a word number to hex
word_to_hex:
	push bp
	mov bp, sp

	push cx
	push bx
	push si
	
	mov si, [bp + arg1]	; start for recording
	mov ax, [bp + arg2]	; number
	mov cx, 4			

next_dig:
	rol ax, 4
	
	mov bx, ax			
	and bx, 000Fh		
	
	cmp bl, 10
	jb below_num
	 
	add bl, 'A' - 10
	jmp after_convert
	
below_num:
	add bl, '0'

after_convert:
	mov byte ptr [si], bl
	inc si

	loop next_dig	
	
	pop si
	pop bx
	pop cx
	mov sp, bp
	pop bp
	ret


; void itoa(int num, char *str)
; function to convert a number to a string
_itoa: 
    push bp
    mov bp, sp
	
	push si
	push di
	push cx
	push dx
	
	mov ax, [bp + arg1]		; remembered the number
	mov bx, [bp + arg2]		; remembered the pointer to the buffer for writing
	
	xor di, di 				; 0=positive
	cmp ax, 0
	jge not_negative
	
	mov di, 1
	neg ax					; take the flag into account and make the number positive
	
not_negative: 
	cmp ax, 0
	jne not_zero
	mov byte ptr [bx], '0'
	mov byte ptr [bx + 1], 0
	jmp itoa_end
	
not_zero:
	mov si, bx				; buffer start address
	add si, 6				; saved to the end
	mov byte ptr [si], 0	; recorded the zero terminator

convert_cycle:
	xor dx, dx
	xor cx, cx
	mov cx, 10
	div cx	
	add dl, '0'
	
	dec si
	mov byte ptr [si], dl
	
	cmp ax, 0
	jne convert_cycle
	
	; recorded the zero terminator
	cmp di, 0
	je help_copy
	
	dec si
	mov byte ptr[si], '-'
	
help_copy:
	cmp si, bx
	je itoa_end
	
copy_string:
	mov cl, byte ptr [si]
	mov byte ptr [bx], cl
	inc bx
	inc si
	
	; we write the null terminator and exit
	cmp byte ptr [si], 0
	jne copy_string
	mov byte ptr [bx], 0
	
itoa_end:
	pop dx
	pop cx
	pop di
	pop si
    mov sp, bp
    pop bp
    ret

	
; void itoa32(int num, char *str)
; function to convert a number from dx:ax to a string
_itoa32:
	push bp
	mov bp, sp
	
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	
	mov ax, [bp + arg1]		; remembered ax
	mov dx, [bp + arg2]		; remembered dx
	mov di, [bp + arg3]		; address of the beginning of the line to write
	
	cmp ax, 0
	jne not_zero32
	cmp dx, 0
	jne not_zero32
	
	mov byte ptr [di], '0'
	mov byte ptr [di + 1], 0
	jmp end_itoa32
	
not_zero32:
	xor cx, cx				; flag for a sign
	test dx, 8000h			; check the sign
	jz itoa_pos				; if 0 = positive
	
	; transform into a positive number
	not ax
	not dx
	add ax, 1
	adc dx, 0
	mov cx, 1				; flag for a negative number

itoa_pos:
	push cx
	push di
	
	add di, 12
	mov byte ptr [di], 0	; the pointer is at the end of the buffer
	dec di					; last digit pointer
	
itoa_divide:
	push di
	
	xor si, si              ; SI = remainder
	mov cx, 32				; loop counter
	
	; let's save the dividend in temporary registers
	mov di, ax				; DI = younger part
	mov bx, dx				; BX = senior part (temporary)
	
	; collect the private parts back here
	xor ax, ax
	xor dx, dx
	
itoa_div_loop:
	shl di, 1				; shift of the minor part
	rcl bx, 1				; shift of the major part with carry
	
	rcl si, 1				; added a bit to the remainder
	
	cmp si, 10
	jb below_10
	
	sub si, 10		
	
	; we write 1 in the quotient
    shl ax, 1
    rcl dx, 1
    or ax, 1
    jmp next_bit
	
below_10: 				
	; we write 0 in the quotient
    shl ax, 1
    rcl dx, 1
	
next_bit:
	loop itoa_div_loop
	; remainder in SI
	
	mov cx, si				; balance in CX
	pop di
	
	add cl, '0'
	dec di
	mov byte ptr [di], cl
	
	; check the quotient (it's in dx:ax)
    or dx, dx
    jnz itoa_divide
    or ax, ax
    jnz itoa_divide
	
	; sign
	pop si					; start of buffer
	pop cx					; flag
	
	cmp cx, 1
	jne copy_str_32
	
	dec di
	mov byte ptr [di], '-'
	
copy_str_32:	
	xor bx, bx
	mov bl, byte ptr [di]
	mov byte ptr [si], bl
	inc si
	inc di
	
	cmp byte ptr [di], 0
	jne copy_str_32

	mov byte ptr [si], 0

end_itoa32:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	
	mov sp, bp
	pop bp
	ret
	

; void convert(const char *input_line)
; function for taking numbers and an operand from a checked string
_convert:
	; ax = first number
	; dx = second number
	; bl = operator
	; cf = error
	
	push bp
	mov bp, sp
	
	push si
	push cx
	
	mov si, [bp + arg1]				

	
	; 1 number
	push si
	
	cmp [base], 'd'
	je use1_atoi_10
	
use1_atoi_16:
	call _atoi_hex					; ax contains the 1st number
	jmp after_atoi
	
use1_atoi_10:
	call _atoi						
	
after_atoi:
	jc convert_error
	add sp, 2
	
	mov si, [bp + arg1]
	mov cx, ax						; saved in the temporary register
	jmp check_space_1
	
check_space_1:
	cmp byte ptr[si], ' '
	je found_space_1
	inc si
	jmp check_space_1
	
found_space_1:
	inc si							; sign
	mov bl, byte ptr [si]			; wrote the operand to bl
	inc si							; space
	inc si							; the beginning of a new number
	
	; second number
	push si
	
	cmp [base], 'd'
	je use2_atoi_10
	
use2_atoi_16:
	call _atoi_hex
	jmp after_atoi2

use2_atoi_10:
	call _atoi
	
after_atoi2:
	jc convert_error
	add sp, 2						; ax contains the 2nd number
	
	mov dx, ax						; 2 number was written in ax
	mov ax, cx						; 1 number was written in ax
	jmp convert_end

convert_end:
	pop cx
	pop si
	mov sp, bp
    pop bp 
	clc
	ret

convert_error:
	pop cx
	pop si
	mov sp, bp
    pop bp
	mov ah, 2	
	xor al, al
	stc
	ret
	

; int _check_hex(const char *input_line)
; function for checking the format of a string with hex numbers
_check_hex:
	push bp
	mov bp, sp
		
	push bx
	push cx
	push si
	  
	mov si, [bp + arg1]       
	  
	; check 1 number
	push si
	call check_number_hex  
	jc _check_fail32 
	add sp, 2
	  
	; chech space
	cmp byte ptr [si], ' '
	jne _check_fail32
	inc si

	; check sign
	cmp byte ptr [si], '+'
	je check_sign32
	cmp byte ptr [si], '-'
	je check_sign32
	cmp byte ptr [si], '*'
	je check_sign32
	cmp byte ptr [si], '/'
	je check_sign32
	cmp byte ptr [si], '%'
	je check_sign32

	; otherwise, if the sign is incorrect
	jmp _check_fail32
	
check_sign32:
	inc si							; transition to the symbol AFTER the sign

	; check space
	cmp byte ptr [si], ' '
	jne _check_fail32
	inc si							; move to character AFTER space
	
	; check 2 number
	push si
	call check_number_hex
	jc _check_fail32				
	add sp, 2
	
	; checking for end of line after 2nd number
	cmp byte ptr [si], 0
	jne _check_fail32
	
	; otherwise we were satisfied with everything
	pop si
	pop cx
	pop bx
    mov sp, bp
    pop bp
	clc
    ret			
	
; helper function for checking a number in hexadecimal system
; int check_number_hex(const char *str)
check_number_hex:
	push bp
	mov bp, sp
	
	push cx
	
	mov si, [bp + arg1]
	xor cx, cx				; digit counter
	
	; checking for a negative number
	cmp byte ptr [si], '-'
	jne cycle_number_hex
	inc si
	
cycle_number_hex:
	cmp byte ptr [si], ' '
	je check_number_hex_end
	cmp byte ptr [si], 0
	je check_number_hex_end
	
	cmp byte ptr [si], '0'
	jb check_hex_error	
	cmp byte ptr [si], '9'
	jbe next_hex_num
	
	cmp byte ptr [si], 'A'
	jb check_hex_error	
	cmp byte ptr [si], 'F'
	jbe next_hex_num 
	
	jmp check_hex_error
	
next_hex_num:
	; counted the number
	inc cx
	inc si
	jmp cycle_number_hex
	
check_number_hex_end:
	cmp cx, 0			; no numbers were counted
	je check_hex_error	
	
	clc					; successful formatting
	pop cx
	mov sp, bp
    pop bp
	ret					; return to check_hex
	
check_hex_error:
	stc					; formatting error - sets a flag
	pop cx
	mov sp, bp
    pop bp
	ret					; return to check_hex
	
; puts an error
_check_fail32:
	pop si
	pop cx
	pop bx
    mov sp, bp
    pop bp
	mov ah, 3
	xor al, al
	stc
    ret					; return to main
	

; int check(const char *input_line)    
; function for checking the entered string for compliance with the format
_check: 
    push bp
    mov bp, sp
	
	push bx
	push cx
	push si
	
	mov si, [bp + arg1] 
	
	; check 1 number
	push si
	call check_number	
    jc _check_fail16	
	add sp, 2
	
	; check space
	cmp byte ptr [si], ' '
	jne _check_fail16
	inc si
	
	; check sign
	cmp byte ptr [si], '+'
	je check_sign
	cmp byte ptr [si], '-'
	je check_sign
	cmp byte ptr [si], '*'
	je check_sign
	cmp byte ptr [si], '/'
	je check_sign
	cmp byte ptr [si], '%'
	je check_sign
	
	; otherwise, if the sign is incorrect
	jmp _check_fail16

check_sign:
	inc si							; transition to the symbol AFTER the sign

	; check space
	cmp byte ptr [si], ' '
	jne _check_fail16
	inc si							; move to character AFTER space
	
	; check 2 number
	push si
	call check_number
	jc _check_fail16				; if error
	add sp, 2
	
	; checking for end of line after 2nd number
	cmp byte ptr [si], 0
	jne _check_fail16
	
	; otherwise we were satisfied with everything
	pop si
	pop cx
	pop bx
    mov sp, bp
    pop bp
	clc
    ret			; return to main
	
; helper function for checking a number
; int check_number(const char *str)
check_number:
	push bp
	mov bp, sp
	
	push cx
	
	mov si, [bp + arg1]
	xor cx, cx				; count numbers
	
	; checking for a negative number
	cmp byte ptr [si], '-'
	jne cycle_number
	inc si
	
cycle_number:
	cmp byte ptr [si], ' '
	je check_number_end
	cmp byte ptr [si], 0
	je check_number_end
	
	cmp byte ptr [si], '0'
	jb check_error	
	cmp byte ptr [si], '9'
	ja check_error
	
	; counted the number
	inc cx
	inc si
	jmp cycle_number
	
check_number_end:
	cmp cx, 0			; no numbers were counted
	je check_error	
	
	clc					; successful formatting
	pop cx
	mov sp, bp
    pop bp
	ret
	
check_error:
	stc					; formatting error - sets a flag
	pop cx
	mov sp, bp
    pop bp
	ret
	
; puts an error
_check_fail16:
	pop si
	pop cx
	pop bx
    mov sp, bp
    pop bp
	mov ah, 3
	xor al, al
	stc
    ret					; return to main
	
; void operation (int num1, int num2, char op)
; operation execution function
_operation:
    push bp
    mov bp, sp
	
	mov bx, [bp + arg1]		
	mov ax, [bp + arg2]
	mov dx, [bp + arg3]

    cmp bl, '+'
    je addition
    cmp bl, '-'
    je subtraction
    cmp bl, '*'
    je multiplication
    cmp bl, '/'
    je division
    cmp bl, '%'
    je remainder

	mov ah, 3
	xor al, al
	stc
    jmp op_end

addition:
	add ax, dx
	jo overflow
	clc
    jmp op_end
subtraction:
    sub ax, dx
    jo overflow
	clc
    jmp op_end
multiplication:
	imul dx				; result in DX:AX (32-bit)
	clc					; always success
    jmp op_end
	
division:
    cmp dx, 0
    je div_error

    cmp ax, 8000h      ; -32768
    jne safe_div
    cmp dx, -1
	jne safe_div
    jmp overflow
safe_div:
	mov bx, dx      ; divider
    cwd             
    idiv bx         ; AX = quotient, DX = divisible
    clc
    jmp op_end

remainder:
    cmp dx, 0
    je div_error
	
	cmp ax, 8000h      ; -32768
    jne safe_remain
    cmp dx, -1
    jne safe_remain
	
	; -32768 % -1 = 0
	xor ax, ax
	clc
	jmp op_end

safe_remain:
	mov bx, dx      ; divider
    cwd
    idiv bx
    mov ax, dx      ; take the remainder
    clc
    jmp op_end

div_error:
	mov ah, 1
	xor al, al
	stc
    jmp op_end

overflow:
    mov ah, 2
	xor al, al
	stc
	
op_end:
    mov sp, bp
    pop bp
    ret
	
	
; void calc() - calculator function
; displays a message corresponding to the error code,
; if the called function failed.
_calc: 
    push bp
    mov bp, sp
	
	; input of the number system
	push offset welcome_base_msg
	call _putstr
	add sp, 2
	
	call _getchar				; in al - symbol
	push ax
	call _notation
	jc error_manage
	add sp, 2
	
	call _getchar				; enter
	call _putnewline
	
	; expression input
	push offset welcome_msg
	call _putstr
	add sp, 2
	
	push max_len			
	push offset input_str
	call _getstr
	add sp, 4
	
	call _putnewline
	
	; branch work expense
	; format check
	push offset input_str
	
	cmp [base], 'h'
	je hex_input
	jmp dec_input

hex_input:
	call _check_hex	
	jmp after_input
	
dec_input: 
	call _check
	
after_input:
	jc error_manage
	add sp, 2
	
	; taking numbers and an operand
	push offset input_str
	call _convert
	jc error_manage	
	add sp, 2
	
	; after that in ax,dx are numbers, bl is the sign
	mov[operator], bl
	
	push dx       			 ; +arg3
	push ax        			 ; +arg2
	mov al, [operator]		 
	cbw            			 
	push ax     			 ; +arg1
	
	call _operation
	jc error_manage
	add sp, 6
	
	push ax					; saved the result
	push dx					

	cmp byte ptr [operator], '*'
	je _32res_print
	jmp _16res_print

_16res_print:
	pop dx					; freeing up unnecessary things
	
	; output in decimal
	push offset result_dec_msg
	call _putstr
	add sp, 2
	
	pop ax							; restored to the result
	push ax
	
	push offset res_str				; +arg2
	push ax							; +arg1
	call _itoa
	add sp, 4
	
	push offset res_str
	call _putstr
	add sp, 2
	
	call _putnewline
	push offset result_hex_msg
	call _putstr
	add sp, 2
	
	; output in hexadecimal
	pop ax

	push offset res_str
	push ax
	call _itoa16_hex
	add sp, 4
	
	push offset res_str
	call _putstr
	add sp, 2
	

	jmp end_calc

	
_32res_print:
	; output in decimal
	push offset result_dec_msg
	call _putstr
	add sp, 2

	pop dx				; restored after withdrawal
	pop ax
	push ax				; taken for the second withdrawal
	push dx
	
	push offset res_str_dw			; arg3
	push dx							; arg2
	push ax							; arg1
	call _itoa32
	add sp, 6
	
	push offset res_str_dw
	call _putstr
	add sp, 2
	
	call _putnewline
	push offset result_hex_msg
	call _putstr
	add sp, 2
	; output in hexadecimal
	
	pop dx							; restored
	pop ax
	
	push offset res_str_dw			; arg3
	push dx							; arg2
	push ax							; arg1
	call _itoa32_hex
	add sp, 6
	
	push offset res_str_dw
	call _putstr
	add sp, 2
	
	jmp end_calc
	
	
error_manage:
	cmp ah, 1
	je print_div_zero
	
	cmp ah, 2
	je print_overflow
	
	cmp ah, 3
	je print_invalid_format
	
	jmp print_invalid_format
	
	
print_div_zero:
	push offset error_msg_div_0
	call _putstr
	add sp, 2
	jmp end_calc
	
print_overflow:
	push offset error_msg_overflow
	call _putstr
	add sp, 2
	jmp end_calc
	
print_invalid_format:
	push offset error_msg_format
    call _putstr
    add sp, 2
    jmp end_calc
	
end_calc:
	mov sp, bp
    pop bp
    ret
	
start: 
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax

    call _calc
	call _exit0
code ends

end start