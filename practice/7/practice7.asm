BITS 32
GLOBAL _start

SECTION .data

msg_array   db "array: "
msg_arr_len equ $-msg_array

msg_min     db "min: "
msg_min_len equ $-msg_min

msg_max     db "max: "
msg_max_len equ $-msg_max

msg_idx     db " idx: "
msg_idx_len equ $-msg_idx

ch_space    db " "
ch_nl       db 10

SECTION .bss

buf     resb 256
numstr  resb 32
arr     resd 50
n_val   resd 1

SECTION .text

_start:
    mov     eax, 3
    mov     ebx, 0
    mov     ecx, buf
    mov     edx, 255
    int     0x80

    mov     esi, buf
    call    skip_spaces
    call    parse_int

    cmp     eax, 5
    jge     .lo_ok
    mov     eax, 5
.lo_ok:
    cmp     eax, 50
    jle     .hi_ok
    mov     eax, 50
.hi_ok:
    mov     [n_val], eax

    xor     ecx, ecx
.fill:
    cmp     ecx, [n_val]
    jge     .fill_end
    mov     eax, ecx
    imul    eax, ecx
    lea     edx, [ecx + ecx*2]
    sub     eax, edx
    add     eax, 7
    mov     [arr + ecx*4], eax
    inc     ecx
    jmp     .fill
.fill_end:

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_array
    mov     edx, msg_arr_len
    int     0x80

    xor     ecx, ecx
.ploop:
    cmp     ecx, [n_val]
    jge     .ploop_end
    push    ecx
    mov     eax, [arr + ecx*4]
    call    print_int32
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, ch_space
    mov     edx, 1
    int     0x80
    pop     ecx
    inc     ecx
    jmp     .ploop
.ploop_end:

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, ch_nl
    mov     edx, 1
    int     0x80

    mov     eax, [arr]
    mov     ebx, eax
    mov     edx, eax
    xor     esi, esi
    xor     edi, edi

    mov     ecx, 1
.scan:
    cmp     ecx, [n_val]
    jge     .scan_end
    mov     eax, [arr + ecx*4]
    cmp     eax, ebx
    jge     .chk_max
    mov     ebx, eax
    mov     esi, ecx
.chk_max:
    cmp     eax, edx
    jle     .scan_next
    mov     edx, eax
    mov     edi, ecx
.scan_next:
    inc     ecx
    jmp     .scan
.scan_end:

    push    edi
    push    edx
    push    esi
    push    ebx

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_min
    mov     edx, msg_min_len
    int     0x80

    mov     eax, [esp]
    call    print_int32

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_idx
    mov     edx, msg_idx_len
    int     0x80

    mov     eax, [esp+4]
    call    print_int32

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, ch_nl
    mov     edx, 1
    int     0x80

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_max
    mov     edx, msg_max_len
    int     0x80

    mov     eax, [esp+8]
    call    print_int32

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_idx
    mov     edx, msg_idx_len
    int     0x80

    mov     eax, [esp+12]
    call    print_int32

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, ch_nl
    mov     edx, 1
    int     0x80

    add     esp, 16

    mov     eax, 1
    xor     ebx, ebx
    int     0x80

parse_int:
    xor     eax, eax
    xor     ecx, ecx
    cmp     byte [esi], '-'
    jne     .digits
    inc     esi
    mov     ecx, 1
.digits:
    movzx   edx, byte [esi]
    cmp     edx, '0'
    jl      .done
    cmp     edx, '9'
    jg      .done
    imul    eax, eax, 10
    sub     edx, '0'
    add     eax, edx
    inc     esi
    jmp     .digits
.done:
    test    ecx, ecx
    jz      .ret
    neg     eax
.ret:
    ret

skip_spaces:
    cmp     byte [esi], ' '
    je      .s
    cmp     byte [esi], 9
    je      .s
    cmp     byte [esi], ','
    je      .s
    ret
.s:
    inc     esi
    jmp     skip_spaces

print_int32:
    push    ecx
    push    edx
    push    edi
    mov     edi, numstr+31
    mov     byte [edi], 0
    dec     edi
    xor     ecx, ecx
    test    eax, eax
    jns     .positive
    neg     eax
    mov     ecx, 1
.positive:
    mov     ebx, 10
.dloop:
    xor     edx, edx
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    test    eax, eax
    jnz     .dloop
    test    ecx, ecx
    jz      .write
    mov     byte [edi], '-'
    dec     edi
.write:
    inc     edi
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, edi
    mov     edx, numstr+31
    sub     edx, edi
    int     0x80
    pop     edi
    pop     edx
    pop     ecx
    ret