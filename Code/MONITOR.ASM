	;TITLE	"4K STAND ALONE MONITOR/DEBUG PACKAGE"
	;PAGE 0
;
;	SYSTEM VARIABLE DEFINITIONS
;

FALSE	EQU	0
TRUE	EQU	NOT FALSE

ISIO2	EQU	FALSE	;IMSAI SIO-2
CSS1	EQU	TRUE	;COMPUPRO SYSTEM SUPPORT 1
ROMMON		EQU	TRUE
TESTING		EQU	TRUE
AUTOBOOT	EQU	FALSE
COMPUPRO85	EQU	FALSE

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
SWAP	EQU	0FDH	;OUTPUT TO SWAP 8085/8088
NDISKS	EQU	1		;NUMBER OF DISK DRIVES
FDISK8	EQU	10H		;OMNI DEV TYPE FOR 8" FLOPPY
FDISK5	EQU	14H		;OMNI DEV TYPE FOR 5" FLOPPY
LUN0	EQU	0		;LOGICAL UNIT 0
PHY0	EQU	FDISK8+0;PHYSICAL DEVICE 0

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
	IF NOT ROM$MON
ROMTOP	EQU	0800H	;ROM SIZE 2K
	ENDIF
	IF ROM$MON
ROMTOP	EQU	1000H	;ROM SIZE 4K
	ENDIF1


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

SERFLAG	EQU	01H	;SERIAL I/O FLAG CHANELL A
SERFLGB	EQU	02H	;SERIAL I/O FLAG CHANELL B

;
PROMPT	EQU	'$'	;SCREEN PROMPT

;
;********************************************************
;	VALID COMMAND BYTE ONE FOR OMNI CONTROLLER	*
;	   (THESE EQUATES ARE COPIED FROM BIOS)		*
;********************************************************

OC$BOOT	EQU	0		;BOOT SYSTEM
OC$SWRT	EQU	1		;WRITE SYSTEM (INVERSE OF BOOT)
OC$MODE EQU	2		;DMA/IO MODE
OC$FMTF	EQU	3		;FORMAT FLOPPY TRACK
OC$DLDS EQU	4		;DEFINE LOGICAL DEVICE SET
OC$GLDS	EQU	5		;GET LOGICAL DEVICE SET
;C$FWRT	EQU	6       ;FORCE WRITE OF MODIFIED BUFFERS
OC$RBPH	EQU	7		;RESET BOOT PHANTOM
;C$SKEW	EQU	8		;Set sector skew
OC$UNIT	EQU	9		;SELECT (LOGICAL) UNIT
OC$TRAK	EQU	10		;SELECT TRACK
OC$RECD	EQU	11		;SELECT (LOGICAL) RECORD
OC$DADR	EQU	12		;SET DMA ADDRESS
OC$READ	EQU	13		;READ
OC$WRIT	EQU	14		;WRITE
OC$HEAD	EQU	15		;SET HEAD (NOT USED, ANYWHERE)
;C$MOVM	EQU	16		;DMA memory move
OC$GDPB	EQU	17		;GET DPB (GET CP/M DPB FROM OMNI)
;C$DFMD	EQU	18		;Define memory disk
OC$SSEK EQU	19		;NON-IMPYED SEEK (NOT USED IN BIOS)
;C$TIOR	EQU	20		;DEBUG READS FROM OMNI
;C$TIOW	EQU	21		;DEBUG WRITES TO OMNI
OC$GENS EQU	22		;GET GENERAL STATUS
OC$EXTS	EQU	23		;GET EXTENDED STATUS
;C$SRTY	EQU	24		;Set floppy disk retry counters
;C$DPBX	EQU	25		;Get extended DPB
;C$GBPB	EQU	26		;Get MS-DOS bios parameter block
;C$GMCS	EQU	27		;Get media change status
OC$SFDP	EQU	28		;Set Floppy Disk Parameters
OC$PREA	EQU	29		;Physical Sector Read
OC$PWRT	EQU	30		;Physical Sector Write
;C$HDPA	EQU	31		;Set Common Hard Disk Parameters
;C$HTBL	EQU	32		;Set Hard Disk Tables
OC$FDIE	EQU	33		;Ignore Floppy Disk Errors & Mark Buffer Valid
;C$SIHD	EQU	34		;Set Individual HD Parameters
;C$GIHD	EQU	35		;Get Individual HD Parameters
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
;*******************************************************
; COMMAND STRING FOR FULCRUM OMNI DISK INTERFACE
;	AND WORK AREA FOR THE DISPLAY COMMAND
;*******************************************************

UNIT	DS	1	;UNIT #
TRACK	DS	2	;TRACK #
RECORD	DS	1	;SECTOR #
DMAADR	DS	2	;CURRENT DMA BUFFER
WRITEA	DS	1	;SECTOR WRITE$MODE
LOGSEC	DS	1	;LOGICAL/PHYSICAL SECTOR I/O
RETRY$ADDRESS
		DS	2	;RETRY ADDRESS
DTRACK	DS	2	;DEFAULT TRACK #
SECTOR	DS	1	;DEFAULT SECTOR #
TMAADR	DS	2	;DMA BUFFER ADDRESS
TRACEF	DS	1	;TRACE FLAG
DEVICE	DS	1	;DEVICE FOR ALL OPERATIONS
QUIET	DS	1	;CONSOLE QUIET FLAG
LINE:			;ASCII PRINT BUFFER, 17 BYTES
DPHADRS DS	2	;ADDRESS OF DPH
STATUS	DS	10	;BUFFER
		DS	6	;
CWFLAG:	DS	1		;COLD/WARM BOOT FLAG
AUTOFLG:
		DS	1		;AUTOBOOT COMMAND FLAG
EOL		EQU	$
;*******************************************************
; END OF INIT SCRATCH RAM
;*******************************************************

RSECTNO	DS 1		;RECEIVED SECTOR NUMBER
SECTNO	DS 1		;CURRENT SECTOR NUMBER
DMABLK	DS 2		;CURRENT DMA BLOCK
INDEV	DS 1		;INPUT DEVICE SELECT BYTE
OUTDEV	DS 1		;OUTPUT DEVICE SELECT BYTE
VRAMPTR	DS 2		;AVAILABLE RAM POINTER FOR DIRECT I/O
IORAM	DS 3		;RAM FOR DIRECT I/O COMMANDS
ASAVE	DS 1		;A REG SAVE AREA

;********************************************************
;	UN-INIT SCRATCH RAM AREA FOR BDOS USE		*
;********************************************************

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
VARSIZE	EQU	$		;END OF VARS

	IF ROM$MON
IOBYTE		DS	1		;INTEL I/O BYTE
	ENDIF ;ROM$MON
	IF NOT ROM$MON
IOBYTE	EQU	0003H		;INTEL I/O BYTE
CDISK	EQU	0004H		;CURRENT CPM DISK BUFFER (CONTENTS 0=A,..,15=P)
	ENDIF ;NOT ROM$MON

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

	IF NOT ROM$MON
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
	IF NOT ROM$MON
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
	IF NOT ROM$MON

	IF NOT LST
 	XRA		A			;...THEN ALLWAYS READY
	ENDIF ;NOT LST
	IF NOT ROM$MON

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
	IF NOT ROM$MON

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
	IF NOT ROM$MON
	IF NOT RDRPUN
	MVI		A,1AH		;NO READER? RETURN ^Z AS EOF INDICATION
	ENDIF ;NOT RDRPUN
	IF NOT ROM$MON
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
	IF NOT ROM$MON
	IF DMA
	DB	DMAPRI+80H			;BIOS USES DMA FOR READ/WRITE
	ENDIF ;DMA
	IF NOT ROM$MON
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
	IF NOT ROM$MON
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
	IF NOT ROM$MON
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
	IF NOT ROM$MON
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
	IF NOT ROM$MON

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
	IF ROM$MON
	IF DMA
	jmp		dma$rw
	ENDIF ;DMA
	IF NOT ROM$MON

;********************************************************
;	WRITE A LOGICAL SECTOR				*
;********************************************************
;	WRITE THE SELECTED CP/M SECTOR
;		AT ENTRY C:	0 - FOR NORMAL SECTOR WRITE
;					1 - WRITE DIRECTORY SECTOR
;					2 - WRITE SECTOR OF A NEW DATA BLOCK
;

write:
	mov		a,c			;Get WRITE$MODE
	sta		writea
	call	sreta
	call	onelist
	db		oc$writ		;OMNI COMAND: Write Logical Record
	lda		writea
	call	sendcmd		;Send P1
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
	IF NOT ROM$MON
	IF DMA
dma$rw:
	call	inchar		;GET GENERAL STATUS AFTER DATA XFER
	ENDIF ;DMA
	IF NOT ROM$MON

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
	DB	'^C ABORT, cr IGNORE, ELSE RETRY',0DH,0AH,0
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
;
;********************************************************
;********************************************************
;
	ENDIF ;NOT ROM$MON
;
;********************************************************
;********************************************************

;********************************************************
;	ROM MONITOR
;********************************************************
	IF ROM$MON
CBOOT:
	LXI		SP,STACK
; INIT RAM AREA
	LXI		H,UNIT		;BASE OF RAM
	MVI		C,EOL-UNIT	;BYTES TO CLEAR
	XRA		A			;A=0
INITCMD:
	MOV		M,A			;CLEAR MEMORY
	INX		H			;NEXT BYTE
	DCR		C			;DONE?
	JNZ		INITCMD		;NO
	LXI		H,IORAM		;GET ADDR OF WHERE TO DO I/O INTRUCTIONS
	SHLD	VRAMPTR		;SAVE IN RAM I/O AREA
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
	IF ROM$MON
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
	IF ROM$MON
;
; TRY BOOTING FLOPPY DISK
	CALL	INITFD		;INIT OMNIDISK
	IF AUTOBOOT
	CALL	ABOOT		;FIND MAIN DRIVE AND TRY TO READ IN A SECTOR
	ORA		A			;TEST FLAGS
	JZ		BOOTOK		;NO ERRORS?
	CALL	GET$EXTS	;CLEAR GEN$STAT
	ENDIF ;AUTOBOOT
	IF ROM$MON
;
 	CALL	SETSYSP		;SET UP I/O PORTS BY HITTING SPACE BAR
SIGN:
	LXI		H,SIGNON
	CALL	SYSMSG		;"FULCRUM MPU-Z MONITOR REV 2"


;******************************************
;
;	PROMPT ROUTINE
;
; * ROUTINES DISPATCHED FROM COMMAND ROUTINE RETURN HERE *
;
;******************************************

WBOOT:
PRMPTSP:
	LXI		SP,STACK
PRMPT:
	LXI		H,PRMPTSP
	PUSH 	H			;RETURN ADDRESS IN STACK
	CALL	CRLF
	MVI		A,PROMPT
	CALL	SYSOUT	;PRINT PROMPT CHARACTER
	CALL	IOCONST		;CLEAR INPUT
;
;****************************************
;
;	COMMAND DISPATCH ROUTINE
;
;****************************************
	LXI		H,CMDTBL
CMDFIND:
	CALL	SYSIN	;GET COMMAND
	CALL	LOOKUP	;LOOK UP COMMAND ADDRESS
	RZ				;RETURN IF COMMAND IS INVALID
	CALL	SPACE
	MVI		B,1		;SET B TO KNOWN VALUE FOR VARIOUS ROUTINES
	PCHL			;DO COMMAND
;
TBLSET2:
	LXI		H,CMDTBL2;GET ADDR FOR SECOND CMD TABLE
	JMP		CMDFIND

;
;****************************************************
; SS-1 GO86.HEX
	IF COMPUPRO85
GO86:
	LXI		H,JMP86			;SOURCE
	LXI		D,02F0H			;DEST=2F0H
	LXI		B,JMPF86-1		;SIZE
	CALL	MVCUP
	LXI		D,3F0H			;DEST=3F0H
	LXI		B,5				;SIZE
	JMP		MVCUP
JMP86:
	DB	0E4H,SWAP				;IN AL,SWAP
	DB	0EBH,0EH				;JMPS 300H
	DW	0,0,0,0,0				;NOP'S
	DB	0DBH,SWAP				;IN SWAP
JMPF86:
	DB	0EAH					;JMPF
	DW	400H,0					;400:00
E86	EQU	$
	ENDIF ;COMPUPRO85
	IF ROM$MON

;****************************************************
;FIND THE APPROPRIATE SYSTEM PORT AND SET BAUD RATE IF
;PORT IS SERIAL
;****************************************************
SETSYSP:
	LXI  H,OUTDEV
	XRA	A			;DE-ALLOCATE ALL OUTPUT
	MOV  M,A
	DCX  H			;MOVE MEM POINTER TO INPUT DEV
	MOV  M,A		;DE-ALLOCATE ALL INPUT
	MVI	B,SERFLAG	;B=Serial Port
;
;		ALLOCATE AN I/O DEVICE
;			PASS DEVICE MASK IN B
;
ALLOCIO
	LXI  H,INDEV	;SET MEM POINTER TO INPUT SELECT BYTE
	MOV  A,M
	ORA  B			;OR DEVICE BIT WITH DEVICE SELECT BYTE
	MOV  M,A
	INX  H			;INCR MEM POINTER TO OUTPUT SELECT BYTE
	MOV  A,M
	ORA  B			;OR DEVICE BIT WITH DEVICE SELECT BYTE
	MOV  M,A
	RET
;
;**********************************************
;SELECT BAUD RATE COMMAND
;B <RATE><CR> FORCE SPECIFIED STANDARD BAUD RATE
;************************************************
BAUDSEL:
	CALL IHEX		;READ 16 BIT VALUE
	MOV A,H			;USE HIGH 2 DIGITS AS CODE
	ORA L			;ANY PARM?
	JZ	ERR			;NO, INVALID
	MOV A,H			;GET CODE AGAIN
BAUDSET:
	LXI H,BAUDTBL	;POINT AT TABLE, A=LOOKUP VALUE
	PUSH B			;SAVE BC
	CALL LOOKUP		;IS VALUE IN TABLE? RETURNS: HL=VALUE
	POP B			;RESTORE BC
	JNZ BAUDSET1	;SET BAUD RATE
	LXI H,MSG6		;"BAUD RATE ERROR"
	JMP  SYSMSG
BAUDSET1:
	IF CSS1
;Reset mode byte flipflop before setting baud rate
	IN	CCTRL		;reset mode byte flipflop
;Mode reg initialization
	MOV	A,H			;Stop bits, Parity, word length, Baud rate factor
	OUT	CMODE
	MOV	A,L			;Baud rate
	OUT	CMODE
;Control reg initialization
	mvi	a,CTL2651	;Enable Tx, Rx, RTS=low, DTR=low
	out	CCTRL
	ENDIF ;CSS1
	IF ROM$MON
	RET

;**************************************************
;	JUMP: JUMP TO MEMORY.
;	CALL1: CALL MEMORY WITH RETURN TO MONITOR.
;**************************************************
JUMP:
	POP		D		;REMOVE RETURN ADDRESS
CALL1:
	CALL	IHEX	;GET JUMP ADDRESS
	PCHL

;
;***************************************************
;	ENTER BYTE INTO MEMORY AND MODIFY IF DESIRE
;	'CR' = DONE, '-' = BACK, ' ' = NEXT
;***************************************************
ENTR:
	CALL	IHEX	;START ADDR
	CALL	CRLF
	CALL	OHEXHL	;DISPLAY ADDRESS
	CALL	EBYTE	;DISPLAY AND CHANGE BYTE
	DCX		H
	CPI		0AH		;DONE?
	RZ				;YES
	CPI		'-'		;BACKWARD?
	JZ		ENTR+3	;YES
	INX		H
	INX		H		;DEFAULT FORWARD
	JMP		ENTR+3
;
EBYTE:
	MOV  A,M	;GET BYTE IN MEMORY
	MOV  E,A	;PRESET FOR IHEX
	CALL OHEXB	;DISPLAY BYTE
	XCHG		;DE = ADDRESS, L = DEFAULT CHAR
	CALL IHEX+3	;GET MODIFIER OR DEFAULT
	XCHG		;HL = ADDRESS, E = BYTE
	MOV  M,E
	RET
;
;*****************************************************
;	DISPLAY MEMORY "D START,END"
;*****************************************************
DISP:
	CALL	SIZE	;HL = START, BC = SIZE
	MVI		E,24	;SAVE # OF LINES PER BLOCK
	PUSH	H		;POINTER TO MEMORY
NXTBLOC:
	MOV		D,E		;# OF LINES FOR EACH BLOCK
NXTLINE:
	PUSH	D
	MVI		D,17	;NUMBER OF BYTES TO ZERO
	LXI		H,LINE+17	;POINTER TO ASCII PRINT BUFFER
	XRA		A		;ZERO ACCUM
LNZERO:
	DCX		H
	MOV		M,A		;ZERO BUFFER
	DCR		D
	JNZ		LNZERO
	POP		D
	XTHL			;GET MEM POINTER
	CALL	CRLF
	CALL	OHEXHL	;PRINT ADDRESS
	CALL	SPACE
NXTBYTE:
	CALL	IOCONST	;HAS A CHAR BEEN INPUTED?
	JNZ		DISPEX	;YES.  INTERUPT
	MOV		A,M		;GET DATA BYTE
	CALL	OHEXB	;PRINT HEX WITH TRAILING BLANK
	MOV		A,M		;GET DATA BYTE
	INX		H		;INCREMENT MEM POINTER
	XTHL			;GET ASCII BUF POINTER
	MOV		M,A		;MOVE DATA TO BUFFER
	CPI		32		;IS DATA LESS THAN BLANK?
	JC		PERIOD	;YES.  INVALID CHAR
	CPI		127		;IS DATA LESS THAN RUB-OUT?
	JC		CHAROK	;YES.  CHARACTER IS OK
PERIOD:
	MVI		M,'.'	;MOVE PERIOD TO BUFFER
CHAROK:
	INX		H		;INCREMENT BUF POINTER
	DCX		B
	MOV		A,B
	ORA		C		;WAS THAT THE LAST BYTE?
	JZ		PRNTASC	;YES.  PRINT ASCII BUFFER
	XTHL
	MOV		A,L		;GET LOW LOW ORDER ADDR OF MEM
	ANI		0FH		;IS IT TIME FOR NEXT LINE?
	JNZ		NXTBYTE	;NO.  PROCESS NEXT BYTE
	XTHL
PRNTASC:
	CALL	SPACE
	LXI		H,LINE	;GET ADDR TO ASCII BUFFER
	CALL	SYSMSG	;PRINT ASCII BUFFER
	MOV		A,B
	ORA		C		;WAS THAT THE LAST BYTE?
	JZ		DISPEX	;YES.  EXIT ROUTINE
	DCR		D		;READY TO PAUSE?
	JNZ		NXTLINE	;NO.  DO NEXT LINE
	CALL	IOCONIN	;PAUSE UNTIL A CHAR IS TYPED
	CALL	CRLF
	JMP		NXTBLOC	;DO NEXT BLOCK OF DATA
DISPEX:
	POP		H
	JMP		CRLF	;EXIT DISPLAY ROUTINE

;
;*******************************************************
;	BINARY LOADER
;*******************************************************

;  Transfer related equates

SOH		EQU	1
EOT		EQU	4
ACK		EQU	6
NAK		EQU	15H
CTRLC	EQU	3			;Control-C

XMODEM:
	xra  a
	sta  SECTNO			;init sector number to zero
	lhld DMAADR			;SET H,L AS BUFFER PTR
	shld DMABLK			;Set base
	call OHEXHL

;  GOBBLE UP GARBAGE CHARS FROM THE LINE

PURGE:
	MVI  B,1			;times out after 1 second if no data
	CALL RECV
	jc   RECEIVE$FILE	;line is clear, go receive the file
	cpi  ctrlc			;exit if abort requested
	rz					;yes
	JMP  PURGE			;wait for packet
;
;**************RECEIVE FILE****************
;
RECEIVE$FILE:
	MVI  A,NAK			;NAK block
	CALL SEND

; Wait for block header

RECV$HDR:
	MVI  B,3			;3 SEC TIMEOUT
	CALL RECV
	JNC  RECV$HDR$NOW	;NO TIMEOUT

; Receive SECT/HDR error or timeout

RECV$SECT$ERR:
						;PURGE THE LINE OF INPUT CHARS
	MVI  B,1			;1 SEC W/NO CHARS
	CALL RECV
	JNC  RECV$HDR$NOW 	;LOOP UNTIL SENDER DONE
	MVI  A,NAK			;NAK the block
	CALL SEND
	JMP  RECV$HDR		;Wait for block header

;GOT CHAR - MUST BE SOH OR CTRL-C TO ABORT

RECV$HDR$NOW:
	CPI  SOH			;Start-OF-Header?
	JZ   GOT$SOH		;yes
	cpi  ctrlc			;control-c to abort?
	rz					;yes
	CPI  EOT			;End-OF-Transmission?
	JZ   GOT$EOT		;yes
	JMP  RECV$SECT$ERR	;no

; Receive Header Validation

GOT$SOH:
	MVI  B,1			;Wait 1 second for next char
	CALL RECV
	JC   RECV$SECT$ERR
	MOV  D,A			;D=BLK #
	MVI  B,1
	CALL RECV			;Get CMA'D BLK #
	JC   RECV$SECT$ERR
	CMA
	CMP  D				;Good BLK #?
	JNZ  RECV$SECT$ERR

;  Receive Block

RECV$SECTOR:
	MOV  A,D			;Save BLK #
	STA  RSECTNO
	MVI  C,0			;INIT CKSUM
	MVI  E,80H			;SIZE OF SECTOR
	LHLD DMABLK			;Get start of DMA buffer
RECV$CHAR:
	MVI  B,1			;1 SEC TIMEOUT
	CALL RECV			;Get char
	JC   RECV$SECT$ERR	;No, NAK block
	MOV  M,A			;Store char
	INX  H				;Advance DMA ptr
	DCR  E				;Done?
	JNZ  RECV$CHAR		;Not yet

; Verify received CHECKSUM

	MOV  D,C			;Save computed CHECKSUM
	MVI  B,1			;TIMEOUT
	CALL RECV			;Get CHECKSUM
	JC   RECV$SECT$ERR	;Timeout, NAK block
	CMP  D				;Is CHECKSUM valid?
	JNZ  RECV$SECT$ERR	;No, NAK block

; Got a block, advance if = 1+PREV BLk #

	LDA  RSECTNO		;Get current BLK #
	MOV  B,A			;SAVE IT
	LDA  SECTNO			;Get prev BLK #
	INR  A				;Calc next BLK #
	CMP  B				;Match?
	JNZ  DO$ACK			;No, was repeat of last sector

; Got new BLK# - Advance to next DMA block

	SHLD DMABLK			;Update DMA ptr for next block
	LDA  RSECTNO		;Get current BLK #
	STA  SECTNO			;Update prev BLK #

; ACK that valid block received

DO$ACK:
	MVI  A,ACK			;ACK block
	CALL SEND
	JMP  RECV$HDR		;Get next packet

GOT$EOT:
	MVI  A,ACK			;ACK the EOT
	CALL SEND
; DONE - CLOSE UP SHOP
	LHLD DMABLK			;Get last address
	DCX  H
	XCHG				;Into DE
	LHLD DMAADR			;Get first address
	CALL SIZE+3			;Compute size
	MOV  H,B
	MOV  L,C
	JMP	OHEXHL			;-- EXIT --


; - - - - - - - - - - - - - - -
; RECV CHAR ROUTINE
;-------------------------------------
RECV:
	PUSH D			;SAVE D,E
MSEC:
	lxi d,(159 shl 8)	;49 cycle loop, 6.272ms/wrap * 159 = 1 second
MWTI:
	CALL IOCONST
	JNZ  GOT$CHAR	;GOT CHAR
	DCR  E			;COUNT DOWN
	JNZ  MWTI		;FOR TIMEOUT
	DCR  D
	JNZ  MWTI
	DCR  B			;DCR # OF SECONDS
	JNZ  MSEC

; TIMED OUT RECEIVING

	POP  D			;RESTORE D,E
	STC				;CARRY SHOWS TIMEOUT
	RET

;GOT CHAR

GOT$CHAR:
	POP  D			;RESTORE DE
	PUSH PSW		;CALC CHECKSUM
	ADD  C
	MOV  C,A
	POP  PSW
	ORA  A			;TURN OFF CARRY TO SHOW NO TIMEOUT
	RET

; - - - - - - - - - - - - - - -
; SEND CHAR ROUTINE
;----------------------------------
;
SEND:
	PUSH PSW		;CHECK IF MONITORING OUTPUT
	ADD  C			;CALC CKSUM
	MOV  C,A
SENDW:
	POP  PSW		;GET CHAR
	JMP  SYSOUT

;
;*******************************************************
;	INTEL LOADER LOADS INTEL FORMAT TAPES FROM
;		INPUT DEVICE.
;*******************************************************
INTEL:
	CALL IHEX	;GET OPTIONAL OFFSET
	SHLD DMAADR	;SAVE IT
; WAIT FOR START OF RECORD
WSOR:
	CALL SYSIN	;READ CHARACTER
	SUI  ':'	;RECORD MARKER?
	JNZ  WSOR	;NO
	MOV  D,A	;ZERO CHECKSUM
	CALL IBYTE	;INPUT 2 HEX CHARS
	MOV  B,E	;BYTE COUNT
	CALL IBYTE	;INPUT LOAD ADDRESS (H)
	MOV  H,E
	CALL IBYTE	;INPUT LOAD ADDRESS (L)
	MOV  L,E
	CALL IBYTE	;DUMMY RECORD TYPE IGNORED
; TEST FOR END-OF-FILE RECORD
	MOV  A,B	;TEST BYTE COUNT
	DCR  A		;IS IT ZERO?
	JM   EOF	;COUNT = 0  MEANS END
; OFFSET LOAD ADDRESS OF RECORD
	PUSH  D		;SAVE CHECKSUM
	XCHG		;DE=LOAD ADDRESS
	LHLD DMAADR	;HL=OFFSET
	DAD  D		;HL=HL+OFFSET
	POP  D		;RESTORE CHECKSUM
DATA:
	CALL IBYTE	;INPUT DATA
	MOV  M,E	;SAVE IN MEMORY
	INX  H
	DCR  B		;ALL DATA READ?
	JNZ  DATA	;NO
	CALL IBYTE	;READ AND ADD CHECKSUM
	JZ   WSOR	;OK AS IS
	JMP  BAD
EOF:
; READ AND DUMP CHARACTERS
	CALL IBYTE	;READ AND ADD CHECKSUM
	JMP  JUNK	;IGNORE CHECKSUM
BAD:
	MVI  A,'C'
	CALL SYSOUT	;CHECKSUM ERROR MESSAGE
JUNK:
	CALL IOCONST	;CHARACTER READY?
	JNZ  JUNK		;JUNK IT
	RET				;LOAD COMPLETE
;
;***********************************************************
;	READ 2 ASCII HEX BYTES AND CONVERT TO BINARY
;   E=BINARY VALUE, D=UPDATED CHECKSUM
;***********************************************************
IBYTE:
	CALL ICHAR		;READ CHARACTER
	ADD  A
	ADD  A
	ADD  A
	ADD  A
	MOV  E,A		;SAVE HALF BYTE
IBYTE2:
	CALL ICHAR		;INPUT CHAR
	ADD  E			;ADD TO HALF BYTE
	MOV  E,A		;SAVE BINARY VALUE
	ADD  D			;ADD TO CHECKSUM
	MOV  D,A		;SAVE CHECKSUM
	RET
ICHAR:
	CALL SYSIN		;READ CHARACTER
	CALL ASCBI		;CONVERT TO BINARY
	RNC  			;VALID CHARACTER?
; TRANSMISSION ERROR
	MVI  A,'T'		;TRANSMISSION ERROR CODE
	CALL SYSOUT
	JMP  JUNK		;JUNK TO EOF
;
;*******************************************
;	MEMORY TEST ROUTINE
;*******************************************
MEMTEST:
	CALL SIZE	;HL = START, BC = SIZE
	DCX  B		;BC = SIZE-1  OR  0
MEM2:
	XRA  A
	MOV  D,M	;SAVE CELL
MEM1:
	MOV  M,A
	CMP  M
	JNZ  MEMERR	;NOT GOOD
	DCR  A		;NEXT PATTERN
	JNZ  MEM1
	MOV  M,D	;RESTORE MEMORY
	CALL IOCONST	;BAIL OUT?
	RNZ		;YES
	INX  H
	DCX  B
	MOV  A,B
	ORA  C
	JNZ  MEM2
	RET
MEMERR:
	INX  H		;ADJUST FOR PRNMEM
	MOV  E,A	;SAVE
	CALL PNTMEM	;PRINT ADDR, CONTENTS
	MOV  A,E	;RESTORE
	JMP  SRCPNT1	;PRINT SHOULD BE

;
;***********************************************************
;	MEMORY MOVE SOURCE BEG, SOURCE END, DEST
;***********************************************************
MOVE:
	CALL PARM4	;START, END, DEST
MOVE1:
	JMP  MVCUP	;DO MOVE
;
;********************************************
;	FILL MEMORY WITH CHAR
;********************************************
FILL:
	CALL PARM4	;START, END, FILL CHAR IN E
	MOV  A,E	;FILL CHAR
	MOV  M,A	;STORE IN FIRST LOCATION
	DCX  B
	MOV  D,H
	MOV  E,L	;DEST ADDR
	INX  D		;=START ADDR+1

;
;************************************************************
;	MOVE BC CHARS FROM HL TO DE FROM BOTTOM
;************************************************************
MVCUP:
	MOV  A,B
	ORA  C
	RZ
	MOV  A,M
	STAX D		;MOVE IT
	DCX  B
	INX  H
	INX  D
	JMP  MVCUP	;KEEP GOING
;
;******************************************************
;	DO DIRECT I/O FROM SPECIFIED PORT
;******************************************************
INPORT:
	DCR  B		;B = 0 = INPUT, B = 1 = OUTPUT
OUTPORT
	CALL PARM5	;INPUT PORT, VALUE IN HL AND DE
	MOV  A,B	;FLAG
	RLC
	RLC
	RLC
	XRI  0DBH	;FORM I/O INSTRUCTION
	MOV  D,L
	LHLD VRAMPTR	;GET POINTER TO I/O RAM
	MOV  M,A
	CMP  M
	RNZ		;INVALID RAM
	PUSH H
	INX  H
	MOV  M,D	;PORT #
	INX  H
	MVI  M,0C9H	;RETURN
	LXI  H,IORET
	XTHL		;PUT RETURN ADDR, GET START ADDR
	MOV  A,B
	ORA  A		;SET FLAG FOR IN OR OUT
	MOV  A,E	;OUTPUT BYTE
	PCHL
IORET
	JZ   OHEXB	;PRINT IF INPUT
	RET		;ELSE RETURN
;
;
;************************************************
;	RELOCATE I/O RAM
;************************************************
RELIO:
	CALL IHEX	;GET ADDRESS
	MOV  A,H
	ORA  L		;IS ADDR ZERO?
	JNZ  $+3	;NO.  SKIP NEXT INSTR
	LXI  H,IORAM	;DEFAULT ADDRESS
	SHLD VRAMPTR	;SAVE ADDRESS
	RET
;
;******************************************************
;	COMPARE MEMORY BLOCKS AND PRINT DIFFERENCES
;******************************************************
CMPBLK:
	CALL PARM4	;HL = START, BC = END, DE = DEST
CMPBLK1:
	LDAX D		;DEST BYTE
	CMP  M		;SAME AS SOURCE BYTE?
	INX  H
	INX  D
	JZ   CMPB1	;YES.  DONT PRINT
	CALL PNTMEM	;PRINT ADDR, SOURCE DEST
	XCHG
	CALL PNTMEM+3	;NO CRLF
	XCHG
CMPB1:
	DCX  B
	MOV  A,B
	ORA  C
	RZ		;YES, RETURN
	CALL IOCONST	;BAIL OUT?
	RNZ		;YES
	JMP  CMPBLK1
;
;********************************************************
;	SEARCH FOR MASKED 16 BIT VALUE
;	"S BEG, END, 16 BIT VALUE, 16 BIT MASK"
;********************************************************
SEARCH:
	CALL PARM4	;HL = START, BC = SIZE, DE = VALUE
	PUSH H		;SAVE
	LXI  H,-1	;DEFAULT MASK ALL
	CPI  0AH	;USER SPECIFIED MASK?
	CNZ  IHEX	;YES, READ IT INTO HL
	XTHL		;MASK ON STACK, START IN HL
SEARCH1:
	MOV  A,M	;LOW BYTE
	XTHL		;HL = MASK VALUE
	ANA  H		;MASK HIGH BYTE
	CMP  D		;IS IT CORRECT VALUE?
	XTHL		;RESTORE START POINTER
	INX  H		;BUMP POINTER
	JNZ  CMP16	;NO MATCH
	MOV  A,M	;LOW BYTE
	XTHL		;GET MASK IN HL
	ANA  L
	CMP  E
	XTHL		;HL = START, STACK = MASK
	CZ   SRCPNT	;PRINT MATCH IF FOUND
CMP16:
	DCX  B
	MOV  A,B
	ORA  C
	JNZ  SEARCH1
	POP  B		;REMOVE MASK VALUE
	RET

;
;******************************************
;	DEVICE ALLOCATION
;******************************************
;
ALINPUT:
	LXI  H,INDEV	;INPUT ALLOCATION
	JMP  EBYTE		;DISPLAY AND RE-ENTER BYTE
;
ALOUTPT:
	LXI  H,OUTDEV	;OUTPUT ALLOCATION
	JMP  EBYTE		;DISPLAY AND RE-ENTER BYTE

;
;*********************
;SIZE INPUT START END
;RETURNS: BC
;*********************
SIZE:
	CALL	PARM2	;H,L=START,D,E=END
	PUSH	A
	MOV		A,E
	SUB		L
	MOV		C,A
	MOV		A,D
	SBB		H
	MOV		B,A
	INX		B
	POP		A
	RET
;
;***********************************
;PARM2 READ 2 PARMS INTO H,L AND D,E
;**********************************
PARM2:
	CALL	IHEX
	MOV		D,H
	MOV		E,L		;USE SAME FOR DEFAULT
PARM6:
	CPI		0AH		;TERMINATED?
	RZ				;YES
	CPI		' '
	JZ		PARM3
	CPI		','
	RNZ				;INVALID
PARM3:
	XCHG
	CALL	IHEX	;2ND PARM
	XCHG
	RET
PARM4:
	CALL	SIZE	;INPUT  START, END, VALUE
	JMP 	PARM3	;CONVERT TO HL=START, BC=SIZE, DE=VALUE
PARM5:
	CALL	IHEX
	LXI		D,0
	JMP		PARM6
;

;*******************
;SYSTEM SUBROUTINES
;*******************
;
;*********************************
;LOOKUP IN 3 BYTE TABLE
;*********************************
LOOKUP:
	MOV B,A		;SAVE
	MOV A,M
	ORA A
	RZ		;NOT FOUND Z FLAG SET
	CMP B		;MATCH?
	INX H
	JZ LOOKM	;YES
	INX H
	INX H		;TRY NEXT ENTRY
	JMP LOOKUP+1
LOOKM
	MOV B,M
	INX H
	MOV H,M
	MOV L,B
	ORA A		;SET NOT ZERO
	RET

;
;*********************************
;I/O DRIVERS
;*********************************
SERINA:
	IN   SERCTLA	;SERIAL PORT CONTROL PORT
	ANI  SERRX
	RZ				;A=0
	IN   SERDATA
	RET
;
SERINB:
	IF ISIO2
	IN   SERCTLB	;SERIAL PORT B
	ANI  SERRX
	RZ				;A=0
	IN   SERDATB
	ENDIF ;ISIO2
	IF ROM$MON
	IF CSS1
	XRA	A			;A=0
	ENDIF ;CSS1
	IF ROM$MON
	RET
	ENDIF ;ISIO2
	IF ROM$MON
;
;*********************************
SEROUTA:
	IN   SERCTLA
	ANI  SERTX
	JZ   SEROUTA	;WAIT UNTIL READY
	LDA  ASAVE		;GET OUTPUT CHAR
	OUT  SERDATA
	RET
;
IOLIST:
SEROUTB:
	IF ISIO2
	CALL IOLISTST
	JZ   SEROUTB	;WAIT UNTIL READY
	LDA  ASAVE		;GET OUTPUT CHAR
	OUT  SERDATB
	ENDIF ;ISIO2
	IF ROM$MON
	RET
;
IOLISTST:
	IF ISIO2
	IN  SERCTLB
	ANI SERTX
	ENDIF ;ISIO2
	IF ROM$MON
	IF CSS1
	XRA A			;NOT READY
	ENDIF ;CSS1
	IF ROM$MON
	RET
;
IOPUNCH:
IOREADER:
	MVI  A,1AH
	RET
;
;
;*********************************
;SYSTEM INPUT
;*********************************
IOCONIN:
	CALL IOCONST	;INPUT CHARACTER, IF ANY
	JZ   IOCONIN	;TRY AGAIN, IF NO INPUT
	RET
;
IOCONST:
	LDA		INDEV	;INPUT ALLOCATION BYTE
	ANI		SERFLAG	;TRY SERIAL PORT 'A'?
	CNZ		SERINA	;YES
	RNZ				;Z FLAG SET IF NO INPUTS.
;
	LDA		INDEV
	ANI		SERFLGB	;TRY SERIAL PORT 'B'?
	CNZ		SERINB	;YES
	RET				;Z FLAG SET IF NO INPUTS.
;
;
;*********************************
;SYSTEM OUTPUT
;*********************************
IOCONOUT:
	MOV		A,C
SYSOUT:
	STA  ASAVE	;SAVE ACCUM
	LDA	QUIET
	ANA	A
	RNZ
	PUSH H		;SAVE HL
	LXI  H,OUTDEV	;OUTPUT SELECT BYTE
;
	MOV  A,M
	ANI  SERFLAG	;SERIAL?
	CNZ  SEROUTA
;
	MOV  A,M
	ANI  SERFLGB	;SERIALB?
	CNZ  SEROUTB
	LDA	ASAVE
	POP	H
	RET

;
;*****************************************
;SYSIN READ CHAR AND ECHO TO SYSTEM DEVICE
;  AND CONVERT TO UPPER CASE
;*****************************************
SYSIN:
	CALL IOCONIN	;READ NEXT CHAR TYPED
	ANI  7FH		;REMOVE PARITY BIT
	CPI  0DH		;WAS IT A RETURN?
	JZ   CRLF		;YES.  PRINT CR AND LF
	CPI  0AH		;WAS IT LINE-FEED?
	JZ   SYSIN		;YES, JUNK IT
	CPI  1AH		;WAS IT A CONTROL ^Z ?
	JZ   SYSIN		;YES, JUNK IT
	CPI  03H		;WAS IT A CONTROL ^C ?
	JZ   PRMPTSP	;YES.  RESET STACK AND GO ON TO NEXT COMMAND
	CPI  15H		;WAS IT A CONTROL ^U ?
	JZ   PRMPTSP	;YES.  RESET STACK AND GO ON TO NEXT COMMAND
	CALL UPPER		;CONVERT TO UPPER CASE
	JMP SYSOUT		;ECHO CHARACTER
;
UPPER:
	CPI  'A'+20H	;LOWER CASE A
	RC		;RETURN IF < L.C. A
	CPI  'Z'+21H	; L.C. Z +1
	RNC		;RETURN IF > L.C. Z
	XRI  20H	;CONVERT TO UPPER CASE
	RET

;
;*****************************************
; PRINT NULL TERMINATED STRING
;*****************************************
SYSMSGCR:
	CALL CRLF
SYSMSG:
	MOV  A,M	;GET NEXT CHAR
	ORA A		;IS IT TERMONATOR
	RZ			;YES,ALL DONE
	CALL SYSOUT	;OUTPUT IT TO SYSTEM DEVICE
	INX H
	JMP SYSMSG

;
;*****************************
;CRLF CARRIAGE RETURN/LINE FEED
;*****************************
CRLF:
	MVI A,0DH
	CALL SYSOUT
	MVI A,0AH
	JMP  SYSOUT
;
;***********************
;OUTPUT HEX ASCII VALUE
;***********************
OHEX:
	PUSH A
	RRC
	RRC
	RRC
	RRC
	CALL HBIAS	;BINARY TO ASCII
	POP A
HBIAS:
	ANI 0FH		;MASK NIBBLE
	ADI 90H
	DAA
	ACI 40H
	DAA
	JMP  SYSOUT
;
;************************************
;OHEXHL-OUTPUT H,L REG TO SYSTEM OUTPUT
;************************************
OHEXHL:
	MOV  A,H
	CALL OHEX
	MOV A,L
OHEXB:
	CALL OHEX
SPACE:
	MVI A,' '
	JMP  SYSOUT

;
;************************************
; PRINT CHAR IN 'A' FOLLOWED BY '='
;************************************
PRINT$EQU:
	CALL SYSOUT
	MVI A,'='
	JMP  SYSOUT
;
;***************************
;INPUT 16 BIT HEX VALUE FROM
;SYSTEM INPUT DEVICE
;***************************
IHEX:
	LXI H,0		;DEFAULT VALUE
	CALL SYSIN
	PUSH A
	CALL ASCBI	;CONVERT TO ASCII
	JNC IHEX1	;VALID DIGIT
	POP A
	RET		;A=FIRST INVALID CHAR
IHEX1:
	DAD H
	DAD H
	DAD H
	DAD H
	ADD L
	MOV L,A		;MERGE IN NEW DIGIT
	POP A
	JMP IHEX+3
;
;********************************
;ASCII TO BINARY CONVERSION
;********************************
ASCBI:
	SUI 30H
	RC
	CPI 10
	JC ASCBI1
	SUI 17
	RC
	ADI 10
	CPI 16
ASCBI1
	CMC
	RET
;
;********************************
;PRINT HL AND 16 BIT MEMORY AT HL
;********************************
SRCPNT:
	CALL PNTMEM
	MOV  A,M	;BYTE 2
SRCPNT1:
	CALL OHEX
	RET
PNTMEM:
	CALL CRLF
	DCX  H		;BACK UP 1
	CALL OHEXHL
	MOV  A,M
	CALL OHEXB
	INX  H
	RET

;
;********************************

BAUDTBL:
	IF CSS1
	DB	19H		;19.2K
	DW	CBD192
	DB	96H		;9600 baud
	DW	CBD9600
	DB	01H		;110 baud (2 stop bits)
	DW	CBD110	
	DB	03H		;300 baud
	DW	CBD300
	DB	48H		;4800 baud
	DW	CBD4800
	DB	24H		;2400 baud
	DW	CBD2400
	DB	12H		;1200 baud
	DW	CBD1200
	DB	06H		;600 baud
	DW	CBD600
	ENDIF	;CSS1
	IF ROM$MON
	DB 0		;END OF TABLE
CMDTBL:
	DB 'A'
	DW 0		;NA
	DB 'B'
	DW BAUDSEL	;SELECT BAUD RATE
	DB 'C'
	DW CALL1	;CALL ADDRESS WITH RETURN	
	DB 'D'
	DW DISP		;DISPLAY MEMORY
	DB 'E'
	DW ENTR		;EXAMINE AND ENTER INTO MEMORY
	DB 'F'
	DW FILL		;FILL MEMORY
	DB 'G'
	DW	0		;NA
	DB 'H'
	DW INTEL	;LOAD INTEL HEX FORMAT
	DB 'I'
	DW INPORT	;INPUT FROM SPECIFIED PORT
	DB 'J'
	DW JUMP		;JUMP TO ADDRESS
	DB 'K'
	DW 0		;NA
	DB 'L'
	DW 0		;NA
	DB 'M'
	DW MOVE		;MOVE MEMORY BLOCK
	DB 'N'
	DW 0		;NA
	DB 'O'
	DW OUTPORT	;OUTPUT TO SPECIFIED PORT
	DB 'P'
	DW 0		;NA
	DB 'Q'
	DW 0		;NA
	DB 'R'
	DW 0		;NA
	DB 'S'
	DW SEARCH	;16 BIT MASKED SEARCH
	DB 'T'
	DW MEMTEST	;TEST MEMORY
	DB 'U'
	DW 0		;NA
	DB 'V'
	DW CMPBLK	;COMPARE MEMORY BLOCKS
	DB 'W'
	DW 0		;NA
	DB 'X'
	DW XMODEM	;BINARY LOAD
	DB 'Y'
	DW RELIO	;RELOCAT I/O RAM
	DB 'Z'
	DW 0
 	DB ':'
	DW TBLSET2	;SET UP FOR SECOND CMD TABLE
	DB	0		;END OF TABLE
CMDTBL2
	DB	'<'
	DW	GETOS	;GET SYSTEM
	DB	'>'
	DW	PUTOS	;PUT SYSTEM
	DB	'B'
	DW	TRYBOOT	;GET SYSTEM
	DB	'D'
	DW	FSETDMA	;SET DMA ADDRESS
	DB	'E'
	DW	ESTATUS	;EXTENDED STATUS
	DB	'F'
	DW	FORMAT	;FORMAT FLOPPY DISK
	DB	'G'
	DW	GSTATUS	;GENERAL STATUS
	DB	'H'
	DW	FDPH	;GET DPH BLOCK
	DB	'I'
	DW	ALINPUT	;INPUT ALLOCATION
	DB	'L'
	DW	LOG$PHY
	DB	'M'
	DW	MAPLUN	;MAP LOGICAL->PHYSICAL
	DB	'O'
	DW	ALOUTPT	;OUTPUT ALLOCATION
	DB	'P'
	DW	SHOWPARMS
	DB	'R'
	DW	FREAD	;READ SECTOR FROM DISKETTE
	DB	'S'
	DW	SEEK	;FORCE PHYSICAL SEEK
	DB	'T'
	DW	TRACE	;TRACE OMNI TOGGLE
	DB	'U'
	DW	FUNIT	;SET DEFAULT UNIT#
	DB	'V'
	DW	VERIFY	;VERIFY FLOPPY DISK
	DB 'W'
	DW	FWRITE	;WRITE SECTOR TO DISKETTE
	DB	'X'
	DW	XMODE	;SET WRITE$MODE
	DB	'Z'
	DW	RESET	;RESET OMNIDISK CONTROLLER
	DB 0		;END OF TABLE
;******************************************
;SYSTEM MESSAGES
;*****************
SIGNON:
	DB	'(C)1984  MONITOR WITH OMNIDISK '
	IF NOT DMA
	DB	'NON-'
	ENDIF ;NOT DMA
	IF ROM$MON
	DB	'DMA DEBUG',0DH,0AH,0

	IF CSS1
MSG6	DB 'INVALID BAUD',0
MSGSER	DB 'BAUD SERIAL',0DH,0AH,0
	ENDIF ;CSS1
	IF ROM$MON

;
;******************************************
; OMNIDISK CONTROLLER EXTENSIONS
;******************************************

;
;********************************
;	UNIT
;********************************
FUNIT:
	LXI		H,DEVICE
	MOV		C,M		;SAVE OLD VALUE
	CALL	EBYTE	;MODIFY BYTE
	MOV		A,M		;GET NEW VALUE
	CPI		1CH+1	;>1C?
	JC		FSEL	;NO
	MOV		M,C		;YES, RESTORE OLD VALUE
	JMP		ERR		;REPORT INVALID
FSEL:
	MVI		A,'U'
	CALL	PRINT$EQU
	MOV		A,M		;A=DEVICE#
	STA		UNIT	;SET UNIT#
	JMP		OHEX	;DISPLAY IT

;
;********************************
;	SET WRITE$MODE
;********************************
;0=Normal, 1=Directory, 2=Random_Access
XMODE:
	LXI		H,WRITEA
	MOV		C,M		;SAVE OLD VALUE
	CALL	EBYTE	;MODIFY BYTE
	MOV		A,M		;GET NEW VALUE
	CPI		2+1		;>2?
	JC		XM$OK	;NO
	MOV		M,C		;YES, RESTORE OLD VALUE
	JMP		ERR		;REPORT INVALID
XM$OK:
	MVI		A,'W'
	CALL	PRINT$EQU
	MOV		A,M		;A=WRITE$MODE
	JMP		OHEX

;
;********************************
;	SETDMA ADDR
;********************************
FSETDMA:
	CALL	IHEX		;HL=DMA ADDRESS
	SHLD	TMAADR		;SET DEFAULT DMA ADDRESS
	MOV		C,L
	MOV		B,H
	CALL	SETDMA
	JMP		OHEXHL

;
;********************************
;	GENERAL STATUS
;********************************
GSTATUS:
	CALL	ONELIST
	DB		OC$GENS
	CALL	INCHAR		;GET GENSTATUS RESULT
	JMP		OHEXB		;DISPLAY IT

;
;********************************
;	EXTENDED STATUS
;********************************
ESTATUS:
	CALL	GET$EXTS
	JMP		FULL$EXTS

;
;********************************
;	MAPLUN
;********************************
MAPLUN:
	CALL	PARM2	;LUN#,PHY#
	CPI		'?'		;WAS '?' ENTERED
	JZ		GETMAPS	;YES, DISPLAY LUN MAP
	MOV		A,L		;L=LUN#
	CPI		0FH+1	;>15?
	JNC		ERR		;YES
	MOV		A,E		;E=PHY#
	CPI		10H		;<10?
	JC		GETMAP	;YES, GET MAP
	CPI		1CH+1	;>1C?
	JNC		ERR		;YES
; NOW MAP LUN
	CALL	ONELIST	;SEND COMMAND TO OMNI
	DB	OC$DLDS		;OMNI COMMAND: Define Logical Device Mapping
	MOV	A,L			;LUN#
	CALL SENDCMD	;SEND TO OMNI
	MOV	A,E			;PHY#
	JMP	 SENDCMD	;SEND TO OMNI
; RETURN MAP OF LUN
GETMAP:
	CALL	SPACE
	MVI		A,'L'
	CALL	SYSOUT
	MOV		A,E
	CALL	OHEX
	MVI		A,'='
	CALL	SYSOUT
	CALL	ONELIST	;SEND COMMAND TO OMNI
	DB		OC$GLDS	;OMNI COMMAND: Get Logical Device Map
	MOV		A,L		;LUN#
	CALL	SENDCMD
	CALL	INCHAR	;READ VALUE
	JMP		OHEX
; DISPLAY LUN -> PHY MAPPING
GETMAPS:
	LXI		B,000FH		;B=00, C=0F
GMAPS1:
	CALL	CRLF
	MVI		A,'L'
	CALL	SYSOUT
	MOV		A,B
	CALL	OHEX
	MVI		A,'='
	CALL	SYSOUT
	CALL 	ONELIST
	DB		OC$GLDS		;OMNI COMMAND: Get Logical Device Mapping
	MOV		A,B
	CALL 	SENDCMD		;LUN
	CALL	INCHAR		;READ VALUE
	CALL	OHEX
	INR		B
	DCR		C
	JP		GMAPS1		;IF WE NEED TO ZAP MORE UNITS
	RET

;
;********************************
;	SEEK (FORCED)
;********************************
SEEK:
	CALL	IHEX		;HL=TRACK#
	SHLD	TRACK		;SAVE AS CURRENT TRACK#
	SHLD	DTRACK		;SAVE AS DEFAULT TRACK#
	CALL	SPARM		;SEND PARAMETERS
SEEK1:
	IN		OMNIDATA
	CALL	ONELIST
	DB		OC$SSEK	;OMNI COMMAND: SEEK PHYSICAL TRACK
	MOV		A,L
	CALL	SENDCMD		;P1: TRACK LOWER BYTE
	MOV		A,H
	JMP		SENDCMD		;P2: TRACK UPPER BYTE

;
;********************************
;	TRACE
;********************************
TRACE:
	LDA		TRACEF
	CMA				;TOGGLE TRACE FLAG
	STA		TRACEF
	JMP		OHEX

;
;********************************
;	LOG$PHY I/O
;********************************
LOG$PHY:
	LXI		H,LOGSEC
	CALL	EBYTE	;UPDATE FLAG: 0=LOGICAL SECTOR I/O
					;NON-ZERO IS NUMBER OF RECORDS TO TRANSFER
	MVI		A,'R'
	CALL	PRINT$EQU
	MOV		A,M
	JMP		OHEX

;
;********************************
;	LOAD BOOT FROM DISKETTE
;********************************
TRYBOOT:
	CALL	SRETA		;SET ERROR RETURN ADDRESS
	CALL	ONELIST
	DB	OC$UNIT			;SET DRIVE 0 (A:)
	LDA		UNIT
	CALL	SENDCMD		;P1: UNIT#
	CALL	CMDLIST
	DB	3
	DB	OC$BOOT,1		;READ FIRST SECTOR
	DB	OC$GENS			;GET GENERAL STATUS
	LXI		H,0000		;PUT BOOT INTO LOCATION 0000
	CALL	GETDAT		;READ BOOT SECTOR
	CALL	CKERR		;TEST FLAGS
;	... FALL INTO BOOTOK

;******************************************
;	EXECUTE BOOT ROUTINE
;******************************************
BOOTOK:					;SYSTEM CONTROL PORT FOR MAPPINGS
	LXI		H,0			;HL=JUMP ADDRESS
	MVI		A,0EBH		;8080 XCHG OR 8088 JMPS INSTRUCTION
	CMP		M			;TEST FIRST BYTE
	JZ		BOOT86		;IF 8086/8088 BOOT IN PROGRESS
	MVI		A,0E5H		;EMPTY SECTOR
	CMP		M			;TEST FIRST BYTE
	RZ					;BACK TO ROM
BOOTOK1:
	PCHL				; Start boot code.
BOOT86:
	IF COMPUPRO85
	IN		SWAP
	ENDIF ;COMPUPRO85
	IF ROM$MON
	RET					;BACK TO ROM
; READ BOOT BLOCK
ABOOT:
	CALL	CMDLIST
	DB	5
	DB	OC$UNIT,0		;SET DRIVE 0 (A:)
	DB	OC$BOOT,1		;READ FIRST SECTOR
	DB	OC$GENS			;GET GENERAL STATUS
	LXI		H,0000		;READ BOOT SECTOR INTO LOCATION 0000
;	... FALL INTO FGETDAT

;********************************************************
;	SUBROUTINE FOR BLOCK READ
;
;	NOTE:	THIS SUBROUTINE READS DATA UNTIL
;		THE OMNI CONTROLLER ACCEPTS THE
;		GENERAL STATUS COMMAND OR TIMEOUT
;********************************************************
FGETDAT:
	LXI		B,0			;B,C=#READ STATUS TIMEOUT
GFLAGS:
	IN		OMNISTAT
	RRC					;Rotate right to test bit 0
	JC		GREADY		;Date READY?
	DCX		B			;Timeout yet?
	MOV		A,B			;B,C
	ORA		C			;=0?
	JNZ		GFLAGS		;Try again?
	MVI		A,0FFH		;Reached timeout
	RET					;Return with error set
; Test for data or gen$status
GREADY:
	ANI		40H			;(WHAT DO WE HAVE HERE: DATA -OR- GEN STATUS?)
	IN		OMNIDATA	;TAKE IT, WHATEVER IT IS
	JZ		GDONE		;IF IT IS GENERAL STATUS, THEN RETURN
	MOV		M,A			;ELSE...PUT INTO BUFFER
	LDA		TRACEF		;Test TRACE flag
	ORA		A			;Non-zero for tracing
	MOV		A,M			;Read back byte
	CNZ		OHEX		;Show data just read
	INX		H			;Advance RAM pointer
	JMP		FGETDAT		;KEEP ON KEEPING ON
GDONE:
	PUSH	PSW			;SAVE FLAGS
	LDA		TRACEF
	ORA		A
	CNZ		CRLF
	POP		PSW
	RET					;EXIT WITH FLAGS SET

;
;********************************
;	GET OS FROM DISKETTE
;********************************
GETOS:
	CALL	IHEX		;GET #RECORDS
	MOV		A,L
	CPI		1			;IS <1?
	JNC		GETOS1		;NO
	MVI		A,1			;YES, DEFAULT TO 1 RECORD
GETOS1:	
	CPI		0FFH		;>FE?
	JNC		ERR			;YES
	STA		LINE		;SAVE #RECORDS
	CALL	QSPARM		;SET PARAMETERS
	CALL	CLR$JUNK	;CLEAR OMNI

; SHOW #RECORDS TO READ
	CALL	CRLF
	MVI		A,'R'
	CALL	PRINT$EQU
	LDA		LINE
	CALL	OHEXB
;	IN		OMNIDATA	;READ&TRASH TO RESET ANY TRASH IN REG

; SEND READ$SYSTEM COMMAND
	CALL	SRETA		;SET RE-TRY ADDRESS
	CALL	ONELIST
	DB		OC$BOOT		;BOOT OS
	LDA		LINE
	CALL	SENDCMD		;P1: #RECORDS
	CALL	ONELIST
	DB		OC$GENS		;GET GENSTATUS ON COMPLEATION

	LHLD	DMAADR		;READ BOOT SECTOR DMAADR
	CALL	GETDAT		;READ SECTOR OR GENSTATUS
						;RETURN FLAGS SET
	JMP		CKERR		;TEST FOR ERROR

;
;****************************************
;	PUT OS TO DISKETTE
;****************************************
PUTOS:
	CALL	IHEX		;GET NUMBER OF RECORDS
	MOV		A,L
	CPI		0			;0?
	JNZ		PUTOS1		;NO
	MVI		A,1			;SET TO 1
PUTOS1:
	CPI		0FFH		;>FE?
	JNC		ERR			;YES
	STA		LINE		;SAVE #RECORDS
	CALL	QSPARM		;SET PARAMETERS
	CALL	CLR$JUNK	;CLEAR OMNI

; SEND WRITE$SYSTEM COMMAND
	CALL	ONELIST
	DB		OC$SWRT		;WRITE SYSTEM
	LDA		LINE		;A=#RECORDS
	CALL	SENDCMD		;P2: NUMBER OF RECORDS TO WRITE

; CHECK GEN$STATUS
	CALL	DSKERR		;GET GENERAL STATUS BEFORE DATA XFER
	LHLD	DMAADR		;HL=DMA BUFFER PTR
	MVI		B,1			;ON SCREEN RECORD COUNTER
	LDA		TRACEF		;ARE WE TRACING?
	ORA		A
	PUSH	PSW			;SAVE TRACE FLAG STATUS
; MAIN LOOP
PUTOS2:
	MVI		A,'<'
	CALL	SYSOUT
	MOV		A,B
	CALL	OHEX		;SHOW ON CONSOLE CURRENT RECORD#
	MVI		A,'>'
	CALL	SYSOUT
	MVI		C,128		;SIZE OF ONE SECTOR
; ONE SECTOR TRANSFER LOOP
PUTOS3:
	CALL	IOCONST		;Keypress?
	JZ		PUTOS4		;NO
	SUI		'C'-40H		;YES, IS IT CTRL=C?
	JZ		PRMPTSP		;Yes, ABORT
PUTOS4:
	IN		OMNISTAT	;CONTROLLER STATUS
	ADD		A			;OK TO SEND DATA?
	JC		PUTOS4		;NO
	MOV		A,M			;YES
	OUT		OMNIDATA	;SEND DATA BYTE
	IN		OMNIDATA
	ORA		A
	JNZ		PUTOS5		;DONE?
	POP		PSW
	PUSH	PSW
	MOV		A,M			;GET BYTE FROM MEMORY
	CNZ		OHEX		;OUTPUT TO CONSOLE
	INX		H			;ADVANCE DMA BUFFER PTR
	DCR		C			;ALL DONE?
	JNZ		PUTOS3		;128 BYTES SENT?
	POP		PSW
	PUSH	PSW
	CNZ		CRLF
	LDA		LINE
	CMP		B			;ALL DONE?
	JZ		PUTOS5		;YES
	INR		B			;COUNT RECORD SENT
	JMP		PUTOS2		;NEXT RECORD?
PUTOS5:
	POP		PSW
	CNZ		CRLF
;
; CHECK GEN$STATUS
DSKERR:
	IN		OMNIDATA	;READ BYTE
	ORA		A			;SHOULD BE 0
	RZ
	PUSH	PSW
	LXI		H,ERR1
	CALL	SYSMSGCR	;DISK I/O ERROR
	POP		PSW
	JMP		OHEX

;
; Clear junk
CLR$JUNK:
	IN		OMNIDATA
	ORA		A
	RZ
; SEE IF GET GEN$STATUS WILL CLEAR CONTROLLER
CLR$LOOP
	CALL	DLY
	MVI		A,'.'
	CALL	SYSOUT
	CALL	ONELIST
	DB		OC$GENS
; HAS JUNK, TEST FOR CTRL-C EXIT
	CALL	IOCONST		;Keypress?
	JZ		CLR$JUNK	;NO
	SUI		'C'-40H		;YES, IS IT CTRL-C?
	JZ		PRMPTSP		;Yes, ABORT
	JMP		CLR$JUNK


;****************************************
;	R TRACK,SECTOR[,BUFFER,UNIT]
;****************************************
FREAD:
	CALL	LOAD		;LOAD PARAMETERS
	LDA		LOGSEC		;GET SECTOR I/O FLAG
	ANA		A			;Test
	jz		read		;Normal logical sector read

; PHYSICAL SECTOR READ
	CALL	SRETA
	CALL	CMDLIST
	DB		2
	DB		OC$PREA
	DB		OC$GENS
	IF NOT DMA
	LHLD	DMAADR
	CALL	FGETDAT
	CALL	CKERR		;CHECK FOR ERRORS
; HOW MANY BYTES IN SECTOR
	XCHG				;DE=LAST BYTE READ
	LHLD	DMAADR		;HL=STARTING ADDRESS
	CALL	SIZE+3		;COMPUTE SIZE OF TRANSFER
	MVI		A,'R'
	CALL	PRINT$EQU
	MOV		A,B			;B IS NUMBER OF RECORDS
	STA		LOGSEC		;SAVE IT
	JMP		OHEX		;COMPLETE DISPLAY
	ENDIF ;NOT DMA
	IF DMA
	JMP		DMA$RW
	ENDIF ;DMA
	IF ROM$MON


;****************************************
;	W TRACK,SECTOR[,BUFFER,UNIT]
;****************************************
FWRITE:
	CALL	LOAD		;LOAD PARAMETERS
	LDA		WRITEA		;GET WRITE$MODE
	MOV		C,A			;Save
	LDA		LOGSEC		;GET SECTOR I/O FLAG
	ANA		A			;Test
	jz		write		;Normal logical sector write

; PHYSICAL SECTOR WRITE
	MOV		B,A			;SET NUMBER OF RECORDS
	CALL	SRETA
	CALL	ONELIST
	DB		OC$PWRT
	MOV		A,C
	CALL	SENDCMD
	IF NOT DMA
	CALL	INCHAR
	ORA		A
	JNZ		CKERR
PWNXT:
	MVI		C,128
	LHLD	DMAADR
PWRITE:
	IN		OMNISTAT
	ADD		A
	JC		PWRITE
	MOV		A,M
	OUT		OMNIDATA
	INX		H
	DCR		C
	JNZ		PWRITE
	DCR		B
	JNZ		PWNXT
	XRA		A
	ENDIF ;NOT DMA
	IF ROM$MON
	IF DMA
	CALL	INCHAR
	ENDIF ;DMA
	IF ROM$MON
	JMP		CKERR


;****************************************
;	Get DPH
;****************************************
FDPH:
	CALL	SPARM
	LHLD	DMAADR		;HL=DMA BUFFER
	call	sreta		;SET RETRY ADDRESS FOR CKERR
	push	h			;SAVE DPH ADDRESS
	call	cmdlist
	DB		5			;LENGTH OF LIST
	DB		OC$TRAK		;OMNI COMMAND: SELECT TRACK (SEEK)
	DW		4			;GO TO TRACK 4 FOR GETDPB FUNCTION
	DB		OC$GDPB		;OMNI COMMAND: GET DPB
	DB		OC$GENS		;OMNI COMMAND: GET GENERAL STATUS
	call	fgetdat
	pop		h			;DPH ADDRESS
	jmp		ckerr		;CHECK ERROR, GIVE ERROR MSG ETC


;********************************************************
;	GET EXTENDED STATUS
;	THIS IS THE ONLY WAY TO ZERO GENSTAT
; gen-status phy-sector ST-0 ST-1 ST-2 Cyl H Sec N 
;********************************************************
GET$EXTS:
	LXI		H,STATUS	;EXTENDED STATUS BUFFER
	LDA		TRACEF		;A=CURRENT TRACE FLAG
	PUSH 	PSW			;SAVE IT
	XRA		A			;A=0
	STA		TRACEF		;TRACE OFF
	CALL	ONELIST		;SEND COMMAND
	DB		OC$EXTS		;OMNI COMMAND: GET EXTENDED STATUS
	MVI		B,9			;LENGTH OF EXTENDED STATUS LIST
GETEX1:
	CALL	INCHAR		;GET EXTENDED STATUS BYTE FROM OMNI
	MOV		M,A			;INTO BUFFER
	INX		H			;NEXT BUFFER ADDRESS
	DCR		B			;ALL DONE?
	JNZ		GETEX1		;IF NO MORE EXTENDED STATUS
	POP		PSW			;RESTORE TRACE FLAG
	STA		TRACEF		;SET TRACE FLAG
	RET

;**************************************************
;	DISPLAY EXTENDED STATUS
; gen-status phy-sector ST-0 ST-1 ST-2 Cyl H Sec N
;**************************************************
FULL$EXTS:
	LXI 	H,ESHDR
	CALL	SYSMSGCR	;PRINT <CR,LF>"GENS PHY#..."<CR,LF>
	MVI		E,4			;E=SPACES
	JMP		DSP$EXTS+2
DSP$EXTS:
	MVI		E,1			;
	MVI		C,9			;LENGTH OF EXTENDED STATUS LIST
	LXI		H,STATUS	;HL=STATUS BUFFER
DSP$NEXT:
	MOV		B,E			;B=GET FORMAT CNTROL
	MOV		A,M			;GET BYTE
	INX		H			;NEXT STATUS BYTE
	CALL	OHEX		;SEND TO CONSOLE
DSP$SPCS:
	CALL	SPACE		;SEND SPACE
	DCR		B			;DONE WITH FORMATTING?
	JNZ		DSP$SPCS	;NO
	DCR		C			;ALL DONE?
	JNZ		DSP$NEXT	;IF NO MORE EXTENDED STATUS
	JMP		CRLF		;END WITH CR,LF
ESHDR:	DB 'GENS  PHYS# ST-0  ST-1  ST-2  CYL#  HEAD  SECT# BYTES',0DH,0AH,0

;*****************************************
;	GET PARAMETERS: TRACK, SECTOR, [DMA ADDRESS, UNIT#]
;*****************************************
LOAD:
	CALL	SETDEF	;SET CONTROLLER DEFAULTS
	LXI		D,-1	;TEST VALUE
	CALL	IHEX	;HL=vvvv<cr>
	STA		ASAVE	;STORE CHAR FOLLOWING HEX CHARS
	CALL	PARM6	;Get Sector#
	INR		D		;Valid Sector#
	JZ		SPARM	;No, ONLY Track# entered

; SAVE TRACK, SECTOR#
	SHLD	TRACK	;STORE TRACK#
	SHLD	DTRACK	;AND AS DEFAULT TRACK#
	MOV		A,E
	STA		RECORD	;STORE SECTOR#
	STA		SECTOR	;AND AS DEFAULT RECORD#

; TEST FOR OPTIONAL PARAMETERS
	LDA		ASAVE
	CPI		0AH		;WAS THERE A RETURN TYPED?
	JZ		SPARM	;YES, ALL DONE.

; GET OPTIONAL DMA BUFFER, UNIT#
	CALL	PARM5	;HL = DMA BUFFER, DE = UNIT#
	SHLD	DMAADR	;STORE ADDR OF DMA BUFFER
	SHLD	TMAADR	;AND SET DEFAULT DMA BUFFER
	MOV 	A,E		;UNIT#
	CPI		1CH+1	;>1C?
	JNC 	ERR		;YES
	STA		UNIT	;STORE UNIT#
	JMP		SPARM
;
; SET PARAMETERS QUIETLY
QSPARM:
	MVI		A,0FFH
	STA		QUIET
	CALL	SPARM
	XRA		A
	STA		QUIET
	RET
;
; SEND PARAMETERS TO OMNI CONTROLLER
;
SPARM:
	PUSH	H
	PUSH	B
	LXI		H,UNIT	;BASE OF PARAMETERS
	MOV		C,M		;UNIT#
	CALL	SELECT$UNIT
	MVI		A,'U'
	CALL	PRINT$EQU
	MOV		A,C
	CALL	OHEXB
	INX		H
	MOV		C,M		;TRACK - LOWER
	INX		H
	MOV		B,M		;TRACK - UPPER
	CALL	SETTRK	;SET TRACK
	MVI		A,'T'
	CALL	PRINT$EQU
	MOV		A,B
	CALL	OHEX
	MOV		A,C
	CALL	OHEXB
	INX		H
	MOV		C,M		;RECORD#
	CALL	SETSEC	;SET SECTOR
	MVI		A,'S'
	CALL	PRINT$EQU
	MOV		A,C
	CALL	OHEXB
	INX		H
	MOV		C,M		;DMA - LOWER
	INX		H
	MOV		B,M		;DMA - UPPER
	CALL	SETDMA	;SET DMA
	MVI		A,'D'
	CALL	PRINT$EQU
	MOV		A,B
	CALL	OHEX
	MOV		A,C
	CALL	OHEXB
	POP		B
	POP		H
	RET

;
; SELECT$UNIT EXPECTS UNIT# IN REG. C
SELECT$UNIT:
	CALL	CVT$UNT	;CONVERT UNIT#
	CALL	ONELIST
	DB		oc$unit	;OMNI COMMAND: SELECT LOGICAL UNIT
	MOV		A,C		;A=DEVICE#
	JMP		SENDCMD	;...to OMNI

;
; EXPECTS UNIT# IN REG. C
CVT$UNT:
	MOV		A,C
	CPI		0FH		;Logical unit?
	RC				;YES, NOTHING TO DO.
	ANI		0FH		;MASK BITS
	MOV		C,A
	CPI		3H		;8" DRIVE?
	RC				;YES, ALL DONE
	SUI		4H		;CONVERT 5" DRIVE
	MOV		C,A		;SAVE RESULT IN REG. C
	RET

;
;*****************************************
;	SHOW PARAMETERS: UNIT#, TRACK,
;   SECTOR, DMA ADDRESS, WRITE$MODE,
;   LOGICAL/PHYSICAL RECORDS
;*****************************************
SHOWPARMS:
	MVI		A,'U'
	CALL	PRINT$EQU
	LDA		DEVICE
	CALL	OHEXB
	MVI		A,'T'
	CALL	PRINT$EQU
	LHLD	DTRACK
	CALL	OHEXHL
	MVI		A,'S'
	CALL	PRINT$EQU
	LDA		RECORD
	CALL	OHEXB
	MVI		A,'D'
	CALL	PRINT$EQU
	LHLD	DMAADR
	CALL	OHEXHL
	MVI		A,'W'
	CALL	PRINT$EQU
	LDA		WRITEA
	CALL	OHEXB
	MVI		A,'R'
	CALL	PRINT$EQU
	LDA		LOGSEC
	CALL	OHEX
	JMP		CRLF

;
;*****************************************
; Set CONTROLLER defaults
;*****************************************
SETDEF:
	LDA		DEVICE		;A=DEFAULT DEVICE
	STA		UNIT		;UNIT#
	LHLD	DTRACK		;HL=DEFAULT TRACK#
	SHLD	TRACK		;TRACK#
	LDA		SECTOR		;A=DEFAULT SECTOR#
	STA		RECORD		;SECTOR#
	LHLD	TMAADR		;HL=DEFAULT DMA BUFFER
	SHLD 	DMAADR		;SET CURRENT DMA BUFFER
	RET
;
;*****************************************
ERR:
	LXI		H,QUEST
	CALL	SYSMSG
	JMP		PRMPTSP
QUEST	DB   'INVALID',0

;*****************************************
;  RESET OMNIDISK CONTROLLER
;*****************************************
RESET:
	LDA		TRACEF
	ANA		A
	CNZ		CRLF
	CALL	CMDLIST
	DB		2
	DB		OC$INIT		;OMNI COMMAND: Re-Initialize Omnidisk Controller
	DB		OC$GENS
	CALL	INCHAR		;WAIT FOR GEN$STATUS

;*****************************************
;  INIT FLOPPY DISK TABLES
;*****************************************

;
;	INIT CONTROLLER.
;
INITFD:
	LDA		TRACEF
	ORA		A
	PUSH	PSW

;
;	UNDEFINE ALL LOGICAL-TO-PHYSICAL MAPPING
;
;	LXI		B,000FH		;B=00, C=0F
;INITFD1:
;	CALL 	ONELIST
;	DB		OC$DLDS		;OMNI COMMAND: Define Logical Device Mapping
;	MOV		A,C
;	CALL 	SENDCMD		;LUN
;	MOV		A,B
;	CALL 	SENDCMD		;PHY
;	DCR		C
;	JP		INITFD1		;IF WE NEED TO ZAP MORE UNITS
;	POP		PSW
;	PUSH 	PSW
;	CNZ		CRLF

;
;	Define DMA mode
;
	CALL	CMDLIST
	DB		2			;LENGTH OF LIST
	DB		OC$MODE		;OMNI COMMAND: SET DMA MODE
	IF NOT DMA
	DB		DMAPRI		;NOTE TO USERS WHERE DMA KILLS YOUR SYSTEM:
						;BIOS DOES NOT CAUSE ANY DMA
	ENDIF ;NOT DMA		;UNLESS MEMORY DISK IS USED.
	IF ROM$MON
	IF DMA
	DB		DMAPRI+80H	;BIOS USES DMA FOR READ/WRITE
	ENDIF ;DMA
	IF ROM$MON

	POP		PSW
	PUSH 	PSW
	CNZ		CRLF
;
;	DEFINE FLOPPY DISK PHYSICAL PARAMETERS
;
	CALL	CMDLIST
	DB		9			;LENGTH OF LIST
	DB		OC$SFDP
	DB		6			;Delay before write * 250ms
	DB		20			;Head unload time * 250ms
	DB		6			;8" FLOPPY STEP RATE IN ms
	DB		6			;5" FLOPPY STEP RATE IN ms
	DB		35			;8" FLOPPY HEAD LOAD TIME IN ms
	DB		0			;5" FLOPPY HEAD LOAD TIME IN ms
	DB		14			;8" FLOPPY HEAD SETTLE TIME (AFTER FD SEEK)
	DB		14			;5" FLOPPY HEAD SETTLE TIME (AFTER FD SEEK)
	POP		PSW
	CNZ		CRLF


;
;	DEFINE LOGICAL-TO-PHYSICAL MAPPINGS USED BY CURRENT SYSTEM
;
;	CALL	CMDLIST
;	DB	CBLEND-$-1		;LENGTH OF LIST
;	;DRIVES 0-1 ( A: & B: )
;	DB	OC$DLDS,00H,FDISK5+0	;DEFINE A:
;	DB	OC$DLDS,01H,FDISK5+1	;DEFINE B:
;	; DRIVES 2-15( C:-P: )
;	DB	OC$DLDS,02H,FDISK5+2	;DEFINE C:
;	DB	OC$DLDS,03H,FDISK5+3	;DEFINE D:
;	DB	OC$DLDS,04H,FDISK5+4	;DEFINE E:
;	DB	OC$DLDS,05H,FDISK5+5	;DEFINE F:
;	DB	OC$DLDS,06H,FDISK5+6	;DEFINE G:
;	DB	OC$DLDS,07H,FDISK5+7	;DEFINE H:
;	DB	OC$DLDS,08H,FDISK5+8	;DEFINE I:
;	DB	OC$DLDS,09H,FDISK5+9	;DEFINE J:
;	DB	OC$DLDS,0AH,FDISK5+10	;DEFINE K:
;	DB	OC$DLDS,0BH,FDISK5+11	;DEFINE L:
;	DB	OC$DLDS,0CH,FDISK5+12	;DEFINE M:
;	DB	OC$DLDS,0DH,FDISK5+13	;DEFINE N:
;	DB	OC$DLDS,0EH,FDISK5+14	;DEFINE O:
;	DB	OC$DLDS,0FH,FDISK5+15	;DEFINE P:
;CBLEND	EQU	$		;END OF LIST

;
;	RESET OMNI UNIT#,DMA,TRACK,SECTOR
;

;	CALL	CMDLIST		;SEND COMMAND TO OMNI
;	DB		2			;LENGTH
;	DB		OC$GLDS		;OMNI COMMAND: Get Logical Device Map
;	DB		0			;LUN#
;	CALL	INCHAR		;READ VALUE


	XRA		A			;A=0
	STA		DEVICE		;SET DEFAULT DEVICE
	STA		SECTOR		;SET SECTOR#
	STA		RECORD		;
	LXI		H,0000H		;HL=0000H
	SHLD	DTRACK		;SET DEFAULT TRACK
	LXI		H,TPA		;DEFAULT DMA
	SHLD	TMAADR		;SAVE DEFAULT DMA ADDRESS
	CALL	SETDEF		;SET DEFAULTS
	CALL	QSPARM		;COMMAND OMNI
	LXI		H,0			;TRACK#
	CALL	SEEK1		;SEEK TO TRACK ZERO
	RET

;*****************************************
;  FORMAT FLOPPY DISK
;*****************************************
; 0010 0000 - read list of available densities
; 0001 0000 - check # of sides, non-destructive
; 0001 0001 - check # of sides, destructive
; 0000 XXVF - Format/Verify
;      00 : normal, use 2 heads
;      01 : use head 0 only
;      10 : use head 1 only
;      11 : use head 0 only, normal
;        V - set V=1 for verify
;         F - set F=1 for format

;FDREL table
;Fmt	 Fmt	Type	Dens	Sec/	Bytes/	Notes
; #		Name	8/5"	S/D/Q	Track	Sector	-----------
;00		A		8"		S		26		 128	Standard 8"
;01		B		8"		S		15		 256
;02		C		8"		S		 8		 512
;03		D		8"		S		 4		1024
;04		E		8"		D		26		 256
;05		F		8"		D		15		 512
;06		G		8"		D		 8		1024	W/W Components
;07		A		5"		S		16		 128
;08		B		5"		S		17		 128
;09		C		5"		S		18		 128	Xerox
;0A		D		5"		S		 8		 256	Osborne
;0B		E		5"		S		10		 256
;0C		F		5"		S		 4		 512
;0D		G		5"		D		16		 256	Heath/NEC
;0E		H		5"		D		17		 256
;0F		I		5"		D		18		 256
;10		J		5"		D		 8		 512	IBM PC/XT - 8 Sector
;11		K		5"		D		 9		 512	IBM PC/AT - 9 Sector
;12		L		5"		D		10		 512
;13		M		5"		D		 4		1024
;14		N		5"		D		 5		1024
VERIFY:
	MVI		A,'V'
	STA		LINE
	MVI		B,0000$0010b	;VERIFY
	CALL	IHEX		;HL=FORMAT CODE
	MOV		A,L
	CPI		14H+1		;>14?
	JNC		ERR			;YES
	JMP		FMT
FORMAT:
	MVI		A,'F'
	STA		LINE
	MVI		B,0000$0001b	;FORMAT
	CALL	IHEX		;HL=FORMAT CODE
	MOV		A,L
	CPI		14H+1		;>14?
	JNC		GETFDREL	;YES
	CALL	FMT			;NO, BEGIN FORMAT
	RNZ					;DON'T VERIFY IF BAD FORMAT
	MVI		A,'V'
	STA		LINE
	MVI		B,0000$0010b	;VERIFY
	JMP		FIS8

FMT:
	MOV		D,A			;NO, SAVE FORMAT CODE
; SET LAST$TRACK BASED ON FLOPPY FORMAT CODE
	MVI		E,77-1		;SET TO 8" DRIVE
	CPI		07H
	JC		FIS8
	MVI		E,40-1		;SET TO 5" DRIVE
FIS8:
; SEND PARAMETERS TO OMNIDISK
	CALL	QSPARM
	CALL	CLR$JUNK

; READY FOR TRACK FORMAT
	LXI		H,0			;HL=TRACK TO FORMAT
	SHLD	TRACK

; FORMAT TRACK LOOP
FLOOP:
	CALL	IOCONST		;Keypress?
	JZ		FLOOP1		;No
	SUI		'C'-40H		;YES, IS IT CTRL=C?
	JZ		FDONE		;Yes.
; SHOW TRACK#
FLOOP1:
	MOV		A,L			;TRACK #
	ANI		07H
	CZ		CRLF
	LDA		LINE
	CALL	PRINT$EQU
	MOV		A,L			;CURRENT TRACK#
	CALL	OHEXB		;SHOW IT
;
; ISSUE FMTF COMMAND
	CALL	ONELIST
	DB		OC$FMTF		;OMNI COMMAND: FORMAT FLOPPY TRACK
	MOV		A,D			;P1: Format code
	CALL	SENDCMD
	MOV		A,B			;P2: Format/Verify mode
	CALL	SENDCMD
	IN		OMNIDATA	;CHECK GENSTAT
	ANA		A			;SHOULD BE 0
	JNZ		FBAD		;FORMAT TRACK FAILED
;
; More tracks to format?
	MOV		A,E			;A=Last track#
	CMP		L			;Test TRACK# low byte
	JZ		FDONE		;DONE

	INX		H			;INCREMENT TRACK #
;
; Next TRACK
	PUSH	B
	MOV		B,H
	MOV		C,L
	CALL	settrk
	POP		B
	JMP		FLOOP		;FORMAT NEXT TRACK
;
; RESET HEAD
FDONE:
	IN		OMNIDATA	;CHECK GENSTAT
	LXI		H,0
	JZ		SEEK1		;OK
;	... FALL INTO FBAD
; FORMAT TRACK ERROR
FBAD:
	PUSH	PSW			;SAVE ERROR CODE
	CALL	CRLF
	LXI		H,FMTMSG
	CALL	SYSMSG
	POP		PSW
	PUSH	PSW
	CALL	OHEX		;DISPLAY ERROR CODE
	CALL	CRLF
	CALL	FDONE
	POP		PSW
	RET
FMTMSG:
	DB	'Format track failed: ',0
GETFDREL:
	CALL	CMDLIST
	DB		3
	DB		OC$FMTF		;OMNI COMMAND: FORMAT FLOPPY TRACK
	DB		0			;P1: FORMAT CODE#
	DB		020H		;P2: READ LIST OF AVAILABLE DENSITIES
	LXI		H,0			;HL=WHERE TO PUT DATA
	CALL	FGETDAT
	CALL	OHEX		;OUTPUT STATUS BYTE
	RET
DLY:
	XRA	A
	DCR	A
	JNZ	DLY+1
	RET
;
;********************************************************
;********************************************************
;
;   ROM MONITOR MODIFIED FUNCTIONS
;
;********************************************************
;********************************************************
;
	IF ROM$MON
seldsk:
	lxi		h,0		;USED FOR <H>=0 AND IF SELECT ERROR
	mov		a,c
	cpi		ndisks	;MUST BE BETWEEN 0 AND NDISKS-1
	rnc				;IF INVALID DISK NUMBER

;	COMPUTE PROPER DISK PARAMETER HEADER ADDR

	call	onelist
	db		oc$unit	;OMNI COMMAND: SELECT LOGICAL UNIT
	mov		a,c
	jmp		sendcmd	;...to OMNI

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
	IF ROM$MON
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
	IF ROM$MON

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
	IF ROM$MON
	IF DMA
	jmp		dma$rw
	ENDIF ;DMA
	IF ROM$MON

;********************************************************
;	WRITE A LOGICAL SECTOR				*
;********************************************************
;	WRITE THE SELECTED CP/M SECTOR
;		AT ENTRY C:	0 - FOR NORMAL SECTOR WRITE
;					1 - WRITE DIRECTORY SECTOR
;					2 - WRITE SECTOR OF A NEW DATA BLOCK
;

write:
	mov		a,c			;Get WRITE$MODE
	sta		writea
	call	sreta
	call	onelist
	db		oc$writ		;OMNI COMAND: Write Logical Record
	lda		writea
	call	sendcmd		;Send P1
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
	IF ROM$MON
	IF DMA
dma$rw:
	call	inchar		;GET GENERAL STATUS AFTER DATA XFER
	ENDIF ;DMA
	IF ROM$MON

;********************************************************
;	SUBROUTINE FOR UNEXPECTED DRIVE ERRORS		*
;********************************************************

ckerr:
	ora		a
	rz					;IF NO ERROR
	lxi		h,ERR1		;OUT MESSAGE = <CR,LF>"DISK I/O ERROR -"
	call	sysmsgcr
	call	estatus		;Get EXTENDED status
	lxi		h,ERR2
	call	sysmsg		;OUT MESSAGE = "^C ABORT etc..."
	call	ioconin		;WAIT FOR RESPONSE FROM USER
	cpi		0DH
	rz					;IF <cr> THEN RTN TO BDOS WITH <A> NON-ZERO
	lhld	RETRY$ADDRESS
	sui		'C'-40H
	jz		wboot		;IF ^C WE ABORT CHANGING LOGGED DISK TO "A:"
	pchl
ERR1:	DB	'DISK I/O ERROR',0
ERR2:	DB	'^C ABORT, cr IGNORE, ELSE RETRY',0


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
	JZ		GETDAT1		;IF IT IS GENERAL STATUS, THEN RETURN
	mov		m,a			;ELSE...PUT INTO BUFFER
	LDA		TRACEF		;Test TRACE flag
	ORA		A			;Non-zero for tracing
	MOV		A,M			;Read back byte
	CNZ		OHEX		;Show data just read
	inx		h			;Advance RAM pointer
	jmp		getdat		;KEEP ON KEEPING ON
GETDAT1:
	PUSH	PSW			;SAVE FLAGS
	LDA		TRACEF
	ORA		A
	CNZ		CRLF
	POP		PSW
	RET					;EXIT WITH FLAGS SET

;****************************************************************
;	SUBROUTINE TO ACCEPT ONE BYTE FROM DISK CONTROLLER	*
;****************************************************************

inchar:
	in		OMNISTAT
	rrc					;Rotate right to test bit 0
	jnc		inchar		;IF OMNI HAS NOT YET SENT REPLY
	in		OMNIDATA	;ACCEPT REPLY
	PUSH	PSW
	STA		ASAVE
	LDA		TRACEF
	ORA		A
	LDA		ASAVE	
	CNZ		OHEX
	POP		PSW
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
	LDA		TRACEF
	ANA		A
	RZ
	JMP		CRLF

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
	PUSH 	PSW			;BYTE TO SEND TO OMNI
	IN		OMNISTAT
	RLC					;Rotate left to test bit 7
	JC		sendcmd+1	;IF OMNI NOT READY TO TAKE BYTE
	POP		PSW
	OUT		OMNIDATA
	PUSH 	PSW
	LDA 	TRACEF
	ANA 	A
	JZ 		NOTRACE
	POP 	PSW
	JMP 	OHEXB		;CONVERT TO HEX & SEND TO CONSOLE
NOTRACE
	POP 	PSW
	RET
	ENDIF


	ENDIF ;ROM$MON

ROM		EQU	$-CBOOTE
R$FREE	EQU	ROMTOP-ROM	;2K ROM
	IF ROM/ROMTOP
R$OVER	EQU	-R$FREE	;HOW MUCH YOU ARE OVER
 EQU;LONGER THAT 2K
	ENDIF

	END
