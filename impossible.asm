.nolist
	#include	"ti83plus.inc"
	#include	"mirage.inc"
.list
.org	$9D93
.db	$BB, $6D

screenBuf	equ	$8000		;1036 = 14*74
commandsBuf	equ	screenBuf+1036	;508

gameVarStart	equ	commandsBuf+508

spriteBuf	equ	gameVarStart	;150
itemBuf		equ	spriteBuf+150	;50
sprites		equ	itemBuf+50	;1
items		equ	sprites+1	;1
spritePtr	equ	items+1		;2
itemPtr		equ	spritePtr+2	;2
spriteTill	equ	itemPtr+2	;2
itemTill	equ	spriteTill+2	;2
spriteDark	equ	itemTill+1	;1
itemDark	equ	spriteDark+1	;1
squareY		equ	itemDark+1	;2
yVel		equ	squareY+2	;2
scrolled	equ	yVel+2		;1
jumpCount	equ	scrolled+1	;1
pausePressed	equ	jumpCount+1	;1
winCount	equ	pausePressed+1	;1
intCount	equ	winCount+1	;1
invert		equ	intCount+1	;1
effectFlags	equ	invert+1	;1
flipped		equ	effectFlags+1	;1

;blank for now				;2

darkCount	equ	flipped+3	;1
levelCount	equ	darkCount+1	;2
winsNeeded	equ	levelCount+2	;1

gameVarEnd		equ	winsNeeded+1


interruptBuf	equ	$8D00
commandTable	equ	$8E01


varStart	equ	appBackUpScreen
contrastSave	equ	varStart	;1
tempContrast	equ	contrastSave+1	;1
forAppVar	equ	tempContrast+1	;2
appVarShad	equ	forAppVar+2	;20
appVarDirty	equ	appVarShad+20	;1
goodCalc	equ	appVarDirty+1	;1
selected	equ	goodCalc+1	;1
levelData	equ	selected+1	;2
attempt		equ	levelData+2	;2
attemptBuf	equ	attempt+2	;16
attemptPic	equ	attemptBuf+16	;35

varEnd		equ	attemptPic+35



; ---------------------------------------------------------------------------
		ret
; ---------------------------------------------------------------------------
		db    1
		db    0
		db    0
		db    0
		db    0
		db    8
		db    0
		db  14h
		db    0
		db  22h	; "
		db    0
		db  14h
		db    0
		db    8
		db    0
		db    3
		db  18h
		db    3
		db  18h
		db    7
		db 0BCh	; ¼
		db    7
		db 0BCh	; ¼
		db 0FFh
		db 0FEh	; þ
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
aTheImpossibleG:
	.db "The Impossible Game v2.0",0
; ---------------------------------------------------------------------------
		set	7, (iy+14h)
		res	1, (iy+0Dh)
		ld	a, 1
		ld	(goodCalc), a
		di
		xor	a
		ld	r, a
		ld	a, r
		cp	2
		jr	nz, badCalcz
		in	a, (2)
		and	20h ; ' '
		jr	nz, calcIsGood
		in	a, (21h)
		and	1
		jr	z, calcIsGood

badCalcz:				; CODE XREF: RAM:9DE3j
		xor	a
		ld	(goodCalc), a

calcIsGood:				; CODE XREF: RAM:9DE9j	RAM:9DEFj
		im	1
		in	a, (29h)
		push	af
		ld	a, 0Ch
		out	(29h), a
		rst	28h
; ---------------------------------------------------------------------------
		dw 4C84h		; disableAPD
; ---------------------------------------------------------------------------
		ld	hl, statVars
		ld	de, varEnd
		ld	bc, 64h	; 'd'
		ldir
		ld	a, (contrast)
		ld	(tempContrast),	a
		ld	(contrastSave),	a
		ld	hl, appVarName
		rst	20h
		rst	28h
; ---------------------------------------------------------------------------
		dw 42F1h		; chkFindSym
; ---------------------------------------------------------------------------
		jr	nc, appVarExists
		ld	hl, 14h
		rst	28h
; ---------------------------------------------------------------------------
		dw 4E6Ah		; createAppvar
; ---------------------------------------------------------------------------
		inc	de
		inc	de
		ld	l, e
		ld	h, d
		inc	de
		ld	bc, 13h
		ld	(hl), 0
		ldir
		ld	hl, appVarName
		rst	20h

inRam:					; CODE XREF: RAM:9E40j
		rst	28h
; ---------------------------------------------------------------------------
		dw 4FD8h		; arcUnarc
; ---------------------------------------------------------------------------
		ld	hl, appVarName
		rst	20h
		rst	28h
; ---------------------------------------------------------------------------
		dw 42F1h		; chkFindSym
; ---------------------------------------------------------------------------

appVarExists:				; CODE XREF: RAM:9E1Cj
		ld	a, b
		or	a
		jr	z, inRam
		call	findStartInRom
		ld	a, b
		ld	de, forAppVar
		ld	bc, 16h
		rst	28h
; ---------------------------------------------------------------------------
		dw 5017h		; flashToRam
; ---------------------------------------------------------------------------
		xor	a
		ld	(appVarDirty), a
		ld	a, (forAppVar)
		cp	8
		jr	nz, mainMenu
		ld	bc, (appVarShad)
		ld	de, (appVarShad+2)
		ld	hl, (appVarShad+4)
		ld	(appVarShad), hl
		ld	hl, (appVarShad+6)
		ld	(appVarShad+2),	hl
		ld	(appVarShad+4),	bc
		ld	(appVarShad+6),	de
		ld	hl, appVarShad+8
		ld	de, appVarShad+9
		ld	(hl), 0
		ld	bc, 0Bh
		ldir
		ld	a, 1
		ld	(appVarDirty), a

mainMenu:				; CODE XREF: RAM:9E58j	RAM:A0C2j ...
		xor	a
		ld	(selected), a

mainMenuLp:				; CODE XREF: RAM:9F06j
		set	3, (iy+5)
		call	blackScreen
		ld	hl, titleText
		ld	b, 5
		call	textAScreen
		ld	a, (selected)
		rlca
		rlca
		rlca
		add	a, 17h
		ld	(penRow),	a
		ld	a, 0Fh
		ld	(penCol), a
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	a, 46h ; 'F'
		ld	(penCol), a
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	hl, 0C09h
		ld	de, 5309h
		xor	a
		call	fastLine
		ld	hl, 313h
		ld	de, 332h
		xor	a
		call	fastLine
		ld	hl, 5C13h
		ld	de, 5C32h
		xor	a
		call	fastLine
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------

menuKeyLoop:				; CODE XREF: RAM:9F0Aj
		ei
		halt
		rst	28h
; ---------------------------------------------------------------------------
		dw 4018h		; getCSC
; ---------------------------------------------------------------------------
		cp	36h ; '6'
		jr	z, secondPressed
		cp	9
		jr	nz, notEnter

secondPressed:				; CODE XREF: RAM:9EDEj
		ld	a, (selected)
		or	a
		jp	z, pickScreen
		dec	a
		jr	z, statsScreen
		jp	quit
; ---------------------------------------------------------------------------

notEnter:				; CODE XREF: RAM:9EE2j
		cp	0Fh
		jp	z, quit
		cp	4
		jr	nz, notUp
		ld	a, (selected)
		sub	1
		jr	nc, titleCommon
		ld	a, 2

titleCommon:				; CODE XREF: RAM:9EFFj	RAM:9F12j ...
		ld	(selected), a
		jr	mainMenuLp
; ---------------------------------------------------------------------------

notUp:					; CODE XREF: RAM:9EF8j
		cp	1
		jr	nz, menuKeyLoop
		ld	a, (selected)
		inc	a
		cp	3
		jr	nz, titleCommon
		xor	a
		jr	titleCommon
; ---------------------------------------------------------------------------

statsScreen:				; CODE XREF: RAM:9EECj
		xor	a
		ld	(selected), a

statsLoop:				; CODE XREF: RAM:A0BDj	RAM:A0D1j
		call	blackScreen
		ld	hl, aStats	; "Stats"
		ld	de, 28h	; '('
		call	vPutSDE
		ld	a, (selected)
		ld	b, a
		ld	hl, screen1
		or	a
		jr	z, foundText
		ld	hl, screen2
		dec	a
		jr	z, foundText
		ld	hl, screen3

foundText:				; CODE XREF: RAM:9F2Fj	RAM:9F35j
		ld	a, b
		cp	2
		jr	nz, notHaulScreen
		push	hl
		call	isHaulUnlocked
		pop	hl
		jr	nz, notHaulScreen
		ld	hl, haulNotText
		ld	b, 2
		call	textAScreen
		jp	haulReturn
; ---------------------------------------------------------------------------

notHaulScreen:				; CODE XREF: RAM:9F3Dj	RAM:9F44j
		ld	a, (selected)
		add	a, a
		ld	b, a
		add	a, a
		add	a, b
		ld	de, statData
		add	a, e
		ld	e, a
		jr	nc, noCarry1
		inc	d

noCarry1:				; CODE XREF: RAM:9F5Dj
		ld	b, 2

statsDispNames:				; CODE XREF: RAM:9F83j
		push	bc
		ld	a, (de)
		or	a
		jr	z, noText
		ex	de, hl
		ld	c, a
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	(penCol), bc
		ld	b, (hl)
		inc	hl
		ex	de, hl

statsNameLp:				; CODE XREF: RAM:9F80j
		inc	hl
		inc	hl
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	a, (penCol)
		inc	a
		inc	a
		ld	(penCol), a
		djnz	statsNameLp

noText:					; CODE XREF: RAM:9F65j
		pop	bc
		djnz	statsDispNames
		ld	a, (selected)
		cp	2
		jr	z, drawHalf
		add	a, a
		add	a, a
		add	a, a
		ld	hl, appVarShad+4
		add	a, l
		ld	l, a
		jr	nc, noCarry2
		inc	h

noCarry2:				; CODE XREF: RAM:9F94j
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		push	hl
		ex	de, hl
		ld	a, 1Eh
		rst	28h
; ---------------------------------------------------------------------------
		dw 4012h		; divHLbyA
; ---------------------------------------------------------------------------
		push	hl
		srl	l
		ld	a, 5
		add	a, l
		ld	h, a
		ld	l, 2Fh ; '/'
		ld	de, 52Fh
		call	drawBar
		pop	hl
		ld	de, 8000h
		call	convHex
		ld	a, 25h ; '%'
		ld	(de), a
		inc	de
		xor	a
		ld	(de), a
		ld	hl, 8000h
		ld	de, 2E3Ch
		call	vPutSDE
		ld	hl, aTimesCompleted ; "Times  completed:  "
		ld	de, 360Ch
		call	vPutSDE
		pop	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl
		ld	de, 8000h
		call	convHex
		ld	hl, 8000h
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	hl, 52Eh
		ld	de, 534h
		xor	a
		call	fastLine
		ld	hl, 372Eh
		ld	de, 3734h
		xor	a
		call	fastLine

drawHalf:				; CODE XREF: RAM:9F8Aj
		ld	a, (selected)
		add	a, a
		add	a, a
		add	a, a
		ld	hl, appVarShad
		add	a, l
		ld	l, a
		jr	nc, noCarry3
		inc	h

noCarry3:				; CODE XREF: RAM:A000j
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		push	hl
		ex	de, hl
		ld	b, 1Eh
		ld	a, (selected)
		cp	2
		jr	nz, notTheHaul
		ld	b, 7Fh ; ''

notTheHaul:				; CODE XREF: RAM:A010j
		ld	a, b
		rst	28h
; ---------------------------------------------------------------------------
		dw 4012h		; divHLbyA
; ---------------------------------------------------------------------------
		push	hl
		srl	l
		ld	a, 5
		add	a, l
		ld	h, a
		ld	l, 13h
		ld	de, 513h
		call	drawBar
		pop	hl
		ld	de, 8000h
		call	convHex
		ld	a, 25h ; '%'
		ld	(de), a
		inc	de
		xor	a
		ld	(de), a
		ld	hl, 8000h
		ld	de, 123Ch
		call	vPutSDE
		ld	hl, aTimesCompleted ; "Times  completed:  "
		ld	de, 1A0Ch
		call	vPutSDE
		pop	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ex	de, hl
		ld	de, 8000h
		call	convHex
		ld	hl, 8000h
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	hl, 512h
		ld	de, 518h
		xor	a
		call	fastLine
		ld	hl, 3712h
		ld	de, 3718h
		xor	a
		call	fastLine

haulReturn:				; CODE XREF: RAM:9F4Ej
		ld	hl, 408h
		ld	de, 5B08h
		xor	a
		call	fastLine
		ld	hl, 424h
		ld	de, 5B24h
		xor	a
		call	fastLine
		ld	a, (selected)
		ld	b, a
		cp	2
		jr	z, isLastScreen
		ld	de, 385Bh
		ld	(penCol), de
		ld	a, 5
		rst	28h
; ---------------------------------------------------------------------------
		dw 455Eh		; vPutMap
; ---------------------------------------------------------------------------

isLastScreen:				; CODE XREF: RAM:A085j
		ld	a, b
		or	a
		jr	z, isFirstScreen
		ld	de, 3802h
		ld	(penCol), de
		ld	a, 0CFh	; 'Ï'
		rst	28h
; ---------------------------------------------------------------------------
		dw 455Eh		; vPutMap
; ---------------------------------------------------------------------------

isFirstScreen:				; CODE XREF: RAM:A095j
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------

statsKeyLoop:				; CODE XREF: RAM:A0ACj
		ei
		halt
		rst	28h
; ---------------------------------------------------------------------------
		dw 4018h		; getCSC
; ---------------------------------------------------------------------------
		or	a
		jr	z, statsKeyLoop
		cp	2
		jr	nz, notzLeft
		ld	a, (selected)
		sub	1
		jr	nc, statsCommon
		inc	a

statsCommon:				; CODE XREF: RAM:A0B7j
		ld	(selected), a
		jp	statsLoop
; ---------------------------------------------------------------------------

notzLeft:				; CODE XREF: RAM:A0B0j
		cp	3
		jp	nz, mainMenu
		ld	a, (selected)
		inc	a
		cp	3
		jr	nz, statsCommon2
		dec	a

statsCommon2:				; CODE XREF: RAM:A0CBj
		ld	(selected), a
		jp	statsLoop
; ---------------------------------------------------------------------------

pickScreen:				; CODE XREF: RAM:9EE8j
		xor	a
		ld	(selected), a

pickScreenLp:				; CODE XREF: RAM:A155j	RAM:A17Dj
		call	blackScreen
		ld	a, (selected)
		bit	2, a
		jp	nz, haulSelected
		ld	hl, screen1
		ld	b, 9
		call	textAScreen
		ld	de, 101h
		rrca
		jr	nc, leftSide
		ld	d, 31h ; '1'

leftSide:				; CODE XREF: RAM:A0EFj
		rrca
		jr	nc, bottom
		ld	e, 21h ; '!'

bottom:					; CODE XREF: RAM:A0F4j
		ld	bc, 2D1Dh
		call	doBox
		ld	hl, appVarShad+2
		ld	e, 3
		ld	b, 2

showWin:				; CODE XREF: RAM:A11Fj
		push	bc
		ld	b, 2
		ld	d, 3

showWin2:				; CODE XREF: RAM:A11Aj
		ld	a, (hl)
		inc	hl
		or	(hl)
		inc	hl
		inc	hl
		inc	hl
		push	bc
		ld	bc, 2919h
		call	nz, doBox
		pop	bc
		ld	d, 33h ; '3'
		djnz	showWin2
		pop	bc
		ld	e, 23h ; '#'
		djnz	showWin
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------

pickKeyLoop:				; CODE XREF: RAM:A15Ej	RAM:A198j ...
		call	isHaulUnlocked
		ld	a, (selected)
		ld	c, a
		push	af
		ei
		halt
		rst	28h
; ---------------------------------------------------------------------------
		dw 4018h		; getCSC
; ---------------------------------------------------------------------------
		pop	de
		cp	36h ; '6'
		jp	z, newGame
		cp	9
		jp	z, newGame
		cp	0Fh
		jp	z, mainMenu
		ld	b, a
		bit	6, e
		jr	z, haulButtons

standardButtons:			; CODE XREF: RAM:A16Cj
		ld	a, b
		cp	2
		jr	z, moveHoriz
		cp	3
		jr	nz, notHoriz

moveHoriz:				; CODE XREF: RAM:A149j	RAM:A176j ...
		ld	a, c
		xor	1

pickScreenCom:				; CODE XREF: RAM:A163j
		ld	(selected), a
		jp	pickScreenLp
; ---------------------------------------------------------------------------

notHoriz:				; CODE XREF: RAM:A14Dj
		cp	4
		jr	z, moveVert
		cp	1
		jr	nz, pickKeyLoop

moveVert:				; CODE XREF: RAM:A15Aj	RAM:A192j ...
		ld	a, c
		xor	2
		jr	pickScreenCom
; ---------------------------------------------------------------------------

haulButtons:				; CODE XREF: RAM:A144j
		ld	a, c
		bit	2, a
		jr	z, notOnHaul
		res	2, c
		jr	standardButtons
; ---------------------------------------------------------------------------

notOnHaul:				; CODE XREF: RAM:A168j
		ld	a, b
		cp	2
		jr	nz, notLeftz
		ld	a, c
		bit	0, a
		jr	nz, moveHoriz

haulCommon:				; CODE XREF: RAM:A189j	RAM:A194j ...
		or	4
		ld	(selected), a
		jp	pickScreenLp
; ---------------------------------------------------------------------------

notLeftz:				; CODE XREF: RAM:A171j
		cp	3
		jr	nz, notRight
		ld	a, c
		bit	0, a
		jr	z, moveHoriz
		jr	haulCommon
; ---------------------------------------------------------------------------

notRight:				; CODE XREF: RAM:A182j
		cp	4
		jr	nz, notUpz
		ld	a, c
		bit	1, a
		jr	nz, moveVert
		jr	haulCommon
; ---------------------------------------------------------------------------

notUpz:					; CODE XREF: RAM:A18Dj
		cp	1
		jr	nz, pickKeyLoop
		ld	a, c
		bit	1, a
		jr	z, moveVert
		jr	haulCommon
; ---------------------------------------------------------------------------

haulSelected:				; CODE XREF: RAM:A0E0j
		ld	hl, haulText
		ld	b, 5
		call	textAScreen
		ld	de, 1C19h
		ld	bc, 270Ch
		call	doBox
		ld	hl, (appVarShad+18)
		ld	a, h
		or	l
		ld	de, 1E1Bh
		ld	bc, 2308h
		call	nz, doBox
		ld	hl, 415h
		ld	de, 5B15h
		xor	a
		call	fastLine
		ld	hl, 429h
		ld	de, 5B29h
		xor	a
		call	fastLine
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------
		jp	pickKeyLoop
; ---------------------------------------------------------------------------
levels:		dw fireAura		; DATA XREF: RAM:A1F1o
		dw xboxLevel		
		dw chaozFantasy
		dw heaven
; ---------------------------------------------------------------------------

newGame:				; CODE XREF: RAM:A134j	RAM:A139j
		di
		ld	a, (selected)
		bit	2, a
		jr	z, notHaulin
		ld	a, 4
		ld	(selected), a
		xor	a

notHaulin:				; CODE XREF: RAM:A1E8j
		add	a, a
		ld	hl, levels
		add	a, l
		ld	l, a
		jr	nc, noCarry4
		inc	h

noCarry4:				; CODE XREF: RAM:A1F6j
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	l, a
		ld	(levelData), hl
		call	ioSaveLoad
		ld	hl, aAttempt
		ld	de, attemptBuf
		ld	bc, 9
		ldir
		ld	hl, 0
		ld	(attempt), hl
		ld	hl, interruptBuf
		ld	de, interruptBuf+1
		ld	bc, 100h
		ld	(hl), 99h ; ''
		ldir
		ld	a, 0C3h	; 'Ã'
		ld	($9999), a
		ld	hl, interrupt
		ld	($999A), hl
		ld	a, 8Dh ; ''
		ld	i, a
		im	2
		call	interrupt
; START	OF FUNCTION CHUNK FOR death

start:					; CODE XREF: death+1Cj	death+28j
		ld	hl, screenBuf
		ld	de, screenBuf+1
		ld	bc, 40Bh
		ld	(hl), 0
		ldir
		ld	hl, plotSScreen
		ld	de, plotSScreen+1
		ld	bc, 4Bh	; 'K'
		ld	(hl), 0
		ldir
		ld	hl, (attempt)
		inc	hl
		ld	(attempt), hl
		ld	de, attemptBuf+9
		call	convHex
		res	3, (iy+5)
		ld	hl, attemptBuf
		ld	de, 4
		ld	(penCol), de
		rst	28h
; END OF FUNCTION CHUNK	FOR death
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ld	hl, plotSScreen+12
		ld	de, attemptPic
		ld	b, 5

copyAttemptLp:				; CODE XREF: RAM:A282j
		push	bc
		ld	bc, 7
		ldir
		push	de
		ld	de, 5
		add	hl, de
		pop	de
		pop	bc
		djnz	copyAttemptLp
		call	makeCMDs
		ld	hl, gameVarStart
		ld	de, gameVarStart+1
		ld	bc, gameVarEnd-gameVarStart
		ld	(hl), 0
		ldir
		ld	a, 0Ah
		ld	(spriteTill), a
		ld	a, 2Ah ; '*'
		ld	(itemTill),	a
		ld	hl, (levelData)
		ld	(spritePtr), hl
		ld	(itemPtr), hl
		ld	a, (selected)
		and	4
		jr	z, isHauling
		ld	a, 3
		ld	(winsNeeded), a

isHauling:				; CODE XREF: RAM:A2ACj
		ld	a, (contrastSave)
		ld	(tempContrast),	a
		add	a, 0D8h	; 'Ø'
		out	(10h), a
		ld	a, (goodCalc)
		or	a
		call	nz, waitDone

gameLoop:				; CODE XREF: RAM:A37Aj	RAM:A388j
		ld	hl, (levelCount)
		inc	hl
		ld	(levelCount), hl
		call	nextSprite
		call	doPhysics
		call	dispAttempts
		call	dispSquare
		call	dispSprites
		ld	a, (scrolled)
		cp	13h
		jr	nc, cantSeeLine
		ld	l, a
		ld	h, 0
		ld	e, l
		ld	d, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		sbc	hl, de
		add	hl, hl
		call	negHL
		ld	de, screenBuf+322
		add	hl, de
		ld	e, l
		ld	d, h
		inc	de
		ld	bc, 0Dh
		ld	(hl), 0FFh
		ldir

cantSeeLine:				; CODE XREF: RAM:A2DFj
		ld	a, (winCount)
		or	a
		jr	z, notWinning
		dec	a
		ld	(winCount), a
		jp	z, totalVictory
		and	7
		jr	nz, notWinning
		ld	a, (tempContrast)
		cp	27h ; '''
		jr	nc, notWinning
		inc	a
		ld	(tempContrast),	a
		add	a, 0D8h	; 'Ø'
		out	(10h), a

notWinning:				; CODE XREF: RAM:A302j	RAM:A30Dj ...
		ld	a, (flipped)
		or	a
		call	z, regFastCopy
		call	nz, invFastCopy
		ld	a, 0BFh	; '¿'
		call	keyScan
		bit	7, b
		jr	nz, notMenuing
		call	ioSaveLoad
		jp	mainMenu
; ---------------------------------------------------------------------------

notMenuing:				; CODE XREF: RAM:A32Fj
		bit	6, b
		jr	nz, notPausing
		ld	a, (pausePressed)
		or	a
		jr	nz, pauseDone
		halt
		halt

unKeyLp:				; CODE XREF: RAM:A34Bj
		halt
		ld	a, 0BFh	; '¿'
		call	keyScan
		bit	6, b
		jr	z, unKeyLp

keyLp:					; CODE XREF: RAM:A355j
		halt
		ld	a, 0BFh	; '¿'
		call	keyScan
		bit	6, b
		jr	nz, keyLp
		ld	a, 1
		ld	(pausePressed),	a
		jr	pauseDone
; ---------------------------------------------------------------------------

notPausing:				; CODE XREF: RAM:A339j
		xor	a
		ld	(pausePressed),	a

pauseDone:				; CODE XREF: RAM:A33Fj	RAM:A35Cj
		ld	a, 0FDh	; 'ý'
		call	keyScan
		bit	6, b
		jr	nz, notQuit
		call	ioSaveLoad
		jp	quit
; ---------------------------------------------------------------------------

notQuit:				; CODE XREF: RAM:A369j
		ld	a, (goodCalc)
		or	a
		jr	z, isBadCalc
		call	waitLoop
		jp	gameLoop
; ---------------------------------------------------------------------------

isBadCalc:				; CODE XREF: RAM:A375j	RAM:A382j
		ld	a, (intCount)
		cp	3
		jr	c, isBadCalc
		xor	a
		ld	(intCount), a
		jp	gameLoop
; ---------------------------------------------------------------------------

totalVictory:				; CODE XREF: RAM:A308j
		call	ioSaveLoad
		call	blackScreen
		set	3, (iy+5)
		ld	a, (selected)
		ld	hl, winText
		ld	b, 2
		and	4
		jr	z, notWinHaul
		ld	hl, wowText
		ld	b, 1

notWinHaul:				; CODE XREF: RAM:A39Fj
		call	textAScreen
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------

dwait1:					; CODE XREF: RAM:A3B0j
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait1
		ld	a, (contrastSave)
		ld	(tempContrast),	a
		add	a, 0D8h	; 'Ø'
		out	(10h), a
		call	isHaulUnlocked
		push	af
		ld	de, 0BB8h
		ld	a, (selected)
		bit	2, a
		jr	z, notWinHaul2
		ld	hl, (appVarShad+14)
		inc	hl
		ld	(appVarShad+14), hl
		ld	de, 319Ch

notWinHaul2:				; CODE XREF: RAM:A3C8j
		add	a, a
		add	a, a
		ld	hl, appVarShad
		add	a, l
		ld	l, a
		jr	nc, notCarry5
		inc	h

notCarry5:				; CODE XREF: RAM:A3DBj
		ld	(hl), e
		inc	hl
		ld	(hl), d
		inc	hl
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	de
		ld	(hl), d
		dec	hl
		ld	(hl), e
		ld	a, 1
		ld	(appVarDirty), a

winKeyLoop:				; CODE XREF: RAM:A3F4j	RAM:A3F8j ...
		ei
		halt
		rst	28h
; ---------------------------------------------------------------------------
		dw 4018h		; getCSC
; ---------------------------------------------------------------------------
		or	a
		jr	z, winKeyLoop
		cp	36h ; '6'
		jr	z, winKeyLoop
		cp	4
		jr	z, winKeyLoop
		pop	af
		jp	nz, mainMenu
		call	isHaulUnlocked
		jp	z, mainMenu
		call	blackScreen
		ld	hl, unlockedText
		ld	b, 5
		call	textAScreen
		rst	28h
; ---------------------------------------------------------------------------
		dw 486Ah		; grBufCpy
; ---------------------------------------------------------------------------

winKeyLp2:				; CODE XREF: RAM:A41Cj
		ei
		halt
		rst	28h
; ---------------------------------------------------------------------------
		dw 4018h		; getCSC
; ---------------------------------------------------------------------------
		or	a
		jr	z, winKeyLp2
		jp	mainMenu
; ---------------------------------------------------------------------------

quit:					; CODE XREF: RAM:9EEEj	RAM:9EF3j ...
		di
		im	1
		ld	a, 0Bh
		out	(3), a
		ld	hl, varEnd
		ld	de, statVars
		ld	bc, 64h	; 'd'
		ldir
		rst	28h
; ---------------------------------------------------------------------------
		dw 4540h		; clrLCDFull
; ---------------------------------------------------------------------------
		rst	28h
; ---------------------------------------------------------------------------
		dw 4BD0h		; grBufClr
; ---------------------------------------------------------------------------
		rst	28h
; ---------------------------------------------------------------------------
		dw 4C87h		; enableAPD
; ---------------------------------------------------------------------------
		res	2, (iy+2)
		res	3, (iy+5)
		pop	af
		out	(29h), a
		ld	a, (contrastSave)
		ld	(contrast), a
		add	a, 0D8h	; 'Ø'
		out	(10h), a
		ld	a, (appVarDirty)
		or	a
		jr	z, notDirty
		ld	hl, appVarName
		rst	20h
		rst	28h
; ---------------------------------------------------------------------------
		dw 42F1h		; chkFindSym
; ---------------------------------------------------------------------------
		rst	28h
; ---------------------------------------------------------------------------
		dw 4FC6h		; delVarArc
; ---------------------------------------------------------------------------
		ld	hl, appVarName
		rst	20h
		ld	hl, 14h
		rst	28h
; ---------------------------------------------------------------------------
		dw 4E6Ah		; createAppVar
; ---------------------------------------------------------------------------
		inc	de
		inc	de
		ld	hl, appVarShad
		ld	bc, 14h
		ldir
		ld	hl, appVarName
		rst	20h
		rst	28h
; ---------------------------------------------------------------------------
		dw 4FD8h		; arc_unarc
; ---------------------------------------------------------------------------

notDirty:				; CODE XREF: RAM:A455j
		ld	hl, progName
		rst	20h
		rst	28h
; ---------------------------------------------------------------------------
		dw 42F1h		; chkFindSym
; ---------------------------------------------------------------------------
		ld	de, ($96A5)
		or	a
		sbc	hl, de
		ld	a, h
		add	hl, de
		or	a
		ret	nz
		ld	($96A5), hl
		ret

; =============== S U B	R O U T	I N E =======================================


death:					; CODE XREF: doPhysics+B3p
					; doPhysics+F9p ...

; FUNCTION CHUNK AT A235 SIZE 00000036 BYTES

		pop	af
		pop	af
		ld	a, (selected)
		add	a, a
		add	a, a
		ld	hl, appVarShad
		add	a, l
		ld	l, a
		jr	nc, loc_A4A1
		inc	h

loc_A4A1:				; CODE XREF: death+Cj
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	de
		push	hl
		ld	hl, (levelCount)
		or	a
		sbc	hl, de
		add	hl, de
		pop	de
		jp	c, start
		ex	de, hl
		ld	(hl), d
		dec	hl
		ld	(hl), e
		ld	a, 1
		ld	(appVarDirty), a
		jp	start
; End of function death


; =============== S U B	R O U T	I N E =======================================


doBox:					; CODE XREF: RAM:A0FBp	RAM:A114p ...
		push	bc
		push	de
		push	hl
		push	de
		ld	a, b
		add	a, d
		ld	h, a
		ld	l, e
		xor	a
		push	bc
		push	hl
		call	fastLine
		pop	de
		pop	bc
		ld	a, c
		add	a, e
		ld	l, a
		ld	h, d
		xor	a
		push	bc
		push	hl
		call	fastLine
		pop	de
		pop	bc
		ld	a, d
		sub	b
		ld	h, a
		ld	l, e
		push	hl
		xor	a
		call	fastLine
		pop	de
		pop	hl
		xor	a
		call	fastLine
		pop	hl
		pop	de
		pop	bc
		ret
; End of function doBox


; =============== S U B	R O U T	I N E =======================================


drawBar:				; CODE XREF: RAM:9FAEp	RAM:A024p
		ld	b, 5

drawBarLp:				; CODE XREF: drawBar+Ej
		push	bc
		push	hl
		push	de
		xor	a
		call	fastLine
		pop	de
		pop	hl
		inc	e
		inc	l
		pop	bc
		djnz	drawBarLp
		ret
; End of function drawBar


; =============== S U B	R O U T	I N E =======================================


isHaulUnlocked:				; CODE XREF: RAM:9F40p
					; RAM:pickKeyLoopp ...
		ld	b, 4
		ld	de, 3
		ld	hl, appVarShad+2

haulUnlockLp:				; CODE XREF: isHaulUnlocked+Dj
		ld	a, (hl)
		inc	hl
		or	(hl)
		ret	z
		add	hl, de
		djnz	haulUnlockLp
		ret
; End of function isHaulUnlocked


; =============== S U B	R O U T	I N E =======================================


blackScreen:				; CODE XREF: RAM:9E90p	RAM:statsLoopp	...
		ld	hl, plotSScreen
		ld	de, plotSScreen+1
		ld	bc, 2FFh
		ld	(hl), 0FFh
		ldir
		ret
; End of function blackScreen


; =============== S U B	R O U T	I N E =======================================


doPhysics:				; CODE XREF: RAM:A2CEp
		ld	a, (itemTill)
		dec	a
		ld	(itemTill),	a
		jr	nz, notAddingItem
		ld	hl, (itemPtr)

itemParseLp:				; CODE XREF: doPhysics+24j
					; doPhysics+4Bj
		ld	a, (hl)
		and	0C0h ; 'À'
		jr	z, doneForFrame2
		sub	40h ; '@'
		jr	nz, mustBeSprite
		ld	a, (hl)
		and	3Fh ; '?'
		dec	a
		jr	nz, notItemDark
		ld	a, (itemDark)
		xor	1
		ld	(itemDark), a

notItemDark:				; CODE XREF: doPhysics+19j
		inc	hl
		jr	itemParseLp
; ---------------------------------------------------------------------------

mustBeSprite:				; CODE XREF: doPhysics+13j
		rlca
		and	1
		ld	b, a
		ld	de, itemBuf-3

findItemOpenLp:				; CODE XREF: doPhysics+32j
		inc	de
		inc	de
		inc	de
		ld	a, (de)
		or	a
		jr	nz, findItemOpenLp
		ld	a, 6
		ld	(de), a
		inc	de
		ld	a, b
		ld	(de), a
		inc	de
		ld	a, (hl)
		and	1Fh
		add	a, a
		ld	c, a
		add	a, a
		add	a, c
		ld	(de), a
		ld	a, (items)
		inc	a
		ld	(items), a
		inc	hl
		jr	itemParseLp
; ---------------------------------------------------------------------------

doneForFrame2:				; CODE XREF: doPhysics+Fj
		ld	a, (hl)
		ld	(itemTill),	a
		inc	hl
		ld	(itemPtr), hl

notAddingItem:				; CODE XREF: doPhysics+7j
		ld	a, (winCount)
		or	a
		jr	nz, jumpin
		ld	a, 0BFh	; '¿'
		call	keyScan
		bit	5, b
		jr	z, jumpin
		ld	a, 0FEh	; 'þ'
		call	keyScan
		bit	3, b
		jr	nz, notJumpin

jumpin:					; CODE XREF: doPhysics+59j
					; doPhysics+62j
		ld	hl, (yVel)
		ld	a, h
		or	l
		jr	nz, notJumpin
		ld	hl, 401h
		ld	(yVel),	hl
		ld	hl, squareY
		inc	(hl)

notJumpin:				; CODE XREF: doPhysics+6Bj
					; doPhysics+72j
		ld	hl, (yVel)
		ld	de, 0FF6Fh
		add	hl, de
		ld	(yVel),	hl
		ld	de, (squareY)
		add	hl, de
		ld	(squareY), hl
		ld	hl, jumpCount
		inc	(hl)
		ld	a, (squareY+1)
		cp	0E6h ; 'æ'
		jr	c, notOnGround
		ld	hl, 0
		ld	(yVel),	hl
		ld	(squareY), hl
		xor	a
		ld	(jumpCount), a

notOnGround:				; CODE XREF: doPhysics+99j
		ld	hl, (squareY)
		ld	a, h
		or	l
		jr	nz, notOnGround2
		ld	a, (itemDark)
		or	a
		call	nz, death

notOnGround2:				; CODE XREF: doPhysics+ADj
		ld	a, (items)
		or	a
		jp	z, noItems
		ld	b, a
		ld	a, (squareY+1)
		ld	c, a
		ld	hl, itemBuf

checkBlocksLp:				; CODE XREF: doPhysics+CCj
					; doPhysics+D5j
		ld	a, (hl)
		or	a
		jr	nz, itemFound
		inc	hl
		inc	hl
		inc	hl
		jr	checkBlocksLp
; ---------------------------------------------------------------------------

itemFound:				; CODE XREF: doPhysics+C7j
		inc	hl
		ld	a, (hl)
		or	a
		jr	nz, notATri
		inc	hl

inTheClear:				; CODE XREF: doPhysics+E3j
		inc	hl
		djnz	checkBlocksLp
		jr	blockLpDone
; ---------------------------------------------------------------------------

notATri:				; CODE XREF: doPhysics+D1j
		inc	hl
		ld	a, (hl)
		sub	c
		jp	p, notNeg
		neg

notNeg:					; CODE XREF: doPhysics+DCj
		cp	6
		jr	nc, inTheClear
		ld	a, (hl)
		sub	c
		jp	p, touching
		neg
		cp	3
		jr	c, touching

blockLand:				; CODE XREF: doPhysics+116j
		ld	a, (yVel+1)
		cp	2
		jr	z, negativeSpeed
		cp	14h
		call	c, death

negativeSpeed:				; CODE XREF: doPhysics+F5j
		ld	a, (hl)
		add	a, 6
		ld	(squareY+1), a
		xor	a
		ld	(squareY), a
		ld	(jumpCount), a
		ld	hl, 0
		ld	(yVel),	hl
		jr	blockLpDone
; ---------------------------------------------------------------------------

touching:				; CODE XREF: doPhysics+E7j
					; doPhysics+EEj
		ld	a, (yVel+1)
		cp	3
		jr	nc, blockLand
		call	death

blockLpDone:				; CODE XREF: doPhysics+D7j
					; doPhysics+10Fj
		ld	a, (items)
		ld	b, a
		ld	a, (squareY+1)
		ld	c, a
		ld	hl, itemBuf

findItemLp2:				; CODE XREF: doPhysics+12Dj
					; doPhysics+13Aj ...
		ld	a, (hl)
		or	a
		jr	nz, itemFound2
		inc	hl
		inc	hl
		inc	hl
		jr	findItemLp2
; ---------------------------------------------------------------------------

itemFound2:				; CODE XREF: doPhysics+128j
		cp	6
		jr	nc, safeDistance
		cp	3
		jr	nc, hitDistance

safeDistance:				; CODE XREF: doPhysics+131j
		inc	hl

itsABlock:				; CODE XREF: doPhysics+141j
		inc	hl
		inc	hl
		djnz	findItemLp2
		jr	triLpDone
; ---------------------------------------------------------------------------

hitDistance:				; CODE XREF: doPhysics+135j
		inc	hl
		ld	a, (hl)
		or	a
		jr	nz, itsABlock
		inc	hl
		ld	a, (hl)
		sub	c
		jp	p, notNeg2
		neg

notNeg2:				; CODE XREF: doPhysics+146j
		cp	6
		call	c, death
		djnz	findItemLp2

triLpDone:				; CODE XREF: doPhysics+13Cj
		ld	a, (items)
		ld	b, a
		ld	hl, itemBuf

increaseItemsLp:			; CODE XREF: doPhysics+160j
		ld	a, (hl)
		or	a
		jr	nz, foundItem3

nextItem:				; CODE XREF: doPhysics:notGonej
		inc	hl
		inc	hl
		inc	hl
		jr	increaseItemsLp
; ---------------------------------------------------------------------------

foundItem3:				; CODE XREF: doPhysics+15Bj
		dec	(hl)
		jr	nz, notGone
		ld	a, (items)
		dec	a
		ld	(items), a

notGone:				; CODE XREF: doPhysics+163j
		djnz	nextItem

noItems:				; CODE XREF: doPhysics+BAj
		ld	a, (scrolled)
		ld	b, a
		ld	a, (squareY+1)
		sub	b
		ld	hl, scrolled
		jp	p, notTooHigh
		add	a, (hl)
		ld	(hl), a
		jr	notTooLow
; ---------------------------------------------------------------------------

notTooHigh:				; CODE XREF: doPhysics+179j
		cp	1Dh
		jr	c, notTooLow
		sub	1Dh
		add	a, (hl)
		ld	(hl), a

notTooLow:				; CODE XREF: doPhysics+17Ej
					; doPhysics+182j
		ret
; End of function doPhysics


; =============== S U B	R O U T	I N E =======================================


nextSprite:				; CODE XREF: RAM:A2CBp	nextSprite+7Dj
		ld	a, (spriteDark)
		or	a
		jr	z, notDark
		ld	a, (darkCount)
		dec	a
		ld	(darkCount), a
		jr	nz, notDark
		ld	a, 3
		ld	(darkCount), a
		ld	de, 379h
		call	newSprite

notDark:				; CODE XREF: nextSprite+4j
					; nextSprite+Dj
		ld	a, (spriteTill)
		dec	a
		ld	(spriteTill), a
		ret	nz
		ld	hl, (spritePtr)

spriteParseLp:				; CODE XREF: nextSprite+5Cj
					; nextSprite+64j ...
		ld	a, (hl)
		and	0C0h ; 'À'
		jp	z, doneForFrame
		sub	40h ; '@'
		jp	nz, itsASprite
		ld	a, (hl)
		and	3Fh ; '?'
		jr	nz, notWin
		ld	a, (winsNeeded)
		or	a
		jr	z, youWin
		dec	a
		ld	(winsNeeded), a
		ex	de, hl
		sub	2
		neg
		add	a, a
		add	a, a
		ld	hl, appVarShad+2
		add	a, l
		ld	l, a
		jr	nc, notCarry6
		inc	h

notCarry6:				; CODE XREF: nextSprite+4Bj
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
		inc	bc
		ld	(hl), b
		dec	hl
		ld	(hl), c
		ex	de, hl
		ld	a, 1
		ld	(appVarDirty), a
		inc	hl
		jr	spriteParseLp
; ---------------------------------------------------------------------------

youWin:					; CODE XREF: nextSprite+39j
		ld	a, 7Dh ; '}'
		ld	(winCount), a
		inc	hl
		jr	spriteParseLp
; ---------------------------------------------------------------------------

notWin:					; CODE XREF: nextSprite+33j
		dec	a
		jr	nz, notToggleDark
		ld	a, 1
		ld	(darkCount), a
		ld	(spriteTill), a
		ld	a, (spriteDark)
		xor	1
		ld	(spriteDark), a
		inc	hl
		ld	(spritePtr), hl
		jr	nextSprite
; ---------------------------------------------------------------------------

notToggleDark:				; CODE XREF: nextSprite+67j
		dec	a
		jr	nz, notFlipping
		ld	a, (flipped)
		xor	1
		ld	(flipped), a
		jr	effectCommon
; ---------------------------------------------------------------------------

notFlipping:				; CODE XREF: nextSprite+80j
		dec	a
		jr	nz, notInverting
		ld	a, (invert)
		xor	1
		ld	(invert), a
		ld	a, (contrastSave)
		ld	(tempContrast),	a
		jr	z, turningLight
		sub	3
		ld	(tempContrast),	a

turningLight:				; CODE XREF: nextSprite+9Dj
		add	a, 0D8h	; 'Ø'
		out	(10h), a
		jr	effectCommon
; ---------------------------------------------------------------------------

notInverting:				; CODE XREF: nextSprite+8Dj
		dec	a
		jr	nz, notRising
		ld	a, (effectFlags)
		xor	1
		ld	(effectFlags), a
		jr	effectCommon
; ---------------------------------------------------------------------------

notRising:				; CODE XREF: nextSprite+ABj
		ld	a, (effectFlags)
		xor	2
		ld	(effectFlags), a
		jr	effectCommon
; ---------------------------------------------------------------------------

itsASprite:				; CODE XREF: nextSprite+2Dj
		ld	a, (hl)
		and	0E0h ; 'à'
		sub	40h ; '@'
		rlca
		bit	6, a
		jr	z, aSpike
		ld	a, 4
		jr	itsBlock
; ---------------------------------------------------------------------------

aSpike:					; CODE XREF: nextSprite+C9j
		and	1
		jr	nz, itsBlock
		ld	a, 2

itsBlock:				; CODE XREF: nextSprite+CDj
					; nextSprite+D1j
		ld	d, a
		ld	a, (hl)
		and	1Fh
		rlca
		ld	c, a
		rlca
		add	a, c
		add	a, 80h ; ''
		ld	e, a
		call	newSprite

effectCommon:				; CODE XREF: nextSprite+8Aj
					; nextSprite+A8j ...
		inc	hl
		jp	spriteParseLp
; ---------------------------------------------------------------------------

doneForFrame:				; CODE XREF: nextSprite+28j
		ld	a, (hl)
		ld	(spriteTill), a
		inc	hl
		ld	(spritePtr), hl
		ret
; End of function nextSprite


; =============== S U B	R O U T	I N E =======================================


newSprite:				; CODE XREF: nextSprite+17p
					; nextSprite+E0p
		push	hl
		ld	hl, spriteBuf

findOpeningLp:				; CODE XREF: newSprite+Bj
		ld	a, (hl)
		or	a
		jr	z, openingFound
		inc	hl
		inc	hl
		inc	hl
		jr	findOpeningLp
; ---------------------------------------------------------------------------

openingFound:				; CODE XREF: newSprite+6j
		ld	a, (effectFlags)
		and	2
		jr	z, notRisingz
		ld	a, e
		add	a, 0C4h	; 'Ä'
		ld	e, a

notRisingz:				; CODE XREF: newSprite+12j
		ld	(hl), d
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), 0DEh ; 'Þ'
		ld	hl, sprites
		inc	(hl)
		pop	hl
		ret
; End of function newSprite


; =============== S U B	R O U T	I N E =======================================


textAScreen:				; CODE XREF: RAM:9E98p	RAM:9F4Bp ...
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		call	vPutSDE
		djnz	textAScreen
		ret
; End of function textAScreen

; ---------------------------------------------------------------------------

vPutSDE:				; CODE XREF: RAM:9F24p	RAM:9FC4p ...
		ld	(penCol), de
		rst	28h
; ---------------------------------------------------------------------------
		dw 4561h		; vPutS
; ---------------------------------------------------------------------------
		ret

; =============== S U B	R O U T	I N E =======================================


keyScan:				; CODE XREF: RAM:A32Ap	RAM:A346p ...
		out	(1), a
		nop
		nop
		nop
		nop
		in	a, (1)
		ld	b, a
		ld	a, 0FFh
		out	(1), a
		ret
; End of function keyScan


; =============== S U B	R O U T	I N E =======================================


dispSprites:				; CODE XREF: RAM:A2D7p
		ld	a, (sprites)
		or	a
		ret	z
		ld	hl, spriteBuf
		ld	b, a

dispSpritesLp:				; CODE XREF: dispSprites+A1j
		push	bc
		ld	bc, 3

findSpriteLp:				; CODE XREF: dispSprites+12j
		ld	a, (hl)
		or	a
		jr	nz, spriteFound
		add	hl, bc
		jr	findSpriteLp
; ---------------------------------------------------------------------------

spriteFound:				; CODE XREF: dispSprites+Fj
		inc	hl
		ld	c, a
		ld	b, 3
		and	2
		jr	nz, notBlock
		ld	b, 6

notBlock:				; CODE XREF: dispSprites+1Aj
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ld	a, d
		sub	2
		ld	d, a
		ld	(hl), d
		cp	7Ch ; '|'
		jr	nz, spriteNotGone
		dec	hl
		dec	hl
		ld	(hl), 0
		inc	hl
		inc	hl
		push	hl
		ld	hl, sprites
		dec	(hl)
		jr	spriteContinue
; ---------------------------------------------------------------------------

spriteNotGone:				; CODE XREF: dispSprites+28j
		ld	a, (effectFlags)
		or	a
		jr	z, noEffects
		rrca
		jr	nc, notFalling
		push	af
		ld	a, d
		cp	8Eh ; ''
		jr	nc, notInBound
		ld	a, e
		sub	2
		ld	e, a

notInBound:				; CODE XREF: dispSprites+44j
		pop	af

notFalling:				; CODE XREF: dispSprites+3Ej
		rrca
		jr	nc, notRising2
		ld	a, d
		cp	0C0h ; 'À'
		jr	c, notRising2
		cp	0D4h ; 'Ô'
		jr	nc, notRising2
		ld	a, e
		add	a, 6
		ld	e, a

notRising2:				; CODE XREF: dispSprites+4Cj
					; dispSprites+51j ...
		dec	hl
		ld	(hl), e
		inc	hl

noEffects:				; CODE XREF: dispSprites+3Bj
		push	hl
		ld	a, (scrolled)
		sub	e
		neg
		ld	e, a
		cp	68h ; 'h'
		jr	c, spriteContinue
		cp	0ADh ; '­'
		jr	nc, spriteContinue
		ld	a, d
		ld	d, 0
		ld	h, d
		ld	l, e
		add	hl, hl
		add	hl, hl
		add	hl, hl
		sbc	hl, de
		add	hl, hl
		ld	e, a
		srl	e
		srl	e
		srl	e
		add	hl, de
		and	6
		rrca
		ld	e, a
		ld	a, c
		and	1
		bit	2, c
		jr	z, notXSpike
		ld	a, 2

notXSpike:				; CODE XREF: dispSprites+8Aj
		rlca
		rlca
		or	e
		ld	de, 7A86h
		add	hl, de
		ex	de, hl
		rlca
		rlca
		inc	a
		ld	l, a
		ld	h, 8Eh ; ''
		jp	(hl)
; ---------------------------------------------------------------------------

spriteContinue:				; CODE XREF: dispSprites+35j
					; dispSprites+68j ...
		pop	hl
		inc	hl
		pop	bc
		dec	b
		jp	nz, dispSpritesLp
		ret
; End of function dispSprites


; =============== S U B	R O U T	I N E =======================================


dispSquare:				; CODE XREF: RAM:A2D4p
		ld	a, (scrolled)
		ld	l, a
		ld	a, (squareY+1)
		sub	l
		ld	l, a
		ld	h, 0
		ld	e, l
		ld	d, h
		add	hl, hl
		add	hl, hl
		add	hl, hl
		sbc	hl, de
		add	hl, hl
		ld	de, screenBuf+423
		add	hl, de
		ex	de, hl
		ld	a, (jumpCount)

mod6:					; CODE XREF: dispSquare+1Dj
		sub	6
		jr	nc, mod6
		add	a, 6
		rlca
		rlca
		rlca
		ld	hl, squarePics
		add	a, l
		ld	l, a
		jr	nc, notCarry7
		inc	h

notCarry7:				; CODE XREF: dispSquare+29j
		ld	b, 7

copySquare:				; CODE XREF: dispSquare+38j
		push	bc
		ldi
		ld	bc, 0FFF1h
		ex	de, hl
		add	hl, bc
		ex	de, hl
		pop	bc
		djnz	copySquare
		ret
; End of function dispSquare


; =============== S U B	R O U T	I N E =======================================


dispAttempts:				; CODE XREF: RAM:A2D1p
		ld	a, (flipped)
		or	a
		jr	z, notFlipped
		ld	hl, attemptPic
		ld	de, screenBuf+87
		ld	b, 5

flippedCopy:				; CODE XREF: dispAttempts+1Cj
		push	bc
		ld	bc, 7
		ldir
		push	hl
		ld	hl, 7
		add	hl, de
		ex	de, hl
		pop	hl
		pop	bc
		djnz	flippedCopy
		ret
; ---------------------------------------------------------------------------

notFlipped:				; CODE XREF: dispAttempts+4j
		ld	hl, attemptPic
		ld	de, screenBuf+941
		ld	b, 5

regCopy:				; CODE XREF: dispAttempts+35j
		push	bc
		ld	bc, 7
		ldir
		push	hl
		ld	hl, 0FFEBh
		add	hl, de
		ex	de, hl
		pop	hl
		pop	bc
		djnz	regCopy
		ret
; End of function dispAttempts

; ---------------------------------------------------------------------------

regFastCopy:				; CODE XREF: RAM:A322p
		ld	a, (invert)
		ld	(smc_neg2), a
		or	a
		jr	z, notInv
		ld	a, 2Fh ; '/'
		ld	(smc_neg2), a

notInv:					; CODE XREF: RAM:A8F7j
		ld	hl, screenBuf+952
		ld	c, 20h ; ' '

dwait2:					; CODE XREF: RAM:A907j	RAM:A932j
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait2
		ld	a, c
		cp	2Ch ; ','
		ret	z
		out	(10h), a

dwait3:					; CODE XREF: RAM:A913j
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait3
		ld	a, 80h ; ''
		out	(10h), a
		ld	de, 0FFF2h
		ld	b, 40h ; '@'

dwait4:					; CODE XREF: RAM:A922j	RAM:A92Bj
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait4
		ld	a, (hl)
; ---------------------------------------------------------------------------
smc_neg2:	db 0			; DATA XREF: RAM:A8F3w	RAM:A8FBw
; ---------------------------------------------------------------------------
		out	(11h), a
		ld	(hl), 0
		add	hl, de
		djnz	dwait4
		ld	de, 381h
		add	hl, de
		inc	c
		jr	dwait2
; ---------------------------------------------------------------------------

invFastCopy:				; CODE XREF: RAM:A325p
		ld	a, (invert)
		ld	(smc_neg1), a
		or	a
		jr	z, notInv2
		ld	a, 2Fh ; '/'
		ld	(smc_neg1), a

notInv2:				; CODE XREF: RAM:A93Bj
		ld	hl, screenBuf+70
		ld	c, 20h ; ' '

dwait5:					; CODE XREF: RAM:A94Bj	RAM:A976j
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait5
		ld	a, c
		cp	2Ch ; ','
		ret	z
		out	(10h), a

dwait6:					; CODE XREF: RAM:A957j
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait6
		ld	a, 80h ; ''
		out	(10h), a
		ld	de, 0Eh
		ld	b, 40h ; '@'

dwait7:					; CODE XREF: RAM:A966j	RAM:A96Fj
		in	a, (10h)
		and	90h ; ''
		jr	nz, dwait7
		ld	a, (hl)
; ---------------------------------------------------------------------------
smc_neg1:	db 0			; DATA XREF: RAM:A937w	RAM:A93Fw
; ---------------------------------------------------------------------------
		out	(11h), a
		ld	(hl), 0
		add	hl, de
		djnz	dwait7
		ld	de, 0FC81h
		add	hl, de
		inc	c
		jr	dwait5

; =============== S U B	R O U T	I N E =======================================


interrupt:				; CODE XREF: RAM:A232p
					; DATA XREF: RAM:A226o
		ex	af, af'
		in	a, (4)
		and	2
		jr	z, wrongInterrupt
		ld	a, (intCount)
		inc	a
		ld	(intCount), a

wrongInterrupt:				; CODE XREF: interrupt+5j
		xor	a
		out	(3), a
		ld	a, 0Ah
		out	(3), a
		ex	af, af'
		ei
		ret
; End of function interrupt


; =============== S U B	R O U T	I N E =======================================


makeCMDs:				; CODE XREF: RAM:A284p
		ld	hl, commandsBuf
		ld	de, commandTable
		ld	bc, 400h

makeCMDLp:				; CODE XREF: makeCMDs+26j
		push	bc
		ld	ix, spikePic
		call	makeCMD1
		push	de
		ld	b, 6

makeCMDLp2:				; CODE XREF: makeCMDs+1Ej
		push	bc
		ld	a, (ix+0)
		inc	ix
		call	makeCMD2
		pop	bc
		djnz	makeCMDLp2
		call	djnzRetStyle
		pop	de
		pop	bc
		inc	c
		djnz	makeCMDLp
		ld	bc, 400h

makeBlockLp:				; CODE XREF: makeCMDs+46j
		push	bc
		call	makeCMD1
		push	de
		ld	a, 0FCh	; 'ü'
		call	makeCMD2
		ld	(hl), 10h
		inc	hl
		ld	(hl), 0F8h ; 'ø'
		or	a
		jr	z, noSecondByte
		ld	(hl), 0F4h ; 'ô'

noSecondByte:				; CODE XREF: makeCMDs+3Bj
		inc	hl
		call	djnzRetStyle
		pop	de
		pop	bc
		inc	c
		djnz	makeBlockLp
		ld	bc, 400h

spikeXLp:				; CODE XREF: makeCMDs+68j
		push	bc
		ld	ix, spikeXPic
		call	makeCMD1
		push	de
		ld	b, 6

spikeXLp2:				; CODE XREF: makeCMDs+60j
		push	bc
		ld	a, (ix+0)
		inc	ix
		call	makeCMD2
		pop	bc
		djnz	spikeXLp2
		call	djnzRetStyle
		pop	de
		pop	bc
		inc	c
		djnz	spikeXLp
		ret
; End of function makeCMDs


; =============== S U B	R O U T	I N E =======================================


djnzRetStyle:				; CODE XREF: makeCMDs+20p makeCMDs+40p ...
		ld	(hl), 0C3h ; 'Ã'
		inc	hl
		ld	(hl), 75h ; 'u'
		inc	hl
		ld	(hl), 0A8h ; '¨'
		inc	hl
		ret
; End of function djnzRetStyle


; =============== S U B	R O U T	I N E =======================================


makeCMD1:				; CODE XREF: makeCMDs+Ep makeCMDs+2Cp	...
		ex	de, hl
		ld	(hl), 0C3h ; 'Ã'
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), d
		inc	hl
		inc	hl
		ex	de, hl
		ld	(hl), 0EBh ; 'ë'
		inc	hl
		ld	(hl), 11h
		inc	hl
		ld	(hl), 0F1h ; 'ñ'
		inc	hl
		ld	(hl), 0FFh
		inc	hl
		ret
; End of function makeCMD1


; =============== S U B	R O U T	I N E =======================================


makeCMD2:				; CODE XREF: makeCMDs+1Ap makeCMDs+32p ...
		ld	b, c
		ld	c, 0
		sla	b
		jr	z, preAligned

alignLoop:				; CODE XREF: makeCMD2+Aj
		rra
		rr	c
		djnz	alignLoop

preAligned:				; CODE XREF: makeCMD2+5j
		ld	(hl), 3Eh ; '>'
		inc	hl
		ld	(hl), a
		ld	a, c
		inc	hl
		ld	de, forCopyData
		ex	de, hl
		ldi
		ldi
		ldi
		or	a
		jr	nz, is2Byte
		ld	hl, lastForCopy
		jr	is1Byte
; ---------------------------------------------------------------------------

is2Byte:				; CODE XREF: makeCMD2+1Dj
		ex	de, hl
		ld	(hl), 3Eh ; '>'
		inc	hl
		ld	(hl), a
		inc	hl
		ex	de, hl
		ld	hl, midForCopy
		ldi
		ldi

is1Byte:				; CODE XREF: makeCMD2+22j
		ldi
		ex	de, hl
		ret
; End of function makeCMD2

; ---------------------------------------------------------------------------

forCopyData:				; DATA XREF: makeCMD2+12o
		or	(hl)
		ld	(hl), a
		inc	hl

midForCopy:				; DATA XREF: makeCMD2+2Bo
		or	(hl)
		ld	(hl), a

lastForCopy:				; DATA XREF: makeCMD2+1Fo
		add	hl, de

; =============== S U B	R O U T	I N E =======================================


waitLoop:				; CODE XREF: RAM:A377p	waitLoop+Aj
		in	a, (31h)
		bit	2, a
		jr	nz, waitDone
		in	a, (4)
		bit	5, a
		jr	z, waitLoop
; End of function waitLoop


; =============== S U B	R O U T	I N E =======================================


waitDone:				; CODE XREF: RAM:A2C1p	waitLoop+4j
		ld	a, 45h ; 'E'
		out	(30h), a
		xor	a
		out	(31h), a
		ld	a, 3Ah ; ':'
		out	(32h), a
		ret
; End of function waitDone

; ---------------------------------------------------------------------------

convHex:				; CODE XREF: RAM:9FB5p	RAM:9FD8p ...
		push	de
		inc	de
		inc	de
		inc	de
		inc	de
		push	de
		ld	b, 1

convHexLp:				; CODE XREF: RAM:AA8Dj
		push	de
		or	a
		ld	de, 0Ah
		sbc	hl, de
		add	hl, de
		jr	c, doneCoverting
		pop	de
		inc	b
		ld	a, 0Ah
		rst	28h
; ---------------------------------------------------------------------------
		dw 4012h
; ---------------------------------------------------------------------------
		add	a, 30h ; '0'
		ld	(de), a
		dec	de
		jr	convHexLp
; ---------------------------------------------------------------------------

doneCoverting:				; CODE XREF: RAM:AA80j
		pop	de
		ld	a, 30h ; '0'
		add	a, l
		ld	(de), a
		pop	hl
		pop	de
		inc	hl
		push	bc

subHLbyB:				; CODE XREF: RAM:AA99j
		dec	hl
		djnz	subHLbyB
		pop	bc
		push	bc
		ld	c, b
		ld	b, 0
		ldir
		pop	bc
		xor	a
		ld	(de), a
		ret

; =============== S U B	R O U T	I N E =======================================


negHL:					; CODE XREF: RAM:A2EDp
		push	de
		ld	de, 0
		ex	de, hl
		or	a
		sbc	hl, de
		pop	de
		ret
; End of function negHL


; =============== S U B	R O U T	I N E =======================================


fast_bhl:				; CODE XREF: RAM:AABEp	RAM:AAC7p
		ld	a, h
		res	7, h
		set	6, h
		cp	h
		ret	z
		inc	b
		ret
; End of function fast_bhl

; ---------------------------------------------------------------------------

findStartInRom:				; CODE XREF: RAM:9E42p
		ex	de, hl
		ld	de, 9
		add	hl, de
		call	fast_bhl
		rst	28h
; ---------------------------------------------------------------------------
		dw 501Dh		; loadCIndPaged
; ---------------------------------------------------------------------------
		inc	c
		ld	e, c
		add	hl, de
		call	fast_bhl
		ret
; ---------------------------------------------------------------------------
ioSaveData:	db  39h	; 9		; DATA XREF: ioSaveLoad+1Do
		db  84h	; 
		db  3Fh	; ?
		db    0
		db 0BFh	; ¿
		db  84h	; 
		db  49h	; I
		db    0
		db  88h	; 
		db  85h	; 
		db  64h	; d
		db    1
		db 0ECh	; ì
		db  89h	; 
		db  4Eh	; N
		db    0
		db  4Dh	; M
		db  8Ch	; 
		db 0B3h	; ³
		db    2

; =============== S U B	R O U T	I N E =======================================


ioSaveLoad:				; CODE XREF: RAM:A200p	RAM:A331p ...
		di
		im	1
		xor	a
		ld	(flags), a
		inc	a
		ld	($95E0), a
		ld	a, (iy+0)
		or	a
		ld	iy, 95E0h
		jr	z, firstTime
		ld	iy, flags

firstTime:				; CODE XREF: ioSaveLoad+13j
		ld	(iy+0),	a
		push	af
		ld	ix, ioSaveData
		ld	hl, 9943h
		ld	a, 4
		call	ioSaveRoutine
		pop	af
		ld	(iy+0),	a
		ld	hl, 938Ch
		ld	a, 1
; End of function ioSaveLoad


; =============== S U B	R O U T	I N E =======================================


ioSaveRoutine:				; CODE XREF: ioSaveLoad+26p
					; ioSaveRoutine+20j
		ld	e, (ix+0)
		ld	d, (ix+1)
		ld	bc, 4
		add	ix, bc
		ld	c, (ix-2)
		ld	b, (ix-1)
		bit	0, (iy+0)
		jr	nz, notSwitched
		ex	de, hl
		ldir
		ex	de, hl
		jr	switched
; ---------------------------------------------------------------------------

notSwitched:				; CODE XREF: ioSaveRoutine+15j
		ldir

switched:				; CODE XREF: ioSaveRoutine+1Bj
		dec	a
		jr	nz, ioSaveRoutine
		ret
; End of function ioSaveRoutine

; ---------------------------------------------------------------------------
progName:	db    6			; DATA XREF: RAM:notDirtyo
		db  49h	; I
		db  4Dh	; M
		db  50h	; P
		db  4Fh	; O
		db  53h	; S
		db  42h	; B
		db  4Ch	; L
		db  45h	; E
aAttempt:	db  41h	; A		; DATA XREF: RAM:A203o
		db  74h	; t
		db  74h	; t
		db  65h	; e
		db  6Dh	; m
		db  70h	; p
		db  74h	; t
		db  20h
		db  20h
aTimesCompleted:.db "Times  completed:  ",0 ; DATA XREF: RAM:9FC7o
					; RAM:A03Do
screen1:	db  0Ch			; DATA XREF: RAM:9F2Bo	RAM:A0E3o
		db    9
aLevel1:	.db "Level  1",0
		db    8
		db  10h
aFireAura:	.db "Fire  Aura",0
		db  38h	; 8
		db    9
aXboxLive:	.db "Xbox  Live",0
		db  35h	; 5
		db  10h
aIndieLevel:	.db "Indie  Level",0
screen2:	db  0Ch			; DATA XREF: RAM:9F31o
		db  26h	; &
aLevel2:	.db "Level  2",0
		db  0Eh
		db  2Dh	; -
aChaoz:		.db "Chaoz",0
		db  0Bh
		db  34h	; 4
aFantasy:	.db "Fantasy",0
		db  3Ch	; <
		db  29h	; )
aLevel3:	.db "Level  3",0
		db  3Ch	; <
		db  30h	; 0
aHeaven:	.db "Heaven",0
haulText:	db  1Eh			; DATA XREF: RAM:haulSelectedo
		db    3
aSixMinutes:	.db "six  minutes",0
		db  12h
		db  0Bh
aWithoutAMistak:.db "without  a  mistake",0
screen3:	db  20h			; DATA XREF: RAM:9F37o
		db  1Ch
aLongHaul:	.db "Long  Haul",0
		db  16h
		db  2Dh	; -
aCanYouSurvive:	.db "Can  you  survive",0
		db  17h
		db  35h	; 5
aTheLongHaul?:	.db "the  Long  Haul?",0
haulNotText:	db  0Fh			; DATA XREF: RAM:9F46o
		db  0Fh
aBeatAllFourLev:.db "Beat  all  four  levels",0
		db  20h
		db  17h
aToUnlock:	.db "to  unlock",0
titleText:	db  0Dh			; DATA XREF: RAM:9E93o
		db    2
aTheImpossibl_0:.db "The  Impossible  Game",0
		db  1Dh
		db  17h
aStartGame:	.db "Start  Game",0
		db  28h	; (
		db  1Fh
aStats:		.db "Stats",0        ; DATA XREF: RAM:9F1Eo
		db  2Ah	; *
		db  27h	; "
aQuit:		.db "Quit",0
		db    8
		db  38h	; 8
aByBrianCoventr:.db "By:  Brian  Coventry   v2.0 ",0
		.db ">>>",0
		.db "<<<",0
unlockedText:	db  14h			; DATA XREF: RAM:A40Bo
		db    7
aCongratulation:.db "Congratulations!",0
		db    8
		db  0Fh
aYouBeatAllFour:.db "You  beat  all  four  levels",0
		db  0Dh
		db  1Eh
aScrollOffTheSe:.db "Scroll  off  the  select",0
		db  0Fh
		db  26h	; &
aScreenForAHidd:.db "screen  for  a  hidden",0
		db  1Fh
		db  2Eh	; .
aChallenge:	.db "challenge",0
wowText:	db  28h	; (		; DATA XREF: RAM:A3A1o
		db  1Ch
aWow:		.db "wow",0
winText:	db  23h	; #		; DATA XREF: RAM:A398o
		db  13h
aYouWin:	.db "You  Win!",0
		db  26h	; &
		db  20h
aNice___:	.db "Nice...",0
appVarName:	db  15h			; DATA XREF: RAM:9E15o	RAM:9E30o ...
		db  49h	; I
		db  6Dh	; m
		db  70h	; p
		db  6Fh	; o
		db  73h	; s
		db  62h	; b
		db  6Ch	; l
		db  65h	; e
statData:	db    7			; DATA XREF: RAM:9F58o
		db  0Ah
		db    2
		db    2
		db  26h	; &
		db    2
		db    2
		db  0Ah
		db    3
		db    9
		db  26h	; &
		db    2
		db  11h
		db  0Ah
		db    1
		db    0
spikePic:	db  38h	; 8		; DATA XREF: makeCMDs+Ao
		db  38h	; 8
		db  6Ch	; l
		db  6Ch	; l
		db 0C6h	; Æ
		db 0FEh	; þ
spikeXPic:	db  30h	; 0		; DATA XREF: makeCMDs+4Co
		db  30h	; 0
		db  48h	; H
		db  48h	; H
		db  84h	; 
		db 0FCh	; ü
squarePics:	db    0			; DATA XREF: dispSquare+24o
		db  7Eh	; ~
		db  42h	; B
		db  42h	; B
		db  42h	; B
		db  42h	; B
		db  7Eh	; ~
		db    0
		db  70h	; p
		db  4Eh	; N
		db  42h	; B
		db  82h	; 
		db  84h	; 
		db 0E4h	; ä
		db  1Ch
		db    0
		db  30h	; 0
		db  4Ch	; L
		db  42h	; B
		db  82h	; 
		db  84h	; 
		db  64h	; d
		db  18h
		db    0
		db  10h
		db  28h	; (
		db  44h	; D
		db  82h	; 
		db  44h	; D
		db  28h	; (
		db  10h
		db    0
		db  18h
		db  64h	; d
		db  84h	; 
		db  82h	; 
		db  42h	; B
		db  4Ch	; L
		db  30h	; 0
		db    0
		db  1Ch
		db 0E4h	; ä
		db  84h	; 
		db  82h	; 
		db  42h	; B
		db  4Eh	; N
		db  70h	; p
		db    0
fireAura:	db  80h	; 
		db  33h	; 3
		db  80h	; 
		db    3
		db  80h	; 
		db  30h	; 0
		db 0C0h	; À
		db    3
		db  41h	; A
		db  0Ah
		db 0C0h	; À
		db  41h	; A
		db  33h	; 3
		db  80h	; 
		db    3
		db  80h	; 
		db  36h	; 6
		db  80h	; 
		db  18h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  18h
		db  80h	; 
		db  36h	; 6
		db  80h	; 
		db  30h	; 0
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    7
		db 0C1h	; Á
		db  82h	; 
		db    7
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  0Fh
		db  80h	; 
		db  24h	; $
		db  80h	; 
		db  1Eh
		db  80h	; 
		db  15h
		db  80h	; 
		db  1Bh
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db  85h	; 
		db    7
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db  86h	; 
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db  86h	; 
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    9
		db 0C4h	; Ä
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    6
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  0Ch
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db    9
		db 0CBh	; Ë
		db  0Bh
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  0Fh
		db 0CBh	; Ë
		db  0Fh
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Fh
		db 0CDh	; Í
		db    9
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db    3
		db 0CBh	; Ë
		db 0ACh	; ¬
		db    3
		db 0CBh	; Ë
		db 0ACh	; ¬
		db    3
		db 0CBh	; Ë
		db 0ACh	; ¬
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db  0Fh
		db 0CAh	; Ê
		db  0Fh
		db 0C9h	; É
		db  0Fh
		db 0C8h	; È
		db  0Fh
		db 0C7h	; Ç
		db  0Fh
		db 0C6h	; Æ
		db  0Fh
		db 0C5h	; Å
		db  0Fh
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Fh
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  0Fh
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  1Bh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  1Eh
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Eh
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Eh
		db 0C4h	; Ä
		db  0Eh
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db    9
		db 0C4h	; Ä
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    6
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db  10h
		db 0C0h	; À
		db  0Eh
		db 0C0h	; À
		db  0Ch
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db    6
		db 0C3h	; Ã
		db  84h	; 
		db    6
		db 0C4h	; Ä
		db    3
		db  41h	; A
		db    9
		db  80h	; 
		db  12h
		db  80h	; 
		db  18h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  0Ch
		db 0D3h	; Ó
		db  0Ch
		db 0D4h	; Ô
		db  0Ch
		db 0D5h	; Õ
		db  0Ch
		db 0D6h	; Ö
		db  0Ch
		db 0D7h	; ×
		db  0Bh
		db 0D8h	; Ø
		db  99h	; 
		db    9
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db  12h
		db  41h	; A
		db    9
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  21h	; !
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ch
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  15h
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  1Bh
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    9
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  15h
		db  80h	; 
		db  1Eh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  11h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db 0C0h	; À
		db  81h	; 
		db  0Ch
		db 0C4h	; Ä
		db 0C1h	; Á
		db  82h	; 
		db  0Ch
		db 0C5h	; Å
		db 0C2h	; Â
		db  83h	; 
		db  0Ch
		db 0C6h	; Æ
		db 0C3h	; Ã
		db  84h	; 
		db  0Ch
		db 0C7h	; Ç
		db 0C4h	; Ä
		db  85h	; 
		db  0Ch
		db 0C8h	; È
		db 0C5h	; Å
		db  86h	; 
		db    9
		db 0C7h	; Ç
		db 0CAh	; Ê
		db  8Bh	; 
		db    9
		db 0C6h	; Æ
		db 0CBh	; Ë
		db  8Ch	; 
		db  0Fh
		db 0C5h	; Å
		db 0C9h	; É
		db  8Ah	; 
		db  0Fh
		db 0C4h	; Ä
		db 0C8h	; È
		db  89h	; 
		db  0Eh
		db 0C4h	; Ä
		db 0C8h	; È
		db  89h	; 
		db  0Ch
		db 0C5h	; Å
		db 0C2h	; Â
		db  83h	; 
		db  0Ch
		db 0C6h	; Æ
		db 0C3h	; Ã
		db  84h	; 
		db  0Ch
		db 0C7h	; Ç
		db 0C4h	; Ä
		db  85h	; 
		db  0Ch
		db 0C8h	; È
		db 0C5h	; Å
		db  86h	; 
		db  0Ch
		db 0C9h	; É
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C9h	; É
		db  8Ah	; 
		db    3
		db 0C8h	; È
		db  89h	; 
		db    3
		db 0C7h	; Ç
		db  88h	; 
		db    3
		db 0C5h	; Å
		db  86h	; 
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    3
		db 0C0h	; À
		db  81h	; 
		db  41h	; A
		db  1Bh
		db  80h	; 
		db  12h
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  18h
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  40h	; @
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  41h	; A
		db  32h	; 2
xboxLevel:	db  80h	; 
		db  1Bh
		db  80h	; 
		db  18h
		db  80h	; 
		db    3
		db  80h	; 
		db  2Dh	; -
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  41h	; A
		db  18h
		db  80h	; 
		db    3
		db  80h	; 
		db  2Ah	; *
		db  80h	; 
		db  30h	; 0
		db  80h	; 
		db  18h
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  18h
		db  80h	; 
		db  33h	; 3
		db  80h	; 
		db  1Eh
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  15h
		db 0A0h	;  
		db    3
		db 0C0h	; À
		db    4
		db 0A0h	;  
		db  12h
		db  80h	; 
		db  36h	; 6
		db 0C0h	; À
		db  0Ch
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  1Bh
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Fh
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    6
		db 0C0h	; À
		db  0Eh
		db 0C0h	; À
		db  0Ch
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db    9
		db 0C4h	; Ä
		db    3
		db 0C6h	; Æ
		db    6
		db 0C3h	; Ã
		db    6
		db 0C7h	; Ç
		db    3
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db 0C8h	; È
		db    9
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db 0C9h	; É
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  0Ch
		db 0D3h	; Ó
		db  0Ch
		db 0D4h	; Ô
		db  0Ch
		db 0D5h	; Õ
		db  10h
		db 0D4h	; Ô
		db    3
		db 0D4h	; Ô
		db  95h	; 
		db    3
		db 0D4h	; Ô
		db  95h	; 
		db    9
		db 0D3h	; Ó
		db  0Fh
		db 0D2h	; Ò
		db  0Fh
		db 0D1h	; Ñ
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db  0Ch
		db 0D0h	; Ð
		db  0Fh
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db  90h	; 
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db  90h	; 
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db    3
		db 0CFh	; Ï
		db  90h	; 
		db    9
		db 0CEh	; Î
		db  0Fh
		db 0CDh	; Í
		db  0Fh
		db 0CCh	; Ì
		db  0Fh
		db 0CBh	; Ë
		db  0Fh
		db 0CAh	; Ê
		db  0Fh
		db 0C9h	; É
		db  0Fh
		db 0C8h	; È
		db  0Fh
		db 0C7h	; Ç
		db  0Fh
		db 0C6h	; Æ
		db  0Fh
		db 0C5h	; Å
		db  0Fh
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Fh
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  12h
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  1Bh
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  12h
		db 0C1h	; Á
		db    9
		db  41h	; A
		db  0Ch
		db  80h	; 
		db  12h
		db  80h	; 
		db  12h
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  12h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  18h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db    9
		db 0C8h	; È
		db  0Eh
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  12h
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db    9
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db    9
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  0Fh
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  0Ch
		db 0D3h	; Ó
		db  0Ch
		db 0D4h	; Ô
		db  18h
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    9
		db  41h	; A
		db  1Bh
		db  80h	; 
		db    3
		db  80h	; 
		db  18h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  1Bh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ch
		db  80h	; 
		db  0Ch
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db 0C0h	; À
		db    3
		db  41h	; A
		db  0Ch
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  0Ch
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  1Eh
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  24h	; $
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  1Bh
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  15h
		db  80h	; 
		db  21h	; !
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  40h	; @
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  41h	; A
		db  32h	; 2
chaozFantasy:	db  80h	; 
		db  10h
		db  80h	; 
		db  14h
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  0Fh
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  14h
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  0Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  0Bh
		db  80h	; 
		db    3
		db  80h	; 
		db  0Eh
		db  80h	; 
		db  0Fh
		db  80h	; 
		db  14h
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  0Fh
		db  80h	; 
		db  10h
		db  80h	; 
		db  14h
		db  80h	; 
		db    3
		db  80h	; 
		db  19h
		db  80h	; 
		db  0Dh
		db  80h	; 
		db    4
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0C0h	; À
		db  81h	; 
		db    3
		db 0C0h	; À
		db  81h	; 
		db    8
		db 0C0h	; À
		db    5
		db 0C0h	; À
		db  81h	; 
		db    3
		db 0C0h	; À
		db  81h	; 
		db  14h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  0Eh
		db 0C0h	; À
		db  0Eh
		db 0C0h	; À
		db  0Ch
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C1h	; Á
		db 0A2h	; ¢
		db    6
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Eh
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  16h
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  12h
		db  80h	; 
		db  3Fh	; ?
		db  42h	; B
		db    6
		db  80h	; 
		db  23h	; #
		db  80h	; 
		db    3
		db  80h	; 
		db  27h	; '
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  11h
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  14h
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db  80h	; 
		db  0Eh
		db  80h	; 
		db  11h
		db  80h	; 
		db    4
		db 0C0h	; À
		db    7
		db  80h	; 
		db    7
		db 0C0h	; À
		db    4
		db  80h	; 
		db  19h
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  0Eh
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  41h	; A
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  12h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Eh
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    9
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    8
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  1Ah
		db  80h	; 
		db  12h
		db  80h	; 
		db  3Fh	; ?
		db  42h	; B
		db    9
		db  80h	; 
		db  0Ah
		db  80h	; 
		db  18h
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db  81h	; 
		db    3
		db  41h	; A
		db    6
		db 0C1h	; Á
		db  0Eh
		db 0C1h	; Á
		db    4
		db  41h	; A
		db  0Ah
		db  80h	; 
		db    5
		db 0C1h	; Á
		db  1Eh
		db  80h	; 
		db  1Ch
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  41h	; A
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  1Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  19h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  0Eh
		db 0C0h	; À
		db  41h	; A
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  18h
		db  80h	; 
		db  3Fh	; ?
		db    7
		db  42h	; B
		db  0Ch
		db  80h	; 
		db  1Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  19h
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  19h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Eh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Eh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Eh
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db  41h	; A
		db  0Dh
		db  80h	; 
		db    7
		db 0C1h	; Á
		db    9
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0C0h	; À
		db  3Fh	; ?
		db  42h	; B
		db  1Eh
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  32h	; 2
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  16h
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  20h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db  41h	; A
		db    7
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  16h
		db  80h	; 
		db    4
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Eh
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db  0Fh
		db 0C0h	; À
		db  41h	; A
		db  14h
		db  80h	; 
		db  2Bh	; +
		db  80h	; 
		db    3
		db  80h	; 
		db  22h	; "
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  40h	; @
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  41h	; A
		db  32h	; 2
heaven:		db  80h	; 
		db  15h
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  19h
		db  80h	; 
		db  20h
		db  80h	; 
		db  1Ah
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db  81h	; 
		db    3
		db 0C0h	; À
		db  81h	; 
		db  17h
		db  80h	; 
		db  16h
		db  80h	; 
		db  1Dh
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  1Ch
		db  80h	; 
		db  19h
		db  80h	; 
		db  20h
		db  80h	; 
		db  15h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C0h	; À
		db 0C1h	; Á
		db  41h	; A
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  10h
		db  80h	; 
		db  15h
		db  80h	; 
		db  1Ah
		db  80h	; 
		db  1Dh
		db  80h	; 
		db  1Dh
		db  80h	; 
		db  1Ah
		db  80h	; 
		db  21h	; !
		db  80h	; 
		db  12h
		db 0C0h	; À
		db  0Bh
		db 0C1h	; Á
		db  82h	; 
		db  0Ch
		db  80h	; 
		db  13h
		db  80h	; 
		db  13h
		db  80h	; 
		db    3
		db  80h	; 
		db  1Eh
		db  80h	; 
		db  18h
		db 0C0h	; À
		db    3
		db 0C0h	; À
		db  81h	; 
		db    3
		db 0C0h	; À
		db  81h	; 
		db    3
		db 0C0h	; À
		db  1Ch
		db  80h	; 
		db  15h
		db  80h	; 
		db    3
		db  80h	; 
		db  0Ah
		db  80h	; 
		db    3
		db  80h	; 
		db  11h
		db  80h	; 
		db  1Ch
		db  80h	; 
		db    3
		db  80h	; 
		db  32h	; 2
		db  43h	; C
		db  3Fh	; ?
		db  44h	; D
		db  19h
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  43h	; C
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db    3
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  0Fh
		db 0C5h	; Å
		db  0Dh
		db 0C6h	; Æ
		db    3
		db 0C6h	; Æ
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db    9
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db    3
		db 0C6h	; Æ
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    4
		db 0C6h	; Æ
		db    4
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    4
		db 0C6h	; Æ
		db    4
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db  87h	; 
		db    3
		db 0C6h	; Æ
		db    9
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db    8
		db 0C7h	; Ç
		db    3
		db 0C7h	; Ç
		db  88h	; 
		db    3
		db 0C7h	; Ç
		db  88h	; 
		db    3
		db 0C7h	; Ç
		db  88h	; 
		db    3
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db    3
		db 0C9h	; É
		db    3
		db 0C9h	; É
		db  8Ah	; 
		db    3
		db 0C9h	; É
		db  8Ah	; 
		db    3
		db 0C9h	; É
		db  8Ah	; 
		db    3
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db    3
		db 0CAh	; Ê
		db    3
		db 0CAh	; Ê
		db  8Bh	; 
		db    3
		db 0CAh	; Ê
		db  8Bh	; 
		db    3
		db 0CAh	; Ê
		db  8Bh	; 
		db    3
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db    3
		db 0CBh	; Ë
		db  8Ch	; 
		db    3
		db 0CBh	; Ë
		db  8Ch	; 
		db    3
		db 0CBh	; Ë
		db  8Ch	; 
		db    3
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db    9
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Fh
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db    3
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db    9
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db    9
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db    9
		db 0CEh	; Î
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db    3
		db 0CEh	; Î
		db  8Fh	; 
		db    6
		db 0CDh	; Í
		db    3
		db 0CDh	; Í
		db  8Eh	; 
		db    3
		db 0CDh	; Í
		db  8Eh	; 
		db    3
		db 0CDh	; Í
		db  8Eh	; 
		db    6
		db 0CCh	; Ì
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    4
		db 0CCh	; Ì
		db    4
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    3
		db 0CCh	; Ì
		db  8Dh	; 
		db    4
		db 0CCh	; Ì
		db    9
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db    7
		db 0D0h	; Ð
		db  91h	; 
		db    7
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db    7
		db 0D1h	; Ñ
		db  92h	; 
		db    7
		db 0D1h	; Ñ
		db    3
		db 0D1h	; Ñ
		db    3
		db 0D1h	; Ñ
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db    3
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db    9
		db 0D1h	; Ñ
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db    3
		db 0D1h	; Ñ
		db  92h	; 
		db    8
		db 0D1h	; Ñ
		db    9
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db    9
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò
		db  0Ch
		db 0D3h	; Ó
		db  0Ch
		db 0D4h	; Ô
		db  0Ch
		db 0D5h	; Õ
		db  19h
		db 0D2h	; Ò
		db    3
		db 0D1h	; Ñ
		db  41h	; A
		db    3
		db 0D0h	; Ð
		db 0D1h	; Ñ
		db 0D2h	; Ò
		db 0D3h	; Ó
		db 0D4h	; Ô
		db 0D5h	; Õ
		db    3
		db 0D1h	; Ñ
		db    3
		db 0D2h	; Ò
		db  17h
		db  43h	; C
		db  44h	; D
		db  45h	; E
		db  2Dh	; -
		db 0C0h	; À
		db  43h	; C
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Eh
		db 0C2h	; Â
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Fh
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Eh
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    3
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  0Ch
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db  83h	; 
		db    9
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db    3
		db 0C3h	; Ã
		db  84h	; 
		db    9
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db  85h	; 
		db  0Ch
		db 0C3h	; Ã
		db    7
		db 0C3h	; Ã
		db  84h	; 
		db    7
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ah
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db  85h	; 
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db    3
		db 0C4h	; Ä
		db  85h	; 
		db    3
		db 0C4h	; Ä
		db    9
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Fh
		db 0C3h	; Ã
		db    9
		db 0C2h	; Â
		db  0Fh
		db 0C1h	; Á
		db    6
		db  41h	; A
		db    3
		db 0C0h	; À
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db    3
		db 0A0h	;  
		db  25h	; %
		db  80h	; 
		db  21h	; !
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db    8
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  1Fh
		db 0C1h	; Á
		db  82h	; 
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C2h	; Â
		db    3
		db 0C3h	; Ã
		db    3
		db  80h	; 
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C3h	; Ã
		db    3
		db 0C0h	; À
		db 0C2h	; Â
		db    3
		db 0C0h	; À
		db 0C3h	; Ã
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db  81h	; 
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C4h	; Ä
		db    3
		db 0C0h	; À
		db 0C3h	; Ã
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C2h	; Â
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db    3
		db 0C1h	; Á
		db  16h
		db  80h	; 
		db  0Fh
		db  80h	; 
		db    3
		db  80h	; 
		db  0Eh
		db  80h	; 
		db    3
		db  80h	; 
		db    3
		db  80h	; 
		db  0Eh
		db  80h	; 
		db    3
		db  80h	; 
		db  0Eh
		db  80h	; 
		db  26h	; &
		db  45h	; E
		db 0C0h	; À
		db    3
		db  41h	; A
		db    9
		db 0C1h	; Á
		db  0Ch
		db 0C2h	; Â
		db  0Ch
		db 0C3h	; Ã
		db  0Ch
		db 0C4h	; Ä
		db  0Ch
		db 0C5h	; Å
		db  0Ch
		db 0C6h	; Æ
		db  40h	; @
		db  0Ch
		db 0C7h	; Ç
		db  0Ch
		db 0C8h	; È
		db  0Ch
		db 0C9h	; É
		db  0Ch
		db 0CAh	; Ê
		db  0Ch
		db 0CBh	; Ë
		db  0Ch
		db 0CCh	; Ì
		db  0Ch
		db 0CDh	; Í
		db  0Ch
		db 0CEh	; Î
		db  0Ch
		db 0CFh	; Ï
		db  0Ch
		db 0D0h	; Ð
		db  0Ch
		db 0D1h	; Ñ
		db  0Ch
		db 0D2h	; Ò


































.end
.end
