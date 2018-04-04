; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   Name: Idrees Kamal
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

      
.CODE

DrawStarField proc

	;; Draws 16 stars as the background

      invoke DrawStar, 20, 20
      invoke DrawStar, 200, 200
      invoke DrawStar, 150, 150
      invoke DrawStar, 300, 99
      invoke DrawStar, 99, 400
      invoke DrawStar, 600, 400
      invoke DrawStar, 570, 499
      invoke DrawStar, 323, 391
      invoke DrawStar, 12, 5
      invoke DrawStar, 500, 300
      invoke DrawStar, 2, 300
      invoke DrawStar, 565, 370
      invoke DrawStar, 500, 130
      invoke DrawStar, 340, 240
      invoke DrawStar, 200, 400
      invoke DrawStar, 444, 444

     
	ret  			; Careful! Don't remove this line
DrawStarField endp



END
