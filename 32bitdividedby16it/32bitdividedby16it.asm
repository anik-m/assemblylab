;32bit/16bit
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
    num1l dw ?
    num1h dw ?
    num2 dw ?
    ;num2h dw ?  
    s db 0
    msg1 db 'Give 32 bit number in hexadecimal:',spa,'$'  ; define message for user input
    msg2 db 'Give 16 bit number in hexadecimal:',spa,'$'  ; define message for user input 
    msg3 db 'Not a valid 16 bit number. Run program again with an 16 bit number','$'     ; define error message 
    msg4 db cr,nl,'$'  ; define message for new line 
    msg5 db '1st number: $'
    msg6 db '2nd number: $'
    msg7 db 'Quotient in hexadecimal: $'
    msg8 db 'Remainder in hexadecimal: $'
    msg9 db 'Product: $'
    str db 10 dup(?) 
    temp dw ?
data ends 

extra segment 
    suml dw ?
    sumh dw ?
    carry db 0
    diffl dw ?
    diffh dw ?
    prodl dw ?
    prodh dw ?
    quotient1 dw ?
    quotient2 dw ?
    remainder dw ?
extra ends

code segment           ; start of code segment
    assume cs:code,ds:data,es:extra   ; set code, data and extra segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    mov ax,extra         ; move address of extra segment to ax
    mov es,ax           ; set es register to point to extra segment
    

    printstring msg1
    mov di,offset num1h ; set di to point to the first number input variable
    call readnumhex     ; read hexadecimal input and store in num1 variable
    cmp s,01h           ; check the status variable s to see if input was valid
    je error            ; jump to error message if input was invalid 
    
    mov di,offset num1l ; set di to point to the first number input variable
    call readnumhex     ; read hexadecimal input and store in num1 variable
    cmp s,01h           ; check the status variable s to see if input was valid
    je error 
    
    printstring msg4
    printstring msg2
    mov di,offset num2 ; set di to point to the first number input variable
    call readnumhex     ; read hexadecimal input and store in num1 variable
    cmp s,01h           ; check the status variable s to see if input was valid
    je error            ; jump to error message if input was invalid
    
    ;mov di,offset num2l ; set di to point to the first number input variable
    ;call readnumhex     ; read hexadecimal input and store in num1 variable
    ;cmp s,01h           ; check the status variable s to see if input was valid
    ;je error            ; jump to error message if input was invalid
    
    
    printstring msg4
    mov ax,num1h
    mov si,offset str
    call h2ah
    printstring msg5
    printstring str
    
    mov ax,num1l
    mov si,offset str
    call h2ah
    printstring str
    
    printstring msg4
    mov ax,num2
    mov si,offset str
    call h2ah
    printstring msg6
    printstring str
    
    ;mov ax,num2l
    ;mov si,offset str
    ;call h2ah
    ;printstring str
    
divnum:
    mov cx,num1l
    mov temp, cx
    mov dx, 00
    mov ax, num1h
    div num2
    ;mov es:quotient,ax
    ;mov es:remainder,dx
    xchg ax,temp
    div num2
    mov cx, temp
    mov es:quotient1,cx
    mov es:quotient2,ax
    mov es:remainder,dx
     
    
printq:
    printstring msg4
    mov ax,es:quotient1
    mov si,offset str
    call h2ah
    printstring msg7
    printstring str
    
    mov ax,es:quotient2
    mov si,offset str
    call h2ah
   ; printstring msg7
    printstring str

printr:
    printstring msg4
    mov ax,es:remainder
    mov si,offset str
    call h2ah
    printstring msg8
    printstring str
    
                
    jmp end
    
error:             ; if there is error , print error message
    printstring msg4
    printstring msg3

end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos


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
    ret            ; Return from the procedure
    
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
    ret            ; Return from the procedure
readnumhex endp

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
h2ah endp 
 
code ends               ;end of code segment
end start               ;end of program


