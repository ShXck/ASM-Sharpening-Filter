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
	image_array resb 5		; reserves memory for image data, maximum res is 1920x1080.

section .text
	global _start

_start:
	request_width   ; prompts request to enter image width.
	get_width 		; gets width by user input.
	request_height	; prompts request to enter image height.
	get_height		; gets width by user input.

    mov r12, 0 ; offset of reading a file.
    mov r9d, [width] ; saves width on register. 
    mov r10d, [height] ; saves height on register.
    mov r8d, r9d ; sets loop counter = width.

_getValuesOfImageLoop:

    mov rax, SYS_OPEN      ; opens the file.
    mov rdi, read_file_img ; target file.
    mov rsi, O_RDONLY      ; read only mode.
    mov rdx, 0
    syscall

    push rax
    mov rdi, rax 

    mov rax, SYS_LSEEK ; updates the file pointer.
    mov rsi, r12 ; start of reading offset.
    mov rdx, 0 ; offset reference point, 0 meaning the start of the file. 
    syscall

    mov rax, SYS_READ      ; reads file from where the pointer is.
    mov rsi, image_array   ; store data read.
    mov rdx, 5             ; bytes stored.
    syscall

    mov rax, SYS_CLOSE ; closes the file.
    pop rdi
    syscall

    add r12, 5 ; updates reading offset.

    ;call _writeFile

    ; decrements the loop counter.
    dec r8d
    jnz _getValuesOfImageLoop

_endProgram:

    ;call _writeFile ; writes file.

    mov rax, SYS_EXIT
	mov rdi, 0
	syscall			; exits the program.

_writeFile:

	mov rax, SYS_OPEN
    mov rdi, new_file
    mov rsi, O_APPEND + O_WRONLY
    mov rdx, 0666o
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, image_array
    mov rdx, 5
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall
	ret