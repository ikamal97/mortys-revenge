; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;
;	Name: Idrees Kamal
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	SCREEN_WIDTH = 640
	SCREEN_HEIGHT = 480
	
.CODE

DrawPixel PROC USES esi edi ebx eax edx ecx x:DWORD, y:DWORD, color:DWORD
LOCAL INDEX:DWORD
	;; Implement functionality for out of bound checking


	mov esi, x 		; esi = x
	mov edi, y 		; edi = y
	; memory offset for the pixel to be colored = 640*y + x
	mov eax, edi	; eax = y
	mov ebx, 640	; ebx = 640
	xor edx, edx	; clear edx
	mul ebx			; eax = 640*y
	add eax, esi	; eax = 640y + x
	;mov INDEX, eax	; INDEX = edx
	mov edx, eax	; edx = 640y + x
	mov eax, color 	; eax = color value
	mov ecx, ScreenBitsPtr
	add ecx, edx 	; ecx = index into ScreenBitsPtr
	mov byte ptr [ecx], al
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES esi edi ebx eax edx ecx ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL tcolor:BYTE, x1:DWORD, x2:DWORD, y1:DWORD, y2:DWORD, bmHeight:DWORD, bmWidth:DWORD, lpPtr:DWORD,
		x_iterator:DWORD, y_iterator:DWORD

	; Bitmap pointer 
	mov eax, ptrBitmap
	; Pointer to transparent color value
	mov bl, (EECS205BITMAP ptr [eax]).bTransparent
	mov tcolor, bl

	; Bitmap xcenter
	mov ebx, xcenter
	mov x1, ebx
	mov x2, ebx
	; drawing should start at xcenter - (dwWidth/2)
	mov ecx, (EECS205BITMAP ptr [eax]).dwWidth
	mov bmWidth, ecx
	sar ecx, 1		; dwWidth/2
	sub x1, ecx		; x1 = xcenter - (dwWidth/2)

	; Bitmap xcenter
	mov ebx, xcenter
	; drawing should end at xcenter + (dwWidth/2)
	mov ecx, (EECS205BITMAP ptr [eax]).dwWidth
	sar ecx, 1		; dwWidth/2
	add x2, ecx		; x2 = xcenter + (dwWidth/2)

	; Bitmap ycenter
	mov ebx, ycenter
	mov y1, ebx
	mov y2, ebx
	; drawing should start at ycenter - (dwHeight/2)
	mov ecx, (EECS205BITMAP ptr [eax]).dwHeight
	mov bmHeight, ecx
	sar ecx, 1		; dwHeight/2
	sub y1, ecx		; y1 = ycenter - (dwHeight/2)

	; Bitmap ycenter
	mov ebx, ycenter
	; drawing should end at ycenter + (dwHeight/2)
	mov ecx, (EECS205BITMAP ptr [eax]).dwHeight
	sar ecx, 1		; dwHeight/2
	add y2, ecx		; y2 = ycenter + (dwHeight/2)

	; Loop through the rows and columns
	mov ecx, x1
	mov edx, x2

	mov esi, y1
	mov edi, y2

	mov ebx, (EECS205BITMAP ptr [eax]).lpBytes	; ptr to the start of color array
	mov lpPtr, ebx

	mov x_iterator, 0
	mov y_iterator, 0

	row_loop:
	; esi = y1
	; edi = y2
	; ecx = x1
	; edx = x2

	; If y1 >= y2, break
	cmp esi, edi
	jge y_break

			col_loop:
			; If x1 >= x2, break
			mov edx, x2				; put x2 back into edx
			cmp ecx, edx
			jge col_break

			mov eax, y_iterator	; eax = y_iterator
			xor edx, edx		; clear edx
			imul bmWidth		; eax = y_iterator*bmWidth
			add eax, x_iterator	; eax = y_iterator*bmWidth + x_iterator
			add eax, lpPtr		; eax = address of colorval
			mov al, byte ptr [eax]	; al = color value

			;; skip if transparent
      		cmp al, tcolor
      		je NOPLOT

      		;;skip if out of x bounds
	      	cmp ecx, 0
	      	jl NOPLOT
	      	cmp ecx, SCREEN_WIDTH
	      	jge NOPLOT

	      	;;skip if out of y bounds
	      	cmp esi, SCREEN_HEIGHT
	      	jge NOPLOT
	      	cmp esi, 0
	      	jl NOPLOT

      		; PLOT
			movzx eax, al
			invoke DrawPixel, ecx, esi, eax

			NOPLOT:
			inc ecx				; x++
			inc x_iterator		; iterator++
			jmp col_loop

		col_break:
		mov ecx, x1				; reset x1
		mov x_iterator, 0		; reset iterator
		mov edi, y2				; put y2 back into edi
		inc esi					; y++
		inc y_iterator			; y_iterator++
		jmp row_loop

	y_break:
	ret 			; Don't delete this line!!!	
BasicBlit ENDP


RotateBlit PROC USES ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
  LOCAL cosA: FXPT, sinA: FXPT 
  LOCAL shiftX: DWORD, shiftY: DWORD
  LOCAL screenX: DWORD, screenY: DWORD
  LOCAL srcX: DWORD, srcY: DWORD
  LOCAL dstWidth: DWORD, dstHeight: DWORD
 
  ; cosa = FixedCos(angle)
  INVOKE FixedCos, angle
  mov cosA, eax    
  mov ebx, cosA                                      

  ; sina = FixedSin(angle)
  INVOKE FixedSin, angle
  mov sinA, eax
  mov ecx, cosA                                        

  ; esi = lpBitmap
  mov esi, lpBmp                                          
  mov edx, (EECS205BITMAP PTR[esi]).dwWidth       ; edx = dwWidth       
  mov edi, (EECS205BITMAP PTR[esi]).dwHeight      ; edi = dwHeight   

  ;; Calculate shiftX
  mov eax, (EECS205BITMAP PTR[esi]).dwWidth
  sal eax, 16									; convert dwWidth to FXPT
  sar ebx, 1     								; cosa/2
  imul ebx     									; dwWidth*cosa/2
  mov shiftX, edx								; edx = dwWidth*cosa/2
  mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  sal eax, 16
  sar ecx, 1                                              ;; ecx = sinA/2
  imul ecx                                                ;; edx = dwHeight * sinA/2              
  sub shiftX, edx                                         ;; shiftX = dwWidth * cosA/2 - dwHeight * sinA/2

  ;; Calculate shiftY
  mov edx, (EECS205BITMAP PTR[esi]).dwWidth
  mov ebx, cosA
  mov ecx, sinA
  mov eax, (EECS205BITMAP PTR[esi]).dwHeight
  sal eax, 16                                         
  sar ebx, 1                                               
  imul ebx                                                
  mov shiftY, edx   
  mov eax, (EECS205BITMAP PTR[esi]).dwWidth
  sal eax, 16                                               ;; eax = dwWidth
  sar ecx, 1                                                ;; ecx = sinA/2
  imul ecx                                                  ;; edx = dwHeight * sinA/2 
  add shiftY, edx                                           ;; shiftY = dwWidth * cosA/2 - dwHeight * sinA/2

  ;; CALCULATE dstWidth and dstHeight
  mov edi, (EECS205BITMAP PTR[esi]).dwHeight
  add edi, (EECS205BITMAP PTR[esi]).dwWidth
  mov dstWidth, edi
  mov dstHeight, edi

 ;; initialization for outer loop
  neg edi
  jmp row_loop_CHECK

  row_loop:
    ;; inner loop initialization
    mov ecx, dstHeight
    neg ecx
    jmp col_loop_CHECK

    col_loop:

    ;; calculate srcX
    mov eax, edi
      sal eax, 16
      imul cosA
      mov srcX, edx

      mov eax, ecx
      sal eax, 16
      imul sinA
      add srcX, edx

      ;; calculate srcY
      mov eax, ecx
    sal eax, 16
      imul cosA
      mov srcY, edx

      mov eax, edi
      sal eax, 16
      imul sinA
      sub srcY, edx

;; checking conditions 
      mov eax, xcenter
      add eax, edi
      sub eax, shiftX

      cmp eax, 0
      jl col_loop_CHECK
      cmp eax, 639
      jge col_loop_CHECK
      mov screenX, eax

      mov eax, ycenter
      add eax, ecx
      sub eax, shiftY

      cmp eax, 0
      jl col_loop_CHECK
      cmp eax, 479
      jge col_loop_CHECK
      mov screenY, eax

      mov eax, srcX
      cmp eax, 0
      jl col_loop_CHECK
      cmp eax, (EECS205BITMAP PTR[esi]).dwWidth
      jge col_loop_CHECK

      mov eax, srcY
      cmp eax, 0
      jl col_loop_CHECK
      cmp eax, (EECS205BITMAP PTR[esi]).dwHeight
      jge col_loop_CHECK


      mov eax, srcY
      imul (EECS205BITMAP PTR[esi]).dwWidth
      add eax, srcX
      add eax, (EECS205BITMAP PTR[esi]).lpBytes
      mov al, BYTE PTR [eax]

      ;; compare to transparent
      cmp al, (EECS205BITMAP PTR[esi]).bTransparent
      je col_loop_CHECK

      movzx eax, al
      INVOKE DrawPixel, screenX, screenY, eax

    col_loop_CHECK:
    	inc ecx
      	cmp ecx, dstHeight
      	jl col_loop
	row_loop_CHECK:
    	inc edi
    	cmp edi, dstWidth
    	jl row_loop

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
