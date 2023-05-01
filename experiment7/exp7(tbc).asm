;program to find pallindromes
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm 
data segment
    cr equ 0dh
    nl equ 0ah
    ;space equ 20h 
    string1 db 100 dup('$')
    rstring1 db 100 dup('$')
    length db 0   
    ;lst db 10 dup('$')
    ;half db ?
    msg1 db 'Give string for processing: $'    ;define message for prompt
    msg2 db cr,nl,'$'                         ;define message for newline
    msg3 db 'The string is a pallindrome.$'    ;define message for indication
    msg4 db 'The string is not a pallindrome.$';define message for indication
    msg5 db 'Reversed string: $'               ;define message for indication
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
                           
    mov si, offset string1
    printstring msg1
    
reads:
    mov ah,01h           ; set function code for reading char
    int 21h              ;calling dos
    cmp al, cr           ;comparing obtained character with cr
    je next              ;if it is obtained, input taing is stopped
    inc length           ;length variable is increased to show length
    mov ah,0             ;clear ah to ensure ax represents al, or the read character
    push ax              ;push ax to stack to be used later
    mov [si],al          ;move the character into the current string position
    inc si               ;go to next position of string using index
    jmp reads            ;continue loop as long as input doesn't hove cr
    
next:
    mov [si],'$'         ;terminate the original string
    mov di,si            ;move current si value into di
    dec di               ;decrease di to make it show the last character position
    
    ;printstring msg2
    ;printstring string1
    
    mov ch,0                 ;move length into cx
    mov cl,length            ;to run loops
    mov si, offset rstring1  ;make si point to the start of reverse string
rev:
    pop ax                   ;retrieve character from stack
    mov [si],al              ;move character to the current reverse string position
    inc si                   ;onto next position of reverse string
    loop rev                 ;continue loop until all characters are retrieved
    
    mov [si],'$'             ;end reversed string with $ 
    printstring msg2
    printstring msg5
    printstring rstring1
    

    
    mov ah,0
    mov al,length
    inc ax          ; for iterating on half of the string in
    mov dl,02h      ; both odd and even cases,(length+1)/2
    div dl          ; after these number of iterations
                    ; having mirrored elements means pallindrome
    
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
    
code ends               ;end of code segment
end start               ;end of program
             
    
    

