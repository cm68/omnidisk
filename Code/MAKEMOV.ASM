;*****************************************************************************
;
;  MAKEMOV - Generate a MOVCPM.COM file
;	Given two ready to SYSGEN images for a customized CP/M, this 
;	program generates MOVCPM.COM for the customized CP/M. The output
;	file is named BMOVCPM.COM (Beta-MOVCPM).
;
;	Usage: MAKEMOV param1 param2
;	  Where param1 & param2 = [filename]XX[.ext]
;
;	param1 and param2 identify two ready-to-SYSGEN CP/M image files
;	of two different memory sizes
;
;	Examples:
;	  MAKEMOV CPM32.COM CPM48.COM
;	  MAKEMOV CPM32 CPM48  (assumes .COM extension)
;	  MAKEMOV 32 48        (assumes filename like CPMxx.COM)
;
;	Rev	 Date	  Desc
;	1.0	11/9/17   Mike Douglas, Original
;
;*****************************************************************************

; BDOS equates

BDOS	equ	5		;BDOS entry point
PRINT	equ	9		;BDOS write string to console
RDLINE	equ	10		;BDOS read a line from the console
OPENF	equ	15		;BDOS open file
CLOSEF	equ	16		;BDOS close file
DELETEF	equ	19		;BDOS delete file
READF	equ	20		;BDOS read file
WRITEF	equ	21		;BDOS write file
MAKEF	equ	22		;BDOS make file
SETDMA	equ	26		;BDOS set DMA address

; File control block

FCB	equ	5Ch		;location of default CP/M FCB
FCBFN	equ	FCB+1		;location of file name
FCBEXT	equ	FCB+9		;location of file extension
FCBCR	equ	FCB+32		;current record

FCB2	equ	6Ch		;location of 2nd FCB from command line
FCB2FN	equ	FCB2+1		;location of file name

; Misc equates

MODOFF	equ	0800h		;offset of module base in the image file
CPMOVEL	equ	0200h		;length of CPMOVE code
IBUFLEN	equ	80		;length of input buffer
CR	equ	13		;ascii for carriage return
LF	equ	10		;ascii for line feed

;-----------------------------------------------------------------------------
; Start of program
;-----------------------------------------------------------------------------
	org	0100h		;CP/M load and entry address

	lxi	h,0		;save stack pointer by HL=SP+0
	dad	sp		;HL=current stack pointer from CP/M
	shld	saveStk		;save for restore later

	lxi	sp,stack	;setup local stack
	
	call	chkParm		;check input parameters
	call	memSize		;get CP/M memory size from file name
	call	rdFiles		;read the two image files into memory
	call	findCpm		;find the start of CP/M in the image
	call	mkBmap		;make the bitmap
	call	movMove		;move CPMOVE code into the image
	call	getMsg		;get the "constructing" message from user
	call	dspData		;display the data we've collected
	call	wrtImg		;write the image to BMOVCPM.COM

	lxi	d,mDone		;DE->creation complete message
	jmp	exitMsg

;-----------------------------------------------------------------------------
; chkParm - Verify the file name parameters are supplied. If not, display
;    help banner and exit. Otherwise, save the 2nd file name supplied in
;    fcbSave.
;-----------------------------------------------------------------------------
chkParm	lxi	d,mHelp		;DE->help message

	lda	FCBFN		;look at 1st character of 1st file name
	cpi	' '		;anything there?
	jz	exitMsg		;no, exit with message from DE

	lda	FCB2FN		;look at 1st character of 2nd file name
	cpi	' '		;anything there?
	jz	exitMsg		;no, exit with message from DE

	lxi	h,FCB2		;HL->source FCB (2nd file name)
	lxi	d,fcbSave	;DE->destination (FCB save area)
	jmp	movFcb		;save 2nd FCB and exit

;-----------------------------------------------------------------------------
; memSize - Get the memory size for the 1st CP/M image from it's name.
;   Save in cpmTop as the full address of the top of CP/M.
;-----------------------------------------------------------------------------
memSize	lxi	h,FCBEXT	;HL->last character of file name+1

skipSpc	dcx	h		;parse file name from right to left
	mov	a,m		;skip spaces
	cpi	' '
	jz	skipSpc		;know 1st is not space so this is safe

	lxi	d,mNoSize	;DE->No memory size message

	sui	'0'		;convert ASCII to binary
	cpi	10		;valid 0-9?
	jnc	exitMsg		;no, exit with error

	mov	b,a		;save 1's digit in b
	
	dcx	h		;point to 10's digit
	mov	a,m		;A=10's digit
	sui	'2'		;convert ASCII to binary
	cpi	5		;sanity check 2-6
	jnc	exitMsg		;exit with error

	adi	2		;A=binary value of 10's digit
	add	a		;*2
	mov	c,a		;C=10's digit *2
	add	a		;*4
	add	a		;*8
	add	c		;*10
	
	add	b		;A=memory size in K
	add	a		;*2 (512 byte lsbit)
	add	a		;*4 (256 byte lsbit)
	
	mov	h,a		;form HL=16 bit address of CP/M top
	mvi	l,0
	shld	cpmTop		;save memory size in cpmTop

	ret

;-----------------------------------------------------------------------------
; rdFiles - Read the two image files into memory and verify they are the
;     same length. Save the length in imgLen.
;-----------------------------------------------------------------------------
rdFiles	lxi	h,img1		;HL->where to read image file
	call	readImg		;read image from file #1
	shld	imgLen		;save length read

	lxi	h,fcbSave	;HL->source FCB (2nd file name)
	lxi	d,FCB		;DE->destination (default FCB)
	call	movFcb		;put 2nd file name into default FCB

	lxi	h,img2		;HL->where to read image file
	call	readImg		;read image 2 from file #2
	
	lxi	d,mLenErr	;DE->length error message
	
	lda	imgLen+1	;compare length MSBs
	cmp	h
	jnz	exitMsg		;exit with length error message

	lda	imgLen		;compare length LSBs 
	cmp	l
	jnz	exitMsg		;exit with length error message

	lxi	d,MODOFF	;DE=offset in image to start of module
	call	hlSubDe		;HL=module length = imgLen - start of module
	shld	modLen		;save module length
	
	ret

;-----------------------------------------------------------------------------
; readImg - Read image file in FCB into RAM pointed to by HL. Number
;     of bytes read returned in HL.
;----------------------------------------------------------------------------
readImg	push	h		;save starting address on stack

	lxi	d,-80h		;pre-decrement address by one sector
	dad	d		;HL->image-80h
	push	h		;save on stack
	
; Insert .COM extension if not supplied. If just memory sizes entered
;    as parameters, create the default 'CPMxx' file name.

	lxi	h,FCBEXT	;HL->file extension in FCB
	mvi	a,' '		;compare to space to see if ext present
	cmp	m
	jnz	haveExt		;yes, extension is present

	mvi	m,'C'		;else, insert 'COM' as extension
	inx	h
	mvi	m,'O'
	inx	h
	mvi	m,'M'

haveExt	lda	FCBFN		;A=first character of file name
	sui	'2'		;see if a digit 2-6
	cpi	5
	jnc	haveFn		;no, a file name must already be there

	lhld	FCBFN		;move xx memory size to 3,4 in file name
	shld	FCBFN+3
	
	lxi	h,'CP'		;put 'CPM' in 0-2 of file name
	shld	FCBFN
	mvi	a,'M'
	sta	FCBFN+2

; Read the file image into memory

haveFn	xra	a		;zero current record in FCB
	sta	FCBCR

	lxi	d,FCB		;DE->file control block
	mvi	c,OPENF		;C=open file command
	call	BDOS		;open the image file
	
	lxi	d,mNoFile	;DE->file not found message
	inr	a		;test for FFh error
	jz	exitMsg		;file not found, exit

rdLoop	pop	h		;HL->last address read
	lxi	d,80h		;increment by one sector
	dad	d		;HL->next sector
	push	h		;save on stack
	
	xchg			;DE=buffer address
	mvi	c,SETDMA	;C=set buffer address command
	call	BDOS

	lxi	d,FCB		;DE->file control block
	mvi	c,READF		;C=read file sequential
	call	BDOS		;read the file
	ora	a		;end of file?
	jz	rdLoop		;no, read more

	pop	h		;HL->end of last sector read + 1
	pop	d		;DE->start of image file
	jmp	hlSubDe		;HL=end-start = length read, exit

;-----------------------------------------------------------------------------
; findCpm - Find the start of CP/M (the CCP) by looking for the two jumps
;    and the input buffer length (7F) on an 80h boundary. Once this is
;    found, compute and save the following:
;
;	cpmOff - offset of start of CP/M (CCP) within img1
;	csegLen - length of the code segment of CP/M
;	cpmBase - runtime start address of the CP/M in img1
;	dsegLen - length of uninitialized data after BIOS
;
;    This code assumes the image starts on a 128 byte boundary.
;-----------------------------------------------------------------------------
findCpm	lxi	h,modBas1	;HL->start of image
	lxi	d,80h		;DE=128 byte boundaries to check	
	mvi	b,16		;B=max number of 1/2 pages to check

fcLoop	mov	a,m		;look for JMP
	cpi	JMP
	jnz	fndNxt2		;not the CCP

	inx	h		;move to 2nd JMP
	inx	h
	inx	h

	mov	a,m		;look for 2nd JMP
	cpi	JMP
	jnz	findNxt		;not the CCP

	inx	h		;move to buffer length
	inx	h
	inx	h

	mov	a,m		;look for 7F
	cpi	7Fh
	jz	fndCcp		;found the start of CP/M (CCP)

findNxt	mov	a,l		;restore L to original value
	ani	80h
	mov	l,a

fndNxt2	dad	d		;HL=HL+80h
	dcr	b		;loop until all checks have been made
	jnz	fcLoop

	lxi	d,mNoCpm	;DE->can't find CP/M message
	jmp	exitMsg

; fndCcp- Found the start of CP/M. Compute and save cpmOff, csegLen,
;    cpmBase, and dsegLen.

fndCcp	mov	a,l		;A=lsb somewhere in start page of CCP
	ani	80h		;move back to 80h boundary
	mov	l,a		;HL->start of CCP in img1
	push	h		;save result on stack

	lxi	d,-img1		;compute offset within img1
	dad	d
	shld	cpmOff		;save the offset of CP/M within img1

	xchg			;DE=offset of CP/M
	lhld	imgLen		;HL=length of image
	call	hlSubDe		;HL=image length minus CP/M offset
	shld	csegLen		;which is length of CP/M code segment

	pop	h		;HL->start of CP/M (CCP) in img1
	lxi	d,89h		;at 88h-89h from start of CCP is pointer
	dad	d		;    to input buffer at CCP start+8

	mov	d,m		;D=msb of CP/M input buffer pointer
	mvi	e,0		;DE=runtime base address of this CP/M

	lxi	b,img2-img1	;BC=offset to same location in img2
	dad	b		;HL->CCP base pointer in img2

	mov	a,m		;A=MSB of CP/M base address in img2
	cmp	d		;img1 and img2 at different addresses?

	xchg			;HL=runtime based address of img1 CP/M
	lxi	d,mNotDif	;DE->CP/M images aren't different msg
	jz	exitMsg		;exit if two images are same location

	shld	cpmBase		;save img1 CP/M base address in cpmBase

	xchg			;DE=runtime address of this CP/M
	lhld	cpmTop		;HL=runtime top of this CP/M
	call	hlSubDe		;HL=top - bottom = total memory required
	
	xchg			;DE=total memory for CP/M
	lhld	csegLen		;HL=CP/M code segment length
	xchg			;HL=total length, DE=CSEG length
	call	hlSubDe		;compute dsegLen = total length - csegLen
	shld	dsegLen		;save it
	
	ret

;-----------------------------------------------------------------------------
; mkBmap - Make relocation bitmap and put at the end of image 1. The
;    total length of the image (imgLen) is updated to include the
;    addition of the bitmap.
;-----------------------------------------------------------------------------
mkBmap	xra	a		;initialize 1st bitmap byte
	sta	bmByte
	
	lhld	modLen		;HL=length of module
	mov	b,h		;BC=length of module
	mov	c,l

	lxi	d,modBas1	;DE->start of module in image 1
	dad	d		;HL->end of module, start of bit map
	shld	bmapPtr		;save as the bitmap pointer

	lxi	h,modBas2	;HL->start of module in image 2

; mbLoop - Loop through all bytes of the module and create bitmap

mbLoop	lda	bmByte		;rotate bitmap byte
	rlc	
	sta	bmByte

	ldax	d		;A=byte from image 1
	cmp	m		;same as from image 2?
	push	h		;save HL
	jz	mbMod8		;yes, nothing to do

	lxi	h,cpmBase+1	;HL->MSB of CP/M base address in this image
	sub	m		;adjust so CCP starts at zero
	stax	d		;update the image with adjusted address

	lda	bmByte		;A=current bitmap byte
	ori	1		;set bit to flag adjustment is required
	sta	bmByte

mbMod8	inx	d		;increment image 1 pointer
	mov	a,e		;see if LSB is multiple of 8
	ani	07h		
	jnz	mbNext		;no, go on

	lda	bmByte		;A=completed bitmap byte
	lhld	bmapPtr		;HL->bit map for addresses just finished
	mov	m,a		;store the eight bits just done	
	inx	h		;HL->next bit map location
	shld	bmapPtr		;save it

	xra	a		;clear bitmap byte to start another 8
	sta	bmByte

mbNext	pop	h		;restore HL
	inx	h		;increment image 2 pointer

	dcx	b		;decrement total byte counter
	mov	a,b
	ora	c
	jnz	mbLoop		;loop if not zero

; Compute new length of image with the bitmap at the end and round up to
;     128 byte boundary, then subtract one. Later, when writing the file
;     and imgLen is decremented by 128 for each record (using DAD -80),
;     then we're assured to cross zero when the last sector is written.

	lhld	bmapPtr		;HL->end of image
	lxi	d,img1		;DE->start of image
	call	hlSubDe		;Compute end-start in HL

	mov	a,l		;A=LSB of length
	adi	7Fh		;round up to next 80h boundary
	jnc	haveLen		;didn't wrap to MSB

	inr	h		;LSB wrapped, increment MSB
 
haveLen	ani	80h		;for LSB of 00h or 80h
	mov	l,a		;HL=image length rounded up to 128 bytes
	dcx	h		;decrement by one for DAD -80 to cross zero
	shld	imgLen		;update image length
	
	ret	

;-----------------------------------------------------------------------------
; movMove - Move the image of CPMOVE in this program into the start of
;    img1. Set module size, boot code size, BIOS work pages for CPMOVE.
;-----------------------------------------------------------------------------
movMove	lxi	h,img1		;HL->destination for CPMOVE.COM
	lxi	d,cpMove	;DE->CPMOVE.COM
	lxi	b,CPMOVEL+100h	;BC=number of bytes to move
	
mmLoop	ldax	d		;move CPMOVE to image 1
	mov	m,a

	inx	h		;increment pointers
	inx	d

	dcx	b		;decrement and test count
	mov	a,b
	ora	c
	jnz	mmLoop

; Set parameters for CPMOVE to use when it runs

	lhld	modLen		;HL=length of module
	shld	modSize		;store in image where CPMOVE expects it

	lhld	cpmOff		;HL=offset to CP/M in module
	lxi	d,-MODOFF	;subtract start of boot code
	dad	d		;HL=length of boot code
	shld	bootLen		;save boot code length for CPMOVE

	lda	dsegLen+1	;A=pages in data segment (ignore LSB)
	sta	biosWk		;save for CPMOVE		

	ret

;-----------------------------------------------------------------------------
; getMsg - Get message strings from the user that are displayed by
;    CPMOVE (MOVCPM) when it runs
;-----------------------------------------------------------------------------
getMsg	lxi	d,mConst	;display "Constructing" message
	mvi	c,PRINT		;C=BDOS display message command
	call	BDOS

	lxi	d,mEntLin	;display "Enter Line 1:" message
	mvi	c,PRINT		;C=BDOS display message command
	call	BDOS

	lxi	d,inBuf		;DE->input buffer
	mvi	c,RDLINE	;C=read console buffer command
	call	BDOS
	
	lxi	h,custMsg	;HL->destination in CPMOVE code
	call	movMsg		;move message into CPMOVE code

	push	h		;save pointer of where to put next line

	mvi	a,'2'		;prompt for line 2 now
	sta	dEntLin

	lxi	d,mEntLin	;display "Enter Line 2:" message
	mvi	c,PRINT		;C=BDOS display message command
	call	BDOS

	lxi	d,inBuf		;DE->input buffer
	mvi	c,RDLINE	;C=read console buffer command
	call	BDOS
	
	pop	h		;restore destination pointer
	jmp	movMsg		;move message into CPMOVE code and exit

;-----------------------------------------------------------------------------
; movMsg - Move message typed by user from console input buffer into
;    the CPMOVE image as pointed to by HL. The string is followed by
;    CR, LF and '$'. HL points to '$' on exit (not past it).
;-----------------------------------------------------------------------------
movMsg	lxi	d,ibLen		;DE->bytes read into inbuf
	ldax	d		;A=byte read
	ora	a		;anything entered?
	jz	mmCrLf		;no, add trailing CR,LF,$

	mov	b,a		;B=number of bytes to move
	inx	d		;DE->first byte of user entered data

movLoop	ldax	d		;move from (DE) to (HL)
	mov	m,a
	
	inx	h		;increment pointers
	inx	d
	
	dcr	b		;decrement count
	jnz	movLoop

mmCrLf	mvi	m,CR		;store trailing CR, LF
	inx	h
	mvi	m,LF
	inx	h
	mvi	m,'$'		;string terminator, but leave HL

	ret

;-----------------------------------------------------------------------------
; dspData - Display information about the parameters found and computed
;-----------------------------------------------------------------------------
dspData	lxi	d,mModOff	;display offset of module in image
	mvi	c,PRINT		;C=CP/M print message command
	call	BDOS

; CP/M offset in image

	lhld	cpmOff		;HL=data to display
	lxi	d,dCpmOff	;DE->where to put ascii result
	lxi	b,mCpmOff	;BC->message to display
	call	dataMsg		;display message with data

; Module size

	lhld	modLen		;HL=data to display
	lxi	d,dModSz	;DE->where to put ascii result
	lxi	b,mModSz	;BC->message to display
	call	dataMsg		;display message with data

; Code segment length

	lhld	csegLen		;HL=data to display
	lxi	d,dCseg		;DE->where to put ascii result
	lxi	b,mCseg		;BC->message to display
	call	dataMsg		;display message with data

; Data segment length

	lhld	dsegLen		;HL=data to display
	lxi	d,dDseg		;DE->where to put ascii result
	lxi	b,mDseg		;BC->message to display
	call	dataMsg		;display message with data

; Boot loader length

	lhld	bootLen		;HL=data to display
	lxi	d,dBootSz	;DE->where to put ascii result
	lxi	b,mBootSz	;BC->message to display
	call	dataMsg		;display message with data

; Final image size

	lhld	imgLen		;HL=data to display
	inx	h		;restore actual value
	lxi	d,dImgSz	;DE->where to put ascii result
	lxi	b,mImgSz	;BC->message to display
	jmp	dataMsg		;display message with data and exit

;-----------------------------------------------------------------------------
; dataMsg - Display a data message given:
;    HL = 16 bit data to display
;    DE->where to put ASCII hex of the value in HL
;    BC->message to display after inserting the data
;-----------------------------------------------------------------------------
dataMsg	xchg			;DE=data,HL->ascii location

	mov	a,d		;A=MSB of data
	call	bin2hex		;store as ASCII at (HL)

	mov	a,e		;A=LSB of data
	call	bin2hex		;store as ASCII at (HL)

	mov	d,b		;DE->message to display
	mov	e,c

	mvi	c,PRINT		;C=CP/M print message command
	jmp	BDOS		;display the message and exit

;-----------------------------------------------------------------------------
; bin2hex - Convert byte in A into two ascii hex bytes and store where
;    pointed to by HL. HL=HL+2 on exit.
;-----------------------------------------------------------------------------
bin2hex	push	a		;save copy of value

	rrc			;put msn into lsn
	rrc
	rrc
	rrc
	ani	0Fh		;get nibble alone
	adi	'0'		;convert to printable ascii
	cpi	'9'+1		;see if > '9'
	jc	msnDone

	adi	7		;make A to F printable

msnDone	mov	m,a		;store msn at (HL)
	inx	h

	pop	a		;get original byte back

	ani	0Fh		;get lsb alone
	adi	'0'		;convert to printable ascii
	cpi	'9'+1		;see if > '9'
	jc	lsnDone		;no, lsn is done

	adi	7		;make A-F printable

lsnDone	mov	m,a		;store at (HL)
	inx	h

	ret

;-----------------------------------------------------------------------------
; wrtImg - Write the final image to BMOVCPM.COM
;----------------------------------------------------------------------------
wrtImg	lxi	h,outFcb	;HL->FCB for BMOVCPM.COM
	lxi	d,FCB		;DE->destination (default FCB)
	call	movFcb		;put output file name into default FCB

	lxi	d,FCB		;DE->output file FCB
	mvi	c,DELETEF	;C=delete file command
	call	BDOS		;delete BMVOVCPM.COM

	lxi	d,FCB		;DE->output file FCB
	mvi	c,MAKEF		;C=make file command
	call	BDOS		;create the file
	
	lxi	d,mMakErr	;DE->can't create file error message
	inr	a		;test for FF (make file fail)
	jz	exitMsg		;create file failed, exit

	xra	a		;zero current record
	sta	FCBCR

	lxi	h,img1		;HL->image to write to disk

wrLoop	push	h		;save pointer on stack
	xchg			;DE=buffer address
	mvi	c,SETDMA	;C=set buffer address command
	call	BDOS

	lxi	d,FCB		;DE->file control block
	mvi	c,WRITEF	;C=write file sequential
	call	BDOS

	lxi	d,mWrtErr	;DE->write error message
	ora	a		;test for write error
	jnz	exitMsg		;write failed, exit

	lhld	imgLen		;decrement bytes left to write
	lxi	d,-80h
	dad	d
	shld	imgLen		;save the bytes remaining
	jnc	wrExit		;all done, exit

	pop	h		;restore HL
	lxi	d,80h		;increment by 80h bytes
	dad	d
	jmp	wrLoop	

wrExit	pop	h		;restore stack

	lxi	d,FCB		;DE->output file FCB
	mvi	c,CLOSEF	;C=close file command
	jmp	BDOS		;do close and exit	

;-----------------------------------------------------------------------------
; movFCB - Move 16 byte FCB from (HL) to (DE)
;-----------------------------------------------------------------------------
movFcb	mvi	b,16		;move 16 bytes

mfLoop	mov	a,m		;move from (HL) to (DE)
	stax	d

	inx	h		;increment pointers
	inx	d

	dcr	b		;decrement and test count
	jnz	mfLoop

	ret

;-----------------------------------------------------------------------------
; hlSubDe - HL = HL - DE, sets Zero flag for result = 0
;-----------------------------------------------------------------------------
hlSubDe	mov	a,l		;subtract LSBs
	sub	e
	mov	l,a		;result in L

	mov	a,h		;subtract MSBs
	sbb	d
	mov	h,a		;result in H

	ora	l		;set zero flag for 16 bit result
	
	ret

;-----------------------------------------------------------------------------
;  exitMsg
;-----------------------------------------------------------------------------
exitMsg	mvi	c,PRINT		;display message passed in DE
	call	BDOS

	lhld	saveStk		;restore stack pointer
	sphl

	ret			;return to CCP 

;-----------------------------------------------------------------------------
;  String Constants
;-----------------------------------------------------------------------------
mHelp	equ	$		;banner/help display
 db CR,LF
 db 'MAKEMOV v1.0 - Make MOVCPM.COM for a customized CP/M',CR,LF
 db LF
 db 'Creates the program BMOVCPM.COM (Beta-MOVCPM)',CR,LF
 db LF
 db 'Usage: MAKEMOV param1 param2',CR,LF
 db '  Where param1 & param2 = [filename]XX[.ext]',CR,LF
 db LF
 db 'param1 and param2 identify two ready-to-SYSGEN CP/M image files',CR,LF
 db 'of two different memory sizes',CR,LF
 db LF
 db 'Examples:',CR,LF
 db '  MAKEMOV CPM32.COM CPM48.COM',CR,LF
 db '  MAKEMOV CPM32 CPM48  (assumes .COM extension)',CR,LF
 db '  MAKEMOV 32 48        (assumes filename like CPMxx.COM)',CR,LF,'$' 

mConst	equ	$		;"Constructing" message prompt
 db CR,LF
 db 'Sample status message displayed by MOVCPM:',CR,LF
 db LF
 db '  Constructing 48K CP/M 2.2ab Ver 1.1',CR,LF
 db '  For Altair 8" Floppy',CR,LF
 db LF
 db 'Specify lines 1 and 2 for the status message as shown below:',CR,LF
 db LF
 db '  Constructing xxK CP/M 2.2[line 1 here]',CR,LF
 db '  [line 2 here]',CR,LF,'$'

mEntLin	db	CR,LF,'Enter line '
dEntLin	db	'1:$'

mModOff	db	CR,LF,LF,'Offset of Module in file: 0800h',CR,LF,'$'

mCpmOff	db	'Offset of CP/M in file: '
dCpmOff	db	'xxxxh',CR,LF,'$'

mModSz	db	'Input module size: '
dModSz	db	'xxxxh',CR,LF,'$'

mCseg	db	'CP/M code segment size: '
dCseg	db	'xxxxh',CR,LF,'$'

mDseg	db	'BIOS data segment size: '
dDseg	db	'xxxxh',CR,LF,'$'

mBootSz	db	'Boot loader size: '
dBootSz	db	'xxxxh',CR,LF,'$'

mImgSz	db	'Final image size: '
dImgSz	db	'xxxxh',CR,LF,'$'

mDone	db	LF,'BMOVCPM.COM Created',CR,LF,'$'

mLenErr	db	CR,LF,'File sizes do not match',CR,LF,'$'
mNoFile	db	CR,LF,'File not found',CR,LF,'$'
mRdErr	db	CR,LF,'File read error',CR,LF,'$'
mNotDif	db	CR,LF,'The two files are the same CP/M memory size',CR,LF,'$'
mMakErr	db	CR,LF,'Can''t create output file',CR,LF,'$'
mWrtErr	db	CR,LF,'File write error, disk full?',CR,LF,'$'
mNoCpm	db	CR,LF,'Can''t find start of CP/M in image',CR,LF,'$'
mNoSize	db	CR,LF,'CP/M memory size not in file name',CR,LF,'$'

;-----------------------------------------------------------------------------
;  Data Area
;-----------------------------------------------------------------------------
outFcb	db	0,'BMOVCPM COM',0,0,0,0		;output FCB

inBuf	equ	$		;input buffer for BDOS read console call
ibMax	db	IBUFLEN		;maximum characters to read
ibLen	ds	1		;number of characters actually read
ibData	ds	IBUFLEN		;characters read are stored here

saveStk	ds	2		;save area for CP/M stack pointer 
fcbSave	ds	16		;save area for FCB prepared by the CCP
bmapPtr	ds	2		;pointer to current bitmap location
bmByte	ds	1		;single byte of bits for bitmap

imgLen	ds	2		;length of image file
modLen	ds	2		;module length (boot plus CP/M)
cSegLen	ds	2		;length of CP/M code segment
dSegLen	ds	2		;length of CP/M data segment (past BIOS)
cpmOff	ds	2		;offset to start of CP/M within image
cpmTop	ds	2		;memory size of CP/M in image
cpmBase	ds	2		;base run-time address of CP/M in image

	ds	32		;local stack space
stack	equ	$

;-----------------------------------------------------------------------------
;  CPMOVE.COM is patched here for copying into the generated MOVCPM
;-----------------------------------------------------------------------------
	org	($+255) AND 0FF00h	;force page boundary
cpMove	ds	CPMOVEL+100h	;parameters are in last page

;-----------------------------------------------------------------------------
; The CP/M image files read from disk are saved here in img1 and img2.
;    12K is reserved for each image. Images are on a page boundary
;-----------------------------------------------------------------------------
img1	equ	$
bootLen	equ	img1+CPMOVEL	;boot loader size for CPMOVE
biosWk	equ	bootLen+2	;DSEG length in pages for CPMOVE
custMsg	equ	bootLen+1Eh	;custom part of "Constructing..." msg
modSize	equ	img1+0701h	;location of module size for CPMOVE
modBas1	equ	img1+MODOFF	;start of module within image

img2	equ	img1+3000h	;leaves 12K for 1st image
modBas2	equ	img2+MODOFF	;start of module within image				

	end


