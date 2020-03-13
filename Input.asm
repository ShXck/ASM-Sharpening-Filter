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
	image_array resb 4		; reserves memory for image data, maximum res is 1920x1080.

section .text
	global _start

_start:
	request_width   ; prompts request to enter image width.
	get_width 		; gets width by user input.
	request_height	; prompts request to enter image height.
	get_height		; gets width by user input.

	call _openFile
    call _endProgram

_openFile:
    mov rax, SYS_OPEN
    mov rdi, read_file_img
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall

    push rax
    mov rdi, rax

    mov r9d, [width] ; saves width on register. 
    mov r10d, [height] ; saves height on register.
    mov r8d, r9d ; sets loop counter = width.

FileLoop:
    mov [image_array], ecx

    mov rax, SYS_READ
    mov rsi, image_array
    mov rdx, 4
    syscall

    ; decrements the loop counter.
    dec r8d
    jnz FileLoop
    jmp _endProgram

;_printLines:
;    mov [image_array], ecx
;    dec ecx
;    jnz _printLines
;    jmp _endProgram

_endProgram:

    mov rax, SYS_CLOSE ; closes the file.
    pop rdi
    syscall

    call _writeFile ; writes file.
    print image_array

    mov rax, SYS_EXIT
	mov rdi, 0
	syscall			; exits the program.

_writeFile:

	mov rax, SYS_OPEN
    mov rdi, new_file
    mov rsi, O_CREAT + O_WRONLY
    mov rdx, 0644o
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, image_array
    mov rdx, 4
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall
	ret

