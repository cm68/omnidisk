;	TITLE	'SYSGEN5 - SYSTEM GENERATION PROGRAM 1983'
;	SYSTEM GENERATION PROGRAM, VERSION FOR FULCRUM OMNIDISK
VERS	EQU	30	;X.X
;
;	COPYRIGHT (C) DIGITAL RESEARCH
;	         1976, 1977, 1978, 1979
;

NDISKS	EQU	16			;NUMBER OF DISK DRIVES
SECSIZ	EQU	128			;SIZE OF EACH SECTOR
;
DPBTBL	equ	0AH
FCB		EQU	005CH		;DEFAULT FCB LOCATION
FCBCR	EQU	FCB+32		;CURRENT RECORD LOCATION
TPA		EQU	0100H		;TRANSIENT PROGRAM AREA
LOADP	EQU	0900H		;LOAD POINT FOR SYSTEM DURING LOAD/STORE
LOADP1	EQU	LOADP+40H	;BOOT CODE
RECORDS	EQU	LOADP+7EH	;CCP-3 (NUMBER OF RECORDS IN BOOT)
BDOS	EQU	5H			;DOS ENTRY POINT
BOOT	EQU	0			;JMP TO 'BOOT' TO REBOOT SYSTEM
CONI	EQU	1			;CONSOLE INPUT FUNCTION
CONO	EQU	2			;CONSOLE OUTPUT FUNCTION
SELF	EQU	14			;SELECT DISK
OPENF	EQU	15			;DISK OPEN FUNCTION
DREADF	EQU	20			;DISK READ FUNCTION
SETDMA	EQU	26			;SET DMA ADDRESS
;
;
;********************************************************
;	VALID COMMAND BYTE ONE FOR OMNI CONTROLLER V1.3		*
;	   (THESE EQUATES ARE COPIED FROM BIOS)				*
;********************************************************

OC$BOOT	EQU	0		;BOOT SYSTEM
OC$SWRT	EQU	1		;WRITE SYSTEM (INVERSE OF BOOT)
OC$MODE EQU	2		;DMA/IO MODE
OC$FMTF	EQU	3		;FORMAT FLOPPY TRACK
OC$DLDS EQU	4		;DEFINE LOGICAL DEVICE SET
OC$GLDS	EQU	5		;GET LOGICAL DEVICE SET
OC$FWRT	EQU	6       ;FORCE WRITE OF MODIFIED BUFFERS
OC$RBPH	EQU	7		;RESET BOOT PHANTOM
OC$SKEW	EQU	8		;Set sector skew
OC$UNIT	EQU	9		;SELECT (LOGICAL) UNIT
OC$TRAK	EQU	10		;SELECT TRACK
OC$RECD	EQU	11		;SELECT (LOGICAL) RECORD
OC$DADR	EQU	12		;SET DMA ADDRESS
OC$READ	EQU	13		;READ
OC$WRIT	EQU	14		;WRITE
OC$HEAD	EQU	15		;SET HEAD (NOT USED, ANYWHERE)
OC$MOVM	EQU	16		;DMA memory move
OC$GDPB	EQU	17		;GET DPB (GET CP/M DPB FROM OMNI)
OC$DFMD	EQU	18		;Define memory disk
OC$SSEK EQU	19		;NON-IMPYED SEEK (NOT USED IN BIOS)
OC$TIOW	EQU	20		;DEBUG WRITES TO OMNI
OC$TIOR	EQU	21		;DEBUG READE FROM OMNI
OC$GENS EQU	22		;GET GENERAL STATUS
OC$EXTS	EQU	23		;GET EXTENDED STATUS
OC$SRTY	EQU	24		;Set floppy disk retry counters
OC$DPBX	EQU	25		;Get extended DPB
OC$GBPB	EQU	26		;Get MS-DOS bios parameter block
OC$GMCS	EQU	27		;Get media change status
OC$SFDP	EQU	28		;Set Floppy Disk Parameters
OC$PREA	EQU	29		;Physical Sector Read
OC$PWRT	EQU	30		;Physical Sector Write
OC$HDPA	EQU	31		;Set Common Hard Disk Parameters
OC$HTBL	EQU	32		;Set Hard Disk Tables
OC$FDIE	EQU	33		;Ignore Floppy Disk Errors & Mark Buffer Valid
OC$SIHD	EQU	34		;Set Individual HD Parameters
OC$GIHD	EQU	35		;Get Individual HD Parameters
OC$SFPB	EQU	36		;SET FLOPPY DPB AND PARAMETERS
OC$GFPB	EQU	37		;GET FLOPPY DPB AND PARAMETERS
OC$DRID	EQU	38		;READ I.D. INFO TO EXTENDED STATUS
OC$SIND	EQU	39		;SET INDIVIDUAL STEP RATES
OC$STPI	EQU	40		;SET TRACK DENSITY STATUS (TPI)
OC$GTPI	EQU	41		;INVERSE OF ABOVE
OC$GVER	EQU	42		;RETURN VERSION NUMBER
OC$GTAG	EQU	43		;RETURN BUFFER TAGS TO HOST
OC$INIT	EQU	255		;Re-Initialize Omnidisk Controller

OMNIDATA EQU	0A0H		;<== DATA PORT FOR OMNI CONTROLLER
OMNISTAT EQU	OMNIDATA+1	;STATUS PORT FOR OMNI
INREADY  EQU	01H		;** OMNI HAS DATA TO SEND
OUTREADY EQU	80H		;** OMNI CAN NOT ACCEPT ANOTHER BYTE NOW
;
MAXTRY	EQU	10	;MAXIMUM NUMBER OF RETRIES ON EACH READ/WRITE
CR		EQU	0DH	;CARRIAGE RETURN
LF		EQU	0AH	;LINE FEED
STACKSIZE	EQU	16	;SIZE OF LOCAL STACK
;
WBOOT	EQU	1	;ADDRESS OF WARM BOOT (OTHER PATCH ENTRY
;
	org	tpa
;
begin:
	ei
	jmp	start
;
DATAPORT:	db	0A0H
	db	' COPYRIGHT (C) 1978, DIGITAL RESEARCH '
	db	0DH,0AH
	db	' CHANGES COPYRIGHT (c) 1983, W/W COMPONENTS',1AH
;
;	READ CONSOLE CHARACTER TO REGISTER A
getchar:
	mvi		c,CONI
	call	bdos
;	CONVERT TO UPPER CASE BEFORE RETURN
	cpi		'A' OR 20H			;RETURN IF BELOW LOWER CASE A
	rc
	cpi		('Z' OR 20H) + 1
	rnc							;RETURN IF ABOVE LOWER CASE Z
	ani		05FH
	ret
;
;	WRITE CHARACTER FROM A TO CONSOLE
putchar:
	mov		e,a
	mvi		c,CONO
	call	bdos
	ret
;
;	SEND CARRIAGE RETURN, LINE FEED
crlf:
	mvi		a,CR
	call	putchar
	mvi		a,LF
	call	putchar
	ret
;
;	PRINT MESSAGE ADDRESSED BY H,L TIL ZERO
crmsg:
	push	h
	call	crlf
	pop		h
;
;	DROP THRU TO OUTMSG0
outmsg:
	mov		a,m
	ora		a
	rz
;	MESSAGE NOT YET COMPLETED
	push	h
	push	d
	push	b
	call	putchar
	pop		b
	pop		d
	pop		h
	inx		h
	jmp		outmsg
;
;	SET DMA ADDRESS TO VALUE OF H,L
dmadread:
	push	b
	push	d
	push	h
	mov		d,h
	mov		e,l
	mvi		c,SETDMA
	call	bdos
	pop		h
	pop		d
	pop		b
;	DROP THRU TO DREAD
;
;	DISK READ FUNCTION
dread:
	push	b
	push	d
	push	h
	mvi		c,DREADF
	call	bdos
	pop		h
	pop		d
	pop		b
	ret
;
;	FILE OPEN FUNCTION
open:
	mvi		c,OPENF
	jmp		bdos
;
;	SELECT DISK GIVEN BY REGISTER A
sel:
	lxi		h,nodisk
	sta		data0a
	sta		data0c
	call	cmdlist
	db		004H				;LENGTH OF LIST
	db		OC$UNIT				;09H
data0a:
	db		000H
	db		OC$GLDS				;05H
data0c:
	db		000H
;
	call	inchar
	mov		b,a
	ani		00CH
	sta		sdisk
	ora		b
	rp
flush:
	call	inchar
	ora		a
	rp
	jmp		flush
;
getdat:
	in		OMNISTAT			;0DBH
X01D1	EQU	$-1					;0A1H
	rrc
	jnc		getdat
	ani		040H
	in		OMNIDATA			;0DBH
X01D9	EQU	$-1					;0A0H
	rz
	mov		m,a
	inx		h
	jmp		getdat
;
onelist:
	xthl
	mov		a,m
	inx		h
	xthl
sendcmd:
	push	psw
;
sendcmd1:
	in		OMNISTAT			;0DBH
X01E6	EQU	$-1					;0A1H
	ral
	jc		sendcmd1
	pop		psw
	out		omnidata			;0D3H
X01ED	EQU	$-1					;0A0H
	ret
;
inchar:
	in		OMNISTAT			;0DBH
X01F0	EQU	$-1					;0A1H
	rar
	jnc		inchar
	in		OMNIDATA			;0DBH
X01F6	EQU	$-1					;0A0H
	ret
;
cmdlist:
	xthl
	mov		c,m
	inx		h
;
cmdlist1:
	in		OMNISTAT			;0DBH
X01FC	EQU	$-1					;0A1H
	ani		OUTREADY
	jnz		cmdlist1
	mov		a,m
	inx		h
	out		OMNIDATA			;0D3H
X0205	EQU	$-1					;0A0H
	dcr		c
	jnz		cmdlist1
	xthl
	ret
;
getdpb:
	lxi		d,dpbtbl
	dad		d
	mov		e,m
	inx		h
	mov		h,m
	mov		l,e
	call	cmdlist
	db		005H				;LENGTH
	db		OC$TRAK				;00AH
	db		002H
	db		000H
	db		OC$GDPB				;011H
	db		OC$GENS				;016H
	call	getdat
	ret
;
start:
	lda		DATAPORT
	sta		X01D9
	sta		X01ED
	sta		X01F6
	sta		X0205
	sta		X03EC
	inr		a
	sta		X01D1
	sta		X01E6
	sta		X01F0
	sta		X01FC
	sta		X03E4
	lxi		sp,stack			;SET LOCAL STACK POINTER
	lxi		h,signon
	call	outmsg
;
;	CHECK FOR DEFAULT FILE LOAD INSTEAD OF GET
;
	lda		fcb+1				;BLANK IF NO FILE
	cpi	' '
	jz		getsys				;SKIP TO GET SYSTEM MESSAGE IF BLANK
	lxi		d,fcb				;TRY TO OPEN IT
	call	open				;
	inr		a					;255 BECOMES 00
	jnz		rdok				;OK TO READ IF NOT 255
;
;	FILE NOT PRESENT, ERROR AND REBOOT
;
	lxi		h,nofile
	call	crmsg
	jmp		reboot
;
;	FILE PRESENT
;	  READ TO LOAD POINT
;
rdok:
	xra		a
	sta		fcbcr				;CURRENT RECORD = 0
;
;	PRE-READ AREA FROM TPA TO LOADP
;
	mvi		c,(LOADP-TPA)/SECSIZ	;010H
;	PRE-READ FILE
prerd:
	lxi		d,fcb				;INPUT FILE CONTROL COUNT
	call	dread				;ASSUME SET TO DEFAULT BUFFER
	ora		a
	jnz		badrd				;CANNOT ENCOUNTER END-OF FILE
	dcr		c					;COUNT DOWN
	jnz		prerd				;FOR ANOTHER SECTOR
;
;	SECTORS SKIPPED AT BEGINNING OF FILE
;
	lxi		h,LOADP
	call	dmadread
	lda		records
	mov		c,a
rdinp:
	lxi		d,SECSIZ
	dad		d					;HL IS NEW LOAD ADDRESS
	lxi		d,fcb
	call	dmadread
	ora		a
	jnz		badrd
	dcr		c
	jnz		rdinp				;ASSUME EOF IF NOT ZERO
	jmp		putsys
;
badrd:							;EOF ENCOUNTERED IN INPUT FILE
	lxi		h,badfile
	call	crmsg
	jmp		reboot
;
badunit:
	lxi		h,qdisk
failmsg:
	call	crmsg
;
;	GET SYSTEM
getsys:
	lxi		h,askget			;GET SYSTEM?
	call	crmsg
	call	getchar
	cpi		CR
	jz		putsys				;SKIP IF CR ONLY
	sta		gdisk
	sui		'A'					;041H
	cpi		NDISKS				;VALID DRIVE?
	jnc		badunit				;TOO HIGH
	call	sel
	jz		failmsg
	lxi		h,getmsg
	call	crmsg
	call	getchar
	cpi		CR					;00DH
	jnz		reboot
	call	crlf
	call	cmdlist
data2:
	db		003H				;LENGTH
	db		OC$BOOT				;000H
	db		001H
	db		OC$GENS				;016H
	lxi		h,LOADP1
	call	getdat
	ora		a
	lxi		h,rsysbad
	jnz		bail
	lda		records
	sta		data3a
	call	cmdlist
	db		003H				;LENGTH
	db		OC$BOOT				;000H
data3a:
	db		000H				;# RECORDS
	db		OC$GENS				;016H
	lxi		h,LOADP1
	call	getdat
	ora		a
	lxi		h,rsysbad
	jnz		bail
	jmp		putsys
;
diskerr:
	lxi		h,qdisk
fail:
	call	crmsg
;
;	PUT SYSTEM
putsys:
	lxi		h,askput
	call	crmsg
	call	cpmsize
	call	getchar
	cpi		CR
	jz		reboot
	sta		pdisk
	sui		'A'
	cpi		NDISKS				;VALID DRIVE?
	jnc		diskerr				;TOO HIGH
	call	sel
	jz		fail
	lxi		h,putmsg
	call	crmsg
	call	getchar
	cpi		CR					;00DH
	jnz		reboot
	call	setup
	jnz		fail
	call	crlf
	call	onelist
	db		OC$SWRT				;001H
	lda		records
	call	sendcmd
	lxi		h,LOADP1
	call	writerec
	call	onelist
	db		OC$GENS				;016H
	call	inchar
	lxi		h,wsysbad
	ora		a
	jnz		fail
	jmp		putsys
;
setup:
	mvi		c,002H
	lxi		h,dpb1
	call	loaddpb
	lxi		h,dstnrd
	jnz		rpterr
	lda		records
	mov		b,a
	lhld	disk1
	mov		c,l
	mov		a,l
	ani		0F8H				;NOT 07 1111$1000
	ora		h
	lxi		h,destbad
	jnz		rpterr
	ora		c
	jz		rpterr
	jmp		sizeit
;
willitfit:
	lxi		h,dpb2
	push	b
	call	loaddpb
	pop		b
	lxi		h,dstnrd
	jnz		rpterr
	lda		dpb2
	cma
	inr		a
	add		b
	mov		b,a
	jnc		goodfit
	jz		goodfit
sizeit:
	dcr		c
	jp		willitfit
	lxi		h,toobig
rpterr:
	ora		h
	ret
;
goodfit:
	xra		a
	ret
;
loaddpb:
	mov		a,c
	sta		data4a
	call	cmdlist
	db		005H				;LENGTH
	db		OC$TRAK				;00AH
data4a:
	db		000H
	db		000H
	db		OC$GDPB				;011H
	db		OC$GENS				;016H
	call	getdat
	ora		a
	rz
	lxi		h,status
	call	cmdlist
	db		002H				;LENGTH
	db		OC$EXTS				;017H
	db		OC$GENS				;016H
	call	getdat
	lda		status
	ora		a
	ret
;
writerec:
	lda		records
	mov		b,a
writenext:
	call	inchar
	ora		a
	rnz
	mvi		c,SECSIZ			;080H
waitrec:
	in		OMNISTAT			;0DBH
X03E4	EQU	$-1					;0A1H
	add		a
	jc		waitrec
	mov		a,m
	inx		h
	out		OMNIDATA			;0D3H
X03EC	EQU	$-1					;0A0H
	dcr		c
	jnz		waitrec
	dcr		b
	jnz		writenext
	ret
;
cpmsize:
	xra		a
	lda		records
	dcr		a
	rar
	adi		10					;00AH
	mvi		l,47				;02FH
szloop:
	inr		l
	sui		10					;00AH
	jp		szloop
	adi		58					;03AH
	mov		h,a
	shld	sizecpm
	ret
;
bail:
	call	crmsg
reboot:
	lhld	sizecpm
	mov		a,h
	ora		l
	lxi		h,savcpm
	cnz		crmsg
	call	crlf
	jmp		BOOT
;
signon:	db	'SYSGEN VER '
		db	VERS/10+'0','.',VERS MOD 10+'0'
		db	0
askget:	db	'SOURCE DRIVE NAME (OR RETURN TO SKIP)',0
getmsg:	db	'SOURCE ON '
GDISK:	db	'?'					;FILLED IN AT GET FUNCTION
		db	', THEN TYPE RETURN',0
askput:	db	'DESTINATION DRIVE NAME (OR RETURN TO REBOOT)',0
putmsg:	db	'DESTINATION ON '
pdisk:	db	'?'					;FILLED IN AT PUT FUNCTION
		db	', THEN TYPE RETURN',0
errmsg:	db	'PERMANENT ERROR, TYPE RETURN TO IGNORE',0
qdisk:	db	'INVALID DRIVE NAME (USE LETTER ''A'' TO ''P'')',0
nodisk:	db	'NO DISK DEFINED FOR THAT LETTER',0
nofile:	db	'NO SOURCE FILE ON DISK',0
badfile:db	'SOURCE FILE INCOMPLETE',0
rsysbad:db	'ERROR READING SYSTEM FROM SYSTEM TRACKS',0
wsysbad:db	'ERROR WRITING SYSTEM TRACKS',0
destbad:db	'DESTINATION DISK CAN NOT CONTAIN SYSTEM',0
dstnrd:	db	'CAN NOT ACCESS DESTINATION DISK',0
toobig:	db	'SYSYEM TO BIG FOR SELECTED DEVICE -- WRITE NOT ATTEMPTED',0
savcpm:	db	'(If desired, SAVE '
sizecpm:dw	000H				;FILLED IN AT BAIL TIME
		db	' CPMxx.COM)',0
		db	0
sdisk:	db	0
dpb1:	db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0
disk1:	dw	0
dpb2:	db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0
disk2:	dw	0
status:
	db	000H
	db	000H
	db	000H
	db	000H
	db	000H
	db	000H
	db	000H
	db	000H
	db	000H
;
	DS	STACKSIZE*2
stack	EQU	06B2H
	end	100h
