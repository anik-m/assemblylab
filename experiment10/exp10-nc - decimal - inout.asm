;Write and execute an assembly language program for performing the
;multiplication and division on 16-bit signed data.
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm 

data segment
    cr equ 0dh         ; define carriage return character
    nl equ 0ah         ; define new line character
    spa equ 20h        ; define space character
    tab equ 09h        ; define tab character
    num1 dw ?          ; define a variable for the first number input
    num2 dw ?          ; define a variable for the second number input
    mulup dw ?         ; define a variable for the upper 16 bits of the multiplication result
    muldo dw ?         ; define a variable for the lower 16 bits of the multiplication result
    divq dw ?          ; define a variable for the quotient of the division
    divr dw ?          ; define a variable for the remainder of the division
    s db 0             ; define a variable to store the status of the input (valid/invalid)
    negind db 0
    decind dw 0ah
    tempstore dw ?
    msg1 db 'Give 1st 16 bit number in binary:',spa,'$'  ; define message for user input
    msg2 db 'Give 2nd 16 bit number in binary:',spa,'$'  ; define message for user input
    msg3 db 'Not a valid 16 bit number. Run program again with an 16 bit number','$'     ; define error message 
    msg4 db cr,nl,'$'  ; define message for new line  
    msg5 db 'Signed product : ','$'       ; define message for multiplication result
    msg6 db 'Signed quotient : ','$'      ; define message for division quotient
    msg7 db 'Signed remainder : ','$'     ; define message for division remainder
    msg8 db 'First number: ','$'         ; define message for the first number input
    msg9 db 'Second number: ','$'        ; define message for the second number input
    msg11 db 'Give 1st 16 bit number in Hexadecimal(XXXX):',spa,'$'  ; define message for user input
    msg12 db 'Give 2nd 16 bit number in Hexadecimal(XXXX):',spa,'$'  ; define message for user input
    str1 db 20 dup('$')                  ; define a buffer for hexadecimal representation of input
    str2 db 20 dup('$')                  ; define a buffer for hexadecimal representation of input
    strb1 db 20 dup('$')                  ; define a buffer for binary representation of input
    strb2 db 20 dup('$')                  ; define a buffer for binary representation of input
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    
    printstring msg11  ; print message for 1st user input
    mov di,offset num1 ; set di to point to the first number input variable
    call readnum
    ;call readnumhex     ; read hexadecimal input and store in num1 variable
    ;call readnum16bit
    ;cmp s,01h           ; check the status variable s to see if input was valid
    ;je error            ; jump to error message if input was invalid
    
        
    printstring msg4   ; print new line
    printstring msg12  ; print message for 2nd user input
    mov di,offset num2 ; set di to point to the second number input variable
    call readnum
    ;call readnumhex    ; call readnumhex to read the first hexadecimal number from input 
    ;call readnum16bit
    ;cmp s,01h          ; compare s with 1 (indicates an error)
    ;je error           ; if s is 1, jump to error
    
                       ;for printing the numbers for confirmation
    printstring msg4   ; print a message to the console
    printstring msg8   ; print another message to the console
    ;mov dx, 00
    mov ax, num1       ; move the first number to ax
    cwd
    mov si, offset str1 ; point si to str1
    call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    printstring str1   ; print the result to the console

    printstring msg4   ; print another message to the console
    printstring msg9   ; print another message to the console
    ;mov dx,00
    mov ax, num2       ; move the second number to ax
    cwd
    mov si, offset str1 ; point si to str1
    call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    printstring str1   ; print the result to the console
    
    
                       ;finding signed product
    mov ax, num1       ; move the first number to ax
    mov dx,00          ; set dx to 0
    imul num2          ; multiply the two numbers and store the result in ax
    mov mulup,dx       ; move the upper word of the result to mulup
    mov muldo,ax       ; move the lower word of the result to muldo
                       
                       ;printing product
    printstring msg4   ; print another message to the console
    printstring msg5   ; print another message to the console
    
    mov dx, mulup      ; move the upper word of the result to ax
    ;mov si, offset str1 ; point si to str1
    ;call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    ;printstring str1   ; print the result to the console

    mov ax, muldo      ; move the lower word of the result to ax
    mov si, offset str1 ; point si to str1
    call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    printstring str1   ; print the result to the console
    
                       
                       ;finding signed division result
    mov ax, num1       ; move the first number to ax
    cwd
division:
    idiv num2          ; divide the two numbers and store the quotient in ax and the remainder in dx
    mov divq,ax        ; move the quotient to divq
    mov divr,dx        ; move the remainder to divr
        
    printstring msg4   ; print another message to the console
    printstring msg6   ; print another message to the console
    ;mov dx,00
    mov ax, divq       ; move the quotient to ax
    cwd
    mov si, offset str1 ; point si to str1
    call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    printstring str1   ; print the result to the console
    
    printstring msg4   ; print another message to the console
    printstring msg7   ; print another message to the console
    ;mov dx,00
    mov ax, divr       ; move the remainder to ax
    cwd
    mov si, offset str1 ; point si to str1
    call h2ad
    ;call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
    printstring str1   ; print the result to the console
    jmp end            ; jump to the end of the program
    
error:                 ; if there is error , print error message
    printstring msg3    
        
    
end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos


; procedure for reading 4-digit signed number from keyboard
; number will be held in [di]
readnum proc near
	mov bx,00
	mov cx,00
	mov negind,00
m1:
	mov ah,01h
	int 21h
	cmp al,'-'
	je negate
	sub al,'0'
	mov ah,00
	add bx,ax
	cmp cx,03h
	je doneread
	inc cx
	mov ax,bx
	mul decind
	mov bx,ax
	jmp m1

doneread:
	cmp negind,01h
	je negform
send:
	mov [di],bx
	ret
negate:
	mov negind,01h
	jmp m1
negform:
	neg bx
	jmp send
readnum endp

readnum16bit proc
    mov cx,00h          ; set counter for loop to 0
    mov bx,00h           ; set bx register to 0
                         
read:                   ; start of loop for reading binary number
    mov ah,01h          ; set function code for reading character from input
    int 21h             ; read character from input
    mov ah,00           ; set ah to 0 for logical OR operation
    sub al,'0'          ; convert character to number
    cmp al, 01h         ; check if input is 0 or 1
    jg errorb            ; jump to error message if not 0 or 1
    or bx,ax            ; perform logical OR operation to store binary number
    cmp cx,0Fh          ; check if all bits have been read
    je next             ; jump to next step if all bits have been read
    shl bx,1            ; shift bits to the left
    inc cx              ; increment counter
    jmp read            ; repeat loop
    
next:                   ;move number in bx to number variable
    mov [di],bx
    ret
errorb:                 ;error for binary input
    mov s,01h
    ret
readnum16bit endp  
    
readnumhex proc
    mov cx,00      ; Initialize counter to 0
    mov bx,00      ; Initialize value to store the number to 0
        
    mov ah,01h     ; Set up to read a character from keyboard
l1: int 21h        ; Read a character
    
    cmp al,'9'     ; Compare the character read to '9'
    jg letter      ; If it's greater, it must be a letter (not a number)
    sub al,'0'     ; Convert character to a number by subtracting '0'
    
lb: 
    ;cmp al,0Fh     ; Compare the number to 0Fh (15 decimal)
    ;jg errorh      ; If it's greater, it's not a valid hexadecimal number
    or bl,al       ; Combine the current digit with previous digits
    cmp cx,03h     ; Check if we've read all 4 hexadecimal digits
    je next1       ; If yes, jump to the end
    shl bx,4       ; Shift the value left by 4 bits (multiply by 16)
    inc cx         ; Increment the counter for the number of digits read
    jmp l1         ; Read the next digit
    
next1:
    mov [di],bx    ; Store the final value in the memory location pointed to by "di"
    ret           ; Return from the procedure
    
letter:
    cmp al,'a'     ; Compare the character read to 'a'
    jge small      ; If it's greater or equal, it's a lowercase letter
    sub al, 37h    ; Convert uppercase letter to number
    cmp al, 0Fh
    jg errorh
    jmp lb         ; Jump to the code for processing the digit
    
small:
    sub al,57h
    cmp al, 0Fh
    jg errorh     ; Convert lowercase letter to number
    jmp lb         ; Jump to the code for processing the digit
    
errorh:
    mov s,01h      ; Set an error flag if a non-hexadecimal digit is read
    ret           ; Return from the procedure
readnumhex endp

; procedure for displaying signed number
; number is held in DX:AX, string offset in si
h2ad proc near
	test dx,dx
	jns onlynum

	not dx
	neg ax

	mov bl,'-'
	mov [si],bl
	inc si

onlynum:
	mov cx,00
digitseparate:
	mov tempstore, ax       ;storing lower word in tempstore
	mov ax,dx               ;moving upper word to ax     
	xor dx,dx               ;converting dx:ax into 00:ax for the sake of division      

	div decind              ;so upper word in ax to be divided to obtain quotient                             
							;and remainder of upper portion of number      

	xchg ax,tempstore       ;we exchange values to place lower word in ax again                             
							;to obtain dx:ax = remainder:lower word which would've happened                             
							;for normal division so that we can divide it further                             
							;and we place first part of quotient in tempstore      

	div decind              ;dividing it further to obtain 2nd part of quotient and last remainder      

	add dx,'0'              ;adding 30h to convert remainder into decimal digit     
	push dx                 ;pushing converted remainder to stack     
	inc cx                  ;counter keeping tabs on how many digits are pushed      

	mov dx,tempstore        ;moving 1st part of quotient to dx for next iteration, should it come     
	or tempstore, ax        ;tempstore = tempstore OR ax                             
							;checking if there is any quotient at all     

	cmp tempstore,00        ;by comparing logical OR of first and 2nd part of quotient to zero      

	jne digitseparate       ;if it isn't zero we do the whole upper process under digitseparate                             
							;again to obtain next digit  

digittostring:     
	pop dx     
	mov [si],dl     
	inc si     
	loop digittostring      

	mov [si],'$' 
	ret

h2ad endp


    
code ends               ;end of code segment
end start               ;end of program
