%include "InputMacro.inc"
%include "Macros.inc"

section .data

	kernel_array DW 0, -1, 0   ; defines the 3x3 filter kernel.
			     DW -1, 5, -1
				 DW 0, -1, 0

	read_file_img db "unfiltered_img.txt", 0 	; file with no filtered image.
	sharp_file db "sharpened.txt", 0   			; file with sharpened image.
	oversharp_file db "oversharpened.txt", 0	; file with oversharpened image.

section .bss
	image_array resb 1920 * 1080 		; reserves memory for image data, maximum res is 1920x1080.

section .text
	global _start

_start:
	request_width   ; prompts request to enter image width.
	get_width 		; gets width by user input.
	request_height	; prompts request to enter image height.
	get_height		; gets width by user input.

	call _readFile
	
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall			; exits the program.

_readFile:
	mov rax, SYS_OPEN
    mov rdi, filename
    mov rsi, O_RDWR
    mov rdx, 0644o ; TODO: change this number to the correct one.
    syscall
