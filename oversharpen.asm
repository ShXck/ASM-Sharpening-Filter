%include "InputMacro.inc"

section .data

	read_file_img db "unfiltered_img.txt", 0 	; file with no filtered image.
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
    ;lea rbx, [width] ; loads width into rbx.
    ;call _getLenChar ; gets the len of width.
    ;mov r9, rcx      ; moves the len of width to r9.

    ;lea esi, [width] ; loads width into esi.
    ;mov ecx, r9d     ; moves the len of width into ecx.
    ;call _string2int ; converts the value of width to an actual integer.
    ;mov r9d, eax     ; moves the integer value of width to r9d.
    mov rdx, width
    call atoi
    mov r9, rax

    ;lea rbx, [height] ; loads height into rbx.
    ;call _getLenChar  ; gets the len of height.
    ;mov r10, rcx      ; moves the len of height to r10.

    ;lea esi, [height] ; loads width into esi.
    ;mov ecx, r10d     ; moves the len of height into ecx.
    ;call _string2int ; converts the value of height to an actual integer.
    ;mov r10d, eax     ; moves the integer value of height to r10d.
    mov rdx, height
    call atoi
    mov r10, rax

    mov r8, r9     ; moves the value of width to the counter.

    add r8, 3      ; adds 3 to the width position to consider the zero padding.
    mov r15, 3     ; loads multiplication factor.
    mov rax, r8    ; loads number to multiply.
    mul r15        ; (width + 3) * 3 this is where the first actual pixel will be. 

    mov r8, rax    ; moves the result back to r8, which is our position register.
    mov r14, rax   ; moves the result to keep it for further use in the algorithm.
    mov r12, r8    ; moves the starting value for it is neccesary for the calculation of the position of upper pixels.
    mov r11, r8    ; moves the starting value, necesarry for the calculation of lower addjacent along the row.
    mov r13, 3     ; register for keeping the offset of the lower adjacent pixel. Starts at 3.

    mov r15, 0 ; sets 0 r15, which will store the final pixel convolution result.

    push r9    ; stores the value of width in the stack.

_convolveImage:
    ; Getting the current pixel and the adjacent values for convolution with the kernel.
    push r8                ; push the value of the current pixel position to the stack to preserve it for future use.
    
    ; Operating middle pixel.
    call _getPixelValue    ; gets the current pixel. Value is stored in pixel value.
    call _pixel2int        ; converts the pixel value to integer. Return value is stored in rbx.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    mov rbx, 9             ; loads the multiplication factor of the center of the kernel (9)
    mul rbx                ; multiply the pixel value by the factor. Result is stored in rax.
    mov r15, rax           ; stores the partial result in r15.

    pop r8                 ; restores pixel position to original.
    push r8                ; saves the original value again.
    sub r8, 3              ; - 1 to current position, will give us the position of the left adjacent pixel.

    ; Operating left adjacent
    call _getPixelValue    ; gets the left adjacent pixel.
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    add r8, 3              ; + 1 to the current position, will give us the position to the right adjacent pixel.

    ; Operating right adjacent
    call _getPixelValue    ; gets the left adjacent pixel.
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    sub r8, r14            ; set the position to the upper adjacent pixel. pixel = position - initial_pos.             
    add r8, 3              ; moves the position to the right to get the right position.

    ; Operating upper adjacent.
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    
    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    sub r8, r14            ; set the position to the upper adjacent pixel. pixel = position - initial_pos.             
    add r8, 6              ; moves the position to the right to get the right position.

    ; Operating upper right adjacent
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the original value.
    push r8                ; saves the original value.
    sub r8, r14            ; set the position to the upper adjacent pixel. pixel = position - initial_pos.             

    ; Operating upper left adjacent
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    pop r8                 ; restores the pixel value position to the original.
    push r8                ; saves the original value.
    add r8, r12            
    sub r8, r13            ; adjust position to be the lower adjacent.   

    ; Operating lower adjacent.
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.


    pop r8                 ; restores the pixel value position to the original.
    push r8                ; saves the original value.
    add r8, r12            
    sub r8, r13            ; adjust position to be the lower adjacent.   
    add r8, 3     
    
    ; Operating lower right adjacent
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.      

    pop r8                 ; restores the pixel value position to the original.
    push r8                ; saves the original value.
    add r8, r12            
    sub r8, r13            ; adjust position to be the lower adjacent.   
    sub r8, 3              ; adjust the pixel position to the right.

    ; Operating lower left adjacent.
    call _getPixelValue    ; gets the left adjacent pixel.      
    call _pixel2int        ; converts the pixel value to integer.
    mov rax, rbx           ; loads the value of the integer conversion to rax.
    sub r15, rax           ; The factor for this pixel is -1, so we just substract from the partial result the value of this pixel.

    ; Convolution of pixel is complete at this point.
    mov rax, r15
    call itoa
    mov r15, rdi
    mov [conv_result], rdi ; loads the result into memory.

    call _writeFile        ; writes the result of the pixel convolution.
    call _addNewLine       ; adds a line jump to make the output readable.

    pop r8                 ; restores value position of pixel.
    mov r15, 0             ; restarts the result of convolution.

    dec r9                 ; - 1 to row width, because we already operated one pixel. 
    jz _updatePosition     ; updates position if the row is complete.

    ; Update the next pixel to be convolved.
    add r8, 3              ; + 1 to current pixel position, moving horizontally.
    add r13, 3             ; updates the offset for lower adjacents
    add r12, 3             ; updates the lower position offset.

    jmp _convolveImage     ; else keep operating row pixels.

; Updates the position of the pixel row.
_updatePosition:
    add r8, 9              ; updates the position to the next value.
    mov r13, 3             ; restores offset for lower adjacent. 
    mov r12, r11           ; restores the position offset for lower adjacent
    pop r9                 ; restores the value of the width, to keep operating the next row.
    push r9                ; saves the value again in the stack.        
    dec r10                ; - 1 to vertical position, since we already operated one row.
    jz _endProgram         ; the whole image is ready, exits the program.
    jmp _convolveImage     ; else keep convolving.

_getPixelValue:

    push r11

    mov rax, SYS_OPEN      ; opens the file.
    mov rdi, read_file_img ; target file.
    mov rsi, O_RDONLY      ; read only mode.
    mov rdx, 0
    syscall

    push rax
    mov rdi, rax 

    mov rax, SYS_LSEEK ; updates the file pointer.
    mov rsi, r8 ; start of reading offset.
    mov rdx, 0  ; offset reference point, 0 meaning the beginning of the file. 
    syscall

    mov rax, SYS_READ      ; reads file from where the pointer is.
    mov rsi, pixel_value   ; store data read.
    mov rdx, 3             ; bytes stored.
    syscall

    mov rax, SYS_CLOSE ; closes the file.
    pop rdi
    syscall

    pop r11

    ret

; Exits the program.
_endProgram:
    mov rax, SYS_EXIT ; exits the program.
	mov rdi, 0
	syscall			

; Writes value of pixel_value to a file.
_writeFile:

    push r11

	mov rax, SYS_OPEN
    mov rdi, oversharp_file
    mov rsi, O_APPEND + O_WRONLY
    mov rdx, 0666o
    syscall

    push rax
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, conv_result
    mov rdx, 3
    syscall

    mov rax, SYS_CLOSE
    pop rdi
    syscall

    pop r11
	ret

_addNewLine:
    mov dword [conv_result], 10  ; loads the ascii for a new line.
    call _writeFile             ; writes the line jump.

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

; ascii to integer, input ascii should be in rdx and return value is stored at rax.
atoi:
	xor rax, rax ; 
.top:
	movzx rcx, byte [rdx] 
	inc rdx 
	cmp rcx, '0'  
	jb .done
	cmp rcx, '9'
	ja .done
	sub rcx, '0'  
	imul rax, 10  
	add rax, rcx  
	jmp .top  
	.done:
ret

itoa:
	mov ebx, 0xCCCCCCCD             
	xor rdi, rdi
.loop:
	mov ecx, eax                    ; save original number

	mul ebx                         ; divide by 10 using agner fog's 'magic number'
	shr edx, 3                      ;

	mov eax, edx                    ; store it back into eax

	lea edx, [edx*4 + edx]          ; multiply by 10
	lea edx, [edx*2 - '0']          ; and ascii it
	sub ecx, edx                    ; subtract from original number to get remainder

	shl rdi, 8                      ; shift in to least significant byte
	or rdi, rcx                     ;

	test eax, eax
	jnz .loop   
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