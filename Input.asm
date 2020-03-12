%include "InputMacro.inc"
%include "Macros.inc"

section .data

	kernel_array DW 0, -1, 0   ; defines the 3x3 filter kernel.
			     DW -1, 5, -1
				 DW 0, -1, 0

	new_file db "new_file.txt", 0 ; file terminated in 0
	read_file_img db "unfiltered_img.txt", 0 	; file with no filtered image.
	sharp_file db "sharpened.txt", 0   			; file with sharpened image.
	oversharp_file db "oversharpened.txt", 0	; file with oversharpened image.

section .bss
	;image_array resb 1920 * 1080 		; reserves memory for image data, maximum res is 1920x1080.
	current_pix resb 4

section .text
	global _start

_start:
	request_width   ; prompts request to enter image width.
	get_width 		; gets width by user input.
	request_height	; prompts request to enter image height.
	get_height		; gets width by user input.

	call _readFile
    call _writeFile
	
	mov rax, SYS_EXIT
	mov rdi, 0
	syscall			; exits the program.

_applySharpening:



_readFile:
    mov rax, SYS_OPEN
    mov rdi, read_file_img
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, current_pix
    mov rdx, 4
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    
    print current_pix
    ret

_writeFile:

	mov rax, SYS_OPEN
    mov rdi, new_file
    mov rsi, O_CREAT + O_WRONLY
    mov rdx, 0644o
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, current_pix
    mov rdx, 4
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall
	ret

