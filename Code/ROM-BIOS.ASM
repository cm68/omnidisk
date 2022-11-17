	;TITLE	"2K ROM BIOS"
	;PAGE 0
;
;	SYSTEM VARIABLE DEFINITIONS
;

FALSE	EQU	0
TRUE	EQU	NOT FALSE
TESTING	EQU	TRUE
ISIO2	EQU	FALSE	;IMSAI SIO-2
CSS1	EQU	TRUE	;COMPUPRO SYSTEM SUPPORT 1

MSIZE	EQU	60		;<== MEMORY SIZE IN K-BYTES
;	"BIAS" IS ADDRESS OFFSET FROM 3400H FOR MEMORY SYSTEMS
;	OTHER THAN 16K (REFERRED TO AS "B" THROUGHOUT THE TEXT).

BIAS	EQU	(MSIZE-20)*1024 ;ADDR OFFSET FROM 3400H (20K SYSTEM)

CCP	EQU	3400H+BIAS		;BASE OF CCP 
BDOS	EQU	CCP+806H	;BASE OF BDOS 
BIOS	EQU	CCP+1600H	;BASE OF BIOS
LENBSTRAP	EQU	80H				;LENGTH RESERVED FOR BOOTSTRAP
BSORG		EQU	CCP-LENBSTRAP	;BOOTSTRAP ORGIN AS ASSEMBLED
								;NOTE: BOOTSTRAP IS LOADED INTO
								;      AND RUNS AT LOCATION 0000

; VARIOUS CONFIGURATION EQUATES FOR THE LIST  DEVICE -- MODIFY AS NEEDED
; SET ONLY ONE OF THE FOLLOWING EQUATES "TRUE" TO SELECT THE CPM LIST 
; DEVICE IF YOURE IO DEVICE IS NOT LISTED HERE THEN YOU MUST MODIFY THE 
; IO DRIVERS FOR YOUR IO DEVICE.
LST		EQU	FALSE	;<== SET TRUE FOR LIST DEVICE
LPST	EQU	00H		;<== LIST DEVICE STATUS PORT
LPDATA	EQU	00H		;<== LIST DEVICE DATA PORT
LPTxRDY	EQU	1h		;<== LPR TRANSMITTER READY (TxRDY)
LPRxRDY	EQU	2h		;<== LPR RECIEVER READY (RxRDY)

;
; VARIOUS CONFIGURATION EQUATES FOR THE PUNCH READER DEVICE - MODIFY AS NEEDED
; SET ONLY ONE OF THE FOLLOWING EQUATES "TRUE" TO SELECT THE CPM READER/PUNCH 
; DEVICE IF YOURE IO DEVICE IS NOT LISTED HERE THEN YOU MUST MODIFY THE 
; IO DRIVERS FOR YOURE IO DEVICE

RDRPUN	EQU	FALSE	;<== SET TRUE FOR READER/PUNCH ON RPDATA PORT
RPST	EQU	00H		;<== READER/PUNCH STATUS PORT
RPDATA	EQU	00H		;<== READER/PUNCH DATA PORT
RPTXR	EQU	1h		;<== READER/PUNCH TRANSMITTER READY (TxRDY)
RPRXR	EQU	2h		;<== READER/PUNCH RECIEVER READY (RxRDY)

TPA		EQU	100H	;START OF TRANSIENT PGM AREA
NDISKS	EQU	2		;NUMBER OF DISK DRIVES
FDISK8	EQU	10H		;OMNI DEV TYPE FOR 8" FLOPPY
FDISK5	EQU	14H		;OMNI DEV TYPE FOR 5" FLOPPY

;
; Use DMA or Programmed I/O disk access
;
DMA	EQU	FALSE		;<== TRUE IF DMA OPERATION FALSE FOR IO
;
;	IF "DMA EQU TRUE" THEN THE TOP 8 BITS OF THE 24-BIT ADDRESS
;	NEEDS TO BE SPECIFIED.  IF YOUR CPU DRIVES THE BUS WITH
;	ZEROS, THEN LEAVE THE FOLLOWING EQUATE ALONE.  IF YOUR CPU
;	DRIVES THE BUS WITH SOME STRANGE VALUE, THEN CHANGE THE
;	EQUATE TO MATCH.  IF YOUR CPU DOES NOT DRIVE THE TOP 8
;	ADDRESS BITS (SUCH AS THE W/W MPU-B) THEN A PROPERLY
;	TERMINATED BUS WILL HAVE 0FFH ON THESE BITS.  IF YOU ARE
;	NOT USING DMA OR YOUR MEMORY DOES NOT RESPOND TO EXTENDED
;	ADDRESSING THEN THIS VALUE DOES NOT MATTER.
;
;DMAEXT	EQU	0		;<== TOP 8 OF 24-BIT DMA ADDRESS
DMAEXT	EQU	0FFH
;
;	OMNIDISK DMA PRIORITY IS SET BY SOFTWARE, NOT BY A DIP SWITCH.
;
;	SELECT WHATEVER PRIORITY YOU DESIRE --
;	00H IS THE LOWEST, 0FH IS THE HIGHEST.
;
;	OMNIDISK RUNS WELL WITH THE LOWEST PRIORITY BECAUSE IT
;	IS NEVER DOING ANYTHING TIME-CRITICAL WHEN DMA IS USED.
;
;	THERE ARE ONLY THREE CASES WHERE THE OMNIDISK CONTROLLER USES
;	DMA.  (1) READ/WRITE OPERATIONS WHEN THE BIOS IS ASSEMBLED
;	WITH DMA=TRUE.  (2) ANY ACCESS TO THE MEMORY DISK, EVEN IF
;	THE BIOS IS ASSEMBLED WITH DMA=FALSE.  (3) THE OC$MOVM COMMAND
;	WHICH MOVES A BLOCK OF MEMORY USING DMA.  OC$MOVM IS NOT USED
;	BY THE BIOS OR ANY UTILITY FUNCTION PROVIDED BY W/W OR FULCRUM.
;
;	IF DMA IS BROKEN IN YOUR SYSTEM, AVOID THE ABOVE 3 CONDITIONS
;	AND ENJOY MOST OF THE OMNIDISK ADVANTAGES.
;
DMAPRI   EQU	0Fh		;<== DMA PRIORITY
;

; MEMORY MAP
	IF TESTING
ROMPTR	EQU	08000H	;TOP OF 32K
RAMPTR	EQU	09000H	;ADDR OF RAM
	ENDIF
	IF NOT TESTING
ROMPTR	EQU	0F800H	;FIRMWARE LOCATION
RAMPTR	EQU	0F000H	;ADDR OF RAM
	ENDIF

ROMTOP	EQU	0800H	;ROM SIZE 2K


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
CSTOP1	equ	06E00h		;8N1 x16
CSTOP2	equ	0EE00h		;8N2 x16
CTL2651	equ	27h			;Ctrl reg initialization value
;Console Port 2651 baud rates
;(The high byte of these words gets written first)
CBD110	equ	CSTOP2 or 72h	;110 baud (2 stop bits)
CBD150	equ	CSTOP1 or 74h	;150 baud
CBD300	equ	CSTOP1 or 75h	;300 baud
CBD600	equ	CSTOP1 or 76h	;600 baud
CBD1200	equ	CSTOP1 or 77h	;1200 baud
CBD2400	equ	CSTOP1 or 7Ah	;2400 baud
CBD4800	equ	CSTOP1 or 7Ch	;4800 baud
CBD9600	equ	CSTOP1 or 7Eh	;9600 baud
CBD192	equ	CSTOP1 or 7Fh	;19200 baud
CBD384	equ	0		;38400 baud (Not supported)
CBD576	equ	0 		;57600 baud (not supported)
CBD768	equ	0		;76800 baud (Not supported)

CPBAUD	equ	CBD9600		;Console port baud rate
 ENDIF	;CSS1

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
OC$TIOR	EQU	20		;DEBUG READS FROM OMNI
OC$TIOW	EQU	21		;DEBUG WRITES TO OMNI
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
OC$INIT	EQU	255		;Re-Initialize Omnidisk Controller

OMNIDATA EQU	0A0H		;<== DATA PORT FOR OMNI CONTROLLER
OMNISTAT EQU	OMNIDATA+1	;STATUS PORT FOR OMNI
INREADY  EQU	01H		;** OMNI HAS DATA TO SEND
OUTREADY EQU	80H		;** OMNI CAN NOT ACCEPT ANOTHER BYTE NOW

;*********************************************
;	DISK SYSTEM EQUATES (change with care if you wish to save space)

ALV5	EQU	38		;MAX ALLOCATION VECTOR LENGTH FOR 5" FLOPPY
ALV8	EQU	75		;MAX ALLOCATION VECTOR LENGTH FOR 8" FLOPPY
ALVHD	EQU	2000/8	;ALLOCATION VECTOR LENGTH FOR HARD DISK

CKV5	EQU	48		;5" FD CHECK VECTOR LENGTH (128 FILES)
CKV8	EQU	32		;8" FD CHECK VECTOR LENGTH (128 FILES)
CKVHD	EQU	0		;HARD DISK CHECK VECTOR NOT USED
CKVMD	EQU	0		;MEMORY DISK CHECK VECTOR NOT USED

FDISK8	EQU	10H		;OMNI DEV TYPE FOR 8" FLOPPY
FDISK5	EQU	14H		;OMNI DEV TYPE FOR 5" FLOPPY
HDISK	EQU	18H		;OMNI DEV TYPE FOR HARD DISK
MDISK	EQU	1CH		;OMNI DEV TYPE FOR MEMORY DISK

; --------- FLOPPY DISK LOGICAL UNITS


ALV$A	EQU	ALV8		;<== SET A: FOR 8"          
CKV$A	EQU	CKV8		;<== SET A: FOR 8"          
DEV$A	EQU	FDISK8+0	;<== SET A: FOR 8" UNIT 0   
ALV$B	EQU	ALV8		;<== SET A: FOR 8"          
CKV$B	EQU	CKV8		;<== SET A: FOR 8"          
DEV$B	EQU	FDISK8+1	;<== SET A: FOR 8" UNIT 1  
;
;
;*******************************************************************
;
;	SYSTEM RAM ALLOCATION
;
;*******************************************************************
;
;;	ORG	RAMPTR+(800H-VARSIZE)
	ORG	RAMPTR

;
;********************************************************
;	 SCRATCH RAM AREA FOR BIOS USE		*
;********************************************************

DMAADR	DS	2
RETRY$ADDRESS
		DS	2	;RETRY ADDRESS
CWFLAG:	DS	1	;COLD/WARM BOOT FLAG
AUTOFLG:
		DS	1	;AUTOBOOT COMMAND FLAG

DPHADRS	DS	2
DPHBASE	DS	16*2

TDPB$A	DS	15
TCKV$A	DS	CKV$A
TALV$A	DS	ALV$A

TDPB$B	DS	15
TCKV$B	DS	CKV$B
TALV$B	DS	ALV$B

DIRBUF	DS	128		;DIRECTORY BUFFER

		DS	80		;SPACE FOR 40 LEVELS OF STACK
STACK	EQU	$		;Stack grows down

;*******************************************************
;	END OF SCRATCH RAM
;*******************************************************

IOBYTE	EQU	0003H		;INTEL I/O BYTE
CDISK	EQU	0004H		;CURRENT CPM DISK BUFFER (CONTENTS 0=A,..,15=P)


;************************************************
;ENTRY HERE IS ON POWER UP OR SYSTEM RESET
;************************************************

	ORG ROMPTR
CBOOTE:
	JMP	CBOOT		;COLD START
WBOOTE:
	JMP	WBOOT		;WARM START
	JMP	IOCONST		;CONSOLE STATUS
	JMP	IOCONIN		;CONSOLE CHAR IN
	JMP	IOCONOUT	;CONSOLE CHAR OUT
	JMP	IOLIST		;LIST CHAR OUT
	JMP	IOPUNCH		;PUNCH CHAR OUT
	JMP	IOREADER	;READER CHAR OUT
	JMP	HOME		;MOVE HEAD TO HOME POSITION
	JMP	SELDSK		;SELECT DISK
	JMP	SETTRK		;SET TRK #
	JMP	SETSEC		;SET SECT #
	JMP	SETDMA		;SET DMA ADDR
	JMP	READ		;READ DISK
	JMP	WRITE		;WRITE DISK
	JMP	IOLISTST	;RETURN LIST STATUS
	MOV H,B 		;SECTRAN. REPLACE 3-BYTE JMP WITH 3-BYTE ROUTINE
 	MOV L,C 
	RET

;	CONSOLE STATUS - CON:
IOCONST:
	CALL	DISPATCH
	DB	1		;USE IOBYTE BITS 1-0
	DB	CRTSTAT-$	;00 - TTY: (CRT STATUS)
	DB	CRTSTAT-$	;01 - CRT:	"
	DB	CRTSTAT-$	;10 - BAT:	"
	DB	CRTSTAT-$	;11 - UC1:	"

;	CONSOLE IN - CON:
IOCONIN:
	CALL	DISPATCH
	DB	1		;USE IOBYTE BITS 1-0
	DB	CRTIN-$		;00 - TTY: (CRT INPUT)
	DB	CRTIN-$		;01 - CRT:	"
	DB	CRTIN-$		;10 - BAT:	"
	DB	CRTIN-$		;11 - UC1:	"

;	CONSOLE OUT - CON:
IOCONOUT:
	CALL	DISPATCH
	DB	1		;USE IOBYTE BITS 1-0
	DB	CRTOUT-$	;00 - TTY: (CRT OUTPUT)
	DB	CRTOUT-$	;01 - CRT:	"
	DB	CRTOUT-$	;10 - BAT:	"
	DB	CRTOUT-$	;11 - UC1:	"

;	LIST OUT - LST:
IOLIST:
	CALL DISPATCH
	DB	3		;USE IOBYTE BITS 7-6
	DB	CRTOUT-$	;00 - TTY: (CRT OUTPUT)
	DB	CRTOUT-$	;01 - CRT:	"
	DB	LPTOUT-$	;10 - LPT: (LINE PRINTER OUTPUT)
	DB	CRTOUT-$	;11 - UL1: (CRTSOLE OUTPUT)

;	LIST STATUS -LST:
IOLISTST:
	CALL DISPATCH
	DB	3		;USE IOBYTE BITS 7-6
	DB	CRTSTAT-$	;00 - TTY: (CRT OUTPUT)
	DB	CRTSTAT-$	;01 - CRT:	"
	DB	LPTSTAT-$	;10 - LPT: (LINE PRINTER OUTPUT)
	DB	CRTSTAT-$	;11 - UL1: (CRTSOLE OUTPUT)

;	PUNCH OUT - PUN:
IOPUNCH:
	CALL	DISPATCH
	DB	5		;USE IOBYTE BITS 5-4
	DB 	CRTOUT-$	;00 - TTY: (CRTSOLE OUTPUT)
	DB	PUNOUT-$	;01 - PTP: (HIGH SPEED PUNCH OUTPUT)
	DB	CRTOUT-$	;10 - UP1: (CRTSOLE OUTPUT)
	DB	CRTOUT-$	;11 - UP2:	"

;	READER IN - RDR:
IOREADER:
	CALL	DISPATCH
	DB	7		;USE IOBYTE BITS 3-2
	DB	CRTIN-$		;00 - TTY: (CRT INPUT)
	DB	RDRIN-$		;01 - PTR: (HIGH SPEED READER INPUT)
	DB	CRTIN-$		;10 - UR1: (CRT INPUT)
	DB	CRTIN-$		;11 - UR2:	"

;********************************************************
;	LIST CHARACTER IN C				*
;********************************************************

LPTOUT:
	IF LST
	CALL	LPTSTAT		;GET PRINTER STATUS
	JZ		LPTOUT		;LOOP IF NOT READY

	IF ISIO2
	MOV		A,C			;NO
	OUT		SERDATB		;SEND IT
	ENDIF ;ISIO2
	ENDIF ;LST
	RET					;BYE

;********************************************************
;	RETURN LIST STATUS (FF IF READY, ELSE 0)	*
;********************************************************

LPTSTAT:
	IF LST
	IF ISIO2
	IN		SERCTLB		;GET SIO PORT B STATUS
	ANI		SERTX		;IS IT BUSY
	ENDIF ;ISIO2
	ENDIF ;LST

	IF NOT LST
 	XRA		A			;...THEN ALLWAYS READY
	ENDIF ;NOT LST

	DCR		A			;<A> AS ADVERTISED
	RET					;BYE

;********************************************************
;	CRT STATUS RETURNED IN A.			*
;							*
;	<A>=00	KEYBOARD CHARACTER NOT READY		*
;	<A>=FF  KEYBOARD CHARACTER READY		*
;********************************************************
CRTSTAT:
	IN		SERCTLA		;STATUS PORT
	ANI		SERRX		;TEST RxRDY
	RZ					;IF NOT READY
	MVI		A,0FFH		;ELSE...RETURN <FF>
	RET					;BYE

;********************************************************
;	CRTIN RETURNS KEYBOARD CHARACTER IN <A>		*
;********************************************************
CRTIN:
    CALL	CRTSTAT
	JZ		CRTIN		;GET RxRDY
    IN		SERDATA		;GET CHAR
	ANI	7FH				;STRIP PARITY
	RET					;BYE

;********************************************************
;	CRT SENDS THE CHARACTER IN <C> TO OUTPUT
;********************************************************

CRTOUT:
    IN  	SERCTLA		;GET STATUS
	ANI		SERRX		;TxRDY?
	JZ		CRTOUT		;REPEAT, NOT READY
	MOV		A,C			;CHAR TO ACCUM
    OUT 	SERDATA		;CHAR TO PORT
	RET

;********************************************************
;	PUNCH CHARACTER IN REGISTER <C>			*
;********************************************************

PUNOUT:
	IF RDRPUN
	IN		RPST
	ANI		RPTXR
	JZ		PUNOUT		;IF RECIEVER NOT READY FOR NEXT BYTE
	MOV		A,C
	OUT		RPDATA		;DATA TO "PUNCH"
	ENDIF ;RDRPUN

;	NOTE: IF RDRPUN=FALSE WE USE RET FROM RDRIN

;********************************************************
;	READ CHARACTER INTO <A> FROM READER DEVICE	*
;********************************************************

RDRIN:
	IF RDRPUN
	IN		RPST
	ANI		RPRXR
	JZ		RDRIN		;IF NO DATA FROM "READER" AS YET
	IN		RPDATA		;ACCEPT BYTE FROM READER
	ENDIF ;RDRPUN
	IF NOT RDRPUN
	MVI		A,1AH		;NO READER? RETURN ^Z AS EOF INDICATION
	ENDIF ;NOT RDRPUN
	RET					;BYE

;********************************************************
;	DISPATCH TO ACCESS CONSOLE, PRINTER PUNCH, ETC	*
;							*
;	(FOR MAX RANGE ON ONE-BYTE ADDRESSES IT IS	*
;	 BEST TO LEAVE THIS ROUTINE AFTER THE END	*
;	 OF THE LAST CRT, PRINTER, PUNCH OR WHATEVER	*
;	 ACCESS SUBROUTINE.)				*
;********************************************************

DISPATCH:
	XTHL			;SAVE CALLER'S <HL>, GET TABLE ADDR
	MOV		D,M		;SHIFT COUNT
	INX		H		;POINT TABLE
	LDA 	IOBYTE	;GET IO ASSIGNMENTS BYTE
DSHFT:
	RLC
	DCR		D
	JNZ		DSHFT	;SHIFT TO POSITION BITS
	RRC
	ANI		03H		;MASK BITS
	MOV		E,A		;D ALREADY CLEAR
	DAD		D		;INDEX INTO TABLE
	MOV		E,M		;FETCH PROPER ADDRESS BYTE
	DAD		D		;ADD BACK THE "-$" OR DISPATCH ADDRESS TO <HL>
	XTHL			;PUT DISPATCH ADDRESS, RESTORE CALLER'S <HL>
	RET				;GO TO ROUTINE

;----------------------------------------
; COLD BOOT
;----------------------------------------
cboot:
	LXI		H,0081H			;00 (A:) FOR CDISK, 81 FOR IOBYTE
	SHLD	IOBYTE			;IOBYTE IS LOC 3, CDISK IS LOC 4
	XRA		A				;A=0
	STA		CWFLAG			;CLEAR COLD BOOT FLAG
; COPY DPHBLOCK
	LXI		D,DPHBASE		;RAM
	LXI		H,ROM$DPHBASE	;ROM TABLE
	MVI		B,2*16			;SIZE OF TABLE
r$copy:
	MOV		A,M
	STAX	D
	INX		H
	INX		D
	DCR		B
	JNZ		r$copy
; CONFIGURE OMNIDOSK
	CALL	CMDLIST
	DB	CBLEND-$-1			;LENGTH OF LIST
	DB	OC$MODE				;OMNI COMMAND: SET DMA OR NON-DMA MODE
	IF NOT DMA
	DB	DMAPRI				;NOTE TO USERS WHERE DMA KILLS YOUR SYSTEM:
							;BIOS DOES NOT CAUSE ANY DMA
	ENDIF ;NOT DMA			;UNLESS MEMORY DISK IS USED.
	IF DMA
	DB	DMAPRI+80H			;BIOS USES DMA FOR READ/WRITE
	ENDIF ;DMA

;	DEFINE FLOPPY DISK PHYSICAL PARAMETERS
	DB	OC$SFDP				;OMNI COMMAND: SET FLOPPY DISK PARAMETERS
	DB		6			;Delay before write * 250ms
	DB		20			;Head unload time * 250ms
	DB		6			;8" FLOPPY STEP RATE IN ms
	DB		6			;5" FLOPPY STEP RATE IN ms
	DB		35			;8" FLOPPY HEAD LOAD TIME IN ms
	DB		0			;5" FLOPPY HEAD LOAD TIME IN ms
	DB		14			;8" FLOPPY HEAD SETTLE TIME (AFTER FD SEEK)
	DB		14			;5" FLOPPY HEAD SETTLE TIME (AFTER FD SEEK)
	;DRIVES 0-1 ( A: & B: )
	DB	OC$DLDS,00H,FDISK5+0	;DEFINE A:
	DB	OC$DLDS,01H,FDISK5+1	;DEFINE B:
CBLEND	EQU	$				;END OF LIST

;----------------------------------------
;Initialize the IMSAI sio-2 card
;----------------------------------------
	IF ISIO2
	xra	a			; Zero
	out	IECTL		; Disable SIO-2 interrupts
	out	SERCTLA		; Port A
	out	SERCTLA
	out	SERCTLA
	out	SERCTLB		; Port B
	out	SERCTLB
	out	SERCTLB
	mvi	a,40H		; Reset 8251
	out	SERCTLA		; Port A
	out	SERCTLB		; Port B
	mvi	a,4EH		; 8N1 /16
 	out	SERCTLA		; Port A
	out	SERCTLB		; Port B
	mvi	a,37H		; Clear ERRS, Enable Rx/Tx
 	out	SERCTLA		; Port B
	out	SERCTLB		; Port B
	in	SERDATA		; Clear junk
	in	SERDATB		; Clear junk
	ENDIF	;ISIO2

;----------------------------------------
;Initialize the Compupro System Support-1
;----------------------------------------
	IF CSS1
	in	CCTRL		;reset mode byte flipflop
;Set Console Stop bits, Parity, Baud rate factor
	mvi	a,CPBAUD shr 8
	out	CMODE		;
;Set Console baud rate
	mvi	a,CPBAUD and 0FFh
	out	CMODE		;
;Control reg initialization
	mvi	a,CTL2651	;Enable Tx, Rx, RTS=low, DTR=low
	out	CCTRL
	in	SERDATA		;Clear junk
	ENDIF ;CSS1

	ret				;RETURN TO CALLER


;********************************************************
;	DISK PARAMETER HEADER TABLES			*
;********************************************************
;
;	PLEASE NOTE SEVERAL THING ABOUT THIS TABLE:
;
;	    THE "DW DEV$x" IN PLACE OF THE SKEW TABLE ADDRESS
;	    IS CLEARLY NOT SKEW TABLE ADDRESS.  IT IS USED BY
;	    BY THE LU-CHANGING UTILITY AND PERHAPS SOMEDAY BY
;	    COLD START WITHIN THE BIOS.
ROM$DPHBASE:
	DW	DEV$A,0,0,0,DIRBUF
	DW	TDPB$A,TCKV$A,TALV$A
	DW	DEV$B,0,0,0,DIRBUF
	DW	TDPB$B,TCKV$B,TALV$B

;----------------------------------------
; WARM BOOT
;----------------------------------------

wboot0:
	sta		CDISK		;(FROM BIOS ERROR RECOVERY) SET FOR "A:" DISK
wboot:
	lxi		sp,TPA		;USE SPACE BELOW TPA FOR STACK
	call	cmdlist
	DB	5				;LENGTH OF LIST
	DB	OC$UNIT,0		;SELECT A: DISK
	DB	OC$BOOT
	DB	(BDOS-BSORG+127)/128;NUMBER OF (LOGICAL) SECTORS TO LOAD
	DB	OC$GENS				;GENERAL STATUS REQUEST FOR READ END
	call	inchar		;THIS IS EITHER 1ST OF BOOTSTRAP OR GENSTAT
	in		OMNISTAT
	ora		a			;WHAT DID INCHAR JUST DELIVER?
	jp		wboot		;IF WE GOT GENSTAT THEN ERROR.  GO RETRY.
	mvi		c,LENBSTRAP-1
wboot1:
	call	inchar		;READ AND TRASH BOOTSTRAP PART OF 1ST SECTOR
	dcr		c
	jnz		wboot1		;IF MORE BOOTSTRAP TO TRASH
	lxi		h,CCP		;Loading CCP + BDOS now
	call	getdat
	ora		a			;GENERAL STATUS
	jnz		wboot		;IF ERROR RELOADING CCP WE GO TRY AGAIN
	mvi		a,1
	sta		CWFLAG		;Set warm boot flag
						;FALL INTO GOCPM

;********************************************************
;	SET PARAMETERS AND GO TO CP/M			* 		
;********************************************************

gocpm:
	mvi		a,(JMP)
	sta		0			;JMP TO WBOOT
	lxi		h,WBOOTE	;WBOOT ENTRY POINT
	shld	1			;JUMP ADDR AT 0

	sta		5			;JMP TO BDOS
	lxi		h,BDOS		;BDOS ENTRY POINT
	shld	6			;JUMP ADDR AT 5

	lxi		b,80H		;** SETUP DEFAULT
	call	setdma		;** DMA ADDRESS

;	CLEAN UP AND GO TO CCP

	lda		CDISK		;CURRENT DISK #
	mov		c,a			;SEND TO CCP
	ei					;ENABLE INTERRUPTS

	lda		CWFLAG		;IS COLD OR WARM BOOT?
	ora		a			;SET FLAGS. NOTE:DO NOT DO ANYTHING TO CHANGE
						; FLAGS FROM HERE TO COLDBT:
	lda		AUTOFLG		;DO WE HAVE AN AUTOBOOT?
	jz		coldbt		;If Cold Boot
	rar					;Else warm boot tests
coldbt:
	rar
	jc		CCP			;DO AUTOBOOT
	jmp		CCP+3		;JUST GO TO CCP


;********************************************************
; 	ROUTINES START HERE				*
;********************************************************
;	DISK I/O DRIVERS. STORE	THE PARAMETERS		*
;	AWAY FOR THE READ AND WRITE SUBROUTINES		*
;********************************************************

;********************************************************
;	SELECT DISK GIVEN BY <C>			*
;********************************************************

seldsk:
	lxi		h,0		;USED FOR <H>=0 AND IF SELECT ERROR
	mov		a,c
	cpi		ndisks	;MUST BE BETWEEN 0 AND NDISKS-1
	rnc				;IF INVALID DISK NUMBER

;	COMPUTE PROPER DISK PARAMETER HEADER ADDR

	call	onelist
	db		oc$unit	;OMNI COMMAND: SELECT LOGICAL UNIT
	mov		a,c
	call	sendcmd	;...to OMNI
	mov		l,c		;<HL> = UNIT NUMBER (A:=0, B:=1,,, P:=0FH)
	dad		h		;*2
	dad		h		;*4
	dad		h		;*8
	dad		h		;*16 (SIZE OF EACH HEADER)
	lxi		b,DPHBASE
	dad		b		;<HL> = DPH ADDRESS
	mov		a,e
	rar
	rc				;IF DRIVE WAS LOGGED
;
;	DRIVE NEVER LOGGED -- CALL DRIVE SELECT
;
	shld	DPHADRS	;SAVE DPH ADDRESS IN CASE WE NEED TO RETRY
	call	sreta	;SET RETRY ADDRESS FOR CKERR
	lhld	DPHADRS
	push	h		;DPH ADDRESS
	call	seldrv	;DO THE GETDPB STUFF
	pop		h		;DPH ADDRESS
	jmp		ckerr	;CHECK ERROR, GIVE ERROR MSG ETC


;********************************************************
;	HOME THE HEAD TO TRACK 0			*
;********************************************************

home:
	lxi		b,0

;********************************************************
;	SET TRACK GIVEN IN <BC>				*
;********************************************************

settrk:
	call	onelist
	db		oc$trak
	mov		a,c
	call	sendcmd
	mov		a,b
	jmp		sendcmd

;********************************************************
;	SET SECTOR (RECORD NUMBER) GIVEN BY <C>		*
;********************************************************

setsec:
	call	onelist
	db		oc$recd
	mov		a,c
	jmp		sendcmd

;********************************************************
;	SET DMA GIVEN BY <BC> FOR READ/WRITE BUFF	*
;********************************************************

setdma:
	mov		l,c
	mov		h,b
	shld	dmaadr
	IF NOT DMA
	ret
	ENDIF ;NOT DMA

	IF DMA
	call	onelist
	db		OC$DADR	;OMNI COMMAND: SET DMA ADDRESS
	mov		a,c
	call	sendcmd
	mov		a,b
	call	sendcmd
	mvi		a,dmaext
	jmp		sendcmd
	ENDIF ;DMA


;********************************************************
;	READ A LOGICAL SECTOR				*
;********************************************************

read:
	call	sreta
	call	cmdlist
	db		2
	db		oc$read
	db		oc$gens
	IF NOT DMA
	lhld	dmaadr
	call	getdat
	jmp		ckerr
	ENDIF ;NOT DMA

	IF DMA
	jmp		dma$rw
	ENDIF ;DMA


;********************************************************
;	WRITE A LOGICAL SECTOR				*
;********************************************************
;	WRITE THE SELECTED CP/M SECTOR
;		AT ENTRY C:	0 - FOR NORMAL SECTOR WRITE
;					1 - WRITE DIRECTORY SECTOR
;					2 - WRITE SECTOR OF A NEW DATA BLOCK
;

write:
	call	sreta
	call	onelist
	db		oc$writ		;OMNI COMAND: Write Logical Record
	mov		a,c			;
	call	sendcmd		;Send P1: write$mode
	IF NOT DMA
	call	inchar		;GET GENERAL STATUS BEFORE DATA XFER
	ora		a
	jnz		ckerr
	mvi		c,128
	lhld	dmaadr
write1:
	in		omnistat
	add		a
	jc		write1
	mov		a,m
	out		omnidata
	inx		h
	dcr		c
	jnz		write1
	xra		a			;FAKE GOOD STATUS FOR CKERR
	ENDIF ;NOT DMA

	IF DMA
dma$rw:
	call	inchar		;GET GENERAL STATUS AFTER DATA XFER
	ENDIF ;DMA


;********************************************************
;	SUBROUTINE FOR UNEXPECTED DRIVE ERRORS		*
;********************************************************

ckerr:
	ora		a
	rz					;IF NO ERROR
	call	onelist
	DB	OC$EXTS			;OMNI COMMAND: GET EXTENDED STATUS
;						(THIS IS THE ONLY WAY TO ZERO GENSTAT)
	call	outm$cr		;OUT MESSAGE = "DISK I/O ERROR -"
	DB	'DISK I/O ERROR'
	
	mvi		b,9			;LENGTH OF EXTENDED STATUS LIST
ckerr1:
	mvi		c,' '
	call	ioconout
	call	inchar		;GET EXTENDED STATUS BYTE FROM OMNI
	call	hexout		;SEND TO CONSOLE
	dcr		b
	jnz		ckerr1		;IF NO MORE EXTENDED STATUS
	call	outm$cr		;OUT MESSAGE = "^C ABORT etc..."
	DB	'^C ABORT, cr IGNORE, ELSE RETRY',0
	call	ioconin		;WAIT FOR RESPONSE FROM USER
	lxi		h,0			;FOR "IGNORE" EXIT WHEN USED FROM SELDSK
	cpi		0DH
	rz					;IF <cr> THEN RTN TO BDOS WITH <A> NON-ZERO
	lhld	RETRY$ADDRESS
	sui		'C'-40H
	jz		wboot0		;IF ^C WE ABORT CHANGING LOGGED DISK TO "A:"
	pchl
;
; OUTPUT NULL TERMINATED MESSAGE FOLLOWING CALL
;
om$crlf:
	call	outmcr
	DB		0
	ret
outm$cr:
	call	outm
	DB		0DH,0AH,0
outm:
	xthl				;H,L POINTS TO MESSAGE STRING
	mov		a,m
	inx		h
	ora		a
	jz		eom			;IF AT END OF MESSAGE
	mov		c,a
	call	ioconout	;SEND TO CONSOLE
	jmp		outm+1		;REPEAT UNTIL DONE
eom:
	xthl				;SP POINTS TO AFER MESSAGE
	ret

HEXOUT:
	PUSH	PSW
	RAR 
	RAR 
	RAR
	RAR					;POSITION HIGH ORDER NIBBLE...
	CALL	HEXOUT1		;...SEND TO CONSOLE
	POP		PSW			;NOW LOW NIBBLE
HEXOUT1:
	ANI		0FH			;ISOLATE NIBBLE
	SUI		10
	JM		HEXOUT2		;IF CONVERTING 0-9
	ADI		7			;ELSE CONVERTING A-F
HEXOUT2:
	ADI		10+'0'		;NIBBLE NOW CONVERTED TO ASCII
	MOV		C,A
	JMP		IOCONOUT	;SEND TO CONSOLE AND RETURN TO OUR CALLER

;********************************************************
;	SET RETRY ADDRESS FOR OMNI I/O ERRORS		*
;********************************************************

sreta:
	xthl
	shld	RETRY$ADDRESS
	xthl
	ret

;********************************************************
;	SELECT A NEW DRIVE				*
;********************************************************
;
;	NOTE USE OF TRACK 4 IN GETDPB.  ONE MIGHT THINK THAT TRACK
;	TWO (DIRECTORY) WOULD BE BETTER.  TRACK 4 WAS SELECTED
;	BECAUSE (1) WE DO NOT WANT THE DIRECTORY TRACK BECAUSE
;	IT IS THE MOST LIKELY TO BE ZAPPED BY A SYSTEM PROBLEM,
;	(2) WE DO NOT WANT ANY SYSTEM TRACKS BECAUSE THEY MIGHT
;	BE FORMATTED AT SOME DENSITY OTHER THAN THE REST OF THE
;	DISK AND (3) THE SYSTEM TAKES 3 TRACKS ON SOME 5" FLOPPIES.

seldrv:
	lxi		d,10		;DPH OFFSET TO DPB
	dad		d
	mov		e,m			;LOW DPB
	inx		h
	mov		h,m			;HIGH DBP
	mov		l,e			;<HL> = DPB ADDRESS
	call	cmdlist
	DB		5			;LENGTH OF LIST
	DB		OC$TRAK		;OMNI COMMAND: SELECT TRACK (SEEK)
	DW		4			;GO TO TRACK 4 FOR GETDPB FUNCTION
	DB		OC$GDPB		;OMNI COMMAND: GET DPB
	DB		OC$GENS		;OMNI COMMAND: GET GENERAL STATUS
;				     (USED TO END GETDAT LOOP)
;	... FALL INTO GETDAT

;********************************************************
;	SUBROUTINE FOR BLOCK READ			*
;							*
;	NOTE:	THIS SUBROUTINE READS DATA UNTIL	*
;		THE OMNI CONTROLLER ACCEPTS THE		*
;		GENERAL STATUS COMMAND			*
;********************************************************

getdat:
	in		OMNISTAT
	rrc					;Rotate right to test bit 0
	jnc		getdat		;IF NOTHING TO GET FROM OMNI
	ani		40H			;(WHAT DO WE HAVE HERE: DATA -OR- GEN STATUS?)
	in		OMNIDATA	;TAKE IT, WHATEVER IT IS
	rz					;IF IT IS GENERAL STATUS, THEN RETURN
	mov		m,a			;ELSE...PUT INTO BUFFER
	inx		h			;Advance RAM pointer
	jmp		getdat		;KEEP ON KEEPING ON

;****************************************************************
;	SUBROUTINE TO ACCEPT ONE BYTE FROM DISK CONTROLLER	*
;****************************************************************

inchar:
	in		OMNISTAT
	rrc					;Rotate right to test bit 0
	jnc		inchar		;IF OMNI HAS NOT YET SENT REPLY
	in		OMNIDATA	;ACCEPT REPLY
	ret

;********************************************************
;	SUBROUTINE TO ISSUE COMMAND LIST		*
;********************************************************

cmdlist:
	xthl
	mov		c,m			;FETCH LENGTH OF LIST
	inx		h
cmdlist1:
	mov		a,m			;NEXT BYTE TO SEND
	inx		h
	call	sendcmd		;BYTE TO CONTROLLER
	dcr		c
	jnz		cmdlist1	;IF MORE COMMANDS TO SEND
	xthl
	ret

;********************************************************
;	SUBROUTINE TO SEND CONSTANT BYTE TO OMNIDISK	*
;********************************************************

onelist:
	xthl
	mov		a,m
	inx		h
	xthl
;	...	FALL INTO SENDCMD

;********************************************************
;	SUBROUTINE TO SEND COMMAND TO DISK CONTROLLER	*
;********************************************************

sendcmd:
	push 	psw			;BYTE TO SEND TO OMNI
	in		OMNISTAT
	rlc					;Rotate left to test bit 7
	jc		sendcmd+1	;IF OMNI NOT READY TO TAKE BYTE
	pop		psw
	out		OMNIDATA
	ret

ROM		EQU	$-CBOOTE
R$FREE	EQU	ROMTOP-ROM	;2K ROM
	IF ROM/ROMTOP
R$OVER	EQU	-R$FREE	;HOW MUCH YOU ARE OVER
 EQU;LONGER THAT 2K
	ENDIF

	END
