	; SHOWDPB.ASM
	;
	;
	; Report DPB of specified drive
	;

	cr equ 10
	lf equ 13
	fcb equ 5ch
	EOT equ '$'

	org	100h

show$dpb
	lda fcb
	dcr a
	jp current$drive	; Process command tail
	mvi c,19h		; Get current drive in A
	call 5

current$drive
	mov e,a
	adi 'A'
	sta m$drive		; Make ascii and store in 
				; message
	push	d
	mvi	c,0eh		; Select Disk E
	call	5
	pop	d

	push	d
	mvi	c,1fh		; Get DPB pointer in HL
	call	5
	pop	d

	push H			; Save DPB pointer

	lxi d,m$spt	!	call Store2
	lxi d,m$bsh	!	call Store1
	lxi d,m$blm	!	call Store1
	lxi d,m$exm	!	call Store1
	Lxi d,m$dsm	!	call Store2
	Lxi d,m$drm	!	call Store2
	Lxi d,m$alv0	!	call Store1
	Lxi d,m$alv1	!	call Store1
	Lxi d,m$cks	!	call Store2
	Lxi d,m$ofs	!	call Store2

	push	h

	mvi	c,12		; Get CPM version in HL and A
	call	5
	cpi	30h

	pop	h
	jc	ver2		; Old CPM

	lxi	d,m$psh ! call store1
	lxi	d,m$psm	! call store1

	mvi	a,lf
	sta	mod3		; Fix printable stuff
	mvi	a,17
	sta	mod31+1

ver2:
	lxi d,DPBDUMP
	mvi	c,9
	call	5	; Print message
	pop h
mod31:
	mvi b,15
	call Hex$list1	; Print 15 bytes of DPB
	jmp CRLF

Store2:	push h
	inx h
	call Store1
	xthl
	call Store1
	pop h
	ret


Store1:	mov a,m
	inx h
	call phex$C
	stax d		; store lower nibble at DE
	inx d
	mov a,c
	stax d
	inx d		; store high nibble at DE+1
	ret

Hex$list1:
	call phex$HL
	mvi a,':'
	call prn$A
	call p$space

	;
	; Print B bytes at HL in ascii based HEX
	;

Hex$list2:
	mov a,m
	call phex$a
	call p$space
	inx h
	dcr b
	jnz Hex$list2
	ret


phex$HL:
	mov a,h
	call phex$a
	mov a,l


	; prn$a$hex
	;

phex$A
	push a
	call get$up$nib
	call prn$A
	pop a
	call get$lw$nib
	jmp prn$A


	; get$upper$nibble
	;

get$up$nib
	rar ! rar ! rar ! rar 

	; get$lower$nibble
	;

get$lw$nib:
	ani 0000$1111b
	cpi 10
	jc less
	adi 7
less:	
	adi '0'
	ret


	; Convert A to ascii based HEX, lower 4 bits in C, upper in A
	;

phex$C:	
	push a
	call get$lw$nib
	mov c,a
	pop a
	jmp get$up$nib


	; prn$a
	; print ascii to console from <A>

prn$A:	push b ! push d ! push h
	mov e,a
	mvi c,2
	call 5
	pop h ! pop d !	pop b
	ret

	; Print CR,LF to console

CRLF:	mvi a,lf
	call prn$A
	mvi a,cr
	jmp prn$A


	; Print a space
	;

p$space	mvi	a,' '
	jmp	prn$a


DPBDUMP:DB	'SHOW DPB (Disk Parameter Block)',cr,lf,cr,lf
	db	'DPB for drive '
m$drive:db	'A:',cr,lf,cr,lf
	db	'SPT:  '
m$spt:	db	0,0,0,0,'H',9,'Sectors per track.',cr,lf
	db	'BSH:  '
m$bsh:	db	0,0,'H',9,'Block shift.',cr,lf
	db	'BLM:  '
m$blm:	db	0,0,'H',9,'Block mask.',cr,lf
	db	'EXM:  '
m$exm:	db	0,0,'H',9,'Extent mask.',cr,lf
	db	'DSM:  '
m$dsm:	db	0,0,0,0,'H',9,'Maximum # of blocks - 1.',cr,lf
	db	'DRM:  '
m$drm:	db	0,0,0,0,'H',9,'Directory entries-1.',cr,lf
	db	'ALV0: '
m$alv0:	DB	0,0,'H',9,'Directory group allocation 0.',cr,lf
	db	'ALV1: '
m$alv1:	DB	0,0,'H',9,'Directory group allocation 1.',cr,lf
	db	'CKS:  '
m$cks:	DB	0,0,0,0,'H',9,'Check size.',cr,lf
	db	'OFF:  '
m$ofs:	DB	0,0,0,0,'H',9,'Offset (number reserved tracks).',cr,lf

mod3:	db	EOT

	db	'PSH:  '
m$psh:	db	0,0,'H',9,'Physical record shift factor',cr,lf
	db	'PSM:  '
m$psm:	db	0,0,'H',9,'Physical record mask',cr,lf

	db	EOT

hexdmp:	DB	cr,lf,'"DPB address and Hex dump of table."',cr,lf
	db	EOT

dumpbuf:

	END

