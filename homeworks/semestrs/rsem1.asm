.386

stack segment para stack
	db 256 dup(?)
stack ends

data segment para public

	alph db "0123456789ABCDEF"
	hex_str_1 db 4 dup(?), "$"
	hex_str_2 db 8 dup(?), "$"
	
	invite_crc16 db "CRC-16: ", "$"
	invite_crc32 db "CRC-32: ", "$"

	input_line  db 255
				db ?
				db 255 dup (?)
				db 0
		   
	new_line db 0Ah, 0Dh, "$"
	
	crc16table  dw 0000h, 0C0C1h, 0C181h, 0140h, 0C301h, 03C0h, 0280h, 0C241h
			dw 0C601h, 06C0h, 0780h, 0C741h, 0500h, 0C5C1h, 0C481h, 0440h
			dw 0CC01h, 00CC0h, 00D80h, 0CD41h, 00F00h, 0CFC1h, 0CE81h, 00E40h
			dw 00A00h, 0CAC1h, 0CB81h, 00B40h, 0C901h, 009C0h, 00880h, 0C841h
			dw 0D801h, 018C0h, 01980h, 0D941h, 01B00h, 0DBC1h, 0DA81h, 01A40h
			dw 01E00h, 0DEC1h, 0DF81h, 01F40h, 0DD01h, 01DC0h, 01C80h, 0DC41h
			dw 01400h, 0D4C1h, 0D581h, 01540h, 0D701h, 017C0h, 01680h, 0D641h
			dw 0D201h, 012C0h, 01380h, 0D341h, 01100h, 0D1C1h, 0D081h, 01040h
			dw 0F001h, 030C0h, 03180h, 0F141h, 03300h, 0F3C1h, 0F281h, 03240h
			dw 03600h, 0F6C1h, 0F781h, 03740h, 0F501h, 035C0h, 03480h, 0F441h
			dw 03C00h, 0FCC1h, 0FD81h, 03D40h, 0FF01h, 03FC0h, 03E80h, 0FE41h
			dw 0FA01h, 03AC0h, 03B80h, 0FB41h, 03900h, 0F9C1h, 0F881h, 03840h
			dw 02800h, 0E8C1h, 0E981h, 02940h, 0EB01h, 02BC0h, 02A80h, 0EA41h
			dw 0EE01h, 02EC0h, 02F80h, 0EF41h, 02D00h, 0EDC1h, 0EC81h, 02C40h
			dw 0E401h, 024C0h, 02580h, 0E541h, 02700h, 0E7C1h, 0E681h, 02640h
			dw 02200h, 0E2C1h, 0E381h, 02340h, 0E101h, 021C0h, 02080h, 0E041h
			dw 0A001h, 060C0h, 06180h, 0A141h, 06300h, 0A3C1h, 0A281h, 06240h
			dw 06600h, 0A6C1h, 0A781h, 06740h, 0A501h, 065C0h, 06480h, 0A441h
			dw 06C00h, 0ACC1h, 0AD81h, 06D40h, 0AF01h, 06FC0h, 06E80h, 0AE41h
			dw 0AA01h, 06AC0h, 06B80h, 0AB41h, 06900h, 0A9C1h, 0A881h, 06840h
			dw 07800h, 0B8C1h, 0B981h, 07940h, 0BB01h, 07BC0h, 07A80h, 0BA41h
			dw 0BE01h, 07EC0h, 07F80h, 0BF41h, 07D00h, 0BDC1h, 0BC81h, 07C40h
			dw 0B401h, 074C0h, 07580h, 0B541h, 07700h, 0B7C1h, 0B681h, 07640h
			dw 07200h, 0B2C1h, 0B381h, 07340h, 0B101h, 071C0h, 07080h, 0B041h
			dw 05000h, 090C1h, 09181h, 05140h, 09301h, 053C0h, 05280h, 09241h
			dw 09601h, 056C0h, 05780h, 09741h, 05500h, 095C1h, 09481h, 05440h
			dw 09C01h, 05CC0h, 05D80h, 09D41h, 05F00h, 09FC1h, 09E81h, 05E40h
			dw 05A00h, 09AC1h, 09B81h, 05B40h, 09901h, 059C0h, 05880h, 09841h
			dw 08801h, 048C0h, 04980h, 08941h, 04B00h, 08BC1h, 08A81h, 04A40h
			dw 04E00h, 08EC1h, 08F81h, 04F40h, 08D01h, 04DC0h, 04C80h, 08C41h
			dw 04400h, 084C1h, 08581h, 04540h, 08701h, 047C0h, 04680h, 08641h
			dw 08201h, 042C0h, 04380h, 08341h, 04100h, 081C1h, 08081h, 04040h
					
	crc32table  dd 00000000h, 077073096h, 0EE0E612Ch, 0990951BAh
			dd 0076DC419h, 0706AF48Fh, 0E963A535h, 09E6495A3h
			dd 00EDB8832h, 079DCB8A4h, 0E0D5E91Eh, 097D2D988h
			dd 009B64C2Bh, 07EB17CBDh, 0E7B82D07h, 090BF1D91h
			dd 01DB71064h, 06AB020F2h, 0F3B97148h, 084BE41DEh
			dd 01ADAD47Dh, 06DDDE4EBh, 0F4D4B551h, 083D385C7h
			dd 0136C9856h, 0646BA8C0h, 0FD62F97Ah, 08A65C9ECh
			dd 014015C4Fh, 063066CD9h, 0FA0F3D63h, 08D080DF5h
			dd 03B6E20C8h, 04C69105Eh, 0D56041E4h, 0A2677172h
			dd 03C03E4D1h, 04B04D447h, 0D20D85FDh, 0A50AB56Bh
			dd 035B5A8FAh, 042B2986Ch, 0DBBBC9D6h, 0ACBCF940h
			dd 032D86CE3h, 045DF5C75h, 0DCD60DCFh, 0ABD13D59h
			dd 026D930ACh, 051DE003Ah, 0C8D75180h, 0BFD06116h
			dd 021B4F4B5h, 056B3C423h, 0CFBA9599h, 0B8BDA50Fh
			dd 02802B89Eh, 05F058808h, 0C60CD9B2h, 0B10BE924h
			dd 02F6F7C87h, 058684C11h, 0C1611DABh, 0B6662D3Dh
			dd 076DC4190h, 001DB7106h, 098D220BCh, 0EFD5102Ah
			dd 071B18589h, 006B6B51Fh, 09FBFE4A5h, 0E8B8D433h
			dd 07807C9A2h, 00F00F934h, 09609A88Eh, 0E10E9818h
			dd 07F6A0DBBh, 0086D3D2Dh, 091646C97h, 0E6635C01h
			dd 06B6B51F4h, 01C6C6162h, 0856530D8h, 0F262004Eh
			dd 06C0695EDh, 01B01A57Bh, 08208F4C1h, 0F50FC457h
			dd 065B0D9C6h, 012B7E950h, 08BBEB8EAh, 0FCB9887Ch
			dd 062DD1DDFh, 015DA2D49h, 08CD37CF3h, 0FBD44C65h
			dd 04DB26158h, 03AB551CEh, 0A3BC0074h, 0D4BB30E2h
			dd 04ADFA541h, 03DD895D7h, 0A4D1C46Dh, 0D3D6F4FBh
			dd 04369E96Ah, 0346ED9FCh, 0AD678846h, 0DA60B8D0h
			dd 044042D73h, 033031DE5h, 0AA0A4C5Fh, 0DD0D7CC9h
			dd 05005713Ch, 0270241AAh, 0BE0B1010h, 0C90C2086h
			dd 05768B525h, 0206F85B3h, 0B966D409h, 0CE61E49Fh
			dd 05EDEF90Eh, 029D9C998h, 0B0D09822h, 0C7D7A8B4h
			dd 059B33D17h, 02EB40D81h, 0B7BD5C3Bh, 0C0BA6CADh
			dd 0EDB88320h, 09ABFB3B6h, 003B6E20Ch, 074B1D29Ah
			dd 0EAD54739h, 09DD277AFh, 004DB2615h, 073DC1683h
			dd 0E3630B12h, 094643B84h, 00D6D6A3Eh, 07A6A5AA8h
			dd 0E40ECF0Bh, 09309FF9Dh, 00A00AE27h, 07D079EB1h
			dd 0F00F9344h, 08708A3D2h, 01E01F268h, 06906C2FEh
			dd 0F762575Dh, 0806567CBh, 0196C3671h, 06E6B06E7h
			dd 0FED41B76h, 089D32BE0h, 010DA7A5Ah, 067DD4ACCh
			dd 0F9B9DF6Fh, 08EBEEFF9h, 017B7BE43h, 060B08ED5h
			dd 0D6D6A3E8h, 0A1D1937Eh, 038D8C2C4h, 04FDFF252h
			dd 0D1BB67F1h, 0A6BC5767h, 03FB506DDh, 048B2364Bh
			dd 0D80D2BDAh, 0AF0A1B4Ch, 036034AF6h, 041047A60h
			dd 0DF60EFC3h, 0A867DF55h, 0316E8EEFh, 04669BE79h
			dd 0CB61B38Ch, 0BC66831Ah, 0256FD2A0h, 05268E236h
			dd 0CC0C7795h, 0BB0B4703h, 0220216B9h, 05505262Fh
			dd 0C5BA3BBEh, 0B2BD0B28h, 02BB45A92h, 05CB36A04h
			dd 0C2D7FFA7h, 0B5D0CF31h, 02CD99E8Bh, 05BDEAE1Dh
			dd 09B64C2B0h, 0EC63F226h, 0756AA39Ch, 0026D930Ah
			dd 09C0906A9h, 0EB0E363Fh, 072076785h, 005005713h
			dd 095BF4A82h, 0E2B87A14h, 07BB12BAEh, 00CB61B38h
			dd 092D28E9Bh, 0E5D5BE0Dh, 07CDCEFB7h, 00BDBDF21h
			dd 086D3D2D4h, 0F1D4E242h, 068DDB3F8h, 01FDA836Eh
			dd 081BE16CDh, 0F6B9265Bh, 06FB077E1h, 018B74777h
			dd 088085AE6h, 0FF0F6A70h, 066063BCAh, 011010B5Ch
			dd 08F659EFFh, 0F862AE69h, 0616BFFD3h, 0166CCF45h
			dd 0A00AE278h, 0D70DD2EEh, 04E048354h, 03903B3C2h
			dd 0A7672661h, 0D06016F7h, 04969474Dh, 03E6E77DBh
			dd 0AED16A4Ah, 0D9D65ADCh, 040DF0B66h, 037D83BF0h
			dd 0A9BCAE53h, 0DEBB9EC5h, 047B2CF7Fh, 030B5FFE9h
			dd 0BDBDF21Ch, 0CABAC28Ah, 053B39330h, 024B4A3A6h
			dd 0BAD03605h, 0CDD70693h, 054DE5729h, 023D967BFh
			dd 0B3667A2Eh, 0C4614AB8h, 05D681B02h, 02A6F2B94h
			dd 0B40BBE37h, 0C30C8EA1h, 05A05DF1Bh, 02D02EF8Dh
	
data ends

code segment para public use16
assume cs:code,ds:data,ss:stack


start:
    mov ax, data
    mov ds, ax
    mov ax, stack
    mov ss, ax


main_loop:
	mov dx, offset input_line
	mov ah, 0Ah
	int 21h
	
	call new_line_print
	call new_line_print

	mov si, offset input_line
	xor cx, cx
	mov cl, byte ptr [si + 1]      		; line length
	mov bp, cx							; bp = actual length of the written string
	
	cmp bp, 0
	je exit
	
	; CRC16
	push bp								; save	
	call calc_crc16						; ax = result crc16
	call htoi16	
	
	; print result
	mov dx, offset invite_crc16
	call str_print
	mov dx, offset hex_str_1
	call str_print
	call new_line_print	
	
	
	; CRC-32
	pop bp								; restored real len string
	
	call calc_crc32		; dx:ax = result crc32
	call htoi32

	; print result
	mov dx, offset invite_crc32
	call str_print
	mov dx, offset hex_str_2
	call str_print
	call new_line_print
	
	call exit

	

; crc16 = (crc >> 8) ^ Crc16Table[(crc & FFh) ^ *pcBlock++];
calc_crc16:
	mov ax, 0FFFFh
	
	mov bx, offset input_line
	add bx, 2	

	iter_over_str_1:
	
		; getting an index in the table:
		; index = a number from 0 to 255
		; the table contains 256 el
		; the size of the table = 512 bytes (each element = word)
		; the element's address = index * 2
		
		mov dx, ax 
		xor cx, cx
		mov cl, byte ptr [bx]		; cl = current char
		xor cl, dl					; cx = index of the element in the table			
		
		mov si, cx					; si = index in the table
		shl si, 1
	
		shr ax, 8		
		mov di, offset crc16table
		add di, si
		xor ax, word ptr [di]
		
		inc bx						; skip to the next char
		dec bp						; reducing the counter after processing
		cmp bp, 0
		jnz iter_over_str_1
		ret							; return to main
	
	
htoi16:	
	mov cx, 4			; iterations on our number
	mov di, 0			; iterations on a hex string
	
next_dig:
	rol ax, 4
	mov bx, ax			; saved a copy

	and bx, 000Fh	

	call digit_to_hex					; bx = symbol
	mov byte ptr [hex_str_1 + di], bl
	inc di

	; moving on to the next digit
	loop next_dig
	ret


; (crc >> 8) ^ Crc32Table[(crc ^ *pcBlock++) & 0xFF]
calc_crc32:
	mov dx, 0FFFFh
	mov ax, 0FFFFh
	
	mov bx, offset input_line
	add bx, 2

	iter_over_str_2:
	
		; getting an index in the table:
		; index = a number from 0 to 255
		; the table contains 256 el
		; the size of the table = 1024 bytes (each element = dword)
		; the element's address = index * 4

		; [(crc ^ *pcBlock++) & 0xFF]
		xor cx, cx
		mov cl, byte ptr [bx]		; cl = current char
		xor cl, al					; cx = index of the element in the table			
		
		mov si, cx					; si = index in the table
		shl si, 2
		
		; (crc >> 8) 
		shrd ax, dx, 8
		shr dx, 8

		mov di, offset crc32table
		add di, si
		xor ax, word ptr [di]
		xor dx, word ptr [di + 2]
		
		inc bx						; skip to the next char
		dec bp						; reducing the counter after processing
		cmp bp, 0
		jnz iter_over_str_2
		
		not ax
		not dx	
		
		ret							; return to main
		
		
htoi32:
	; DX:AX - high and low word
	; first DX, then AX
	mov di, 0			; iterations on a hex string
	
	push ax 			; saved the low word to the stack
	mov ax, dx
	call word_to_hex
	
	pop ax
	call word_to_hex
	
	ret					; return main_loop

word_to_hex:	
	mov cx, 4			; iterations on our number

next_dig32:
	rol ax, 4
	mov bx, ax			; saved a copy

	and bx, 000Fh		
	call digit_to_hex
	mov byte ptr [hex_str_2 + di], bl
	inc di

	; moving on to the next digit
	loop next_dig32			
	ret
		
		
digit_to_hex:		; work with bx
	cmp bl, 10
	jb below_num
	 
	add bx, 'A'
	sub bx, 10
	ret
below_num:
	add bx, '0'
	ret
; end of digit_to_hex	


str_print:
	mov ah, 09h
	int 21h
	ret
	
new_line_print: 
	mov dx, offset new_line
    mov ah, 09h
    int 21h
    ret
	
exit:
    mov ah, 4ch
	int 21h

	
code ends
end start