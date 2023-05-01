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
    ; Read first digit from user
    mov ah, 01h      ; Function number for ASCII input
    int 21h          ; Call DOS
    sub al, '0'      ; Extracting digit by subtracting '0' or 30h
    mov ah, 00       ; Set AH to 0
    mov bx, 3E8h     ; BX = 1000d
    mul bx           ; AX = AL * BX (Multiplying by 1000d to obtain 1000's place)
    mov n, ax        ; n is the number to be taken as input
    
    ; Read second digit from user
    mov ah, 01h      ; Function number for ASCII input
    int 21h          ; Call DOS
    sub al, '0'      ; Extracting digit by subtracting '0' or 30h
    mov bl, 64h      ; BL = 100d
    mul bl           ; AX = AL * BL (Multiplying by 100d to obtain 100's place)
    add n, ax        ; Add 100's place to n
    
    ; Read third digit from user
    mov ah, 01h      ; Function number for ASCII input
    int 21h          ; Call DOS
    sub al, '0'      ; Extracting digit by subtracting '0' or 30h
    ;mov ah, 00       ; Set AH to 0
    mov bl, 0Ah      ; BL = 10d
    mul bl           ; AX = AL * BL (Multiplying by 10d to obtain 10's place)
    add n, ax        ; Add 10's place to n
    
    ; Read fourth digit from user
    mov ah, 01h      ; Function number for ASCII input
    int 21h          ; Call DOS
    sub al, '0'      ; Extracting digit by subtracting '0' or 30h
    mov ah, 00       ; Set AH to 0
    add n, ax        ; Add 1's place to n
endm



data segment
    cr equ 0dh         ; define carriage return character
    nl equ 0ah         ; define new line character
    ;spa equ 20h        ; define space character
    ;tab equ 09h        ; define tab character
    num1 dw ?          ; define variable for number 1
    num2 dw ?          ; define variable for number 2
    decind dw 0ah      ; define variable for storing 10d for use in division
    tempstore dw ?     ; define variable for temporary storage
    msg1 db 'Give 1st 16 bit(4-digit) number : $'  ; define message for user input
    msg2 db 'Give 2nd 16 bit(4-digit) number : $'  ; define message for user input 
    msg4 db cr,nl,'$'  ; define message for new line 
    ;msg5 db '1st number: $'  ;define message to display number 1
    ;msg6 db '2nd number: $'  ;define message to display number 2
    msg7 db 'Sum: $'         ;define message to display sum
    msg8 db 'Difference: $'  ;define message to display difference
    msg9 db 'Product: $'     ;define message to display product
    str db 10 dup(?)         ;define string for use as buffer
data ends 

extra segment 
    sum dw ?            ;define variable to store sum
    diff dw ?           ;define variable to store difference
    prodl dw ?          ;define variable to store product upper word
    prodh dw ?          ;define variable to store product lower word
extra ends

code segment           ; start of code segment
    assume cs:code,ds:data,es:extra   ; set code, data and extra segments
    
start:                  ; start of program
    mov ax,data         ; move address of data segment to ax
    mov ds,ax           ; set ds register to point to data segment
    mov ax,extra         ; move address of extra segment to ax
    mov es,ax           ; set es register to point to extra segment
    
    
    printstring msg1   ;message for decimal input
    readnumdeci num1   ;calling macro to take input
    
    
    printstring msg4   ;message for newline
    
    printstring msg2   ;message for decimal 2nd input
    
    readnumdeci num2   ;calling macro to take input
    
    
    ;printstring msg4   ;message for newline
    ;mov ax,num1
    ;mov si,offset str
    ;mov dx,00
    ;call h2adec
    ;printstring msg5
    ;printstring str
    
    ;printstring msg4   ;message for newline
    ;mov ax,num2
    ;mov si,offset str
    ;mov dx,00
    ;call h2adec
    ;printstring msg6
    ;printstring str
    
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
    printstring msg4   ;message for newline
    printstring msg7
    
    mov dx,00
    mov ax,es:sum
    mov si,offset str
    
    call h2adec
    printstring str
    
printdiff:
    printstring msg4   ;message for newline
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
    printstring msg4   ;message for newline
    printstring msg9
    
    
    mov dx,es:prodh
    mov ax,es:prodl
    mov si,offset str
    
    call h2adec
    printstring str
    
    
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
    

h2adec proc near                 ;procedure to convert 32 bit number to ascii values corresponding to decimal value
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
h2adec endp

code ends               ;end of code segment
end start               ;end of program
