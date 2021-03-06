; SMALLPONG v1.6 (300 bytes)
; Brad Smith
; 6/29/2008

; 16-bit instruction set, begin at 100h
use16
org 100h

; constants

SCREEN_WIDTH =		320
SCREEN_HEIGHT = 	200
SCREEN_X_MID =		SCREEN_WIDTH / 2
SCREEN_Y_MID =		SCREEN_HEIGHT / 2
SCREEN_SIZE =		SCREEN_WIDTH * SCREEN_HEIGHT

PADDLE_SIZE =		10
;PADDLE_LEFT_X =        0
PADDLE_RIGHT_X =	SCREEN_WIDTH - 1
PADDLE_TOP =		1
PADDLE_MID =		SCREEN_Y_MID - (PADDLE_SIZE/2)
PADDLE_BOTTOM = 	(SCREEN_HEIGHT-1) - PADDLE_SIZE

BALL_MID_X =		SCREEN_X_MID
BALL_MID_Y =		SCREEN_Y_MID
BALL_TOP =		PADDLE_TOP
BALL_BOTTOM =		(PADDLE_BOTTOM + PADDLE_SIZE) - 1

AI_THRESHOLD =		SCREEN_WIDTH - 90
RANDOM_PRIME =		14033

; main program
start:
	; set up VGA mode 13h
		mov	ax, 0013h
		int	10h
		; store video register in es (will stay constant from here on)
		push	word 0A000h
		pop	es

	; reset the screen
		;xor     di, di ; di = 0
		;mov     cx, SCREEN_SIZE
		;xor     al, al ; al = 0
		;repz    stosb

    game_loop:

	; check input
		; reset movement
		mov    word [player_move], 0
		; get shift registers
		mov	ah, 02h
		int	16h
		; test for CTRL
		test	al, 4
		jz	no_ctrl
		inc    word [player_move]
	    no_ctrl:
		; test for ALT
		test	al, 8
		jz	no_alt
		dec    word [player_move]
	    no_alt:

	; wait for vsync
	    vsync_active:
		mov	dx, 03DAh	; input status port for checking retrace
		in	al, dx
		test	al, 8
		jnz	vsync_active	; Bit 3 on signifies activity
	    vsync_retrace:
		in	al, dx
		test	al, 8
		jz	vsync_retrace	; Bit 3 off signifies retrace

	; draw game part 1
		; clear old ball
		mov	ax, [ball_y]
		mov	bx, [ball_x]
		xor	dl, dl ; dl = 0
		call	put_pixel

	; update game state part
		; right paddle AI
			; bx = ball_x
			cmp	bx, AI_THRESHOLD
			mov	bx, [paddle_right_y]
			jl	end_ai
			; ax = ball_y
			sub	al, (PADDLE_SIZE / 2)
			cmp	ax, bx
			je	end_ai
			jg	ai_dn
		    ;ai_up:
			dec	bx
			jmp	end_ai
		    ai_dn:
			inc	bx
		    end_ai:
			call	clamp_paddle
			mov	[paddle_right_y], bx
		; move ball vertical
			mov	ax, [ball_y]
			add	ax, [ball_dy]
			mov	[ball_y], ax
			; bounce vertical
			cmp	al, BALL_TOP
			jne	ball_not_top
			neg	word [ball_dy]
		    ball_not_top:
			cmp	al, BALL_BOTTOM
			jne	ball_not_bottom
			neg	word [ball_dy]
		    ball_not_bottom:
		; move ball horizontal
			mov	cx, [ball_x]
			add	cx, [ball_dx]
			mov	[ball_x], cx
		; check for right paddle collision / goal
			; ax = ball_y
			; bx = paddle_right_y
			; cx = ball_x
			mov	dx, PADDLE_RIGHT_X
			call	collide_paddle
		; left paddle moved by player
			mov	bx, [paddle_left_y]
			add	bx, [player_move]
			call	clamp_paddle
			mov	[paddle_left_y], bx
		; check for left paddle collision / goal
			; ax = ball_y
			; bx = paddle_left
			xor	dx, dx ; dx = PADDLE_LEFT_X
			call	collide_paddle
	; end update game state

	; draw game part 2
		; draw ball
		; ax = ball_y
		mov	bx, [ball_x]
		mov	dl, 15
		call	put_pixel
		; draw left paddle
		mov	ax, [paddle_left_y]
		xor	bx, bx ; bx = PADDLE_LEFT_X
		call	draw_paddle
		; draw right paddle
		mov	ax, [paddle_right_y]
		mov	bx, PADDLE_RIGHT_X
		mov	dl, 15
		call	draw_paddle
	; end draw game

	; continue game if no regular keypresses
	mov	ah, 1
	int	16h
	jz	game_loop

	; [ 2 bytes ]
	; exit if a key has been pressed
	int	20h

; global data

paddle_left_y:	dw	PADDLE_MID
paddle_right_y: dw	PADDLE_MID
player_move:	dw	0
ball_x: 	dw	BALL_MID_X
ball_y: 	dw	BALL_MID_Y
ball_dx:	dw	1
ball_dy:	dw	-1
screen_width:	dw	SCREEN_WIDTH

; subroutines

; put_pixel
; plots a pixel at bx,ax with color dl
; (registers preserved)
put_pixel:
	push	ax bx dx
	mul	word [screen_width]
	add	bx, ax
	pop	dx
	mov	[es:bx], dl
	pop	bx ax
	ret

; draw_paddle
; draws a paddle (position: bx,ax colour: dl)
draw_paddle:
	mov	cx, PADDLE_SIZE
	draw_paddle_loop:
		call	put_pixel
		inc	ax
		loop	draw_paddle_loop
	xor	dl, dl ; dl = 0
	call	put_pixel
	sub	al, PADDLE_SIZE+1
	call	put_pixel
	ret

; clamp_paddle
;   clamps bx to [PADDLE_TOP,PADDLE_BOTTOM]
clamp_paddle:
	cmp	bl, PADDLE_TOP-1
	jne	not_top
	mov	bl, PADDLE_TOP
    not_top:
	cmp	bl, PADDLE_BOTTOM+1
	jne	not_bottom
	mov	bl, PADDLE_BOTTOM
    not_bottom:
	ret

; collide_paddle
;   collides paddle with ball
;   ax = ball_y
;   bx = paddle_y
;   cx = ball_x
;   dx = PADDLE_X
collide_paddle:
	cmp	cx, dx
	jne	no_collide
	cmp	ax, bx
	jl	new_ball
	add	bl, PADDLE_SIZE
	cmp	ax, bx
	jge	new_ball
	neg	word [ball_dx]
	ret
    new_ball:
	; use ax (ball_y) + paddle_y to make a random number:
	add	ax, bx
	mul	word [RANDOM_PRIME]
	; random number now in AX
	and	ax, 127
	add	ax, BALL_MID_Y - 64
	mov	[ball_y], ax
	mov	word [ball_x], BALL_MID_X
	; don't bother resetting ball_dx/dy
	; just send ball to player who just lost
    no_collide:
	ret

; END OF FILE
; Brad Smith, 2008
