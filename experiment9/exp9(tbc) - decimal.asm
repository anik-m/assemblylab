printstring macro str   ; macro definition for printing string
    ;push ax
    mov ah,09h          ; set function code for printing string
    mov dx,offset str   ; set the address of string to be printed
    int 21h             ; calling dos to print string
    ;pop ax
endm

printchar macro char   ; macro definition for printing char  
    ;push ax
    mov ah,02h          ; set function code for printing char
    mov dl,char   ; set the char to be printed
    int 21h             ; calling dos to print string
    ;pop ax
endm


readnumdeci macro n
    ;mov dx,00
    mov ah,01h
    int 21h
    sub al,'0'
    cmp al,0ah
    jge error
    mov ah,00
    mov bx,3E8h
    mul bx
    mov n,ax
    
    ;mov dx,00
    mov ah,01h           ;function number for ascii input
    int 21h              ;calling dos
    sub al,'0'           ;extracting digit by subtracting '0' or 30h
    cmp al,0ah
    jge error
    mov bl,64h           ; 
    mul bl               ;multiplying by 100d to obtain 100's place 
    add n,ax             ;n is the number to be taken as input
    
             
    mov ah, 01h           ; input again
    int 21h
    sub al,'0'
    cmp al,0ah
    jge error          
    mov bl,0ah            
    mul bl                ; multiply by 10d for 10's place value
    add n, ax            ;adding 10's place value
    
    mov ah, 01h
    int 21h
    sub al,'0'
    cmp al,0ah
    jge error
    mov ah,00
    add n, ax           ;adding 1's place value
endm

data segment
    cr equ 0dh         ; define carriage return character
    nl equ 0ah         ; define new line character
    spa equ 20h        ; define space character
    tab equ 09h        ; define tab character
    num1 dw ?
    num2 dw ?  
    s db 0 
    decind dw 0ah
    tempstore dw ?
    msg1 db 'Give 1st 16 bit number in hexadecimal:',spa,'$'  ; define message for user input
    msg2 db 'Give 2nd 16 bit number in hexadecimal:',spa,'$'  ; define message for user input 
    msg3 db 'Not a valid number. Run program again with an valid number','$'     ; define error message 
    msg4 db cr,nl,'$'  ; define message for new line 
    msg5 db '1st number: $'
    msg6 db '2nd number: $'
    msg7 db 'Sum: $'
    msg8 db 'Difference: $'
    msg9 db 'Product: $'
    msg10 db 'Give 1st 16 bit(4 digit) number in decimal:',spa,'$'  ; define message for user input
    msg11 db 'Give 2nd 16 bit(4 digit) number in decimal:',spa,'$'  ; define message for user input
    str db 10 dup(?) 
data ends 

extra segment 
    sum dw ?
    carry db ?
    diff dw ?
    prodl dw ?
    prodh dw ?
extra ends

code segment           ; start of code segment
    assume cs:code,ds:data,es:extra   ; set code, data and extra segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    mov ax,extra         ; move address of extra segment to ax
    mov es,ax           ; set es register to point to extra segment
    
    
    printstring msg10   ;message for decimal input
    readnumdeci num1
    
    
    printstring msg4
    
    printstring msg11   ;message for decimal 2nd input
    
    readnumdeci num2
    
    
    printstring msg4
    mov ax,num1
    mov si,offset str
    
    call h2ad
    printstring msg5
    printstring str
    
    printstring msg4
    mov ax,num2
    mov si,offset str
    
    call h2ad
    printstring msg6
    printstring str
    
addnum:
    mov ax,num1
    add ax,num2
    mov es:sum,ax
    

subnum:
    mov ax,num1
    sub ax,num2
    mov es:diff,ax
    
multinum:
    mov ax,num1
    mul num2
    mov es:prodh,dx
    mov es:prodl,ax
    
printsum:
    printstring msg4
    printstring msg7
    
    mov dx,00
    mov ax,es:sum
    mov si,offset str
    
    call h2adec
    printstring str
    
printdiff:
    printstring msg4
    printstring msg8
    
    mov dx,00
    mov ax,es:diff
    mov bx,01
    shl bx,15
    and bx,ax
    push ax
    
    cmp bx,00
    jne makecomplement
    
 diffprocessing:   
    mov si,offset str
    
    call h2adec
    printstring str

printproduct:        
    printstring msg4
    printstring msg9
    
    
    mov dx,es:prodh
    mov ax,es:prodl
    mov si,offset str
    
    call h2adec
    printstring str
    
    jmp end
    
error:             ; if there is error , print error message
    printstring msg4
    printstring msg3

end:  
    mov ah,4ch           ;end program
    mov dx,00		    ;error code is 0 for successful termination
    int 21h		        ;calling dos


makecomplement:
    printchar '-'
    pop ax
    neg ax
    mov dx,00
    jmp diffprocessing
    

;readnumdec proc
;    pusha
;    
;    mov bx,00
;    ;mov dx,0ah
;    mov cx,00
;    
;ld1:
;    mov ah,01h
;    int 21h
;    sub al,'0'
;    cmp al, 0ah
;    jge errord
;    
;   add bl,al
;    cmp cx,03h
;    je ld2
;    
;    mov ax,bx
;    mul decind
;    mov bx,ax
;    inc cx
;    jmp ld1
;
;ld2:
;    mov [di],bx    ; Store the final value in the memory location pointed to by "di"
;    ret            ; Return from the procedure
;    
;errord:
;    mov s,01h      ; Set an error flag if a non-decimal digit is read
;    ret            ; Return from the procedure
    
h2ad proc                        ;procedure to change from binary to dec
    
    ;pusha                        ;saving registers for possible later use
    ;push si
    mov cx,00
    mov bx,0ah
markd1:
    mov dx,00
    div bx
    add dx,'0'
    push dx
    inc cx
    cmp ax,00
    jne markd1
    
    
markd2:
    pop ax                       ;pop digits from stack
    mov [si],ax                  ;poped digits are added to the result string
    inc si                       ;move to next position in string
    loop markd2                   ;repeat above process until all digits are in
                                 ;result string
    
    mov [si],'$'                 ;append dollar sign to terminate string
    
    ;pop si
    ;popa                       ;retrieving resister values
    ret


h2adec proc                  ;procedure to convert 32 bit number to ascii values corresponding to decimal value
    pusha
    mov cx,00
digitseparate:
    mov tempstore, ax       ;storing lower word in tempstore
    mov ax,dx               ;moving upper word to ax
    xor dx,dx               ;converting dx:ax into 00:ax for ease of division
    
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
    mov [si],dx
    inc si
    loop digittostring
    
    mov [si],'$'
    
    popa
    ret
     
 
 
code ends               ;end of code segment
end start               ;end of program
     


