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
    msg1 db 'Give 1st 16 bit number in binary:',spa,'$'  ; define message for user input
    msg2 db 'Give 2nd 16 bit number in binary:',spa,'$'  ; define message for user input
    msg3 db 'Not a valid 16 bit number. Run program again with an 16 bit number','$'     ; define error message 
    msg4 db cr,nl,'$'  ; define message for new line  
    msg5 db 'Signed product: ','$'       ; define message for multiplication result
    msg6 db 'Signed quotient: ','$'      ; define message for division quotient
    msg7 db 'Signed remainder: ','$'     ; define message for division remainder
    msg8 db 'First number: ','$'         ; define message for the first number input
    msg9 db 'Second number: ','$'        ; define message for the second number input
    msg11 db 'Give 1st 16 bit number in Hexadecimal:',spa,'$'  ; define message for user input
    msg12 db 'Give 2nd 16 bit number in Hexadecimal:',spa,'$'  ; define message for user input
    str1 db 20 dup('$')                  ; define a buffer for hexadecimal representation of input
    str2 db 20 dup('$')                  ; define a buffer for hexadecimal representation of input
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    
    printstring msg11  ; print message for 1st user input
    mov di,offset num1 ; set di to point to the first number input variable
    call readnumhex     ; read hexadecimal input and store in num1 variable
    ;call readnum16bit
    cmp s,01h           ; check the status variable s to see if input was valid
    je error            ; jump to error message if input was invalid
    
    printstring msg4   ; print new line
    printstring msg12  ; print message for 2nd user input
    mov di,offset num2 ; set di to point to the second number input variable
    call readnumhex    ; call readnumhex to read the first hexadecimal number from input 
    ;call readnum16bit

    cmp s,01h          ; compare s with 1 (indicates an error)
    je error           ; if s is 1, jump to error

printstring msg4   ; print a message to the console
printstring msg8   ; print another message to the console
mov ax, num1       ; move the first number to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console

printstring msg4   ; print another message to the console
printstring msg9   ; print another message to the console
mov ax, num2       ; move the second number to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console

mov ax, num1       ; move the first number to ax
mov dx,00          ; set dx to 0
imul num2          ; multiply the two numbers and store the result in ax
mov mulup,dx       ; move the upper word of the result to mulup
mov muldo,ax       ; move the lower word of the result to muldo

printstring msg4   ; print another message to the console
printstring msg5   ; print another message to the console
mov ax, mulup      ; move the upper word of the result to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console

mov ax, muldo      ; move the lower word of the result to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console

mov ax, num1       ; move the first number to ax
mov dx,00          ; set dx to 0
idiv num2          ; divide the two numbers and store the quotient in ax and the remainder in dx
mov divq,ax        ; move the quotient to divq
mov divr,dx        ; move the remainder to divr

printstring msg4   ; print another message to the console
printstring msg6   ; print another message to the console
mov ax, divq       ; move the quotient to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console

printstring msg4   ; print another message to the console
printstring msg7   ; print another message to the console
mov ax, divr       ; move the remainder to ax
mov si, offset str1 ; point si to str1
call h2ah          ; call h2ah to convert the number to hexadecimal and store it in str1
printstring str1   ; print the result to the console
jmp end            ; jump to the end of the program

error:             ; if there is error , print error message
printstring msg3    
        
    
end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos
    
    
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
  
    
readnumhex proc
    mov cx,00      ; Initialize counter to 0
    mov bx,00      ; Initialize value to store the number to 0
        
    mov ah,01h     ; Set up to read a character from keyboard
l1: int 21h        ; Read a character
    
    cmp al,'9'     ; Compare the character read to '9'
    jg letter      ; If it's greater, it must be a letter (not a number)
    sub al,'0'     ; Convert character to a number by subtracting '0'
    
lb: 
    cmp al,0Fh     ; Compare the number to 0Fh (15 decimal)
    jg errorh      ; If it's greater, it's not a valid hexadecimal number
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
    jmp lb         ; Jump to the code for processing the digit
    
small:
    sub al,57h     ; Convert lowercase letter to number
    jmp lb         ; Jump to the code for processing the digit
    
errorh:
    mov s,01h      ; Set an error flag if a non-hexadecimal digit is read
    ret           ; Return from the procedure

    
h2ah proc                        ;procedure to change from binary to hexa
    
    pusha                        ;saving registers for possible later use
    ;push si
    mov cx,04
mark1:
    mov bx,0fh
    and bx,ax
    cmp bx,09h
    jg letteradd
    add bx,'0'
    push bx
 afteradd:
    shr ax,4
    loop mark1
    
    mov cx,04
    
mark2:
    pop ax                       ;pop digits from stack
    mov [si],ax                  ;poped digits are added to the result string
    inc si                       ;move to next position in string
    loop mark2                   ;repeat above process until all digits are in
                                 ;result string
    
    mov [si],'$'                 ;append dollar sign to terminate string
    
    ;pop si
    popa                       ;retrieving resister values
    ret
    
letteradd:                     ;adding 37h or 55d to get 10=A(65d), 11=B(66d) and so on
    add bx,37h
    push bx
    jmp afteradd
 
    
code ends               ;end of code segment
end start               ;end of program
     