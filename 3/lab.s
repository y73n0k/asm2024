bits	64
section	.data

msghelp:
	db	`Please provide FILE env variable\n`
msghelp_len equ $-msghelp

delims:
	db	0x9, 0xA, 0x20
delims_len equ $-delims

env_file:
	db	`FILE=`
env_file_len equ $-env_file

cur_char:
	db	0
prev_char:
	db	0

size	equ	1024

buffer:
	times size	db	0

section	.text
global	_start

print:
	; buffer, length
	xchg	rsi, rdx
	xchg	rdi, rsi
	xor		rdi, rdi
	mov		rax, 1
	syscall
	ret

print_word:
	; fd, start of word, length
	push	rdx
	mov		rdx, 0
	call	lseek
	pop		rax
	
	mov		rdx, 0
	mov		r9, size
	div		r9
	mov		rcx, rax
	push	rdx

	or		rcx, rcx
	push	rdi
	jz		word_reminder

word_loop:
	mov		rsi, buffer
	mov		rdx, size
	push 	rcx
	call	read
	pop		rcx
	
	push	rdi
	mov		rdi, rsi
	mov		rsi, size
	push 	rcx
	call	print
	pop		rcx
	pop		rdi
	loop	word_loop

word_reminder:
	pop		rdi
	pop		rdx
	mov		rsi, buffer
	push	rdx
	call	read
	mov		rdi, buffer
	pop		rsi
	call	print

	lea		rdi, [delims + 2]
	mov		rsi, 1
	call	print
	ret

lseek:
	; fd, offset, whence
	mov		rax, 8
	syscall
	ret

read:
	; fd, buffer, size
	mov		rax, 0
	syscall
	ret

get_first_char:
	mov		rdi, r13
	mov		rsi, r15
	mov		rdx, 0
	call	lseek
	mov		rdi, r13
	mov		rsi, cur_char
	mov		rdx, 1
	call	read
	ret

eof:
	mov		rdi, r13
	mov		bl, byte [prev_char]
	call	get_first_char
	cmp		byte [cur_char], bl
	jne		endline
	mov		rdi, r13
	mov		rsi, r15
	mov		rdx, r14
	call	print_word
endline:
	lea		rdi, [delims + 1]
	mov		rsi, 1
	call	print
	jmp		close


length:
	xor		rsi, rsi
len_loop:
	cmp		byte [rdi], 0
	je		len_end
	inc		rdi
	inc		rsi
	jmp		len_loop
len_end:
	mov		rax, rsi
	ret

_start:
	pop		rcx
skip_arguments:
	pop		rdi
	loop	skip_arguments
	pop		rdi

search_env:
	pop		rdi
	or		rdi, rdi
	jz		kapec

	mov		rsi, env_file
	mov		rcx, env_file_len
	push	rdi
	cld
	repe	cmpsb
	pop		rdi
	je		open
	jmp		search_env

kapec:
	mov		rdi, msghelp
	mov		rsi, msghelp_len
	call	print

	mov		rdi, 1
	jmp		exit

open:
	add		rdi, env_file_len
	xor		rsi, rsi
	mov		rax, 2
	syscall

	cmp		rax, 0
	jl		error

	mov		r13, rax	; r13 - file descriptor
	xor 	r14, r14	; r14 - length of word
	xor		r15, r15	; r15 - offset of word start

main_loop:
	mov		al, byte [cur_char]
	mov		byte [prev_char], al
	mov		rdi, r13
	mov		rsi, cur_char
	mov		rdx, 1
	call	read
	or		rax, rax
	jz		eof

	mov		rdi, delims
	mov		al, byte [cur_char]
	mov		r12b, al
	mov		rcx, delims_len
	cld
	repne	scasb
	je		offset_processing
	inc		r14
	jmp		main_loop

offset_processing:
	or		r14, r14
	jnz		word_end
	inc		r15

	cmp		r12b, 0xA
	jne		not_newline
	lea		rdi, [delims + 1]
	mov		rsi, 1
	call	print
not_newline:
	jmp		main_loop

word_end:
	mov		bl, byte [prev_char]	; rbx - last char

	call	get_first_char

	cmp		byte [cur_char], bl
	jne		skip_word
	mov		rdi, r13
	mov		rsi, r15
	mov		rdx, r14
	call	print_word

skip_word:
	add		r15, r14
	mov		rdi, r13
	mov		rsi, r15
	mov		rdx, 0
	call 	lseek

	xor		r14, r14
	jmp 	main_loop

close:
	mov		rdi, r13
	mov		rax, 3
	syscall

	xor		rdi, rdi
	jmp		exit

error:
	mov		rdi, rax

exit:
	mov		rax, 60
	syscall
