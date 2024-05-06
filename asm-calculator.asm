global _start

section .data
    LF equ 10
    NULL equ 0
    SYS_EXIT equ 60
    STDOUT equ 1
    SYS_WRITE equ 1
    STDIN equ 0
    SYS_READ equ 0

     menu db "************MENU***********", LF
         db "[1] Addition", LF
         db "[2] Subtraction", LF
         db "[3] Integer Division", LF
         db "[0] Exit", LF
         db "**************************", LF
         db "Choice: ", NULL
    menuLen equ $-menu

    msg db "Enter a two-digit number: ", NULL
    msgLen equ $-msg

    newLine db LF, NULL
    newLineLen equ $-newLine

    num1 db 0, 0
    num2 db 0, 0
    sum db 0, 0

    num1_val db 0
    num2_val db 0
    result_val db 0
    temp db 0

    hundreds db 0
    tens db 0
    ones db 0

    choice db 0


    section .text
_start:
    ; Loop for the menu
menu_loop:
    ; Write the menu to stdout
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, menu
    mov rdx, menuLen
    syscall

    ; Read the choice from stdin
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, choice
    mov rdx, 2  ; Read two characters (choice + newline)
    syscall

    cmp byte [choice], '0'
    je exit_program

    ; Write the message prompt to stdout
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, msgLen
    syscall

    ; Read the two-digit number from stdin
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, num1
    mov rdx, 3  ; Read two characters plus the newline
    syscall

    ; Convert the input to a numerical value
    mov al, byte [num1]    ; Load tens digit
    sub al, '0'
    mov bl, 10
    mul bl              ; Multiply by 10
    mov byte[num1_val], al

    mov al, byte [num1 + 1]; Load ones digit
    sub al, '0'
    add byte[num1_val], al              ; Add ones digit


    ; Write the message prompt to stdout
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg
    mov rdx, msgLen
    syscall

    ; Read the two-digit number from stdin
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, num2
    mov rdx, 3  ; Read two characters plus the newline
    syscall

    ; Convert the input to a numerical value
    mov al, byte [num2]    ; Load tens digit
    sub al, '0'
    mov bl, 10
    mul bl              ; Multiply by 10
    mov byte[num2_val], al


    mov al, byte [num2 + 1]; Load ones digit
    sub al, '0'
    add byte[num2_val], al              ; Add ones digit

    ; Check the choice
    cmp byte [choice], '1'
    je addition
    cmp byte [choice], '2'
    je subtraction
    cmp byte [choice], '3'
    je integer_division

    ; Invalid choice, loop back to menu
    jmp menu_loop

exit_program:
    ; Exit the program
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

addition:
    ; Add num1_val and num2_val and store the result in result_val
    mov al, byte [num1_val]  ; Load num1_val into al
    add al, byte [num2_val]  ; Add num2_val to al
    mov byte [result_val], al   ; Store the result in result_val
    call print_result
    jmp menu_loop

subtraction:
    mov al, byte[num1_val]
    cmp al, byte[num2_val]
    jng switch ; Check if num1_val is the higher number

    ret_subtract:
    ; Subtract num1_val and num2_val and store the result in result_val
    mov al, byte [num1_val]  ; Load num1_val into al
    sub al, byte [num2_val]  ; Subtract num2_val from al
    mov byte [result_val], al   ; Store the result in result_val
    call print_result
    jmp menu_loop

switch:
    ; Swap the values of num1_val and num2_val
    mov al, byte[num1_val]
    mov bl, byte[num2_val]
    mov byte[num1_val], bl
    mov byte[num2_val], al
    jmp ret_subtract

integer_division:
    xor rax, rax
    ; Add num1_val and num2_val and store the result in result_val
    mov al, byte [num1_val]  ; Load num1_val into al
    mov bl, byte [num2_val]  ; Divide num1_val by num2_val 
    div bl
    mov byte [result_val], al   ; Store the result in result_val
    call print_result
    jmp menu_loop

print_result:
    xor rax, rax
    mov al, byte [result_val] ; Load the result into AL
    mov bl, 100            ; Load the divisor (100) into BL
    div bl                 ; Divide AL by BL, quotient (hundreds place) in AL, remainder in AH
    mov byte [hundreds], al ; Store the quotient (hundreds place) in hundreds variable
    add byte [hundreds], '0'  ; Convert to ASCII

    
    mov byte[temp], ah      ; Remainder is tens and ones place
    xor rax, rax

    mov al, byte[temp]             ; Load the remainder from the previous division (tens place) into AL
    mov bl, 10             ; Load the divisor (10) into BL
    div bl                 ; Divide AL by BL, quotient (tens place) in AL, remainder (ones place) in AH
    mov byte [tens], al    ; Store the quotient (tens place) in tens variable
    add byte [tens], '0'      ; Convert to ASCII

    mov byte [ones], ah    ; Store the remainder (ones place) in ones variable
    add byte [ones], '0'      ; Convert to ASCII


    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, hundreds
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, tens
    mov rdx, 1 
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, ones
    mov rdx, 1 
    syscall

    ; Print a new line
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

    ; Loop back to menu
    jmp menu_loop