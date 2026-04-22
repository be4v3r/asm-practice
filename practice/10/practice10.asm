section .data
    msg_prompt  db "Enter x p q r (e.g. 146 4 1 4):", 0x0A, 0
    msg_plen    equ $ - msg_prompt - 1
    msg_bin     db "Binary: ", 0
    msg_bin_len equ $ - msg_bin - 1
    msg_pop     db "Popcount: ", 0
    msg_pop_len equ $ - msg_pop - 1
    msg_res     db "Result: ", 0
    msg_res_len equ $ - msg_res - 1
    newline     db 0x0A
    space_ch    db " "

section .bss
    bitbuf      resb 40
    outbuf      resb 12
    inbuf       resb 64
    val_p       resd 1
    val_q       resd 1
    val_r       resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_prompt
    mov edx, msg_plen
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, inbuf
    mov edx, 64
    int 0x80

    mov esi, inbuf

    call parse_uint
    mov edi, eax
    call skip_ws

    call parse_uint
    mov [val_p], eax
    call skip_ws

    call parse_uint
    mov [val_q], eax
    call skip_ws

    call parse_uint
    mov [val_r], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, msg_bin_len
    int 0x80

    mov eax, edi
    call print_binary

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, msg_pop_len
    int 0x80

    mov eax, edi
    call popcount
    call print_uint

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, edi

    mov ecx, [val_p]
    mov esi, 1
    shl esi, cl
    or  eax, esi

    mov ecx, [val_q]
    mov esi, 1
    shl esi, cl
    or  eax, esi

    mov ecx, [val_r]
    mov esi, 1
    shl esi, cl
    not esi
    and eax, esi

    push eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_res
    mov edx, msg_res_len
    int 0x80

    pop eax
    call print_uint

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

parse_uint:
    xor eax, eax
.pu_loop:
    movzx ecx, byte [esi]
    cmp ecx, '0'
    jl  .pu_done
    cmp ecx, '9'
    jg  .pu_done
    sub ecx, '0'
    imul eax, eax, 10
    add eax, ecx
    inc esi
    jmp .pu_loop
.pu_done:
    ret

skip_ws:
.sw_loop:
    movzx ecx, byte [esi]
    cmp ecx, ' '
    je  .sw_skip
    cmp ecx, 0x0A
    je  .sw_skip
    cmp ecx, 0x0D
    je  .sw_skip
    ret
.sw_skip:
    inc esi
    jmp .sw_loop

print_binary:
    push ebx
    push esi
    push edi
    mov  esi, bitbuf
    mov  ecx, 32
.fill_bits:
    mov  edx, eax
    and  edx, 0x80000000
    shr  edx, 31
    add  dl, '0'
    mov  [esi], dl
    inc  esi
    shl  eax, 1
    dec  ecx
    jnz  .fill_bits
    xor  ecx, ecx
.pb_loop:
    cmp  ecx, 32
    je   .pb_done
    test ecx, ecx
    jz   .pb_char
    mov  edx, ecx
    and  edx, 3
    jnz  .pb_char
    push ecx
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, space_ch
    mov  edx, 1
    int  0x80
    pop  ecx
.pb_char:
    push ecx
    lea  ecx, [bitbuf + ecx]
    mov  eax, 4
    mov  ebx, 1
    mov  edx, 1
    int  0x80
    pop  ecx
    inc  ecx
    jmp  .pb_loop
.pb_done:
    pop  edi
    pop  esi
    pop  ebx
    ret

popcount:
    xor ecx, ecx
.pc_loop:
    test eax, eax
    jz   .pc_done
    mov  edx, eax
    and  edx, 1
    add  ecx, edx
    shr  eax, 1
    jmp  .pc_loop
.pc_done:
    mov  eax, ecx
    ret

print_uint:
    push ebx
    push esi
    lea  esi, [outbuf + 11]
    mov  byte [esi], 0
    test eax, eax
    jnz  .pu2_loop
    dec  esi
    mov  byte [esi], '0'
    jmp  .pu2_print
.pu2_loop:
    test eax, eax
    jz   .pu2_print
    xor  edx, edx
    mov  ecx, 10
    div  ecx
    add  dl, '0'
    dec  esi
    mov  [esi], dl
    jmp  .pu2_loop
.pu2_print:
    mov  ecx, esi
    lea  edx, [outbuf + 11]
    sub  edx, esi
    mov  eax, 4
    mov  ebx, 1
    int  0x80
    pop  esi
    pop  ebx
    ret