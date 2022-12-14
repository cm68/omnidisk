;	SOURCE IS BPROM.ASM
;
;	THIS PROGRAM RESIDES ON A 512x8 PROM ON THE OMNIDISK CONTROLLER.
;	ITS PURPOSE IS TO GET A SYSTEM UP FAST.
;
;	DURING THE FIRST PART OF ITS EXECUTION THE PROGRAM APPEARS
;	ALL OVER MEMORY DURING READ CYCLES BECAUSE THE OMNIDISK
;	ONLY USES THE LOW 9 BITS OF THE 24-BIT MEMORY ADDRESS.
;	"PHANTOM" IS ASSURTED TO DISABLE OTHER MEMORY THAT MAY BE
;	PRESENT.  "PHANTOM" IS NOT ASSURTED DURING WRITE
;	CYCLES -- THIS ALLOWS THE PROGRAM TO COPY ITSELF TO REAL
;	MEMORY AND THEN TO CAUSE THE "PHANTOM OF THE BOOT" TO RESET.
;
;	UNTIL OUR "PHANTOM" IS RESET WE CAN ONLY WRITE TO REAL MEMORY.
;
START	EQU	200H
LENPROM EQU	200H		;200H IS MAX
SWAP	EQU	0FDH		;SWAP PORT FOR COMPUPRO (tm) 8085/8088

;********************************************************
;	VALID COMMAND BYTE ONE FOR OMNI CONTROLLER	*
;	   (THESE EQUATES ARE COPIED FROM BIOS)		*
;********************************************************

OC$BOOT	EQU	0		;BOOT SYSTEM
OC$SWRT	EQU	1		;WRITE SYSTEM (INVERSE OF BOOT)
OC$MODE EQU	2		;DMA/IO MODE
*C$FMTF	EQU	3		;FORMAT FLOPPY TRACK
*C$DLDS EQU	4		;DEFINE LOGICAL DEVICE SET
OC$GLDS	EQU	5		;GET LOGICAL DEVICE SET
*C$FWRT	EQU	6       	;FORCE WRITE OF MODIFIED BUFFERS
OC$RBPH	EQU	7		;RESET BOOT PHANTOM
*C$----	EQU	8		;NOT ASSIGNED
OC$UNIT	EQU	9		;SELECT (LOGICAL) UNIT
OC$TRAK	EQU	10		;SELECT TRACK
OC$RECD	EQU	11		;SELECT (LOGICAL) RECORD
OC$DADR	EQU	12		;SET DMA ADDRESS
OC$READ	EQU	13		;READ
OC$WRIT	EQU	14		;WRITE
OC$HEAD	EQU	15		;SET HEAD (NOT USED, ANYWHERE)
*C$----	EQU	16		;NOT ASSIGNED
OC$GDPB	EQU	17		;GET DPB (GET CP/M DPB FROM OMNI)
*C$----	EQU	18		;NOT ASSIGNED
*C$SSEK EQU	19		;NON-IMPYED SEEK (NOT USED IN BIOS)
*C$TIOR	EQU	20		;DEBUG READS FROM OMNI
*C$TIOW	EQU	21		;DEBUG WRITES TO OMNI
OC$GENS EQU	22		;GET GENERAL STATUS
OC$EXTS	EQU	23		;GET EXTENDED STATUS

OMNIDATA EQU	0A0H		;<== DATA PORT FOR OMNI CONTROLLER
OMNISTAT EQU	OMNIDATA+1	;STATUS PORT FOR OMNI
INREADY  EQU	01H		;** OMNI HAS DATA TO SEND
OUTREADY EQU	80H		;** OMNI CAN NOT ACCEPT ANOTHER BYTE NOW
;
;	THE FOLLOWING CODE HAS A LITTLE TRICK IN IT:
;
;	ON RESET THE 8085 STARTS AT 0000.  THE 200H BYTE BOOT PROM
;	IS MAPPED INTO ALL ADDRESS, REPEATING AT 200H INTERVALS.
;
;	THE CODE FROM "DI" TO THE FIRST TIME THE "JNZ L1" IS EXECUTED,
;	RUNS AT 0000-000B.  THE JMP TAKES US TO "L1" IN THE LOW 200
;	ADDRESS RANGE AND WE CONTINUE RUNNING AT 2xx UNTIL WE JMP
;	TO THE BOOT SECTOR WHICH WE LOAD AT 0000.
;
	ORG	START		;FOR "L1" LOOP TO WORK,
				;"START" MUST BE ON 100H BOUNDRY

	DI			;JUST TO BE SURE
	IN	SWAP		;WAKE UP 8088 IF USING COMPUPRO (tm) 8085/8088
	LXI	H,CODELBA+1
L1:	DCR	L
	MOV	A,M		;MOVE PROG TO REAL
	MOV	M,A		;MEMORY "UNDER" PROM
	JNZ	L1		;IF NOT DONE MOVING TO REAL MEMORY

	SPHL			;INIT STACK TO START (200H)

	IN	OMNIDATA	;READ&TRASH TO RESET ANY TRASH IN REG
	MVI	A,OC$RBPH	;RESET BOOT PHANTOM...
	OUT	OMNIDATA	;...TO OMNI
;
;	NOW WAIT FOR OMNI TO HONOR REQUEST TO RESET THE PHANTOM OF THE BOOT
;
;	THE METHOD WE USE IS QUITE SIMPLE.  WE STORE A ZERO INTO THE
;	FIRST BYTE OF THIS CODE AND THEN COMPARE THAT FIRST BYTE AGAINST
;	THE ZERO WE JUST STORED.  THE STORE WILL ALLWAYS WORK -- BUT
;	IF THE BOOT PHANTOM IS NOT RESET THE MEMORY FETCH PART OF THE
;	COMPARE WILL FETCH THE ORIGINAL BYTE.  WE CONTINUE LOOPING
;	UNTIL WE FETCH THE ZERO.
;
				;NOTE THAT <HL> = 200H
L2	XRA	A
	MOV	M,A		;THIS STORE ALLWAYS WORKS BUT...
	CMP	M		;...IF BS PHANTOM NOT RESET, THIS FETCHES PROM
	JNZ	L2
L3	CALL	CMDLIST
	DB	3		;(LENGTH OF LIST)
	DB	OC$BOOT,1	;READ ONLY FIRST SECTOR OF BOOT
	DB	OC$GENS
	LXI	H,0000		;READ BOOT SECTOR INTO LOCATION 0000
	CALL	GETDAT
	ORA	A		;GENERAL STATUS
	JZ	0000		;IF BOOT READ OK, GO FIRE UP BOOT
;
;	FAILURE READING BOOT SECTOR
;
;	RESET GENERAL STATUS BY FETCHING EXTENDED STATUS
;
	CALL	CMDLIST
	DB	2		;(LENGTH OF LIST)
	DB	OC$EXTS		;REQUEST EXTENDED STATUS (SETS GENSTAT=0)
	DB	OC$GENS
	CALL	GETDAT		;ACCEPT (& SCRAP) EXTENDED STATUS
;
;	WAIT SEVERAL SECONDS BEFORE TRYING AGAIN
;
	MVI	A,30		;FOR DELAY COUNTER (=5 SEC ON 6MHZ 8085)
L4	DCR	L	;**
	JNZ	L4	;** ON 8085 THESE LOOPS TAKE 1,118,464
	DCR	H	;** T-STATES OR ABOUT 1/CLOCK SEC
	JNZ	L4	;**
	DCR	A
	JNZ	L4
	JMP	L3		;TRY AGAIN AFTER DELAY

;********************************************************
;	SUBROUTINE FOR BLOCK READ			*
;							*
;	NOTE:	THIS SUBROUTINE READS DATA UNTIL	*
;		THE OMNI CONTROLLER ACCEPTS THE		*
;		GENERAL STATUS COMMAND			*
;********************************************************

GETDAT:	IN	OMNISTAT
	RRC
	JNC	GETDAT		;IF NOTHING TO GET FROM OMNI
	ANI	40H		;(WHAT DO WE HAVE HERE: DATA -OR- GEN STATUS?)
	IN	OMNIDATA	;TAKE IT, WHATEVER IT IS
	RZ			;IF IT IS GENERAL STATUS, THEN RETURN
	MOV	M,A		;ELSE...PUT INTO BUFFER
	INX	H
	JMP	GETDAT		;KEEP ON KEEPING ON

;********************************************************
;	SUBROUTINE TO ISSUE COMMAND LIST		*
;********************************************************
CMDLIST:
	XTHL
	MOV	C,M		;FETCH LENGTH OF LIST
	INX	H
CMDLIST1:
	IN	OMNISTAT
	ANI	OUTREADY
	JNZ	CMDLIST1	;IF OMNI NOT READY FOR COMMAND
	MOV	A,M		;NEXT BYTE TO SEND
	INX	H
CMDLIST2 OUT	OMNIDATA
	DCR	C
	JNZ	CMDLIST1	;IF MORE COMMANDS TO SEND
	XTHL
CODELBA	RET			;LABEL DEFINES CODE LAST BYTE ADDRESS (LBA)

;
;	THE FOLLOWING 8088 CODE IS USED IF WE HAVE BOOTED TO
;	A COMPUPRO (tm) 8085/8088 CPU.
;
;	THE 8085 "IN SWAP" AT THE FIRST OF THIS PROM CAUSES THE 8088
;	TO BEGIN AT ITS RESET ADRESS, 0FFFF0H.  THAT TAKES US TO 1F0H
;	IN THIS PROM BECAUSE THE HIGH-ORDER BITS OF THE ADDRESS ARE
;	IGNORED.  THE "JMP FAR" INSTRUCTION FOUND THERE SETS <CS> TO
;	ZERO AND THE PROGRAM COUNTER TO 3FCH.  NOW AT 3FCH (ASSEMBLED
;	AT 1FCH FOR THIS PROM) THE 8088 EXECUTES "IN AL,SWAP",
;	CAUSING THE 8085 TO START RUNNING AGAIN.  ***BEFORE THE 8088
;	SWITCHES, IT PRE-FETCHES THE TWO "NOP" INSTRUCTIONS.***
;	THUS WHEN THE 8088 IS STARTED AGAIN IT EXECUTES 3FEH AND 3FFH,
;	THE PRE-FETCHED	NOP'S, AND APPEARS TO START EXECUTION AT 400H.
;
	ORG	1F0H
	DB	0E4H		;8088 JMP FAR ...
	DW	3FCH,0		;8088 JMP FAR DEST & CODE SEG

	ORG	1FCH
	DB	0E4H,SWAP	;8088 IN AL,SWAP
	DB	90H,90H		;8088 TWO NOP'S FOR PREFETCH 
	END
