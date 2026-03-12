BITS 32
GLOBAL _start

SECTION .data

msg_signed      db "SIGNED: a "
msg_signed_len  equ $-msg_signed

msg_unsigned    db "UNSIGNED: a "
msg_unsigned_len equ $-msg_unsigned

str_lt          db "< b", 10
str_lt_len      equ $-str_lt

str_eq          db "= b", 10
str_eq_len      equ $-str_eq

str_gt          db "> b", 10
str_gt_len      equ $-str_gt

msg_max_s       db "max_signed: "
msg_max_s_len   equ $-msg_max_s

msg_max_u       db "max_unsigned: "
msg_max_u_len   equ $-msg_max_u

SECTION .bss

buf     resb 256
numstr  resb 32
val_a   resd 1
val_b   resd 1

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
    mov     [val_a], eax

    call    skip_spaces
    call    parse_int
    mov     [val_b], eax

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_signed
    mov     edx, msg_signed_len
    int     0x80
    call    cmp_signed

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_unsigned
    mov     edx, msg_unsigned_len
    int     0x80
    call    cmp_unsigned

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_max_s
    mov     edx, msg_max_s_len
    int     0x80
    mov     eax, [val_a]
    mov     ebx, [val_b]
    cmp     eax, ebx
    jge     .pick_a_s
    mov     eax, ebx
.pick_a_s:
    call    print_int32

    mov     eax, 4
    mov     ebx, 1
    mov     ecx, msg_max_u
    mov     edx, msg_max_u_len
    int     0x80
    mov     eax, [val_a]
    mov     ebx, [val_b]
    cmp     eax, ebx
    jae     .pick_a_u
    mov     eax, ebx
.pick_a_u:
    call    print_uint32

    mov     eax, 1
    xor     ebx, ebx
    int     0x80

cmp_signed:
    mov     eax, [val_a]
    cmp     eax, [val_b]
    jl      .s_lt
    jg      .s_gt
    mov     ecx, str_eq
    mov     edx, str_eq_len
    jmp     .s_print
.s_lt:
    mov     ecx, str_lt
    mov     edx, str_lt_len
    jmp     .s_print
.s_gt:
    mov     ecx, str_gt
    mov     edx, str_gt_len
.s_print:
    mov     eax, 4
    mov     ebx, 1
    int     0x80
    ret

cmp_unsigned:
    mov     eax, [val_a]
    cmp     eax, [val_b]
    jb      .u_lt
    ja      .u_gt
    mov     ecx, str_eq
    mov     edx, str_eq_len
    jmp     .u_print
.u_lt:
    mov     ecx, str_lt
    mov     edx, str_lt_len
    jmp     .u_print
.u_gt:
    mov     ecx, str_gt
    mov     edx, str_gt_len
.u_print:
    mov     eax, 4
    mov     ebx, 1
    int     0x80
    ret

parse_int:
    xor     eax, eax
    xor     ecx, ecx
    cmp     byte [esi], '-'
    jne     .pi_digits
    inc     esi
    mov     ecx, 1
.pi_digits:
    movzx   edx, byte [esi]
    cmp     edx, '0'
    jl      .pi_done
    cmp     edx, '9'
    jg      .pi_done
    imul    eax, eax, 10
    sub     edx, '0'
    add     eax, edx
    inc     esi
    jmp     .pi_digits
.pi_done:
    test    ecx, ecx
    jz      .pi_ret
    neg     eax
.pi_ret:
    ret

skip_spaces:
    cmp     byte [esi], ' '
    je      .skip
    cmp     byte [esi], 9
    je      .skip
    cmp     byte [esi], ','
    je      .skip
    ret
.skip:
    inc     esi
    jmp     skip_spaces

print_int32:
    mov     edi, numstr+31
    mov     byte [edi], 10
    dec     edi
    mov     ecx, 0
    test    eax, eax
    jns     .p_positive
    neg     eax
    mov     ecx, 1
.p_positive:
    mov     ebx, 10
.p_loop:
    xor     edx, edx
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    test    eax, eax
    jnz     .p_loop
    test    ecx, ecx
    jz      .p_write
    mov     byte [edi], '-'
    dec     edi
.p_write:
    inc     edi
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, edi
    mov     edx, numstr+32
    sub     edx, edi
    int     0x80
    ret

print_uint32:
    mov     edi, numstr+31
    mov     byte [edi], 10
    dec     edi
    mov     ebx, 10
.pu_loop:
    xor     edx, edx
    div     ebx
    add     dl, '0'
    mov     [edi], dl
    dec     edi
    test    eax, eax
    jnz     .pu_loop
    inc     edi
    mov     eax, 4
    mov     ebx, 1
    mov     ecx, edi
    mov     edx, numstr+32
    sub     edx, edi
    int     0x80
    ret