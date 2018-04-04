; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;
;   Name: IDREES KAMAL  
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD

DrawLine PROC USES eax ebx ecx edx esi edi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD

	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, prev_error:DWORD, curr_x:DWORD, curr_y:DWORD

	;; Place your code here
      mov ebx, x1             ; ebx = x1
      mov ecx, x0             ; ecx = x0
      mov esi, y1             ; esi = y1
      mov edi, y0             ; edi = y0
      
      sub ebx, ecx            ; ebx = x1 - x0
      cmp ebx, 0              ; IF ebx >= 0
      jge skip_abs_x          ; skip the abs procedure

abs_x:
      neg ebx                 ; ebx = |ebx|

skip_abs_x:
      
      mov delta_x, ebx        ; delta_x = abs(x1-x0)

      sub esi, edi            ; esi = y1 - y0
      cmp esi, 0              ; IF esi >= 0
      jge skip_abs_y          ; skip the abs procedure

abs_y:
      neg esi                 ; esi = |esi|

skip_abs_y:
      
      mov delta_y, esi        ; delta_y = abs(y1-y0)

      mov ebx, x1             ; ebx = x1 
      cmp ecx, ebx            ; if (x0 < x1)
      jge else_x              ; GOTO else case if false
      mov inc_x, 1
      jmp skip_else_x         ; skip the else routine            
else_x:
      mov inc_x, -1
      
skip_else_x:
      mov esi, y1             ; esi = y1 
      cmp edi, esi            ; if (y0 < y1)
      jge else_y              ; GOTO else case if false
      mov inc_y, 1
      jmp skip_else_y         ; skip the else routine
                  
else_y:
      mov inc_y, -1

skip_else_y:
      mov eax, delta_y        ; eax = delta_y --- used only for comparison 
      cmp delta_x, eax        ; if(delta_x < delta_y)
      jle else_delta          ; GOTO else case if false
      mov ecx, 2              ; ecx = 2
      mov eax, delta_x        ; eax = delta_x
      mov edx, 0              ; zero out edx
      div ecx                 ; eax = eax/2
      mov error, eax          ; error = delta_x/2
      jmp skip_else_delta     ; skip the else routine
      
else_delta:
      mov ecx, 2              ; ecx = 2
      mov eax, delta_y        ; eax = delta_y
      mov edx, 0              ; zero out edx
      div ecx                 ; eax = eax/2
      neg eax                 ; eax = -eax
      mov error, eax          ; error = -delta_y / 2

skip_else_delta:
      mov ecx, x0             ; ecx = x0
      mov edi, y0             ; esi = y1
      mov curr_x, ecx         ; curr_x = x0
      mov curr_y, edi         ; curr_y = y0

      invoke DrawPixel, curr_x, curr_y, color

loop_condition:
      mov ebx, x1             ; ebx = x1
      cmp curr_x, ebx         ; curr_x != x1
      jne loop_body           ; passed first condition (short circuit)
      mov ebx, y1             ; ebx = y1
      cmp curr_y, ebx         ; curr_y != y1
      jne loop_body           ; passed second condition
      jmp break               ; neither condition passed

loop_body:
      invoke DrawPixel, curr_x, curr_y, color

      mov ebx, error          ; ebx = error
      mov prev_error, ebx   ; prev_error = error

first_if:
      mov ebx, delta_x        ; ebx = delta_x
      neg ebx                 ; ebx = -delta_x
      cmp prev_error, ebx     ; prev_error > - delta_x
      jle second_if           ; condition didn't pass
      mov ebx, delta_y        ; ebx = delta_y
      sub error, ebx          ; error = error - delta_y
      mov ebx, inc_x          ; ebx = inc_x
      add curr_x, ebx         ; curr_x = curr_x + inc_x
      
second_if:
      mov ebx, delta_y        ; ebx = delta_y
      cmp prev_error, ebx     ; prev_error < delta_y
      jge loop_condition      ; condition didn't pass
      mov ebx, delta_x        ; ebx = delta_x
      add error, ebx          ; error = error + delta_x
      mov ebx, inc_y          ; ebx = inc_y
      add curr_y, ebx         ; curr_y = curr_y + inc_y

      jmp loop_condition      ; next iteration
      
break:
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
