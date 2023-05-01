;Write and execute an assembly language program for performing the
;multiplication and division on 16-bit signed data.
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm                    ; end of printstring macro


data segment       
    cr equ 0dh         ; define carriage return character
    nl equ 0ah         ; define new line character
    num1 dw ?          ; first number input
    num2 dw ?          ; second number input
    mulup dw ?         ; upper 16 bits of the signed product
    muldo dw ?         ; lower 16 bits of the signed product
    divq dw ?          ; quotient of the division
    divr dw ?          ; remainder of the division
    negind db 0        ; negative status of the number
    decind dw 0ah      ; storing 10d for ease of division
    tempstore dw ?     ; variable for storing values temporarily
    msg1 db 'Give 1st 16 bit(4-digit) number : $'  ; message for 1st number input
    msg2 db 'Give 2nd 16 bit(4-digit) number : $'  ; message for 2nd number input
    msg3 db cr,nl,'$'  ; message for new line  
    msg4 db 'Signed product : ','$'       ; prompt message for multiplication result
    msg5 db 'Signed quotient : ','$'      ; prompt message for division quotient
    msg6 db 'Signed remainder : ','$'     ; prompt message for division remainder
    ;msg8 db 'First number: ','$'         ; prompt message for the first number input
    ;msg9 db 'Second number: ','$'        ; prompt message for the second number input
    str1 db 20 dup('$')                  ; buffer for printing numbers
data ends           


code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    
    printstring msg1  ; print message for 1st user input
    mov di,offset num1 ; set index di to point to the first number input variable
    call readnum      ;call readnum procedure to take input of 1st number
    
    
        
    printstring msg3   ; print new line
    printstring msg2  ; print message for 2nd user input
    mov di,offset num2 ; set index di to point to the second number input variable
    call readnum      ;call readnum procedure to take input of 2nd number
    
                       ;for printing the numbers for confirmation
    ;printstring msg3   ; print newline
    ;printstring msg8   ; print first number prompt to the console
    ;mov ax, num1       ; move the first number to ax
    ;cwd                ; extending sign bit of ax into dx
    ;mov si, offset str1 ; point si to buffer str1
    ;call h2ad          ; calling h2ad procedure to convert number into corresponding ASCII
    ;printstring str1   ; print buffer to the console

    ;printstring msg3   ; print newline
    ;printstring msg9   ; print second number prompt to the console
    ;mov ax, num2       ; move the second number to ax
    ;cwd                ; extending sign bit of ax into dx
    ;mov si, offset str1 ; point si to buffer str1
    ;call h2ad          ; calling h2ad procedure to convert number into corresponding ASCII
    ;printstring str1   ; print buffer to the console

product:                  ;finding signed product
    mov ax, num1       ; move the first number to ax
    ;mov dx,00          ; set dx to 0
    imul num2          ; do signed multilication the two numbers and store the result in (dx:ax)
    mov mulup,dx       ; move the upper word of product to mulup
    mov muldo,ax       ; move the lower word of product to muldo
                       
printproduct:           
    printstring msg3   ; print newline
    printstring msg4   ; print prompt of product to the console
    
    mov dx, mulup      ; move the upper word of the result to ax
    mov ax, muldo      ; move the lower word of the result to ax
    mov si, offset str1 ; point si to buffer str1
    call h2ad          ; calling h2ad procedure to convert product into corresponding ASCII 
    printstring str1   ; print buffer to the console

division:                ;finding signed division results
    mov ax, num1       ; move the first number to ax
    cwd                ; sign extend ax into dx

    idiv num2          ; do signed division on the two numbers and store the quotient in ax and the remainder in dx
    mov divq,ax        ; move the quotient to divq
    mov divr,dx        ; move the remainder to divr

printquotient:        
    printstring msg3   ; print newline
    printstring msg5   ; print prompt of quotient to the console
    mov ax, divq       ; move the quotient to ax
    cwd               ; sign extend ax into dx
    mov si, offset str1 ; point si to buffer str1
    call h2ad          ; calling h2ad procedure to convert quotient into corresponding ASCII 
    printstring str1   ; print the buffer to the console

printremainder:    
    printstring msg3   ; print newline
    printstring msg6   ; print prompt of remainder to the console
    mov ax, divr       ; move the remainder to ax
    cwd               ; sign extend ax into dx
    mov si, offset str1 ; point si to bufferstr1
    call h2ad          ; calling h2ad procedure to convert remainder into corresponding ASCII 
    printstring str1   ; print the buffer to the console


end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos


; procedure for reading 4-digit signed number from keyboard
; number will be held in [di]
readnum proc near
	mov bx,00           ;move 0 to bx register, where number will be stored
	mov cx,00           ;move 0 to counter
	mov negind,00       ;move 0 to negative indicator
m1:
	mov ah,01h          ;set function number for reading char
	int 21h             ;calling dos
	cmp al,'-'          ;compare obtained char with minus sign
	je negate           ;if it's minus sign, set negind to 01
	
	sub al,'0'          ;subtract 0 to get number
	mov ah,00           ;set ah to 0
	add bx,ax           ;add ax to bx to get number
	cmp cx,03h          ;if number is muktiplied by 10 3 times, exit loop
	je doneread         ;jump out of loop
	
	inc cx              ;increase  counter to count multiplication instances
	mov ax,bx           ;mov num to ax for multiplication 
	mul decind          ;multiply by 10
	mov bx,ax           ;bring number back to bx
	jmp m1              ;jump to m1

doneread:
	cmp negind,01h      ;check if negative indicator is 1
	je negform          ;if it is, negate number

send:
	mov [di],bx         ;move number to assigned variable
	ret                 ;return to main program

negate:
	mov negind,01h      ;set negative indicator
	jmp m1              ;jmp back to loop

negform:
	neg bx              ;replace bx with it's 2's complement
	jmp send            ;jump to number assignment

readnum endp


; procedure for displaying signed number
; number is held in DX:AX, string offset in si
h2ad proc near
	test dx,dx              ;conduct logical and of dx with itself to use resulting sign flag 
	jns onlynum             ;if number is negative or sign flag is set, the processing below isn't necessary

onlynegnum:
	not dx                  ;as number is negative, sign extension dx is all 1, now converted to all 0
	neg ax                  ;to get 2's complement of ax

	mov bl,'-'              ;move minus sign into the buffer string
	mov [si],bl             ;to indicate that the number is negative
	
	inc si                  ;move to next string position

onlynum:
	mov cx,00               ;set counter to 0

digitseparate:
	mov tempstore, ax       ;storing lower word in tempstore
	mov ax,dx               ;moving upper word to ax     
	xor dx,dx               ;converting dx:ax into 00:ax for the sake of division      

	div decind              ;so upper word in ax to be divided to obtain quotient                             
							;and remainder of upper portion of number      

	xchg ax,tempstore       ;we exchange values to place lower word in ax again                             
							;to obtain dx:ax = remainder:lower word which would've happened                             
							;for normal by-hand division so that we can divide it further                             
							;and we store first part of quotient in tempstore      

	div decind              ;dividing it further to obtain 2nd part of quotient and last remainder      

	add dx,'0'              ;adding 30h to convert remainder into decimal digit     
	push dx                 ;pushing converted remainder to stack     
	inc cx                  ;counter keeping tabs on how many digits are pushed      

	mov dx,tempstore        ;moving 1st part of quotient to dx for next iteration, should it come     
	or tempstore, ax        ;tempstore = tempstore OR ax                             
							;checking if there is any quotient at all
							;if result is zero, there is no quotient     

	cmp tempstore,00        ;by comparing logical OR of first and 2nd part of quotient to zero      

	jne digitseparate       ;if it isn't zero we do the whole upper process under digitseparate                             
							;again to obtain next digit until there is no quotient or all digits are taken 

digittostring:              ;to retrieve ascii value of digits from stack to put in buffer string
	pop dx                  ;popping digit from stack
	mov [si],dl             ;moving digit to buffer
	inc si                  ;move to next position in the string
	loop digittostring      ;continue loop until all pushed digits are retrieved

	mov [si],'$'            ;end string with dollar sign
	ret                     ;return to main program

h2ad endp


    
code ends               ;end of code segment
end start               ;end of program
