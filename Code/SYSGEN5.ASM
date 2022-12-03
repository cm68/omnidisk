;	TITLE	'SYSGEN5 - SYSTEM GENERATION PROGRAM 1983'
;	SYSTEM GENERATION PROGRAM, VERSION FOR FULCRUM OMNIDISK
VERS	EQU	30	;X.X
;
;	COPYRIGHT (C) DIGITAL RESEARCH
;	         1976, 1977, 1978, 1979
;

NDISKS	EQU	16		;NUMBER OF DISK DRIVES (A - P)
SECSIZ	EQU	128		;SIZE OF EACH SECTOR
;
DPBTBL	equ	0AH
FCB		EQU	5CH		;DEFAULT FCB LOCATION
FCBCR	EQU	FCB+32	;CURRENT RECORD LOCATION
TPA		EQU	100H	;TRANSIENT PROGRAM AREA
;
; BDOS FUNCTIONS
BDOS	EQU	5H		;DOS ENTRY POINT
BOOT	EQU	0		;JMP TO 'BOOT' TO REBOOT SYSTEM
CONI	EQU	1		;CONSOLE INPUT FUNCTION
CONO	EQU	2		;CONSOLE OUTPUT FUNCTION
SELF	EQU	14		;SELECT DISK
OPENF	EQU	15		;DISK OPEN FUNCTION
DREADF	EQU	20		;DISK READ FUNCTION
SETDMA	EQU	26		;SET DMA ADDRESS
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
OC$DLDM EQU	4		;DEFINE LOGICAL DEVICE MAPPING
OC$GLDM	EQU	5		;GET LOGICAL DEVICE MAPPING
OC$FWRT	EQU	6		;FORCE WRITE OF MODIFIED BUFFERS
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
DATAPORT:
	db	OMNIDATA				;Omnidisk DATA port
	db	' COPYRIGHT (C) 1978, DIGITAL RESEARCH '
	db	CR,LF
	db	' CHANGES COPYRIGHT (c) 1983, W/W COMPONENTS'
	db	01AH
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
;	PRINT CR,LF, MESSAGE AT <HL>
crmsg:
	push	h
	call	crlf
	pop		h
;
;	DROP THRU TO OUTMSG0
;	PRINT MESSAGE ADDRESSED BY H,L TIL ZERO
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
	sta		DEV
	sta		LUN
	call	cmdlist
	db		004H				;LENGTH OF LIST
	db		OC$UNIT				;Command: select unit
DEV	db		000H				;P1: unit#
	db		OC$GLDM				;Command: get logical drive mapping
LUN	db		000H				;P1: logical unit#
	call	inchar
	mov		b,a					;<B> = physical unit#
	ani		00CH				;Isolate bits: 0000$1100
	sta		sdisk				;00=8", 04=5.25", 08=WD, 0C=RAM
	ora		b					;Restore <A>, set flags
	rp							;Done if positive value
flush:
	call	inchar				;Get byte from Omnidisk
	ora		a					;Set flags
	rp							;Done if positive value
	jmp		flush				;Keep flushing bytes
;
;************************************************
;	SUBROUTINE FOR BLOCK READ					*
;												*
;	NOTE:	THIS SUBROUTINE READS DATA UNTIL	*
;		THE OMNI CONTROLLER ACCEPTS THE			*
;		GENERAL STATUS COMMAND					*
;************************************************
getdat:
	in		OMNISTAT
X01D1	EQU	$-1
	rrc							;Rotate right to test bit 0
	jnc		getdat				;IF NOTHING TO GET FROM OMNI
	ani		40H					;(WHAT DO WE HAVE HERE: DATA -OR- GEN STATUS?)
	in		OMNIDATA			;TAKE IT, WHATEVER IT IS
X01D9	EQU	$-1
	rz							;IF IT IS GENERAL STATUS, THEN RETURN
	mov		m,a					;ELSE...PUT INTO BUFFER
	inx		h
	jmp		getdat				;KEEP ON KEEPING ON

;********************************************************
;	SUBROUTINE TO SEND CONSTANT BYTE TO OMNIDISK		*
;********************************************************

onelist:
	xthl
	mov		a,m
	inx		h
	xthl
;	...	FALL INTO SENDCMD

;********************************************************
;	SUBROUTINE TO SEND COMMAND TO DISK CONTROLLER		*
;********************************************************

sendcmd:
	push	psw					;BYTE TO SEND TO OMNI
sendcmd1:
	in		OMNISTAT
X01E6	EQU	$-1
	ral							;Rotate left to test bit 7
	jc		sendcmd1			;IF OMNI NOT READY TO TAKE BYTE
	pop		psw
	out		omnidata			;SEND BYTE TO OMNI
X01ED	EQU	$-1
	ret

;************************************************************
;	SUBROUTINE TO ACCEPT ONE BYTE FROM DISK CONTROLLER		*
;************************************************************

inchar:
	in		OMNISTAT
X01F0	EQU	$-1
	rar							;Rotate right to test bit 0
	jnc		inchar				;IF OMNI HAS NOT YET SENT REPLY
	in		OMNIDATA			;ACCEPT REPLY
X01F6	EQU	$-1
	ret

;********************************************
;	SUBROUTINE TO ISSUE COMMAND LIST		*
;********************************************

cmdlist:
	xthl
	mov		c,m					;FETCH LENGTH OF LIST
	inx		h
cmdlist1:
	in		OMNISTAT
X01FC	EQU	$-1
	ani		OUTREADY
	jnz		cmdlist1			;IF OMNI NOT READY TO TAKE BYTE
	mov		a,m					;NEXT BYTE TO SEND
	inx		h
	out		OMNIDATA			;BYTE TO CONTROLLER
X0205	EQU	$-1
	dcr		c
	jnz		cmdlist1			;IF MORE COMMANDS TO SEND
	xthl
	ret

;********************************************
;	SUBROUTINE TO GET Disk Parameter Block	*
;	<HL> = OFFSET 00,02,04,06,08,10,12		*
;********************************************
;	DPBTBL:	DW DRIVE00
;			DW DRIVE01
;			DW DRIVE02
;			:
;			:
;			DW DRIVE15

getdpb:
	lxi		d,DPBTBL			;Base of address table
	dad		d
	mov		e,m
	inx		h
	mov		h,m
	mov		l,e					;<HL> = DPB buffer
	call	cmdlist
	db		005H				;LENGTH
	db		OC$TRAK				;Command: move to track
	db		002H				;P1: track low
	db		000H				;P2: track hi
	db		OC$GDPB				;Command: get DPB
	db		OC$GENS				;Command: get genstatus
	call	getdat				;Read table
	ret

;****************************************
;		MAIN PROGRAM STARTS HERE		*
;****************************************

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
	lxi		sp,STACK			;SET LOCAL STACK POINTER
	lxi		h,signon
	call	outmsg
;
;	CHECK FOR DEFAULT FILE LOAD INSTEAD OF GET
;
	lda		fcb+1				;BLANK IF NO FILE
	cpi		' '
	jz		getsys				;SKIP TO GET SYSTEM MESSAGE IF BLANK
	lxi		d,FCB				;TRY TO OPEN IT
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
	sta		FCBCR				;CURRENT RECORD = 0
;
;	PRE-READ AREA FROM TPA TO LOADP
;
	mvi		c,(LOADP-TPA)/SECSIZ	;010H
;	PRE-READ FILE
prerd:
	lxi		d,FCB				;INPUT FILE CONTROL BLOCK
	call	dread				;ASSUME SET TO DEFAULT BUFFER, READ SECTOR
	ora		a
	jnz		badrd				;CANNOT ENCOUNTER END-OF FILE
	dcr		c					;COUNT DOWN
	jnz		prerd				;FOR ANOTHER SECTOR WE IGNORE
;
;	NOW POINTING TO BEGINNING OF OS IMAGE [BOOT CODE]
;
	lxi		h,LOADP				;<HL> = 0900H
	call	dmadread			;DMA ADDRESS SET & READ SECTOR WITH BOOT CODE
	lda		RECORDS				;1ST SECTOR HAS NUMBER OF RECORDS TO READ
	mov		c,a					;<C> = RECORD COUNT
rdinp:
	lxi		d,SECSIZ
	dad		d					;HL IS NEW LOAD ADDRESS
	lxi		d,FCB				;READY FOR READ
	call	dmadread			;DMA ADDRESS SET & READ SECTOR
	ora		a
	jnz		badrd				;CANNOT ENCOUNTER END-OF FILE
	dcr		c
	jnz		rdinp				;ASSUME EOF IF NOT ZERO
	jmp		putsys				;EOF - ASK FOR DESTINATION DRIVE
;
;	EOF ENCOUNTERED IN INPUT FILE
;
badrd:
	lxi		h,badfile
	call	crmsg
	jmp		reboot				;Exit SYSGEN
;
;	BAD DISK NAME
;
badunit:
	lxi		h,qdisk
failmsg:
	call	crmsg
;	...		FALL INTO GETSYS
;
;	GET SYSTEM
;
getsys:
	lxi		h,askget			;GET SYSTEM?
	call	crmsg
	call	getchar
	cpi		CR
	jz		putsys				;SKIP IF CR ONLY
	sta		gdisk
	sui		'A'					;CONVERT TO BINARY VALUE
	cpi		NDISKS				;VALID DRIVE?
	jnc		badunit				;TOO HIGH, REPORT ERROR AND ASK AGAIN
	call	sel					;TO SELECT THE DRIVE
	jz		failmsg				;<HL>='NO DISK' MESSAGE
	lxi		h,getmsg			;'SOURCE ON' MESSAGE
	call	crmsg
	call	getchar				;Get drive letter
	cpi		CR
	jnz		reboot				;Exit SYSGEN?
	call	crlf
	call	cmdlist
data2:
	db		003H				;LENGTH
	db		OC$BOOT				;Command: read OS
	db		001H				;P1: #records
	db		OC$GENS				;Command: get genstats
	lxi		h,LOADP				;<HL> = 0900H
	call	getdat				;Read record
	ora		a					;Should be 0
	lxi		h,rsysbad
	jnz		bail				;READ ERROR?
	lda		RECORDS				;<A> = #RECORDS @ xx7EH
	sta		REC
	call	cmdlist
	db		003H				;LENGTH
	db		OC$BOOT				;Command: read OS
REC	db		000H				;P1: #records
	db		OC$GENS				;Command: get genstatus
	lxi		h,LOADP
	call	getdat				;Read ALL records
	ora		a					;Shoukld be 0
	lxi		h,rsysbad
	jnz		bail				;READ ERROR?
	jmp		putsys				;Good read, Ask where to PUT
;
;	INVALID DRIVE NAME
;
diskerr:
	lxi		h,qdisk
fail:
	call	crmsg
;
;	PUT SYSTEM
;
putsys:
	lxi		h,askput
	call	crmsg
	call	cpmsize				;Compute SIZE of OS
	call	getchar
	cpi		CR
	jz		reboot				;Exit SYSGEN?
	sta		pdisk
	sui		'A'					;CONVERT TO BINARY VALUE
	cpi		NDISKS				;VALID DRIVE?
	jnc		diskerr				;TOO HIGH, REPORT ERROR AND ASK AGAIN
	call	sel					;TO SELECT THE DRIVE
	jz		fail				;<HL>='NO DISK' MESSAGE
	lxi		h,putmsg			;'DESTINATION ON' MESSAGE
	call	crmsg
	call	getchar
	cpi		CR					;REBOOT?
	jnz		reboot				;Exit SYSGEN
	call	setup				;Is dest empty?
	jnz		fail				;YES...
	call	crlf				;NO
	call	onelist
	db		OC$SWRT				;Command: write system
	lda		RECORDS
	call	sendcmd				;P1: #records to write
	lxi		h,LOADP				;<HL> = 0900H
	call	writerec			;Write ALL records
	call	onelist
	db		OC$GENS				;Command: get genstatus
	call	inchar				;Should be 0
	lxi		h,wsysbad
	ora		a					;Set flags
	jnz		fail				;WRITE ERROR?
	jmp		putsys				;Ask for next disk
;
;	GET DPB OF DESTINATION DRIVE
;	TOO CHECK IF OVERWRITING ANOTHER OS
;
setup:
	mvi		c,2					;<C> = TRACK#
	lxi		h,DPB1				;<HL> = where to load DPB
	call	loaddpb				;Read DPB from selected track#
	lxi		h,dstnrd
	jnz		rpterr				;READ ERROR?
	lda		RECORDS
	mov		b,a					;<B> = #records in OS
	lhld	DISK1
	mov		c,l					;<C> = disk size
	mov		a,l
	ani		0F8H				;NOT 07 1111$1000
	ora		h
	lxi		h,destbad
	jnz		rpterr				;Drive has OS allready?
	ora		c
	jz		rpterr
	jmp		sizeit				;Now check size
;
willitfit:
	lxi		h,DPB2
	push	b
	call	loaddpb
	pop		b
	lxi		h,dstnrd
	jnz		rpterr				;READ ERROR?
	lda		DPB2
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
	ora		h					;<A> not 0
	ret
;
goodfit:
	xra		a					;<A> is 0
	ret
;
;	READ DPB FROM TRACK <C>
;
loaddpb:
	mov		a,c
	sta		TRK
	call	cmdlist
	db		005H				;LENGTH
	db		OC$TRAK				;Command: set track
TRK	db		000H				;P1: track low
	db		000H				;P2: track hi
	db		OC$GDPB				;Command: read DPB
	db		OC$GENS				;Command: get genstatus
	call	getdat				;Get data
	ora		a					;Should be 0
	rz							;Good read
;
;	GET EXTENDED STATUS
;
	lxi		h,STATUS
	call	cmdlist
	db		002H				;LENGTH
	db		OC$EXTS				;Command: get extstatus
	db		OC$GENS				;Command: get genstatus
	call	getdat				;Get data
	lda		STATUS
	ora		a					;Set flags
	ret
;
;	WRITE ALL RECORDS
;
writerec:
	lda		RECORDS
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
;	Compute size of CP/M as decimal number
;
cpmsize:
	xra		a
	lda		RECORDS
	dcr		a
	rar
	adi		10
	mvi		l,'0'-1
szloop:
	inr		l
	sui		10
	jp		szloop
	adi		'9'+1
	mov		h,a
	shld	sizecpm
	ret
;
;	REPORT ERROR & REBOOT
bail:
	call	crmsg
;	...		FALL INTO REBOOT
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
qdisk:	db	'INVALID DRIVE NAME (USE LETTER "A" TO "P")',0
nodisk:	db	'NO DISK DEFINED FOR THAT LETTER',0
nofile:	db	'NO SOURCE FILE ON DISK',0
badfile:db	'SOURCE FILE INCOMPLETE',0
rsysbad:db	'ERROR READING SYSTEM FROM SYSTEM TRACKS',0
wsysbad:db	'ERROR WRITING SYSTEM TRACKS',0
destbad:db	'DESTINATION DISK CAN NOT CONTAIN SYSTEM',0
dstnrd:	db	'CAN NOT ACCESS DESTINATION DISK',0
toobig:	db	'SYSYEM TO BIG FOR SELECTED DEVICE -- WRITE NOT ATTEMPTED',0
savcpm:	db	'(If desired, SAVE '
sizecpm:db	'??'				;FILLED IN BY CPMSIZE
		db	' CPMxx.COM)',0
		db	0
;
sdisk:	db	0	;Selected disk: 00=8", 04=5.25", 08=WD, 0C=RAM
;
dpb1:	db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0
disk1:	dw	0
;
dpb2:	db	0,0,0,0
		db	0,0,0,0
		db	0,0,0,0
		db	0
disk2:	dw	0
;
status:	db	0,0,0,0
		db	0,0,0,0
		db	0
;
		dw	0,0,0,0,0,0,0
;
stack	EQU	06B2H
;
		ORG	0900H
LOADP	EQU	$			;LOAD POINT FOR SYSTEM DURING LOAD/STORE
RECORDS	EQU	LOADP+7EH	;NUMBER OF RECORDS LOCATED IN BOOT CODE
		END	TPA
