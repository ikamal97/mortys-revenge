; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;   Name: Idrees Kamal
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	      ;;  PI / 2
PI =  205887	                  ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                              ;;  (It is easier to use than divison would be)
	                              ;; this value is 256/pi


	;; If you need to, you can place global variables here
	
.CODE
   
FixedSin PROC USES ebx edx esi angle:FXPT

	mov eax, angle          ; eax = angle(FXPT)

	;if the angle is negative, add 2PI
negative_check:
	mov edx, eax
	and edx, 0f0000000h		; checks if the mbd is 1 (negative value)
	jz angle_mod			; if not 1, skip procedure
	; angle is negative
	mov esi, TWO_PI
	add eax, esi
	jmp negative_check		; loops until value is positive

angle_mod:
	; angle = angle%2PI
	xor edx, edx
	mov esi, TWO_PI
	idiv esi
	mov eax, edx

zero_to_pihalf:
	;; conditional check for angle being [0,pi/2]
	mov esi, PI_HALF
	cmp eax, esi
    jg pihalf_to_pi

    mov ebx, PI_INC_RECIP   ; ebx = 256/PI -- FXPT
	xor edx, edx			; set edx to 0 if eax is positive, 
	imul ebx				; {edx, eax} <-- PI_RECIP*angle
	mov eax, edx
    movzx eax, [SINTAB + 2*edx]

    ret

pihalf_to_pi:
	;; sin(pi - x)
	;; conditional check for angle being [pi/2, pi]
	mov esi, PI
	cmp eax, esi
    jg pi_to_3pi2

	mov ebx, PI 			; ebx = PI	
	sub ebx, eax			; ebx = PI - angle
	mov eax, ebx			; eax = PI - angle
	xor edx, edx			; clear edx
	mov esi, PI_INC_RECIP
	imul esi		; {edx,eax} <-- (PI-x)*PI_RECIP
	mov eax, edx
	movzx eax, [SINTAB + 2*edx]
	ret	

pi_to_3pi2:
	;; -sin(x)
	;; conditional check for angle being [pi/2, 3pi/2]
	mov esi, PI
	mov edi, PI_HALF
	add esi, edi			; 3PI/2
	cmp eax, esi
    jg three_pi_to_2pi

    mov ebx, PI_INC_RECIP   ; ebx = 256/PI -- FXPT
							; set edx to -1 if eax is negative
	imul ebx				; {edx, eax} <-- PI_RECIP*angle
    ;; edx = index 
    mov ebx, 256			; ebx = 256
    mov eax, edx			; eax = overflow index
    xor edx, edx			; clear edx
    idiv ebx 				;; divide eax by 256 
    mov eax, edx
    movzx eax, [SINTAB + 2*edx]	; edx = remainder
    neg eax
	ret

three_pi_to_2pi:
;; conditional check for angle being [3pi/2, 2pi]
	mov esi, TWO_PI
	cmp eax, esi
    jg over_2pi

	mov eax, angle			; eax = angle
	mov ebx, TWO_PI 		; ebx = 2PI	
	sub ebx, eax			; ebx = 2PI - angle
	mov eax, ebx			; eax = 2PI - angle
	xor edx, edx			; clear edx
	mov esi, PI_INC_RECIP
	imul esi		; {edx,eax} <-- (PI-x)*PI_RECIP
	mov ebx, 256			; ebx = 256
    mov eax, edx			; eax = overflow index
    xor edx, edx			; clear edx
    idiv ebx 				;; divide eax by 256 
    mov eax, edx
    movzx eax, [SINTAB + 2*edx]	; edx = remainder
    neg eax
	ret

over_2pi:
	jmp zero_to_pihalf
	ret

FixedSin ENDP 

FixedCos PROC angle:FXPT

	mov eax, angle          ; eax = angle(FXPT)
	add eax, PI_HALF
	invoke FixedSin, eax
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
