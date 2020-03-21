%include "InputMacro.inc"
%include "Macros.inc"

section .data

	new_file db "new_file.txt", 0 ; file terminated in 0
	read_file_img db "unfiltered_img.txt", 0 	; file with no filtered image.
	sharp_file db "sharpened.txt", 0   			; file with sharpened image.
	oversharp_file db "oversharpened.txt", 0	; file with oversharpened image.

section .bss
	pixel_value resb 3		; reserves memory for current pixel value.
    conv_result resb 3      ; reserves memory for pixel convolution result.

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
    mov r10, rcx      ; moves the len of height to r10.

    lea esi, [height] ; loads width into esi.
    mov ecx, r10d     ; moves the len of height into ecx.
    call _string2int ; converts the value of height to an actual integer.
    mov r10d, eax     ; moves the integer value of height to r10d.

    mov r12, 0 ; starts the offset reading file.
    mov r14, 0 ; sets reference for offset.

    mov r8, r9 ; moves the value of width to the counter.
    dec r9     ; - 1 to width size, for later comparison with counters.
    add r8, 4  ; adds 4 to the width position, this is where the first actual pixel will be after padding the array with zeros.

    mov r15, 0 ; sets 0 r15, which will store the final pixel convolution result.

    push r9    ; stores the value of width in the stack.

_convolveImage:
    ; Getting the current pixel and the adjacent values for convolution with the kernel.
    push r8                ; push the value of the current pixel position to the stack to preserve it for future use.

    ; Operating middle pixel.
    call _getPixelValue    ; gets the current pixel. Value is stored in pixel value.
    call _pixel2int        ; converts the pixel value to integer. Return value is stored in rbx.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    mov rbx, 5             ; loads the multiplication factor of the center of the kernel (5)
    mul rbx                ; multiply the pixel value by the factor. Result is stored in rax.
    mov r15, rax           ; stores the partial result in r15.

    pop r8                 ; restores pixel position to original.
    push r8                ; saves the original value again.
    sub r8, 1              ; - 1 to current position, will give us the position of the left adjacent pixel.

    ; Operating left adjacent
    call _getPixelValue    ; gets the left adjacent pixel.
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    add r8, 1              ; + 1 to the current position, will give us the position to the right adjacent pixel.

    ; Operating right adjacent
    call _getPixelValue    ; gets the left adjacent pixel.
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    sub r8, r9             ; set the position to the upper adjacent pixel. pixel = position - size_of_padded_array.             
    sub r8, 3 

    ; Operating upper adjacent.
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the pixel value position to the original.
    push r8                ; saves the original value.
    add r8, r8             ; multiplies current position by a factor of 2. 
    sub r8, 2              ; adjust position to be the lower adjacent.

    ; Operating lower adjacent.
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.
    
    ; Convolution of pixel is complete at this point.
    mov [conv_result], r15d ; loads the result into memory.

    call _writeFile        ; writes the result of the pixel convolution.

    pop r8                 ; restores value position of pixel.
    mov r15, 0             ; restarts the result of convolution.

    ; Update the next pixel to be convolved.
    add r8, 1              ; + 1 to current pixel position, moving horizontally.
    dec r9                 ; - 1 to row width, because we already operated one pixel.            
    
    jz _updatePosition     ; updates position if the row is complete.
    jmp _convolveImage     ; else keep operating row pixels.

; Updates the position of the pixel row.
_updatePosition:
    add r8, 3              ; updates the position to the next value.
    pop r9                 ; restores the value of the width, to keep operating the next row.
    push r9                ; saves the value again in the stack.        
    dec r10                ; - 1 to vertical position, since we already operated one row.
    jz _endProgram         ; the whole image is ready, exits the program.
    jmp _convolveImage     ; else keep convolving.

_getPixelValue:
    ; open file code here, in case of error.
    mov rax, SYS_OPEN      ; opens the file.
    mov rdi, read_file_img ; target file.
    mov rsi, O_RDONLY      ; read only mode.
    mov rdx, 0
    syscall

    push rax
    mov rdi, rax 

_getPixel:
    mov rax, SYS_LSEEK ; updates the file pointer.
    mov rsi, r12 ; start of reading offset.
    mov rdx, 0 ;r14 ; offset reference point, 0 meaning the beginning of the file. 
    syscall

    mov rax, SYS_READ      ; reads file from where the pointer is.
    mov rsi, pixel_value   ; store data read.
    mov rdx, 3             ; bytes stored.
    syscall

    ; close file code here, in case of error.
    
    add r12, 3 ; updates reading offset. 3 bytes because each number is formatted for a len of 3.

    ;call _writeFile

    dec r8  ; decrements the loop counter.
    jnz _getPixel
    mov r12, 0 ; resets the offset

    mov rax, SYS_CLOSE ; closes the file.
    pop rdi
    syscall

    ret

; Exits the program.
_endProgram:

    ;call _writeFile 

    mov rax, SYS_EXIT ; exits the program.
	mov rdi, 0
	syscall			

; Writes value of pixel_value to a file.
_writeFile:

    ;mov [conv_result], r15

	mov rax, SYS_OPEN
    mov rdi, new_file
    mov rsi, O_APPEND + O_WRONLY
    mov rdx, 0666o
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, conv_result 
    mov rdx, 4
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
  add ebx, eax   ; ebx = ebx*10 + eax
  dec ecx
  jnz .next_digit  ; while (--ecx)
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