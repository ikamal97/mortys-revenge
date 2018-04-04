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
include spritelogic.inc
include debug.inc
include keys.inc
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib	
include\masm32\include\masm32.inc
includelib\masm32\lib\masm32.lib

.DATA
; Acceleration constant = 1
ACCELERATION FXPT 000020000h

;; Defining SPRITES
;RICK SPRITE <offset rick_right, 001400000h, 0006c0000h>
RICK SPRITE <offset rick_right, 00000000h>

;MORTY_ARR SPRITE <offset morty_right, 000DC0000h, 0015E0000h>, <offset morty_left, 001F40000h, 0015E0000h>
MORTY_ARR SPRITE 10 DUP(<offset morty_right>)

; Defining Projectiles
LASER PROJECTILE 2 DUP(<offset laser>)

; Defining platforms
GROUND PLATFORM <offset ground, 320, 440, 393>
STARTPLATFORM PLATFORM <offset platform, 320, 174,152>

; Boolean for limiting shooting 
LAST_KEY DWORD 000h

; Score counter
SCORE DWORD 0
fmtStr BYTE "Score: %d", 0
outstr BYTE 256 DUP(0)

.CODE

InitMortys PROC USES ebx ecx edx esi edi
	LOCAL offset_:DWORD, startAddr:DWORD, rposition:DWORD, rorientation:DWORD
	mov startAddr, offset MORTY_ARR
	mov offset_, 0

	jmp condition
loop_:
	; Get random position
	invoke nrandom, 320					; eax = random number
	add eax, 320
	shl eax, 16
	mov rposition, eax

	; get random orientation
	invoke nrandom, 2
	cmp eax, 1
	je orientRight
orientLeft:
	mov rorientation, offset morty_left
	jmp init
orientRight:
	mov rorientation, offset morty_right
init:
	; Compute index
	mov ecx, startAddr
	add ecx, offset_					;esi =  Morty index
	; Init Morty's position
	mov eax, rposition
	mov (SPRITE PTR [ecx]).x_coord, eax
	; Init Morty's orientation
	mov eax, rorientation
	mov (SPRITE PTR [ecx]).obj, eax
increment:
	mov edi, TYPE MORTY_ARR
	add offset_, edi					; edx = edx + size of one sprite
condition:
	mov edx, offset_
	cmp edx, SIZEOF MORTY_ARR
	jl	loop_
	ret
InitMortys ENDP


DrawMortys PROC USES ebx ecx edx esi edi
LOCAL deadMortys:DWORD
	mov deadMortys, 0
	mov ebx, offset MORTY_ARR		; ebx = starting address
	xor edx, edx					; edx = offset from starting address
	jmp condition
loop_:

	; Check if alive
	invoke CheckAlive, ebx, edx
	cmp eax, 0
	je DeadMorty	; Don't draw anything if Morty is dead

	; Update singular Morty's data
	invoke UpdateMortyData, ebx, edx

	; convert position values from FXPT to integer
	mov esi, (SPRITE PTR [ebx + edx]).x_coord
	shr esi, 16
	mov ecx, (SPRITE PTR [ebx + edx]).y_coord
	shr ecx, 16

	;Draw Sprite
	invoke BasicBlit, (SPRITE ptr [ebx + edx]).obj, esi, ecx
	jmp increment
DeadMorty:
	inc deadMortys
	mov eax, deadMortys
	cmp deadMortys, LENGTHOF MORTY_ARR
	je AllDead
increment:
	mov edi, TYPE SPRITE
	add edx, edi					; edx = edx + size of one sprite
condition:
	cmp edx, SIZEOF MORTY_ARR
	jl	loop_
	mov eax, 1
	ret
AllDead:
	mov eax, 0
	ret
DrawMortys ENDP


DrawRick PROC USES ebx ecx edx esi edi
	mov edx, offset RICK

	; update Rick's data
	invoke UpdateRickData

	; Don't draw if Rick is dead
	mov esi, (SPRITE PTR [edx]).status
	cmp esi, 0
	je DeadRick

	; convert position values from FXPT to integer
	mov eax, (SPRITE PTR [edx]).x_coord
	shr eax, 16
	mov ecx, (SPRITE PTR [edx]).y_coord
	shr ecx, 16

	;Draw Sprite
	invoke BasicBlit, (SPRITE ptr [edx]).obj, eax, ecx
	mov eax, 1
	ret
DeadRick:
	mov eax, 0
	ret
DrawRick ENDP


DrawProjectiles PROC uses ebx ecx edx esi edi
	LOCAL startAddr:DWORD

	mov ecx, offset LASER
	mov startAddr, ecx

	xor edx, edx					; edx = offset from starting address
	jmp condition
loop_:
	mov ecx, startAddr
	mov esi, ecx
	add esi, edx	; Projectile index

	; Check if the projectile is active, skip if not 
	mov edi, (PROJECTILE PTR [esi]).status
	cmp edi, 0
	je increment

	; Update singular projectile 
	invoke UpdateProjectileData, esi
	mov ebx, (PROJECTILE PTR [esi]).x_coord
	mov ecx, (PROJECTILE PTR [esi]).y_coord

	; Draw Projectile
	shr ebx, 16
	shr ecx, 16
	invoke BasicBlit, (PROJECTILE PTR [esi]).obj, ebx, ecx
increment:
	mov edi, TYPE LASER
	add edx, edi					; edx = edx + size of one sprite
condition:
	cmp edx, SIZEOF LASER
	jl	loop_
	ret
DrawProjectiles ENDP


DrawPlatforms PROC 
	; draw the ground
	mov eax, offset GROUND
	invoke BasicBlit, (SPRITE PTR [eax]).obj, (SPRITE PTR [eax]).x_coord, (SPRITE PTR [eax]).y_coord

	; draw the starting platform
	;mov eax, offset STARTPLATFORM
	;invoke BasicBlit, (SPRITE PTR [eax]).obj, (SPRITE PTR [eax]).x_coord, (SPRITE PTR [eax]).y_coord

	ret
DrawPlatforms ENDP


DrawScore PROC uses ebx ecx edx esi edi
	mov eax, SCORE
	push eax
	push offset fmtStr
	push offset outstr
	call wsprintf
	add esp, 12
	invoke DrawStr, offset outstr, 550, 10, 000
	ret
DrawScore ENDP


UpdateRickData PROC uses ebx ecx edx esi edi
	mov edx, offset RICK

	; Update Rick's position data
	invoke UpdateSpritePosition, edx

	; Update Rick's status
	invoke CheckRickHit
	ret
UpdateRickData ENDP


UpdateMortyData PROC uses ebx ecx edx esi edi startAddr: DWORD, offset_:DWORD
	mov ebx, startAddr
	add ebx, offset_

	;Update Morty's position
	invoke UpdateMortyPosition, ebx

	; Update Morty's status
	invoke CheckMortyHit, ebx
	cmp eax, 1 
	je UpdateStatus
	ret
UpdateStatus:
	; Deactivate Sprite
	mov (SPRITE PTR [ebx]).status, 0
	inc SCORE
	ret
UpdateMortyData ENDP


UpdateProjectileData PROC uses ebx ecx edx esi edi index_:DWORD
	mov esi, index_

	; Update Laser's position
	invoke UpdateProjectilePosition, esi

	; Update status
	invoke UpdateProjectileStatus, esi
	ret
UpdateProjectileData ENDP


UpdateProjectileStatus PROC uses ebx ecx edx esi edi index_:DWORD
	mov eax, index_
	mov ebx, (PROJECTILE ptr [eax]).x_coord
	
	; Check if projectile is ot of boundaries
	cmp ebx, 000000000h
	jle OutOfBounds
	cmp ebx, 002800000h
	jge OutOfBounds
	ret
OutOfBounds:
	; deactivate projectile
	mov (PROJECTILE PTR [eax]).status, 0
	ret
UpdateProjectileStatus ENDP


UpdateProjectilePosition PROC uses ebx ecx edx esi edi index_:DWORD
	mov eax, index_
	mov ebx, (PROJECTILE ptr [eax]).x_coord
	mov edx, (PROJECTILE ptr [eax]).x_velocity

	; x_coord = x_coord + x_velocity
	add ebx, edx
	mov (PROJECTILE ptr [eax]).x_coord, ebx
	ret
UpdateProjectilePosition ENDP


UpdateMortyPosition PROC uses ebx ecx edx esi edi sprite:DWORD
	mov ecx, sprite

	; check if sprite is at x boundaries
	mov esi, (SPRITE PTR [ecx]).x_coord
	cmp esi, 000000000h
	jle AtLeftEdge
	cmp esi, 002800000h
	jge AtRightEdge
	jmp ChooseVelocity
AtLeftEdge:
	mov (SPRITE PTR [ecx]).obj, offset morty_right
	jmp ChooseVelocity
AtRightEdge:
	mov (SPRITE PTR [ecx]).obj, offset morty_left
ChooseVelocity:
	; determine velocity based on EECS205BITMAP
	mov esi, (SPRITE PTR [ecx]).obj
	cmp esi, offset morty_right
	je posVelocity
negVelocity:
	mov (SPRITE PTR [ecx]).x_velocity, 0fff91958h
	jmp Update
posVelocity:
	mov (SPRITE PTR [ecx]).x_velocity, 000071958h
Update:
	mov esi, (SPRITE PTR [ecx]).x_velocity
	add (SPRITE PTR [ecx]).x_coord, esi		; add x_velocity to x_coord
	ret
UpdateMortyPosition ENDP


UpdateSpritePosition PROC uses ebx ecx edx esi edi sprite:DWORD
	mov ecx, sprite

	; update x_coord
	mov esi, (SPRITE PTR [ecx]).x_velocity	; esi = x velocity
	add (SPRITE PTR [ecx]).x_coord, esi		; add x_velocity to x_coord

	; update y_coord
	mov esi, (SPRITE PTR [ecx]).y_velocity
	add (SPRITE PTR [ecx]).y_coord, esi
	
	; update y_velocity if sprite is airborne
	invoke CheckAirborne, ecx
	cmp eax, 1
	jne NotAirborne
;Sprite is in the air 
GravityActive:
	mov edi, ACCELERATION
	add (SPRITE PTR [ecx]).y_velocity, edi

	; Check if sprite is on the ground or platform
	invoke CheckOnGround, ecx
	cmp eax, 1
	je InactivateGravity
	;invoke CheckOnPlatform, ecx
	;cmp eax, 1
	;je InactivateGravity
	ret
;Sprite is on the ground
InactivateGravity:
	; inactivate gravity
	mov (SPRITE ptr [ecx]).gravity, 0
	mov (SPRITE ptr [ecx]).y_coord, 0015E0000h
	mov (SPRITE ptr [ecx]).y_velocity, 000000000h
NotAirborne:
	ret
UpdateSpritePosition ENDP


; Loops through all active Mortys and checks if any of them hit Rick
CheckRickHit PROC uses ebx ecx edx esi edi
	mov ebx, offset RICK 			; ebx = Rick
	mov ecx, offset MORTY_ARR		; ecx = starting addr of array
	xor edx, edx					; edx = offset from starting address
	jmp condition
loop_:
	mov esi, ecx
	add esi, edx					;esi =  Morty index

	; Check if the Morty is active, skip if not
	mov edi, (SPRITE PTR [esi]).status
	cmp edi, 0
	je increment

	; Check if this Morty hit Rick
	invoke CheckIntersect, (SPRITE ptr [ebx]).x_coord, (SPRITE ptr [ebx]).y_coord, (SPRITE ptr [ebx]).obj, (SPRITE ptr [esi]).x_coord, (SPRITE ptr [esi]).y_coord, (SPRITE ptr [esi]).obj
	cmp eax, 1
	je collision
increment:
	mov edi, TYPE MORTY_ARR
	add edx, edi					; edx = edx + size of one sprite
condition:
	cmp edx, SIZEOF MORTY_ARR
	jl	loop_
	mov eax, 0
	ret
collision:
	; Kill Rick
	mov (SPRITE PTR [ebx]).status, 0
	mov eax, 1
	ret
CheckRickHit ENDP


; Loops through all active projectiles and checks if they hit the morty passed as parameter
CheckMortyHit PROC uses ebx ecx edx esi edi index_:DWORD
	mov ebx, index_					; index into morty array
	mov ecx, offset LASER
	xor edx, edx					; edx = offset from starting address
	jmp condition
loop_:
	mov esi, ecx
	add esi, edx	; Projectile index

	; Check if the projectile is active, skip if not
	mov edi, (PROJECTILE PTR [esi]).status
	cmp edi, 0
	je increment

	; Check if this projectile hit the morty
	invoke CheckIntersect, (SPRITE ptr [ebx]).x_coord, (SPRITE ptr [ebx]).y_coord, (SPRITE ptr [ebx]).obj, (PROJECTILE ptr [esi]).x_coord, (PROJECTILE ptr [esi]).y_coord, (PROJECTILE ptr [esi]).obj
	cmp eax, 1
	je collision
increment:
	mov edi, TYPE LASER
	add edx, edi					; edx = edx + size of one sprite
condition:
	cmp edx, SIZEOF LASER
	jl	loop_
	mov eax, 0
	ret
collision:
	; Deactivate projectile
	mov (PROJECTILE PTR [esi]).status, 0
	mov eax, 1
	ret
CheckMortyHit ENDP


CheckAlive PROC uses ebx ecx edx esi edi startAddr: DWORD, offset_:DWORD
	mov eax, startAddr
	add eax, offset_
	mov ebx, (SPRITE PTR [eax]).status
	cmp ebx, 0
	je dead
	mov eax, 1		; Morty is alive
	ret
dead:
	mov eax, 0		; Morty is dead
	ret
CheckAlive ENDP


; Returns 1 if sprite is airborne, 0 otherwise
CheckAirborne PROC uses ebx ecx edx esi edi sprite:DWORD
	mov ecx, sprite

	; If gravity is activated, sprite is airborne
	mov esi, (SPRITE PTR [ecx]).gravity
	cmp esi, 1
	jne	NotAirborne
	mov eax, 1
	ret
NotAirborne:
	; If gravity is inactivated, sprite is not airborne
	mov eax, 0
	ret
CheckAirborne ENDP


; Returns 1 if the sprite is on the platform, 0 otherwise
CheckOnPlatform PROC uses ebx ecx edx esi edi sprite:DWORD
	LOCAL spriteBottom:DWORD
	mov ecx, offset STARTPLATFORM
	mov ebx, sprite

	mov edx, (SPRITE PTR [ebx]).obj	; pointer to the sprite's bmp

	; get the y-value of the sprite (bottom)
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight	; height of the BMP
	shr eax, 1		; height/2

	mov edx, (SPRITE PTR [ebx]).y_coord
	shr edx, 16		; convert FXPT to INT
	add edx, eax	; y_coord + height/2
	mov spriteBottom, edx

	; if the y-value = top of ground
	mov esi, (PLATFORM PTR [ecx]).top
	cmp edx, esi
	jl FALSE_
	mov eax, 1
	ret
FALSE_:
	mov eax, 0
	ret
CheckOnPlatform ENDP


; Returns 1 if the sprite is on the ground, 0 otherwise
CheckOnGround PROC uses ebx ecx edx esi edi sprite:DWORD
	LOCAL spriteBottom:DWORD
	mov ecx, offset GROUND
	mov ebx, sprite

	mov edx, (SPRITE PTR [ebx]).obj	; pointer to the sprite's bmp

	; get the y-value of the sprite (bottom)
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight	; height of the BMP
	shr eax, 1		; height/2

	mov edx, (SPRITE PTR [ebx]).y_coord
	shr edx, 16		; convert FXPT to INT
	add edx, eax	; y_coord + height/2
	mov spriteBottom, edx

	; if the y-value = top of ground
	mov esi, (PLATFORM PTR [ecx]).top
	cmp edx, esi
	jl FALSE_
	mov eax, 1
	ret
FALSE_:
	mov eax, 0
	ret
CheckOnGround ENDP


CheckKeyPress PROC USES ebx ecx edx esi edi
	mov ebx, offset RICK
	mov ecx, (SPRITE PTR [ebx]).x_coord

	invoke CheckLeftKeyPress
	cmp eax, 1
	je MoveSpriteLeft

	invoke CheckRightKeyPress
	cmp eax, 1
	je MoveSpriteRight

	invoke CheckUpKeyPress
	cmp eax, 1
	je JumpSprite

	invoke CheckSpacePress
	cmp eax, 1
	je Shoot
NoKeyPressed:
	mov (SPRITE PTR[ebx]).x_velocity, 000000000h
	mov LAST_KEY, 000h
	ret
Shoot:
	cmp LAST_KEY, VK_SPACE
	je NoShoot
	invoke InitLaser
	mov LAST_KEY, VK_SPACE
NoShoot:
	ret
; Movement
MoveSpriteLeft:
	; change sprite direction
	mov (SPRITE PTR [ebx]).obj, offset rick_left

	; Move left if not at edge of window
	cmp ecx, 000000000h
	; If at the edge, set values accordingly 
	jle AtLeftEdge
	invoke MoveLeft, ebx
	ret
MoveSpriteRight:
	; change sprite direction
	mov (SPRITE PTR [ebx]).obj, offset rick_right
	
	; Move right if not at edge of window
	cmp ecx, 002800000h
	jge AtRightEdge

	invoke MoveRight, ebx
	ret
JumpSprite:
	; Can't jump if already airborne
	invoke CheckAirborne, ebx
	cmp eax, 1
	je Airborne

	invoke Jump, ebx
	ret
AtRightEdge:
	mov (SPRITE PTR[ebx]).x_coord, 002800000h
	mov (SPRITE PTR[ebx]).x_velocity, 000000000h
	ret
AtLeftEdge:
	mov (SPRITE PTR[ebx]).x_coord, 000000000h
	mov (SPRITE PTR[ebx]).x_velocity, 000000000h
	ret
Airborne:
	; check boundaries so that sprite doesn't jump out of boundaries
	cmp ecx, 000000000h		; x_coord value 
	jle AtLeftEdge
	cmp ecx, 002800000h
	jge AtRightEdge
	ret
CheckKeyPress ENDP


InitLaser PROC uses ebx ecx edx esi edi
	; get Rick's  position
	mov eax, offset RICK
	mov ebx, (SPRITE PTR [eax]).x_coord
	mov ecx, (SPRITE PTR [eax]).y_coord

	; get Rick's direction
	mov esi, (SPRITE PTR [eax]).obj
	cmp esi, offset rick_right
	je right

	; Rick is facing left
	; Get Laser from array
	invoke CreateNewLaser
	mov (PROJECTILE PTR [eax]).x_velocity, 0FFEC0000h
	jmp initposition
right:
	; Rick is facing right
	invoke CreateNewLaser
	mov (PROJECTILE PTR [eax]).x_velocity, 000149283h
initposition:
	; Initialize the laser's position
	mov (PROJECTILE PTR [eax]).x_coord, ebx
	mov (PROJECTILE PTR [eax]).y_coord, ecx
	; Set projectile's status
	mov (PROJECTILE PTR [eax]).status, 1
	ret
InitLaser ENDP

; Returns pointer to laser in EAX
CreateNewLaser PROC uses ebx ecx edx esi edi
	mov ecx, offset LASER
	xor edx, edx					; edx = offset from starting address
	jmp condition
loop_:
	mov esi, ecx
	add esi, edx	; Projectile index

	; Check if the projectile is active, skip if it is 
	mov edi, (PROJECTILE PTR [esi]).status
	cmp edi, 1
	je increment

	; Return inactive projectile index
	mov eax, esi
	ret
increment:
	mov edi, TYPE LASER
	add edx, edi					; edx = edx + size of one sprite
condition:
	cmp edx, SIZEOF LASER
	jl	loop_
	; All projectiles active
	ret
CreateNewLaser ENDP

END