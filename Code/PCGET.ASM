;
;  PCGET - This CP/M program receives a file from a PC via a serial 
;  port and writes it to a file on the CP/M system. The file transfer uses
;  the XMODEM protocol. 
;
;  Note this program is gutted from the Ward Christenson Modem program.
;
;  Hacked to use CompuPro System Support-1 serial interface port, Mike Enkelis.
;
;  Hacked together by Mike Douglas for the Altair 2SIO serial interface board.
;	Ver	Date	Desc
;	1.0    11/7/12	Initial version
;	1.1    2/20/14  Allow transfer to occur over 2SIO port B
;	1.2   12/21/14	Send NAK immediately after file open to speed
;			up the start-up of file transfer (four second
;			delay otherwise).
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE

;  Serial Port Equates
ASIO2	EQU	FALSE	;ALTAIR SIO-2
ISIO2	EQU	FALSE	;IMSAI SIO-2
CSS1	EQU	TRUE	;COMPUPRO SYSTEM SUPPORT 1

	IF	ASIO2
SIOACR	EQU	010H		;2SIO port A control register
SIOADR	EQU	011H		;2SIO port A data register
SIOBCR	EQU	012H		;2SIO port B control register
SIOBDR	EQU	013H		;2SIO port B data register
XMTMASK	EQU	2		;MASK TO ISOLATE XMIT READY BIT
XMTRDY	EQU	2		;VALUE WHEN READY
RCVMASK	EQU	1		;MASK TO ISOLATE RECEIVE READY BIT
RCVRDY	EQU	1		;BIT ON WHEN READY
	ENDIF
	IF	ISIO2
BASE	EQU	00H			; Port A
SIOACR	EQU	BASE + 3	; SIO PORT A STATUS
SIOADR	EQU	BASE + 2	; Data Port A
SIOBCR	EQU	BASE + 5	; SIO PORT B STATUS
SIOBDR	EQU	BASE + 4	; Data Port B
IECTL	EQU	BASE + 8	; SIO INTERRUPTS CTRL PORT
XMTMASK	EQU	1		;MASK TO ISOLATE XMIT READY BIT
XMTRDY	EQU	1		;VALUE WHEN READY
RCVMASK	EQU	2		;MASK TO ISOLATE RECEIVE READY BIT
RCVRDY	EQU	2		;BIT ON WHEN READY
	ENDIF	;ISIO2
	IF	CSS1
BASE	EQU	05CH			; Port A
SIOADR	equ	BASE		;Console data
SIOACR	equ	BASE+1		;Console status
CMODE	equ	BASE+2		;Mode registers
CCTRL	equ	BASE+3		;Command register
CSTOP1	equ	06E00h		;8N1 x16
CSTOP2	equ	0EE00h		;8N2 x16
CTL2651	equ	27h			;Ctrl reg initialization value
XMTMASK	EQU	1		;MASK TO ISOLATE XMIT READY BIT
XMTRDY	EQU	1		;VALUE WHEN READY
RCVMASK	EQU	2		;MASK TO ISOLATE RECEIVE READY BIT
RCVRDY	EQU	2		;BIT ON WHEN READY
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

;  Transfer related equates

SOH	EQU	1
EOT	EQU	4
ACK	EQU	6
NAK	EQU	15H
CTRLC	EQU	3		;Control-C
LF	EQU	10
CR	EQU	13

	ORG	100H

;  Verify a file name was specified

	lda	PARAM1		;A=1st character of parameter 1
	cpi	' '		;make sure something entered
	jnz	havep1
	lxi	d,mHelp		;display usage message
	mvi	c,print
	call	bdos
	ret			;return to CPM

;  See if port "B" specified (2nd parameter)

havep1	mvi	b,0		;assume port b not used
	lxi	d,mSendA	;port a send message
	IF NOT CSS1
	lda	PARAM2		;A=1st character of parameter 2
	ani	5fh		;force upper case
	cpi	'B'		;port b specified?
	jnz	doXfer		;no, go do the transfer
	inr	b		;force flag to non-zero value
	lxi	d,mSendB	;port b send message
	ENDIF
	
;  doXfer - Switch to local stack and do the transfer

doXfer	mov	a,b		;store the port b flag
	sta	fPortB
	LXI	H,0		;HL=0
	DAD	SP		;HL=STACK FROM CP/M
	SHLD	STACK		;..SAVE IT
	LXI	SP,STACK	;SP=MY STACK
	xra	a
	sta	SECTNO		;init sector number to zero

	CALL	INIT$SIO	;MASTER RESET THE SERIAL I/O CHIP

	MVI	C,PRINT		;print the send message
	CALL	BDOS		;PRINT ID MESSAGE

;  GOBBLE UP GARBAGE CHARS FROM THE LINE

purge	MVI	B,1		;times out after 1 second if no data
	CALL	RECV
	jc	RECEIVE$FILE	;line is clear, go receive the file
	cpi	ctrlc		;exit if abort requested
	jz	abort
	jmp	purge
;
;**************RECEIVE FILE****************
;
RECEIVE$FILE:
	CALL	ERASE$OLD$FILE
	CALL	MAKE$NEW$FILE
	MVI	A,NAK
	CALL	SEND		;SEND NAK

RECV$LOOP:
RECV$HDR:
	MVI	B,3		;3 SEC TIMEOUT
	CALL	RECV
	JNC	RHNTO		;NO TIMEOUT

RECV$HDR$TIMEOUT:
RECV$SECT$ERR:			;PURGE THE LINE OF INPUT CHARS
	MVI	B,1		;1 SEC W/NO CHARS
	CALL	RECV
	JNC	RECV$SECT$ERR 	;LOOP UNTIL SENDER DONE
	MVI	A,NAK
	CALL	SEND		;SEND NAK
	JMP	RECV$HDR

;GOT CHAR - MUST BE SOH OR CTRL-C TO ABORT

RHNTO:	CPI	SOH
	JZ	GOT$SOH
	cpi	ctrlc		;control-c to abort?
	jz	abort
	CPI	EOT
	JZ	GOT$EOT
	JMP	RECV$SECT$ERR

GOT$SOH:
	MVI	B,1
	CALL	RECV
	JC	RECV$HDR$TIMEOUT
	MOV	D,A		;D=BLK #
	MVI	B,1
	CALL	RECV		;GET CMA'D SECT #
	JC	RECV$HDR$TIMEOUT
	CMA
	CMP	D		;GOOD SECTOR #?
	JZ	RECV$SECTOR
	JMP	RECV$SECT$ERR

;  Receive Sector

RECV$SECTOR:
	MOV	A,D		;GET SECTOR #
	STA	RSECTNO
	MVI	C,0		;INIT CKSUM
	LXI	H,80H		;POINT TO BUFFER
RECV$CHAR:
	MVI	B,1		;1 SEC TIMEOUT
	CALL	RECV		;GET CHAR
	JC	RECV$HDR$TIMEOUT
	MOV	M,A		;STORE CHAR
	INR	L		;DONE?
	JNZ	RECV$CHAR

;VERIFY CHECKSUM

	MOV	D,C		;SAVE CHECKSUM
	MVI	B,1		;TIMEOUT
	CALL	RECV		;GET CHECKSUM
	JC	RECV$HDR$TIMEOUT
	CMP	D		;CHECK
	JNZ	RECV$SECT$ERR
;
;GOT A SECTOR, WRITE IF = 1+PREV SECTOR
;
	LDA	RSECTNO
	MOV	B,A		;SAVE IT
	LDA	SECTNO		;GET PREV
	INR	A		;CALC NEXT SECTOR #
	CMP	B		;MATCH?
	JNZ	DO$ACK

;GOT NEW SECTOR - WRITE IT

	LXI	D,FCB
	MVI	C,WRITE
	CALL	BDOS
	ORA	A
	JNZ	WRITE$ERROR
	LDA	RSECTNO
	STA	SECTNO		;UPDATE SECTOR #
DO$ACK	MVI	A,ACK
	CALL	SEND
	JMP	RECV$LOOP

WRITE$ERROR:
	CALL	ERXIT
	DB	13,10,10,'Error Writing File',13,10,'$'

GOT$EOT:
	MVI	A,ACK		;ACK THE EOT
	CALL	SEND
	LXI	D,FCB
	MVI	C,CLOSE
	CALL	BDOS
	INR	A
	JNZ	XFER$CPLT
	CALL	ERXIT
	DB	13,10,10,'Error Closing File',13,10,'$'
;
ERASE$OLD$FILE:
	LXI	D,FCB
	MVI	C,SRCHF		;SEE IF IT EXISTS
	CALL	BDOS
	INR	A		;FOUND?
	RZ			;NO, RETURN
ERAY:	LXI	D,FCB
	MVI	C,ERASE
	CALL	BDOS
	RET
;
MAKE$NEW$FILE:
	LXI	D,FCB
	MVI	C,MAKE
	CALL	BDOS
	INR	A		;FF=BAD
	RNZ			;OPEN OK

;DIRECTORY FULL - CAN'T MAKE FILE
	CALL	ERXIT
	DB	13,10,10,'Error - Can''t Make File',13,10
	DB	'(directory must be full)',13,10,'$'
;
; S U B R O U T I N E S
;
; - - - - - - - - - - - - - - -

;EXIT PRINTING MESSAGE FOLLOWING 'CALL ERXIT'

ERXIT	POP	D		;GET MESSAGE
	MVI	C,PRINT
	CALL	BDOS		;PRINT MESSAGE
EXIT	LHLD	STACK		;GET ORIGINAL STACK
	SPHL			;RESTORE IT
	RET			;--EXIT-- TO CP/M

; - - - - - - - - - - - - - - -
;MODEM RECV
;-------------------------------------
RECV	PUSH	D		;SAVE
MSEC	lxi	d,(159 shl 8)	;49 cycle loop, 6.272ms/wrap * 159 = 1 second
	IF	NOT CSS1
	lda	fPortB		;using port B?
	ora	a
	jnz	MWTIB
	ENDIF ;NOT CSS1

;  port A input

MWTI	IN	SIOACR
	ANI	RCVMASK
	CPI	RCVRDY
	JZ	MCHAR		;GOT CHAR
	DCR	E		;COUNT DOWN
	JNZ	MWTI		;FOR TIMEOUT
	DCR	D
	JNZ	MWTI
	DCR	B		;DCR # OF SECONDS
	JNZ	MSEC

;MODEM TIMED OUT RECEIVING

	POP	D		;RESTORE D,E
	STC			;CARRY SHOWS TIMEOUT
	RET

;GOT MODEM CHAR

MCHAR	IN	SIOADR
	POP	D		;RESTORE DE
	PUSH	PSW		;CALC CHECKSUM
	ADD	C
	MOV	C,A
	POP	PSW
	ORA	A		;TURN OFF CARRY TO SHOW NO TIMEOUT
	RET

;  port B input. Look for Ctrl-C on port A to abort

	IF	NOT CSS1
MWTIB	IN	SIOBCR
	ANI	RCVMASK
	CPI	RCVRDY
	JZ	MCHARB		;GOT CHAR
	DCR	E		;COUNT DOWN
	JNZ	MWTIB		;FOR TIMEOUT
	in	SIOACR		;see if a ctrl-c pressed on console
	rrc			;character present?
	jnc	noCtrlC		;no
	in	SIOADR
	cpi	ctrlc		;is it a Ctrl-C?
	jnz	noCtrlC		;no
	pop	d		;restore d,e
	ret			;carry is clear (no timeout), exit

noCtrlC	DCR	D
	JNZ	MWTIB
	DCR	B		;DCR # OF SECONDS
	JNZ	MSEC

;MODEM TIMED OUT RECEIVING

	POP	D		;RESTORE D,E
	STC			;CARRY SHOWS TIMEOUT
	RET

;GOT MODEM CHAR

MCHARB	IN	SIOBDR
	POP	D		;RESTORE DE
	PUSH	PSW		;CALC CHECKSUM
	ADD	C
	MOV	C,A
	POP	PSW
	ORA	A		;TURN OFF CARRY TO SHOW NO TIMEOUT
	RET
	ENDIF ;NOT CSS1

; - - - - - - - - - - - - - - -
;MODEM SEND CHAR ROUTINE
;----------------------------------
;
SEND	PUSH	PSW		;CHECK IF MONITORING OUTPUT
	ADD	C		;CALC CKSUM
	MOV	C,A
	IF	NOT CSS1
	lda	fPortB		;using port B?
	ora	a
	jnz	SENDWB
	ENDIF ;NOT CSS1

; Use port A

SENDW	IN	SIOACR
	ANI	XMTMASK
	CPI	XMTRDY
	JNZ	SENDW
	POP	PSW		;GET CHAR
	OUT	SIOADR
	RET

; Use port B

	IF	NOT CSS1
SENDWB	IN	SIOBCR
	ANI	XMTMASK
	CPI	XMTRDY
	JNZ	SENDWB
	POP	PSW		;GET CHAR
	OUT	SIOBDR
	RET
	ENDIF ;NOT CSS1

; INITITIALIZE THE SERIAL PORT

INIT$SIO:
	IF	ASIO2
	lda	fPortB		;using port B?
	ora	a
	jnz	initB		;yes
;	mvi	a,003h		;don't reset console port
;	out	SIOACR
	mvi	a,015h		;rts on, 8N1
	out	SIOACR
	ret

; initB - init port B instead

initB
	mvi	a,3	
	out	SIOBCR
	mvi	a,015h		;rts on, 8N1
	out	SIOBCR
	ret
	ENDIF ;ASIO2

	IF	ISIO2
	lda	fPortB		;using port B?
	ora	a
	jnz	initB		;yes
	in	SIOADR		;Clear junk
	ret

; initB - init port B instead

initB
	xra	a			; Zero
	out	IECTL		; Disable SIO-2 interrupts
	out	SIOBCR		; Port B
	out	SIOBCR
	out	SIOBCR
	mvi	a,40H		; Reset 8251
	out	SIOBCR		; Port B
	mvi	a,4EH		; 8N1 /16
 	out	SIOBCR		; Port B
	mvi	a,37H		; Clear ERRS, Enable Rx/Tx
 	out	SIOBCR		; Port B
	in	SIOBDR		; Clear junk
	ret
	ENDIF ;ISIO2

	IF	CSS1
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
	in	SIOADR		;Clear junk
	RET
	ENDIF ;CSS1

mSendA	db	'Send the file now using XMODEM...$'
	IF	NOT CSS1
mSendB	db	'Send the file now using XMODEM on Port B...$'
	ENDIF ;NOT CSS1
mHelp	db	CR,LF,'PCGET Ver 1.2',CR,LF,LF
	IF	NOT CSS1
	db	'Usage: PCGET file.ext [B]',CR,LF
	DB	'       (B specifies 2SIO Port B for transfer)',CR,LF,'$'
	ENDIF ;NOT CSS1
	IF	CSS1
	db	'Usage: PCGET file.ext',CR,LF,'$'
	ENDIF ;CSS1

;DONE - CLOSE UP SHOP

XFER$CPLT:
	CALL	ERXIT
	DB	13,10,10,'Transfer Complete',13,10,'$'

abort:	call	erxit
	db	13,10,10,'Transfer Aborted',13,10,'$'

	DS	40	;STACK AREA
STACK	DS	2	;STACK POINTER
RSECTNO	DS	1	;RECEIVED SECTOR NUMBER
SECTNO	DS	1	;CURRENT SECTOR NUMBER 
fPortB	ds	1	;flag to use 2SIO port B instead of A
;
; BDOS EQUATES (VERSION 2)
;
RDCON	EQU	1
WRCON	EQU	2
PRINT	EQU	9
CONST	EQU	11	;CONSOLE STAT
OPEN	EQU	15	;0FFH=NOT FOUND
CLOSE	EQU	16	;   "	"
SRCHF	EQU	17	;   "	"
SRCHN	EQU	18	;   "	"
ERASE	EQU	19	;NO RET CODE
READ	EQU	20	;0=OK, 1=EOF
WRITE	EQU	21	;0=OK, 1=ERR, 2=?, 0FFH=NO DIR SPC
MAKE	EQU	22	;0FFH=BAD
REN	EQU	23	;0FFH=BAD
STDMA	EQU	26
BDOS	EQU	5
REIPL	EQU	0
FCB	EQU	5CH	;DEFAULT FCB
PARAM1	EQU	FCB+1	;COMMAND LINE PARAMETER 1 IN FCB
PARAM2	EQU	PARAM1+16	;COMMAND LINE PARAMETER 2
	END
