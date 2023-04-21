;program to find pallindromes
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm 
data segment
    cr equ 0dh
    nl equ 0ah
    space equ 20h 
    string1 db 100 dup('$')
    rstring1 db 100 dup('$')
    length db 0   
    lst db 10 dup('$')
    half db ?
    msg1 db 'Give string for processing: $'
    msg2 db cr,nl,'$'
    msg3 db 'The string is a pallindrome.$'
    msg4 db 'The string is not a pallindrome.$'
    msg5 db 'Reversed string: $' 
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
                           
    mov si, offset string1
    printstring msg1
    
reads:
    mov ah,01h
    int 21h
    cmp al, cr
    je next
    inc length
    mov ah,0
    push ax
    mov [si],al
    inc si
    jmp reads
    
next:
    mov di,si
    dec di
    mov [si],'$'
    ;printstring msg2
    ;printstring string1
    
    
    mov ch,0 
    mov cl,length
    mov si, offset rstring1
rev:
    pop ax
    mov [si],al
    inc si
    loop rev
    
    mov [si],'$'
    printstring msg2
    printstring msg5
    printstring rstring1
    

    
    mov ah,0
    mov al,length
    inc ax          ; for iterating on half of the string in
    mov dl,02h      ; both odd and even cases,(length+1)/2
    div dl
    
    mov cl,al
    mov si, offset string1
             
    printstring msg2
check: 
    mov al,[si]
    cmp al,[di]
    jne notpal
    inc si
    dec di
    loop check
pal:
    printstring msg3
    jmp end
    

notpal:
    printstring msg4    
    
    
end:
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos
    
    
h2ad proc
    push ax                      
    push bx
    push cx
    push dx                      ;saving registers for possible later use
    
    mov bx,0ah                   ;keeping 10d for continuously dividing and taking decimal digits
    mov cx,0                     ;keeping counter for number of digits
    mov dx,0                     ;keeping upper byte clear for proper division
    
mark:
    div bx                       ;divided by 10d continuously 
    add dl,'0'                   ;adding 30h or '0' to convert digits to ascii
    push dx                      ;push ascii-converted digit to stack
    mov dx,0                     ;clearing upper byte for next division
    inc cx                       ;increasing counter for storing number of digits
    cmp ax,0                     ;if number is zero,all digits are in stack
    jne mark                     ;if number isn't 0, we repeat above process
    
    
mark2:
    pop ax                       ;pop digits from stack
    mov [si],ax                  ;poped digits are added to the result string
    inc si                       ;move to next position in string
    loop mark2                   ;repeat above process until all digits are in
                                 ;result string
    
    mov [si],'$'                 ;append dollar sign to terminate string
    
    pop dx
    pop cx
    pop bx
    pop ax                       ;retrieving resister values
    ret                          ;return 
       
    
code ends               ;end of code segment
end start               ;end of program
             
    
    

