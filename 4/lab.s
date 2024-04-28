bits	64
section	.data
msg0:
	db	"Input prec", 10, 0
msg1:
	db	"Input x", 10, 0
msg2:
	db	"%f", 0
msg3:
	db	"atan(%.10f) = %.10f", 10, 0
msg4:
	db	"myatan(%.10f)=%.10f", 10, 0
string:
    db	"%.10f", 10, 0
file_name:
    db  "result", 0
mode:
    db  "w", 0
one:
    dd	1.0
two:
    dd	2.0
n_one:
    dd	-1.0

section	.text

extern	printf
extern	scanf

extern  fprintf
extern  fopen
extern  fclose

extern	fabsf
extern	atanf

myatan:
    ; rdi - stream, xmm0 - x, xmm1 - prec
    enter   64, 0
    ; [rbp-48] - member
    ; [rbp-40] - n
    ; [rbp-32] - stream
    ; [rbp-24] - res
    ; [rbp-16] - prec
    ; [rbp-8] - x
    movss   [rbp-48], xmm0
    mov     [rbp-32], rdi
    movss   [rbp-24], xmm0
    movss   [rbp-16], xmm1
    movss   [rbp-8], xmm0
    movss   xmm3, [one]
    movss   [rbp-40], xmm3
.loop:
    movss   xmm0, [rbp-48]
    call    fabsf
    ucomiss xmm0, [rbp-16]
    jbe     .finish

    movss   xmm0, [rbp-48]
    mulss   xmm0, [n_one]
    movss   xmm1, [rbp-8]
    mulss   xmm0, xmm1
    mulss   xmm0, xmm1
    movss   xmm2, [rbp-40]
    mulss   xmm0, xmm2
    addss   xmm2, [two]
    divss   xmm0, xmm2
    movss   [rbp-40], xmm2
    movss   [rbp-48], xmm0
    movss   xmm3, [rbp-24]
    addss   xmm3, xmm0
    movss   [rbp-24], xmm3

    cvtss2sd xmm0, xmm0
    mov     rdi, [rbp-32]
    mov     rsi, string
    mov     rax, 1
    call    fprintf

    jmp     .loop

.finish:
    movss   xmm0, [rbp-24]
    leave
	ret


global	main

main:
	enter       32, 0
    ; [rbp-32] - FILE *
    ; [rbp-24] - prec
    ; [rbp-16] - res
    ; [rbp-8] - x

    mov         rdi, file_name
    mov         rsi, mode
    call        fopen
    test        rax, rax
    jz          .file_error
    mov         [rbp-32], rax

	mov         rdi, msg1
	xor         rax, rax
	call	    printf

	mov         rdi, msg2
	lea         rsi, [rbp-8]
	call	    scanf

	movss	    xmm0, [rbp-8]
    call        fabsf
    ucomiss     xmm0, [one]
    jae         .too_big

    mov         rdi, msg0
	xor         rax, rax
	call	    printf

    mov         rdi, msg2
	lea         rsi, [rbp-24]
	mov         rax, rax
	call	    scanf

    movss       xmm0, [rbp-8]
	call	    atanf

	movss	    [rbp-16], xmm0
	mov         rdi, msg3
	cvtss2sd    xmm0, [rbp-8]
	cvtss2sd    xmm1, [rbp-16]
	mov	        rax, 2
	call        printf

    mov         rdi, [rbp-32]
	movss       xmm0, [rbp-8]
    movss       xmm1, [rbp-24]
	call        myatan

	movss       [rbp-16], xmm0
	mov         rdi, msg4
	cvtss2sd    xmm0, [rbp-8]
    cvtss2sd    xmm1, [rbp-16]
	mov	        rax, 2
	call        printf

    mov         rdi, [rbp-32]
    call        fclose

    xor         rax, rax
    jmp         .return

.file_error:
    mov         rax, 2
    jmp         .return

.too_big:
    mov         rdi, [rbp-32]
    call        fclose
    mov         rax, 1

.return:
	leave
	ret
