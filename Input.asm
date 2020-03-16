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
	pixel_value resb 3		; reserves memory for current pixel value.

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
    mov rsi, pixel_value   ; store data read.
    mov rdx, 3             ; bytes stored.
    syscall

    mov rax, SYS_CLOSE ; closes the file.
    pop rdi
    syscall

    add r12, 3 ; updates reading offset. 3 bytes because each number is formatted for a len of 3.

    ; decrements the loop counter.
    dec r8d
    jnz _getValuesOfImageLoop

_convolveImage:


_endProgram:

    ;lea esi, [pixel_value] ; loads pixel value into esi register.
    ;mov ecx, 3 ; loop counter, len of number.
    ;call _string2int

    ;add eax, 5
    ;mov [pixel_value], eax  ; will write to ascii
    
    call _writeFile ; writes in file.

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
    mov rsi, pixel_value
    mov rdx, 3
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall
	ret

; converts chars to integer.
_string2int:
  xor ebx,ebx    ; clear ebx
.next_digit:
  movzx eax, byte[esi]
  inc esi
  sub al, '0'    ; convert from ASCII to number
  imul ebx, 10
  add ebx,eax   ; ebx = ebx*10 + eax
  loop .next_digit  ; while (--ecx)
  mov eax, ebx
  ret