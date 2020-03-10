section .data
	width_text db "Inserte ancho de la imagen: "
	height_text db "Inserte largo de la imagen: "

section .bss
	width resb 16
	height resb 16

section .text
	global _start

_start:
	call _print_width
	call _get_width
	call _print_user_w
	call _print_height
	call _get_height
	call _print_user_h

	mov rax, 60
	mov rdi, 0
	syscall

_get_width:
	mov rax, 0
	mov rdi, 0
	mov rsi, width
	mov rdx, 16
	syscall
	ret 

_get_height:
	mov rax, 0
	mov rdi, 0
	mov rsi, height
	mov rdx, 16
	syscall
	ret 

_print_user_w:
	mov rax, 1
	mov rdi, 1
	mov rsi, width
	mov rdx, 16
	syscall
	ret

_print_user_h:
	mov rax, 1
	mov rdi, 1
	mov rsi, height
	mov rdx, 16
	syscall
	ret

_print_width:
	mov rax, 1
	mov rdi, 1
	mov rsi, width_text
	mov rdx, 28
	syscall
	ret

_print_height:
	mov rax, 1
	mov rdi, 1
	mov rsi, height_text
	mov rdx, 28
	syscall
	ret
