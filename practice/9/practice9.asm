section .bss
    inbuf   resb 16
    freq    resd 10
    linebuf resb 80           

section .text
global _start

_start:

    mov  eax, 3
    mov  ebx, 0
    mov  ecx, inbuf
    mov  edx, 16
    int  0x80

    mov  esi, inbuf
    xor  ebp, ebp
.parse_loop:
    movzx eax, byte [esi]
    inc   esi
    cmp   al, '0'
    jb    .parse_done
    cmp   al, '9'
    ja    .parse_done
    sub   al, '0'
    imul  ebp, ebp, 10
    add   ebp, eax
    jmp   .parse_loop
.parse_done:

    mov  edi, freq
    xor  eax, eax
    mov  ecx, 10
    rep  stosd

    mov  ebx, 12345

.gen_loop:
    test ebp, ebp
    jz   .gen_done

    mov  eax, 1103515245
    imul eax, ebx
    add  eax, 12345
    and  eax, 0x7FFFFFFF
    mov  ebx, eax

    xor  edx, edx
    mov  ecx, 10
    div  ecx

    inc  dword [freq + edx*4]

    dec  ebp
    jmp  .gen_loop

.gen_done:

    xor  ebx, ebx

.print_loop:
    cmp  ebx, 10
    jge  .exit

    mov  edi, linebuf

    mov  al, bl
    add  al, '0'
    stosb
    mov  al, ':'
    stosb
    mov  al, ' '
    stosb

    mov  eax, [freq + ebx*4]
    push eax

    mov  ecx, eax
    test ecx, ecx
    jz   .hashes_done
    mov  al, '#'
.hash_loop:
    stosb
    loop .hash_loop
.hashes_done:

    mov  al, ' '
    stosb
    mov  al, '('
    stosb

    pop  eax
    push ebx

    xor  ecx, ecx
.to_ascii:
    xor  edx, edx
    push ecx
    mov  ecx, 10
    div  ecx
    pop  ecx
    push edx
    inc  ecx
    test eax, eax
    jnz  .to_ascii

.write_digits:
    pop  eax
    add  al, '0'
    stosb
    loop .write_digits

    mov  al, ')'
    stosb
    mov  al, 10
    stosb

    mov  edx, edi
    sub  edx, linebuf
    pop  ebx
    push ebx
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, linebuf
    int  0x80
    pop  ebx

    inc  ebx
    jmp  .print_loop

.exit:
    mov  eax, 1
    xor  ebx, ebx
    int  0x80