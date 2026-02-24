; practice3.asm
; I/O: int 80h
; blocks: I/O, parse, math/logic, loops, memory

BITS 32
GLOBAL _start

SECTION .data
prompt db "practice3: see README.md",10
prompt_len equ $-prompt
nl db 10
D equ 20
M equ 6
A equ 10 + D
B equ 20 + M

SECTION .bss
buf resb 256
outbuf resb 32
x resd 1

SECTION .text
_start:
    mov eax,4
    mov ebx,1
    mov ecx,prompt
    mov edx,prompt_len
    int 0x80

    mov eax,3
    mov ebx,0
    mov ecx,buf
    mov edx,255
    int 0x80

    mov esi,buf
    call atoi
    mov [x],eax

    mov eax,[x]
    mov edi,outbuf
    call itoa
    mov edx,eax
    mov ecx,outbuf
    mov ebx,1
    mov eax,4
    int 0x80
    mov eax,4
    mov ebx,1
    mov ecx,nl
    mov edx,1
    int 0x80

    mov eax,[x]
    add eax,A
    mov edi,outbuf
    call itoa
    mov edx,eax
    mov ecx,outbuf
    mov ebx,1
    mov eax,4
    int 0x80
    mov eax,4
    mov ebx,1
    mov ecx,nl
    mov edx,1
    int 0x80

    mov eax,[x]
    sub eax,B
    mov edi,outbuf
    call itoa
    mov edx,eax
    mov ecx,outbuf
    mov ebx,1
    mov eax,4
    int 0x80
    mov eax,4
    mov ebx,1
    mov ecx,nl
    mov edx,1
    int 0x80

    mov eax,1
    xor ebx,ebx
    int 0x80

atoi:
    xor eax,eax
.parse_loop:
    mov bl,[esi]
    cmp bl,10
    je .done
    cmp bl,'0'
    jb .done
    cmp bl,'9'
    ja .done
    imul eax,eax,10
    sub bl,'0'
    movzx ebx,bl
    add eax,ebx
    inc esi
    jmp .parse_loop
.done:
    ret

itoa:
    push ebx
    push ecx
    push edx

    mov esi,edi
    xor ebx,ebx
    cmp eax,0
    jge .positive
    neg eax
    mov byte [esi],'-'
    inc esi
    mov bl,1

.positive:
    mov ecx,0
    mov edi,10
    cmp eax,0
    jne .convert
    mov byte [esi],'0'
    mov eax,1
    jmp .finish

.convert:
.rev_loop:
    xor edx,edx
    div edi
    add dl,'0'
    push edx
    inc ecx
    test eax,eax
    jnz .rev_loop

.write_loop:
    pop edx
    mov [esi],dl
    inc esi
    loop .write_loop

    mov eax,esi
    sub eax,outbuf
.finish:
    pop edx
    pop ecx
    pop ebx
    ret