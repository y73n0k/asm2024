bits 64

section .text

global flip

flip:
    ; flip(char *buffer, int width, int height, int channels)
    ;           edi          esi        edx         ecx
    push    rbx
    push    r14
    push    r15

    mov     r8, rdx     ; r8d - height
    mov     r9, rcx     ; r9d - channels
     
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

            mov     rcx, r9
            .channel_loop:

                mov     r14b, byte [rdi + r10]
                mov     r15b, byte [rdi + r11]
                mov     byte [rdi + r10], r15b
                mov     byte [rdi + r11], r14b

                inc     r10
                inc     r11

                loop    .channel_loop
            
            pop     rcx
            loop    .width_loop

        pop     rcx
        loop    .height_loop

    pop     r15
    pop     r14
    pop     rbx
    ret
