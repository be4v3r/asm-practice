section .bss
    input_buf   resb 2048
    arr         resd 200
    rev_arr     resd 200
 
section .data
    msg_orig  db "Original:  "
    msg_orig_l equ $ - msg_orig
    msg_rev   db "Reversed:  "
    msg_rev_l  equ $ - msg_rev
    msg_yes   db "PALINDROME: YES", 10
    msg_yes_l  equ $ - msg_yes
    msg_no    db "PALINDROME: NO", 10
    msg_no_l   equ $ - msg_no
    space     db " "
    newline   db 10
    out_buf   times 32 db 0
 
section .text
global _start
 
%macro WRITE 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro
 
_start:
    ; читаємо stdin
    mov eax, 3
    xor ebx, ebx
    mov ecx, input_buf
    mov edx, 2048
    int 0x80
 
    ; парсимо n → EBP
    mov esi, input_buf
    call skip_spaces
    call parse_int
    mov ebp, eax
 
    ; читаємо n чисел у arr
    xor edi, edi
.read_loop:
    cmp edi, ebp
    jge .read_done
    call skip_spaces
    call parse_int
    mov [arr + edi*4], eax
    inc edi
    jmp .read_loop
.read_done:
 
    ; копіюємо arr → rev_arr через rep movsd
    mov ecx, ebp
    mov esi, arr
    mov edi, rev_arr
    cld
    rep movsd
 
    ; реверсуємо rev_arr: swap лівого і правого
    xor eax, eax
    mov ebx, ebp
    dec ebx
.rev_loop:
    cmp eax, ebx
    jge .rev_done
    mov ecx, [rev_arr + eax*4]
    mov edx, [rev_arr + ebx*4]
    mov [rev_arr + eax*4], edx
    mov [rev_arr + ebx*4], ecx
    inc eax
    dec ebx
    jmp .rev_loop
.rev_done:
 
    ; виводимо оригінальний масив
    WRITE msg_orig, msg_orig_l
    xor edi, edi
.print_orig:
    cmp edi, ebp
    jge .orig_done
    mov eax, [arr + edi*4]
    call print_int
    mov eax, ebp
    dec eax
    cmp edi, eax
    je .orig_nsp
    WRITE space, 1
.orig_nsp:
    inc edi
    jmp .print_orig
.orig_done:
    WRITE newline, 1
 
    ; виводимо реверсований масив
    WRITE msg_rev, msg_rev_l
    xor edi, edi
.print_rev:
    cmp edi, ebp
    jge .rev_done2
    mov eax, [rev_arr + edi*4]
    call print_int
    mov eax, ebp
    dec eax
    cmp edi, eax
    je .rev_nsp
    WRITE space, 1
.rev_nsp:
    inc edi
    jmp .print_rev
.rev_done2:
    WRITE newline, 1
 
    ; паліндром: arr[i] == rev_arr[i] для всіх i
    xor edi, edi
.pal_loop:
    cmp edi, ebp
    jge .is_pal
    mov eax, [arr + edi*4]
    mov ecx, [rev_arr + edi*4]
    cmp eax, ecx
    jne .not_pal
    inc edi
    jmp .pal_loop
.is_pal:
    WRITE msg_yes, msg_yes_l
    jmp .exit
.not_pal:
    WRITE msg_no, msg_no_l
 
.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
 
 
; пропускає пробіли/таби/переводи рядка
skip_spaces:
    push eax
.ss_lp:
    mov al, [esi]
    cmp al, ' '
    je .ss_skip
    cmp al, 9
    je .ss_skip
    cmp al, 10
    je .ss_skip
    cmp al, 13
    je .ss_skip
    pop eax
    ret
.ss_skip:
    inc esi
    jmp .ss_lp
 
 
; десяткове ціле зі знаком з [ESI] → EAX; просуває ESI
parse_int:
    push ebx
    push ecx
    push edx
    xor eax, eax
    xor ecx, ecx
    cmp byte [esi], '-'
    jne .pi_lp
    inc ecx
    inc esi
.pi_lp:
    movzx ebx, byte [esi]
    cmp bl, '0'
    jl .pi_done
    cmp bl, '9'
    jg .pi_done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .pi_lp
.pi_done:
    test ecx, ecx
    jz .pi_ret
    neg eax
.pi_ret:
    pop edx
    pop ecx
    pop ebx
    ret
 
; виводить знакове ціле EAX у stdout
print_int:
    pushad
    lea edi, [out_buf + 30]
    mov byte [edi], 0
    dec edi
    xor ecx, ecx
    test eax, eax
    jns .pi2_pos
    inc ecx
    neg eax
.pi2_pos:
    mov ebx, 10
.pi2_lp:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .pi2_lp
    test ecx, ecx
    jz .pi2_nosign
    mov byte [edi], '-'
    dec edi
.pi2_nosign:
    inc edi
    lea edx, [out_buf + 31]
    sub edx, edi
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80
    popad
    ret
 
