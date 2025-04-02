section .data
    prompt     db "Enter temperature in Fahrenheit: "
    prompt_len equ $-prompt
    
    result     db "Temperature in Celsius: "
    result_len equ $-result
    
    newline    db 10
    buf        times 16 db 0  ; Input buffer

section .bss
    fahrenheit resd 1
    celsius    resd 1
    ascii_buf  resb 16       ; For number conversion

section .text
    global _start

_start:
    ; Print prompt
    mov rax, 1               ; sys_write
    mov rdi, 1               ; stdout
    mov rsi, prompt
    mov rdx, prompt_len
    syscall

    ; Read input
    mov rax, 0               ; sys_read
    mov rdi, 0               ; stdin
    mov rsi, buf
    mov rdx, 16
    syscall

    ; Convert ASCII input to integer
    mov rsi, buf
    call ascii_to_int
    mov [fahrenheit], eax

    ; Convert F to C: (F-32)*5/9
    mov eax, [fahrenheit]
    sub eax, 32
    mov ebx, 5
    imul ebx
    mov ebx, 9
    idiv ebx
    mov [celsius], eax

    ; Print result message
    mov rax, 1               ; sys_write
    mov rdi, 1               ; stdout
    mov rsi, result
    mov rdx, result_len
    syscall

    ; Convert Celsius to ASCII
    mov eax, [celsius]
    mov rdi, ascii_buf
    call int_to_ascii
    mov rdx, rax             ; Length of ASCII string

    ; Print Celsius value
    mov rax, 1               ; sys_write
    mov rdi, 1               ; stdout
    mov rsi, ascii_buf
    syscall

    ; Print newline
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit
    mov rax, 60              ; sys_exit
    xor rdi, rdi             ; status 0
    syscall

; Helper: ASCII to integer (result in eax)
ascii_to_int:
    xor eax, eax
    xor ecx, ecx
.next_digit:
    movzx edx, byte [rsi+rcx]
    cmp dl, 10               ; Stop at newline
    je .done
    sub edx, '0'             ; Convert char to digit
    imul eax, 10
    add eax, edx
    inc ecx
    jmp .next_digit
.done:
    ret

; Helper: Integer to ASCII (input in eax, buffer in rdi)
; Returns length in rax
int_to_ascii:
    mov rbx, 10              ; Base 10
    mov rcx, 0               ; Digit counter
    test eax, eax
    jnz .convert
    mov byte [rdi], '0'      ; Handle zero case
    mov rax, 1
    ret
.convert:
    xor edx, edx
    div ebx                  ; Divide by 10
    add dl, '0'              ; Convert to ASCII
    push rdx                 ; Store digit
    inc rcx                  ; Increment counter
    test eax, eax
    jnz .convert
    mov r8, rcx              ; Save length
.store:
    pop rax
    mov [rdi], al
    inc rdi
    loop .store
    mov rax, r8              ; Return length
    ret