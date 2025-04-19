section .data
    prompt      db 'Enter a digit (0-9): ', 0
    msg_below   db 'Input is below 5', 10, 0
    msg_equal   db 'Input is equal to 5', 10, 0
    msg_above   db 'Input is above 5', 10, 0

section .bss
    input_char resb 1

section .text
    global _start

_start:
    mov eax, 4          
    mov ebx, 1         
    mov ecx, prompt
    mov edx, 21         
    int 0x80

    mov eax, 3          
    mov ebx, 0          
    mov ecx, input_char
    mov edx, 1
    int 0x80
    
    mov al, [input_char]
    sub al, '0'         
    mov bl, 5

    cmp al, bl
    jl print_below
    je print_equal
    jg print_above

print_below:
    call print_msg_below
    jmp exit

print_equal:
    call print_msg_equal
    jmp exit

print_above:
    call print_msg_above
    jmp exit

print_msg_below:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_below
    mov edx, 18
    int 0x80
    ret

print_msg_equal:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_equal
    mov edx, 19
    int 0x80
    ret

print_msg_above:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_above
    mov edx, 18
    int 0x80
    ret

exit:
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; return 0
    int 0x80
