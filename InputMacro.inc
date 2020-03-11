section .data
	width_text db "Inserte ancho de la imagen: "
	height_text db "Inserte largo de la imagen: "

section .bss
    width resb 5
	height resb 6

; Prints request to input image width
%macro request_width 0
	mov rax, 1
	mov rdi, 1
	mov rsi, width_text
	mov rdx, 28
	syscall
%endmacro

; Prints request to input image height
%macro request_height 0
	mov rax, 1
	mov rdi, 1
	mov rsi, height_text
	mov rdx, 28
	syscall
%endmacro

; Gets width of image by user input
%macro get_width 0
	mov rax, 0
	mov rdi, 0
	mov rsi, width
	mov rdx, 5
	syscall
%endmacro

; Gets height of image by user input
%macro get_height 0
	mov rax, 0
	mov rdi, 0
	mov rsi, height
	mov rdx, 6
	syscall
%endmacro