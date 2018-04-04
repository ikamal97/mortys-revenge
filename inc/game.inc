; #########################################################################
;
;   game.inc - Includes for EECS205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS

BMPPTR TYPEDEF PTR EECS205BITMAP

; Projectile struct
_PROJECTILE STRUCT
	obj BMPPTR ?
	x_coord FXPT ?
	y_coord FXPT ?
	x_velocity	FXPT ?
	status DWORD 0
_PROJECTILE ENDS

PROJECTILE TYPEDEF _PROJECTILE

; Platform struct 
_PLATFORM STRUCT
	obj BMPPTR ?
	x_coord DWORD ?
	y_coord DWORD ?
	top		DWORD ?
_PLATFORM ENDS

PLATFORM TYPEDEF _PLATFORM

; Rectangle boundaries used for collision checking
_RECTANGLE STRUCT
 upperLeftX DWORD ?
 upperLeftY DWORD ?
 upperRightX DWORD ?
 upperRightY DWORD ?
 bottomLeftX DWORD ?
 bottomLeftY DWORD ?
 bottomRightX DWORD ?
 bottomRightY DWORD ?
_RECTANGLE ENDS

RECTANGLE TYPEDEF _RECTANGLE

;; Sprite Struct : Keeps track of x, y coordinates and rotation of a sprite
_SPRITE STRUCT
 obj BMPPTR ?  			; pointer to the bitmap data
 x_coord FXPT ? 		; the x-coordinate location
 y_coord FXPT 0015E0000h		; the y-coordinate location
 rotation FXPT 000000000h		; rotation in fxpt angle
 x_velocity FXPT 000000000h
 y_velocity FXPT 000000000h
 status DWORD 1			; 1 = alive, 0 = dead
 gravity DWORD 0		; 1 = gravity acting on sprite
 shooting DWORD 0		; 1 = sprite is shooting
_SPRITE ENDS	

SPRITE TYPEDEF _SPRITE

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD
EXTERNDEF asteroid_000:EECS205BITMAP
EXTERNDEF rick:EECS205BITMAP
EXTERNDEF rick_up:EECS205BITMAP
EXTERNDEF rick_left:EECS205BITMAP
EXTERNDEF rick_right:EECS205BITMAP
EXTERNDEF morty:EECS205BITMAP
EXTERNDEF morty_right:EECS205BITMAP
EXTERNDEF morty_left:EECS205BITMAP
EXTERNDEF neutrino_bomb:EECS205BITMAP
EXTERNDEF background_1:EECS205BITMAP
EXTERNDEF ground:EECS205BITMAP
EXTERNDEF laser:EECS205BITMAP
EXTERNDEF instructions_background:EECS205BITMAP
EXTERNDEF title_screen:EECS205BITMAP
EXTERNDEF platform:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
GameOver PROTO
CheckPause PROTO
PausedGame PROTO 
CheckUnpause PROTO
CheckENTER PROTO

