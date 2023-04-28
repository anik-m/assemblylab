printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm
readchar macro char
    mov ah,01h
    int 21h
    mov char,al    
endm
read2gnum macro num
    mov ah,01h
    int 21h
    sub al,'0'
    mov dl,10
    mul dl
    mov num, al 
    mov ah,01h
    int 21h
    sub al,'0'
    add num, al
endm
    
data segment 
    cr equ 0dh
    nl equ 0ah
    space equ 20h 
    string1 db 100 dup('$')
    string2 db 100 dup('$')
    string3 db 100 dup('$')
    msg1 db 'Give string for processing: $'
    msg2 db cr,nl,'$'
    msg3 db 'The original string: $'
    msg4 db 'Give character to be removed: $'
    msg5 db 'Give character to be added: $'
    msg6 db 'Give character after which character is added: $'
    msg7 db 'String after character removal: $'
    msg8 db 'String after character addition: $'
    length db 0
    chartemp db ?
    charremove db ?
    charadd db ?
    charafter db ?
    cmd db ? 
    pos db ?
    
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code and data segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    
    mov si, offset string1
    printstring msg1
reads:
    readchar chartemp
    cmp chartemp, cr
    je next
    inc length
    mov bl,chartemp
    mov [si],bl
    inc si
    jmp reads
    
next:  
    
    
    
          
    printstring msg2
    printstring msg4
    readchar charremove
    
    mov si, offset string1
    mov di, offset string2
removechar:
    mov al,[si]
    cmp al,charremove
    jne rc  
    
    
  afterrc:
    ;mov al,[si]
    
    inc si
    ;inc di
    cmp [si],'$'
    jne removechar
    
    
    
    printstring msg2
    printstring msg5
    readchar charadd
    
    printstring msg2
    printstring msg6
    readchar charafter 
    
    mov si, offset string1
    mov di, offset string3
addchar:
    mov al,[si]
    mov [di],al
    cmp al,charafter
    je ac
  afterac:
    inc si
    inc di
    cmp [si],'$'
    jne addchar
    
    ;printing original string
    printstring msg2
    printstring msg3
    printstring string1
    
    ;printing string after deletion
    printstring msg2
    printstring msg7
    printstring string2
    
    ;printing string after addition                                          
    printstring msg2
    printstring msg8
    printstring string3

    
end:
    mov ah,4ch          ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos

rc: 
    mov [di],al
    inc di
    jmp afterrc

ac:
    inc di
    mov al,charadd
    mov [di],al
    jmp afterac    

code ends               ;end of code segment
end start               ;end of program
             
    
    

    