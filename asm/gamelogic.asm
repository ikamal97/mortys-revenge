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

;; Has keycodes
include keys.inc


.DATA
; Defining recatngles for collision
RECTANGLE_ONE RECTANGLE <>
RECTANGLE_TWO RECTANGLE <>

.CODE

CheckIntersect PROC USES ebx ecx edx edi esi oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
	LOCAL horizontalDistance:DWORD, verticalDistance:DWORD
	; convert positions from FXPT to Intersect
	mov ecx, oneX
	shr ecx, 16
	mov edx, oneY
	shr edx, 16
	mov esi, twoX
	shr esi, 16
	mov edi, twoY
	shr edi, 16

	; calculate the boundaries of the two objects
	mov eax, offset RECTANGLE_ONE
	mov ebx, offset RECTANGLE_TWO

	; convert coordinates from 
	invoke CalculateBoundaries, ecx, edx, oneBitmap, eax
	invoke CalculateBoundaries, esi, edi, twoBitmap, ebx

	invoke CalculateHorizontalDistance, ecx, esi
	mov esi, eax

	invoke CalculateVerticalDistance, edx, edi
	mov edi, eax

	; No intersection if either of the functions return 0 
	cmp esi, 0
	je NoIntersect
	cmp edi, 0
	je NoIntersect
Intersect:
	mov eax, 1
	ret

NoIntersect:
	;invoke DrawStar, 400, 100
	mov eax, 0
	ret
CheckIntersect ENDP


; Calculates vertical distance and returns 1 if collision, 0 otherwise
CalculateVerticalDistance PROC USES ebx ecx edx edi esi oneY:DWORD, twoY:DWORD

	; Check if RECTANGLE_ONE is above or below RECTANGLE_TWO
	mov esi, oneY
	mov edi, twoY
	cmp esi, edi
	jl RelativeAbove

	; RECTANGLE_ONE is below RECTANGLE_TWO
RelativeBelow:
	; Range of Y Vals for the first object
	mov esi, RECTANGLE_ONE.upperLeftY

	; The range of Y Vals for second objects
	mov ecx, RECTANGLE_TWO.bottomLeftY

	mov eax, esi
	sub eax, ecx		; Horizontal distance between left edge and right edge

	cmp eax, 0
	jg posDistance

	mov eax, 1		
	ret

RelativeAbove:
	; Range of Y Vals for the first object
	mov edi, RECTANGLE_ONE.bottomLeftY

	; The range of Y Vals for second objects
	mov ebx, RECTANGLE_TWO.upperLeftY

	mov eax, ebx
	sub eax, edi		; Horizontal distance between right edge and left edge

	cmp eax, 0
	jg posDistance

	mov eax, 1		; return horizontal distance
	ret

posDistance:
	;invoke DrawStar, 300, 200	; DrawStar if not in collision zone
	mov eax, 0
	ret
CalculateVerticalDistance ENDP


; Returns the horizontal distance in eax, 1 if collision
CalculateHorizontalDistance PROC USES ebx ecx edx edi esi oneX:DWORD, twoX:DWORD

	; Check if RECTANGLE_ONE is to the right or to the left of RECTANGLE_TWO
	mov esi, oneX
	mov edi, twoX
	cmp esi, edi
	jl RelativeLeft

	; RECTANGLE_ONE is to the right of RECTANGLE_TWO
RelativeRight:
	;invoke DrawStar, 350, 300
	; Range of X Vals for the first object
	mov esi, RECTANGLE_ONE.upperLeftX

	; The range of X Vals for second objects
	mov ecx, RECTANGLE_TWO.upperRightX

	mov eax, esi
	sub eax, ecx		; Horizontal distance between left edge and right edge

	cmp eax, 0
	jg posDistance

	mov eax, 1		; return horizontal distance
	ret

RelativeLeft:
	; Range of X Vals for the first object
	mov edi, RECTANGLE_ONE.upperRightX

	; The range of X Vals for second objects
	mov ebx, RECTANGLE_TWO.upperLeftX

	mov eax, edi
	sub eax, ebx		; Horizontal distance between right edge and left edge

	cmp eax, 0
	jl posDistance

	mov eax, 1		; return horizontal distance
	ret

posDistance:
	;invoke DrawStar, 300, 300	; DrawStar if not in collision zone
	mov eax, 0
	ret

CalculateHorizontalDistance ENDP


ClearScreen PROC uses ecx edx
	mov eax, 640
	imul eax, 480
	mov ecx, 0
	mov edx, ScreenBitsPtr
clearingScreen:
	cmp ecx, eax
	jge doneClearing
	mov BYTE PTR [edx], 000h
	add ecx, 1
	add edx, 1
	jmp clearingScreen
doneClearing:
	ret
ClearScreen ENDP


ClearScreenBG PROC
	mov eax, offset background_1
	invoke BasicBlit, eax, 320, 240
	ret
ClearScreenBG ENDP


CheckSpacePress PROC uses ecx ebx
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_SPACE
	jne FALSE
	mov eax, 1
	ret
FALSE:
	mov eax, 0
	ret
CheckSpacePress ENDP

CheckMousePress PROC uses ecx
	mov eax, 0
	mov ecx, MouseStatus.buttons
	cmp ecx, MK_LBUTTON
	jne FALSE
	mov eax, 1
	ret
FALSE:
	ret
CheckMousePress ENDP

CheckUpKeyPress PROC USES ecx
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_UP
	jne FALSE
	mov eax, 1
	ret
FALSE:
	ret
CheckUpKeyPress ENDP


CheckDownKeyPress PROC USES ecx
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_DOWN
	jne FALSE
	mov eax, 1
	ret
FALSE:
	ret
CheckDownKeyPress ENDP


CheckRightKeyPress PROC USES ecx
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_RIGHT
	jne FALSE
	mov eax, 1
	ret
FALSE:
	ret
CheckRightKeyPress ENDP

CheckLeftKeyPress PROC USES ecx
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_LEFT
	jne FALSE
	mov eax, 1
	ret
FALSE:
	ret
CheckLeftKeyPress ENDP

;; Moves a SPRITE up
MoveUp PROC uses ecx sprite:DWORD
	mov ecx, sprite
	mov eax, (SPRITE PTR [ecx]).y_coord
	cmp eax, 0
	jle AtTopEdge
	sub (SPRITE PTR [ecx]).y_coord, 10
AtTopEdge:
	ret
MoveUp ENDP

;; Moves a sprite down
MoveDown PROC uses ecx sprite:DWORD
	mov ecx, sprite
	mov eax, (SPRITE PTR [ecx]).y_coord
	cmp eax, 450
	jge AtBottomEdge
	add (SPRITE PTR [ecx]).y_coord, 10
AtBottomEdge:
	ret
MoveDown ENDP

;; Moves a sprite left
MoveLeft PROC uses edx sprite:DWORD
	mov edx, sprite
	mov (SPRITE PTR[edx]).x_velocity, 0FFEC0000h 	; set velocity to -20	
	ret
MoveLeft ENDP

;; Moves a sprite right
MoveRight PROC uses edx sprite:DWORD
	mov edx, sprite
	mov (SPRITE PTR[edx]).x_velocity, 000141093h 	; set velocity to 20
	ret
MoveRight ENDP

;; Jumps a sprite 
Jump PROC uses ecx sprite:DWORD
	mov ecx, sprite
	; y_velocity = -20
	mov (SPRITE PTR [ecx]).y_velocity, 0FFE72909h
	; activate gravity for the sprite
	mov (SPRITE PTR [ecx]).gravity, 1
	ret
Jump ENDP 

CalculateBoundaries PROC USES ebx ecx edx edi esi x:DWORD, y:DWORD, bitmap:PTR EECS205BITMAP, rectangle:PTR RECTANGLE
LOCAL halfWidth:DWORD, halfHeight:DWORD, w:DWORD, h:DWORD

	mov edx, bitmap
	mov eax, (EECS205BITMAP PTR [edx]).dwWidth
	mov w, eax

	xor edx, edx
	mov esi, 2
	idiv esi		; bitmap.width/2
	mov halfWidth, eax

	mov edi, x
	sub edi, eax	; one.x - bitmap.width/2

	mov edx, rectangle
	mov (RECTANGLE PTR [edx]).upperLeftX, edi	; upperLeftX = one.x - bitmap.width/2

	mov edx, bitmap
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight
	mov h, eax

	xor edx, edx
	mov esi, 2
	idiv esi		; bitmap.height/2
	mov halfHeight, eax

	mov edi, y
	sub edi, eax	; one.y - bitmap.height/2

	mov edx, rectangle
	mov (RECTANGLE PTR [edx]).upperLeftY, edi	; upperLeftY = one.y - bitmap.height/2

	;invoke DrawStar, (RECTANGLE PTR [edx]).upperLeftX, (RECTANGLE PTR [edx]).upperLeftY

	mov esi, (RECTANGLE PTR [edx]).upperLeftX
	add esi, w
	mov (RECTANGLE PTR [edx]).bottomRightX, esi

	mov esi, (RECTANGLE PTR [edx]).upperLeftY
	add esi, h
	mov (RECTANGLE PTR [edx]).bottomRightY, esi

	;invoke DrawStar, (RECTANGLE PTR [edx]).bottomRightX, (RECTANGLE PTR [edx]).bottomRightY

	mov esi, (RECTANGLE PTR [edx]).bottomRightX
	mov (RECTANGLE PTR [edx]).upperRightX, esi
	mov esi, (RECTANGLE PTR [edx]).bottomRightY
	sub esi, h
	mov (RECTANGLE PTR [edx]).upperRightY, esi
	
	;invoke DrawStar, (RECTANGLE PTR [edx]).upperRightX, (RECTANGLE PTR [edx]).upperRightY

	mov esi, (RECTANGLE PTR [edx]).bottomRightX
	sub esi, w
	mov (RECTANGLE PTR [edx]).bottomLeftX, esi
	mov esi, (RECTANGLE PTR [edx]).bottomRightY
	mov (RECTANGLE PTR [edx]).bottomLeftY, esi

	;invoke DrawStar, (RECTANGLE PTR [edx]).bottomLeftX, (RECTANGLE PTR [edx]).bottomLeftY

	;mov esi, x
	;mov edi, y
	;invoke DrawStar, esi, edi
	;invoke DrawLine, (RECTANGLE PTR [edx]).bottomLeftX, (RECTANGLE PTR [edx]).bottomLeftY, (RECTANGLE PTR [edx]).bottomRightX, (RECTANGLE PTR [edx]).bottomRightY, 0fffh
	;invoke DrawLine, (RECTANGLE PTR [edx]).upperLeftX, (RECTANGLE PTR [edx]).upperLeftY, (RECTANGLE PTR [edx]).upperRightX, (RECTANGLE PTR [edx]).upperRightY, 0fffh
	;invoke DrawLine, (RECTANGLE PTR [edx]).upperLeftX, (RECTANGLE PTR [edx]).upperLeftY, (RECTANGLE PTR [edx]).bottomLeftX, (RECTANGLE PTR [edx]).bottomLeftY, 0fffh
	;invoke DrawLine, (RECTANGLE PTR [edx]).upperRightX, (RECTANGLE PTR [edx]).upperRightY, (RECTANGLE PTR [edx]).bottomRightX, (RECTANGLE PTR [edx]).bottomRightY, 0fffh

ret
CalculateBoundaries ENDP

END