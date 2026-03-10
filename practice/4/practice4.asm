BITS 32
GLOBAL _start

SECTION .data
nl db 10

SECTION .bss
buf resb 256
outbuf resb 16

SECTION .text
_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 255
    int 0x80

    mov esi, buf
    xor eax, eax
    xor ebx, ebx

parse_loop:
    mov bl, [esi]
    cmp bl, 10
    je parse_done
    cmp bl, 13
    je parse_done
    cmp bl, 0
    je parse_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp parse_loop

parse_done:
    mov ax, ax

    movzx eax, ax
    mov edi, outbuf
    add edi, 15
    mov byte [edi], 0
    dec edi

    cmp eax, 0
    jne convert_loop
    mov byte [edi], '0'
    jmp print

convert_loop:
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz convert_loop
    inc edi

print:
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, outbuf
    add edx, 15
    sub edx, edi
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80