*************************************************************************
*									*
*	SET SKEW FACTOR							*
*									*
*************************************************************************

	;
	; omnidisk i/o equates
	; 

omnidata	equ	0a0h			; data port for omnidisk controller
omnistat	equ	omnidata+1		; status port
omni$in		equ	1			; data is ready
omni$out	equ	80h			; Sending is possible/usefull

oc$unit	equ	9		;select (logical) unit
oc$TRaK	equ	10		;select track
oc$gens	equ	22		;get general status
oc$EXTS	equ	23		;get extended status
oc$SFDP	equ	28		;set floppy disk parameters
oc$fdie set	33		;Ignore floppy disk error & mark buffer valid
oc$GLDS	equ	5		;get logical device set
oc$skew	equ	8		;set non-standard skew factor
oc$DPBX	equ	25		;get extended DPB (CP/M 3.0)


	ORG	100H

;
;	THE OMNIDISK SET SKEW COMMAND IS A FIVE-BYTE COMMAND SEQUENCE
;
;	BYTE	VALUE			COMMENTS
;	----	-----	-------------------------------------------------------
;	1	8	THIS IS THE MAIN COMMAND BYTE
;
;	2	UNIT	IF 0..F THEN THIS IS CP/M A: .. P: (MUST BE FLOPPY)
;			IF 10H..13H THEN 8" FLOPPY 0..3
;			IF 14H..17H THEN 5" FLOPPY 0..3
;
;	3	FORMAT	LOW BITS = SECTOR LEN: 0->128, 1->256, 2->512, 3->1024
;			ADD 40H IF DOUBLE DENSITY
;
;	4	#SECT	NUMBER OF SECTORS/TRACK (SECTORS/SIDE IF 2-SIDED)
;
;	5	SKEW	SKEW FACTOR (=0 RESTORES DEFAULT)
;
;	THE ENTIRE 5-BYTE SEQUENCE NAY BE REPETED USING AS MANY DIFERENT
;	UNITS AND/OR FORMATS THAT YOU WISH.  THE SKEW FACTOR BECOMES
;	EFFECTIVE WHEN THIS PROGRAM IS DONE.  (BECAUSE THIS PROGRAM ENDS
;	FORCING A WARM BOOT AND AFTER WARM BOOT A GETDPB FUNCTION IS
;	DONE BEFORE ANY OTHER ACCESS.)
;
	CALL	OUTLIST
	DB	L1END-$-1	;LENGTH
	DB	oc$skew		;OMNI COMMAND: SET SKEW BYTE
	DB	15h		; 5" unit 1
	DB	2+40H		;FOR 1024-BYTE SECTORS + DOUBLE DENSITY
	DB	8		;8 SECTORS
	DB	1		;SKEW = 3
	db	oc$gens		; Omni command: get general status
L1END:

	CALL	INCHAR		;Get status
	ora	a
	jnz	n0
	lxi	d,m$ok
	jmp	pexit
m$ok:	db	'Skew set',10,13,'$'
n0:	cpi	1
	jnz	n1
	lxi	d,m$1
	jmp	pexit
m$1:	db	'Device is not a floppy',10,13,'$'
n1:	cpi	2
	jnz	n2
	lxi	d,m$2
	jmp	pexit
m$2:	db	'Unknown format',10,13,'$'
n2:	cpi	3
	jnz	n3
	lxi	d,m$3
	jmp	pexit
m$3:	db	'Bad skew factor',10,13,'$'

n3:	
	lxi	d,m$u
pexit:
	mvi	c,9
	jmp	5

m$u:	db	'Unknown error',10,13,'$'


OUTLIST:
	XTHL
	MOV	C,M
	INX	H
OUTLIST1:
	MOV	A,M
	INX	H
	CALL	OUTCHAR
	DCR	C
	JNZ	OUTLIST1
	XTHL
	RET

OUTCHAR:
	PUSH	PSW
OUTCHAR1:
	IN	omnistat
	ANI	omni$out
	JNZ	OUTCHAR1
	POP	PSW
	OUT	omnidata
	RET
INCHAR:
	IN	omnistat
	ANI	omni$in
	JZ	INCHAR
	IN	omnidata
	RET

	END



