BITS 32
GLOBAL _start

SECTION .data
minus1   db "-1",10
newline  db 10
space_ch db 32

SECTION .bss
inbuf    resb 4096
numbers  resd 100
indices  resd 100
ibuf     resb 12

SECTION .text

_start:
    mov  eax, 3
    mov  ebx, 0
    mov  ecx, inbuf
    mov  edx, 4095
    int  0x80

    mov  esi, inbuf

    call skip_ws
    call parse_uint
    mov  ebx, eax

    cmp  ebx, 0
    je   do_exit
    cmp  ebx, 100
    jg   do_exit

    xor  ecx, ecx
.read_loop:
    cmp  ecx, ebx
    jge  .read_done
    call skip_ws
    call parse_uint
    mov  [numbers + ecx*4], eax
    inc  ecx
    jmp  .read_loop
.read_done:

    call skip_ws
    call parse_uint
    mov  edi, eax

    xor  ecx, ecx
    xor  edx, edx

.search:
    cmp  ecx, ebx
    jge  .search_done
    mov  eax, [numbers + ecx*4]
    cmp  eax, edi
    jne  .no_hit
    mov  [indices + edx*4], ecx
    inc  edx
.no_hit:
    inc  ecx
    jmp  .search
.search_done:

    cmp  edx, 0
    jne  .print_first

    push edx
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, minus1
    mov  edx, 3
    int  0x80
    pop  edx
    jmp  .print_count

.print_first:
    mov  eax, [indices]
    call print_uint
    call print_nl

.print_count:
    push edx
    mov  eax, edx
    call print_uint
    call print_nl
    pop  edx

    cmp  edx, 0
    je   .list_done

    xor  ecx, ecx
.list_loop:
    push ecx
    push edx
    mov  eax, [indices + ecx*4]
    call print_uint
    pop  edx
    pop  ecx
    inc  ecx
    cmp  ecx, edx
    jge  .list_done
    push ecx
    push edx
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, space_ch
    mov  edx, 1
    int  0x80
    pop  edx
    pop  ecx
    jmp  .list_loop

.list_done:
    call print_nl

do_exit:
    mov  eax, 1
    xor  ebx, ebx
    int  0x80


skip_ws:
    mov  al, [esi]
    cmp  al, 32
    je   .adv
    cmp  al, 9
    je   .adv
    cmp  al, 13
    je   .adv
    cmp  al, 10
    je   .adv
    ret
.adv:
    inc  esi
    jmp  skip_ws


parse_uint:
    xor  eax, eax
.digit:
    movzx ecx, byte [esi]
    cmp  ecx, 48
    jb   .done
    cmp  ecx, 57
    ja   .done
    sub  ecx, 48
    imul eax, eax, 10
    add  eax, ecx
    inc  esi
    jmp  .digit
.done:
    ret


print_uint:
    push ebx
    push ecx
    push edx
    push esi

    mov  esi, ibuf + 11
    mov  byte [esi], 0
    mov  ecx, 10

    test eax, eax
    jnz  .cvt
    dec  esi
    mov  byte [esi], 48
    jmp  .write

.cvt:
    xor  edx, edx
    div  ecx
    add  dl, 48
    dec  esi
    mov  [esi], dl
    test eax, eax
    jnz  .cvt

.write:
    mov  ecx, esi
    mov  edx, ibuf + 11
    sub  edx, esi
    mov  eax, 4
    mov  ebx, 1
    int  0x80

    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    ret


print_nl:
    push eax
    push ebx
    push ecx
    push edx
    mov  eax, 4
    mov  ebx, 1
    mov  ecx, newline
    mov  edx, 1
    int  0x80
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret