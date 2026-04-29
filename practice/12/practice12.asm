section .data
    prompt_text     db  'Text: '
    prompt_text_len equ $ - prompt_text
    prompt_pat      db  'Pattern: '
    prompt_pat_len  equ $ - prompt_pat
    msg_pos         db  'Position: '
    msg_pos_len     equ $ - msg_pos
    msg_count       db  'Count: '
    msg_count_len   equ $ - msg_count
    msg_empty       db  'Pattern is empty', 0x0A
    msg_empty_len   equ $ - msg_empty
    msg_notfound    db  '-1', 0x0A
    msg_notfound_len equ $ - msg_notfound
    newline         db  0x0A
    digit_buf       times 12 db 0

section .bss
    text_buf    resb 202
    pat_buf     resb 52
    text_len    resd 1
    pat_len     resd 1

section .text
    global _start

strlen:
    push    ebp
    mov     ebp, esp
    push    esi
    mov     esi, [ebp+8]
    xor     eax, eax
.sl_loop:
    cmp     byte [esi+eax], 0x0A
    je      .sl_done
    cmp     byte [esi+eax], 0
    je      .sl_done
    inc     eax
    jmp     .sl_loop
.sl_done:
    pop     esi
    pop     ebp
    ret

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

print_uint:
    push    ebp
    mov     ebp, esp
    push    eax
    push    ebx
    push    ecx
    push    edx
    push    edi
    mov     eax, [ebp+8]
    mov     edi, digit_buf+11
    mov     byte [edi], 0x0A
    dec     edi
.pu_loop:
    xor     edx, edx
    mov     ebx, 10
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    test    eax, eax
    jnz     .pu_loop
    inc     edi
    lea     ecx, [digit_buf+12]
    sub     ecx, edi
    push    ecx
    push    edi
    call    print_line
    add     esp, 8
    pop     edi
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     ebp
    ret

_start:
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, prompt_text
    mov     edx, prompt_text_len
    int     0x80

    mov     eax, 3
    mov     ebx, 0
    mov     ecx, text_buf
    mov     edx, 202
    int     0x80

    push    dword text_buf
    call    strlen
    add     esp, 4
    mov     [text_len], eax

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, prompt_pat
    mov     edx, prompt_pat_len
    int     0x80

    mov     eax, 3
    mov     ebx, 0
    mov     ecx, pat_buf
    mov     edx, 52
    int     0x80

    push    dword pat_buf
    call    strlen
    add     esp, 4
    mov     [pat_len], eax

    cmp     eax, 0
    je      .empty_pattern

    mov     esi, 0
    mov     ebx, -1
    mov     ecx, 0

    mov     edx, [text_len]
    sub     edx, [pat_len]

.outer:
    cmp     esi, edx
    jg      .print_results
    jl      .try_match
    je      .try_match

.try_match:
    push    ecx
    push    edx
    mov     edi, 0

.inner:
    mov     ecx, [pat_len]
    cmp     edi, ecx
    jge     .match_found

    movzx   eax, byte [text_buf + esi + edi]
    movzx   ecx, byte [pat_buf + edi]
    cmp     al, cl
    jne     .no_match

    inc     edi
    jmp     .inner

.match_found:
    pop     edx
    pop     ecx
    cmp     ebx, -1
    jne     .not_first
    mov     ebx, esi
.not_first:
    inc     ecx
    add     esi, [pat_len]
    jmp     .outer

.no_match:
    pop     edx
    pop     ecx
    inc     esi
    jmp     .outer

.print_results:
    push    dword msg_pos_len
    push    dword msg_pos
    call    print_line
    add     esp, 8

    cmp     ebx, -1
    jne     .print_pos
    push    dword msg_notfound_len
    push    dword msg_notfound
    call    print_line
    add     esp, 8
    jmp     .print_count

.print_pos:
    push    ebx
    call    print_uint
    add     esp, 4

.print_count:
    push    dword msg_count_len
    push    dword msg_count
    call    print_line
    add     esp, 8

    push    ecx
    call    print_uint
    add     esp, 4

    mov     eax, 1
    xor     ebx, ebx
    int     0x80

.empty_pattern:
    push    dword msg_empty_len
    push    dword msg_empty
    call    print_line
    add     esp, 8
    mov     eax, 1
    mov     ebx, 1
    int     0x80