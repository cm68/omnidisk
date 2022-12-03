FALSE	EQU	0
TRUE	EQU	NOT FALSE

SAFMT	EQU	FALSE	;BUILD STAND-ALONE
ISIO2	EQU	FALSE	;IMSAI SIO-2
CSS1	EQU	TRUE	;COMPUPRO SYSTEM SUPPORT 1

	IF	NOT SAFMT
WBOOT		equ	0h
BDOS		equ	5h
	ENDIF
TPA			equ	100H

; I/O PORTS
 IF ISIO2
BASE	EQU	00H			; Port A
SERCTLA	EQU	BASE + 3	; SIO PORT A STATUS
SERDATA	EQU	BASE + 2	; Data Port A
SERCTLB	EQU	BASE + 5	; SIO PORT B STATUS
SERDATB	EQU	BASE + 4	; Data Port B
IECTL	EQU	BASE + 8	; SIO INTERRUPTS CTRL PORT
SERTX	EQU	01H			; Transmit Buffer Ready
SERRX	EQU	02H			; RxREADY
 ENDIF	;ISIO2
 
  IF CSS1
BASE	EQU	05CH			; Port A
SERDATA	equ	BASE		;Console data
SERCTLA	equ	BASE+1		;Console status
CMODE	equ	BASE+2		;Mode registers
CCTRL	equ	BASE+3		;Command register
SERTX	equ	  01h		;channel a Tx ready bit
SERRX	equ	  02h		;channel a Rx ready bit
  ENDIF
;
;
OMNIDATA	equ	0A0H
OMNISTAT	equ	OMNIDATA+1
OMNI$IN		EQU	01H		;OMNI HAS DATA TO SEND
OMNI$OUT	EQU	80H		;OMNI CAN NOT ACCEPT ANOTHER BYTE NOW

;********************************************************
;	COMMAND CODES FOR OMNI CONTROLLER V1.3				*
;********************************************************

OC$BOOT	EQU	0		;BOOT SYSTEM
OC$SWRT	EQU	1		;WRITE SYSTEM (INVERSE OF BOOT)
OC$MODE EQU	2		;DMA/IO MODE
OC$FMTF	EQU	3		;FORMAT FLOPPY TRACK
OC$DLDM EQU	4		;DEFINE LOGICAL DEVICE MAPPING
OC$GLDM	EQU	5		;GET LOGICAL DEVICE MAPPING
OC$FWRT	EQU	6		;FORCE WRITE OF MODIFIED BUFFERS
OC$RSBP EQU	7		;RESET BOOT PHANTOM
OC$SKEW	EQU	8		;SET NON-STANDARD SKEW FACTOR
OC$UNIT	EQU	9		;SELECT (LOGICAL) UNIT
OC$TRAK	EQU	10		;SELECT TRACK
OC$RECD	EQU	11		;SELECT (LOGICAL) RECORD
OC$DADR	EQU	12		;SET DMA ADDRESS
OC$READ	EQU	13		;READ
OC$WRIT	EQU	14		;WRITE
OC$HEAD	EQU	15		;SET HEAD (RESERVED FOR FUTURE USE)
OC$MOVM	EQU	16		;MOVE BLOCK OF MEMORY WITH DMA
OC$GDPB	EQU	17		;GET DPB (GET CP/M DPB FROM OMNI)
OC$DFMD	EQU	18		;DEFINE MEMORY DISK
OC$SSEK EQU	19		;NON-IMPYED SEEK (NOT USED IN BIOS)
OC$TIOW	EQU	20		;DEBUG WRITES TO OMNI
OC$TIOR	EQU	21		;DEBUG READS FROM OMNI
OC$GENS EQU	22		;GET GENERAL STATUS
OC$EXTS	EQU	23		;GET EXTENDED STATUS
OC$SRTY	EQU	24		;SET COUNTERS FOR (FLOPPY DISK) RETRY LOGIC
OC$DPBX	EQU	25		;GET EXTENDED DPB (CP/M 3.0)
OC$GBPB	EQU	26		;GET MS-DOS "BIOS PARAMETER BLOCK"
OC$GMCS	EQU	27		;GET MS-DOS "MEDIA CHANGE STATUS"
OC$SFDP	EQU	28		;SET FLOPPY DISK PARAMETERS
OC$PREA	EQU	29		;PHYSICAL SECTOR READ
OC$PWRI	EQU	30		;PHYSICAL SECTOR WRITE
OC$HDPR	EQU	31		;HARD DISK PARMS (#HDS, PCOMP, STP R, CTLR TYP)
OC$HDTB	EQU	32		;HARD DISK TABLES--DEV SEL, PHYS OFFSET, OS TBL
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

CR			equ	0Dh
LF			equ	0Ah

			org		TPA
	IF SAFMT
WBOOT:
	ENDIF
start:
			in		OMNIDATA
			call	outmsg
			dw		signon
L0107:		call	init
L010A:		call	select$device
L010D:		call	L0298
			ora		a
			jz		L0122
			cpi		004H
			jz		L010A
			sta		X102E
			call	L0424
			jmp		L010D
;
L0122:		call	L0377
			jmp		L010D
;
; Init Physical Device Table
;
init:		lxi		h,buff0
			mvi		c,13
clr$buf:	mvi		m,0
			inx		h
			dcr		c
			jnz		clr$buf
			lxi		h,phy$dev$tbl	;01088H
			shld	phy$dev$ptr
			mvi		a,00FH
			sta		log$unit
next$lds:	call	cmdlist		;Get Logical Devices Set
			db		002H
			db		oc$gldm		;005H
log$unit:	db		000H
			call	inchar		;Physical Device Number
			ora		a
			jp		store$phy	;Single device?
			push	psw			;Save original device number
skip$pd:	call	inchar		;Flush more assigned device numbers
			ora		a
			jm		skip$pd
			pop		psw			;Original physical device number
store$phy:	lhld	phy$dev$ptr
			mov		m,a			;Store physical device number
			dcx		h
			shld	phy$dev$ptr	;table built backwards
			jz		bump$lds	;bump to next LUN
			mvi		d,0
			mov		e,a			;<DE> = offset
			lxi		h,phys$dev$tbl
			dad		d
			lda		log$unit
			adi		'A'			;Convert to A-P 041H
			mov		m,a			;Store ASCII drive letter
bump$lds:	lxi		h,log$unit	;Current LUN
			dcr		m			;LUN=LUN - 1
			jp		next$lds	;More to go?
			ret
phy$dev$ptr	dw		0312FH
;
select$device:
			call	outmsg
			dw		askdev
			xra		a
			sta		X1024
			call	conin
			cpi		'A'			;041H
			jc		bad$dev
			cpi		'P'+1		;051H
			jc		valid$dev
			sui		020H
			cpi		'A'			;041H
			jc		bad$dev
			cpi		'P'+1		;'P'+1
			jnc		bad$dev
valid$dev:	sta		DRIVE		;Drive letter (ASCII)
			sui		041H		;Convert to binary unit#
			sta		UNIT
			mvi		d,0
			mov		e,a			;<DE> = offset
			lxi		h,device$tbl
			dad		d
			mov		a,m			;Device exists flag
			ora		a
			jz		no$phy$dev	;No physical device exists
			sta		PHYS$UNIT
			push	psw
			call	cmdlist		;Select unit
			db		002H
			db		oc$unit		;009H
UNIT:		db		000H
			pop		psw
			ani		00CH
			sta		X1030		;Floppy type
			lxi		d,std8
			lxi		h,inch8
			jz		L01F1
			lxi		d,std5
			lxi		h,inch5
			cpi		004H
			jz		L01F1
			cpi		008H
			jz		L0216
			call	cmdlist		;Get list of supported density's
			db		004H
			db		oc$fmtf		;003H
			db		000H
			db		000H
			db		oc$gens		;016H
			lxi		h,dens$tbl
			call	getdat
			lda		X103E		;MEM disk supported in BIOS flag
			ora		a
			rnz
			call	outmsg
			dw		nomdf
			jmp		select$device
;
L01F1:		shld	dev$label
			xchg
			mov		e,m
			inx		h
			mov		d,m
			inx		h
			push	d
			mov		e,m
			inx		h
			mov		d,m
			xchg
			shld	X102B
			pop		h
			shld	X1029
			ret
;
bad$dev:	call	outmsg
			dw		badun
			jmp		select$device
;
no$phy$dev:	call	outmsg
			dw		nophy
			jmp		select$device
;
L0216:		call	cmdlist
			db		002H
			db		oc$gdpb		;011H
			db		oc$gens		;016H
;
L021C:		lxi		h,X1058
			call	getdat
			mvi		a,006H
			sta		X1068
			sta		X106A
			sta		X106B
			mvi		a,001H
			sta		X1067
			lhld	X1065
			cmp		h
			jnz		L0243
			mov		a,l
			cpi		008H
			jnc		L0243
			inr		a
			sta		X1067
L0243:		lhld	X105F
			lxi		d,001FFH
			dad		d
			mov		a,h
			sta		X1069
			lhld	X105D
			inx		h
			lda		X105A
			mov		c,a
			xra		a
L0257:		dad		h
			ral
			dcr		c
			jnz		L0257
			mov		e,a
			mov		d,c
			lda		X1058
			mov		c,a
			lda		X1059
			mov		b,a
			call	L0731
			mov		a,d
			ora		e
			jz		L0270
			inx		h
L0270:		dcx		h
			xchg
			lhld	X1065
			dad		d
			shld	X102B
			lhld	X1065
			mov		a,h
			ora		a
			jnz		L0289
			mvi		a,007H
			cmp		l
			jc		L0289
			mvi		l,000H
L0289:		shld	X1029
			lxi		h,hdisk
			shld	dev$label
			mvi		a,001H
			sta		X1024
			ret
;
L0298:		lda		PHYS$UNIT
			cpi		01CH		;Is it memory disk
			jz		L035D		;Yes
			call	outmsg
			dw		asktrk
;
L02A5:		lhld	dev$label
			call	outmsg$hl
			lda		PHYS$UNIT
			ani		003H
			adi		030H
			sta		X0882
			call	outmsg
			dw		cunit
			call	outmsg
			dw		sep
			lhld	X1029
			xchg
			lxi		h,X1089
			call	outnum
			mvi		m,024H
			call	outmsg
			dw		X1089
			call	outmsg
			dw		to
			lhld	X102B
			xchg
			lxi		h,X1089
			call	outnum
			mvi		m,024H
			call	outmsg
			dw		X1089
			lda		PHYS$UNIT
			ani		00CH
			cpi		008H
			jz		L031E
			lda		X1024
			lxi		h,tstssds
			ora		a
			jz		L030B
			lxi		h,hdzero
			dcr		a
			jz		L030B
			lxi		h,hdone
			dcr		a
			jz		L030B
			lxi		h,ssonly
L030B:		call	outmsg$hl
			lxi		h,trk0ss
			lda		X1030
			ora		a
			jz		L031B
			lxi		h,trk0all
L031B:		call	outmsg$hl
L031E:		call	outmsg
			dw		menu1
			lhld	X102B
			xchg
			lhld	X1029
			mov		a,d
			cmp		h
			jc		L0356
			jnz		L0337
			mov		a,e
			cmp		l
			jc		L0356
L0337:		call	conin
L033A:		cpi		CR
			jz		exit
			sui		030H
			jc		L034E
			cpi		005H
			jnc		L034E
			sta		X102D
			ora		a
			ret
;
L034E:		call	outmsg
			dw		badopt
			jmp		L0298
;
L0356:		call	outmsg
			dw		badtrk
			xra		a
			ret
;
L035D:		call	outmsg
			dw		menu2
			call	conin
			cpi		'0'			;030H
			jz		L034E
			cpi		'2'			;032H
			jz		L034E
			cpi		'3'			;033H
			jz		L034E
			jmp		L033A
;
L0377:		call	outmsg
			dw		trkhlp
			call	outmsg
			dw		cyllo
			call	getnum
			jz		L038A
			shld	X1029
L038A:		call	outmsg
			dw		cylhi
			call	getnum
			jz		L0398
			shld	X102B
L0398:		lda		PHYS$UNIT
			ani		00CH
			cpi		008H
			jz		L03D4
			call	outmsg
			dw		menu3
			call	conin
			cpi		'Z'			;05AH
			jz		L03C3
			cpi		'z'			;07AH
			jz		L03C3
			sui		'0'			;030H
			jc		L03D0
			cpi		004H
			jc		L03BF
			xra		a
L03BF:		sta		X1024
			ret
;
L03C3:		lda		X1030
			ora		a
			mvi		a,0FFH
			jz		L03CD
			xra		a
L03CD:		sta		X1030
L03D0:		lda		X1024
			ret
;
L03D4:		call	outmsg
			dw		optsyst
			lxi		h,X1068
			call	L03F2
			call	outmsg
			dw		optdirs
			lxi		h,X106A
			call	L03F2
			call	outmsg
			dw		optdata
			lxi		h,X106B
L03F2:		mov		a,m
			adi		030H
			cpi		03AH
			jc		L03FC
			adi		007H
L03FC:		sta		X1007
			push	h
			call	outmsg
			dw		optskew
			call	conin
			pop		h
			sui		'0'			;030H
			rm
			rz
			cpi		10			;00AH
			jm		L0422
			sui		17			;011H
			rm
			cpi		6			;006H
			jc		L0420
			sui		32			;020H
			rm
			cpi		6			;006H
			rnc
L0420:		adi		10			;00AH
L0422:		mov		m,a
			ret
;
L0424:		mvi		a,0FFH
			sta		X102F
L0429:		lxi		h,L0440
			push	h
			lda		X102F
			inr		a
			rnz
			lda		PHYS$UNIT
			ani		00CH
			jz		L0561
			cpi		004H
			jz		L0561
			ret
;
L0440:		lda		X102E
			ani		001H
			jz		L0458
			call	outmsg
			dw		warning
			call	conin		;Get byte from console, check for CTRL-C
			cpi		'Y'
			jz		L0458
			cpi		'y'
			rnz
L0458:		lda		PHYS$UNIT		;
			cpi		01CH		;Is PHYSICAL unit RAMDISK?
			jz		dmd			;Define Memory Disk
			cpi		018H
			jnc		L0492
			lda		X1024
			ora		a
			jnz		L0492
			lda		X102E
			ani		001H
			ori		010H
			sta		X0485
			lhld	X1029
			shld	X0481
			call	cmdlist
			db		006H
			db		oc$trak		;00AH
X0481:		dw		000H		;P1=track lo, P2=track hi
X0483:		db		oc$fmtf		;003H
			db		000H		;P1=Format code
X0485:		db		000H		;P2=Format mode
			call	inchar
			ora		a
			jnz		L0492
			call	outmsg
			dw		schkbad
;
L0492:		mvi		a,LF
			call	conout

			mvi		a,oc$recd	;00BH
			call	sendcmd

			lda		X1068
			call	sendcmd

			lda		X102E
			mov		b,a
			lda		X1024
			rlc
			rlc
			ora		b
			sta		X0525
			lda		X102F
			sta		X0524
			mvi		a,040H
			sta		X1034
			lhld	X1029
			mov		a,h
			ora		l
			jnz		L04CC
			lda		X1030
			ora		a
			jnz		L04CC
			sta		X0524
L04CC:		shld	X0521
			lda		X1034
			dcr		a
			sta		X1034
			jnz		L04E9
			lda		PHYS$UNIT
			cpi		018H
			jc		L04E9
			lda		X0525
			ani		0FBH
			sta		X0525
L04E9:		lda		X1067
			dcr		a
			jm		L0501
			sta		X1067
			jnz		L0519

			mvi		a,oc$recd	;00BH
			call	sendcmd
			lda		X106A
			call	sendcmd

L0501:		lda		X1069
			dcr		a
			jm		L0519
			sta		X1069
			jnz		L0519

			mvi		a,oc$recd	;00BH
			call	sendcmd
			lda		X106B
			call	sendcmd

L0519:		call	setreta
			call	cmdlist
			db		007H
			db		oc$trak		;00AH
X0521:		dw		0000H
			db		oc$fmtf		;003H
X0524:		db		000H
X0525:		db		000H
X0526:		db		oc$gens		;016H
			lhld	X0521
			call	showtrk
			call	inchar
			call	ckerr
			lda		X102F
			sta		X0524
			lhld	X102B
			xchg
			lhld	X0521
			inx		h
			mov		a,d
			cmp		h
			jc		L054E
			jnz		L04CC
			mov		a,e
			cmp		l
			jnc		L04CC
L054E:		call	outmsg
			dw		again
			call	conin
			cpi		059H
			jz		L0429
			cpi		079H
			jz		L0429
			ret
;
L0561:		xra		a
			sta		X102F
			call	outmsg
			dw		hdr1
			call	cmdlist
			db		004H
			db		oc$fmtf		;003H
			db		0FFH
			db		020H
			db		oc$gens		;016H
			lxi		h,X1089
			shld	X1032
			call	getdat
			mov		a,c
			sta		X1031
L057F:		call	L05F3
			jm		L05C8
			lxi		h,hdr3
			ani		040H
			jnz		L0590
			lxi		h,hdr2
L0590:		call	outmsg$hl
			mvi		a,020H
			sta		X0EA5
			sta		X0EB0
			call	L05F3
			call	L05E6
			xchg
			lxi		h,X0EA8
			call	outnum16
			call	L05F3
			mov		e,a
			mvi		d,000H
			lxi		h,X0EB1
			call	outnum16
			lda		X102F
			inr		a
			sta		X102F
			adi		040H
			sta		X0EBB
			call	outmsg
			dw		hdr4
			jmp		L057F
;
L05C8:		call	outmsg
			dw		fmtcode
			call	conin
			ori		020H
			sui		061H
			jc		L05E0
			lxi		h,X102F
			cmp		m
			jnc		L05E0
			mov		m,a
			ret

;
; Entry: <A> = Format code
;  0 = 128 byte sectors
;  1 = 256 byte sectors
;  2 = 512 byte sectors
;  3 = 1024 byte sectors
; Exit:  <HL> = Sector size
L05E0:		call	outmsg
			dw		badcode
			pop		h
L05E6:		lxi		h,00080H	;<HL> = 80H  (128)
			ora		a
			rz
			dad		h			;<HL> = 100H (256)
			dcr		a
			rz
			dad		h			;<HL> = 200H (512)
			dcr		a
			rz
			dad		h			;<HL> = 400H (1024)
			ret
;
L05F3:		lxi		h,X1031
			dcr		m
			rm
			lhld	X1032
			mov		a,m
			inx		h
			shld	X1032
			ret
;
;********************************************
;	SUBROUTINE TO Define Memory Disk		*
;********************************************
;
dmd:		mvi		a,oc$dfmd	;012H
			call	sendcmd
			mvi		c,018H		;12 words
			lxi		h,cmdbuf
dmd1:		mov		a,m
			call	sendcmd
			inx		h
			dcr		c
			jnz		dmd1
			mvi		a,0FFH		;Format flag
			jmp		sendcmd
;
;********************************************
;	SUBROUTINE TO CHECK DISK I/O ERRORS		*
;********************************************
ckerr:		ora		a
			rz
			call	cmdlist
			db		001H
			db		oc$exts		;017H
			call	outmsg
			dw		dskioer
; Read and display next 9 bytes
			mvi		b,9
ckerr1:		mvi		a,' '
			call	conout
			call	inchar		;Get data byte from OMNIDISK
			call	hexout
			dcr		b
			jnz		ckerr1
; Ask if IGNORE or RETRY or ABORT operation
			call	outmsg
			dw		errwhat
			call	conin		;Get byte from console, check for CTRL-C
			push	psw
			mvi		a,LF
			call	conout
			pop		psw
			cpi		CR			;IGNORE error
			rz
			pop		h			;Clean stack
;
retry$address:	equ $+1
			jmp		$-$			;Jump to retry-address

;
;********************************************
;	SUBROUTINE TO DISPLAY HEX NUMBER		*
;********************************************
hexout:		push	psw
			rar
			rar
			rar
			rar
			call	hexout1
			pop		psw
hexout1:	ani		00FH
			sui		00AH
			jm		hexout2
			adi		007H
hexout2:	adi		03AH
			jmp		conout
;
;********************************************
;	SUBROUTINE TO SET RETRY ADDRESS			*
;********************************************
setreta:	xthl
			shld	retry$address
			xthl
			ret
;
;********************************************
;	SUBROUTINE TO REBOOT SYSTEM				*
;********************************************
exit:		call	outmsg
			dw		sysdisk
			call	conin		;Get byte from console, check for CTRL-C
			cpi		CR			;User pressed CR?
			jnz		exit		;NO, KEEP WAITING
			jmp		WBOOT
;
;********************************************
;	SUBROUTINE TO DISPLAY MESSAGE			*
;	ADDRESSED AFTER CALL					*
;********************************************
outmsg:		xthl
			push	d
			push	b
			push	psw
			mvi		c,009H
			mov		e,m
			inx		h
			mov		d,m
			inx		h
			push	h
			call	BDOS
			pop		h
			pop		psw
			pop		b
			pop		d
			xthl
			ret
;
;********************************************
;	SUBROUTINE TO DISPLAY MESSAGE 			*
;	ADDRESSED BY <HL>						*
;********************************************
outmsg$hl:	shld	addr$msg
			call	outmsg
addr$msg:	dw		0000
			ret
;
;********************************************
;	SUBROUTINE TO GET BYTE FROM CONSOLE		*
;	CTRL-C CHECK DONE HERE					*
;********************************************
conin:		push	b
			push	d
			push	h
			mvi		c,001H
			call	BDOS
			cpi		003H		;CTRL-C?
			jz		WBOOT		;YES, ABORT
			pop		h
			pop		d
			pop		b
			ret
;
;********************************************
;	SUBROUTINE TO INPUT DECIMAL NUMBER		*
;	RETURNS:	<A>=1, <HL> = NUMBER		*
;	BAD NUMBER:	<A>=0						*
;********************************************
getnum:		call	conin
			sui		030H
			jc		badnum
			cpi		00AH
			jnc		badnum
			mov		l,a
			mvi		h,000H
numloop:	call	conin
			sui		030H
			jc		numok
			cpi		00AH
			jnc		numok
			mov		d,h
			mov		e,l
			dad		h
			dad		h
			dad		d
			dad		h
			mvi		d,000H
			mov		e,a
			dad		d
			jmp		numloop
numok:		ori		001H
			ret
badnum:		xra		a
			ret
;
conout:		push	psw
			push	b
			push	d
			push	h
			mov		e,a
			mvi		c,002H
			call	BDOS
			pop		h
			pop		d
			pop		b
			pop		psw
			ret
;
;********************************************
;	SUBROUTINE TO DISPLAY TRACK NUMBER		*
;********************************************
showtrk:	xchg
			lxi		h,X0F15
			call	outnum
			mvi		m,024H
			call	outmsg
			dw		tnum
			ret
;
;********************************************
;	SUBROUTINE TO ISSUE COMMAND LIST		*
;********************************************
cmdlist:	xthl
			mov		c,m			;FETCH LENGTH OF LIST
			inx		h
cmdlist1:	in		OMNISTAT
			ani		omni$out
			jnz		cmdlist1
			mov		a,m			;NEXT BYTE TO SEND
			inx		h
			out		OMNIDATA	;BYTE TO CONTROLLER
			dcr		c
			jnz		cmdlist1	;IF MORE COMMANDS TO SEND
			xthl
			ret
;
;********************************************************
;	SUBROUTINE TO SEND COMMAND TO DISK CONTROLLER		*
;********************************************************
sendcmd:	push	psw			;BYTE TO SEND TO OMNI
sendcmd1:	in		OMNISTAT
			ani		omni$out
			jnz		sendcmd1	;IF OMNI NOT READY TO TAKE BYTE
			pop		psw
			out		OMNIDATA	;SEND BYTE TO OMNI
			ret
;
;************************************************************
;	SUBROUTINE TO ACCEPT ONE BYTE FROM DISK CONTROLLER		*
;************************************************************
inchar:		in		OMNISTAT
			ani		omni$in
			jz		inchar		;IF OMNI HAS NOT YET SENT REPLY
			in		OMNIDATA	;ACCEPT REPLY
			ret
;
;********************************************************
;	SUBROUTINE FOR BLOCK READ							*
;														*
;	NOTE:	THIS SUBROUTINE READS DATA UNTIL			*
;			THE OMNI CONTROLLER ACCEPTS THE				*
;			GENERAL STATUS COMMAND						*
;	RETURNS: <C> Number of BYTES in record				*
;********************************************************
getdat:		mvi		c,000H		;<C> = byte count 0
getdat1:	in		OMNISTAT
			rrc					;Rotate right to test bit 0
			jnc		getdat1		;IF NOTHING TO GET FROM OMNI
			ani		040H		;(WHAT DO WE HAVE HERE: DATA -OR- GEN STATUS?)
			in		OMNIDATA	;TAKE IT, WHATEVER IT IS
			rz					;IF IT IS GENERAL STATUS, THEN RETURN
			mov		m,a			;ELSE...PUT INTO BUFFER
			inx		h
			inr		c			;Count byte read
			jmp		getdat1		;KEEP ON KEEPING ON
;
L0731:
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			call	cvtnum16
			mov		a,e
			sub		c
			mov		a,d
			sbb		b
			cmc
			ret
;
cvtnum16:	xra		a
			mov		a,l
			ral
			mov		l,a
			mov		a,h
			ral
			mov		h,a
			mov		a,e
			ral
			mov		e,a
			mov		a,d
			ral
			mov		d,a
			mov		a,e
			jc		cvtnum16a
			sub		c
			mov		a,d
			sbb		b
			rc
			mov		d,a
			mov		a,e
			sub		c
			mov		e,a
			inr		l
			ret
;
cvtnum16a:	sub		c
			mov		e,a
			mov		a,d
			sbb		b
			mov		d,a
			inr		l
			rc
			pop		psw
			stc
			ret
;
cvtnum8:	mvi		d,010H
cvtnum8a:	xra		a
			mov		a,l
			ral
			mov		l,a
			mov		a,h
			ral
			mov		h,a
			mov		a,e
			ral
			mov		e,a
			jc		cvtnum8d
			sub		c
			jc		cvtnum8c
cvtnum8b:	mov		e,a
			inr		l
cvtnum8c:	dcr		d
			jnz		cvtnum8a
			mov		a,e
			sub		c
			cmc
			ret
;
cvtnum8d:	sub		c
			jc		cvtnum8b
			cmc
			ret
;
outnum:		mvi		c,00AH
outnum1:	push	h
			xchg
			mvi		e,000H
			call	cvtnum8
			xchg
			xthl
			mov		a,d
			ora		e
			cnz		outnum1
			pop		d
			mov		a,e
			adi		030H
			mov		m,a
			inx		h
			ret
;
outnum16:	mvi		c,00AH
			push	h
			xchg
L07CA:		mvi		e,000H
			call	cvtnum8
			xthl
			mov		a,e
			adi		030H
			mov		m,a
			dcx		h
			xthl
			mov		a,h
			ora		l
			jnz		L07CA
			pop		h
			ret
;
signon:		db	CR,LF,'FULCRUM format routine vers 1.3 for OMNIDISK'
			db	CR,LF,'W/W Component Supply '
			db	CR,LF,'San Jose Ca. 95112'
			db	CR,LF,'408-295-7171'
			db	CR,LF,24h

inch8:		db	'8 INCH FLOPPY',24h
inch5:		db	'5.25 INCH FLOPPY',24h
hdisk:		db	'HARD DISK',24h
mdisk:		db	'MEMORY DISK',24h
cunit:		db	' UNIT '
X0882:		db	'x'
			db	24h
askdev:		db	CR,LF,LF,'ENTER UNIT (A to P)  ==> ',24h
badun:		db	LF,CR,LF,'**INVALID UNIT LETTER**',24h
nophy:		db	LF,CR,LF,'**UNIT GIVEN HAS NO CORRESPONDING PHYSICAL DEVICE**',24h
nomdf:		db	LF,CR,LF,'**MEMORY DISK NEEDS TO BE DEFINED IN BIOS**',24h
asktrk:		db	LF,CR,LF,'TRACKS TO FORMAT/VERIFY ON ',24h
chtrng:		db	CR,LF,'CHANGE TRACK RANGE FOR ',24h
to:			db	' to ',24h
sep:		db	': ',24h

menu1:		db	LF,CR,LF,'CHANGE TRACK NUMBER RANGE . . 0'
			db	CR,LF,'FORMAT ONLY . . . . . . . . . 1'
			db	CR,LF,'VERIFY ONLY . . . . . . . . . 2'
			db	CR,LF,'FORMAT AND VERIFY . . . . . . 3'
			db	CR,LF,'CHANGE UNIT . . . . . . . . . 4'
			db	CR,LF,'EXIT BACK TO SYSTEM . . . . . cr  ==> ',24h

menu2:		db	LF,CR,LF,'FORMAT MEMORY DISK. . . . . . 1'
			db	CR,LF,'CHANGE UNIT . . . . . . . . . 4'
			db	CR,LF,'EXIT BACK TO SYSTEM . . . . . cr  ==> ',24h

badopt:		db	LF,CR,LF,'**ILLEGAL OPTION**',24h
badtrk:		db	LF,CR,LF,'**MAXIMUM TRACK CAN NOT BE LESS THAN MINIMUM TRACK**',24h
sysdisk:	db	CR,LF,'ASSURE SYSTEM DISK IN A:, PRESS cr  ==> ',24h

menu3:		db	LF,CR,LF,'  SPECIAL FLOPPY DISK PARAMETER ADJUSTMENT'
			db	CR,LF
			db	CR,LF,'0 -- TEST DRIVE FOR SINGLE/DOUBLE SIDED (DEFAULT)'
			db	CR,LF,'1 -- FORMAT/VERIFY FIRST HEAD ONLY'
			db	CR,LF,'2 -- DRIVE IS DOUBLE SIDED, FMT/VERIFY SECOND HEAD ONLY'
			db	CR,LF,'3 -- DRIVE IS DOUBLE SIDED, BUT FORMAT AS SINGLE '
			db	'(FIVE INCH FLOPPY ONLY)'
			db	CR,LF,'Z -- CHANGE TRACK ZERO TREATMENT  ==> ',24h

tstssds:	db	CR,LF,'TEST DRIVE FOR SINGLE/DOUBLE SIDED',24h
hdzero:		db	CR,LF,'FORMAT/VERIFY FIRST HEAD ONLY',24h
hdone:		db	CR,LF,'DRIVE IS DOUBLE SIDED, FMT/VERIFY SECOND HEAD ONLY',24h
ssonly:		db	CR,LF,'DRIVE IS DOUBLE SIDED, BUT FORMAT AS SINGLE',24h
trk0ss:		db	CR,LF,'TRACK ZERO FORMATTED/CHECKED AS SINGLE DENSITY',24h
trk0all:	db	CR,LF,'TRACK ZERO TREATED THE SAME AS THE REST OF THE DISK',24h
trkhlp:		db	LF,CR,LF
			db	'TRACK NUMBER ENDS WITH ANY NON-NUMERIC CHARACTER'
			db	CR,LF,'TRACK NOT CHANGED IF FIRST CHARACTER IS NOT NUMERIC'
			db	LF,24h
cyllo:		db	CR,LF,'ENTER LOW CYLINDER NUMBER  ==> ',24h
cylhi:		db	CR,LF,'ENTER HIGH CYLINDER NUMBER  ==> ',24h
fmtcode:	db	'  ENTER FORMAT CODE  ==> ',24h
hdr1:		db	LF,CR,LF
			db	'         SECTOR  NUMBER OF  FORMAT'
			db	CR,LF,'DENSITY  LENGTH   SECTORS    CODE'
			db	CR,LF,'-------  ------   -------   ------',24h
hdr2:		db	CR,LF,' SINGLE',24h
hdr3:		db	CR,LF,' DOUBLE',24h
hdr4:		db	'   '
X0EA5:		db	'1024'
X0EA8:		db	'       '
X0EB0:		db	'X'
X0EB1:		db	'X'
			db	'         '
X0EBB:		db	'J'
			db	24h
badcode:	db	LF,CR,LF,'**INVALID FORMAT NUMBER**',24h
warning:	db	CR,LF,'FORMAT ERASES ALL FILES ON DEVICE "Y" IF OK  ==> ',24h
tnum:		db	CR,'TRACK '
X0F15:		db	'.....'
			db	24h
again:		db	CR,LF,'ENTER "Y" FOR SAME OPERATION ON SAME DRIVE  ==> ',24h
schkbad:	db	CR,LF,'NUMBER-OF-SIDES CHECK FAILED---GOING ON ANYWAY',24h
dskioer:	db	CR,LF,'DISK I/O ERROR -',24h
errwhat:	db	CR,LF,'^C ABORT, cr IGNORE, ELSE RETRY',24h
optsyst:	db	CR,LF,'CHANGE SYSTEM TRACK',24h
optdirs:	db	CR,LF,'CHANGE DIRECTORY',24h
optdata:	db	CR,LF,'CHANGE DATA',24h
optskew:	db	' SKEW FACTOR (CURRENT VALUE '
X1007:		db	'X'
			db	') ENTER IN HEX ==> ',24h
;
std5:		db	000H
			db	000H
			db	027H
			db	000H
std8:		db	000H
			db	000H
			db	04CH
			db	000H
X1024:
			db	000H
DRIVE:
			db	000H
PHYS$UNIT:
			db	000H
dev$label:
			db	000H
			db	000H
X1029:
			db	000H
			db	000H
X102B:
			db	000H
			db	000H
X102D:
			db	000H
X102E:
			db	000H
X102F:
			db	000H
X1030:
			db	000H
X1031:
			db	000H
X1032:
			db	000H
			db	000H
X1034:		db	000H
dens$tbl:	db	000H
cmdbuf:
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
X103E:		db	000H
;
			db 0,0,0,0,0,0,0
			db 0,0,0,0,0,0,0
			db 0,0,0,0,0,0,0
			db 0,0,0,0
;
X1058:
			db	000H
X1059:
			db	000H
X105A:
			db	000H
			db	000H
phys$dev$tbl:
			db	000H
X105D:
			db	000H
			db	000H
X105F:
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
			db	000H
X1065:
			db	000H
			db	000H
X1067:
			db	000H
X1068:
			db	000H
X1069:
			db	000H
X106A:
			db	000H
X106B:
			db	000H
buff0:		;0106C
			db	0,0,0,0
			db	0,0,0,0
			db	0,0,0,0
			db	0
			0
device$tbl:		db	0,0,0,0,0,0,0
			db	0,0,0,0,0,0,0
			db	0
			org		1088h
phy$dev$tbl	db	0
X1089:		db	0
			ds	15		;Physical unit # 0 - 15
			ds	15		;ASCII drive letter A - P
			db	0
;
	IF SAFMT
			ds	80H
BDOS:		MOV		A,C
			CPI		1
			JZ		CINP
			CPI		2
			JZ		COUT
			XCHG
OMSG:		MOV		A,M
			CPI		'$'			;check for terminating character.
			RZ
			INX		H
			MOV		E,A
			CALL	COUT		;otherwise, bump pointer and print it.
			JMP		OMSG

CINP:		IN   	SERCTLA		;SERIAL PORT CONTROL PORT
			ANI  	SERRX
			JZ		CINP		;No data
			IN   	SERDATA
			ANI		7FH			;STRIP BIT 8
			MOV		E,A

COUT:		IN		SERCTLA		;SERIAL PORT CONTROL PORT
			ANI		SERTX
			JZ		COUT
			MOV		A,E
			OUT		SERDATA
			RET
	ENDIF
			END	TPA
