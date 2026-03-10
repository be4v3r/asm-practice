BITS 32
GLOBAL _start

SECTION .data
nl db 10
K dd 7

SECTION .bss
buf resb 256
outbuf resb 32
x resd 1
sum resd 1
len resd 1

SECTION .text

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 255
    int 0x80

    mov esi, buf
    call atoi
    mov [x], eax

    mov eax, [x]
    xor ebx, ebx
    xor ecx, ecx

sum_loop:
    cmp eax, 0
    je sum_done
    xor edx, edx
    mov edi, 10
    div edi
    add ebx, edx
    inc ecx
    jmp sum_loop

sum_done:
    mov [sum], ebx
    mov [len], ecx

    mov eax, [sum]
    call itoa
    call print

    mov eax, [len]
    call itoa
    call print

    mov eax, [sum]
    add eax, [K]
    call itoa
    call print

    mov eax, 1
    xor ebx, ebx
    int 0x80

atoi:
    xor eax, eax
atoi_loop:
    mov bl, [esi]
    cmp bl, 10
    je atoi_done
    cmp bl, 13
    je atoi_done
    cmp bl, 0
    je atoi_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp atoi_loop
atoi_done:
    ret

itoa:
    mov edi, outbuf
    add edi, 31
    mov byte [edi], 0
    dec edi
    cmp eax, 0
    jne itoa_loop
    mov byte [edi], '0'
    jmp itoa_done

itoa_loop:
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz itoa_loop
    inc edi
itoa_done:
    mov esi, edi
    ret

print:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, outbuf
    add edx, 31
    sub edx, esi
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80
    ret