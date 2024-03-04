bits	64
section	.data
n:
	db	4
matrix:
	dq  16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
section	.text
global	_start
_start:
    mov     al, [n]
    jz error
    mov     r14b, al    ; length of diagonal (right)
    mov     r13b, al    ; length of diagonal (down)
    mov     r15b, al
    inc     r15w        ; r15w = row delta
    mov     al, cl
    mov     r9, matrix
    jmp iter1

sort:
    ; r8b - length
    ; r9 - begin pointer
    mov     r10b, r8b
    dec     r10b        ; r10w = step
    jmp outer_condition
outer_loop:
    mov     cl, r8b
    sub     cl, r10b
    xor     edi, edi

inner_loop:
    mov     rax, r10
    mul     r15w
    add     rax, rdi
    mov     r11, [r9 + 8 * rdi]
    mov     r12, [r9 + 8 * rax]

    cmp     r11, r12
    jle     skip
    mov     [r9 + 8 * rdi], r12
    mov     [r9 + 8 * rax], r11
skip:
    add     edi, r15d
    loop inner_loop
    mov     ax, r10w
    mov     bl, 2
    div     bl
    movzx   r10w, al

outer_condition:
    cmp     r10w, 1
    jae outer_loop
    jmp iter1

iter1:
    cmp     r14b, 1
    jbe iter2
    mov     r8b, r14b
    movzx   ax, byte [n]
    sub     rax, r14
    lea     r9, [matrix + 8 * rax]
    dec     r14b
    jmp sort

iter2:
    dec     r13b
    cmp     r13b, 1
    jbe finish
    mov     r8b, r13b
    movzx   ax, byte [n]
    sub     rax, r13
    movzx   bx, byte [n]
    mul     rbx
    lea     r9, [matrix + 8 * rax]
    jmp sort

finish:
    xor     edi, edi
    jmp	exit

error:
	mov edi, 1
exit:
	mov	eax, 60
	syscall
