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
    
    ; Input data set up.
    lea rbx, [width] ; loads width into rbx.
    call _getLenChar ; gets the len of width.
    mov r9, rcx      ; moves the len of width to r9.

    lea esi, [width] ; loads width into esi.
    mov ecx, r9d     ; moves the len of width into ecx.
    call _string2int ; converts the value of width to an actual integer.
    mov r9d, eax     ; moves the integer value of width to r9d.


    lea rbx, [height] ; loads height into rbx.
    call _getLenChar  ; gets the len of height.
    mov r10, rcx      ; moves the len of height to r9.

    lea esi, [height] ; loads width into esi.
    mov ecx, r10d     ; moves the len of height into ecx.
    call _string2int ; converts the value of height to an actual integer.
    mov r10d, eax     ; moves the integer value of height to r9d.

    add r9, 4 ; adds 4 to the width position, this is where the first actual pixel will be after padding the array with zeros.

    mov r8, r9 ; sets first pixel to retrieve, pixel = width + 4.
    mov r15, 0 ; sets 0 r15, which will store the final pixel convolution result.

_convolveImage:
    ; Getting the current pixel and the adjacent values for convolution with the kernel.

    push r8                ; push the value of the current pixel position to the stack to preserve it for future use.

    ; Operating middle pixel.
    call _getPixelValue    ; gets the current pixel. Value is stored in pixel value.
    call _pixel2int        ; converts the pixel value to integer. Return value is stored in rbx.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    imul rax, 5
    mov r15, rax           ; stores the partial result in r15.

    inc r8                 ; + 1 to current position, will give us the position of the right adjacent pixel.

    ; Operating right adjacent
    call _getPixelValue    ; gets the right adjacent pixel.
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    imul rax, -1           ; multiples right adjacent by -1 (kernel)
    add r15, rax           ; adds the partial result.

    pop r8                 ; restores pixel position to original.
    dec r8                 ; - 1 to current position, will give us the position of the left adjacent pixel. 

_getPixelValue:

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

    call _writeFile

    dec r8  ; decrements the loop counter.
    jnz _getPixelValue

; Exits the program.
_endProgram:

    ;call _writeFile 

    mov rax, SYS_EXIT
	mov rdi, 0
	syscall			; exits the program.

; Writes value of pixel_value to a file.
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

_pixel2int:
    lea esi, [pixel_value] ; loads pixel value into esi.
    mov ecx, 3     ; moves the len of pixel value into ecx.
    call _string2int ; converts the pixel value to an actual integer.
    mov rbx, rax     ; moves the integer pixel value to rbx.
    ret


; converts chars to integer, return value is at eax.
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

; Gets the len of a string and returns it to ecx. ; TODO: fix for len > 3
_getLenChar:
    push rbx
    mov ecx,0
    dec ebx
    count:
        inc ecx
        inc ebx
        cmp byte[ebx], 0
        jnz count
    sub ecx, 2
    pop rbx
    ret