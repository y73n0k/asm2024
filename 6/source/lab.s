bits 64

section .text

global flip

flip:
    ; flip(char *buffer, int width, int height, int channels, char *new_buffer)
    ;           edi         esi        edx         ecx             r8
    push    rbp
    mov     rbp, rsp
    
    push    rbx
    push    r13
    push    r14
    push    r15

    mov     r13, r8         ; r13 - new_buffer
    mov     r8, rdx         ; r8d - height
    mov     r9, rcx         ; r9d - channels
     
    mov     rax, rdx
    sar     rax, 1

    xor     r10, r10    ; r10d - index

    mov     rbx, rax    ; height / 2
    mov     rcx, rax

    .height_loop:
        push    rcx

        mov     rcx, rsi
        .width_loop:
            push    rcx
            
            mov     rax, [rsp + 8]
            dec     rax
            add     rax, rbx
            mul     rsi
            add     rax, rsi
            sub     rax, rcx
            mul     r9
            mov     r11, rax    ; r11 - opposite_index

            movups  xmm0, [rdi + r10]
            movups  xmm1, [rdi + r11]
            movups  [r13 + r10], xmm1
            movups  [r13 + r11], xmm0

            add     r10, r9
            add     r11, r9

            pop     rcx
            loop    .width_loop

        pop     rcx
        loop    .height_loop


    pop     r15
    pop     r14
    pop     r13
    pop     rbx
    leave
    ret
