bits	64
;	res=(a^3 + b^3)/(a^2*c - b^2*d + e)
section	.data
res:
	dq	0
a:
	dq	37875
b:
	dd	94843024
c:
	dd	3951080645
d:
	db	189
e:
	dw	58554
section	.text
global	_start
_start:
	mov		rbx, [a]	; rbx = a
	mov		rax, rbx
	mul		rbx
	jc overflow
	mov		rcx, rax	; rcx = a^2

	mov		esi, [b]	; esi = b
	mov		eax, esi
	mul		esi
	shl		rdx, 32
	or		rax, rdx
	mov		rdi, rax	; rdi = b^2

	mul		rsi
	mov		r8, rdx
	mov		r9, rax		; r8:r9 = b^3

	mov		rax, rbx
	mul		rcx			; rdx:rax = a^3
	add		r9, rax
	adc		r8, rdx		; r8:r9 = a^3 + b^3
	jc overflow

	mov		eax, [c]
	mul		rcx			; rcx = a^2 * c
	jc overflow
	mov		bx, [e]
	add		rax, rbx
	jc overflow
	mov		rcx, rax	; rcx = a^2*c + e

	mov		rax, rdi	; b^2
	movzx	bx, byte [d]
	mul		rbx
	jc overflow
	sub		rcx, rax	; rcx = a^2*c - b^2*d + e
	jc overflow

	mov		rdx, r8
	mov		rax, r9
	div		rcx

	mov		[res], rax

	xor		rdi, rdi
	jmp	exit

overflow:
	mov edi, 1
exit:
	mov	eax, 60
	syscall