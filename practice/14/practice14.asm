section .bss
    inbuf   resb 512
    arr     resd 100
    n       resd 1
    outbuf  resb 32

section .data
    msg_before      db "Before: "
    msg_before_len  equ $ - msg_before
    msg_after       db "After:  "
    msg_after_len   equ $ - msg_after
    msg_median      db "Median: "
    msg_median_len  equ $ - msg_median
    newline         db 0x0a
    space           db 0x20

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, inbuf
    mov edx, 512
    int 0x80

    mov esi, inbuf
    call skip_ws
    call parse_uint
    mov [n], eax

    mov edi, 0
.read_loop:
    cmp edi, [n]
    jge .read_done
    call skip_ws
    call parse_int
    mov [arr + edi*4], eax
    inc edi
    jmp .read_loop
.read_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_before
    mov edx, msg_before_len
    int 0x80

    mov edi, 0
.pb_loop:
    cmp edi, [n]
    jge .pb_done
    push edi
    mov eax, [arr + edi*4]
    call print_int
    call print_space
    pop edi
    inc edi
    jmp .pb_loop
.pb_done:
    call print_nl

    mov ecx, 0
.outer:
    mov eax, [n]
    dec eax
    cmp ecx, eax
    jge .sort_done

    push ecx
    mov edx, ecx
    mov ebx, ecx
    inc ebx
.inner:
    cmp ebx, [n]
    jge .inner_done
    mov eax, [arr + ebx*4]
    cmp eax, [arr + edx*4]
    jge .no_new_min
    mov edx, ebx
.no_new_min:
    inc ebx
    jmp .inner
.inner_done:
    pop ecx
    cmp edx, ecx
    je .no_swap
    mov eax, [arr + ecx*4]
    mov ebx, [arr + edx*4]
    mov [arr + ecx*4], ebx
    mov [arr + edx*4], eax
.no_swap:
    inc ecx
    jmp .outer
.sort_done:

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_after
    mov edx, msg_after_len
    int 0x80

    mov edi, 0
.pa_loop:
    cmp edi, [n]
    jge .pa_done
    push edi
    mov eax, [arr + edi*4]
    call print_int
    call print_space
    pop edi
    inc edi
    jmp .pa_loop
.pa_done:
    call print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_median
    mov edx, msg_median_len
    int 0x80

    mov eax, [n]
    xor edx, edx
    mov ecx, 2
    div ecx
    test edx, edx
    jnz .odd_n
    dec eax
.odd_n:
    mov eax, [arr + eax*4]
    call print_int
    call print_nl

    mov eax, 1
    xor ebx, ebx
    int 0x80

skip_ws:
    mov al, [esi]
    cmp al, 0x20
    je .skip
    cmp al, 0x0a
    je .skip
    cmp al, 0x0d
    je .skip
    cmp al, 0x09
    je .skip
    ret
.skip:
    inc esi
    jmp skip_ws

parse_uint:
    xor eax, eax
.pu_loop:
    mov cl, [esi]
    cmp cl, 0x30
    jl .pu_done
    cmp cl, 0x39
    jg .pu_done
    imul eax, eax, 10
    sub cl, 0x30
    movzx ecx, cl
    add eax, ecx
    inc esi
    jmp .pu_loop
.pu_done:
    ret

parse_int:
    mov al, [esi]
    cmp al, 0x2d
    jne parse_uint
    inc esi
    call parse_uint
    neg eax
    ret

print_int:
    pushad

    lea edi, [outbuf + 31]
    mov byte [edi], 0
    dec edi

    xor ecx, ecx
    test eax, eax
    jns .positive
    mov ecx, 1
    neg eax
.positive:
    test eax, eax
    jnz .digits
    mov byte [edi], 0x30
    dec edi
    jmp .sign
.digits:
    test eax, eax
    jz .sign
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, 0x30
    mov [edi], dl
    dec edi
    jmp .digits
.sign:
    test ecx, ecx
    jz .do_print
    mov byte [edi], 0x2d
    dec edi
.do_print:
    inc edi
    lea edx, [outbuf + 31]
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80

    popad
    ret

print_space:
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    popad
    ret

print_nl:
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    popad
    ret