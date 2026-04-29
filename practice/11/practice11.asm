section .data
    prompt      db  'Введіть висоту (5..25): '
    prompt_len  equ $ - prompt
    err_msg     db  'Помилка: висота поза межами [5..25]!', 0x0A
    err_len     equ $ - err_msg

section .bss
    input_buf   resb 8
    line_buf    resb 60

section .text
    global _start

print_line:
    push    ebp
    mov     ebp, esp
    push    eax
    push    ebx
    push    ecx
    push    edx

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, [ebp+8]
    mov     edx, [ebp+12]
    int     0x80

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     ebp
    ret

_start:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, prompt
    mov     edx, prompt_len
    int     0x80

    mov     eax, 3
    mov     ebx, 0
    mov     ecx, input_buf
    mov     edx, 8
    int     0x80

    mov     esi, input_buf
    xor     edx, edx
.atoi_loop:
    movzx   ecx, byte [esi]
    cmp     cl, '0'
    jl      .atoi_done
    cmp     cl, '9'
    jg      .atoi_done
    sub     cl, '0'
    imul    edx, edx, 10
    add     edx, ecx
    inc     esi
    jmp     .atoi_loop
.atoi_done:

    cmp     edx, 5
    jl      .bad_input
    cmp     edx, 25
    jg      .bad_input

    mov     ebp, edx
    mov     esi, 1

.row_loop:
    cmp     esi, ebp
    jg      .done

    mov     edi, line_buf

    mov     ecx, ebp
    sub     ecx, esi
    jz      .no_spaces
.space_loop:
    mov     byte [edi], ' '
    inc     edi
    loop    .space_loop

.no_spaces:
    mov     ecx, esi
    shl     ecx, 1
    dec     ecx
.star_loop:
    mov     byte [edi], '*'
    inc     edi
    loop    .star_loop

    mov     byte [edi], 0x0A
    inc     edi

    mov     ecx, edi
    sub     ecx, line_buf

    push    ecx
    push    dword line_buf
    call    print_line
    add     esp, 8

    inc     esi
    jmp     .row_loop

.done:
    mov     eax, 1
    xor     ebx, ebx
    int     0x80

.bad_input:
    push    dword err_len
    push    dword err_msg
    call    print_line
    add     esp, 8

    mov     eax, 1
    mov     ebx, 1
    int     0x80