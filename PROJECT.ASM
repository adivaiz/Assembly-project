data segment
    prompt_str db ">>please choose one of the following options: $"
    msg1 db "1. Prime number checker $"
    msg2 db "2. Caesar's shift coder $"
    msg3 db "3. Exit $"
    eop1 db ">>Enter a positive integer number N(255>N>2) to finish put dot: $"
    eop2 db ">>Type a string(only small characters in english) and dot: $"
    ffset db ">>Enter one decimal digit(between 2 to 9): $"
    msg_prime db "The number is prime.$"
    msg_not_prime db "The number is not prime.$"   
    String1 db 20 dup(?)
    size_var db 2 dup(?)  
    offset_var db 1 dup(?)
    String2 db 20 dup(?)
    Number dw 0
data ends

stack_seg segment
    db 100 dup(?)
stack_seg ends

code segment
assume ds:data, cs:code, ss:stack_seg

start:
    mov ax, data
    mov ds, ax

mainloop:
    call newline
    mov dx, offset prompt_str
    mov ah, 9
    int 21h                    ; Print prompt
    call newline                   ; New line
    mov dx, offset msg1
    mov ah, 9
    int 21h                    ; Print option 1
    call newline               ; New line
    mov dx, offset msg2
    mov ah, 9
    int 21h                    ; Print option 2
    call newline               ; New line
    mov dx, offset msg3
    mov ah, 9
    int 21h                    ; Print option 3
    call newline               ; New line
    mov ah, 1
    int 21h                    ; Get user input
    cmp al, '1'
    je option1                 ; If user selects option 1, jump to option1
    cmp al, '2'
    je option2                 ; If user selects option 2, jump to option2
    cmp al, '3'
    je option3                 ; If user selects option 3, jump to option3
    jmp mainloop               ; Loop back if input is invalid

option3:
    mov ax,4c00h
    int 21h                    ; Exit the program

option1:
    mov dx, offset eop1
    mov ah, 9
    int 21h                    ; Print the message to enter a number
    xor bx, bx                 ; Clear bx to start building the number
enter_number:
    mov ah, 1
    int 21h                    ; Read user input
    cmp al, '.'                ; If input is a dot, end input
    je endop1
    sub al, '0'                ; Convert character to numeric value
    mov ah, 0
    add bx, ax
    mov ax, bx
    mov si, 10
    mul si                     ; Multiply current number by 10 to add the new digit
    mov bx, ax                 ; Add the new digit to BX
    jmp enter_number           ; Repeat for the next input
endop1:
    mov ax, bx                 ; Move bx to ax (dividend)
    mov si, 10                 ; Move 10 to si (divisor)
    div si                     ; Divide ax by si
    mov bx, ax                 ; Store the quotient in bx
    mov Number, bx             ; Move bx to Number variable
    mov bx, offset Number
    push bx
    call check                 ; Call check procedure to determine if the number is prime
    jmp mainloop               ; Return to the main loop

tomain: jmp mainloop           ; Return to the main loop

option2:
    mov dx, offset eop2
    mov ah, 9
    int 21h                    ; Print instruction to enter a string
    mov bx, offset String1
    push bx
    call save_string           ; Call save_string procedure to store input in String1
    call newline
    mov dx, offset ffset
    mov ah, 9
    int 21h                    ; Print the message to enter offset for Caesar shift
    mov ah, 1
    int 21h                    ; Enter offset
    sub al, '0'                ; Convert character to numeric value
    mov [offset_var], al
    mov cl, [offset_var]        ; Load offset value into CL for Caesar shift
    mov bx, offset String1      ; BX points to String1 (input string)
    mov si, offset String2      ; SI points to String2 (output string)
    call newline
caesar_shift:
    mov al, [bx]                ; Load current character from String1
    cmp al, 0                   ; Check if end of string
    je end_caesar_shift         ; If end, jump to end_caesar_shift
    add al, cl                  ; Apply Caesar shift
    cmp al, 'z'                 ; Check if it exceeds 'z'
    jle store_char              ; If not, store the character
    sub al, 26                  ; Wrap around to 'a' if it exceeds 'z'
store_char:
    mov [si], al                ; Store shifted character in String2
    inc bx                      ; Move to the next character in String1
    inc si                      ; Move to the next position in String2
    jmp caesar_shift            ; Repeat for the next character
end_caesar_shift:
    mov byte ptr [si], 0        ; Set end of string with null character
    mov bx, offset String2      ; BX points to String2 for printing
print_loop:
    mov dl, [bx]                ; Load character from String2
    cmp dl, 0                   ; Check if end of string
    je tomain                ; If end, jump back to main loop
    mov ah, 2
    int 21h                     ; Print the character
    inc bx                      ; Move to the next character
    jmp print_loop              ; Repeat for the next character

newline proc
    mov dl, 10      ;make new line
    mov ah, 2
    int 21h
    ret
newline endp

check proc                ; This procedure checks if the given number is prime
    mov bp, sp
    mov bx, 2
check_loop:
    mov si, [bp+2]
    mov ax, [si]
    cmp bx, ax
    je print_prime                 ; If bx equals ax, the number is prime
    xor dx, dx
    div bx                         ; Divide ax by bx
    cmp dx, 0
    je not_prime                   ; If remainder is 0, the number is not prime
    inc bx
    cmp bx, ax
    jbe check_loop                 ; Repeat until bx is greater than ax

print_prime:
    call newline
    mov dx, offset msg_prime
    mov ah, 9
    int 21h                        ; Print "The number is prime"
    call newline
    call print_triangle            ; Call procedure to print a triangle
    jmp done

not_prime:
    call newline
    mov dx, offset msg_not_prime
    mov ah, 9
    int 21h                        ; Print "The number is not prime"
    call newline
    call print_square              ; Call procedure to print a square
done:
    ret 
check endp

save_string proc                   ; This procedure saves an input string into memory
    mov bp, sp
    mov bx, [bp+2]
enter_string:
    mov ah, 1
    int 21h                        ; Read character
    cmp al, '.'
    je end_string                  ; End input if '.' is encountered
    mov [bx], al                   ; Store character in memory
    inc bx
    jmp enter_string               ; Repeat for next character

end_string:
    ret 2
save_string endp

print_triangle proc           ; This procedure prints a right triangle made of '@' characters
    mov bp, sp
    mov si, [bp+4]
    mov cx, [si]
    mov bx, 1
triangle_loop:
    push cx
    push bx
    mov cx, bx
print_line:
    mov dl, '@'
    mov ah, 2
    int 21h                        ; Print '@' for the current line
    loop print_line                   
    call newline                   ; Print newline after each line of the triangle
    pop bx                    
    pop cx
    inc bx                         ; Increase the number of '@'s in the next line
    loop triangle_loop             ; Repeat until the triangle is complete
    ret 
print_triangle endp

print_square proc                   ; This procedure prints a square made of '*' character
    mov bp, sp
    mov si, [bp+4]
    mov cx, [si]
loop_1:
    push cx
    mov si,[bp+4]
    mov cx,[si]
square_loop:
    mov dl, '*'
    mov ah, 2
    int 21h                        ; Print '*' for the current line
    loop square_loop
    mov dl, 10
    mov ah, 2
    int 21h                        ; Print newline after each line of the square
    pop cx
    loop loop_1                    ; Repeat until the square is complete
    pop bp
    ret 
print_square endp

code ends
end start
