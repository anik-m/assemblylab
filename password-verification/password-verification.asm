printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm 
data segment
    cr equ 0dh
    nl equ 0ah
    string1 db 100 dup('$')
    length db 0   
    msg1 db 'Give Password: $'    ;define message for prompt
    msg2 db cr,nl,'$'                         ;define message for newline
    msg3 db 'The password is correct.$'    ;define message for indication
    msg4 db 'The password is not correct.$';define message for indication
    password db 'deez nuts'
    passlength db 9
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
                           
    mov si, offset string1
    printstring msg1
    

reads:
    mov ah,07h           ; set function code for reading char
    int 21h              ;calling dos
    
    cmp al, cr           ;comparing obtained character with cr
    je next              ;if it is obtained, input taing is stopped
    
    inc length           ;length variable is increased to show length
    mov [si],al          ;move the character into the current string position
    inc si               ;go to next position of string using index
    
    ;mov ah,02h
    ;mov dl,'*'
    ;int 21h
    jmp reads            ;continue loop as long as input doesn't hove cr
    
next:
    mov [si],'$'         ;terminate the original string
    
    
    mov al,length
    cmp al,passlength
    jne notpass
    
    
    
    mov si, offset password
    mov di, offset string1
    
    mov ch,0
    mov cl,length
    
matchloop:
    mov al, [di]
    cmp al, [si]
    jne notpass
    inc si
    inc di
    loop matchloop
    
    
pass:
    printstring msg2
    printstring msg3
    jmp end
    
notpass:
    printstring msg2
    printstring msg4    
    
    
end:
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos
    
code ends               ;end of code segment
end start               ;end of program
             
