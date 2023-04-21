;program to add/remove from string
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
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
    msg1 db 'Give string for processing: $'
    msg2 db cr,nl,'$'
    msg3 db 'Remove or Add character(r/a)? $'
    msg4 db 'Give position on the string: $'
    msg5 db 'Give character to be added: $'
    length db 0 
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
    mov [si],'$'  
    
    printstring msg2
    printstring string1
    
    printstring msg2
    printstring msg3
    mov ah,01h
    int 21h
    mov cmd,al       
    printstring msg2
    printstring msg4
    read2gnum pos
    
    
    mov si, offset string1
    mov di,si
    mov ah,0
    mov al,pos
    add si,ax
    dec si
    mov al,length
    add di,ax
    
    
    cmp cmd,'r'
    je remove
    cmp cmd,'R'
    je remove
    
    ;dec di
    
addchar:
    printstring msg2
    printstring msg5
    mov ah,01h
    int 21h
    
    
 iter1:
    xchg [si],al
    inc si
    cmp si,di
    jle iter1
    
    mov [si],'$'
    
    
    printstring msg2
    printstring string1
    jmp end
    
    
    
    
remove:
    mov bx,si   
    inc si
 iter2:
    mov ax,[si]
    xchg [bx],ax
    inc si
    inc bx
    cmp si,di
    jle iter2
    
    printstring msg2
    printstring string1
    
 


        
    
    
    ;printstring string1
       
    
end:
    mov ah,4ch          ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos

code ends               ;end of code segment
end start               ;end of program
             
    
    

    
