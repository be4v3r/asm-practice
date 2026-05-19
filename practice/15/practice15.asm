section .bss
    calls   resd 1
    result  resd 1

section .data
    msg_fact      db "fact(n) = ", 0
    msg_fact_len  equ $ - msg_fact
    msg_calls     db "calls   = ", 0
    msg_calls_len equ $ - msg_calls
    buf           times 14 db 0

section .text
global _start

; Вхід: eax = n   Вихід: eax = n!
fact:
    push ebp
    mov  ebp, esp
    push ecx
    push edx

    inc  dword [calls]

    cmp  eax, 1
    jle  .base

    mov  ecx, eax
    dec  eax
    call fact
    imul eax, ecx
    jmp  .done

.base:
    mov  eax, 1

.done:
    pop  edx
    pop  ecx
    pop  ebp
    ret

; Вхід: eax = число   Вихід: ecx = вказівник, edx = довжина
uint_to_str:
    push ebp
    mov  ebp, esp
    push ebx
    push edi

    lea  edi, [buf+12]
    mov  byte [edi], 10     ; '\n'
    dec  edi

    test eax, eax
    jnz  .convert
    mov  byte [edi], '0'
    dec  edi
    jmp  .finish

.convert:
    mov  ebx, 10
.loop:
    test eax, eax
    jz   .finish
    xor  edx, edx
    div  ebx
    add  dl, '0'
    mov  [edi], dl
    dec  edi
    jmp  .loop

.finish:
    lea  ecx, [edi+1]
    lea  edx, [buf+13]
    sub  edx, edi

    pop  edi
    pop  ebx
    pop  ebp
    ret

_start:
    mov  eax, 3
    mov  ebx, 0
    mov  ecx, buf
    mov  edx, 13
    int  0x80

    mov  esi, buf
    xor  eax, eax
    xor  ecx, ecx

.parse_loop:
    movzx edx, byte [esi+ecx]
    cmp  dl, '0'
    jl   .parse_done
    cmp  dl, '9'
    jg   .parse_done
    imul eax, eax, 10
    sub  dl, '0'
    add  eax, edx
    inc  ecx
    jmp  .parse_loop

.parse_done:
    cmp  eax, 12
    jle  .n_ok
    mov  eax, 12
.n_ok:
    mov  dword [calls], 0

    call fact
    mov  [result], eax

    ; друкуємо мітку
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_fact
    mov  edx, msg_fact_len
    int  0x80

    ; друкуємо факторіал
    mov  eax, [result]
    call uint_to_str
    mov  eax, 4
    mov  ebx, 1
    int  0x80

    ; друкуємо мітку
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, msg_calls
    mov  edx, msg_calls_len
    int  0x80

    ; друкуємо calls
    mov  eax, [calls]
    call uint_to_str
    mov  eax, 4
    mov  ebx, 1
    int  0x80

    mov  eax, 1
    xor  ebx, ebx
    int  0x80