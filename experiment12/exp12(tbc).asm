;program to find median of array
printstring macro str   ; macro definition for printing string
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
endm 
printchar macro char
    mov ah,02h
    mov dl,char
    int 21h
endm    

read3dignum macro num
    mov ah,01h
    int 21h
    sub al,'0'
    mov bh,100 
    
    mul bh
    mov num,ax  
    
    mov ah,01h
    int 21h
    sub al,'0'
    mov bh,10
    mul bh    
    add num,ax
    
    mov ah,01h
    int 21h
    sub al,'0'
    mov ah,00
    add num,ax
endm    

data segment
    cr equ 0dh         ; define carriage return character
    nl equ 0ah         ; define new line character
    spa equ 20h        ; define space character
    tab equ 09h        ; define tab character 
    msg1 db 'Give the number of elements in the array: $'
    msg2 db 'Give number to be put in array: $' 
    msg3 db cr,nl,'$'
    msg4 db 'The numbers are: $'
    msg5 db 'The sorted numbers are: $'
    msg6 db 'The median is $'
    n dw ?  
    temp dw ?
    count dw 0
    arr dw 100 dup(?)
    str db 10 dup(?)
    half db ?
    sumeven dw 0
    median dw ?
data ends

code segment           ; start of code segment
    assume cs:code,ds:data   ; set code, data and extra segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    
    printstring msg1
    read3dignum n
    
    mov cx,n
    mov si,offset arr
    
read:
    printstring msg3
    printstring msg2
    read3dignum temp
    mov ax, temp
    mov [si],ax
    add si,2
    loop read
    
    mov cx,n
    mov bx, offset arr    
    printstring msg3
    printstring msg4
    printstring msg3
show1:
    mov ax,[bx]
    mov si,offset str
    call h2ad
    printstring str
    printchar spa
    add bx,2
    loop show1
    
    
    cmp n,1
    je oneelement
    
    
    ;printstring msg3
    
    
    mov cx,n
    dec cx  
sort:
    ;cmp [si],'$'
    ;je end
    mov count,00
    mov di,offset arr    ;test
 next:
    mov ax,[di]
    cmp ax,[di+2]
    jg swap
 swapend:
    inc di
    inc di      ;next position
    inc count   ;keeping tab on the position ofr comparison
    mov ax,n
    dec ax
    cmp count,ax
    jl next
    
    loop sort
    
    
    mov cx,n
    mov bx, offset arr    
    printstring msg3
    printstring msg5
    printstring msg3
show2:
    mov ax,[bx]
    mov si,offset str
    call h2ad
    printstring str
    printchar spa
    add bx,2
    loop show2
    
    
med:
    printstring msg3
    printstring msg6
    
    mov si, offset arr
    mov ax,n
    mov bh,2
    div bh
    mov dl,al
    mov dh,00 
    
    add si, n
    dec si
    
    cmp ah,01
    je odd
    
    
even:    
    mov ax,[si-1]
    add ax,[si+1]
    mov dx,00 
    mov bx,02
    div bx
    mov sumeven,dx
    mov si,offset str
    call h2ad
    printstring str
    cmp sumeven,01
    je printfloat
    jmp end
    
odd:
    mov ax,[si]
    mov si,offset str
    call h2ad
    printstring str 
        

end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos

oneelement:
    printstring msg3
    printstring msg6
    mov si, offset arr
    jmp odd
printfloat:
    printchar '.'
    printchar '5'
    jmp end

swap:
    xchg ax,[di+2]
    mov [di],ax
    jmp swapend     
    
    
h2ad proc
    pusha                     ;saving registers for possible later use
    
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
    
    
    popa                       ;retrieving resister values
    ret                          ;return 

    
code ends               ;end of code segment
end start               ;end of program
     

    
    
    
    
    
