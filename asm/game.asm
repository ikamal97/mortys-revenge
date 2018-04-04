; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
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
include game.inc
include gamelogic.inc
include spritelogic.inc
include debug.inc
include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib
include\masm32\include\masm32.inc
includelib\masm32\lib\masm32.lib

;; Has keycodes
include keys.inc

.DATA

TITLESCREEN DWORD 1
INSTRUCTIONS DWORD 1
PAUSED DWORD 0
GAMEMUSIC DWORD 0

;String definitions
gamePausedStr BYTE "GAME PAUSED", 0
gameOverStr BYTE "GAME OVER", 0
gameWinStr BYTE "YOU WIN!", 0


; Filepath for music 
titleMusic BYTE "title_music.wav",0
gameMusic BYTE "game_music_lv.wav", 0

.CODE
	
GameInit PROC
	rdtsc
	invoke nseed, eax
	invoke InitMortys
	invoke PlaySound, offset titleMusic, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP
	ret         ;; Do not delete this line!!!
GameInit ENDP

GamePlay PROC
	; Don't perform if PAUSED
	cmp PAUSED, 1
	je PauseGame
	cmp TITLESCREEN, 1
	je DisplayTitle
	cmp INSTRUCTIONS, 1
	je DisplayInstructions
	cmp GAMEMUSIC, 0
	je PlayGameMusic

	; Clear Screen
	invoke ClearScreenBG

	; Draw platforms
	invoke DrawPlatforms

	; Check for Player Movement
	invoke CheckKeyPress

	; Draw Sprites
	invoke DrawRick		; EAX returns 0 if Rick is dead
	cmp eax, 0
	je GameOver

	invoke DrawMortys	; EAX returns 0 if all Mortys are dead
	cmp eax, 0
	je GameWin

	; Draw Projectiles
	invoke DrawProjectiles

	; Draw the score
	invoke DrawScore

	; Check pause
	invoke CheckPause
	cmp eax, 1
	je PauseGame
	ret

PlayGameMusic:
	invoke PlaySound, offset gameMusic, 0, SND_FILENAME OR SND_ASYNC OR SND_LOOP
	mov GAMEMUSIC, 1
	ret

DisplayTitle:
	; Display the instructions 
	mov TITLESCREEN, 1

	mov eax, offset title_screen
	invoke BasicBlit, eax, 320, 240

	; Check if user presses ENTER
	invoke CheckENTER
	cmp eax, 1
	je DisplayInstructions
	ret

DisplayInstructions:

	mov TITLESCREEN, 0
	invoke ClearScreen
	; Display the instructions 
	mov INSTRUCTIONS, 1

	mov eax, offset instructions_background
	invoke BasicBlit, eax, 320, 240

	; Check if user presses ENTER
	invoke CheckENTER
	cmp eax, 1
	je StartGame
	ret

StartGame:
	mov INSTRUCTIONS, 0
	ret

PauseGame:
	invoke PausedGame
	ret
GamePlay ENDP


CheckENTER PROC uses ebx ecx edx esi edi
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_RETURN
	jne FALSE_
	mov eax, 1
	mov KeyPress, 000h
	ret
FALSE_:
	ret
CheckENTER ENDP

CheckPause PROC uses ebx ecx edx esi edi
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_P
	jne FALSE_
	mov eax, 1
	ret
FALSE_:
	ret
CheckPause ENDP


PausedGame PROC 
	mov PAUSED, 1
	invoke DrawStr, offset gamePausedStr, 280, 200, 000h

	;Check if player unpaused
	invoke CheckUnpause
	cmp eax, 1
	je UnpauseGame
	ret

UnpauseGame:
	mov PAUSED, 0
	ret
PausedGame ENDP


CheckUnpause PROC uses ebx ecx edx esi edi
	mov eax, 0
	mov ecx, KeyPress
	cmp ecx, VK_U
	jne FALSE_
	mov eax, 1
	ret
FALSE_:
	ret
CheckUnpause ENDP


GameWin PROC
	invoke DrawStr, offset gameWinStr, 280, 200, 000h
	invoke DrawScore
	ret
GameWin ENDP

GameOver PROC
	invoke DrawStr, offset gameOverStr, 280, 200, 000h
	invoke DrawScore
	ret
GameOver ENDP






END
