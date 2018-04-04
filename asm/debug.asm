 .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc
include gamelogic.inc
include debug.inc
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib	

.DATA

fmtStr BYTE "%d", 0
outStr BYTE 256 DUP (0)

.CODE

WriteInt PROC uses ebx ecx edx esi edi input:DWORD

	mov ebx, input
	push ebx
	push offset fmtStr
	push offset outStr
	call wsprintf
	add esp, 12
	invoke DrawStr,offset outStr,300,300,000
	ret

WriteInt ENDP

END