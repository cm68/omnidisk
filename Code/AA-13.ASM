TITLE 'AA-13.ASM OMNIDISK FIRMWARE'
PAGE 0
;
;KK       NOTE: FOR CHANGES DONE BY DAVE KOSKI SEARCH FOR: KK
;********************************************************************
;         DMA DISK CONTROLLER FIRMWARE                              *
;         COPYRIGHT (c) 1983 W/W COMPONENT SUPPLY                   *
;                                                                   *
;         MACHINE READABLE SOURCE CODE IS AVAIABLE TO QUALIFIED     *
;         CUSTOMERS. CALL US FOR MORE INFO.                         *
;                                                                   *
;         WARNING: FEDERAL COPYRIGHT LAW PROHIBITS UNAUTHORIZED     *
;         DISTRIBUTION.                                             *
;                                                                   *
;********************************************************************
;   STICKY LABEL: 97 TIME: 0800 DATE: 12 MAR 85
;
;-----------FIX--HISTORY------------------------
;
;
;        24 NOV (Turkey day) 1983
;                ADD 16 MS DELAY AFTER FLOPPY DISK 8<==>5 SWAP
;                SHOULD NOW DO SINGLE/DOUBLE ON 8" W/O READY CHANGE
;                (MOVED NECINT2..NECINT5 TO RPI. NAMES: RPINTx)
;
;        26 NOV 1983
;                CLEAN UP RPINTx CODE
;
;        03 DEC 1983
;                RPI NOW CHECKS RESSC FOR CORRECT CYILNDER W/ RETRY IF BAD
;
;        23 DEC 1983
;                DEBUG CODE TO TEST WHO-IS-TO-BE-THE-A:-DISK SWITCH SETTING
;
;        25 DEC (Merry Christmas) 1983
;                REMOVE 23 DEC DEBUG CODE
;                DOCUMENT SWITCH SETTING
;                REMOVE DEBUG DELAYS FOR 5" FLOPPY
;                USED RRC/JNC INSTED OF ANI/JZ IN GETHOST
;                PULLED ALL DEBUG CALLS
;                SET RAM SIZE TO 12K
;
;        26 DEC 1983
;                (25 DEC SYSTEM DID NOT WORK)
;                INITSPEC USED INSTED 0F HEX CONSTANT FOR STEP RATE SETTING IN INIT
;                PUT RAM BACK TO 16K -- AND BACK TO 12K
;                RESTORE ANI/JZ TO PRE - CHRISTMAS USE -- AND BACK TO CHRISTMAS
;                RESTORE PBUFFER: AND DELETE
;                RESTORE EXTRA DELAYS
;
;        27 DEC 1983
;                PULL DELAYS IN NECSERV AND WNB2
;
;        28 DEC 1983
;                SET RAM SIZE TO 10K
;
;        03 JAN 1984
;                HAPPY NEW YEAR
;                ONLY A: DEFINED AT POWER ON, SWITCH SETTING DEFINES DISK
;
;        *** 1984 ***
;
;        05 JAN 1984
;                FIX 03 JAN CODE. FORCE UNDEFINE ALL BUT A: DISK.
;
;        06 JAN 1984
;                REMOVE DROP-DEAD*ON-ERROR SUBROUTINE
;                CHANGE AND DOCUMENT SEVERAL UNIQUE ERROR CODES
;                REMOVE SEEK-TO-INNER FROM RWRETRY ETC
;
;        11 JAN 1984
;                ADDED HARD DISK STUFF BCW
;
;        29 FEB (leap day) 1984
;                SPLIT INTO 25 SECTIONS
;                MADE ALL THINGS NEW UNDER THE GETDPB COMMAND
;                NEW GETDPB: FIXED BAD JMP THAT STOPPED SD DISKETTS FROM WORKING
;
;        01 MAR 1984
;                NEW GETDPB: FIXED WRONG REGISTER IN LOCDPB FDRELTAB SEARCH
;                NEW GETDPB: ADDED MISSING CODE TO LOCDPB
;
;        02 MAR 1984
;                NEW GETDPB: YET ANOTHER FIX IN THE NEW FDREL SEARCH
;                RESTORED PART OF FMT MESSED UP IN DOING NEW GETDPB
;
;        05 MAR 1984
;                STILL 5" SYSWRT PROBLEM
;                ADDED RE-ORGANIZED HARD DISK CODE WITH 3 DIVIDE ROUTINES
;                REMOVE ALL "PRIORITY BUFFER" STUFF
;
;        09 MAR 1984
;                REMOVED "PRIORITY BUFFER" LENGTH FROM MAKECUR
;                ADDED ZAP OF "WDDEV" TO DEV CHANGE IN MAKECUR (BOOT PROBLEM)
;
;        11 MAR 1984
;                REMOVE SOME DEBUG CODE
;                PULL GARBAGE (??) FROM HDINIT
;
;        16 MAR 1984
;                FIX HD$DPB ALLOC COUNT
;                START TO MAKE VERIFY ONLY ON HARD DISK WORK
;                MAKE HD FORMAT WRITE ES'S TO ALL SECTORS
;
;        17 MAR (Have a nice St. Pat's day.) 1984
;                HDINIT NOW USES (OPTIONAL) RECAL PLUS SEEK [NOT RECAL + RECAL]
;
;        18 MAR 1984
;                FIX MORE OF HDINIT
;
;        19 MAR 1984
;                AGAIN REMOVE UNCONDITIONAL HEAD LOAD AND RECAL AFTER RESET
;                ** DEBUG VERSION: SA712 HAS ONLY 3 HEADS
;
;        20 MAR 1984
;                MADE WRITE AN INTERNAL SUBROUTINE TO HELP SYSWRT WHEN NO
;                VALID ID CAN BE READ FROM FLOPPY DISK TRACK
;
;        22 MAR 1984
;                ADDED SEVERAL NEW FD FORMATS IN FDREL
;
;        25 MAR 1984
;                PUT SA712 BACK TO 4-HEAD DEVICE
;
;        27 MAR 1984
;                READID ON SIDE 2 OF 5.25" FLOPPIES FOR DOUBLE-SIDED CHECK
;                REMOVE "SETHEAD" USE FROM "GETDPB" FUNCTION
;
;        29 MAR 1984
;                BOOT/SYSWRT TO USE (DPB) LOGICAL SECTORS/LOGICAL TRACK
;                REMOVED CURLDT AREA
;                ZAPPED BUFSIDE IN MAKECUR TO KEEP FWT FROM ACTING UP
;
;        30 MAR 1984
;                5.25" SIDE 2 READID ERROR NO LONGER LEFT IN GENSTAT
;
;        01 APR (tax time approaches...no foolen) 1984
;                CHANGED 5.25" STEP RATE TO 16 Ms FOR DEBUG
;                FIXED 8/5 STEP RATE SETUP NEAR MAKEC1A
;
;        05 APR 1984
;                ZEROED CPSSSIDE BEFORE LOCDPB CALL IN BOOT/SYSWRT
;                5.25" STEP RATE BACK TO 5MS
;
;        06 APR 1984
;                FIXED SETSKEW FUNCTION (SKEW BYTE ADDRESS WAS MESSED UP)
;
;        10 APR (property tax day) 1984
;                ADDED GET ROUTINES FOR EXTENDED DPB AND MS-DOS BPB
;                EXTENDED COMMAND TABLE FOR NEW OPCODES
;                CHANGED END-OF-TABLE EQUATE
;                MOVED FF OPCODE INTO COMAND TABLE
;
;        12 APR 1984
;                ADDING EXTENDED DPB AND BPB STUFF...
;                AT THIS POINT WE ARE USING 128-BYTE LOGICAL SECTORS
;
;        14 APR (At last my federal tax refund came -- just in time to pay state tax)
;                ADDING CODE FOR PHYSICAL FORMAT I/O
;                MAX LENGTH FOR HARD DISK IS 2000 (NOT 2048) ALLOC UNITS
;
;        15 APR 1984
;                PHYSICAL MODE I/O DONE...NOW TO DEBUG
;
;        16 APR 1984
;                FIXED STUPID BUG IN INBUFREAD/WRITE -- NEED "0080H" NOT JUST "0080"
;
;        17 APR 1984
;                FIXES IN MS-DOS BPB GENERATOR
;                FIXED WRONG SENSE OF RTN ON PFIOFLAG IN HARD DISK BUFFER ADDRESS
;                FIXED BAD LENGTH IN 200H & 400H SECTOR SIZE
;
;        18 APR 1984
;                FIXED BAD LENGTH IN FLOPPY DISK GETDPB
;                FIX BAD LENGTH IN PHYS FORMAT WRITE
;
;        19 APR 1984
;                MORE LITTLE CHANGES IN INBUF READ/WRITE LENGTH USAGE
;                MULTI-LOGICAL-SECTOR DMA XFERS JUST MIGHT NOW WORK
;
;        20 APR 1984
;                ADDED 5" DD 512-BYTE 9 SECTOR FORMAT
;                PULLED DD 128 FORMATS
;                ADJUSTED 5" DD 1024-BYTE 5 SECTOR FORMAT
;
;        23 APR 1984
;                FIXED HANG IN PHYS MODE WRITE
;
;        25 APR 1984
;                CHANGED GET MEDIA CHANGE STATUS STUB TO REAL ROUTINE
;                MEDIA CHANGE STAT PUT INTO GETDPB, NECSERV AND UNLOAD
;
;        26 APR 1984
;                MEDIA CHANGE STATUS PUT INTO 8<==>5 SWAP
;                HARD DISK DPB EXTENDED FOR MS-DOS ETC
;                MASK ST3 BEFORE USING TO MAKE DEVICE TABLE ADDRESS
;
;        27 APR 1984
;                PUT A BUNCH OF CHANGES INTO MOST ALL MY DMA CODE

;        30 APR 1984
;                FIX LOCAL DMA ADDRESS IN MEMORY DISK READ
;
;        02 MAY 1984
;                CORRECTED DPB EXTENSION FOR CP/M+
;
;        03 MAY 1984
;                ADDED # SIDES CHECK IN FORMAT
;                RECAST (FLOPPY DISK) FORMAT AND VERIFY INTO SEPARATE SUBROUTINES
;
;        04 MAY 1984
;                BUG FIXES IN CHANGED FORMAT STUFF
;
;        09 MAY 1984
;                MOVED CODE FROM INITALL TO INIT TO STOP FWT AFTER RESET
;
;        11 MAY 1984
;                DEBUG TURNED ON TO FIND STRANGE HANG
;
;        12 MAY 1984
;                MS-DOS SS 5" FD TO ONE PHYSICAL SECTOR PER ALLOCATION UNIT
;
;        13 MAY 1984
;                DEBUG TURNED OFF (FMT BUG KILLED ONLY DISKETTE GIVING STRANGE HANG)
;                FORMAT CODE FOR NUMBER-OF-SIDES CHECK NOW IN PLACE
;                FORMAT CODE FOR KILL BACK SIDE OF DISKETTE NOW IN PLACE
;
;        14 MAY 1984
;                HARD DISK BPB FIXED ('TWAZ OFF BY 4 BYTES)
;                SEEK TO GIVEN TRACK BEFORE DOING NUMBER-OF-SIDES CHECK USING WRITE
;
;        21 MAY 1984
;                BPB FIX IN 8" 8 1024-BYTE SINGLE DENSITY
;                DEFINE "SET FLOPPY DISK PARAMETERS" COMMAND
;                VARIOUS CHANGES TO USE VALUES SET IN ABLVE NEW COMMAND
;                INIT PART OF RAM BY A LIST COPY
;
;        23 MAY 1984
;                DEFINE MS-DOS FAT SIZE FOR FLOPPY USING MATH INSIDE MACRO
;                IMPLEMEMT HEAD SETTLE DELAY IN WAITNBUSY
;                PUT REPLY TO SETSKEW COMMAND IN GENERAL STATUS
;
;        29 MAY 1984
;                POWER-ON BUG FIXED (READ AND TRASH DONE TWICE)
;
;        04 JUN 1984
;                FIX FOR 8" GET-MEDIA-CHANGE STATUS
;
;        05 JUN 1984
;                FIX FOR ALL FLOPPY GET-MEDIA-CHANGE STATUS
;
;        24 JUN 1984
;                FOR MS-DOS 8" DS 1024-BYTE SECTORS: 1 SECTOR = 1 ALLOCATION UNIT
;
;        25 JUN 1984
;                BETTER CHECK FOR READY CHANGE IN NECSERV
;
;        26 JUN 1984
;                FIX STUPID BUG IN PHYSICAL (OPS 1E/1F) HARD DISK READ/WRITE
;
;        27 JUN 1984
;                NEW SUBROUTINE OF NECSERV TO TAKE ALL INTERRUPT STAT BEFORE
;                DOING ANYTHING ELSE (RECURSIVE SUBROUTINE)
;
;        19 JUL 1984
;                PART WAY TO COMMON HARD DISK STUFF:
;                NUMBER OF HEADS IS IN MEMORY
;                (HARD DISK) CONTROLLER **ECC/NO-ECC** TYPE IS IN MEMORY
;
;        20 JUL 1984
;                BUG FIXES FROM 19 JUL:
;                BAD VALUE FOR CTLR TYPE
;                N0 "RET" IN DIVIDE SUBROUTINE
;
;        26 JUL 1984
;                MORE COMMON HARD DISK STUFF:
;                STEP RATE NOW IN MEMORY BYTE
;                HAVE HARD DISK DEVICE TABLE ENTRY FOR 0S TABLE (DPB/BPB/WHATEVER)
;
;        27 JUL 1984
;                MOVED STEP RATE SETTER TO ABOVE HDINIT TO ALSO SET STEP RATE
;
;        28 JUL 1984
;                ADDED PRECOMP CYL TO MEMORY PARAMETER
;                GETDPB ETC NOW USE OS BLOCK IN HARD DISK DEVICE TABLE
;                FIXED BAD REGISTER IN GETDPB ETC FROM HARD DISK
;
;        29 JUL 1984
;                HD BOOT SHOULD NOW WORK--SECTORS/TRK NO LONGER FROM DPB
;                HD I/O CODE NOW USES DEV SEL AND HARDWARE OFFSET
;
;        31 JUL 1984
;                CHANGED GET OF MEMORY DISK PARAMETER STUFF
;                STRUCTURE NOW: INIT FLAG, FOUR LEN/LOC PAIRS, LEN OS BLOCK, OS BLOCK
;                (PRIOR STRUCTURE HAD INIT FLAG LAST AND ONLY DPB ALLOWED)
;
;        01 AUG 1984
;                CHANGED TO RETURN MEM DISK OS BLOCK DEFINED YESTERDAY
;
;        02 AUG 1984
;                BOOT/SYSWRT CODE TO SWAP CTLR TYPE ON CERTAIN HARD DISK ERRORS
;                "JMP BOOTSUB" NOW SETUP IN INITALL LIST
;                INSTALL DEBUG CODE SO I CAN SEE HARD DISK ERROR CODE IN BOOT
;                (Brent is so very busy this year)
;
;        03 AUG 1984
;                INSTALL MORE DEBUG CODE (SEE 02 AUG)
;                TRY EC=40 (BUT CHECK IF FLOPPY ERROR CODE)
;                ITS OK W/ ECC CONTROLLER. FLOPPY DOES NOT MAKE EC=40.
;
;        04 AUG 1984
;                PULL DEBUG CODE IN BOOT/SYSWRT
;                SKEW FACTOR FROM SEEKSEC USED IN HARD DISK FORMAT
;
;        05 AUG 1984
;                MOVE ZERO OF SEEKSEC OUT OF EARLY PART OF FMTTRK
;
;        10 SEP 1984
;                FIX PHYSICAL SECTOR READ/WRITES FOR HARD DISK, MOSLTLY WRITES
;                ADD FAST READ/WRITES FOR PHYSICAL NON DMA HARD DISK
;
;        06 NOV (election day) 1984
;                CORRECT MEDIA BYTES FOR IBM-PC COMPATABILITY; MAKE ALL UNIQUE
;                PULL SOME OLD COMMENTED-OUT HARD DISK STUFF
;
;        20 NOV 1984
;                TRIM .75 USEC/BYTE OFF NON-DMA FULL SECTOR HARD DISK READ
;                RESTORE HARD DISK FWT WITH HD FULL SECOTR NON-DMA READ/WRITE
;
;        26 NOV 1984
;                PUT BRENTS HEX PATCHES OF FDRELTAB INTO SOURCE
;                ADD IGNORE FD ERROR OPCODE
;
;        *** 1985 ***
;
;        16 JAN 1985
;                ADD OPCODES TO SET AND GET (SEPARATE) HARD DISK PARAMS
;
;        11 MAR 1985
;                MORE OF THE SAME...
;
;        12 MAR 1985
;                GETTING THE FINAL BUGS OUT OF THE ABOVE
;                MOVED HDINIT CALL INTO INITALL
;
;---------END--FIX--HISTORY------------------------
;
;                ORGANIZATION OF THIS CODE....
;
;                1. EQUATES
;                2. "RST" AREA
;                        RST 0: POWER ON/RESET JMP
;                        RST 4..7 JMP TO THE ONE-BYTE NEC/HOST READ/WRITE ROUTINES
;                3. FINISH RESET PROCESSING
;                        IDLE LOOP
;                        COMMAND DECODE
;                        COMMAND TABLE
;                4. POWER-ON INIT
;                5. VARIOUS SHORT COMMAND PROCESSORS
;                6. THE ONE-BYTE NEC/HOST READ/WRITE ROUTINES
;                7. BOOT/SYSWRT ORGANIZER
;                8. FLOPPY DISK SEEK STUFF
;                9. FLOPPY DISK HEAD LOAD
;                10. FORMAT TRACK MAINLINE AND FLOPPY DISK FORMAT
;                11. CALCLUATE PHYSICAL SECTOR FOR FLOPPY DISK
;                12. FLOPPY DISK READ/WRITE
;                13. FLOPPY DISK READ-PHYSICAL-ID (FOR DENSITY INFO)
;                l4. FLOPPY DISK FORCE WRITE (OF MODIFIED SECTORS), DUMP BUFTAGS
;                15. NEC INTERRUPT SERVICE WITH ERROR CODE GENERATOR AND RESET$NEC
;                16. ALL HARD DISK ACCESS CODE
;                17. ALL DMA STUFF (FOR NORMAL READ/WRITE, MEM DISK AND MOVE MEMORY)
;                18. BLOCK TRANSFER TO/FROM HOST AND RELATED STUFF
;                19. SETUPS FOR PHYSICAL DISK CHANGE
;                20. LOGICAL/PHYSICAL DEVICE SUBROUTINES
;                21. SET AND USE RETRY COUNTERS
;                22. SET SKEW (HOST CALL), BUILD FPY SKEW TABLE, FPY SECTOR OFFSET STUF
;                    RETURN VERSION NUMBER (1.1 AND LATER)
;                23. MACROS TO HELP BUILD FDREL; FDREL; HARD DISK DPB
;                24. DEBUG SUBROUTINE
;                25. RAM ORGANIZATION
;
;        KK 22 MAR 1986
;                DAVE COMPLETES MODIFICATIONS
;                FUNCTIONS ADDED: DEC HEX
;                SETRAMDPB        36  24 SET FLOPPY DPB AND PARAMETERS
;                GETRAMDPB        37  25 GET FLOPPY DPB AND PARAMETERS
;                DORID            38  26 READ I.D. INFO TO EXTENDED STATUS
;                INDIVSTEP        39  27 SET INDIVIDUAL STEP RATES
;                SETTPI           40  28 SET TRACK DENSITY STATUS (48-96 TPI)
;                GETTPI           41  29 INVERSE OF ABOVE
;                GETVERS          42  2A RETURN VERSION TO HOST
;                DUMPTAGS         43  2B RETURN BUFTAGS TO HOST
;
;                ADDITIONAL NOTES:
;                        - 48 TPI DISKS MAY BE USED IN 96 TPI UNITS. USE FUNCTION 40 28H TO
;                        SET/RESET THIS ATTRIBUTE. IF SET, CPS$TRACK:= CPS$TRACK * 2.
;
;                        - DPB PARAMETER "OFF" IS NOW TRACK OFFSET AND NOT CYLINDER OFFSET.
;                        THIS MAKES IT POSSIBLE TO R/W KAYPRO IV DISKS AND OTHERS WHICH HAVE
;                        A ONE TRACK (NOT ONE CYLINDER) OFFSET. FOR SINGLE SIDED DISKS, TRACK
;                        OF COURSE IS SAME AS CYLINDER. CPS AND FDREL HAD TO BE MODIFIED
;                        TO SUPPORT THE ABOVE. SEPERATE ENTRY IS NOW AVAILABLE FOR SEEK$CPS.
;
;                        - WHEN A SEEK TRACK (CPS$TRACK) IS GREATER THAN THE NUMBER OF
;                        CYLINDERS OF A FLOPPY UNIT, CPS$SIDE IS INCRIMENTED AND THE NUMBER
;                        OF PHYSICAL CYLINDERS IS SUBTRACTED FROM CPS$TRACK. THIS MAKES IT
;                        POSSIBLE TO R/W DISKS THAT ALLOCATE SIDE ZERO COMPLETELY BEFORE
;                        ALLOCATING ANYTHING TO SIDE ONE (LIKE VECTOR GRAPHICS).
;
;                        - EVEN WITH THE ABILITY TO ADD A BIAS T0 SECTOR AND SIDE IDs
;                        (FUNCTION 36 24H), IT IS ALAS, STILL NOT POSSIBLE TO R/W SOME TYPES.
;                        OF THOSE ARE DISKS THAT HAVE EVEN PHYSICAL SECTOR ID NUMBERS ON ONE
;                        SIDE AND ODD ON THE OTHER, DISKS THAT HAVE FALSE "R" ID FIELDS
;                        (COMPUGRAPHIC USES FE, PRESUMABLY THEY USE A WESTERN DIGITAL 179x
;                        CONTROLLER), DISKS THAT ARE BYTE COMPLEMENTED (THOUGH THE BIOS
;                        COUD FIX THAT), ETC.
;
;        KK 27 APR 1986
;                BUG FOUND: RECAL NOT WORKING ON 96 TPI SOMETIMES BECAUSE
;                NEC STEPS IN 77 TIMES AND GIVES UP
;                SOLUTION: ON RECAL, DO IT TWICE UNCONDITIONALLY. IF IT WORKED
;                THE FIRST TIME, SO WHAT? LITTLE TIME IS WASTED TRYING SECOND TIME.
;
;        KK 07 DEC 1986
;                ADD FUNCTIONS TO ENABLE HOST DIAGNOSTIC SOFTWARE TO USE DYSAY DDD
;                (DIGITAL DIAGNOSTIC DISKETTE) FOR ALIGNMENT, ETC. FUNCTIONS INCLUDE
;                ADDING BIT TO PARAMETER OF HOST FORMAT COMMAND SO THAT HOST MAY CALL
;                OMNI TO "VERIFY" A TRACK STARTING AT A GIVEN PHYSICAL SECTOR. ALSO
;                A FUNCTION HAS BEEN ADDED TO RETURN THE BUFTAGS TO "SEE" WHICH SECTORS
;                HAVE BEEN SUCCESFULLY READ. A FUNCTION TO RETURN OMNI FIRMWERE VERSION
;                NUMBER (STARTING 11H FOR 1.1 "AA11.ASM") TO HOST HAS BEEN ADDED.
;
;        KK 22 DEC 1986
;                BUG IN BOOT FIXED. LOCDPB WAS USING SEEKTRK (WHICH IS SEEK CYLINDER)
;                AND R/W IN BOOT WAS USING CPS$TRACK. THIS CAUSED LOCDPB TO REPORT THE
;                DENSITY OF THE WRONG TRACK OF 8 INCH IN WHICH THE BOOT CYLINDER IS OF
;                A DIFFERENT DENSITY. FAILURE WAS ON THE SECOND TRACK.
;
;                I DON'T LIKE THE WAY POWER ON INITIALIZATION WAS DONE. THE ORDER HAS
;                BEEN CHANGED. TABLES WERE BEING ACCESSED BEFORE THEY WERE BEING INIT-
;                IALIZED - I THINK.
;
;        KK 30 DEC 1986
;                COMPLETED TIMER FOR PREAD/PWRITE TO CHECK DRQ FROM 765 TO SEE IF
;                WE HAVE A 5 INCH WITHOUT A DISK. ON TIMEOUT THE 765 IS RESET
;                (REQUIRES HARDWARE MOD.) AND AN ERROR CODE IS FAKED AND THEN
;                EXECUTION RESUMES AN "BEGIN$0" WHICH RESETS STACK AND WAITS FOR
;                HOST COMMANDS (MAIN IDLE LOOP). LOCDPB NOW ALSO TIMES OUT AND FAKES
;                AN ERROR CODE. THE DRQ CHECK IS DONE BY A RIM INSTRUCTION. THIS ALSO
;                REQUIRES A HARDWARE MODIFICATION AND PROBABLY RENDERS THIS FIRMWARE
;                INCOMPATABLE WITH UNMODIFIED BOARDS. IT IS A SIMPLE ONE THOUGH.
;
;                SIMPLY CONNECT SID OF 8085 TO DRQ OF 765 - NO CUT TRACES.
;
;        KK 31 DEC 1986 (11:55 P.M. happy new year)
;                FIXED BUG IN FORMAT. WAS NOT SETTING CPS$SIDE TO 0 RESULTING IN
;                INCORRECT NUMBER OF SIDES REPORT. WAS FORMATTING DOUBLE SIDED
;                DISKS SINGLE SIDED SOMETIMES DEPENDING ON THE VALUE THAT HAPPENED
;                TO BE IN CPS$SIDE.
;
;                ALSO FORCED 2 SIDED TRUE ON ALL 5 INCH AND FIXED A STACK PROBLEM
;                AT PRWlO, THE RETURN ROUTINE OF PHYSICAL R/W.
;

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   1.          EQUATES
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;                CONFIGURATION EQUATES (done with SET to reduce size of ".SYM" file)
;
VERSION         EQU     13H                 ;VERSION 1.3 (A13.ASM)
INITRETRY       SET     0503H               ;RETRYC1=3, RETRYC2=5
;
INITLOCCONT     SET     08FH                ;SET FOR 8" AT POWERUP/RESET
;INITSPEC       SET     SPEC8               ;SET FOR 8" AT POWERUP/RESET
;
FALSE           SET     0
TRUE            SET     NOT FALSE
IN$OS$DEBUG     EQU     FALSE               ;KK SET FOR DEBUG IN CP/M AT 100H
DEBUGGING       EQU     FALSE               ;MAE Set to enable DEBUG code
;
RIM             MACRO
                DB      20H
                ENDM
SIM             MACRO
                DB      30H
                ENDM
SIMMSK          EQU     0101$1011B          ;KK DEFAULT SIM VALUE
;
;              MSB                                                      LSB
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;SIM        |  SOB  |  USE  |  NOT  | RESET |  USE  | MASK  | MASK  | MASK  |
;INST       |       |  SOB  | USED  |RST 7.5| MASKS | 7.5   | 6.5   | 5.5   |
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;
;              MSB                                                      LSB
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;RIM        |  SIB  |  7.5  |  6.5  |  5.5  | 0:DI  | 7.5   | 6.5   | 5.5   |
;INST       |       |ACTIVE |ACTIVE |ACTIVE | 1:EI  |MASKED |MASKED |MASKED |
;           +-------+-------+-------+-------+-------+-------+-------+-------+
;
; KK                SOB:          RESET NEC
;                   SIB:          NEC DRQ
;                   5.5:          ?? ON SOME SORT OF JUMPER ??
;                   6.5:          WD1001 INTERRUP
;                   7.5:          NEC CHIP INTERRUPT
;
;
;               MSB                                                     LSB
;STATUS     +-------+-------+-------+-------+-------+-------+-------+-------+
;           |       |       |       |       | FROM  |0: ON  |0: ON  |  TO   |
;4018H      |       |       |       |       | HOST  |1: OFF |1: OFF | HOST  |
;I/O: 58    +-------+-------+-------+-------+-------+-------+-------+-------+
;                                                   | SW# 6   SW# 4 |
;       FROM HOST             TO HOST               |   SWITCH S1   |
;       0: DATA NOT READY     0: OK TO SEND         +---------------+
;       1: DATA READY         1: HOST HAS NOT
;                                TAKEN OUR LAST BYTE
;
;LOCAL          MSB                                                     LSB
;CONTROL    +-------+-------+-------+-------+-------+-------+-------+-------+
;           | DMA   | HEAD  | 0: 8" |       |       |4-BIT S100 DMA PRIORITY|
;C006H      |DIREC'N| LOAD  | 1: 5" |       |       |                       |
;I/O: C6    +-------+-------+-------+-------+-------+-------+-------+-------+
;
;
;
;S100           MSB                                                     LSB
;CONTROL    +-------+-------+-------+-------+-------+-------+-------+-------+
;           |       |       |       |       |       |       |       |       |
;C007H      |       |       |       |       |       |       |       |       |
;I/O: C7    +-------+-------+-------+-------+-------+-------+-------+-------+
;
;
;               HARDWARE EQUATES
;
;               (MOST ARE DONE WITH "SET" TO KEEP THEM OUT OF
;                THE MAC ".SYM" FILE -- THE SYMBOLS ARE NOT CHANGED)
;
WDDATA          SET     4000H               ;HARD DISK DATA TRANSFER PORT
WDDATAIO        SET     40H
WDERROR         SET     4001H               ;HARD DISK ERROR REGISTER
WDERRORIO       SET     41H
DSECTCNT        SET     4002H               ;HARD DISK NUMBER OF SECTORS??
WDSECTCNTIO     SET     42H
WDSECT          SET     4003H               ;HARD DISK SECTOR NUMBER
WDSECTIO        SET     43H
WDLOTRK         SET     4004H               ;HARD DISK TRACK NUMBER (LOW 8 BITS)
WDLOTRKIO       SET     44H
WDHITRK         SET     4005H               ;HARD DISK TRACK NUMBER (HIGH ORDER HITS)
WDHITRKIO       SET     45H
WDSPEC          SET     4006H               ;HARD DISK SPECS (STEP RATE, ETC)
WDSPECIO        SET     46H
WDSTAT          SET     4007H               ;HARD DISK STATUS
WDSTATIO        SET     47H
WDCMD           SET     4007H               ;HARD DISK COMMAND
WDCMDIO         SET     47H

WDFMTCMD        SET     50H
WDWRITECMD      SET     30H
WDREADCMD       SET     20H
HDSECS          SET     16
HDSKEW          SET     2                   ;VALUE FOR SKEW FOR FORMAT
;
;               HARD DISK SELECTION DEFERRED INTO 'OS' INIT CODE
;
HDRECAL         SET     TRUE                ;PULL COND ASSEM IF PROBLEM RESOLVED
HDRECAL         SET     FALSE               ;LEAVE IN FOR SA712

;
;               VARIOUS EQUATES THAT APPLY TO HOST SOFTWARE
;
LEN$DPB         SET     15
LEN$DPBEX       SET     17
LEN$BPB         SET     15

;
;                HARDWARE PORT EQUATES
;
NECSTAT         SET     4008H
NECSTATIO       SET     48H
NECDAT          SET     4009H
NECDATIO        SET     49H

SYSDATIN        SET     4010H               ;DATA TO/FROM S100 SYSTEM
SYSDATINIO      SET     50H

SYSSTAT         SET     4018H               ;STATUS REGISTER FOR XFERS TO/FROM HOST
SYSSTATIO       SET     58H
SYSOUTSTAT      SET     08H
SYSINSTAT       SET     01H

RAMORG          EQU     8000H
RAMEND          EQU     RAMORG+2800H        ;LBA+1 OF RAM

LOCDMAHI        SET     0C000H              ;LOCAL RAM DMA ADDRESS BITS 15-8
LOCDMAHIIO      SET     0C0H
LOCDMALO        SET     0C001H              ;LOCAL RAM DMA ADDRESSBIT 7 ONLY
LOCDMALOIO      SET     0C1H
SYSDMAEX        SET     0C002H              ;S100 SYSTEM DMA ADDRESS BITS 23-16
SYSDMAEXIO      SET     0C2H
SYSDMAHI        SET     0C003H              ;S100 SYSTEM DMA ADDRESS BITS 15-8
SYSDMAHIIO      SET     0C3H
SYSDMALO        SET     0C004H              ;S100 SYSTEM DMA ADDRESS BITS 7-0
SYSDMALOIO      SET     0C4H
SYSDATOUT       SET     0C005H              ;DATA TO S100 SYSTEM
SYSDATOUTIO     SET     0C5H
LOCCONT         SET     0C006H              ;LOCAL CONTROL
LOCCONTIO       SET     0C6H
DMASTAT         SET     0C007H              ;S100 CONTROL FOR DMA XFER
DMASTATIO       SET     0C7H

SYSSTATWR       SET     080H                ;** SET DMA INTO DMASTAT TO CONTROL
SYSSTATRD       SET     091H                ;** DMA TRANSFERS TO/FROM HOST

;                NOTES ON THE ABOVE
;
;                LOCDMALO IS ONLY BIT 7.  IE OUR SIDE OF DMA
;                TRANSFERS ARE DONE ON 128-BYTE BOUNDRIES
;
;                SEE BLOCK AT START OF LISTING FOR LOCCONT AND DMASTAT

;**********************************************************
;               NEC 765 (INTEL 8272) OPCODES
;**********************************************************

READDATA        SET     26H                 ;WITH "SKIP DELETED DATA ADDRESS MARK"
READID          SET     0AH
WRITEDATA       SET     05H
FORMAT          SET     0DH
RECAL           SET     07H
READINT         SET     08H
SPECIFY         SET     03H
DRIVESTAT       SET     04H
SEEKCMD         SET     0FH
;


;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   2.      "RST" AREA
;           RST 0: POWER ON/RESET JMP
;           RST 4..7 JMP TO THE ONE-BYTE NEC/HOST READ/WRITE ROUTINES
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                ORG     0000H
ROM:
                in      SYSDATINIO
                jmp     INIT
                db      0, 0, 0, 0
                db      0, 0, 0, 0
                db      0, 0, 0, 0
                db      0, 0, 0, 0
                db      0, 0, 0, 0
                db      0, 0, 0, 0
                db      0, 0, 0
;               ORG     20H                 ;RST 4 ADDRESS
                jmp     SENDCHAR            ;GO OUTPUT <A> TO HOST
PUTHOST         EQU     4
                db      0, 0, 0, 0
                db      0
;               ORG     28H                 ;RST 5 ADDRESS
                jmp     GETCHAR             ;GO GET A BYTE FROM HOST
GETHOST         EQU     5
                db      0, 0, 0, 0
                db      0
;               ORG     30H                 ;RST 6 ADDRESS
                jmp     SENDNEC             ;GO OUTPUT <A> TO NEC
PUTNEC          EQU     6
                db      0, 0, 0, 0
                db      0
;               ORG     38H                 ;RST 7 ADDRESS
                jmp     GETNEC1             ;GO GET DATA FROM NEC
GETNEC          EQU     7
                db      0
;               ORG     3CH                 ;RST 7.5 ADDRESS
RST75:          di
                jmp     NECSERV
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   3.          FINISH RESET PROCESSING
;               IDLE LOOP
;               COMMAND DECODE
;               COMMAND TABLE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

                IF      IN$OS$DEBUG
                ORG     100H
                ENDIF
INIT:
                lxi     sp,STACK
                mvi     a,INITLOCCONT
                out     LOCCONTIO           ;SET LOCL CONTROL FOR 8"
                sta     CURLCONT            ;SAVE FOR USE BY OTHERS
;
;        IF POWER ON THEN INIT EVERYTHING
;
;        WE CAN TELL BECAUSE RAM DOES NOT COME UP AS 1234H
;
                lhld    H1234
                mvi     a,12H
                xra     h                   ;<A>=0 IF <H>=12H
                mov     b,a
                mvi     a,34H
                xra     l                   ;<A>=0 IF <L>=34H
                ora     b                   ;<A>=0 IF <HL>=1234H
                jnz     INITALL             ;IF POWER ON
;
;        A PROBLEM HAS BEEN REPORTED IN THE ABOVE: IF THE SYSTEM IS POWERED
;        DOWN FOR 5 TO 10 SECONDS, THE OMNIDISK STATIC RAM WILL BEGIN TO
;        FAIL -- BUT THERE IS NO WAY TO BE SURE THAT OUR 1234H WILL GO
;        BEFORE SOME OTHER RAM LOCATIONS.
;
                call    RESET$NEC           ;KK DO A RESET OF NEC AND A DOSPEC ETC.
                xra     a
                sta     DEBUGB

                lxi     h,-1                ;100% JUNK SO AS TO AVOID A MATCH LATER
                shld    BUFTRKS

BEGINGENSTAT:
                sta     GENSTAT
;                        ....               ;FALL INTO COMMAND DECODE

;********************************************************************
;                                                                                                                                        *
;               COMMAND DECODE                                                                                *
;                                                                                                                                        *
;********************************************************************

BEGIN$0:        lxi     sp,STACK
BEGIN:
                lxi     h,BEGIN             ;** PUSH "RTN" ADDRESS
                push    h                   ;** FOR COMMAND ROUTINES
                lxi     h,MODE
                mov     a,m                 ;##
                ani     8FH                 ;## RESET BOOT/SYSWRT FLAG IN MODE BYTE
                mov     m,a                 ;##

                lxi     h,22222             ;22222 = 4000 * 250 / 45
;                                            45 T-STATES/LOOP
;                                            250 MS IS OUR 1/4 SEC TIMER
;                                            4000 T-STATES / MS
;
GETCMD1:
                in      SYSSTATIO           ;10 <===T-STATES FOR INSTRUCTION
                rrc                         ; 4
                jc      GETCMD2             ; 7  IF SOMETHING FROM HOST
                dcx     h                   ; 6
                mov     a,l                 ; 4
                ora     h                   ; 4
                jnz     GETCMD1             ; 10 IF NOT DONE TIMING 1/4 SEC
;                                            ----
;                                             45 T-STATES / LOOP
;
                lxi     h,TIME$WRITE
                dcr     m
                jz      FWT                 ;IF TIME TO FORCE WRITES
                inx     h                   ;<HL>=TIME$HLOAD
                dcr     m
                rnz                         ;IF NOT TIME TO UNLOAD HEADS
;
;        IT IS NOW TIME TO UNLOAD HEADS
;
;UNLOAD:
                lxi     h,CURLCONT
                mov     a,m
                ani     not 40H             ;NOT HEAD LOAD BIT
                mov     m,a
                out     LOCCONTIO
                ani     20H
                rz                          ;IF 8" DRIVES ACTIVE
                lda     RLINE5
                ora     a
                rnz                         ;IF 5" DRIVES HAVE READY LINE
                lxi     h,FD500+PDTFLG
                lxi     d,FD501-FD500
                mvi     c,4
UNL1:           mov     a,m
                ani     NOT 02              ;SET "DROP READY" CONDITION
                mov     m,a
				dad     d                   ;NEXT 5" DEVICE TABLE
                dcr     c
                jnz     UNL1
                ret
;
GETCMD2:        in      SYSDATINIO
                inr     a                   ;(TO PUT FF COMMAND INTO LIST)
                cpi     CMDLIMIT
                rnc                         ;IF INVALID COMMAND TREAT AS NOP
                mvi     b,0
                mov     c,a
                lxi     h,CMDTBL
                dad     b
                dad     b                   ;<HL> = ADDRESS W/I CMDTBL
                mov     e,m
                inx     h
                mov     d,m
                xchg                        ;<HL> = PROCESS ADDRESS
                pchl                        ;GO DO IT -- NOTE: <B>=0
;
CMDTBL:
                dw      INITALL             ;-1        FF        OC$RESET               POWER-ON RESET
                dw      BOOT                ;00        00        OC$BOOT                BOOT DISK
                dw      SYSWRT              ;01        01        OC$SWRT                WRITE SYSTEM (INVERSE OF BOOT)
                dw      SETMODE             ;02        02        OC$MODE                SET PORT OR DMA DATA XFER (+DMA PRI)

                dw      FMTTRK              ;03        03        OC$FMTF                FORMAT TRACK
                dw      DLDS                ;04        04        OC$DLDS                DEFINE LOGICAL DEVICE SET
                dw      GLDS                ;05        05        OC$GLDS                GET LOGICAL DEVICE SET
                dw      XFWT                ;06        06        OC$FWRT                FORCE PENDING WRITES
                dw      RBOOTPH             ;07        07        OC$RSBP                RESET (BOOT PROM) PHANTOM

                dw      SETSKEW             ;08        08        OC$SKEW                SET SKEW BYTE INTO DEVICE TABLE
                dw      SETDRV              ;09        09        OC$UNIT                SELECT (LOGICAL) UNIT
                dw      SETTRK              ;10        0A        OC$TRAK                LOGICAL SEEK
                dw      SETSEC              ;11        0B        OC$RECD                SET SECTOR
                dw      SETDMA              ;12        0C        OC$DADR                SET DMA ADDRESS
                dw      READ                ;13        0D        OC$READ                READ LOGICAL SECTOR
                dw      XWRITE              ;14        0E        OC$WRIT                WRITE LOGICAL SECTOR

                dw      SETHEAD             ;15        1F        OC$HEAD                SELECT HEAD (ONLY USED ON HARD DISK)
                dw      MOVMEM              ;16        10        OC$MOVM                MOVE MEMORY WITH DMA
                dw      GETDPB              ;17        11        OC$GDPB                "READ" CP/M DPB FROM SELECTED DRIVE
                dw      DEFMEMD             ;18        12        OC$DFMD                DEFINE MEMORY DISK
                dw      SEPSEEK             ;19        13        OC$SSEK                FORCE MOTION SEEK
                dw      TESTIOIN            ;20        14        OC$TIOW                DEBUG WRITE TO BUFFER
                dw      TESTIOOUT           ;21        15        OC$TIOR                DEBUG READ FROM BUFFER
                dw      GETGENSTAT          ;22        16        OC$GENS                GET GENERAL STATUS
                dw      GETEXTSTAT          ;23        17        OC$EXTS                GET LONG (EXTENDED) STATUS OF R/W ERR
                dw      SETRETRY            ;24        18        OC$SRTY                SET RETRY LOGIC COUNTERS
                dw      GETDPBEx            ;25        19        OC$GPBx                GET EXTENDED DPB (CP/M 3.0)
                dw      GETBPB              ;26        1A        OC$GPBP                GET MS-DOS BPB
                dw      GETMCSTAT           ;27        1B        OC$GMCS                GET MEDIA CHANGE STATUS
                dw      SETFDP              ;28        1C        OC$SFDP                SET FLOPPY DISK PARAMETERS
                dw      PFREAD              ;29        1D        OC$PREA                PHYSICAL FORMAT READ
                dw      PFWRITE             ;30        1E        OC$PWRi                PHYSICAL FORMAT WRITE
                dw      HDPARM              ;31        1F        OC$HDPR                SET HD PARM (#HEADS, PCOMP, STP RATE,CTLR TYP)
                dw      HDTBLS              ;32        20        OC$HDTB                SET HD TABLES (DEV, OFFSET, OS BLOCK)

                dw      ERRIGNORE           ;33        21        OC$FDIE                IGNORE FD ERR & MARK BUFFER VALID
                dw      SETIHDP             ;34        22        OC$SIHD                SET INDIVIDUAL HD PARMS
                dw      GETIHDP             ;35        23        OC$GIHD                GET INDIVIDUAL HD PARMS AND TABLES
                dw      SETRAMDPB           ;36        24        OC$SFPB                SET FLOPPY DPB AND PARAMETERS
                dw      GETRAMDPB           ;37        25        OC$GFPB                GET FLOPPY DPB AND PARAMETERS
                dw      DORID               ;38        26        OC$DRID                READ I.D. INFO TO EXTENDED STATUS
                dw      INDIVSTEP           ;39        27        OC$SIND                SET INDIVIDUAL STEP RATES
                dw      SETTPi              ;40        28        OC$STPi                SET TRACK DENSITY STATUS (TPI)
                dw      GETTPi              ;41        29        OC$GTPi                INVERSE OF ABOVE
                dw      GETVERS             ;42        2A        OC$VERS                RETURN VERSION NUMBER
                dw      DUMPTAGS            ;43        2B        OC$TAGS                RETURN BUFFER TAGS TO HOST
CMDLIMIT        EQU     ($-CMDTBL)/2
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   4.          POWER-ON INIT
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

INITALL:
                di
                xra     a
                lxi     h,RAMORG
                lxi     d,RAMEND-RAMORG
IA1:            mov     m,a
                inx     h
                dcr     e
                jnz     IA1                 ;IF MORE RAM TO ZERO
                dcr     d
                jnz     IA1                 ;IF MORE RAM TO ZERO
;
;        MOVE POWER-UP CONSTANTS TO RAM
;
                lxi     d,PUCONST
                lxi     h,PUDEF
                mvi     c,PULEN
PUMOV:          ldax        d
                mov     m,a
                inx     h
                inx     d
                dcr     c
                jnz     PUMOV               ;IF MORE POWER-UP CONSTANTS TO MOVE TO RAM

                lxi     h,DEBUGC
                shld    DEBUGA
;
;        SET ALL DEVICE TABLES TO UNDEFINED AND
;        INIT FLOPPY DISK SKEW TABLES
;
                lxi     b,12                ;<BC>=PHYS DEV CODE - 10H
IA2:            lxi     h,PDTFINDERS
                dad     b
                dad     b
                mov     e,m
                inx     h
                mov     d,m                 ;<DE>=PHYSICAL DEVICE TABLE ADDRESS
                mvi     a,0FFH              ;** MARK PHYSICAL DEVICE
                stax    d                   ;** TABLE AS UNDEFINED
                lxi     h,LENPDTH
                dad     d                   ;<HL>=PDT ADRS FOR 1ST SKEW CONTROL BYTE
                xchg                        ;...TO <DE>
                mov     a,c                 ;8"=0..3; 5"=4..7; NOT FLOPPY=8..12
                cpi     8
                jnc     IA4                 ;IF NOT FLOPPY DISK DEVICE TABLE
                lxi     h,STD8+5            ;** ASSUME
                mvi     b,NFMT8             ;** 8" DRIVE
                cpi     4
                jc      IA3                 ;IF 8" DRIVE
                lxi     h,STD5+5            ;ELSE...
                mvi     b,NFMT5             ;...SETUP FOR 5" DRIVE

IA3:            mov     a,m                 ;SKEW FACTOR FROM FDRELTAB...
                stax    d                   ;...TO DEVICE TABLE
                inx     d                   ;<DE>=ADRS OF NEXT SKEW CTL BYTE IN DEV TABLE
                push    d
                lxi     d,LENFDREL
                dad     d                   ;<HL>=ADRS OF SKEW BYTE IN NEXT FDREL SLOT
                pop     d
                dcr     b
                jnz     IA3                 ;IF MORE SKEW CONTROL BYTES TO INIT

IA4:            dcr     c
                jp      IA2                 ;IF MORE SKEW TABLES TO INIT
;
;        NOW READ THE SWITCH BITS AND SETUP A: DISK
;
                in      SYSSTATIO
                ani     6                   ;ISOLATE OUR SWITCH BITS
                rlc                         ;SHOULDN'T THIS BE RRC?
                ori     10H                 ;FORM PHYSICAL DEVICDE CODE FOR BOOT DEVICE
                sta     LOGDEVTBL           ;SETUP LOGICAL-TO-PHYSICAL DEVICE TABLE
                xra     a                   ;** FIND PHYSICAL DEVICE TABLE
                call    MLP                 ;** ADDRESS FOR A: DEVICE
                mvi     m,0                 ;PHYS-TO-LOG MAPPING TO PDT TO FINISH A: SETUP

                call    HDINIT              ;INIT FOR HARD DISK
                jmp     INIT                ;NOW DO NORMAL RESET PROCESSING

PUCONST:
                db      6,20                ;WRITE AND HEAD LOAD DELAYS (250MS TICKS)
                db      00FH,00FH           ;8/5 STEP RATE (16MS & 32MS)
                db      0FH,0FH,0FH         ;KK EXTENDED FOR INDIVIDUALIZED STEP RATES
                db      0FH,0FH,0FH
                db      200,200             ;8/5 HEAD LOAD TIME IN MS
                db      50,50               ;8/5 HEAD SETTLE TIME (MS DELAY AFTER SEEK OK)
                dw      INITRETRY           ;READ/WRITE RETRY COUNTS FOR FLOPPY
                dw      1234H
                db      2                   ;HD # HEADS (SET BY OS INIT CODE)
                db      100                 ;HD PRE COMP CYLINDER (FOR WRITES ABOVE THIS CYL)
                db      0FH                 ;HD STEP RATE (INIT TO S...L...O...W)
                db      020H                ;HD DISK CTLR W/O ECC; 512-BYTE SECTORS
                db      (JMP)
PULEN           EQU     $-PUCONST
;
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   5.          VARIOUS SHORT COMMAND PROCESSORS
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; GMCS - Get "Media Change Status"
; Parameters:
;        NONE
; Results:
;        GENSTAT        0  : Media has definitely changed.
;                       -1 : Media status is unknown.
;                       1  : Media has not been changed.
; Description:
;        Returns a one byte description of current media status.
GETMCSTAT:
                call    MAKECUR
                dw      MSC1                ;GO HERE IF HARD DISK OR MEMORY DISK
                lhld    CURPDTADRS
                inx     h ! inx     h       ;FORM ADDRESSOF FLOPPY DISK FLAG BYTE
                mov     a,m                 ;FETCH FLOPPY DISK FLAG BYTE
                ani     3                   ;ISOLATE BITS OF INTREST
                dcr     a                   ;CONVERT TO -1, 0, +1 FOR MS-DOS USE
                rst     PUTHOST
                ret

MSC1:           mvi     a,1                 ;+1 (NO MEDIA CHANGE) IS ALWAYS HARD/MEM STAT
                rst     PUTHOST
                ret

;
; SWAP - Turn Off Boot Prom Mapping
; Parameters:
;        NONE
; Results:
;        NONE
; Description:
;        Release the address space used by the boot PROM.
;        Clears the PHANTOM signal line set by OmniDisk.
RBOOTPH:
                out     SYSDMAEXIO          ;STROBE, NOT CONTENTS, RESETS BOOT PROM PHANTOM
                ret

;
; TESTIOIN - DEBUG WRITE TO RAM
; Parameters:
;        P1 byte:        Lower(L) byte of RAM address.
;        P2 byte:        Upper(H) byte of RAM address.
;        P3 byte:        Lower(E) byte of block count.
;        P4 byte:        Upper(D) byte of block count.
;        P5....<BC>        Block of data
;        If <DE>=0 treat <HL> as EXEC address.
; Results:
;        NONE
; Description:
;        Get block of data from HOST, and optionaly EXEC it.
;
TESTIOIN:
                call    TIOADRLEN
TESTIOIN1:
                rst     GETHOST             ;FETCH BYTE FROM HOST
                mov     m,a                 ;STORE IN BUFFER
                inx     h
                dcx     d
                mov     a,d
                ora     e
                jnz     TESTIOIN1           ;IF MORE BYTES TO BE TRANSFERED
                ret
;
;
; TESTIOOUT - DEBUG READ FROM RAM
; Parameters:
;        P1 byte:        Lower(L) byte of RAM address.
;        P2 byte:        Upper(H) byte of RAM address.
;        P3 byte:        Lower(E) byte of block count.
;        P4 byte:        Upper(D) byte of block count.
;        If <DE>=0 treat <HL> as EXEC address.
; Results:
;        Block of data <BC> bytes in length
; Description:
;        Send block of data to HOST.
;
TESTIOOUT:
                call    TIOADRLEN
TESTIOOUT1:
                mov     a,m                 ;FETCH BYTE FROM BUFFER
                rst     PUTHOST             ;SEND TO HOST
                inx     h
                dcx     d
                mov     a,d
                ora     e
                jnz     TESTIOOUT1          ;IF MORE BYTES TO BE TRANSFERED
                ret
;
TIOADRLEN:                                  ;GET ADDRESS AND LENGTH FOR DEBUG READ/WRITE
                rst     GETHOST
                mov     l,a
                rst     GETHOST
                mov     h,a                 ;HL=ADDRESS OF BLOCK TO READ OR WRITE
                rst     GETHOST
                mov     e,a
                rst     GETHOST             ;DE=LENGTH OF BLOCK TO READ OR WRITE
                mov     d,a
                ora     e
                rnz                         ;LENGTH <> 0 THEN THIS IS READ OR WRITE
                pop     psw                 ;ELSE...KILL RETURN ADDRESS
                pchl                        ;AND OFF WE GO. . . .


;        THE GENERAL STATUS BYTE IS CONFIGURED AS FOLLOWS:
;
;        11XXXXXX - ERROR DETECTED IN PHYSICAL FORMAT
;        10XXXXXX - ERROR DETECTED IN PHYSICAL READ
;        01XXXXXX - ERROR DETECTED IN PHYSICAL WRITE
;        00010000 - (10H) LOGICAL DISK NOT DEFINED
;        00010001 - (11H) ERROR ON FMTTRK PARAMETER LIST
;        00010010 - (12H) CANT READ ID IN RPI (CALLED FROM GETDPB)
;        00010011 - (13H) RETRY FAILS TO RECOVER WRONG CYLINDER IN RPI
;        00010100 - (14H) DISK IS OF UNKNOWN DENSITY
;

;
; GENS - Get General Status
; Parameters:
;        NONE
; Results:
;        byte
; Description:
;        Returns a one byte description of current OmniDisk status.
GETGENSTAT:
                lda     GENSTAT
                jmp     SENDCHAR

;
;        EXTENDED STATUS LIST INCLUDES:
;
;        BYTES    DESCRIPTION
;        -----    -----------------------------------------
;     1      GENERAL STATUS
;     2      PHYSICAL SECTOR IN ERROR
;     3      NEC765/INTEL8272 FDC 7-BYTE RESULT STATUS

;
; EXTS - Get Extended Status
; Parameters:
;        NONE
; Results:
;        Nine bytes:
;        General-Status, Physical-Sector, 7 byte 765A result codes.
;        S0, S1, S2, ..., ..., ..., ...
; Description:
;        Returns a nine bytes description of current OmniDisk status.
GETEXTSTAT:
                lxi     h,GENSTAT
                mov     a,m                 ;GENERAL STATUS HEADS LIST
                mvi     m,0                 ;REQUEST FOR EXTENDED STATUS ZEROS GENERAL STATUS
                rst     PUTHOST             ;SEND GENERAL STATUS TO HOST
                inx     h
                mvi     e,LENESL-1          ;ADDITIONAL LENGTH TO SEND TO HOST
                jmp     GETDPB2             ;SEND <E> BYTES TO HOST

;KK
;KK                SIND - SET INDIVIDUAL STEP RATES
;KK                Parameters:
;KK                        P1 byte:        Floppy device
;KK                        P2 byte:        Step rate
;KK
;KK                Results:
;KK                        NONE
;KK                Description:
;KK                        Set step rate on a selected floppy disk drive
INDIVSTEP:      call    GETFPYHST           ;KK GET FLOPPY DEVICE FROM HOST
                push    psw                 ;KK IF BAD DEVICE CY=1, SAVE
                lxi     h,FD$STEP$RATE
                jnc     INDIVSTEP1          ;KK IF GOOD DEVICE
                lxi     h,MISCBUF           ;KK TRASH INPUT ON BAD DEVICE
INDIVSTEP1:
                cpi     14H                 ;KK 5" OR 8"?
                push    psw                 ;KK SAVE FLAGS
                ani     7
                mov     e,a
                mvi     d,0
                dad     d                   ;KK <HL> = ADDRESS OF SELECTED STEP RATE
                rst     GETHOST             ;KK STEP RATE FROM HOST
                dcr     a
                ral ! ral ! ral
                mov     b,a                 ;KK TEMP SAVE
                pop     psw                 ;KK AGAIN, 5" OR 8"?
                mov     a,b                 ;KK RESTORE
                jnc     INDIVSTEP2          ;KK 5"
                ral
INDIVSTEP2:
                ani     0F0H
                cma
                mov     m,a
                pop     psw                 ;KK ERROR = (CY = 1)
                mvi     a,0
                ral                         ;KK IF CR THEN <A>:= 1
                sta     GENSTAT
                jmp     DOSPEC
;

; SFDP - Set Floppy Disk Parameters
; Parameters:
;        P1 = byte:        Write hold delay in 250ms ticks, 1=255ms.
;        P2 = byte:        Head unload delay in 250ms ticks.
;        P3 = byte:        8" floppy step rate in ms, 1-16ms.
;        P4 = byte:        5" floppy step rate in ms, 2-32ms.
;        P5 = byte:        8" floppy head load time in ms, 0-255ms.
;        P6 = byte:        5" floppy head load time in ms, 0-255ms.
;        P7 = byte:        8" floppy head settle time after seek in ms, 0-255ms.
;        P8 = byte:        5" floppy head settle time after seek in ms, 0-255ms.
; Description:
;        Sets the indicated floppy disk drive parameters.
SETFDP:         lxi     h,WRITE$DELAY
                call    CG2                 ;PICK UP DELAY-AFTER-WRITE AND STAY-LOADED TIME
                rst     GETHOST             ;8" STEP TIME
                dcr     a
                ral ! ral ! ral ! ral
                ani     0F0H
                cma
                mvi     e,4                 ;KK 4 8" DRIVES
SETFDP8:
                mov     m,a                 ;SAVE 8" STEP TIME IN "SPECIFY" FORMAT
                inx     h
                dcr     e
                jnz     SETFDP8

                rst     GETHOST             ;5" STEP TIME
                dcr     a
                ral ! ral ! ral
                ani     0F0H
                cma
                mvi     e,4                 ;KK 4 5" DRIVES
SETFDP5:
                mov     m,a                 ;SAVE 5" STEP TIME IN "SPECIFY" FORMAT
                inx     h
                dcr     e
                jnz     SETFDP5

                call    GC4                 ;GET HEAD LOAD TIMES AND HEAD SETTLE TIMES
;               ...                         ;NOW DO THE SPECIFY
;
;        DOSPEC -- ISSUE SPECIFY COMMAND TO FDC
;
DOSPEC:         lda     CURPHYSDEV          ;KK USE CURRENT DEVICE
                ani     7
                mov     c,a                 ;KK ..FOR STEP TABLE OFFSET
                mvi     b,0
                lxi     h,FD$STEP$RATE      ;SETUP FOR 8" SPECIFY
                dad     b
;KK             LDA     CURLCONT
;KK             ANI     20H
;KK             JZ      DOSPEC1             ;IF 8"
;KK             INX     B                   ;ELSE...SETUP FOR 5" SPECIFY
DOSPEC1:        mvi     a,SPECIFY           ;NEC SPECIFY COMMAND
                di
                rst     PUTNEC
;KK             LDAX    B                   ;STEP RATE WORD
                mov     a,m                 ;KK FROM TABLE INSTEAD
                rst     PUTNEC
                mvi     a,2                 ;MIN (2MS) HEAD SETTLE TIME, DMA
                rst     PUTNEC
                ret

;
; IERR - Error ignore
; Parameters:
;        NONE
; Results:
;        NONE
; Description:
;        Ignore last FD error.
ERRIGNORE:      lda     PIOERSECT
                mov     l,a
                lda     RES$R
                cmp     l
                rnz                         ;IF LAST ERROR SECTOR <> SECTOR IN RESULT VECT
                dcr     l
                rm                          ;IF NO ERROR WE DONT FIX IT
                mvi     h,BUFTAG/100H
                mov     a,m
                ori     80H                 ;SET "SECTOR VALID" TAG IN BUFFER
                mov     m,a
                ret

;
; SHED - Select Head
; Parameters:
;        P1 = byte:        Head Number, 0 base.
; Results:
;        NONE
; Description:
;        Select current unit read/write head.
SETHEAD:        lxi     h,SEEKHD
                jmp     GC1

;
; MODE - Set DMA or I/O mode
; Parameters:
;        P1 = byte: DBXXPPPP
;        Where bits PPPP is the IEEE-696 S-100 Bus DMA priority assignment.
;        Bit D is defined 1 for DMA usage, or 0 for polled I/O.
;        Bit B is defined 1 for BOOT/SYSWRT in progress.
;
; Description:
;        Changes READ and WRITE to indicated DMA mode.
SETMODE:
                lxi     h,MODE
                call    GC1
                ani     0FH                 ;PRIORITY BITS ONLY
                mov     b,a
                mov     a,m                 ;CURLCONT (FOLLOWS MODE BYTE IN RAM)
                ani     0F0H                ;PULL PREVIOUS PRIORITY BITS
                ora     b                   ;MERGE PRIORITY BITS FROM HOST
                mov     m,a                 ;UPDATE CURLCONT IN RAM
                out     LOCCONTIO
                ret

; HDTB - Set Hard Disk TABLES (DEV, OFFSET, OS BLOCK)
; Parameters:
;        P1 = byte: Logical unit.
;        P2 = byte: Physical select * 8 (0=00, 1=09h, 2=10h, 3=18h).
;        P3 = word: Track OFFSET to logical cylinder zero.
;        P4 = byte: Length of OS block (0=256 bytes, 1=1byte).
;        P5...                O/S block bytes
; Results:
;  NONE
; Description:
;  Set Hard Disk Tables (Device Select, Physical Offset, O/S Table).
HDTBLS:         call    GHADRS              ;GET BASE ADRS OF DESIRED UNIT
                lxi     d,PDTHDEV           ;BEGIN BY GETTING DEVICE CODE
                dad     d
                mvi     b,3
                call    GC                 ;SELECT CODE AND "HARDWARE OFFSET" TO DEV TABLE
;
;        ON RETURN <HL> = ADDRESS OF LENGTH OF HARD DISK OS BLOCK LENGTH
;
HDT3:           rst     GETHOST             ;GET LENGTH OF FOLLOWING "OS TABLE"
                mov     b,a                 ;** SETUP FOR GC,
                inr     b                   ;** (GET COUNT) LOOP
                jmp     GCA                 ;NOTE: BOTH COUNT AND OS TABLE GO TO DEV TABLE

; SIHDP - Set Individual Hard Disk Parameters
; Parameters:
;        P1 = byte: Unit
;        P2 = byte: #Heads.
;        P3 = byte: Pre-Comp cyl.
;        P4 = word: Step Rate.
; Results:
;  NONE
; Description:
;  Set Individual Hard Disk Parameters (#HEADS, PRE-COMP CYL AND STEP RATE)
SETIHDP:        call    GHADRS              ;GET BASE OF DEV TBL OF DESIRED UNIT
                lxi     d,PDTHHEADS
                dad     d                   ;FORM ADDRESS W/I DEVICE TABLE
                mvi     b,3                 ;GET #HEADS, PRE-COMP CYL AND STEP RATE
                jmp     GC

; GIHDP - Get Individual Hard Disk Parameters
; Parameters:
;        P1 = byte: Unit
; Results:
;        P1 = byte: #HEADS
;        P2 = byte: PRE-COMP CYL
;        P3 = byte: STEP RATE
;        P4 = byte: SELECT CODE
;        P5 = word: OFFSET
;        P7 = byte: LENGTH OF OS TABLE
;        P8 .....   OS TABLE
; Description:
;  Get Hard Disk Parameters (#HEADS, PRE-COMP CYL AND STEP RATE)
;
; GET INDIVIDUAL HD PARAMETERS
;
GETIHDP:        call    GHADRS              ;GET BASE OF DEV TBL OF DESIRED UNIT
                lxi     d,PDTHHEADS
                dad     d                   ;FORM ADDRESS W/I DEVICE TABLE
                mvi     c,PDTHOSLEN-PDTHHEADS+1 ;XFER # OF HEADS .. LEN BYTE
PIP1:           mov     a,m
                rst     PUTHOST
                inx     h
                dcr     c
                jnz     PIP1                ;IF NOT DOWN TO LENGTH BYTE
                mov     e,a                 ;LENGTH BYTE
                jmp     GETDPB2             ;GO SEND TO HOST OS TABLE

;
;        SUBROUTINE TO GET ADDRESS W/I HARD DISK DEVICE TABLE
;
;        ENTRY: HOST IS ABOUT TO SEND LOGICAL UNIT
;
GHADRS:         rst     GETHOST             ;GET LOGICAL UNIT OF FOLLOWING HARD DISK DATA
                call    MLP                 ;MAP LOGICAL TO PHYSICAL
                jc      GHA1                ;IF BAD LOGICAL DEVICE
                ani     NOT 3
                cpi     18H
                rz                          ;IF HARD DISK
GHA1:           lxi     h,0000              ;FOR "NOT HARD DISK" TRASH DATA "INTO" PROM
                ret

; UNIT - Select (logical or physical) Unit
; Parameters:
;        P1 = byte:  Logical drive unit: 00h-0Fh
;                                Physical drive unit: 10h-1Ch
; Results:
;  NONE
; Description:
;        Select current unit.
SETDRV:         lxi     h,SEEKDEV
                jmp     GC1

; TRAK - Select Track
; Parameters:
;        P1 = word: Track number, low-order byte, high-order byte.
; Results:
;  NONE
; Description:
;        Select track on current unit.
SETTRK:         lxi     h,SEEKTRK           ;LOW ORDER BITS OF TRACK (CYLINDER)
                jmp     CG2

; RECD - Select (logical) Record
; Parameters:
;        P1 = byte: Logical record number.
; Results:
;  NONE
; Description:
;        Select logical record on current track of current unit.
SETSEC:         lxi     h,SEEKSEC
                jmp     GC1

; DADR - Set DMA (TMA) transfer address
; Parameters:
;        P1 = word: DMA address for data transfer, low byte,high byte.
;        P2 = byte: Upper 8-bits of 24-bit address space.
; Results:
;  NONE
; Description:
;        Set data address for next read/write operation.
SETDMA:         lxi     h,SEEKDMALO
                jmp     CG3                 ;GET DMA ADRS BITS 7-0, BITS 15-8, BITS 23-16

; STRY - Set counters for (Floppy Disk) retry logic
; Parameters:
;        P1 = byte: Soft errors
;   P2 = byte: Hard errors, defaults to 3 retries.
; Results:
;  NONE
; Description:
;        Number of times to retry floppy disk access before reporting failure.
SETRETRY:       lxi     h,SEEKRETRY1        ;GET FIRST AND SECOND
                jmp     CG2                 ;R/W RETRY CONTROL BYTES

GC6:            inr     b
                inr     b
GC4:            inr     b
CG3:            inr     b
CG2:            inr     b
GC1:            inr     b
GC:             rst     GETHOST             ;GET PARAMETER FROM HOST
GCA:            mov     m,a
                inx     h
                dcr     b
                jnz     GC                  ;IF MORE PARAMETER BYTES LEFT
                ret

;
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   6.          THE ONE-BYTE NEC/HOST READ/WRITE ROUTINES
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

SENDNEC:        push    psw
                call    WAIT16
SENDNEC2:       in      NECSTATIO           ;MAIN NEC STATUS
                add     a
                jnc     SENDNEC2            ;IF NOT FREADY TO TRANSFER DATA
;               CM      ERROR               ;IF NEC WANTS TO SEND US DATA
                pop     psw
                out     NECDATIO
                ret

GETNEC1:        call    WAIT16
GETNEC2:        in      NECSTATIO           ;MAIN NEC STATUS
                add     a
                jnc     GETNEC2             ;IF NOT FREADY TO TRANSFER DATA
;               CP      ERROR               ;IF NEC WANTS TO SEND US DATA
                in      NECDATIO
                ret

GETCHAR:        in      SYSSTATIO
;               ANI     SYSINSTAT
;               JZ      GETCHAR
                rrc
                jnc     GETCHAR             ;IF NO DATA FROM HOST THEN WE WAIT
                in      SYSDATINIO          ;ACCEPT DATA FROM HOST
                ret

SENDCHAR:       push    psw
SENDCHAR1:      in      SYSSTATIO
                ani     SYSOUTSTAT
                jnz     SENDCHAR1
                pop     psw
HOSTOUT:        out     SYSDATOUTIO
                ret

;
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   7.          BOOT/SYSWRT ORGANIZER
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


; SYSWRT - Write System Tracks
; Parameters:
;        P1 = byte:NSEC
; NSEC defines the number of 128-byte blocks to write.
; A count of 1 transfers 128 bytes, a count of 0(zero) means
; 256 blocks or 32K bytes.
SYSWRT:         lxi     h,WRITE             ;** SET BOOTIO
                call    BOOT0               ;** TO WRITE
                lda     GENSTAT
                ora     a
                rz
                jmp     GETGENSTAT

; BOOT - Read System Tracks
; Parameters:
;        P1 = byte:NSEC
; NSEC defines the number of 128-byte blocks to read.
; A count of 1 transfers 128 bytes, a count of 0(zero) means
; 256 blocks or 32K bytes.
BOOT:           lxi     h,READ              ;** SET BOOTIO
BOOT0:          shld    BOOTSUB             ;** TO READ
                xra     a
                sta     GENSTAT             ;AT LEAST WE START W/ A CLEAN SLATE
                sta     PFIOFLAG            ;FORCE LOGICAL 128-BYTE SECTORS FOR BOOT/SYSWRT
                rst     GETHOST
                sta     BOOTLEN             ;LENGTH OF DATA TO READ (# OF 128-BYTE BLOCKS)
                call    FWT                 ;FORCE WRITE TAGS
                lxi     h,MODE
                mov     a,m
                ori     40H                 ;SET BOOT/SYSWRT FLAG IN MODE
                mov     m,a
                xra     a                   ;V13
                sta     CPS$SIDE            ;V13
                lxi     h,0
                shld    BOOTTRK             ;KK KEEP THE BOOT TRACK BECAUSE...
BOOT1:          shld    SEEKTRK             ;KK ...LOCDPB USES CYLINDER AND R/W USES TRACK
;               XRA     A                   ;V11
;               STA     CPS$SIDE            ;V11 "CHECK BOTH SIDES" FOR LOCDPB
                call    MAKECUR
                dw      BOOT5               ;IF NOT FLOPPY DISK
                call    LOCDPB              ;DO READID, LOCATE DPB, SETUP DEVICE TABLE
                mov     a,h
                ora     l
                rz                          ;IF ID UNREADABLE
                mov     b,m                 ;LOGICAL SECTORS / LOGICAL CYLINDER (FROM DPB)
                push    b                   ;SAVE FOR AFTER MAKECUR
;
                call    MAKECUR             ;SETUP LDT/PDT
                dw      ROM                 ;IF NOT FLOPPY DISK (BUT IT ALLWAYS IS HERE)
                lhld    BOOTTRK             ;KK USE THIS FOR R/W
                shld    SEEKTRK             ;KK
                lhld    CURPDTSKEW          ;<HL> = ADDRS OF START OF SKEW LIST
                lda     CURPDTNST
                mov     d,a                 ;<D> = NUMBER OF (PHYSICAL) SECTORS/TRACK
                mvi     e,1                 ;<E> = SKEW FACTOR
                call    BSKEW               ;SETUP FOR NO SKEW
                pop     b                   ;<B> = LOG SECTS/LOG TRACK FROM DPB
BOOT2:          xra     a
                sta     SEEKSEC             ;STARTING LOGICAL SECTOR
BOOT3:          push    b
                call    JMPBIO              ;CALL READ OR WRITE
                pop     b
                lxi     h,GENSTAT           ;SAVES 1 BYTE OVER "LDA GENSTAT" IF ERROR
                mov     a,m
                ora     a
                jz      BOOT4               ;IF NO ERROR READING OR WRITING BOOT SECTORS
;
;        ERROR READING OR WRITING BOOT SECTORS
;
                xri     40H                 ;IS ERROR ECC/CRC ON HARD DISK?
                rnz                         ;NO...THEN QUIT
                mov     m,a                 ;ZERO GENSTAT TO ALLOW READ/WRITE TO WORK
                lxi     h,HDCTYPE
                mov     a,m
                xri     80H                 ;CHANGE HARD DISK CONTROLLER TYPE
                mov     m,a
                push    b
                call    JMPBIO              ;RETRY READ OR WRITE
                pop     b
                lda     GENSTAT             ;CHECK ERROR CONDITION
                ora     a
                rnz                         ;IF STILL BAD
BOOT4:          lxi     h,BOOTLEN
                dcr     m                   ;REDUCE BLOCKS REMAINING TO READ/WRITE
                jz     FWT                  ;IF ALL DONE WITH BOOT READ/WRITE
                lxi     h,SEEKSEC
                inr     m                   ;BUMP LOGICAL SECTOR
                dcr     b                   ;LOGICAL SECTORS REMAINING ON TRACK
                jnz     BOOT3               ;IF MORE LOGICAL SECTORS TO TRANSFER
                call    FWT                 ;ELSE FORCE WRITE TAGS & DO NEXT CYLINDER
                lhld    BOOTTRK             ;KK INCRIMENT
                inx     h                   ;KK
                shld    BOOTTRK             ;KK
                xchg
                lhld    CURPDTADRS          ;KK SEE IF TWO SIDED
                inx     h ! inx     h       ;KK ADDRESS OF FLAG BYTE
                mov     a,m
                xchg
                ani     4                   ;KK DOUBLE SIDED BIT
                jz      BOOT4A              ;KK SINGLE SIDED
;               MOV     A,H                 ;V11 KK DIV 2 IF DOUBLE SIDED (FOR LOCDPB)
;               RAR                         ;V11
;               MOV     H,A                 ;V11
                mov     a,l                 ;V13
                ani     1                   ;V13
                sta     CPS$SIDE            ;V13
                mov     a,l
                rar
                mov     l,a
                mvi     h,0                 ;V13
BOOT4A:
;               LHLD    SEEKTRK
;               INX     H
                jmp     BOOT1               ;GO BACK FOR NEXT TRACK

BOOT5:          mvi     b,64                ;BOTH HARD AND MEMORY DISK HAVE
                jmp     BOOT2               ;64 128-BYTE SECTORS/TRACK
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   8.          FLOPPY DISK SEEK STUFF
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; SEEK - Force physical seek motion
; Parameters:
;        P1 = byte:        TRACK#
;        P2 = byte:        Logical Drive number
; Results:
;        NONE
; Description:
;        Force selected unit to perform head movement to selected track.
SEPSEEK:
;               call    WAITNBUSY
                rst     GETHOST             ;GET TRACK TO SEEK TO
                mov     b,a
                rst     GETHOST             ;GET LOGICAL DRIVE NUMBER...
                jmp     SEEK2               ;...AND ENTER SEEK STUFF
;
;        SEEK - SEEKS CURRENT DRIVE TO GIVEN TRACK
;
SEEK$CPS:                                   ;KK ADDED
                lda     CPS$TRKS            ;KK USE CPS$TRACK
                jmp     SEEK1
SEEK:           lda     SEEKTRK             ;DESTINATIONTRACK (KK CYLINDER)
SEEK1:          mov     b,a
                lda     CURPDT              ;LOGICAL DEVICE NUMBER -- DONT GET FROM SEEKDEV
SEEK2:          call    SMS                 ;START MOTION SEEK
;               ...                         ;FALL INTO WAITNBUSY

;
;        WAITNBUSY -- WAIT UNTIL NOT BUSY
;
;        IE WAIT UNTIL ALL SEEKS ARE DONE
;
WAITNBUSY:
                call    WAIT16              ;DEBUG ADD DELAY....IN LOOP???
                lhld    TRHLOAD             ;<L>=TIME TO HEADS FULLY LOADED
                                            ;<H>=EXTRA TIME DELAY AFTER SEEK DONE
WNB1:           in      NECSTATIO
                ani     0FH                 ;IS ANYBODY STILL BUSY?
                jz      WNB5                ;IF SEEK COMPLETE
                mov     a,l
                ora     a
                jz      WNB1                ;IF HEADS ALL READY LOADED - JUST WAIT FOR SEEK
WNB2:           dcr     l                   ;REDUCE TIME REMAINING FOR HEADS TOLOAD
WNB3:           mvi     a,250               ;TICK LENGTH IS 1MS
WNB4:           dcr     a                   ; 4<===T-STATES IN INSTRUCTION
                ora     a                   ; 4      (DELAY ALLOWS ONE BYTE COUNTER IN LOOP)
                jnz     WNB4                ;10      IF MORE DELAY TO MAKE 1MS TICK
                jmp     WNB1                ;---
                                            ;16 T-STATES / LOOP
;
WNB5:           shld    TRHLOAD             ;WILL STORE 0000 BEFORE WE EXIT THIS MESS
                mov     a,h
                ora     l
                rz                          ;IF BOTH DELAYS ARE MET
                xra     a
                cmp     h
                jz      WNB6                ;IF HEADS HAVE SETTLED AFTER SEEK
                dcr     h                   ;REDUCE TIME REMAINING FOR HEADS TO SETTLE
WNB6:           cmp     l
                jnz     WNB2                ;IF HEADS HAVE NOT YET LOADED
                jmp     WNB3                ;HEADS HAVE LOADED -- WAIT FOR SETTLE
;
;        Start Motion Seek
;
SMS:            call    MLP                 ;MAP LOGICAL DEVICE TO PHYSICAL
                rc                          ;IF INVALID LOGICAL ADDRESS
                push    h                   ;SAVE PDT ADRS
                mov     c,a                 ;PHYSICAL DEVICE CODE (10H - 17H)
                call    LOAD                ;LOAD HEADS (REQ'D TO SEEK -- XXYY STRAPPED)
                pop     h                   ;PDT ADRS
                inx     h ! inx     h       ;PDT FLAGS ADDRESS
                mov     a,b                 ;TARGET TRACK
                sta     RTRY$TRACK          ;KK SAVE FOR RWTRY
                ora     a
                jz      SMS$RECAL           ;IF SEEKING TO TRACK ZERO THEN DO UNCOND RECAL
;
                mov     a,m                 ;PDT FLAGS
                add     a
                jnc     SMS1                ;IF RECAL IS NOT REQUIRED
                push    h
                push    b
                call    SMS$RECAL           ;START RECAL
                call    WAITNBUSY           ;WAIT UNTIL RECAL IS DONE BEFORE GOING ON
                pop     b
                pop     h
SMS1:
                push    h                   ;KK SAVE
                lhld    CURFPYTAB           ;KK SEE IF DOUBLE STEP FLAGGED (48TPI IN 96TPI
                mov     a,m                 ;KK ..UNIT)
                ani     10H
                jz      SMS1A
                mov     a,b
                add     a                   ;KK *2 TRACK FOR DOUBLE STEP
                mov     b,a
SMS1A:
                pop     h                   ;KK
                inx     h                   ;ADDRESS OF TRACK NUMBER BYTE
                mov     a,b                 ;ONCE AGAIN, OUR TARGET TRACK
                cmp     m
                rz                          ;IF WE ARE ALLREADY ON THE DESIRED TRACK
                mov     m,a                 ;POST DESIRED TRACK NUMBER IN PDT
                mvi     a,SEEKCMD           ;SEEK COMMAND FOR NEC
                di
                rst     PUTNEC
                mov     a,c                 ;DEVICE CODE
                ani     03H                 ;MASK OFF ONLY DRIVE SELECT BITS
                rst     PUTNEC
                mov     a,b                 ;TRACK TO GO TO
SMS3:
                rst     PUTNEC
                ei
                lxi     h,FD$SETTLE
                lda     CURLCONT
                ani     20H
                jz      SMS4
                inx     h
SMS4:
                mov     a,m                 ;PICK UP HEAD SETTLE TIME
                sta     TRHSETL             ;"TIME REMAINING FOR HEAD SETTLE"
;               call    WAIT16              ;WE NEED TO GIVE "BUSY" TIME TO COME UP
;               ...                         ;FALL INTO WAIT16
;
WAIT16:
                xthl                        ;** XTHL TAKES 16 Y-STATES.
                xthl                        ;** AT 4MHZ THIS IS 4USEC
                xthl                        ;** EACH OR 16USEC FOR THE
                xthl                        ;** FOUR WE HAVE HERE
                xthl ! xthl ! xthl ! xthl   ;EXTRA DELAY IS DEBUG STUFF
                ret                         ;(CALL/RET ADD ANOTHER 6USEC)
;
;        RECALLABRATE OPERATION
;
SMS$RECAL:
                push    h
                call    SMS$RECAL1
SMS$RECAL0:
                in      NECSTATIO
                ani     0FH                 ;KK IS ANYBODY STILL BUSY?
                jnz     SMS$RECAL0          ;KK IF SEEK NOT COMPLETE
                pop     h
SMS$RECAL1:                                 ;KK SUBROUTINE SO IT CAN BE CALLED TWICE
                di
                mov     a,m                 ;PDT FLAGS
                ani     7FH                 ;RESET "RECAL REQUIRED" FLAG
                mov     m,a
                inx     h                   ;FORM ADDRESS OF TRACK NUMBER BYTE
                xra     a
                mov     m,a                 ;TRACK NUMBER (ZERO) ==> PDT
                mvi     a,RECAL             ;RECALLABRATE COMMAND FOR NEC
                rst     PUTNEC
                mov     a,c                 ;DEVICE CODE
                ani     03H                 ;MASK OFF ONLY DRIVE SELECT BITS
                call    SMS3                ;KK HEAD SETTLE AND WAIT STUFF
                ret
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   9.          FLOPPY DISK HEAD LOAD
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

LOAD:           lhld    WRITE$DELAY         ;** INIT TIMERS USED TO COUNT DOWN FOR
                shld    TIME$WRITE          ;** FORCE-WRITE AND HEAD-UNLOAD DELAYS
                lxi     h,CURLCONT
                mov     a,m
                ori     40H                 ;HEAD LOAD BIT
                cmp     m
                rz                          ;IF HEADS WERE ALLREADY LOADED
                mov     m,a
                out     LOCCONTIO
                ani     20H                 ;CHECK IF 5" OR 8"
                lxi     h,TRHLOAD           ;ADRS OF TIME REM FOR HEAD LOAD (1 MS TICKS)
                lxi     d,FD$LOAD$TIME
                ldax    d
                mov     m,a                 ;SET FOR 8"
                rz                          ;IF 8"
                inx d ! ldax d              ;ELSE...
                mov     m,a                 ;...SET FOR 5"
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   10.         FORMAT TRACK MAINLINE AND FLOPPY DISK FORMAT
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

; FMTF - Format Floppy Track
; Parameters:
;        P1 = byte: Format number - See FDREL table.
;        P2 = byte: Format control byte.
;                0010 0000 - Read list of available densities
;                0001 0000 - Check # of sides, Non-destructive
;                0001 0001 - Check # of sides, Destructive
;                0000 XXVF - Set F=1 for format
;                                        Set V=1 for verify
;                0000 00                Use 2-heads, normal
;                0000 01                Use head 0 only
;                0000 10                Use head 1 only
;                0000 11                Use head 0 only, normal.
; Description:
;        Format, Verify, or Read physical-format-types list.
FMTTRK:         xra     a
                sta     GENSTAT
                lda     SEEKSEC             ;KK SAVE IN CASE NEEDED (NEW TO VERS 1.1)
                sta     VFYSEC              ;KK
                lxi     h,FMT$NUM
                call    CG2                 ;GET FORMAT NUMBER AND FORMAT CONTROL
                call    MAKECUR             ;(CALLS FWT AS REQUIRED)
                dw      MD$FMT
                lxi     d,STD8              ;** SETUP FOR 8"
                mvi     b,NFMT8             ;** RELATION TABLE
                lda     CURLCONT
                ani     20H
                jz      FMT1                ;IF 8"
                lxi     d,STD5              ;** SETUP FOR 5.25"
                mvi     b,NFMT5             ;** RELATION TABLE
FMT1:           lxi     h,FMT$CNTL
                mov     a,m
                cpi     20H
                jnz     FMT3                ;IF NOT GETTING FORMAT TYPES
                xchg                        ;FIRST RELATION ADDRESS TO <HL>
FMT2:           lxi     d,103H              ;TRANSFER 3 BYTES TO HOST
                call    INBUFREAD3          ;SEND TO HOST
                lxi     d,LENFDREL-3
                dad     d                   ;<HL> POINTS TO THE TOP OF NEXT FDREL ENTRY
                dcr     b
                jnz     FMT2                ;IF NOT DONE SENDING ALL GROUPS
                ret

;...JUST THINKING
;
;               DB      OC$FMTV                        FORMAT AND VERIFY
; FMT$NUM       DB      FORMAT NUMBER
; FMT$CNTL      DB      0010 0000        READ LIST OF DENSITIES
;                       0001 0000        CHECK # SIDES READ ONLY
;                       0001 0001        CHECK # SIDES USING FORMAT
;                       0000 xxVF        F=1 FOR FORMAT, V=1 FOR VERIFY, VF=00 ILLEGAL
;                                         00 USE TWO HEADS, NORMAL
;                                         01 USE HEAD ZERO ONLY (IF HARD DISK INIT TRACK TO E5'S)
;                                         10 USE HEAD ONE ONLY
;                                         11 USE HEAD ZERO NORMAL + KILL HEAD 1 USING H=81H IN CHRN
;KK                     1XXX XXXX        USE SEEKSEC FOR FIRST SECTOR ON VERIFY ONLY

FMT3:
;        AT THIS POINT --
;
;        <A>                = FMT$CNTL
;        <B>                = 1 + MAX VALID NUMBER FOR FMT$NUM
;        <DE>        = ADDRESS OF FIRST FDREL SLOT OF SELECTED SIZE
;        <HL>        = ADDRESS OF FMT$CNTL
;
                xri     10H
                mov     c,a                 ;(USED IF WE GOTO FMT10)
                ani     NOT 01
                jz      FMT10               ;IF TO CHECK # SIDES
                xchg
                dcx     d
                ldax    d                   ;FMT$NUM
                mvi     e,11H               ;ERROR CODE FOR INVALID FORMAT NUMBER
                cmp     b
                jnc     LDPB$Xx             ;IF INVALID FORMAT NUMBER
                mov     c,a                 ;FOR USE AS LOOP COUNTER
                lxi     d,LENFDREL
                jmp     FMT5
FMT4:           dad     d                   ;FORM ADDRESS OF NEXT FDREL SLOT
FMT5:           dcr     c
                jp      FMT4                ;IF NOT DONE WITH FMT$NUM * LENFDREL
                shld    FMT$RELADRS         ;SAVE ADDRESS OF FDREL SLOT

                call    SETDENS             ;SETUP STUFF FOR VERIFY (NOTE: <A>=FMT NUMBER)
                xra     a
                sta     SEEKSEC             ;TO GET BETTER STUFF OUT OF CPS
                call    CPS                 ;MORE SETUP FOR VERIFY
                call    SEEK

                mvi     a,128               ;** MIN REV TIME=166 MS.  HERE WE ADD A 128 MS
                sta     TRHLOAD             ;** OF DELAY AFTER SEEK TO ASSURE HEAD SETTLE.
                call    WAITNBUSY           ;DO THE DELAY
                lda     SEEKTRK
                sta     BUFTRKS             ;SETUP FOR VERIFY
                lda     FMT$CNTL
                ani     0CH                 ;ISOLATE HEAD GAMES STUFF
                cpi     8                   ;START ON SECOND HEAD?
                mvi     a,0                 ;ASSUME START ON FIRST HEAD
                jnz     FMT7                ;IF OUR ASSUMPTION IS GOOD
FMT6:           inr     a                   ;ELSE...START ON SECOND HEAD
FMT7:           sta     BUFSIDE
                lda     FMT$CNTL
                ani     1
                cnz     FMTSUB              ;IF DOING FORMAT
                rc                          ;IF FORMAT ERROR

                lda     FMT$CNTL
                ani     2
                cnz     FMTVFY              ;IF DOING VERIFY
                rc                          ;IF VERIFY ERROR
                lda     CURPDTFLG
                ani     4
                rz                          ;IF NOT DOUBLE SIDED

                lda     BUFSIDE
                ora     a
                rnz                         ;IF FINISHED WITH SECOND SIDE

                lda     FMT$CNTL
                ani     0CH
                jz      FMT6                ;IF DOING BOTH SIDES NORMALLY
                cpi     0CH
                rnz                         ;IF NOT TO KILL BACK SIDE
                mvi     a,80H
                jmp     FMT6                ;GO KILL BACK SIDE

;********************************************************************
;
;        CHECK NUMBER OF SIDES
;
;        <C> = 0 THEN DO SIDE CHECK READ ONLY
;        <C> = 1 THEN CHECK WITH FORMAT OPERATION
;
;        RETURN TO HOST --
;
;        2: DISK IS DOUBLE SIDED
;        1: DISK IS SINGLE SIDED
;        0: DON'T KNOW (NOT READY OR OTHER ERROR)
;
;        METHOD:        IF NOT READY RETURN 0
;                        IF DRIVE SAYS SINGLE-SIDED THEN RETURN 1
;                        IF 8" RETURN 2 (REMEMBER, 8" KNOWS # SIDES)
;                        (NOW ONLY 5" LEFT)
;                        IF READ ONLY METHOD CALL LOCDPB
;                                THEN IF ERROR RETURN 0
;                                ELSE RETURN # SIDES FROM DEVICE TABLE
;                        (NOW 5" TO CHECK WITH FORMAT OPERATION)
;
;
FMT10:          mvi     a,DRIVESTAT         ;NEC "SENSE DRIVE STATUS" COMMAND
                rst     PUTNEC
                lda     CURPHYSDEV
                mov     b,a                 ;SAVE FOR DEVICE TYPE CHECK
                ani     3                   ;UNIT NUMBER (0-3)
                rst     PUTNEC
                rst     GETNEC              ;ST3 -- OUR USE: 20H=READY, 08H=2-SIDED
                ani     028H
                adi     0E0H                ;WILL CARRY IF READY
                jnc     FMT10$0             ;IF DRIVE SAYS "NOT-READY"
                jz      FMT10$1             ;IF DRIVE SAYS "SINGLE-SIDED"
                mov     a,b                 ;CURPHYSDEV
                ani     04H
                jz      FMT10$2             ;IF 8" (& NOT SINGLE-SIDED) THEN DOUBLE-SIDED
                dcr     c
                jz      FMT12               ;IF TO DO # SIDES CHECK WITH FORMAT OPERATION
FMT11:          xra     a                   ;KK START WITH SIDE 0
                sta     CPS$SIDE            ;KK
                call    LOCDPB              ;ELSE...DO SIDE CHECK READ-ONLY
                mov     a,l
                ora     h
                jz      FMT10$0             ;IF ERROR READING DISK
                lhld    CURPDTADRS
                inx     h ! inx     h       ;FORM ADRS OF FLAG BYTE
                mov     a,m
                ani     04H                 ;CHECK DOUBLE SIDED FROM DEVICE TABLE
                jz      FMT10$1             ;IF SINGLE SIDED
FMT10$2:        mvi     a,2                 ;ELSE...DOUBLE SIDED
FMT10$3:        rst     PUTHOST
;               RET                         ;V11
                ral                         ;V13
                ani     04H                 ;V13
                mov     c,a                 ;V13
                lhld    CURPDTADRS          ;V13
                inx     h                   ;V13
                inx     h                   ;V13
                mov     a,m                 ;V13
                ani     0FBH                ;V13
                ora     c                   ;V13
                mov     m,a                 ;V13
                ret                         ;V13

;        CHECK NUMBER OF SIDES WITH FORMAT OPERATION
;
;        GENERAL METHOD:
;
;        1.        USE "STD5" FORMAT
;        2.        FORMAT USING SECOND HEAD FIRST
;                IF ERROR RETURN 1
;        3.        FORAT USING FIRST HEAD SECOND
;        4.        DO READ-ONLY STYLE NUMBER-OF-SIDES CHECK
;
FMT12:
                call    SEEK
                mvi     a,128               ;** MIN REV TIME=166 MS.  HERE WE ADD A 128 MS
                sta     TRHLOAD             ;** OF DELAY AFTER SEEK TO ASSURE HEAD SETTLE.
                call    WAITNBUSY           ;DO THE DELAY
                lxi     h,STD5
                shld    FMT$RELADRS
                mvi     a,1
                sta     BUFSIDE
                call    FMTSUB              ;FORMAT BACK SIDE
                jc      FMT10$1             ;IF ERROR ASSUME ONLY ONE SIDE
                lxi     h,BUFSIDE
                dcr     m                   ;SET FOR FRONT SIDE
                call    FMTSUB
                jmp     FMT11               ;GO BACK AND DO READID STUFF, DENSITY CHECK

FMT10$0:        xra     a
;               RST     PUTHOST             ;V11
;               RET                         ;V11
                jmp     FMT10$3             ;V13

FMT10$1:        mvi     a,1
;               RST     PUTHOST             ;V11
;               RET                         ;V11
                jmp     FMT10$3             ;V13

;********************************************************************
;
;        FMTSUB -- PERFORM PHYSICAL FORMAT
;
;        ENTRY:        FMT$RELADRS        = ADDRESS OF FD RELATION ENTRY
;                        BUFSIDE          = HEAD NUMBER (0 OR 1)
;
FMTSUB:
                lxi     h,FMTSUB2
                shld    NECINTADRS          ;POST INT ADRS FOR WHEN FORMAT TRACK IS DONE
                mvi     a,0C0H              ;** USED IF ERROR TO INDICATE TO HOST
                sta     OPTYPE              ;** THAT ERROR WAS DURING FORMAT OP
                lhld    FMT$RELADRS         ;ADDRESS OF FDREL SLOT
                mov     a,m                 ;POINT TO FIRST ENTRY IN TABLE
                ani     040H                ;MASK OFF SIZE DATA
                ori     FORMAT              ;= NEC FORMAT COMMAND (THE 40H SETS FM/MFM)
                di
                rst     PUTNEC
                lda     BUFSIDE             ;<A> = HEAD NUMBER (0 OR 1)
                mov     c,a                 ;SAVE FOR LATER USE AS "H" OF "CHRN"
                add     a ! add     a
                mov     b,a
                lda     CURPHYSDEV
                ani     3                   ;STRIP OFF DEVICE TYPE (LEAVE ONLY UNIT NUMBER)
                ora     b
                rst     PUTNEC              ;SEND (UNIT, HEAD) INFO
                inx     h
                mov     a,m                 ;GET N -- BYTES/SECTOR = (N+7)**2
                mov     e,a                 ;SAVE FOR LATER USE AS "N" OF "CHRN"
                rst     PUTNEC              ;SEND SECTOR SIZE
                inx     h
                mov     a,m                 ;GET "SC" IE NUMBER OF SECTORS
                mov     d,a                 ;STORE FOR LATER
                rst     PUTNEC              ;SEND NUMBER OF SECTORS
                lda     SEEKTRK
                mov     b,a
                inx     h                   ;(SKIP OVER GAP LENGTH USED FOR NON-FORMAT R/W)
                inx     h
                mov     a,m                 ;GET GPL ASSOSIATED WITH FORMATTING
                rst     PUTNEC              ;SEND FORMAT GAP LENGTH

;KK             MVI     H,1                 ;RECORD NUMBER FOR NEXT (FIRST) ID TO FORMAT
                mvi     a,1                 ;KK DO THIS INSTEAD TO ADD RECORD BIAS
                mov     h,c                 ;KK SIDE NO. FOR SECBIAS
                call    SECBIAS             ;KK
                push    psw                 ;KK TEMP SAVE
                mov     a,c                 ;KK ADD SIDE BIAS FOR SIDE I/D.
                call    SIDEBIAS
                mov     c,a                 ;KK SAVE
                pop     psw                 ;KK RESTORE SECTOR WITH BIAS APPLIED
                mov     h,a                 ;KK USE FOR STARTING SECTOR I.D.
                mvi     a,0E5H              ;FILL BYTE...(INITIATE EXECUTION MODE)...
                rst     PUTNEC              ;...IS LAST BYTE OF COMMAND STRING
;
                ei
                lda     CURLCONT
                ani     7FH
                out     LOCCONTIO           ;ENABLE WAIT GENERATION
                out     LOCDMAHIIO          ;SET INTO WAIT

FMTSUB1:        mov     a,b                 ;CYL
                out     NECDATIO
                mov     a,c                 ;HEAD
                out     NECDATIO
                mov     a,h                 ;RECORD NUMBER
                inr     h
                out     NECDATIO
                mov     a,e                 ;BYTES/SECTOR CODE CALLED "N"
                out     NECDATIO
                dcr     d                   ;SECTORS REMAINING
                jnz     FMTSUB1             ;IF ANOTHER SECTOR TO FORMAT
                hlt                         ;WAIT FOR NEC INTERRUPT

;********************************************************************
;
;        FMTVFY - VERIFY READ AFTER FORMAT
;
;        ENTRY:        FMT$RELADRS        = ADDRESS OF FD RELATION ENTRY
;                        FMT$NUM          = FORMAT NUMBER AS GIVEN BY HOST
;                        BUFSIDE          = HEAD NUMBER (0 OR 1)
;
FMTVFY:
                lhld    FMT$RELADRS         ;ADDRESS OF FDREL SLOT
                lda     FMT$NUM             ;FORMAT NUMBER
                call    SETDENS             ;SETUP STUFF FOR VERIFY
                call    CPS                 ;MORE SETUP FOR VERIFY

                lda     SEEKTRK
                sta     BUFTRKS             ;SETUP FOR VERIFY

                mvi     b,1                 ;FOR VERIFY: FIRST SECTOR TO READ
                lda     FMT$CNTL            ;KK SEE IF WE USE SEEKSEC FOR FIRST SECTOR
                ani     80H                 ;KK (IT WAS SAVED INTO VFYSEC ABOVE)
                jz      FMTVFY1
                lda     VFYSEC              ;KK USE SEEKSEC FOR FIRST SECTOR
                mov     b,a
FMTVFY1:
                lda     CURPDTNST
                mov     c,a                 ;FOR VERIFY: LAST SECTOR TO READ
                call    PREAD               ;PHYSICAL READ

FMTSUB2:        lda     GENSTAT
                adi     0FFH
                ret                         ;RETURN WITH CARRY SET IF ERROR

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   11.         CALCULATE PHYSICAL SECTOR FOR FLOPPY DISK
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

CPS:
                lda     SEEKTRK
                mov     b,a                 ;KK TEMP SAVE
                lxi     h,CPS$SIDE
                mvi     m,0                 ;KK SIDE 0 DEFAULT
                lda     CURPDTFLG           ;KK GET NUMBER OF SIDES
                ani     04H                 ;KK DOUBLE SIDED BIT
                jz      CPSK1               ;KK SINGLE SIDED
                mov     a,b                 ;KK TRACK:= TRACK DIV 2
                ora     a                   ;KK CY:= 0
                rar
                mov     b,a
                mvi     a,0                 ;KK SIDE:= TRACK MOD 2, PICK UP CARRY
                ral
                mov     m,a                 ;KK SAVE SIDE IN CPS$SIDE
CPSK1:
                lda     CURPDTNBC           ;KK GET NUMBER OF CYLINDERS TO CHECK OVERFLOW
                dcr     a                   ;KK TRACK IS [0..NBC-1]
                cmp     b                   ;KK COMPARE WITH TRACK
                jnc     CPSK1A
                inr     a                   ;KK ADJUST BACK TO NBC
                mov     c,a
                mov     a,b
                sub     c                   ;KK OVERFLOW, SUBTRACT CURPDTNBC
                mov     b,a
                inr     m                   ;KK SELECT SIDE 1
CPSK1A:
                mov     a,b
                sta     CPS$TRKS
                mvi     h,0                 ;KK
;KK             MOV     H,A                 ;(ZERO FOR USE LATER)
                lda     CURPDTNST           ;NUMBER OF PHYSICAL SECTORS PER TRACK
                mov     b,a
                lda     SEEKSEC             ;NOTE: STARTS AT ZERO
                mov     l,a                 ;<HL>=SEEKSEC
                mov     d,h                 ;(ZERO)
                lda     PFIOFLAG
                ora     a                   ;READY FOR TEST FOR PHYSICAL FORMAT I/O
                lda     CURPDTPSS           ;PHYS SECTOR SIZE (0=128, 1=256, ETC)
                jnz     CPS$PF              ;IF PHYSICAL FORMAT MODE
                ora     a
                jz      CPSS0               ;IF SECTOR SIZE IS 0 (128)
                sui     2
                jm      CPSS1               ;IF SECTOR SIZE IS 1 (256)
                jz      CPSS2               ;IF SECTOR SIZE IS 2 (512)
                                            ;ELSE...SECTOR SIZE IS 3 (1024)

CPSS3:                                      ;3: 8*128
                dad h ! dad h ! dad h ! dad h ! dad h
                mov     a,h
                mov     h,d                 ;(ZERO)
                dad h ! dad h ! dad h
                lxi     d,1024              ;SECTOR SIZE
                jmp     CPS2
;
CPSS2:                                      ;2: 4*128
                dad h ! dad h ! dad h ! dad h ! dad h ! dad h
                mov     a,h
                mov     h,d                 ;(ZERO)
                dad h ! dad h
                lxi     d,512               ;SECTOR SIZE
                jmp     CPS2
;
CPSS1:                 ;1: 2*128
                dad h ! dad h ! dad h ! dad h ! dad h ! dad h ! dad h
                mov     a,h
                mov     h,d                 ;(ZERO)
                dad     h
                lxi     d,256               ;SECTOR SIZE
                jmp     CPS2

CPS$PF:         mvi     l,40H               ;<HL>=0040H
                mov     d,h                 ;(ZERO) FOR FUTURE <H>=0
CPSPF1:         dad     h
                dcr     a
                jp      CPSPF1
                xchg                        ;<DE>=PHYSICAL SECTOR LENGTH
                lda     SEEKSEC
                jmp     CPS2

CPSS0:                 ;0: 1*128
                mov     a,l
                mov     h,d                 ;(ZERO)
                lxi     d,128               ;SECTOR SIZE
;               ...                         ;FALL INTO CPS2

;        AT THIS POINT:
;
;        <A> = PHYSICAL SECTORS FROM START OF TRACK (B4 INTERLEAVE)
;        <B> = NUMBER OF PHYSICAL SECTORS PER TRACK
;        <DE>= PHYSICAL SECTOR SIZE
;        <H> = # OF 128-BYTE OFFSETS FROM PHYS SECTOR START
;
CPS2:
                push    d                   ;PHYS SECTOR SIZE
                mov     c,h                 ;128-BYTE OFFSETS FROM START OF PHYS SECTOR
;KK             CMP     B
;KK             JC      CPS3                ;IF NOT ON SECOND SIDE
;KK             SUB     B                   ;SECOND SIDE...
;KK             LXI     H,CPS$SIDE
;KK             INR     M                   ;BUMP TO SECOND SIDE

;KK CPS3:
                mvi     d,0                 ;<DE> = PHYS SECTOR BEFORE INTERLEAVE
                mov     e,a
                lhld    CURPDTSKEW
                dad     d                   ;<HL> = ADDRESS WITHIN SKEW LIST
                mov     a,m
                sta     CPS$SECTOR          ;DESIRED PHYSICAL SECTOR - SKEW IS DONE!

;        NOW FORM ADDREESS WITHIN BUFFER THAT CONTAINS
;        (OR WILL CONTAIN) OUR DESIRED LOGICAL SECTOR

                pop     h                   ;NUMBER OF BYTES IN SECTOR
                shld    CPS$PSECT           ;LEAVE AROUND FOR THE USE OF OTHERS
                xchg
                lxi     h,BUFFER
                dcr     a
                jz      CPS5                ;IF WE DESIRE THE FIRST PHYSICAL SECTOR
CPS4:           dad     d                   ;STEP BY PHYSICAL SECTOR SIZE
                dcr     a
                jnz     CPS4                ;KEEP AT IT UNTIL WE COUNT ALL SECTORS
                                            ;<HL>  = START OF SECTOR ADDRESS (? SAVE IT ?)
CPS5:           mov     a,c                 ;NUMBER OF 128-BYTE OFFSETS FROM <HL>
                rar
                mov     d,a
                mvi     a,0                 ;WE WANT THAT CARRY BIT
                rar
                mov     e,a                 ;<DE> = <C> * 128
                dad     d
                shld    CPS$BUFADR
                ret                         ;DONE (AT LAST)

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   12.         FLOPPY DISK READ/WRITE
;               READ MAINLINE
;               WRITE MAINLINE
;               PHYS READ/WRITE AND COMMON SUBROUTINE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

PFREAD:
                mvi     a,0FFH              ;SET PHYSICAL FORMAT FLAG
                jmp     READ1

READ:
                xra     a                   ;RESET PHYSICAL FORMAT FLAG
READ1:
                sta     PFIOFLAG
                lda     GENSTAT
                ora     a
                rnz                         ;IF PENDING ERROR CODE WE ABORT
                call    SRC                 ;SET RETRY COUNTERS
                lda     UNLOAD$DELAY        ;** SET TIMER TO KEEP HEADS
                sta     TIME$HLOAD          ;** LOADED IF ALLREADY LOADED
                call    MAKECUR             ;ASSURE SEEKDEV THE CURRENT DEVICE
                dw      MD$READ             ;IF NOT FLOPPY DISK
                call    CPS                 ;CALCULATE PHYSICAL SECTOR
;
;        CHECK IF REQUESTED TRACK IS IN BUFFER
;
READ2:
                lhld    CPS$TRKS            ;REQUESTED TRACK/SIDE FROM CPS
                xchg
                lhld    BUFTRKS             ;TRACK/SIDE IN BUFFER
                mov     a,h
                xra     d
                mov     c,a
                mov     a,l
                xra     e
                ora     c
                jz     READ3                ;IF TRACK IS IN BUFFER
                call    FWT                 ;ELSE...FORCE WRITE TAGS
                call    VBT                 ;VOID BUFFER TAGS
                call    SEEK$CPS
                lhld    CPS$TRKS            ;** MAKE REQUESTED TRACK AND SIDE
                shld    BUFTRKS             ;** THE CURRENT TRACK AND SIDE
                lda     CURPDTNST           ;NUMBER OF SECTORS
                mov     c,a
                mvi     b,1                 ;(<B>, <C>) = (FIRST, LAST) SECTOR TO READ
                jmp     READ6               ;GO READ FULL TRACK
;
READ3:
                call    BUFCHK              ;CHECK IF REQUESTED SECTOR IS IN BUFFER
                jc      INBUFREAD           ;IF IT IS IN THE BUFFER GO TRANSFER TO HOST
;
;        REQUESTED TRACK IS "IN BUFFER" BUT SECTOR IS NOT "IN BUFFER"
;
                call    SEEK$CPS            ;ASSURE THAT WE ARE ON THE RIGHT TRACK
                lda     CPS$SECTOR
                mov     b,a                 ;READ WILL START WITH THIS SECTOR
                mvi     h,BUFTAG/100H
                mov     l,a
                dcr     l                   ;<HL> POINTS TO BUFTAG BYTE FOR CPS$SECT
                lda     CURPDTNST           ;NUMBER OF PHYSICAL SECTORS ON TRACK
                mov     c,a
READ4:          mov     a,m                 ;FETCH BUFFER TAG
                add     a                   ;CHECK IF IN BUFFER
                jc      READ5               ;IF SECTOR IS IN BUFFER WE DONT RE-READ
                inr     l
                mov     a,c                 ;MAX SECTOR ON TRACK...
                cmp     l                   ;...VSS # OF SECTOR WHOSE TAG WE JUST CHECKED
                jnz     READ4               ;IF MORE TAS CONTINUE LOOP
READ5:          mov     c,l
;
;        AT THIS POINT (<B>, <C> = (FIRST, LAST) SECTOR TO READ
;
READ6:
                call    PREAD
                lda     PIOERSECT           ;PHYSICAL I/O ERROR SECTOR (=0 IF NO ERROR)
                mov     l,a
                lda     CPS$SECTOR          ;ONLY SECTOR WE NEED RIGHT NOW
                xra     l                   ;WAS ERROR (IF ANY) ON OUR SECTOR?
                jnz     READ2               ;NO...GET SECTOR FROM BUF - OR ISSUE SHORT READ
;
;        NEEDED SECTOR HAD ERROR -- TRY TO RECOVER
;
                call    RWRETRY             ;R/W RECOVERY
                dw      READ2               ;RETRY ADDRESS
                ret                         ;EXIT IF UNRECOVERED ERROR

;
;******** FRONT END TO WRITE ********
;
PFWRITE:
                mvi     a,0FFH              ;SET PHYSICAL FORMAT MODE
                jmp     XWRITE1
;
XWRITE:
                xra     a                   ;RESET PHYSICAL FORMAT CODE
XWRITE1:        sta     PFIOFLAG            ;PHYSICAL FORMAT I/O FLAG
                rst     GETHOST             ;GET TYPE OF WRITE
                sta     RWTYPE              ;0=NORMAL     (* BOTH OF THESE MUST BE      *)
                                            ;1=DIRECTORY  (* HANDLED AS UPDATE-IN-PLACE *)
                                            ;2=SEQUENTIAL (DONT WORRY ABOUT PARTIAL SECTOR)
                call    WRITE        
                lda     GENSTAT
                ora     a
                rz                          ;IF WRITE COMPLEATED W/O ERROR
                jmp     GETGENSTAT
;
;        WRITE - WRITE DATA TO DISK
;
;        FOR NOW, THIS CODE LOOKS STRANGELY LIKE THE CODE FROM READ.
;        LATER WE WILL MAKE IT SOMEWHAT SMARTER
;
;        STARTING TO CHANGE -- ADDED RWTYPE=2 STUFF
;

WRITE:
                lda     GENSTAT
                ora     a
                rnz                         ;IF OUTSTANDING ERROR CODE WE EXIT W/O TRYING
                call    SRC                 ;SET RETRY COUNTERS
                lda     WRITE$DELAY         ;** SET TIMER TO ASSURE
                sta     TIME$WRITE          ;** TIMELY ENTRY TO PRW
                call    MAKECUR             ;ASSURE SEEKDEV THE CURRENT DEVICE
                dw      MD$WRITE            ;IF NOT FLOPPY DISK
                call    CPS                 ;CALCULATE PHYSICAL SECTOR
;
;        CHECK IF REQUESTED TRACK IS IN BUFFER
;
WRITE2:
                lhld    CPS$TRKS            ;REQUESTED TRACK/SIDE CROM CPS
                xchg
                lhld    BUFTRKS             ;TRACK/SIDE IN BUFFER
                mov     a,h
                xra     d
                mov     c,a
                mov     a,l
                xra     e
                ora     c
                jz      WRITE3              ;IF TRACK IS IN BUFFER
                call    FWT                 ;ELSE...FORCE WRITE TAGS
                call    VBT                 ;VOID BUFFER TAGS
                call    SEEK$CPS
                lhld    CPS$TRKS            ;** MAKE REQUESTED TRACK AND SIDE
                shld    BUFTRKS             ;** THE CURRENT TRACK AND SIDE
                lda     RWTYPE
                cpi     2
                jz      SEQWRITE            ;IF SEQUENTIAL WRITE, PREREAD IS NOT NESSESSARY
                lda     CURPDTNST           ;NUMBER OF SECTORS
                mov     c,a
                mvi     b,1                 ;(<B>, <C>) = (FIRST, LAST) SECTOR TO READ
                jmp     WRITE6              ;GO READ FULL TRACK
;
WRITE3:
                call    BUFCHK              ;CHECK IF REQUESTED SECTOR IS IN BUFFER
                jc      INBUFWRITE          ;IF IT IS IN THE BUFFER GO GET FROM HOST
                lda     RWTYPE
                cpi     2
                jz      SEQWRITE            ;IF SEQUENTIAL WRITE, PREREAD IS NOT NESSESSARY
;
;        REQUESTED TRACK IS "IN BUFFER" BUT SECTOR IS NOT "IN BUFFER"
;
                call    SEEK$CPS            ;ASSURE THAT WE ARE ON THE RIGHT TRACK
                lda     CPS$SECTOR
                mov     b,a                 ;READ WILL START WITH THIS SECTOR
                mvi     h,BUFTAG/100H
                mov     l,a
                dcr     l                   ;<HL> POINTS TO BUFTAB BYTE FOR CPS$SECT
                lda     CURPDTNST           ;NUMBER OF PHYSICAL SECTORS ON TRACK
                mov     c,a
WRITE4:         mov     a,m                 ;FETCH BUFFER TAG
                add     a                   ;CHECK IF IN BUFFER (READTAG=80H)
                jc      WRITE5              ;IF SECTOR IS IN BUFFER WE DONT RE-READ
                inr     l
                mov     a,c                 ;MAX SECTOR ON TRACK...
                cmp     l                   ;...VSS # OF SECTOR WHOSE TAG WE JUST CHECKED
                jnz     WRITE4              ;IF MORE TAGS CONTINUE LOOP
WRITE5:         mov     c,l
;
;        AT THIS POINT (<A>, <C>) = (FIRST, LAST) SECTOR TO READ???
;
WRITE6:
                call    PREAD
                lda     PIOERSECT           ;PHYSICAL I/O ERROR SECTOR (=0 IF NO ERROR)
                mov     l,a
                lda     CPS$SECTOR          ;ONLY SECTOR WE NEED RIGHT NOW
                xra     l                   ;WAS ERROR (IF ANY) ON OUR SECTOR?
                jnz     WRITE2              ;NO...GET SECTOR FROM BUF - OR ISSUE SHORT READ
;
;        NEEDED SECTOR HAD ERROR -- TRY TO RECOVER
;
                call    RWRETRY             ;R/W RECOVERY
                dw      WRITE2              ;RETRY ADDRESS
                ret                         ;EXIT IF UNRECOVERED ERROR

;********************************************************************
;
;        PREAD - PHYSICAL READ
;
;        ENTRY:        <B> FIRST SECTOR TO READ
;                      <C> LAST SECTOR TO READ
;
;        EXIT:        SECTORS THAT HAVE BEEN READ ARE MARKED VALID IN BUFTAG
;
PREAD:
                lhld    BUFTRKS
                call    PRW                 ;PHYSICAL READ/WRITE
                db      READDATA            ;NEC READ OPCODE
                db      80H                 ;USED IF ERROR TO INDICATE ERROR ON READ
                jz      PREAD0              ;KK DO PROGRAM I/O FOR MINI
;
;               DCX     D                   ;KK WE READ OUR FIRST BYTE BEFORE READ LOOP
                lxi     b,0                 ;KK TIMER
PRL1:                                       ;KK  T-STATES
                dcx     b                   ;KK  5
                mov     a,b                 ;KK  5
                ora     c                   ;KK  4
                jz      RDY$ERR             ;KK 10
;               IN      NECSTATIO           ;KK 10
                rim                         ;KK ===> BOARD PATCH: 8085 SID/NEC DRQ
                add     a                   ;KK  4
                jnc     PRL1                ;KK 10 NO DMA REQUEST, LOOP
                                            ;-----
                                            ;   48 TOTAL T-STATES, 12 MICRO SEC
;               IN      NECDATIO            ;KK OUR FIRST BYTE, GET IT QUICK
;               MOV     M,A                 ;KK (THIS DIDN'T WORK, NO DMACK*)
;               INX     H

;
;        PHYS READ LOOP (MOSTLY) FROM BRENT
;
PREAD0:
                lda     CURLCONT            ;  13 INITIAL VALUE
                ani     07FH                ;   7 SET MSB TO ZERO
                out     LOCCONTIO           ;  10 ENABLE WAIT GENERATION
                out     LOCDMAHIIO          ;  10 SET 8085 INTO WAIT
                lxi     b,NECDAT            ;  10 DATA ADDRESS FOR NEC DATA
                                            ;----
                                            ;  50 TOTAL T-STATES, 12.5 MICRO SEC

PREAD1:         ldax    b                   ;WAIT FOR AND THEN GET DATA BYTE
                mov     m,a                 ;SAVE
                inx     h
                dcx     d                   ;BYTE COUNTER
                mov     a,d
                ora     e
                jnz     PREAD1              ;IF NOT DONE
;
;        NEXT-TO-LAST BYTE HAS BEEN READ FROM LAST SECTOR
;
                out     LOCDMALOIO          ;SET TC TO NEC765

                ldax    b                   ;GET THE LAST BYTE OF THE LAST SECTOR
                mov     m,a                 ;SAVE BYTE
                inx     h                   ;FOR INT PROCESS TO SHOW HOW FAR WE GOT
                jmp     PWRITE2             ;TURN OFF READY SYNC AND WAIT FOR INTERRUPT

;********************************************************************
;
;        PREAD - PHYSICAL READ
;
;        ENTRY:        <B> FIRST SECTOR TO READ
;                      <C> LAST SECTOR TO READ
;
;        EXIT:        SECTORS THAT HAVE BEEN READ ARE MARKED VALID IN BUFTAG
;
;
PWRITE:
                lhld    BUFTRKS
                call    PRW                 ;PHYSICAL READ/WRITE
                db      WRITEDATA           ;NEC WRITE OPCODE
                db      40H                 ;USED IF ERROR TO INDICATE ERROR ON WRITE
                jz      PWRITE0             ;KK DO PROGRAM I/O FOR MINI
;
                lxi     b,0                 ;KK TIMER
PWL1:                 ;KK   T-STATES
                dcx     b                   ;KK  5
                mov     a,b                 ;KK  5
                ora     c                   ;KK  4
                jz      RDY$ERR             ;KK 10
;               IN      NECSTATIO           ;KK 10
                rim                         ;KK ===> BOARD PATCH: 8085 SID/NEC DRQ
                add     a                   ;KK  4
                jnc     PWL1                ;KK 10
                                            ;-----
                                            ;   48 TOTAL T-STATES, 12 MICRO SEC
;
;        PHYS WRITE LOOP (MOSTLY) FROM BRENT
;
PWRITE0:
                lda     CURLCONT            ;INITIAL VALUE
                IF      DEBUGGING
                CALL    DEBUG
                ENDIF
                ani     07FH                ;SET MSB TO ZERO
                out     LOCCONTIO           ;ENABLE WAIT GENERATION
                out     LOCDMAHIIO          ;SETS 8085 INTO WAIT
                lxi     b,NECDAT            ;DATA ADDRESS FOR NEC DATA
                mov     a,m                 ;FIRST BYTE TO WRITE
PWRITE1:        stax    b                   ;DATA BYTE ==> NEC
                inx     h
                dcx     d                   ;BYTE COUNTER
                mov     a,d
                ora     e
                mov     a,m                 ;NEXT BYTE TO WRITE
                jnz     PWRITE1             ;IF NOT ON LAST BYTE
;                                            NEXT-TO-LAST BYTE HAS BEEN WRITTEN TO LAST SECTOR
;
PWRITE2:        out     LOCDMALOIO          ;SET TC TO NEC765
                out     NECDATIO            ;SEND THE LAST BYTE OF THE LAST SECTOR

PWRITE3:        lda     CURLCONT
                out     LOCCONTIO           ;TURN OFF READY SYNC (IE SET MSB ON)
                hlt                         ;WAIT FOR INTERRUPT

;********************************************************************
;
;        PRW - PHYSICAL READ/WRITE (MOST CODE IS COMMON TO BOTH READ & WRITE)
;
;        ENTRY:        <B> FIRST SECTOR TO R/W
;                      <C> LAST SECTOR TO R/W
;                      <H> HEAD NUMBER (0 OR 1)
;                      CALL    PRW
;                      DB      READ OR WRITE OPCODE
;
;
PRW:
                IF      DEBUGGING
                CALL    DEBUG
                ENDIF
                shld    PRWA                ;SAVE TRACK AND HEAD NUMBERS
                call    LOAD                ;LOAD HEAD(S) AND RESET HEAD LOAD TIMER
                call    WAITNBUSY           ;ASSURE THAT HEADS ARE LOADED
                lxi     h,2
                dad     sp
                shld    SPSAVE              ;SP TO RESTORE AFTER NEC INTERRUPT

                xthl                        ;<HL> POINT TO DB FOLLOWING CALL
                lda     CURPDTFLG
                ani     40H                 ;MFM BIT ONLY
                ora     m                   ;NEC COMMAND
                inx     h
                di
                rst     PUTNEC              ;OUTPUT TO NEC
                mov     a,m                 ;$ PICK UP AND SAVE CODE USED TO INDICATE
                sta     OPTYPE              ;$ WHAT WE WERE DOING IF WE GET AN ERROR
                inx     h                   ;** RESTORE RETURN
                xthl                        ;** ADDRESS TO STACK
;
;        POST THE ADDRESS WE WANT TO GOTO WHEN THE READ/WRITE IS DONE
;
                lxi     h,PRW10
                shld    NECINTADRS
;
;        FIND ADDRESS OF WHERE TO START DATA TRANSFER
;
                lhld    CPS$PSECT           ;NUMBER OF BYTES IN SECTOR (FROM CPS)
                xchg                        ;<DE> = NUMBER OF BYTES IN PHYSICAL SECTOR
                lxi     h,BUFFER
                mov     a,b                 ;SECTOR NUMBER TO FIND IN BUFFER
                dcr     a
                jz      PRW2                ;IF FIRST PHYSICAL SECTOR IS WANTED
PRW1:           dad     d                   ;ADD LENGTH OF SECTOR TO (ACCUMLATED) BASE
                dcr     a
                jnz     PRW1                ;CONTINE LOOP UNTIL WE FIND R/W START ADDRESS
                                            ;<HL> = MAIN BUFFER ADDRESS OF PHYS SECT IN <B>
                                            ;<DE> = NUMBER OF BYTES IN EACH SECTOR
PRW2:           push    h                   ;ADDRESS OF WHERE TO PUT FIRST SECTOR
;
;        FIND LENGTH OF DATA TRANSFER
;
                lxi     h,-1
                mov     a,c                 ;LAST SECTOR TO READ
                sub     b                   ;LESS FIRST SECTOR TO READ (= NUMBER OF SECT-1)
PRW3:           dad     d                   ;ADD NUMBER OF BYTES IN SECTOR
                dcr     a
                jp      PRW3                ;FORM TOTAL DESIRED DATA LENGTH
                push    h                   ;LEN TO READ LESS 1 BYTE
;
;        SEND REST OF COMMAND STUFF TO NEC
;
                lhld    PRWA                ;<H>=HEAD NUMBER, <L>=TRACK
                mov     a,h                 ;HEAD NUMBER (0 OR 1)
                add     a
                add     a                   ;HEAD FLAG TO BE OR'D WITH DEVICE NUMBER
                mov     e,a
                lda     CURPHYSDEV
                IF      DEBUGGING
                CALL    DEBUG
                ENDIF
                ani     3                   ;** DEVICE NUMBER
                ora     e                   ;** PLUS SIDE
                rst     PUTNEC              ;** TO NEC
                mov     a,l
                rst     PUTNEC              ;"C" (TRACK NUMBER) TO NEC
                mov     a,h
                call    SIDEBIAS            ;KK ADD SIDE BIAS
                rst     PUTNEC              ;"H" HEAD (SIDE) AS IN I.D. FIELD
                mov     a,b
                sta     PIOFIRSTR           ;SAVE FIRST RECORD THAT WE ARE TRYING TO R/W
                call    SECBIAS             ;KK ADD SECTOR OFFSET (BIAS), <H> = SIDE NO.
                rst     PUTNEC              ;"R" FIRST RECORD (SECTOR) TO R/W
                lhld    CURPDTADRS
                lxi     d,PDTPSS
                dad     d                   ;<HL>=ADRS OF PDTPSS ("N", PHYS SECT SIZE 0-3)
                mov     a,m
                mov     b,a                 ;SAVE "N" TO HELP FORM "DTL"
                rst     PUTNEC              ;"N" LENGTH OF SECTOR (0=128, 1=256,,,)
                mov     a,c
                sta     PIOLASTR            ;SAVE LAST RECORD WE ARE TRYING TO R/W
                IF DEBUGGING
                CALL    DEBUG
                ENDIF
                call    SECBIAS             ;KK ADD SECTOR OFFSET (BIAS), <H> = SIDE NO.
                rst     PUTNEC              ;"EOT" NUMBER OF RECS/TRK (LAST SECTOR)
                inx h ! inx h               ;<HL>=ADRS OF PDTGPL (R/W GAP LENGTH)
                mov     a,m
                rst     PUTNEC              ;"GPL"
                dcr     b                   ;<B> WAS "N"
                mvi     a,0FFH
                jp      PRW4                ;IF SECTOR SIZE > 128
                mvi     a,80H
PRW4:           rst     PUTNEC              ;"DTL" 80H IF "N"=0 ELSE 0FFH
;
;        ALLOW INTS AFTER LAST COMMAND BYTE HAS BEEN SENT TO NEC
;
                ei
                pop     d                   ;LEN TO READ LESS 1 BYTE
                pop     h                   ;BUFFER ADDRESS
                lda     CURLCONT            ;KK FLAG 8 OR 5 INCH
                ani     20H                 ;KK
                ret                         ;BACK TO TRANSFER DATA

;
;        COME HERE FROM READ ENDING INTERRUPT
;
PRW10:
                push    h                   ;LBA+1 READ FROM OR WRITTEN TO NEC
                lhld    PRWA                ;KK SECUNBIAS NEEDS THIS SIDE NO. IN <H>
                lda     RES$R               ;KK UNAPPLY BIAS IN CASE OF ERROR
                call    SECUNBIAS           ;KK ..OR ANYTHING
                sta     RES$R

                lda     PIOFIRSTR           ;FIRST RECORD WE TRIED TO READ OR WRITE
                mov     l,a
                lda     RES$ST0
                ani     0C0H                ;CHECK "IC", INTERRUPT CODE
                sta     PIOERSECT           ;=0 IF NORMAL COMPLEATION
                jz      PRW12               ;IF NO ERROR
                lda     RES$R               ;RECORD NUMBER THAT GAVE ERROR
                sta     PIOERSECT
                dcr     a                   ;= LAST RECORD READ OR WRITTEN W/O ERROR
                jmp     PRW13
;
PRW12:          lda     PIOLASTR            ;LAST RECORD WE READ (ALL WERE READ OK)
PRW13:          sub     l                   ;<A> = 1 LESS THAN NUMBER OF RECORDS READ OK
                jm      PRW15               ;IF NO RECORD WAS READ OK
                mov     c,a
                dcr     l
                mvi     h,BUFTAG/100H
PRW14:          mvi     m,READTAG           ;SET DATA VALID
                inx     h                   ;NEXT TAG ADDRESS
                dcr     c
                jp      PRW14               ;IF MORE RECORDS TO SET TAGS FOR

PRW15:          pop     d                   ;KK RESTORE <HL> (ALMOST)
                lhld    SPSAVE
                sphl
                xchg                        ;KK TOLD'JA
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   13.         FLOPPY DISK READ-PHYSICAL-ID (FOR DENSITY INFO)
;               PLUS GETDPB AND SETDENS
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;        GETBPB          - GET BPB FOR MS-DOS
;        GETDPBEX        - GET EXTENTED DPB FOR CP/M 3.0
;        GETDPB          - GET DPB FOR CP/M


; GBPB - Get MS-DOS Bios Parameter Block
; Parameters:
;        NONE
; Results:
;        13 byte MS-DOS BIOS Parameter Block on success.
; Description:
;        Used to determine the Density of a Floppy Disk Drive.
GETBPB:         lxi     d,LEN$BPB+256*LEN$DPBEX
                jmp     GETDPB1


; GPBX - Get Extended Disk Parameter Block (CP/M-3)
; Parameters:
;        NONE
; Results:
;        17 byte CP/M-3 DPB on success.
; Description:
;        Used to determine the Density of a Floppy Disk Drive.
GETDPBEX:       lxi     d,LEN$DPBEX
                jmp     GETDPB1


; GDPB - Get Disk Parameter Block (CP/M-80)
; Parameters:
;        NONE
; Results:
;        15 byte CP/M-80 DPB on success.
; Description:
;        Used to determine the Density of a Floppy Disk Drive.
GETDPB:         lxi     d,LEN$DPB

GETDPB1:        push    d
                xra     a
                sta     CPS$SIDE            ;START ON HEAD ZERO
                call    LOCDPB              ;LOCATE DPB BY DOING READID AND FDRELTAB SEARCH
                pop     d                   ;RESTORE OFFSET/LENGTH WORD
;KK
;KK        CURRAMDPB IS ASSIGNED IN LOCDPB
;KK
                push    h                   ;KK <HL> = FDREL ADDRESS
                lhld    CURRAMDPB           ;KK RAMDPB VALID INSTEAD?
                mov     a,h
                ora     l
                inx     h                   ;KK ADVANCE PAST LENGTH BYTE
                jnz     GETDPB1A            ;KK IF CURRAMDPB VALID
                xthl                        ;KK NOT RAMPDB, RESTORE FDREL ADDRESS
GETDPB1A:
                pop     b                   ;KK TRASH OTHER ADDRESS TO FIX STACK
                jnz     GETDPB2             ;KK IF NOT FDREL ADDRESS

                mov     a,h
                ora     l
                rz                          ;IF ID UNREADABLE
                mov     c,d                 ;OFFSET
                mvi     b,0                 ;<BC> = OFFSET INTO DPB
                dad     b
GETDPB2:
                mvi     d,1                 ;<D> SET TO XFER <E> BYTES TO HOST
                jmp     INBUFREAD3          ;GO TRANSFER TO HOST
;
;        CP/M GETDPB, GETDPBEX OR MS-DOS GETBPB
;        ENCOUNTER OTHER THAN FLOPPY DISK
;
RPINFD:         pop d ! pop d               ;(WE ARE NOT GOING TO RETURN)
                lxi     h,MD$LOSB           ;ADRS OF LEN OF OS BLOCK FOR MEMORY DISK
                jnz     RPINFD1             ;IF OS BLOCK ON MEMORY DISK IS BEING REQUESTED
                                            ;ELSE...HARD DISK
                lxi     d,PDTHOSLEN         ;OFFSET TO LENGTH OF OS BLOCK
                lhld    CURPDTADRS
                dad     d                   ;= ADDRESS OF LENGTH OF THE OS TABLE
RPINFD1:        mov     e,m
                inx     h                   ;ADDRESS OF OS BLOCK
                jmp     GETDPB2             ;TRANSFER TO HOST

LDPB$YY:        mvi     e,13H               ;ERROR CODE FOR UNRECOVERED WRONG CYLINDER
                lxi     h,RETRYC2
                dcr     m
                jp      LDPB1               ;IF WE GET TO DO IT AGAIN
                                            ;ELSE...EXIT WITH ERROR
LDPB$XX:
                mov     a,e                 ;ERROR CODE...
                sta     GENSTAT             ;...TO GENERAL STATUS
                lxi     h,0                 ;RETURN <HL>=0 FOR FAILURE
                ret
;
;        LOCDPB - LOCATE DPB FOR DEVICE
;
;        USES LOGICAL DEVICE IN SEEKDEV AND TRIES TO
;        READ IN I.D. FROM THAT DEVICE
;
;        FIRST TRIES SINGLE DENSITY (FM) AND THEN
;        IF FAILURE, TRIES DOUBLE DENSITY (MFM).
;
;        THEN SETS UP THE PHYSICAL DEVICE TABLE WITH
;        GAP LENGTHS AND SKEW TABLES
;
LOCDPB:
                lxi     h,0                 ;KK DEFAULT RAMDPB = NONE
                shld    CURRAMDPB
                call    SRC                 ;JUST USED TO SET RETRYC2
                call    FWT                 ;FORCE WRITE TAGS BEFORE WE GET TO FAR ALONG
                mvi     a,0FFH
                sta     CURPHYSDEV          ;FORCE MAKE "MAKECUR"MOVE LDT/PDT (WHY?)
                                            ;(PART OF THE REASON: TO VOID BUFFER TAGS)
                call    MAKECUR             ;MAKE "SEEKDEV" THE CURRENT UNIT
                dw      RPINFD              ;IF NOT FLOPPY DISK
;
;        ASSURE DEVICE TABLE FLAGS ARE CURRENT
;
                mvi     a,DRIVESTAT         ;NEC "SENSE DRIVE STATUS" COMMAND
                rst     PUTNEC
                lda     CURPHYSDEV
                mov     b,a                 ;KK SAVE
                ani     3                   ;UNIT NUMBER (0-3)
                rst     PUTNEC
                rst     GETNEC              ;ST3 -- OUR USE: 40H=WR PROTECT, 08H=2-SIDED
                ani     48H
                mov     c,a                 ;KK
                mov     a,b                 ;KK IF 5 INCH THEN FORCE 2 SIDED FLAG TRUE
                ani     20H                 ;KK THIS CURPHYSDEV
                mov     a,c                 ;KK RESTORE ST3
                jz      LDP0                ;KK IF 8 INCH
                ori     08H                 ;KK 5 INCH, 2-SIDED
LDP0:
                rar                         ;FLAGS FOR PDT ARE DOWN-SHIFTED ONE BIT
                mov     c,a
                lhld    CURPDTADRS
                inx h ! inx h               ;FORM ADDRESS OF FLAGS BYTE
                mov     a,m
                ani     NOT (24H+03H)       ;CLEAR "WRITE PROTECT" & "2-SIDED" FLAGS
                                            ;ALSO CLEAR BITS FOR MEDIA CHANGE STATUS
                ora     c                   ;SET ABOVE FLAGS FROM ST3
                mov     m,a                 ;STORE BACK TO PDT FLAGS BYTE
                lxi     d,PDTNBH-PDTFLG     ;OFFSET TO PDT NUMBER-OF-HEADS BYTE
                dad     d
                ani     4                   ;ISOLATE "2 SIDED" BIT
                rar ! rar                   ;SHIFT INTO LSB OF <A>
                inr     a                   ;<A> = NUMBER OF HEADS (1 OR 2)
                mov     m,a                 ;...POST TO DEVICE TABLE
;KK
;KK        IF DPB IN RAM THEN USE IT
;
                lhld    CURFPYTAB           ;KK ^CURRENT-FLOPPY-TABLE-ENTRY
                mov     a,m                 ;KK 80H= TABLE HAS DPB
                rlc
                jnc     LDPB1               ;KK NO RAM DPB, SKIP
;
                rrc                         ;KK BACK INTO POSITION
                ani     04H                 ;KK DOUBLE SIDED BIT
                mov     b,a                 ;KK SAVE
                inx     h                   ;KK POINT TO RELNUM
                                            ;KK SETDENS WANTS THIS "RELATIONSHIP NO."
                mov     e,m                 ;KK USE FOR COUNTER TO SCAN FDRELTAB
                REPT    5
                inx     h                   ;KK POINT TO SKEW
                ENDM
                mov     d,m                 ;KK TEMP SAVE
                inx     h                   ;KK POINT TO DPB LENGTH BYTE AND SAVE POINTER
                shld    CURRAMDPB           ;KK FOR ANYONE ELSE
                lhld    CURPDTADRS          ;KK SAVE DOUBLE SIDED BIT IN PDT
                inx     h                   ;KK FORM FLAGS ADDRESS
                inx     h
                mov     a,m
                ani     NOT 04H             ;KK RESET DOUBLE SIDED
                ora     b                   ;KK COMBINE DOUBLE SIDED BIT FROM FPYTAB
                mov     m,a
;
                lda     CURPHYSDEV          ;KK 5" OR 8"?
                lxi     h,STD8              ;KK 8" FDRELTAB
                ani     4                   ;KK 8" = 10H..13H
                jz      LDPB0               ;KK IF 8" UNIT
                lxi     h,STD5              ;KK 5" FDRELTAB
LDPB0:
                                            ;KK LDPB9 MOVES <E> TO <A> FOR SETDENS
                mov     a,e                 ;KK USE FOR COUNTER
                lxi     b,LENFDREL
LDPB0A:
                dcr     a
                jm      LDPB0B              ;KK EXIT WHEN <HL> = RELATIONSHIP ADDRESS
                dad     b
                jmp     LDPB0A
;
LDPB0B:
                inx     h                   ;KK LDPB9 DECRIMENTS THIS
                push    psw                 ;KK GET READY FOR LDPB9
                push    h
;
;KK COMMENTED OUT TO DISALLOW RAMDPB'S SKEW TO DESTROY EXISTING SKEW
;
;               LHLD    CURPDTADRS          ;KK MAKE SURE NOT TO ZERO SKEW
;               MOV     A,E                 ;KK REL NUM
;               ADI     LENPDTH
;               MOV     C,A
;;              ABOVE (NOT NEEDED)
;               DAD     B
;               MOV     A,D                 ;KK GET SKEW
;               ORA     A
;               JZ     LDPB9                ;KK IF ZERO LEAVE CURRENT SKEW ALONE
;               MOV     M,A                 ;KK SKEW CONTROL BYTE
                jmp     LDPB9
;KK END

LDPB1:          xra     a
                call    SEEK1               ;RECALLABRATE
                call    SEEK                ;READ ID'S FROM SEEKTRK (USER SPECIFIED TRACK)
;
;        NOW READ ID'S FROM THE DISKETTE
;
;        WE ARE GOING TO LOOP READING ID'S UNTIL WE READ THE MAXIMUM
;        ID NUMBER TWICE.  (BY DOING IT THIS WAY, WE ARE NOT DEPENDANT
;        ON HAVING THE ID'S IN ORDER ON THE TRACK.  ID'S SHOULD BE IN
;        ORDER, OR THE FULL-TRACK READ/WRITE OPERATIONS WILL TAKE
;        MUCH LONGER.  NOTE: THEY WILL CONTINUE TO WORK)
;
                lxi     b,0                 ;<B>=SINGLE DENS (FM), <C>=MAX RECORD SO FAR
                call    RID$CPS             ;KK READ ID USING CPS$SIDE
                jz      LDPB2A              ;IF SINGLE DENSITY IS CORRECT
                mvi     b,40H               ;<B>=DOUBLE DENSITY (MFM)
LDPB2:          call    RID$CPS             ;READ ID
                mvi     e,12H               ;ERROR CODE FOR CANT FIND ID
                jnz     LDPB$Xx             ;IF CANT READ ID
LDPB2A:
;
;        IF WE ARE NOT ON THE CORRECT TRACK, BEGIN CORRECTIVE PROCEDURES
;
                lda     RES$C               ;TRACK NUMBER (CYLINDER) FROM ID WE JUST READ
                lxi     h,SEEKTRK
                cmp     m
                jnz     LDPB$YY             ;IF WE ARE ON THE WRONG CYLINDER
;
;        ASSURE THAT WE SEE THE MAX RECORD NUMBER TWICE
;
                lda     RES$R               ;** RECORD NUMBER OF ID JST FOUND
                cmp     c                   ;** VSS MAX REC NUM FOUND SO FAR
                jc      LDPB2               ;IF JUST READ REC NUM IS LESS THAN CURRENT MAX
                mov     c,a                 ;ELSE...UPDATE CURRENT MAX
                jnz     LDPB2               ;IF MAX HAS BEEN INCREASED
                                            ;ELSE...MAX RECORD HAS BEEN READ TWICE
                lda     CURLCONT
                ani     20H                 ;=0 IF 8" IS CURRENT
                mov     e,a                 ;** SETUP FOR
                mvi     a,8                 ;** 8" UNIT
                jz      LDPB3               ;IF 8" UNIT
                mvi     e,LOW -NFMT8        ;ELSE...
                mvi     a,5                 ;...SETUP FOR 5" UNIT

LDPB3:          ora     b
                mov     b,a                 ;<D> = TYPE BYTE AS IN "FDRELTAB"
;
;        AT THIS POINT:
;
;        <B>          DISKETTE SIZE (8 OR 5) + 40H IF DOUBLE DENSITY
;        RES$N        SECTOR SIZE ("N" OF "CHRN")
;        <C>          NUMBER OF SECTORS PER TRACK
;        <E>          COUNTER WHICH WILL BECOME RELATIVE FORMAT NUMBER

;
;        BEGIN SCAN OF FDRELTAB
;
                lxi     h,FDRELTAB
                mov     a,m
LDPB4:          cmp     b
                jnz     LDPB6               ;IF NOT ON CORRECT SIZE/DENSITY SECTION
                inx     h
                lda     RES$N               ;SECTOR SIZE FROM DISK (0=128, 1=256, 2=512 ETC)
                cmp     m
                jnz     LDPB5               ;IF SECTOR SIZE IS WRONG
                inx     h
                mov     a,m                 ;NUMBER OF SECTORS/TRACK FROM FDRELTAB
                cmp     c                   ;VSS NUMBER FROM DISK
                dcx     h
                jz      LDPB7               ;IF WE FOUND OUR MATCH
LDPB5:          dcx     h
LDPB6:          push    b
                lxi     b,LENFDREL
                dad     b                   ;ADVANCE TO NEXT FLOPPY DISK RELATIONSHIP
                pop     b
                inr     e                   ;BUMP RELATIONSHIP NUMBER
                mov     a,m                 ;** FIRST BYTE OF NEXT FDREL ENTRY...
                cpi     0FFH                ;** ...OR OUR END OF TABLE FLAG
                jnz     LDPB4               ;IF NOT AT END OF TABLE
                mvi     e,14H               ;ERROR CODE = BAD LOGICAL FORMAT
                jmp     LDPB$XX             ;ENTRY NOT IN TABLE
;
;        CORRECT RELATIONSHIP HAS BEEN FOUND
;
LDPB7:
                push    psw
                push    h
                mov     a,b                 ;=5 OR 8 (+40H IF MFM)
                rrc
                jnc     LDPB9               ;IF 8" DRIVE
;
;        FOR 5.25" FLOPPYS ONLY, WE NEED TO READ ID FROM SIDE TWO
;        TO FIND OUT IF WE HAVE A DOUBLE-SIDDED DISKETTE MOUNTED
;
                lxi     h,CPS$SIDE
                inr     m                   ;SIDE: 0 ==> 1
                call    RID$CPS             ;READ ID (THIS TIME FROM SIDE 2)
                lhld    CURPDTADRS
                inx h ! inx h               ;FORM ADDRESS OF FLAGS BYTE
                jnz     LDPB8               ;IF READ ERROR (IE NOT DOUBLE SIDED)
                lda     RES$H
                cpi     1
                jz     LDPB9                ;IF SECOND SIDE ID HAS SECOND SIDE HEAD NUMBER
;
;        DISK IS ONLY SINGLE-SIDED -- RESET DOUBLE-SIDDED BIT IN FLAGS
;
LDPB8:          mov     a,m
                ani     NOT 4               ;CLEAR DOUBLE-SIDED BIT
                mov     m,a
                xra     a
                sta     GENSTAT             ;KILL POSSIBLE ERROR FROM FAILED SIDE 2 READID
LDPB9:
                lhld    CURPDTADRS
                inx h ! inx h               ;FORM ADDRESS OF FLAGS BYTE
                mov     a,m                 ;FLOPPY DISK FLAGS BYTE
                ori     2                   ;SAY "MEDIA NOT CHANGED" (FROM LAST GETDPB)
                mov     m,a
                pop     h
                pop     psw
                dcx     h                   ;<HL> = RELATIONSHIP ADDRESS
                mov     a,e                 ;RELATIONSHIP NUMBER
;               ...                         ;FALL INTO SETDENS

;
;        SETDENS - SET DENSITY RELATED INFO INTO PDT/LDT
;
;        ENTRY:        <A>         RELATIONSHIP NUMBER
;                      <HL>        RELATIONSHIP ADDRESS
;                      USE CURRENT (FLOPPY) DRIVE
;
SETDENS:
                xchg
                lhld    CURPDTADRS
                push    h                   ;SAVE PDT ADDRESS
                adi     LENPDTH             ;OFFSET TO SKEW BYTE = REL NUMB + LEN OF HEADER
                mov     c,a
                mvi     b,0                 ;<BC> = PDT OFFSET TO SKEW CONTROL BYTE
                dad     b                   ;<HL> = ADRS OF SKEW CONTROL BYTE
                mov     c,m                 ;SKEW CONTROL BYTE
                lxi     h,RAMDPBSKEW        ;KK RAMDPB SKEW VALID?
                mov     a,m
                ora     a
                jz     SETDEN0              ;KK NO
                mov     c,a                 ;KK YES, USE IT INSTEAD
SETDEN0:
                pop     h
                inx     h
                inx     h
                di
                mov     a,m
                ori     2                   ;SET "READY FOR R/W" BIT
                ani     NOT 40H             ;DROP MFM BIT
                mov     m,a                 ;RESTORE TO PDT
                ldax    d
                ani     040H                ;ISOLATE MFM BIT FROM RELATIONSHIP TABLE
                ora     m
                mov     m,a                 ;MFM SET IN PDT FLAGS
                ei
                push    psw                 ;SAVE PDT FLAGS FOR DOUBLE SIDED TEST
                inx     h                   ;SKIP TRACK NUMBER
                inx     h
                inx     d
                ldax    d                   ;SECTOR SIZE 2**(N+7) = BYTES/SECTOR
                mov     m,a                 ;...STORE INTO PDT
                inx     h
                inx     d
                ldax    d                   ;PHYSICAL SECTORS PER TRACK
                mov     m,a                 ;...STORE INTO PDT
                mov     b,a                 ;(SAVE FOR BSKEW)
                inx     h
                inx     d
                ldax    d                   ;R/W GAP LENGTH
                mov     m,a                 ;...STORE INTO PDT
                inx     h
                inx     d                   ;<DE>=ADRS OF FMT GAP LENGTH
                inx     d                   ;<DE>=ADRS OF DEFAULT SKEW FACTOR
                inx     d                   ;<DE>=ADRS OF SINGLE SIDED DPB
                push    d
                ldax    d                   ;LOGICAL SECTORS PER SIDE (FROM SS DPB)
                mov     m,a                 ;...STORE INTO PDT
                inx     h
                push    h                   ;<HL>=ADRS OF PDT NUMBER OF PHYSICAL HEADS
                lhld    CURPDTSKEW          ;ADRS OF SKEW LIST
                mov     e,c                 ;SKEW FACTOR
                mov     d,b                 ;SECTORS/TRACK
                call    BSKEW               ;BUILD SKEW LIST AND ...STORE INTO PDT

                pop     d                   ;ADRS OF PDT NUMBER OF PHYSICAL HEADS
                pop     h                   ;ADRS OF SINGLE SIDED DPB
                lxi     b,LEN$DPBEX+LEN$BPB ;LENGTH ADDED TO <HL> IF DOUBLED SIDED
                                            ;NOTE: <B>=0 IS USED IN MAKING # OF HEADS
                pop     psw                 ;PDT FLAGS
                ani     4
                jz      SETDEN1             ;IF SINGLE SIDED
                dad     b                   ;ADVANCE <HL> TO DOUBLESIDED DPB
                inr     b                   ;FOR NUMBER OF HEADS BYTE
SETDEN1:
                mov     a,b
                inr     a                   ;NUMBER OF HEADS
                stax    d                   ;...STORE INTO PDT
                inx     d
                lda     CURLCONT            ;CHECK...
                ani     20H                 ;...FLOPPY SIZE
                mvi     a,TRACKS8           ;NUMBER OF TRACKS ON 8" FLOPPY
                jz      SETDEN2             ;IF 8" FLOPPY
                mvi     a,TRACKS5           ;ELSE...NUMBER OF TRACKS ON 5" FLOPPY
SETDEN2:        stax    d                   ;...STORE INTO PDT
                push    h
                call    MOVCUR              ;MOVE NEW LDT/PDT TO CUR... AREA
                pop     h
                ret

;
;        RID - READ ID FROM FLOPPY DISK
;
;KK        GETS DEVICE FROM RID$DEVICE
;        GETS HEAD NUMBER FROM CURPHYSDEV
;        GETS DENSITY FROM <B> = 00H/40H FOR FM/MFM
;
;        USES:          <A>, <HL>
;        UNCHANGED:     <BC>, <DE>
;
;        RETURNS:        ZERO PSW STATUS IF READID OPERATION WORKED
;
RID$CPS:
                lda     CPS$SIDE            ;KK RID USING CPS$SIDE
                sta     RID$SIDE
RID:
                mov     a,b
                ani     40H                 ;DENSITY BIT
                ori     READID              ;NEC "READ ID" COMMAND
                di
                rst     PUTNEC
;
;        POST THE ADDRESS WE WANT TO GOTO WHEN THE READID IS DONE
;
                lxi     h,RID2
                shld    NECINTADRS

                lda     CURPHYSDEV          ;DEVICE CODE
                ani     03H                 ;MASK OFF ONLY DRIVE SELECT BITS
                mov     l,a                 ;SAVE TEMP
                lda     RID$SIDE            ;KK INSTEAD OF CPS$SIDE
                ani     1                   ;(JUST TO BE SURE)
                add     a
                add     a                   ;SIDE BIT TO HEAD SELECT POSITION
                ora     l                   ;DEVICE SELECT + SIDE
                rst     PUTNEC
                ei

;
;        HERE WE WOULD NORMALLY JUST "HLT" BUT BECAUSE OF THE FAKED
;        READY LINE ON 5" FLOPPUS, WE NEED A TIMEOUT.
;
;        THE TIMEOUT IS SET FOR 500MS (2 000 000 T-STATES).
;        IT SHOULD ONLY "GO OFF" IF READ ID IS ATTEMPTED
;        ON A NOT-READY OR NON-EXTISTANT DRIVE.
;
                lxi     h,588               ;588=2000000/(14*256)
RID1:           dcr     a
                jnz     RID1                ;BASIC TIMEOUT LOOP IS 14 T-STATES/LOOP
                dcr     l
                jnz     RID1
                dcr     h
                jp      RID1                ;IF STILL NOT TIMED OUT
;
;        HIT "TC" AND ALLOW NEC TO INTERRUPT US
;
;        DEBUG ***** IT STILL HUNG.
;        AND AS IF THAT AINT ENOUGH, WHEN WE INSERT A 5" DISK IT TAKES OFF OK!
;
;        NOW WHAT, BUCKY?
;
;        PROBLEM IS NEC CHIP.  ONLY WAY OUT IS TO SEND "RESET" TO THE CHIP.
;        THIS REQUIRES HARDWARE CHANGES ON THE BOARD.  CODE CHANGES WILL WAIT.
;
;               OUT     LOCDMALOIO          ;SEND "TC" TO NEC FDC
;               HLT                         ;WAIT FOR INTERRUPT
;

                call    RESET$NEC           ;KK
                mvi     a,40H               ;KK ABNORMAL TERMINATION CODE
                sta     RES$ST0             ;KK SIMULATE RES$ST0
;
;        RETURN FROM ID READING INTERRUPT
;
RID2:           lda     RES$ST0             ;MAIN RESULT VECTOR BYTE
                ani     0C0H                ;ONLY KEEP ERROR STATUS STUFF
                ret
;
;        HOST CALL TO READ I.D.
;
DORID:
                rst     GETHOST
                sta     RID$SIDE
                rst     GETHOST             ;KK DENSITY
                push    psw
                mvi     a,0FFH
                sta     CURPHYSDEV
                call    MAKECUR
                dw      DORIDEX9            ;KK IF NOT FLOPPY
                call    SEEK
                pop     b                   ;KK RESTORE DENSITY TO <B> FOR RID
                call    RID
;               ORA     A
;DORIDEX:
;               MVI     A,0                 ;KK CY= ERROR
;               RAL                         ;KK IF CY THEN <A>:= 1
                sta     GENSTAT
                ret
;
DORIDEX9:
                pop     b                   ;KK FIX STACK
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   14.         FLOPPY DISK FORCE WRITE (OF MODIFIED SECTORS)
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;        XFWT - HOST CALL TO FORCE WRITE TAGS
;
;        PARAMETER:
;                0        NORMAL
;                1        VOID PROBLEM SECTOR, ELSE NORMAL
;                2        DROP ALL BUFFER TAGS (ALL PENDING WRITES LOST)
;
XFWT:           xra     a
                sta     GENSTAT             ;RESET GENERAL STATUS
                rst     GETHOST             ;ACCEPT PARAMETER
                ora     a
                jz      FWT                 ;IF SIMPLE FORCE WRITE TAGS
                dcr     a
                jz      XFWT1               ;IF TO DROP JUST ONE WRITE TAG
                dcr     a
                jz      VBT                 ;IF TO DROP ALL BUFFER TAGS
                jmp     FWT                 ;ELSE BAD ... DO THE SIMPLE FORCE WRITE
;
XFWT1:          lhld    FWTA
                mov     a,m                 ;FETCH BUFFER TAG FOR PROBLEM SECTOR
                ani     NOT WRITETAG
                mov     m,a                 ;RESTORE W/O "HAS BEEN MODIFIE" FLAG
;               JMP     FWT
;               ...                         ;FALL INTO FWT

;
;        FWT - FORCEWRITE TAGS IN FLOPPY AND HARD DISK BUFFER
;
FWT:
                lda     GENSTAT
                ora     a
                rnz                         ;IF UNPROCESSED ERROR UPON ENTRY
                call    WDFWT
                lda     BUFSIDE
                ani     NOT 1               ;ONLY VALID SIDES ARE 0 AND 1
                rnz                         ;SO...IF THEY ARE NOT VALID BAIL OUT
                call    SRC                 ;SET RETRY COUNTERS
FWT0:
                lxi     h,BUFTAG
                lda     CURPDTNST           ;NUMBER OF SECTORS PER TRACK
                mov     c,a                 ;FOR LOOP COUNTER
;
;        BEGIN BY SCANNING FOR THE FIRST WRITE TAG
;
FWT1:
                mov     a,m
                cpi     READTAG+WRITETAG    ;MUST HAVE "VALID" AND "WRITE" ONLY SET
                jz      FWT2                ;IF WE HAVE A WRITE TAG
                inx     h
                dcr     c
                jnz     FWT1                ;IF MORR TAGS TO LOOK THRU
                lxi     h,0                 ;** NO ERROR -- POINT FWTA AT ROM
                shld    FWTA                ;** TO AVOID CHANCE OF MISTAKE
                ret                         ;DONE IF NO (REMAINING) WRITE TAGS
;
FWT2:           shld    FWTA                ;ADDRESS OF FIRST WRITE TAG
                                            ;  IF WE FAIL TO WRITE AND RWRETRY CANT HELP
                                            ;  US THEN (THE RECORD REFERENDED BY) THIS
                                            ;  TAG IS THE (FIRST) UNWRITEABLE ONE.
                inx     h
                mov     b,l                 ;<B>=FIRST RECORD TO WRITE
;
;        NEXT SCAN FOR LAST CONTIGEOUS WRITE TAG
;
FWT3:           mov     a,m
                cpi     READTAG+WRITETAG    ;MUST HAVE "VALID" AND "WRITE" ONLY SET
                jnz     FWT4                ;IF OFF END OF CONTIGEOUS WRITE TAGS
                inx     h
                dcr     c
                jnz     FWT3                ;IF MORE TAGS TO LOOK THRU
                dcx     h
FWT4:           mov     c,l                 ;<C>=LAST RECORD TO WRITE
                push    b                   ;SAVE FIRST AND LAST RECORD NUMBER
                lda     BUFTRACK
                call    SEEK1               ;ASSURE THAT WE ARE OVER DESIRED TRACK
                pop     b                   ;RESTORE FIRST AND LAST RECORD NUMBERS
                call    PWRITE              ;PERFORM PHYSICAL WRITE
                lda     PIOERSECT
                lxi     h,PIOFIRSTR
                cmp     m
                jnz     FWT                 ;IF NO ERROR OR ERROR NOT ON FIRST RECORD
                call    RWRETRY             ;GO DO RETRY STUFF
                dw      FWT0                ;RETRY ADDRESS
;
;        FALL THRU HERE IF UNRECOVERD ERROR
;
;        THIS IS A VERRRRRY BAD SPOT TO BE IN BECAUSE THE WRITE OPCODE
;        SENT GOOD GENERAL STATUS BACK TO THE HOST.  NOW THE HOST IS
;        DOING SOMETHING ELSE AND WE WOULD LIKE TO BRING THIS CURRENT
;        PROBLEM TO ITS ATTENTION.
;
;        OUR GENERAL ATTACK ON THE PROBLEM IS THIS --
;
;        1.  THE HOST NEEDS TO BE INVOLVED (OR AT LEAST ABLE TO BE INVOLVED).
;        2.  HOST INVOLVEMENT NEEDS TO BE SIMPLE, YET NO IMPORTANT CAPABILITY
;            DARE BE LOST TO IT.
;        3.  HOST NEEDS TO BE ABLE TO RETRY "FWT" OPERATION BOTH WAYS --
;            PURE RETRY OR SKIP THE OFFENDING SECTOR AND TRY AGAIN.
;
;           ---- METHOD ----
;
;        4.  FWT SIMPLY RETURNS WHEN IT FAILS.  (GENSTAT IS LEFT NON-ZERO).
;        5.  FWT RETURNS WITHOUT EVEN TRYING IF GENSTAT IS NON-ZERO UPON ENTRY.
;        6.  LIKEWISE, NETHER READ NOR WRITE EVEN TRY TO OPERATE IF GENSTAT
;            IN NON-ZERO UPON ENTRY: EACH ROUTINE MEERLY EXITS, PRESENTING
;            GENSTAT IN ITS OWN PARTICULAR WAY.
;        7.  AN EXTERNAL FWT CALL SUPPORTS FORCING ALL WRITE TAGS.
;            A MODIFIER TO THIS CALL ALLOWS GIVING UP ON THE SECTOR
;            THAT AN EXTERNAL FWT CALL SUPPORTS FORCING ALL WRITEBTAGS.
;            A MODIFIER TO THIS CALL ALLOWS GIVING UP ON THE SECTOR
;            THAT  HAS FAILED TO WRITE.

                ret                         ;THIS PART OF THE MESS IS SIMPLE

;
;        DUMPTAGS - HOST CALL TO RETURN BUFTAGS TO HOST
;
;        RETURNS:
;                B1              COUNT OF TAGS (SECTORS)
;                B2..BN-1        BUFTAGS
;
DUMPTAGS:
                lda     CURPDTNST           ;KK USE NUMBER OF PHYSICAL..
                mov     e,a                 ;KK ..SECTOR/TRACK FOR COUNT
                rst     PUTHOST             ;KK GIVE LENGTH TO HOST
                lxi     h,BUFTAG            ;KK POINT TO SOURCE
                mvi     d,1                 ;KK READY FOR INBUFREAD3
                mov     a,e                 ;KK DON'T GO IF ZERO TAGS
                ora     a
                rz
                jmp     INBUFREAD3          ;KK READ <E> BYTES TO HOST

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   15.         NEC INTERRUPT SERVICE
;               WITH ERROR CODE GENERATOR AND RESET$NEC
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;KK                WAIT FOR INTERRUPT.  IF NEVER OCCURS THEN ASSUME 5" NOT READY
;KK                THEN RESET FDC. (FOLLOWING CODE BORROWED FROM 'RID' ROUTINE)
;FDC$WAIT:
;        HERE WE WOULD NORMALLY JUST "HLT" BUT BECAUSE OF THE FAKED
;        READY LINE ON R" FLOPPYS, WE NEED A TIMEOUT.
;
;        THE TIMEOUT IS SET FOR 500MS (2 000 000 T-STATES).
;        IT SHOULD ONLY "GO OFF" ON A NOT-READY OR NON-EXISTANT DRIVE.
;
;               EI
;               LXI     D,588               ;588=2000000/(15*256)
;FDC$WAIT1:
;               DCR     A
;               JNZ     FDC$WAIT1           ;BASIC TIMEOUT LOOP IS 14 T-STATES/LOOP
;               DCR     E
;               JNZ     FDC$WAIT1
;               DCR     D
;               JP      FDC$WAIT1           ;IF STILL NOT TIMED OUT
;               ...                           FALL THROUGH TO RESET
RDY$ERR:
;
;KK        RESET NEC, POST ERROR STATUS AND RESTART
;
                push    h
                push    d
                push    b
                call    CLRSTAT
                call    RESET$NEC
                mvi     a,48H               ;KK 1= NOT READY
                sta     RES$ST0             ;KK FAKE NOT READY ST0 STATUS
                call    SEC                 ;KK SET ERROR CODES
                lda     PRWA+1              ;KK HEAD NUMBER
                mov     l,a                 ;KK FOR SECBIAS
                mvi     a,1                 ;KK FAKE SECTOR 1 ERROR
                call    SECBIAS             ;KK PRW10 UNAPPLIES THIS
                sta     RES$R               ;KK STORE BIAS SECTOR FOR PRW10
                pop     b
                pop     d
                pop     h
;               XTHL                        ;KK REPLACE RTN ADDRESS
;               LHLD    NECINTADRS          ;KK WITH SPECIFIED
;               XTHL                        ;KK PROCESS ADDRESS
;               RET
                jmp     BEGIN$0
;KK
;KK                CLEAR EXTENDED STATUS
;KK
CLRSTAT:
                lxi     h,GENSTAT
                mvi     b,9
CLRSTAT1:
                mvi     m,0
                inx     h
                dcr     b
                jnz     CLRSTAT1
                ret
;
RESET$NEC:
                di
                call    WAIT16
                mvi     a,0FFH              ;KK SET SERIAL OUTPUT BIT
                sim                         ;KK <=== SET SOB, TO RESET NEC765 (REQUIRES HARDWARE CHANGE)
                call    WAIT16              ;KK GIVE IT A CHANCE TO DO ITS THIN
                mvi     a,SIMMSK            ;KK 10H: ACK 7.5 (NEC), 0BH: MASK 6.5(WD) AND 5.5
                sim                         ;KK <=== CLEAR SOB
                ei
;
;        FIRST DELAY 20 MS WITH INTERRUPTS ENABLED TO GIVE NEC FDC
;        A CHANCE TO DO ITS THING
;
                lxi     h,2963              ;20 MS * 4000 T-STATES PER MS / 27 T-STATES/LOOP
RESNEC1:
                dcx     h                   ; 6
                mov     a,h                 ; 4
                ora     l                   ; 4
                jnz     RESNEC1             ;13                IF DELAY NOT DONE
                                            ;--
                                            ;27 T-STATES/LOOP  20*4000/27 = 2963 LOOPS
                jmp     DOSPEC              ;ISSUE FLOPPY DISK SPECIFY COMMAND AND RETURN

;
;        NEC INTERRUPT SERVICE
;
NECSERV:
                push    h
                push    d
                push    b
                push    psw
                lda     CURLCONT
                out     LOCCONTIO           ;TURN OFF READY SYNC (MSB SET ALWAYS)
                call    WAIT16              ;DEBUG ADD DELAY...
                in      NECSTATIO           ;THIS IS THE NEC MAIN STATUS REGISTER
                ani     10H
                jz      NECINT2             ;IF R/W COMMAND IS NOT IN PROGRESS
;
;        EXECUTION PHASE OF R/W COMMAND IS OVER
;        BEGIN RESULT PHASE BY ACCEPTING THE 7-BYTE RESULT TABLE
;
NECINT0:
                in      NECSTATIO           ;KK SEE IF FDC READY
                ani     20H                 ;KK
                jnz     NECINT0             ;KK
                lxi     h,RES$ST0
                mvi     c,7
NECINT1:        rst     GETNEC
                mov     m,a
                inx     h
                dcr     c
                jnz     NECINT1             ;IF MORE RESULT PHASE TO INPUT
NECINT1A:
                call    SEC                 ;SET ERROR CODE
                pop     psw
                pop     b
                pop     d
                pop     h
                xthl                        ;** REPLACE RTN ADDRESS
                lhld    NECINTADRS          ;** WITH SPECIFIED
                xthl                        ;** PROCESS ADDRESS
                ei
                ret

NECINT2:        call    CRC                 ;CHECK READY CHANGE

                call    WAIT16              ;DELAY TO ASSURE OK ON NEXT NEC OPERATION
                pop     psw
                pop     b
                pop     d
                pop     h
                ei
                ret                         ;RETURN TO INTERRUPTED CODE

;
;        BEGIN SENSE INTERRUPT STATUS AFTER SEEK, RECAL OR READY CHANGE
;        (RECURSIVE SUBROUTINE WITH MAI ENTRY: CRC)
;
CRC0:           rst     GETNEC              ;FINISH READINT WITH GET (AND TRASH) PCN
CRC:            mvi     a,READINT
                rst     PUTNEC
                rst     GETNEC              ;GET ST0
                cpi     80H
                rz                          ;IF NO MORE UNITSREQUIRE ATTENTION
                push    psw                 ;SAVE ST0
                call    CRC0                ;ALL READINT'S B4 ANY DRIVESTAT (RECURSIVE)
                pop     psw                 ;ST0
                cpi     0C0H
                rc                          ;IF NOT READY CHANGE (MOSTLY SEEK COMPLETE)
;
;        READY CHANGE -- CHANGE DEVICE TABLE IF DROP READY
;
                mov     c,a                 ;SAVE ST0 (THIS IS FROM READINT AFTER PUSH/POP)
                mvi     a,DRIVESTAT         ;NEC "SENSE DRIVE STATUS" COMMAND
                rst     PUTNEC
                mov     a,c                 ;FIRST BYTE OF READINT REPLY
                ani     3                   ;ISOLATE UNIT NUMBER (0-3)
                mov     c,a                 ;SAVE FOR USE IF DROP READY
                rst     PUTNEC
                rst     GETNEC              ;ST3
                ani     20H
                rnz                         ;IF UNIT CAME READY
;
;        UNIT DROPPED READY -- DO "ANI NOT 02" TO DEVICE TABLE FLAG BITS
;        (ALSO, IF 5" DRIVE THEN ALL 5" DRIVES HAVE READY LINES)
;
                mvi     b,0                 ;<BC> = UNIT NUMBER
                lxi     h,PDTFINDERS
                dad b ! dad b               ;<HL> = ADRS OF PDT FINDER ENTRY (IF 8")
                lda     CURLCONT
                ani     20H
                jz      CRC1                ;IF 8" DRIVE
                sta     RLINE5              ;MARK 5" DRIVES AS HAVING READY LINES
                mvi     c,8
                dad     b                   ;<HL> NOW SET AT 5" PDT FINDER
CRC1:           mov     c,m
                inx     h
                mov     b,m                 ;<BC> = DEVICE TAB;E ADDRESS
                inx b ! inx b               ;<BC> = ADRS OF FLAG BYTE
                ldax        b
                ani     NOT 02              ;MARK "DROP READY"
                stax    b
                ret

;        SEC -- SET ERROR CODE
;
;        CALLED FROM NECSERV AFTER 7-BYTE RESULT VECTOR IS READ
;
;        IT SHOULD BE NOTED THAT ERROR RECOVERY IS NOT DONE HERE.
;        ERROR RECOVERY IS DONE IN RWRETRY.  WHAT WE ARE DOING HERE
;        IS DEFINING ERROR CODES AND SETTING UP, BUT NOT DOING,
;        ERROR RECOVERY.
;
;        MOST OF THE OPERATION OF SEC AND ITS SUBROUTINE, MEC
;        IS GIVEN BELOW.
;
;     <D>       <L>       <H>     <B>    <C>    <---REGISTER USE---
;    ST 0      ST 1      ST 2    ERROR
;  76543210  76543210  76543210   CODE
;  --------  --------  --------
;  ...1....  ........  ........    01    DIE      NOT READY
;  ........  ......1.  ........    02    DIE      NOT WRITEABLE
;  ........  ........  ...1....    03    RECAL    WRONG CYLINDER (SEEK ERROR?)
;  ........  ........  ......1.    04    RECAL    BAD CYLINDER (FORMAT ERROR?)
;  ........  ........  .1......    05    SRETRY   CONTROL MARK (DEL DATA AM FOUND)
;  ........  .......1  .......0    06    SRETRY   CANT READ ANY ID ADDRESS MARKS
;  ........  .....1..  ........    07    SRETRY   CANT FIND REQUESTED ID
;  ........  .......1  .......1    08    RETRY    MISSING DATA ADDRESS MARK
;  ........  ..1.....  ..1.....    09    RETRY    CRC ERROR IN DATA
;  ........  ..1.....  ........    10    RETRY    CRC ERROR IN ID
;  ........  ...1....  ........    11    RETRY    OVER RUN (HDW/FIRMWARE ERROR?)
;  ...1....  ........  ........    12    RETRY    DRIVE DETECTED FAULT
;  ..... A L L    E L S E .....    13    RETRY    UNKNOWN ERROR FROM FD CTLR CHIP
;
;
;  <C>  RECOVERY METHOD    HOW IMPLEMENTED
;  ---  ---------------    ---------------------
;  1    NORMAL RETRY
;  2    SEEK RETRY         RETRYC1=O
;  3    RECAL              RETRYC1=0, RETRYC3=2
;  4    DIE                RETRYC1=0, RETRYC3=2, RETRYC2=0
;
SEC:
                lda     RES$ST0
                mov     d,a
                ani     0C0H
                sta     GENSTAT             ;STORE DONE AGAIN IF THIS IS NON-ZERO
                rz                          ;IF NO ERROR THEN WE ARE DONE
                lhld    RES$ST1             ;<L>=ST1, <H>=ST2
                lxi     b,104H              ;<B>=1, <C>=4
                call    MEC                 ;MAP ERROR CODE
                lda     OPTYPE
                ora     b
                sta     GENSTAT
                dcr     c
                rz                          ;IF NORMAL RETRY RECOVERY
                xra     a
                sta     RETRYC1             ;FORCE NEXT RETRY TO SEEK NEXT
                dcr     c
                rz                          ;IF WE WANTED SEEK RETRY
                mvi     a,2
                sta     RETRYC3             ;FORCE SEEK TYPE TO BE RECAL
                dcr     c
                rz                          ;IF WE WANTED RECAL RETRY
                xra     a
                sta     RETRYC2             ;ELSE WE WANT TO DIE
                ret

;
;        MEC -- MAP ERROR CODE
;
;        UPON ENTRY--
;
;        <B> = 4    RECOVERY METHOD = DROP DEAD
;        <C> = 1    ERROR CODE
;        <D> = ST0
;        <L> = ST1
;        <H> = ST2
;
MEC:
                mov     a,d                 ;ST0
                ani     8
                rnz                         ;IF NOT READY (EC=1)
                inr     b                   ;EC=2
                mov     a,l                 ;ST1
                ani     2
                rnz                         ;IF NO WRITE ENABLE (EC=2)
                inr     b                   ;EC=3
                dcr     c                   ;<C>=3, RECAL RETRY
                mov     a,h                 ;ST2
                ani     10H
                rnz                         ;IF WRONG CYL (EC=3)
                inr     b                   ;EC=4
                mov     a,h                 ;ST2
                ani     2
                rnz                         ;IF BAD CYL (EC=4)
                inr     b                   ;EC=5
                dcr     c                   ;<C>=2, SEEK RETRY
                mov     a,h                 ;ST2
                add     a
                rm                          ;IF CONTROL MARK (DELETED DATA MARK) EC=5
                inr     b                   ;EC=6
                mov     a,h                 ;ST2
                cma
                ana     l                   ;ST1
                rrc
                rc                          ;IF CANT READ ANY ID ADDRESS MARK (EC=6)
                inr     b                   ;EC=7
                mov     a,l                 ;ST1
                ani     4
                rnz                         ;IF CANT FIND REQUESTED ID (EC=7)
                inr     b                   ;EC=8
                dcr     c                   ;<C>=1, NORMAL RETRY
                mov     a,l                 ;ST1
                ana     h                   ;ST2
                rrc
                rc                          ;IF MISSING DATA ADDRESS MARK (EC=8)
                inr     b                   ;EC=9
                mov     a,l                 ;ST1
                ana     h                   ;ST2
                ani     20H
                rnz                         ;IF CRC ERROR IN DATA (EC=9)
                inr     b                   ;EC=10
                mov     a,l                 ;ST1
                ani     20H
                rnz                         ;IF CRC IN ID (EC=10)
                inr     b                   ;EC=11
                mov     a,l                 ;ST1
                ani     10H
                rnz                         ;IF OVER RUN (EC=11)
                inr     b                   ;EC=12
                mov     a,d                 ;ST0
                ani     10H
                rnz                         ;IF DRIVE DETECTED ERROR (EC=12)
                inr     b                   ;EC=13
                ret                         ;UNKNOWN RESPONSE FROM FD CTLR CHIP

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   16.         ALL HARD DISK ACCESS CODE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

HDPARM:         call    FWT                 ;JUST TO BE VERY SURE
                shld    WDCYL               ;RAM ADRS ASSURES NO MATCH ON CYLINDER
                lxi     h,HDHEADS           ;SET #HDS, PRE-COMP, HD STEP SATE, HD CTLR TYPE
                call    GC4
;
;        COPY #HEADS, PRECOMP AND STEP RATE TO ALL 4 HARD DISK TABLES
;
HDINIT:
                lxi     b,HDHEADS           ;SOURCE OF COPY
                lxi     h,HD00+PDTHHEADS    ;FIRST COPY DESTINATION
                lxi     d,LENHDDT           ;SPACE BETWEEN DESTINATIONS
                call    HDPSUB              ;COPY NUMBER OF HEADS...
                call    HDPSUB              ;...PRECOMP CYL AND...
                call    HDPSUB              ;...STEP RATE
HDI1:
                in      WDSTATIO
                ani     80H
                jnz     HDI1                ;IF STILL BUSY AFTER SYSTEM RESET
;               XRA     A                   ;<A>=0 FROM ABOVE SO ";" IN COL 1 IS OK
                out     WDHITRKIO
                out     WDLOTRKIO

                IF      HDRECAL
                mvi     a,1fH               ;RECAL WITH 7.5ms STEP RATE
                out     WDCMDIO
HDI2:           in      WDSTATIO
                ani     80h
                jnz     HDI2                ;IF RECAL IS NOT DONE
                ENDIF

                inx     h
;               MOV     A,M                 ;HARD DISK STEP RATE...
                xra     a                   ;DEBUG...I DONT THINK WE NEED THIS SECTION
                ori     70H                 ;...PLUS SEEK COMMAND
                out     WDCMDIO             ;SEEK TO ZERO TO DEFINE STEP RATE FOR DRIVE
HDI3:           in      WDSTATIO
                ani     80H
                jnz     HDI3                ;IF SEEK IS NOT DONE
                ei
                ret
;
HDPSUB:                 ;SUBROUTINE OF HDPARM
                push    h
                ldax    b                   ;FETCH PARAMETER TO MOVE TO HARD DISK DEV TABLE
                mov m,a ! dad d             ;...TO HD00 TABLE
                mov m,a ! dad d             ;...TO HD01 TABLE
                mov m,a ! dad d             ;...TO HD02 TABLE
                mov     m,a                 ;...TO HD03 TABLE
                pop     h
                inx     h
                inx     b
                ret
;
HARD$READ:
                lda     MODE                ;IS IT DMA
                rlc                         ;IF YES WE MUST USE BUFFER FOR TRANSFER
                jc      HARD$READ1
                lda     PFIOFLAG            ;IS IT PHYSICAL READ
                ora     a                   ;IF YES GO DO FAST READ
                jnz     FAST$READ           ;GO DO DIRECT I/O TO WD CONTROLLER
HARD$READ1:
                call    WDCK                ;ARE WE STILL IN OUR CURRENT BUFFER?
                cnz     WDPREAD             ;IF DATA NOT IN BUFFER THEN DO PHYS READ
                rc                          ;IF ERROR...
                call    WDBUFFCAL           ;<HL>=BUFF ADDRESS
                shld    CPS$BUFADR
                jmp     INBUFREAD           ;TRANSFER DATA TO HOST
;
HARD$WRITE:
                lda     MODE                ;IS IT DMA
                rlc                         ;IF YES WE MUST USE BUFFER FOR TRANSFER
                jc      HARD$WRITE1
                lda     PFIOFLAG            ;IS IT A PHYSICAL WRITE
                ora     a                   ;IF YES GO DO FAST WRITE
                jnz     FASTWRITE           ;GO DO DIRECT I/O TO WD CONTROLLER
HARD$WRITE1:
                call    WDCK                ;ARE WE STILL IN OUR CURRENT BUFFER?
                cnz     WDPREAD             ;IF NOT SEQ WRITE THEN PRE-READ IS REQUIRED
                rc                          ;IF ERROR...
                mvi     a,0FFH              ;** MARK BUFFER AS...
                sta     WDBMOD              ;** ...HAVING BEEN MODIFIED
                call    WDBUFFCAL           ;<HL>=BUFF ADDR
                shld    CPS$BUFADR
                jmp     INBUFWRITE          ;FETCH WRITE DATA FROM HOST

;
;        WDPREAD        -- WD PHYSICAL READ
;
;        OPERATION:
;        1.  ASSURE ANY MODIFIED BUFFER IS WRITTEN BACK TO DISK
;        2.  ISSUE COMMANDS FOR READ
;        3.  WAIT FOR COMMAND TO FINISH INSIDE WD CTLR
;        4.  TAKE DATA FROM WD CTLR
;        5.  CHECK WD ERROR STATUS
;
WDPREAD:
                call    WDFWSET             ;FORCE WRT & SETUP WD CTLR FOR PHYS READ/WRITE
                rc                          ;IF FORCE WRITE ERROR
;
;        ENTRY HERE FROM FORMAT VERIFY
;
WDPR0:          lxi     b,WDCMD             ;SETUP WD CD/STS PORT
                mvi     a,WDREADCMD
                stax    b                   ;SEND READ COMMAND
WDPR1:          ldax    b                   ;FETCH WD STATUS
                ani     80H                 ;CHECK FOR "BUSY"
                jnz     WDPR1               ;IF WD CONTROLLER IS NOT READY TO DELIVER DATA
                mov     c,a                 ;FORM DATA PORT ADDRESS IN <BC>
                lxi     h,WDBUFF
                mov     e,c                 ;ZERO LOOP COUNTER FOR 256 LOOPS (512 BYTES)

WDPR2:          ldax    b                   ;DATA BYTE...
                mov     m,a                 ;...TO WDBUFF
                inx     h
                ldax    b                   ;DATA BYTE...
                mov     m,a                 ;...TO WDBUFF
                inx     h
                dcr     e
                jnz     WDPR2               ;IF NOT DONE MOVING 512 BYTES
                in      WDSTATIO
                rrc
                jc      WD$GAVE$ERROR       ;IF WD CTLR GAVE ERROR READING SECTOR
;
;        MARK SECTOR AS ACTIVE AND UNCHANGED
;
                lxi     d,SEEKDEV
                lxi     h,WDDEV
                mvi     c,5                 ;BYTES TO MOVE
WPDR3:          ldax    d
                mov     m,a
                inx     h
                inx     d
                dcr     c
                jnz     WPDR3               ;IF MORE BYTES TO MOVE
                mov     m,c                 ;SEND TO WDBMOD
                ret                         ;NOTE: CARRY MUST BE CLEAR

;
;        WDFWT        -- WD FORCE WRITE SECTOR IF SECTOR IS MODIFIED
;
;        RETURNS WITH CARRY SET IF WD ERROR
;
WDFWT:
                lda     WDBMOD              ;WD BUFFER MODIFIED FLAG
                ora     a
                rz                          ;IF WRITE IS NOT NESSESSARY
WDPWT:
;
;        BUTLER WANTS TO TRY WITH THIS SECTION OUT
;
                lda     PFIOFLAG            ;WE NEED TO SEE IF PHYSICAL I/O
                ora     a                   ;IF SO THEN DO NOT DIVIDE
                lda     WDSEC
                jnz     WDPWT1B
                ani     NOT 03
                rrc ! rrc
WDPWT1B:        out     WDSECTIO
;
WDPWT1A:
                mvi     a,WDWRITECMD
                out     WDCMDIO             ;WRITE CMD TO WD CTLR
                lxi     b,WDDATA            ;DATA PORT ADDRESS TO <BC>
                mov     e,c                 ;ZERO LOOP COUNTER FOR 256 LOOPS (512 BYTES)
                lxi     h,WDBUFF
WDPWT1:         mov     a,m                 ;DATA BYTE...
                stax    b                   ;...TO WD CTLR
                inx     h
                mov     a,m                 ;DATA BYTE...
                stax    b                   ;...TO WD CTLR
                inx     h
                dcr     e
                jnz     WDPWT1              ;IF NOT DONE MOVING 512 BYTES
WDPWT2:         in      WDSTATIO
                rlc                         ;BUSY STATUS ==> CARRY
                jc      WDPWT2              ;IF WRITE HAS NOT COMPLEATED
                in      WDSTATIO
                rrc
                jc      WD$GAVE$ERROR
                xra     a
                sta     WDBMOD              ;MARK SECTOR AS = WHAT WE NOW HAVE ON DISK
                ret
;
FAST$READ:
                call    WDFWSET             ;FORCE ANY PENDING WRITE AND SETUP FOR READ
                rc                          ;IF FORCE WRITE ERROR
                mvi     a,0FFH
                sta     WDSEC               ;VOID WDBUFFER FLAG
                mvi     a,WDREADCMD
                stax    b                   ;ISSUE READ COMMAND
FASTR1A:
                ldax    b                   ;FETCH WD STATUS
                ani     80H                 ;CHECK WD "BUSY"
                jnz     FASTR1A             ;IF WD CONTROLLER IS NOT READY TO DELIVER DATA
                sta     GENSTAT             ;CLEAR ERROR FLAG
                mov     c,a                 ;FORM DATA PORT ADDRESS IN <BC>
                lxi     h,SYSDATOUT
                mov     e,c                 ;ZERO LOOP COUNTER FOR 256 LOOPS (512 BYTES)
                mvi     d,SYSOUTSTAT

FASTR1:         in      SYSSTATIO
                ana     d
                jnz     FASTR1              ;IF HOST HAS NOT ACCEPTED LAST BYTE
                ldax    b                   ;DATA BYTE FROM WD CTLR...
                mov     m,a                 ;...SEND TO HOST
FASTR2:         in      SYSSTATIO
                ana     d
                jnz     FASTR2              ;IF HOST HAS NOT ACCEPTED LAST BYTE
                ldax    b                   ;DATA BYTE FROM WD CTLR...
                mov     m,a                 ;...SEND TO HOST
                dcr     e
                jnz     FASTR1              ;IF NOT DONE MOVING 512 BYTES
FASTR3:         in      SYSSTATIO           ;WAIT FOR HOST TO TAKE LAST BYTE TO SEND
                ana     d
                jnz     FASTR3
                in      WDSTATIO
                rrc
                jc      WD$GAVE$ERROR       ;IF WD CTLR GAVE ERROR READING SECTOR
                ret

FASTWRITE:
                call    WDFWSET             ;FORCE PENDING WRITES AND SETUP FOR WRITE
                rc                          ;IF FORCE WRITE ERROR
                xra     a
                sta     GENSTAT             ;CLEAR ERROR FLAG
                rst     PUTHOST             ;SEND DUMMY ZERO TO HOST
                dcr     a                   ;<A> = 0FFH
                sta     WDSEC               ;VOID WD BUFFER TAGS
                mvi     a,WDWRITECMD
                out     WDCMDIO             ;WRITE CMD TO WD CTLR
                lxi     b,WDDATA            ;DATA PORT ADDRESS TO <BC>
                mov     e,c                 ;ZERO LOOP COUNTER FOR 256 LOOPS (512 BYTES)
                lxi     h,SYSDATIN
FASTW1:         in      SYSSTATIO
                rar
                jnc     FASTW1
                mov     a,m                 ;DATA BYTE FROM HOST...
                stax    b                   ;...TO WD CTLR
FASTW2:         in      SYSSTATIO           ;HAS HOST SENT US A BYTE
                rar
                jnc     FASTW2
                mov     a,m                 ;DATA BYTE FROM HOST...
                stax    b                   ;...TO WD CTLR
                dcr     e
                jnz     FASTW1              ;IF NOT DONE MOVING 512 BYTES
FASTW3:         in      WDSTATIO
                rlc                         ;BUSY STATUS ==> CARRY
                jc      FASTW3              ;IF WRITE HAS NOT COMPLEATED
                in      WDSTATIO
                rrc
                jc      WD$GAVE$ERROR
                ret

HARD$FMT:
                lda     FMT$CNTL            ;FORMAT SUB-OPCODE BYTE
                ani     1
                jz     HDFMT7               ;IF NOT TO FORMAT THEN CHECK FOR VERIFY
                mvi     a,HDSECS
                out     WDSECTCNTIO
                call    WDSET
                mvi     a,27                ;** NON-ECC CTLR ADDS 3 TO ** (THIS DOES NOT
                out     WDSECTIO            ;** GIVE GAP1 = GAP3 = 30  **   EFFECT ECC CTLR)
                mvi     a,WDFMTCMD
                out     WDCMDIO
;
;        BUILD SKEW TABLE FOR PHYSICAL SECTOR ORGANIZATION
;
                lxi     h,WDBUFF
                mov     c,l                 ;INIT SECTOR NUMBER TO ZERO
                mvi     d,HDSECS            ;PHYS SECTORS PER TRACK
                jmp     HDSQ2               ;ENTER LOOP...
;
HDSQ1:          lda     SEEKSEC             ;**
                add     l                   ;** ADD SKEW FACTOR TO ADDRESS
                mov     l,a                 ;**
                sub     d
                jc      HDSQ3               ;IF WE DID NOT WRAP-AROUND
                mov     l,a                 ;ELSE SET ADDRESS-LENGTH
                cmp     b
                jnz     HDSQ3               ;IF WRAPAROUND DID NOT HOT A PREVIOUS VALUE
                inr     l                   ;ELSE...
HDSQ2:          mov     b,l                 ;    ...DO ADJUST
HDSQ3:          mov     m,c
                inr     c
                mov     a,c
                sub     d
                jnz     HDSQ1               ;IF NOT DONE

                mov     l,a                 ;<HL> = WDBUFF **NOTE: <L> ALSO IS LOOP CNTR**
HDFMT2:
                xra     a
                out     WDDATAIO            ;ZERO BYTE TO WD CTLR
                mov     a,m
                out     WDDATAIO            ;SKEW BYTE TO WD CTLR
                inr     l
                jnz     HDFMT2              ;IF MORE DATA TO OUTPUT
HDFMT3:
                in      WDSTATIO
                rlc
                jc      HDFMT3              ;IF STILL BUSY DOING FORMAT
                in      WDSTATIO
                rrc
                jc      WD$GAVE$ERROR
HDFMT4:
;
;        FORMAT DONE OK -- NOW FILL WDBUFF W/ E5'S AND WRITE THE TRACK
;
                lda     FMT$CNTL
                ani     4
                jz     HDFMT7               ;IF NOT TO WRITE E5'S
                lxi     h,WDBUFF
                lxi     b,0E500H            ;<C>=0 FOR 256 LOOPS (FILLS ALL 512 BYTES)
HDFMT5:
                mov     m,b                 ;E5 TO BUFFER
                inx     h
                mov     m,b                 ;E5 TO BUFFER
                inx     h
                dcr     c
                jnz     HDFMT5              ;IF MORE BUFFER TO FILL
;
;        BUFFER FILLED WITH E5'S -- NOW WRITE TO ALL SECTORS
;
;               MVI     C,0
HDFMT6:         push    b
                call    WDSET               ;SETUP TO WRITE...
                pop     b
                mov     a,c
                out     WDSECTIO            ;...DEFINE SECTOR TO WRITE...
                push    b
                call    WDPWT1A             ;...AND THEN WRITE
                pop     b
                rc                          ;RETURN IF ERROR
                inr     c                   ;NEXT SECTOR NUMBER TO WRITE
                mvi     a,HDSECS
                cmp     c
                jnz     HDFMT6              ;IF MORE SECTORS TO WRITE
;
;        PREHAPS WE WANT TO VERIFY
;
HDFMT7:         lda     FMT$CNTL
                ani     2
                rz                          ;IF NOT TO VERIFY
;
;        READ ALL SECTORS
;
                mvi     c,0
HDFMT8:         push    b
                call    WDSET              ;SETUP FOR READ
                pop     b
                mov     a,c
                out     WDSECTIO            ;...DEFINE SECTOR TO READ...
                push    b
                call    WDPR0               ;...AND THEN READ
                pop     b
                rc                          ;RETURN IF ERROR
                inr     c                   ;NEXT SECTOR NUMBER TO VERIFY
                mvi     a,HDSECS
                cmp     c
                jnz     HDFMT8              ;IF MORE SECTORS TO VERIFY
                ret
;
WDFWSET:        call    WDFWT               ;FORCE ANY PENDING WRITES
                rc                          ;IF ERROR
;               ...                         ;FALL INTO WDSET

;
;        HEAD AND CYLINDER ARE FORMED BY DIVIDING LOGICAL CYLINDER
;        (PLUS OFFSET) BY THE NUMBER OF EADS.
;
;        FORMAT USED BY WD CONTROLLER:
;                ESSDDHHH
;                     HHH        HEAD (REMAINDER AFTER DIVIDE)
;                   DD           DRIVE 0-3 FROM CURPHYSDEV
;                 01             512-BYTE SECTORS      ** (THESE BITS COME
;                1               USE ECC IN DATA FIELD **  FROM HDCTYPE)
;
WDSET:
                lda     CURPDT+PDTHPCMP
                out     WDERRORIO           ;DEFINE PRE-COMP VALUE

                lda     CURPDT+PDTHDEV      ;000DD000
                lxi     h,HDCTYPE
                ora     m                   ;MERGE W/ "HARD DISK CTLR TYPE" FOR ECC OR NON-ECC
                lhld    CURPDT+PDTHOFFSET
                xchg
                lhld    SEEKTRK             ;GIVEN TRACK...
                dad     d                   ;...PLUS HARDWARE OFFSET (THIS WE DIVIDE)
                mov     d,a                 ;SAVE ESSDD000 FOR USE AFTER DIVIDE
                lda     CURPDT+PDTHHEADS    ;NUMBER HEADS ON THIS HARD DISK...
                mov     c,a                 ;...IS DIVISOR
                call    DIVMQ               ;DIVIDE <HL> BY <C>
;
;        AT THIS POINT...
;
;        <HL> = PHYSICAL CYLINDER NUMBER FOR WD CTLR
;        <A>  = PHYSICAL HEAD NUMBER FOR WD CTLR
;        <D>  = ESSDD000 READY TO BE MERGED WITH HEAD NUMBER
;
                shld    WDLOTRK             ;SEND BOTH CYLINDER BYTES TO WD CTLR

                ora     d                   ;ERGE ESSDD0000 WITH HEAD NUMBER
                out     WDSPECIO            ;SENT TO WD CTLR
;
;        IF PHYSICAL FORMAT I/O MODE THEN
;          WDSCET <== SEEKSEC
;        ELSE
;          WDSECT <== SEEKSEC/4
;
                lda     PFIOFLAG
                ora     a
                lda     SEEKSEC
                jnz     WDSET1              ;IF IN PHYSICAL FORMAT MODE
                ani     NOT 3
                rrc ! rrc                   ;PHYS SECTOR...
WDSET1:         out     WDSECTIO            ;...TO WD CTLR
                lxi     b,WDCMD
                ret

;
;        RETURNS ADDRESS WITHIN WDBUFF USING "SEEKSEC"
;
;        LOGICAL FRACTION OF PHYSICAL SECTOR COMES
;        FROM LOW 2 BITS OF LOGICAL SECTOR
;
;        MAPPING IS ......XY ==> XY000000
;
WDBUFFCAL:
                lxi     h,512
                shld    CPS$PSECT           ;SETUP BYTES/SECTOR FOR INBUF(READ/WRITE)
                lxi     h,WDBUFF            ;**
                lda     PFIOFLAG            ;** DO THIS STUFF FOR PHYSICAL
                ora     a                   ;** FORMAT I/O
                rnz                        ;**
                lda     SEEKSEC
                ani     3
                rrc ! rrc
;
;        LASTLY, FORM ADDRESS OF LOGICAL SECTOR WITHIN WDBUFF
;
                add     a                   ;Y0000000 & X TO CARRY
                mov     l,a                 ;LOW BYTE OF ADDRESS WITHIN WDBUFF
                ral                         ;0000000X (AND WE ARE DONE WITH Y)
                add     h                   ;WDBUFF/100H (EXACT--WDBUFF IS ON 100H BOUNDARY)
                mov     h,a                 ;<HL> = ADDRESS WITHIN WDBUFF
                ret

;
;        WDCK -- CHECK IF HOST REQUEST IS WITHIN WDBUF
;
;        RETURNS ZERO PSW STATUS IF HOST REQUEST IS WITHIN CURRENT WDBUF
;
WDCK:
                lxi     h,SEEKDEV
                lxi     d,WDDEV
                ldax    d                   ;WDDEV
                cmp     m                   ;SEEKDEV
                rnz
                inx     d
                inx     h
                ldax    d                   ;WDCYL (LOW BYTE)  NOTE: LOGICAL CYLINDERS
                cmp     m                   ;SEEKTRK (LOW BYTE)      ARE CHECKED HERE
                rnz
                inx     d
                inx     h
                ldax    d                   ;WDCYL (HIGH BYTE)
                cmp     m                   ;SEEKTRK (HIGH BYTE)
                rnz
                inx     d                   ;(SKIP WDHEAD
                inx     h                   ; AND SEEKHD)
                inx     d
                inx     h
                lda     PFIOFLAG
                ora     a
                ldax    d                   ;WDSEC
                jnz     WDCK1               ;IF DOING 512-BYTE TRANSFERS
                xra     m                   ;VSS SEEKSEC
                ani     NOT 03              ;DONT CHECK THE BITS WE DONT CARE ABOUT
                ret
;
WDCK1:
                cmp     m                   ;COMPARE FOR 512-BYTE SECTORS
                ret
;
WD$GAVE$ERROR:
                in      WDERRORIO
                sta     GENSTAT
                ret

; ******************************************************************
; DIVMQ -- DIVIDE MEDIUM QUICK (REGISTER ARGUMENTS)
;
; SUBROUTINE IS USED TO DIVIDE TRACK NUMBER (IN SEEKTRK)
; BY THE NUMBER OF HEADS TO GIVE PHYSICAL CYL AND HEAD
; FOR THE HARD DISK
;
; INPUT:  <HL> 16-BIT DIVIDEND (24-BIT IF <AHL> USED)
;         <C> 8-BIT DIVISOR
;
; OUTPUT: <B> = 0 (USED AS LOOP COUNTER)
;         <C> 8-BIT DIVISOR (UNCHANGED)
;         <A> 8-BIT REMAINDER
;         <DE> = UNCHANGED (NOT USED)
;         <HL> 16-BIT QUOITIENT
;
; >>>THIS ROUTINE IS QUICK BECAUSE NO CHECK IS MADE FOR VALID DIVIDE<<<
;

DIVMQ:          xra     a                   ;FOR 16-BIT DIVIDEND IN <HL>
DIVMQ1:                                     ;ENTRY HERE FOR 24-BIT DIVIDEND IN <AHL>
;
;        DELETE THE NEXT SIX LINES AND CHANGE THE
;        LOOP COUNTER TO 16 FOR GENERAL-PURPOSE ROUTINE
;
                dad     h                   ;** THE 6 "DAD H" INSTRUCTIONS HERE ASSURE
                dad     h                   ;** 6 HIGH-ORDER ZERO BITS IN THE QUOTIENT
                dad     h                   ;**
                dad h ! ral                 ;** THE 3 MISSING "RAL" INSTRUCTIONS ARE OK
                dad h ! ral                 ;** BECAUSE WE KNOW THAT THERE OUT DIVIDEND
                dad h ! ral                 ;** HAS AT LEAST 3 HIGH-ORDER ZERO BITS

                mvi     b,10                ;LOOP COUNTER (ONLY 10 BITS IN THIS DIVIDE)
;
;        THIS DIVIDE ROUTINE WORKS FOR ALL DIVISORS FROM 1 TO 80H
;        FOR ALL DIVIDENDS LESS THAN 2000H (AT LEAST 3 HIGH-ORDER
;        ZERO BITS ARE NEEDED) AS LONG AS THE QUOTIENT IS LESS THAN 400H.
;
;        QUOTIENT LESS THAN 4OOH LIMITS THE DIVIDEND TO LESS THAN
;        400H * <C>. THIS IS THE LIMITING FACTOR UNLESS <C>, THE
;        DIVISOR, IS GREATER THAN 8.
;
;        OR IN TERMS OF THE HARD DISKS THAT THIS WAS WRITTEN FOR:
;
;                MAX NUMBER OF TRACKS: 8192
;                MAX NUMBER OF CYLINDERS: 1024        IF 1 TO 8 HEADS
;                                   OR 8192/NH        IF NUMBER OF HEADS >8
;
;        EXECUTION TIME:
;
;                6 * dad     36 (ALL TIME IN T-STATES)
;                3 * RAL                12
;                XRA + MVI              11
;                                      ---
;                                       59 (NON-LOOP OVERHEAD)
;
;                DAD H                  60
;                RAL                    40
;                CMP C                  40
;                JC           85 50/50 JUMP TAKEN/JUMP NOT TAKEN
;                SUB/INR      40 50% EXECUTED
;                DCR B                  40
;                JNZ          97 JUMP TAKEN 9 OUT OF THE 10 TIMES
;                                      ---
;                                      402 (TOTAL LOOP TIME)
;
;                59+402=461 T-STATES
;                OR ABOUT 115 uSEC AVG EXECUTION TIME AT 4MHZ T-STATE CLOCK
;
;                THE AVG TIME IS EVEN LESS THAN INDICATED BECAUSE WE
;                ARE NOT PRODUCING THE ENTIRE RANGE OF QUOTIENTS AND
;                BECAUSE THE OFTEN USED DIRECTORY IS ON A LOW-NUMBERED
;                TRACK WHICH DIVIDES SOMEWHAT FASTER.
;
DIVMQ2:         dad     h
                ral
                cmp     c
                jc      DIVMQ3              ;IF TO DO SUBTRACT
                sub     c
                inr     l                   ;QUOTIENT BIT
DIVMQ3:         dcr     b                   ;LOOP COUNTER
                jnz     DIVMQ2              ;IF MORE BITS
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   17.         ALL DMA STUFF
;               (FOR NORMAL READ/WRITE, MEM DISK AND MOVE MEMORY)
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;        MOVMEM -- MOVE MEMORY HOST CALL
;
;        PARAMETERS:
;
;                DESTINATION: 3 BYTES (LO, HI, EX)
;                SOURCE:      3 BYTES (LO, HI, EX)
;                COUNT OF l28-BYTE BLOCKS (l MOVES 128 BYTES, 0 MOVES 32K)
;

; MOVM - DMA memory move
; Parameters:
;        P1 word: DEST
;        P2 byte: Extended Address bits 17-23
;        P3 word: SRC
;        P4 byte: Extended Address bits 17-23
;        P5 byte: Block length * 128
; Decription:
;        Move Block of Memory with DMA
MOVMEM:
                lxi     h,MMDEST            ;** GET BOTH
                call    GC6                 ;** ADDRESSES
                rst     GETHOST             ;GET LOOP COUNT
                mov     c,a
MMLOOP:         lxi     d,MMFROM            ;HOST SOURCE
                lxi     h,MISCBUF           ;USE OUR LOCAL SCRAP BUFFER
                call    DMACOM              ;GET READY FOR DMA XFER
                push    psw                 ;CURRENT CONTENTS OF LOCCONT REGISTER
                ani     07FH                ;SET BIT 7 LOW LEAVE OTHERS UNCHANGED
                out     LOCCONTIO
                mvi     a,SYSSTATRD         ;READY TO DMA READ FROM HOST
                out     DMASTATIO           ;FIRE UP DMA (WE HANG TILL DONE)
                pop     psw
                out     LOCCONTIO           ;PUT BACK IN READ MODE SO WE CAN TALK TO NEC
                ei
;
MMLOOP1:        lxi     d,MMDEST            ;HOST DESTINATION
                lxi     h,MISCBUF           ;USE OUR LOCAL SCRAP BUFFER
                call    DMACOM              ;GET READY FOR DMA XFER
                mvi     a,SYSSTATWR         ;READY TO WRITE TO HOST
                out     DMASTATIO           ;FIRE UP DMA (WE HANG TILL DONE)
                ei
                dcr     c
                jnz     MMLOOP              ;IF MORE BLOCKS TO XFER
                ret

; DFMD - Define Memory Disk
; Parameters:
;        P1 = byte:        Upper 8 bits of 24-bit address of START of RAMDISK.
;        P2 = byte:        Upper 8 bits of 24-bit address of END of RAMDISK.
;        P3-P8         :   Repeat P1,P2 for block 1, block 2 and block 3.
;        P9 = byte:        Length of RAMDISK O/S block.
;        P10-N         :   O/S block
;        P(N+1) byte:      Init mode (0=No init on boot, -1=Force init RAMDISK, 1=Init on first boot)
; Description:
;        Describes RAMDISK configuration to be used.
DEFMEMD:
                lxi     h,MD$LEP            ;START ADDRESS OF LEN/END STUFF
                mvi     b,8                 ;FOUR GROUPS OF 2 BYTES EACH
                call    GC                  ;GET THOSE 8 BYTES
                call    HDT3                ;GET LEN OF OS BLOCK & THEN OS BLOCK
                lxi     h,MD$INT$FLG
                rst     GETHOST             ;FETCH REQUEST FROM HOST
                ora     a
                rz                          ;IF NOT TO INIT MEMORY
                jm      DMD1                ;IF TO INIT DESPITE FLAG
                mov     a,m                 ;FETCH MEM-DISK-ALLREADY-BEEN-INIT FLAG
                ora     a
                rnz                         ;IF NOT FIRST TIME, WD DONT KILL EXISTING MEM-DISK
DMD1:           mov     m,h                 ;SET MEM-... FLAG
;
;        INIT PUTS 0E5H IN ENTIRE FIRST 64K (ENTIRE DIRECTORY WOULD BE ENOUGH)
;        THIS WORKS JUST FINE FOR CP/M
;
                lxi     h,MISCBUF           ;NOTE: WE DEPEND UPON MISCBUF=XX80H
DMD2:           mvi     m,0E5H
                inr     l
                jnz     DMD2                ;IF ALL MISCBUF NOT FILLED WITH E5'S
                mov     h,l                 ;(ZERO)
                shld    MMDEST              ;ZERO LO&HI BYTES OF THIS 3-BYTE AREA
                lda     MD$LEP              ;EXTENDED ADDRESS BITS OF FIRST MEM DISK AREA
                sta     MMDEST+2
                mov     b,h                 ;ZERO COUNTER FOR 256 128-BYTES BLOCKS TO FILL
                call    DMD3                ;FILL FIRST 32K
;               ...                         ;FALL INTO ROUTINE FOR LAST 32K
DMD3:           mvi     c,1                 ;SET TO MAKE MMLOOP EXIT AFTER WRITE
                call    MMLOOP1             ;FILL BLOCK
                dcr     b
                jnz     DMD3                ;IF MORE BLOCKS TO WRITE
                ret
;
;        MD$FMT
;
MD$FMT:         jz      HARD$FMT            ;IF HARD DISK
;
;        THE ONLY FORMAT OPCODE MD$FMT RESPONDS TO IS THE "SHOW ME"
;        OPCODE.  SO WE DONT EVEN CHECK.
;
                lda     MD$LOSB             ;LENGTH OF OPERATING SYSTEM BLOCK
                adi     10                  ;INIT FLG +1, LEN/END BYTES +8, LEN OS BLK +1
                mov     e,a                 ;SET FOR INBUFREAD3
                lxi     h,MD$INT$FLG        ;SEND FROM HERE
                jmp     GETDPB2             ;TRANSFER TO HOST -- <D>=1 THEN JMP INBUFREAD3
;
;        MD$READ & MD$WRITE
;
MD$READ:
                jz      HARD$READ           ;IF HARD DISK
                call    MD$COM
                dcx d ! dcx d               ;= LXI D,MD$ADRS
                lxi     h,MISCBUF
                mvi     c,1                 ;TRANSFER ONLY ONE 128-BYTE BLOCK
                call    DMAREAD1
                lxi     h,MISCBUF
                jmp     INBUFREAD1          ;TRANSFER TO HOST (ALWAYS LENGTH 80H)
;
MD$WRITE:
                jz      HARD$WRITE          ;IF HARD DISK
                lxi     h,MISCBUF
                call    INBUFWRITE1         ;GET DATA FROM HOST (LENGTH = 0080H)
                call    MD$COM              ;FORM ADDRESS OF MEMORY DISK BLOCK
                dcx d ! dcx d               ;= LXI D,MD$ADRS
                lxi     h,MISCBUF
                mvi     c,1                 ;TRANSFER ONLY ONE 128-BYTE BLOCK
                jmp     DMAWRITE1           ;TRANSFER TO MEMORY DISK
;
;        MD$COM        -- SET MEMORY DISK ADDRESS INTO MD#ADRS
;
;        ERROR CHECKING (RANGE CHECKING) IS NOT DONE TO SAVE TIME
;
MD$COM:         lxi     d,MMFROM
                lhld    SEEKTRK
                dad h ! dad h ! dad h ! dad h ! dad h
                lda     SEEKSEC
                rrc
                mov     b,a
                ani     80H
                stax    d                   ;LOW ADDRESS TO MD$ADRS
                inx     d
                xra     b                   ;REMOVE ODD SECTOR BIT FROM SIGN POSN
                add     l                   ;SAME AS "ORA L" IF GOOD SEC #
                stax    d                   ;HIGH ADDRESS TO MD$ADRS
                inx     d                   ;<DE> READY FOR EXTENDED ADRS PART OF MD$ADRS
                mov     a,h                 ;EXT ADRS BEFORE ADD OF MEM DISK BASE
                mvi     b,4                 ;NUMBER OF GROUPS OF (BASE, LAST BLOCK + 1)
                lxi     h,MD$LEP            ;ADRS OF FIRST BASE (BASE, LAST BLOCK + 1) GROUP
MDCOM1:         add     m                   ;ADD BASE
                inx     h
                stax    d                   ;EXTENDED ADDRESS TO MD$ADRS
                sub     m                   ;LESS (LAST BLOCK + 1)
                rc                          ;IF ADRS JUST STORED IS CORRECT
                inx     h
                dcr     b
                jnz     MDCOM1              ;IF MORE GROUPS
                ret                         ;IF OFF END WE DONT TELL

;        DMAREAD  -- DO l28-BYTE DMA READ FROM S100 HOST
;        DMAWRITE -- DO 128-BYTE DMA WRITE TO S100 HOST
;
;        BOTH ENTRY POINTS USE THE HOST-SPECIFIED DMA ADDRESS
;        (BUT SEE NOTE ON REGISTER <DE> BELOW)
;
;        ENTRY:        <HL>        OUR OWN LOCAL RAM ADDRESS FOR USE IN TRANSFER
;                                        (NOTE: THE LOW 7 BITS OF <L> ARE IGNORED,
;                                         BUT SHOULD BE ZERO)
;
;                      <DE>        POINTS TO LOW-ORDER BYTE OF 3-BYTE S100 ADDRESS
;                                        (THIS REGISTER IS ONLY SPECIFIABLE IF CALLER USES
;                                         THE DMAREADl OR DMAWRITEl ENTRY POINTS)
;
;        EXIT:        JOB DONE
;                        <HL> & <BC> UNCHANGED
;                        <DE> IS INCREASED BY 2 (POINTS TO EX BYTE OF HOST ADDRESS)
;
;        NOTE:        THE S100 DMA ADDRESS IS ARRANGED IN OUR LOCAL RAM
;                        AS "DB LO,HI,EX"
;
;        NOTE AGAIN: DMAREAD RETURNS VIA GETGENSTAT. DMAREADl RETURNS NORMALLY.
;
DMAREAD:
                lxi     d,GETGENSTAT        ;** FORCE RETURN TO SEND
                push    d                   ;** GENERAL STATUS
                call    DMACOMA
DMAREAD1:
                call    DMACOM              ;GET READY FOR DMA TRANSFER
                push    psw                 ;CURRENT CONTENTS OF LOCCONT REGISTER
                ani     07FH                ;SET BIT 7 LOW LEAVE OTHERS UNCHANGED
                out     LOCCONTIO
                mvi     a,SYSSTATRD
                out     DMASTATIO           ;FIRE UP DMA (WE HANG TILL DONE)
                dcr     c
                jnz     DMAREAD1            ;IF MORE BLOCKS TO XFER
                pop     psw
                out     LOCCONTIO           ;PUT BACK IN READ MODE SO WE CAN TALK TO NEC
                ei
                ret

DMAWRITE:
                call    DMACOMA
DMAWRITE1:
                call    DMACOM              ;GET READY FOR DMA TRANSFER
                mvi     a,SYSSTATWR
                out     DMASTATIO           ;FIRE UP DMA (WE HANG TILL DONE)
                dcr     c
                jnz     DMAWRITE1           ;IF MORE BLOCKS TO XFER
                ei
                ret
;
;        DMACOM, DMACOMA -- COMMON CODE FOR DMAREAD & DMAWRITE
;
DMACOMA:
                mov     c,d                 ;# OF 128-BYTE BLOCKS TO XFER
                xchg
                lda     SEEKDMALO           ;** FETCH 24-BIT
                lhld    SEEKDMAHi           ;** HOST ADDRESS
                shld    MMFROM+1            ;HOST ADDRESS TO WORK AREA
                lxi     h,MMFROM
                mov     m,a                 ;HOST ADDRESS TO WORK AREA
                xchg
                ret

DMACOM:
                push    d
                di                          ;KEEP F.D. INTS FROM MESSING UP DMA XFER
;
;        FIRST SETUP HOST ADDRESS
;
                ldax    d
                inx     d
                sui     1                   ;REAL SYSDMA STUFF IS 1HIGHER THAN LOADED
                out     SYSDMALOIO          ;SETUP S100 DMA ADDRESS BITS 7-0
                ldax    d
                inx     d
                sbi     0
                out     SYSDMAHIIO          ;SETUP S100 DMA ADDRESS BITS 15-8
                ldax    d
                sbi     0
                out     SYSDMAEXIO          ;SETUP S100 DMA ADDRESS BITS 23-16
;
                call    MM80                ;BUMP HOST ADDRESS FOR NEXT TIME
                xchg                        ;(MM80 DOES NOT 'XCHG' BACK)
;
;        NOW SETUP LOCAL ADDRESS
;
                mov     a,l
                out     LOCDMALOIO
                mov     a,h
                out     LOCDMAHIIO
                lxi     d,0080H
                dad     d
                pop     d                   ;RESTORE ADRS OF HOST ADDRESS BYTES
                lda     CURLCONT
                ret

MM80:
                xchg
                dcx     h
                dcx     h                   ;FORM ADDRESS OF LOW BYTE OF HOST ADDRESS
                mov     a,m
                adi     80H
                mov     m,a
                rnc                         ;IF WE DONT HAVE TO DO CARRY STUFF
                inx     h
                inr     m                   ;CARRY TO HI BYTE
                rnz                         ;IF NO CARRY TO EX
                inx     h
                inr     m                   ;CARRY TO EX BYTE
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   18.         BLOCK TRANSFER TO/FROM HOST AND RELATED STUFF
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;
;        BUFCHK -- CHECK IF GIVEN PHYSICAL SECTOR IS IN MAIN BUFFER
;
;                RETURNS CARRY SET IF FOUND
;                RETURNS <HL> POINTING TO TAG BYTE
;
BUFCHK:
                lda     CPS$SECTOR
                mov     l,a
                dcr     l
                mvi     h,BUFTAG/100H       ;<HL> = ADDRESS OF BUFFER FLAG BYTE
                mov     a,m
                add     a                   ;MOVE VALID BIT TO CARRY (READTAG=80H)
                ret
;
;        INBUFREAD -- SEND DATA FROM MAIN BUFFER AREA TO HOST
;
;                USES CPS$BUFADR
;
INBUFREAD:
                lhld    CPS$PSECT
                dad     h                   ;<HL> = # OF 128-BYTE BLOCKS TO TRANSFER
                xchg
                lhld    CPS$BUFADR
                lda     PFIOFLAG
                ora     a
                jnz     INBUFREAD2          ;IF DOING PHYSICAL MODE I/O
INBUFREAD1:
                mvi     d,01                ;ELSE...USE LOGICAL SECTOR LENGTH
INBUFREAD2:
                xra     a
                sta     GENSTAT             ;STATUS FOR SECTOR IS GOOD OR WE DONT GET HERE
                lda     MODE
                add     a
                jm      INBUFREAD3A         ;IF DOING BOOT
                jc      DMAWRITE            ;IF DMA MODE GO WRITE TO HOST
INBUFREAD3A:
                mvi     e,80H
INBUFREAD3:
                in      SYSSTATIO
                ani     SYSOUTSTAT
                jnz     INBUFREAD3          ;IF HOST HAS NOT TAKEN LAST BYTE
                mov     a,m
                out     SYSDATOUTIO         ;SEND DATA BYTE TO HOST
                inx     h
                dcr     e
                jnz     INBUFREAD3          ;IF MORE BYTES TO SEND TO HOST
                dcr     d
                jnz     INBUFREAD3A         ;IF MORE BYTES TO SEND TO HOST
INBUFREAD4:
                in      SYSSTATIO
                ani     SYSOUTSTAT
                jnz     INBUFREAD4          ;IF HOST HAS NOT YET TAKEN OUR LAST BYTE
                ret

;
;        INBUFWRITE  -- ACCEPT DATA FROM HOST FOR MAIN BUFFER AREA
;
;        ENTRY:        <HL> POINTS TO BUFFER TAG BYTE
;
;        USES: CPS$BUFADR
;
SEQWRITE:       call    BUFCHK              ;SPECIAL ENTRY FOR SEQUENTIAL WRITE (RWTYPE=2)
INBUFWRITE:
                mov     a,m
                ori     WRITETAG+READTAG    ;MARK AS WRITTEN INTO
                mov     m,a
                lhld    CPS$PSECT           ;PHYSICAL SECTOR LENGTH
                dad     h                   ;<H> = # OF 128-BYTE BLOCKS TO TRANSFER
                xchg
                lhld    CPS$BUFADR
                lda     PFIOFLAG
                ora     a
                jnz     INBUFWRITE2         ;IF DOING PHYSICAL MODE I/O
INBUFWRITE1:
                mvi     d,01                ;ELSE...USE LOGICAL SECTOR LENGTH
INBUFWRITE2:
                xra     a
                sta     GENSTAT             ;STATUS FOR SECTOR IS GOOD OR WE DONT GET HERE
                lda     MODE
                add     a
                jm      INBUFWRITE3         ;IF DOING SYSWRT (CANT BE DMA)
                jc      DMAREAD             ;IF DMA MODE, GO GET DATA TO BE WRITTEN
INBUFWRITE3:
                xra     a                   ;SEND DUMMY GENERAL STATUS
                rst     PUTHOST             ;BEFORE TAKING DATA
INBUFWRITE4A:
                mvi     e,80H
INBUFWRITE4:
                in      SYSSTATIO
                rar
                jnc     INBUFWRITE4         ;IF HOST HAS NOT PRESENTED NEXT BYTE
                in      SYSDATINIO          ;ACCEPT BYTE FROM HOST
                mov     m,a                 ;STORE INTO BUFFER
                inx     h
                dcr     e
                jnz     INBUFWRITE4         ;IF MORE BYTES TO ACCEPT FROM HOST
                dcr     d
                jnz     INBUFWRITE4A        ;IF MORE BYTES TO ACCEPT FROM HOST
                ret
;
;        VBT -- VOID BUFFER TAGS
;
VBT:
                lxi     b,40H
                lxi     h,BUFTAG
VBT1:           mov     m,b
                inx     h
                dcr     c
                jnz     VBT1                ;IF MORE TAGS TO VOID
                ret

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   19.         SETUPS FOR PHYSICAL DISK CHANGE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;
;        MAKECUR -- MAKE THE CURRENT LOGICAL DEV IN SEEKDEV THE CURRENT DEVICE
;        MOVECUR -- UPDATES CUR LDT/PDT FROM TABLE AREA
;
MAKECUR:
                lda     SEEKDEV
                call    MLP
                jc      BADLU               ;IF BAD LOGICAL UNIT
                mov     c,a                 ;PHYS DEVICE CODE
                xthl
                cpi     18H
                jnc     C1A                 ;IF THIS DEVICE IS NOT FLOPPY DISK
                inx     h                   ;** ADJUST RTN ADRS PAST
                inx     h                   ;** 'NOT A FLOPPY' ADDRESS
                jmp     C1B
;
C1A:            mov     a,m                 ;> THIS DEVICE IS NOT A FLOPPY
                inx     h                   ;> SO WE PICK UP THE
                mov     h,m                 ;> 'NOT A FLOPPY' ADDRESS
                mov     l,a                 ;> AND PUT INTO <HL>
C1B:            xthl                        ;RTN ADRS TO STACK
                lda     CURPHYSDEV          ;CURRENT PHYS DEVICE
                cmp     c
                jz      MAKECX              ;IF NO DEVICE CHANGE
                call    FWT                 ;ELSE...FORCE WRITE TAGS
;
;        WE MIGHT BE ABLE TO KEEP THE READ TAGS .... BUT FOR NOW, THEY GO
;
                lxi     h,BUFTAG
                lxi     b,40H               ;<B>=0, <C>=LENGTH OF BUFFER TAGS
MAKEC1:         mov     m,b                 ;ZERO IN-BUFFER TAGS
                inx     h
                dcr     c
                jnz     MAKEC1              ;IF NOT ALL TAGS DONE
                lda     SEEKDEV
                call    MLP                 ;MAP LOGICAL TO PHYSICAL
                sta     CURPHYSDEV          ;POST CURRENT PHYSICAL DEVICE
                sta     WDDEV               ;<A>.NE.SEEKDEV -- USED IF HARD DISK
                sta     BUFSIDE             ;>1 TO KEEP FWT FROM ACTING UP
                shld    CURPDTADRS          ;CURRENT PHYSICAL DEVICE TABLE ADDRESS
                xchg
                shld    CURLDTADRS          ;CURRENT LOGICAL DEVICE TABLE ADDRESS
;
;        TEST AGAIN FOR FLOPPY...
;
;        IF FLOPPY, CHECK IF 8<==>5 CHANGE
;
                cpi     18H
                jnc     MOVCUR              ;IF NOT FLOPPY
;               ANI     4                   ;NON-ZERO IF 5" FLOPP (DONT NEED TO EXECUTE)
                ral ! ral ! ral
                lxi     h,CURLCONT
                xra     m
                ani     20H
                jz      MOVCUR              ;IF NO 8/5 CHANGE
                xra     m                   ;FORM ORIG CURLCONT WITH 8/5 BIT CHANGED
;               ANI     NOT 40H             ;DROP HEAD LOAD BIT (MAKES 'LOAD' SET TIMERS)
                di                          ;DI/EI REQ'D TO AVOID INT AFTER STORE & B4 'OUT'
                mov     m,a                 ;UPDATE CURLCONT
                out     LOCCONTIO           ;TELL DISK ABOUT CHANGE
;
;        NOW WAIT 16 MS FOR NEC 765 TO RECOVER FROM CLOCK CHANGE
;
                lxi     b,167*16            ;DELAY TIME: 16 MS = 16 * 167 MS PER LOOP
MCDELAY:        dcx     b                   ; 6 <== T-STATES PER LOOP
                mov     a,b                 ; 4
                ora     c                   ; 4
                jnz     MCDELAY             ;10 IF MORE TIME TO BURN WAITING FOR OUR NEC765
;                                           ---
;                                            24 T-STATES/LOOP or 4000/24=167 LOOPS PER MS
                mov     a,m
                ani     NOT 40H             ;KK DROP HEAD LOAD BIT (MOVED FROM ABOVE)
                mov     m,a                 ;KK (NOW HEADS DON'T UNLOAD AT 5<==>8 CHANGE)
;
                ei                          ;NOW WE GET OUR 'READY CHANGE' INTS
;
;KK             CALL    DOSPEC              ;ISSUE SPECIFY COMMAND UNCONDITIONALLY AT
;KK                                         ;..MOVCUR BECAUSE OF INDIVIDUAL STEP RATES
;
;        SET ALL "MUST RECALLABRATE" BITS
;        SET ALL MEDIA CHANGE CONDITIONS TO "DONT KNOW"
;
                lxi     h,PDTFINDERS
                mvi     c,8                 ;LOOP COUNTER (ALL 8" + ALL 5")
MAKEC1B:        mov     e,m
                inx     h
                mov     d,m                 ;<DE> = PDT ADDRESS
                inx     h
                inx d ! inx d               ;FORM ADDRESS OF PDT FLAGS BYTE
                ldax    d
                ani     NOT 03              ;CLEAR MEDIA CHANGE CONDITIONS
                ori     81H                 ;"MUST RECAL" BIT (80H) + "DONT KNOW" (01H)
                stax    d
                dcr     c
                jnz     MAKEC1B             ;IF MORE TO DO
                ei                          ;EI ONLY AFTER ALL FLAGS BYTES CHANGED
;
MOVCUR:
                call    DOSPEC              ;KK ISSUE SPECIFY COMMAND
;
;        MOVE HEAD OF PDT
;
                lxi     d,CURPDT
                lhld    CURPDTADRS
                mvi     b,LENPDTH           ;LENGTH OF PDT HEADER
MAKEC3:         mov     a,m
                stax    d                   ;MOVE (FIRST PART OF) PDT TO CURPDT
                inx     h
                inx     d
                dcr     b
                jnz     MAKEC3              ;IF MORE PDT TO MOVE
                mvi     c,NFMT8
                lda     CURPHYSDEV
                ani     4
                jz      MAKEC4              ;IF WORKING ON 8" FLOPPY
                mvi     c,NFMT5
MAKEC4:         dad     b                   ;FORM ADDRESS OF SKEW LIST
                shld    CURPDTSKEW          ;ADDRESS OF SKEW LIST IN PDT ENTRY
MAKECX:
                lda     CURPHYSDEV          ;KK
                call    GETFPYTAB           ;KK <HL> RETURNED WITH ^FLOPPY_TABLE_ENTRY
                shld    CURFPYTAB           ;KK SAVE FOR ANYONE
                lxi     d,RAMDPBSKEW
                xra     a
                stax    d                   ;KK NUL RAMDPB SKEW
                mov     a,m                 ;KK VALID RADPB?
                push    psw                 ;KK SAVE FOR LATER
                ral
                jnc     MAKECX1             ;KK NO, LEAVE RAMDPBSKEW INVALID
                lxi     b,6                 ;KK OFFSET TO SKEW IN FPYTAB
                dad     b
                mov     a,m
                stax    d                   ;KK IS VALID, SAVE
MAKECX1:
                pop     psw                 ;KK FPYFLAGS, SEE IF NEC NEEDS TO BE DOUBLED
                mov     e,a                 ;KK COPY FOR ANDing
                xri     10H                 ;KK IF (NOT DOUBLESTEP)
                rlc
                ana     e                   ;KK AND (96 TPI)
                ani     20H
                jz      MAKECX2
                lhld    CURPDTADRS          ;KK THEN (CYLINDERS = CYLINDERS * 2)
                lxi     d,PDTNBC            ;KK OFFSET TO NUMBER OF CYLINDERS
                dad     d
                mov     a,m
                add     a                   ;KK *2
                sta     CURPDTNBC           ;KK SAVE IN CURRENT TABLE
MAKECX2:
                lda     CURPHYSDEV
                ani     4                   ;SET PHY DEV TYPE INTO PSW:
;                            FLOPPY EXIT    ALT EXIT
;                            -----------    --------
;               JZ             8" FD        HARD DSK
;               JNZ            5" FD        MEM DSK
                ret

BADLU:
                mvi     a,10H               ;EC=BAD LOGICAL UNIT
                jmp     BEGINGENSTAT        ;SET GENSTAT & RESETS LOCAL STACK

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   20.         LOGICAL/PHYSICAL DEVICE SUBROUTINES
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;
;        MLP --- MAP LOGICAL TO PHYSICAL
;
;        ENTRY:       <A>  = LOGICAL DEVICE NUMBER
;
;        EXIT:        <A>  = FIRST PHYSICAL DEVICE NUMBER
;                     <BC>        UNCHANGED
;                     <DE> = LOGICAL DEVICE TABLE ADDRESS
;                     <HL> = FIRST PHYSICAL DEVICE TABLE ADDRESS
;
MLP:
                cpi     10H                 ;CARRY SET IF LOGICAL DEVICE = 00H..0FH
                cmc
                rc                          ;IF LOGICAL DEVICE NUMBER IS INVALID
                mov     l,a
                add     a                   ;*2
                add     a                   ;*4
                add     a                   ;*8
                sub     l                   ;*7
                mov     l,a
                mvi     h,0
                lxi     d,LOGDEVTBL
                dad     d                   ;<HL> = ADDRESS OF GIVEN LOGICAL DEVICE TABLE
                mov     a,m                 ;FIRST PHYSICAL DEVICE NUMBER
                cpi     1                   ;DO WE HAVE ANY PHYSICAL DEVICE?
                rc                          ;IF LOG DEV HAS NO PHYS DEVICE, EXIT WITH CARRY
                push    h
                mov     e,a
                mvi     d,0
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADDRESS OF PHYSICAL DEVICE FINDER
                mov     e,m
                inx     h
                mov     d,m
                xchg                        ;<HL> = ADDRESS OF FIRST PHYS DEV TABLE
                pop     d                   ;<DE> = ADDRESS OF GIVEN LOGICAL DEVICE TABLE
                ret                         ;NOTE: CARRY IS RESET BY "DAD"

;
; DLDS - Define Logical Device Set
; Parameters:
;        P1 = byte: Logical device number 00h-0Fh
;        P2 = byte: Physical device number 10h-1Ch
; Description:
;        The mapping from logical device to physical device may be changed.
DLDS:
                rst     GETHOST
                mov     c,a                 ;SAVE LOGICAL DEVICE NUMBER
                cpi     10H
                rnc                         ;IF INVALID LOGICAL DEVICE NUMBER
                call    KLD                 ;KILL (CURRENT) LOGICAL DEVICE
                mov     a,c
                call    MLP                 ;MAP LOGICAL TO PHYSICAL
                                            ;NOTE: MAPPING FAILS, BUT <HL>=LDT ADDRESS
DLDS1:          rst     GETHOST             ;GET PHYS DEVICE FROM HOST
                mov     b,a
                ani     7FH                 ;DROP NOT-THE-LAST-ONE FLAG
                cpi     10H
                rc                          ;IF INVALID PHYSICAL DEVICE NUMBER
                cpi     1DH                 ;1D = MAX PHYS DEV + 1
                rnc                         ;IF INVALID PHYSICAL DEVICE NUMBER
                mov     m,a                 ;1ST PHYS DEVICE TO LDT -OR- FORWARD THREAD PDT
                call    KPD                 ;KILL PHYSICAL DEVICE

                mov     a,c                 ;LOGICAL DEVICE
                call    MLP                 ;MAP LOGICAL DEVICE TO PHYSICAL
                rc                          ;IF MLP FAILS WE MUST HAVE
                                            ;JUST KILLED OUR OW LDT WITH KPD

                mov     a,b                 ;HOST SPECIFIED PHYSICAL DEVICE CODE
                ani     7FH                 ;DROP "TO-BE-CONTINUED" BIT
                mov     e,a
                mvi     d,0
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADDRESS OF PHYSICAL DEVICE FINDER
                mov     e,m
                inx     h
                mov     d,m
                xchg                        ;<HL> = ADDRESS OF PHYSICAL DEVICE TABLE
                mov     m,c                 ;STORE LOGICAL DEVICE NUMBER INTO PDT

                cmp     b
                rz                          ;IF WE HAVE JUST DONE THE LAST DEVICE
                inx     h                   ;FORM ADDRESS OF PLACE FOR PDT FORWARD THREAD
                jmp     DLDS1               ;GO AFTER THE NEXT PHYSICAL DEVICE

;
; GLDS - Get Logical Device Set
; Parameters:
;        P1 = byte: Logical device number 00h-0Fh
; Results:
;        byte: Physical drive number that is mapped to logical device.
; Description:
;        Return current assignment of physical device to the specific logical device.
GLDS:           rst     GETHOST
                call    MLP                 ;MAP LOGICAL DEVICE TO PHYSICAL DEVICE
                jc      GLDS2               ;IF LOGICAL DEVICE IS ILL-FORMED OR EMPTY
                mov     b,a                 ;PHYSICAL DEVICE CODE
GLDS1:          inx     h
                mov     a,m                 ;NEXT PHYSICAL DEVICE
                ora     a
                jz     GLDS3                ;IF LAST PHYSICAL DEVICE
                mov     c,a                 ;SAVE NEXT PHYSICAL DEVICE FOR NEXT TIME
                mov     a,b
                ori     80H
                rst     PUTHOST
                mov     b,c
                mov     e,c
                mvi     d,0
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADDRESS OF PHYSICAL DEVICE FINDER
                mov     e,m
                inx     h
                mov     d,m
                xchg                        ;<HL> = ADDRESS OF (NEXT) PHYS DEVICE TABLE
                jmp     GLDS1

GLDS2:          mvi     b,0                 ;RETURN ZERO AS "NO DEVICE" INDICATION
GLDS3:          mov     a,b                 ;LAST DEVICE IN THREAD
                jmp     SENDCHAR

;
; KPD -- KILL PHYSICAL DEVICE
;
;        ENTRY:        <A> = PHYSICAL DEVICE NUMBER
;
;        EXIT:        ALL PHYSICAL DEVICES IN LOGICAL DEVICE SET
;                        CONTAINING GIVEN PHYSICAL DEVICE ARE KILLED
;
KPD:            cpi     10H
                rc                          ;IF INVALID PHYSICAL DEVICE NUMBER
                cpi     1DH                 ;1D = MAX PHYS DEV + 1
                rnc                         ;IF INVALID PHYSICAL DEVICE NUMBER
                mov     e,a
                mvi     d,0
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADDRESS OF PHYSICAL DEVICE FINDER
                mov     e,m
                inx     h
                mov     d,m                 ;<DE> = ADDRESS OF PHYSICAL DEVICE TABLE
                ldax        d               ;FETCH LOGICAL DEVICE NUMBER
;               ...
;               ...                         NOTE: WE NOW FALL INTO KLD
;               ...

;
; KLD -- KILL LOGICAL DEVICE
;
;        ENTRY:        <A> = LOGICAL DEVICE TO KILL
;
;        EXIT:        JOB DONE
;                        LDT 1ST PHYSICAL DEVICE ZEROED
;                        FOR EACH PHYSICAL DEVICE IN LOGIAL DEVICE THREAD
;                          PDT LOGICAL DEVICE NUMBER = 0FFH
;                          PDT "NEXT PHYS DEVICE" POINTER = 0
;
KLD:            call    MLP                 ;MAP LOGICAL TO PHYSICAL
                rc                          ;IF NO PHYSICAL DEVICE
                xra     a
                stax    d                   ;KILL LDP POINTER TO 1ST PHYSICAL DEVICE
KLD1:           mvi     m,0FFH              ;KILL LOGICAL DEVICE NUMBER IN PDT
                inx     h                   ;<HL> NOW POINT TO NEXT PHYS DEV IN PDT
                cmp     m
                rz                          ;IF NO NEXT PHYS DEVICE, THEN EXIT
                mov     e,m                 ;ELSE...FORM NEXT PDT ADDRESS
                mov     d,a                 ;(ZERO)
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADDRESS OF PHYSICAL DEVICE FINDER
                mov     e,m
                inx     h
                mov     d,m
                xchg                        ;<HL> = ADDRESS OF NEXT PHYS DEV TABLE
                jmp     KLD1

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   21.         SET AND USE RETRY COUNTERS
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

SRC:
                lhld    SEEKRETRY1          ;SETUP RETRY LOGIC COUNTERS
                shld    RETRYC1             ;SETUP RETRY LOGIC COUNTERS
                mvi     a,3                 ;SETUP RETRY LOGIC COUNTERS
                sta     RETRYC3             ;SETUP RETRY LOGIC COUNTERS
                ret

;
; RWRETRY -- READ/WRITE RETRY
;
;        CALLED AFTER EACH READ OR WRITE OPERATION LIKE THIS:
;
;        CALL    RWRETRY
;        DW      XYZZY                      ;RETRY ADDRESS
;        JZ      OK                         ;IF NO ERROR
;        JNZ     FAILURE                    ;IF ALL RETRY HAS FAILED
;
;        NOTE:        WHEN ERROR RETRY FAILS CONTROL GOES BACK TO IDLE LOOP
;
RWRETRY:
                xthl
                mov     e,m
                inx     h
                mov     d,m                 ;<DE> = RETRY ADDRESS
                inx     h
                xthl                        ;<TOP OF STACK> = NO ERROR RETURN ADDRESS
                lda     GENSTAT
                ora     a
                rz                          ;IF NO ERROR TO RECOVER
                pop     b                   ;** CHANGE RETURN ADDRESS TO
                push    d                   ;** GO TO RETRY POINT
                lxi     h,RETRYC1
                dcr     m
                rp                          ;IF BASIC RETRY COUNTER NOT EXPIRED
                lda     SEEKRETRY1          ;ELSE...RESTORE BASIC
                mov     m,a                 ;       RETRY COUNTER
                inx     h                   ;AND THEN TRY MORE EXOTIC RETRY METHODS
                dcr     m                   ;<HL>=ADRS OF RETRYC2
                jp      RWR2                ;IF TO DO SEEK RETRY...
                pop     d                   ;$$ ...ELSE ALL RETRY HAS FAILED
                push    b                   ;$$ GO BACK TO MAIN RETURN
                ret                         ;$$ WITH PSW NON-ZERO CONDITION
;
RWR1:
                mvi     m,3                 ;RESET SEEK STATE VALUE
RWR2:
                lda     CURPDTNBC           ;NUMBER OF CYLINDERS
                mov     c,a                 ;...FOR USE LATER
                lxi     h,RETRYC3
                dcr     m
                jm      RWR1                ;IF TO RESET STATE VALUE
                mov     a,m
;KK             LHLD    CURPDTADRS          ;KK NO,NO!
;KK             INX     H                   ;KK THIS IS CALCULATED (IF 48TPI IN 96TPI
;KK             INX     H                   ;KK UNIT THEN TRACK:= TRACK *2)
;KK             INX     H                   ;<HL> = ADRS OF CURRENT CYLINDER NUMBER
                dcr     a
                lxi     h,RTRY$TRACK        ;KK USE UNCALC CYLINDER FOR RETRY INSTEAD
;
;        AT THIS POINT:
;
;        IF...           THEN...
;
;        <A> =  1        SEEK UP ONE TRACK
;        <A> =  0        FORCE RECAL
;        <A> = -1        SEEK DOWN ONE TRACK
;
                jz      SEEK1               ;IF TO DO RECAL
                add     m                   ;1 OR -1 PLUS CUR CYL = WANTED CYL
                sub     c                   ;<C> = NUMBER OF CYL
                jnc     RWR2                ;IF NO SUCH CYLINDER
                add     c                   ;RESTORE DESIRED CYLINDER
                jmp     SEEK1

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   22.         SET SKEW (HOST CALL)
;               BUILD FLOPPY SKEW TABLE, SET SECTOR OFFSETS
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

;
; SETSKEW -- SET SKEW BYTE INTO DEVICE TABLE
;
;        HOST CALL:
;
;                08 OMNI COMMAND CODE
;                WW LOGICAL (OR PHYSICAL) DEVICE
;                XX SECTOR LENGTH CODE + DENSITY
;                        BYTES/SECTOR - 2**(SECTOR LENGTH CODE + 7)
;                        ie CODES 0,1,2,3 SPECIFY 128,256,512,1024 BYTES/SECTOR
;                        DENSITY: ADD 40H FOR DOUBLE DENSITY
;                YY NUMBER OF SECTORS (OR ZERO TO ACCEPT FIRST XX MATCH)
;                ZZ DESIRED SKEW FACTOR (OR ZERO TO RESTORE DEFAULT)
;
;        RESPONSE IS LEFT IN GENERAL STATUS --
;                0: GOOD
;                1: BAD DEVICE (NOT FLOPPY DISK)
;                2: UNKNOWN FORMAT
;                3: BAD SKEW FACTOR
;
SETSKEW:
                lxi     h,SSPU
                call    GC4                 ;GET PARAMETERS
                mvi     c,1                 ;ERROR CODE FOR BAD LOGICAL/PHYICAL DEVICE
                lda     SSPU
                cpi     10H
                cc      MLP                 ;MAP LOGICAL TO PHYSICAL
                jc      SSEXIT              ;IF NOT A GOOD LOGICAL DEVICE
;
;        AT THIS POINT <A> = PHYSICAL DEVICE CODE
;
                cpi     18H
                jnc     SSEXIT              ;IF NOT ONE OF OUR EIGHT FLOPPY DEVICES
                mov     e,a
                mvi     d,0                 ;<DE> = PHYSICAL DEVICE CODE
                lxi     h,PDTFINDERS-20H
                dad     d
                dad     d                   ;<HL> = ADRS OF PHYSICAL DEVICE TABLE ADDRESS
                mov     e,m
                inx     h
                mov     d,m                 ;<DE> = PHYSICAL DEVICE TABLE ADDRESS
                lxi     h,LENPDTH
                dad     d                   ;<HL>=ADRS OF ZEROth SKEW BYTE IN PDT
                xchg                         ;ADDRESS OF THAT SKEW BYTE TO <DE>

;        8 OR 5 INCH? FIND OUT AND SETUP FOR FDREL SCAN

                cpi     14H                 ;(REMEMBER, <A> = PHYS DEVICE CODE)
                mvi     b,8                 ;SET FOR 8" FLOPPY
                lxi     h,STD8
                jc      SS1                 ;IF WE ARE WORKING ON 8"
                mvi     b,5
                lxi     h,STD5
SS1:
;
;        <HL> = FIRST RELATIONSHIP TABLE ADDRESS FOR DESIRED FD SIZE
;
;        FINISH SETUP FOR FDREL SCAN
;
                lda     SSDL
                mov     c,a
                ani     40H                 ;ISOLATE DENSITY
                ora     b                   ;MERGE WITH FD SIZE
                mov     b,a                 ;SAVE FOR SCAN
                mov     a,c
                ani     NOT 40H             ;ISOLATE SECTOR LENGTH
                mov     c,a                 ;SAVE FOR SCAN
;
;        SCAN FDREL LOOKING FOR GIVEN FLOPPY DISK FORMAT
;
SS2:
                mov     a,m                 ;FDREL DENS/SIZE
                inx     h
                cmp     b
                jnz     SS4                 ;IF WRONG DENSITY OR SIZE
                mov     a,m                 ;FDREL SECTOR LENGTH CODE, "N" LEN=(N+7)**2
                inx     h
                cmp     c
                jnz     SS3                 ;IF WRONG SECTOR LENGTH
                lda     SSNS                ;SECTORS/TRACK FROM HOST
                ora     a
                jz      SS5                 ;IF "DONT CARE" ON SECTORS/TRACK
                cmp     m
                jz      SS5                 ;IF NUMBER OF SECTORS ALSO MATCHES
SS3:            dcx     h
;
;        AT THIS POINT <HL>=ADRS OF SECOND BYTE IN FDREL ENTRY
;
SS4:            inx     d                   ;BUMP TO NEXT SKEW BYTE ADDRESS
                push    d
                lxi     d,LENFDREL-1
                dad     d                   ;<HL> = ADRS OF HEAD OF NEXT SLOT
                pop     d
                mov     a,m
                ora     a
                jp      SS2                 ;IF NOT AT END OF FDRELTAB WE TRY NEXT SLOT
                mvi     c,2                 ;ERROR CODE FOR "UNKNOWN DENSITY"
                jmp     SSEXIT
;
;        AT THIS POINT:
;
;        <HL> = ADRS OF SECTORS/TRACK IN DESIRED FDREL SLOT
;        <DE> = ADDRESS OF DESIRED SKEW BYTE
;
SS5:            lda     SSFACT              ;SKEW FACTOR FROM USER
                mvi     c,3                 ;ERROR CODE USED IF BAD SKEW FACTOR IS GIVEN
                cmp     m
                jnc     SSEXIT              ;IF HOST GIVEN SKEW .GE. SECTORS/TRACK
                ora     a
                jnz     SS6                 ;IF NOT TO USE DEFAULT SKEW
                inx     h
                inx     h
                inx     h                   ;<HL> NOW POINTS TO DEFAULT SKEW BYTE W/I FDREL
                mov     a,m                 ;SSFACT=0 ==> USE DEFAULT SKEW
SS6:            stax    d                   ;POST SKEW BYTE TO DEVICE TABLE
                mvi     c,0                 ;"GOOD" RESPONSE
SSEXIT:         mov     a,c
                sta     GENSTAT             ;ERROR CODE
                ret

;
; BSKEW -- BUILD SKEW TABLE
;
;        ENTRY:        <D>  = NUMBER OF SECTORS
;                      <E>  = SKEW FACTOR
;                      <HL> = ADDRESS AT WHICH TO START BUILDING TABLE
;
;        EXIT:        <DE> = UNCHANGED
;                     <HL> = ADVANCED PASTLAST ENTRY IN LIST
;
;        USES:        ALL
;
;        CALLS:        NONE
;
;        WORKS FOR ALL N (NUMBER OF SECTORS) 2..81H
;        WITH ALL S (SKEW FACTOR) 1..N-1
;
;        THIS CODE THEN FAILS BECAUSE OF 8-BIT ARITHMETIC
;
BSKEW:
                mov     c,d                 ;USED AS LOOP COUNTER
                xra     a                   ;1ST SECTOR # (1 ADDED AFTER STORE INTO LIST)
BSKEW1:
                mov     b,a                 ;ADJ AFTER WRAPAROUND IF ENTRY (WOULD) = <B>
BSKEW2:
                mov     m,a                 ;DROP ENTRY IN TABLE
                inr     m                   ;(BECAUSE SKEW LIST IS 1..N NOT 0..N-1)
                inx     h
                dcr     c
                rz                          ;IF ALL DONE
                add     e                   ; +SKEW FACTOR
                cmp     d
                jm      BSKEW2              ;IF NO WRAPAROUND
                sub     d                   ; -NUMBER OF SECTORS
                cmp     b
                jnz     BSKEW2              ;IF WRAPAROUND ADJUST IS NOT REQUIRED
;
;        WRAPAROUND ADJUST SECTION IS ONLY USED IN NUMBER OF SECTORS
;        AND SKEW FACTOR HAVE A COMMON DIVISOR.
;
                inr     a                   ;NEXT ITEM FOR LIST...
                jmp     BSKEW1              ;...IS NEXT ADJUST POINT

;
;        KK HOST CALL: SETDBB
;
;                24H OMNI COMMAND CODE
;                Pl LOGICAL (OR PHYSICAL) DEVICE
;                P2 FLAGS:
;           7         6         5         4       3         2         1         0
;        + ------- + ------- + ------- + ------:-------- + ------- + ------- + ------- +
;        |         |         |         |DOUBLE |         |         |         |         |
;        | RAM DBB |         | 96TBI   | STEP  |         |         |         |         |
;        |    IS   |         | UNIT    |(48TBI :         |2 SIDED  |         |         |
;        |  VALID  |         |(QUAD    |DISK IN:         |         |         |         |
;        |         |         | DENS)   | 96TPI):         |         |         |         |
;        + ------- + ------- + ------- + ------: ------- + ------- + ------- + ------- +
;
;                (BITS 4 AND 5 AFFECTED BY SETTBI ONLY)
;
;                P3 FDRELPOS
;                P4 SECTOR I.D. OFFSET FOR SIDE 0, SIGNED INTEGER
;                P5 SECTOR I.D. OFFSET FOR SIDE 1, SIGNED INTEGER
;                P6 SIDE I.D. OFFSET FOR SIDE 0, SIGNED INTEGER
;                P7 SIDE I.D. OFFSET FOR SIDE 1, SIGNED INTEGER
;                P8 SKEW (0= LEAVE ALONE)
;                P9 LENGTH OF DBB
;                P10..DPB
;
;        HOST CALL RESPONSE IS LEFT IN GENERAL STATUS --
;        0: GOOD
;        1: BAD DEVICE (NOT FLOPPY DISK)
;
SETRAMDPB:
                call    GETFPYHST           ;KK GET FLOPPY DEVICE FROM HOST
                push    psw                 ;KK IF BAD DEVICE THEN CY=1, SAVE
                call    GETFPYTAB           ;KK <HL> RETURNED WITH ^FPYTAB(<A>)
                pop     psw                 ;KK WAS IT A BAD DEVICE?
                push    psw
                jnc     SETRAMDPB1          ;KK NO
                lxi     h,MISCBUF           ;KK YES, TRASH INPUT
SETRAMDPB1:
                rst     GETHOST             ;KK GET FLAGS
                ani     NOT 30H             ;KK DON'T DESTROY TPI STATUS
                mov     b,a
                mov     a,m                 ;KK OLD FLAGS
                ani     30H
                ora     b
                mov     m,a
                inx     h
                mvi     b,6                 ;KK FDRELPOS,SECTOFF(2),SIDEOFF(2),SKEW
                call    GC
                rst     GETHOST             ;KK DPB SIZE
                cpi     21                  ;KK MAX DPB SIZE + 1
                jnc     SETDPBEX0           ;KK THIS COULD HANG BUT BETTER THAN CRASH
                ora     a
                jz      SETDPBEX0           ;KK IF ZERO LENGTH DPB
                mov     m,a                 ;KK SAVE LENGTH IN FPY TABLE
                inx     h
                mov     b,a                 ;KK COUNT FOR GC
                call    GC                  ;KK GET DPB
SETDPBEX0:
                pop     psw                 ;; ERROR = (CY = 1)
SETDPBEX:
                mvi     a,0
                ral                         ;KK IF CY THEN <A>:= 1
                sta     GENSTAT
                ret
;
;        PERFORM OPPOSITE OF ABOVE
;
GETRAMDPB:
                call    GETFPYHST           ;KK GET FLOPPY DEVICE FROM HOST
                jc      SETDPBEX            ;KK IF BAD DEVICE
                call    GETFPYTAB           ;KK <HL> RETURNED WITH ^FPYTAB(<A>)
                lxi     d,107H              ;KK FLAGS,FDRELPOS,SECTOFF(2),SIDEOFF(2),SKEW
                call    INBUFREAD3          ;KK SEND <E> BYTES TO HOST
                mov     a,m                 ;KK DPB SIZE
                rst     PUTHOST
                ora     a                   ;KK IF ZERO LENGTH
                jz     SETDPBEX             ;KK IF ZERO LENGTH DPB
                mov     e,a                 ;KK USE FOR COUNTER
                inx     h                   ;KK PAST DPB LENGTH
                mvi     d,1
                call    INBUFREAD3          ;KK SEND DPB
                ora     a                   ;KK CY:= NO ERROR
                jmp     SETDPBEX

;KK                HOST CALL: SETTPI
;KK
;KK                        28H        OMNI COMMAND CODE
;KK                        P1 BYTE    DEVICE#
;KK                        P2 BYTE    TPI (48. / 96.)
;KK
;KK                RETURNS:  NONE
;KK
;KK                SET TPI STATUS FROM HOST (48 OR 96 TPI, 48TPI DISK IN 96TPI UNIT)
;KK                STATUS IS IN FPYTAB FLAGS BYTE
;KK
SETTPI:
                call    GETFPYHST           ;KK GET FLOPPY DEVICE FROM HOST
                push    psw                 ;KK IF BAD DEVICE THEN CY=1, SAVE
                call    GETFPYTAB           ;KK <HL> RETURNED WITH ^FPYTAB(<A>)
                mov     a,m                 ;KK MASK TPI STATUS BITS
                ani     NOT 30H
                mov     b,a                 ;KK SAVE
                rst     GETHOST             ;KK GET NEW STATUS
                ani     30H                 ;KK WE WANT ONLY THESE
                ora     b                   ;KK COMBINE
                mov     b,a
                pop     psw                 ;KK WAS IT A BAD DEVICE?
                jc      SETDPBEx            ;KK EXIT WITHOUT UPDATING
                mov     m,b
                jmp     SETDPBEX
;KK
;KK                KK HOST CALL: GETTPI
;KK
;KK                        29H        OMNI COMMAND CODE
;KK                        P1 BYTE    DEVICE#
;KK
;KK                RETURNS: TPI CODE
;KK
;KK                SEND TPI STATUS TO HOST (48 OR 96TPI, 48TPI DISK IN 96TPI UNIT)
;KKK
GETTPI:
                call    GETFPYHST           ;KK GET FLOPPY DEVICE FROM HOST
                push    psw                 ;KK IF BAD DEVICE THEN CY=1, SAVE
                call    GETFPYTAB           ;KK <HL> RETURNED WITH ^FPYTAB(<A>)
                mov     a,m
                rst     PUTHOST             ;KK GIVE STATUS TO HOST
                pop     psw
                jmp     SETDPBEX
;KK
;KK                GET FLOPPY UNIT NUMBER FROM HOST
;KK                MAP TO PHYSICAL, RETURN CY=1 IF BAD DEVICE
;KK
GETFPYHST:
                rst     GETHOST             ;KK LOGICAL OR PHYSICAL DEVICE
                cpi     10H
                cc      MLP                 ;KK MAP LOGICAL TO PHYSICAL
                rc                          ;KK IF NOT GOOD LOGICAL DEVICE
                cpi     18H
                cmc
;                RC                         ;KK IF NOT ONE OF OUR EIGHT FLOPPY DEVICES
                ret                         ;KK AT THIS POINT <A> = PHYSICAL DEVICE CODE

;KK
;KK                GET ADDRESS OF <A> DISK IN FPYTAB TO <HL>
;KK
GETFPYTAB:
                lxi     h,FPYTAB            ;KK POINT TO SELECTED TABLE ENTRY
                lxi     d,FPYTABSIz         ;KK SIZE OF ENTRIES
GFT1:           ani     7                   ;KK CONVERT TO OFFSET TO FPYTAB, SET FLAGS IN LOOP
                rz                          ;ME <HL> = OUR TABLE ENTRY
                dad     d
                dcr     a
                jmp     GFT1
;KK
;KK                <HL> = OUR TABLE ENTRY
;KK
                ret                         ;ME Unused but left in code for binary compatibility

;KK
;KK                ADD SECTOR BIAS FROM CURFPYTAB THAT WAS SET BY MAKECUR
;KK                ENTRY:        <H> = HEAD NUMBER (0 OR 1)
;KK                                <A> = SECTOR TO ADD BIAS TO
;KK
SECBIAS:
                push    h
                call    GETBIAS
                add     m
                pop     h
                ret
;KK
;KK                REVERSE OF ABOVE
;KK
SECUNBIAS:
                push    h
                call    GETBIAS
                sub     m
                pop     h
                ret
;KK
;KK                ADD SIDE BIAS SAME WAY AS ABOVE
;KK
SIDEBIAS:
                push    h
                call    GETBIAS
                inx     h                   ;KK SIDEBIAS 2 BYTES PAST SECTOR BIAS
                inx     h                   ;KK ..IN FPYTAB
                add     m
                pop     h
                ret
;KK
;KK                SUBROUTINE
;KK
GETBIAS:
                push    d
                push    psw
                mov     a,h                 ;KK ADD SIDE (0 OR 1)
                ani     1                   ;KK JUST MAKE SURE
                mov     e,a
                mvi     d,0
                lhld    CURFPYTAB
                inx     h
                inx     h                   ;KK THIS IS OFFSET FOR SIDE 0
                dad     d                   ;KK ADD SIDE NO. (0 OR 1)
                pop     psw
                pop     d                   ;KK <HL> POINTS TO BIA
                ret

;KK
;KK                RETURN OMNI FIRMWARE VERSION NUMBER, HOST CALL
;KK
;KK                      42  2AH        OMNI COMMAND CODE
;KK
;KK                RETURNS: OMNI FIRMWARE VERSION NUMBER
;KK
GETVERS:
                mvi     a,VERSION
                rst     PUTHOST
                ret
;
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   23. MACROS TO HELP BUILD FDREL
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;               EQUATES USED BY FOLLOWING MACROS
;
;               DEFINED WITH "SET" TO KEEP THEM OUT OF ".SYM" FILE
;               --- THE VALUES ARE NOT CHANGED
;

POW0            SET     1
POW1            SET     2
POW2            SET     4
POW3            SET     8
POW4            SET     10H
POW5            SET     20H
POW6            SET     40H
POW7            SET     80H
POW8            SET     100H

ALSET1          SET     080H
ALSET2          SET     0C0H
ALSET3          SET     0E0H
ALSET4          SET     0F0H
ALSET5          SET     0F8H
ALSET6          SET     0FCH
ALSET7          SET     0FEH
ALSET8          SET     0FFH
ALSET9          SET     080FFH
ALSET10         SET     0C0FFH
ALSET11         SET     0E0FFH
ALSET12         SET     0F0FFH
ALSET13         SET     0F8FFH
ALSET14         SET     0FCFFH
ALSET15         SET     0FEFFH
ALSET16         SET     0FFFFH


SD              SET     0                   ;SINGLE DENS (FM) CODE
DD              SET     40H                 ;DOUBLE DENS (MFM) CODE
TRACKS8         SET     77
TRACKS5         SET     40

FDREL           MACRO   INCHES,DENS,SLEN,SPT,GAPLRW,GAPLFM,SKEW,SINGSIDE,DOUBSIDE
                db      INCHES+DENS,SLEN,SPT,GAPLRW,GAPLFM,SKEW
;;              db      INCHES+DENS         ;INCHES+DENS
;;              db      SLEN                ;SLEN: 0=128, 1=245, 2=512, 3=1024
;;              db      SPT                 ;SECTORS PER TRACK
;;              db      GAP1RW              ;GAP 1 LENGTH FOR NEC765 READ/WRITE CMDS
;;              db      GAP1FM              ;GAP 1 LENGTH FOR NEC765 FORMAT TRACK CMD
;;              db      SKEW                ;SKEW FACTOR
SECTPT          SET     SPT
;; SET TRKLEN TO # OF 128-BLOCKS / TRACK
                SETPOW  LSPERPS,%SLEN       ;LOGICAL SECTORS PER PHYSICAL SECTOR
TRKLEN          SET     LSPERPS*SECTPT
TRKS            SET     TRACKS&INCHES       ;KK ADDED TRKS TO DOUBLE CAPACITY ON 2 SIDED
                FDREL1  INCHES,SINGSIDE

;;SECTPT        SET     SECTPT+SECTPT       ;;KK DON'T DOUBLE
;;TRKLEN        SET     TRKLEN+TRKLEN       ;;KK DTRKLEN IS NOT CYLINDER LENGTH
TRKS            SET     TRKS+TRKS           ;;KK DOUBLE THIS INSTEAD
                FDREL1  INCHES,DOUBSIDE
                ENDM
FDREL1          MACRO   INCHES,TOFFSET,BSHIFTF,DIRBKS,DIRENTS,MSDSAL,MSDRDE,MSDMBY
                SETPOW  BSHIFTM,%BSHIFTF
;;DSM           SET     (TRKLEN*(TRACKS&INCHES-TOFFSET)/BSHIFTM)-1   ;KK MODIFIED AS
DSM             SET     (TRKLEN*(TRKS-TOFFSET)/BSHIFTM)-1            ;KK ...THIS LINE
;; MAKE NUMBER OF DIRECTORY ENTRIES FROM DIRBKS OR DIRENTS
DIRE            SET     0
                IF      NOT NUL DIRBKS
DIRE            SET     (DIRBKS)*4*BSHIFTM
                ENDIF
                IF      NOT NUL DIRENTS
DIRE            SET     DIRENTS
                ENDIF
;; NOW REVERSE ENGINEER TO GET DIRECTORY BLOCKS
DIRB            SET     ((DIRE+3)/4+BSHIFTM-1)/BSHIFTM
                IF      NOT NUL DIRBKS
                IF      DIRBKS > DIRB
DIRB            SET     DIRBKS
                ENDIF
                ENDIF
                IF      DSM < 256
                SETPOW  EXM,%BSHIFTF-3
                ELSE
                SETPOW  EXM,%BSHIFTF-4
                ENDIF
                SETAL01 %DIRB
                db      TRKLEN,0,BSHIFTF,BSHIFTM-1,EXM-1
;;              db      TRKLEN              ;TRKLEN
;;              db      0                   ;0
;;              db      BSHIFTF             ;BSHIFTF
;;              db      BSHIFTM-1           ;BSHIFTM-1
;;              db      EXM-1               ;EXM-1

;               dw      DSM,DIRE-1,AL01,(DIRE+3)/4,TOFFSET,0         ;KK MAKES TOO BIG
                                ;KK ..CKS
CKSIZE          SET     (DIRE+3)/4          ;KK
                IF      INCHES EQ 5         ;KK
CKMAX           SET     30H                 ;KK
                ELSE                        ;KK
CKMAX           SET     20H                 ;KK
                ENDIF
                IF      CKSIZE GT CKMAx     ;KK
CKSIZE          SET     CKMAx               ;KK
                ENDIF                       ;KK
                dw      DSM,DIRE-1,AL01,CKSIZE,TOFFSET,0             ;;KK
;;              dw      DSM                 ;DSM
;;              dw      DIRE-1              ;DIRRECTORY ENTRIES
;;              dw      AL01                ;ALLOCATION
;;              dw      CKSIZE              ;CHECK SIZE
;;              dw      TOFFSET             ;TRACKS OFFSET
;;              dw      0                   ;0

; NOTE: DUMMY CP/M-3 PSH AND PHM FOLLOWS TRACK OFFSET
; BPB FOLLOWS...
TOTSECT         SET     SECTPT*TRKS         ;TOTAL NUMBER OF SECTORS IN MEDIA
TOTALOC         SET     TOTSECT/MSDSAL      ;TOTAL ALLOCATION UNITS IN MEDIA
SLEN            SET     LSPERPS*128         ;SECTOR LENGTH IN BYTES
CFS             SET     (TOTALOC+TOTALOC+TOTALOC+SLEN+SLEN-1)/(SLEN+SLEN)
;;              dw      SLEN,MSDSAL,1,0,2,MSDRDE,TOTSECT,MSDMBY,CFS,SECTPT
                dw      SLEN                ;BYTES/SECTOR
                db      MSDSAL,1,0,2        ;SECTS/ALLOC, RESVD SECTS, NUMBERFATS
                dw      MSDRDE,TOTSECT      ;ROOT DIR ENTS, TOTAL SECTORS IN MEDIA
                db      MSDMBY              ;MEDIA BYTE
                dw      CFS,SECTPT          ;CALCULATED SECTORS PER FAT, SECTORS PER TRACK
                ENDM

SETPOW          MACRO   RESULT,ARG
RESULT          SET     POW&ARG
                ENDM

SETAL01         MACRO   ARG
AL01            SET     ALSET&ARG
                ENDM

;
;                                RELATIONSHIP BETWEEN --
;
;                                DISK TYPE                        GAP LENGTH 1
;                                SECTOR LENGTH                    GAP LENGTH 2
;                                NUMBER OF SECTORS                SKEW FACTOR
;
;                                PLUS FOR CP/M ONE AND TWO SIDED DPB'S
;
;                                DPB PARAMETERS ARE <ONE SIDE>,<TWO SIDES>
;                                WITHIN THE POINTY BRACKETS ARE ---
;
;                P1              TRACK OFFSET (IS THIS EVER NOT = 2?)
;                P2              CP/M ALLOCATION UNIT SIZE (3=1K, 4=2K, 5=4K, 6=8K, 7=16K)
;                P3              ALLOCATION UNITS RESERVER FOR DIRECTORY
;                P4              MAXIMUM NUMBER OF FILES ALLOWED (IF NULL THEN COMPUTE FROM P3)
;
;                                AND THEN FOR MS-DOS...
;
;                P5              (PHYSICAL) SECTORS/ALLOCATION UNIT
;                P6              NUMBER OF ROOT DIRECTORY ENTRIES
;                P7              MEDIA BYTE
;                                SECTORS REQUIRED TO HOLD FAT IS GENERATED IN MACRO
;
;                                ALL PARAMETERS ARE REQUIRED EXCEPT ONLY ONE OF P3/P4
;                                NEED BE PRESENT.  IF BOTH P3 AND P4 ARE PRESENT, P3 IS
;                                ONLY USED IF IT IS LARGER THAN NEEDED.
;
;                TYPE:
;                                05H                5" SINGLE DENSITY (FM)
;                                08H                8" SINGLE DENSITY (FM)
;                                45H                5" DOUBLE DENSITY (MFM)
;                                48H                8" DOUBLE DENSITY (MFM)
;
;                SECTOR LENGTH
;                                0                128
;                                1                256
;                                2                512
;                                3                1024
;
;                NUMBER OF SECTORS PER TRACK:
;                                SECTORS PER SIDE IF DOUBLE SIDED
;
;                GAP LEN1:
;                                GAP LENGTH TO BE USED WITH NEC765 (INTEL 8272) READ/WRITE CMDS
;
;                GAP LEN2:
;                                GAP LENGTH TO BE USED WITH NEC765 FORMAT TRACK COMMAND
;
;                SKEW FACTOR:
;                                LOGICALY CONTIEGEOUS SECTORS ARE THIS FAR APART
;
;KK CP/M TOFFSET DOUBLED ON DOUBLE SIDED FLOPPIES

FDRELTAB:
STD8:
 FDREL 8,SD,0,26,007H,01BH,6,<2,3,2,,4,068,002H>,<4,4,2,,4,068,003H>;8" SD 128
LENFDREL        EQU     $-FDRELTAB
 FDREL 8,SD,1,15,00EH,02AH,1,<2,4,2,,2,112,004H>,<4,4,2,,2,112,005H>;8" SD 256
 FDREL 8,SD,2,08,01BH,03AH,1,<2,4,2,,2,112,006H>,<4,4,2,,2,112,007H>;8" SD 512
 FDREL 8,SD,3,04,047H,08AH,1,<2,4,2,,2,112,008H>,<4,4,2,,2,112,009H>;8" SD 1024

 FDREL 8,DD,1,26,00EH,036H,3,<2,4,2,,2,112,00AH>,<4,4,2,,2,112,00BH>;8" DD 256
 FDREL 8,DD,2,15,01BH,054H,1,<2,4,2,,2,112,00CH>,<4,4,2,,2,112,00DH>;8" DD 512
 FDREL 8,DD,3,08,035H,074H,2,<2,4,2,,1,112,00EH>,<4,4,2,,1,192,00FH>;8" DD 1024 W/W
NFMT8           EQU     ($-STD8)/LENFDREL

STD5:
 FDREL 5,SD,0,16,010H,019H,1,<2,3,2,,1,112,018H>,<4,3,2,,2,112,019H>;5" SD 128 16 SECT
 FDREL 5,SD,0,17,007H,009H,1,<2,3,2,,1,112,01AH>,<4,3,2,,2,112,01BH>;5" SD 128 **NEW**
 FDREL 5,SD,0,18,007H,009H,5,<3,3,,32,1,112,01CH>,<4,3,2,,2,112,01DH>;5" SD 128 Xerox
 FDREL 5,SD,1,08,018H,030H,1,<2,3,2,,1,112,01EH>,<4,3,2,,2,112,01FH>;5" SD 256
 FDREL 5,SD,1,10,007H,010H,2,<3,4,,64,1,112,020H>,<4,3,2,,2,112,021H>;5" SD 256 Osborne
 FDREL 5,SD,2,04,046H,087H,1,<2,3,2,,1,112,022H>,<4,3,2,,2,112,023H>;5" SD 512

 FDREL 5,DD,1,16,020H,032H,1,<2,3,,64,1,112,024H>,<2,4,,256,2,112,025H>;5" DD 256 16 SECT
 FDREL 5,DD,1,17,00AH,00CH,1,<3,3,,64,1,112,026H>,<6,4,,128,2,112,027H>;5" DD 256 **NEW**
 FDREL 5,DD,1,18,00AH,00CH,1,<2,3,2,,1,112,028H>,<4,4,,64,2,112,029H>;5" DD 256 18 SECT
 FDREL 5,DD,2,08,02AH,050H,1,<1,3,,64,1,64,0FEH>,<2,4,,64,2,112,0FFH>;5" DD 512 PC 8 SECT
 FDREL 5,DD,2,09,0030,0060,1,<2,3,,64,1,64,0FCH>,<4,4,2,,2,112,0FDH>;5" DD 512 PC 9 SECT
 FDREL 5,DD,2,10,0017,0034,4,<2,3,,64,1,64,0FAH>,<4,4,,128,2,112,0FBH>;5" DD 512 10 SECT
 FDREL 5,DD,3,04,080H,0F0H,1,<2,3,2,,1,112,030H>,<4,4,2,,2,112,031H>;5" DD 1024 4 SECT
 FDREL 5,DD,3,05,0028,0050,3,<2,4,,128,1,112,032H>,<4,4,,192,2,112,033H>;5" DD 1024 **NEW**
NFMT5           EQU     ($-STD5)/LENFDREL
                db      0FFH                ;END OF LIST

PDTFINDERS:
                dw      FD800
                dw      FD801
                dw      FD810
                dw      FD811
                dw      FD500
                dw      FD501
                dw      FD510
                dw      FD511
                dw      HD00
                dw      HD01
                dw      HD02
                dw      HD03
                dw      MEMDISK
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   24. DEBUG SUBROUTINE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
                IF      DEBUGGING
DEBUG:
                PUSH    H
                PUSH    D
                PUSH    B
                LDA     DEBUGB
                ORA     A
                JZ      DEBUG2
                LXI     H,9+6+16-2
                DAD     SP
                PUSH    H                   ;SO WE CAN ALSO SEE STACK DEPTH
                XCHG
                LHLD    DEBUGA
                MVI     C,10+6+16
DEBUG1:         LDAX    D
                MOV     M,A
                DCX     D
                INX     H
                DCR     C
                JNZ     DEBUG1
                SHLD    DEBUGA
                POP     H                   ;PULL OFF SP+WHATEVER
DEBUG2:         POP     PSW
                POP     B
                POP     D
                POP     H
                RET
                ENDIF
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   25. RAM ORGANIZATION
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
                ORG     RAMORG
BUFFER:         DS      2000H               ;FLOPPY DISK TRACK BUFFER
WDBUFF:         DS      200H                ;512-BYTE HARD DISK BUFFER
; BUFTAG MUST BE ON 100H BOUNDARY
BUFTAG:         DS      40H                 ;TRACK BUFFER FLAGS (64 128-BYTE SECTORS)
READTAG         EQU     80H                 ;DATA IS VALID IN BUFFER
WRITETAG        EQU     20H                 ;DATA NEEDS TO BE WRITTEN BACK TO DISK
;
;        FOLLOWING AREA SETUP BY "INITALL"
;
;        ANY CHANGES MUST ALSO BE REFLECTED IN THE "PUCONST" LIST
;
PUDEF:
WRITE$DELAY:    DS      2                   ;# 250MS TICKS BEFORE MODIFIED BUFFERS WRITTEN
UNLOAD$DELAY    EQU     WRITE$DELAY+1       ;TICKS BEFORE FD HEADS UNLOAD
FD$STEP$RATE:   DS      2+6                 ;KK ALL STEP RATES (IN NEC "SPECIFY" FORMAT)
FD$LOAD$TIME:   DS      2                   ;8/5 HEAD LOAD TIME IN MS
FD$SETTLE:      DS      2                   ;8/5 HEAD SETTLE (AFTER SEEK) IN MS
SEEKRETRY1:     DS      1                   ;R/W RETRY BEFORE FANCY SEEK STUFF
SEEKRETRY2:     DS      1                   ;R/W RETRY WITH SEEK STUFF (TOT RETRY = R1*R2)
H1234:          DS      2                   ;SET=1234H AS SIGNAL THAT POWER IS UP
HDHEADS:        DS      1                   ;HARD DISK PARAMETER: NUMBER OF HEADS
HDPRECOMP:      DS      1                   ;PRE COMP CYLINDER
HDSRATE:        DS      1                   ;HARD DISK STEP RATE
HDCTYPE:        DS      1                   ;HARD DISK CONTROLLER TYPE
JMPBIO:         DS      1                   ;JMP INSTRUCTION ***MUST BE LAST IN INIT LIST***
;
;        END OF AREA SETUP BY "INITALL"
;
;        NOTE: BOOTSUB MUST FOLLOW LAST ENTRY IN "INITALL" LIST
;
BOOTSUB:        DS      2                   ;READ OR WRITE ADDRESS FOR BOOTIO SUBROUTINE
TRHLOAD:        DS      1                   ;TIME REMAINING FOR HEAD LOAD (TICKS AT 1 MS)
TRHSETL:        DS      1                   ;-DITTO- FOR HEAD SETTLE (MUST BE TRHLOAD+1)
MMDEST:         DS      3                   ;MOVE MEMORY DESTINATION ADDRESS (LO, HI, EX)
MMFROM:         DS      3                   ;MOVE EMORY SOURCE ADDRESS (LO, HI, EX)
MD$ADRS         EQU     MMFROM              ;3-BYTE MEMORY DISK ADRS FROM SEEKTRK/SEEKSEC
BUFTRKS:        DS      2                   ;FOR "LHLD" OF FOLLOWING
BUFTRACK        EQU     BUFTRKS             ;CURRENT TRACK NUMBER IN BUFFER
BUFSIDE         EQU     BUFTRKS+1           ;CURRENT SIDE NUMBER IN BUFFER

TIME$WRITE:     DS      2                   ;TIMER FOR UNWRITTEN WRITE TAGS
TIME$HLOAD      EQU     TIME$WRITE+1        ;HEAD UNLOAD TIMER (TIME HEADS STAY LOADED)
NECINTADRS:     DS      2                   ;NEC READ/WRITE "CONTINUE" ADDRESS
BOOTLEN:        DS      1                   ;(REMAINING) # BLOCKS FOR BOOT/SYSWRT
SPSAVE:         DS      2                   ;USED TO ASSURE SP RESTORED AFTER I/O DONE INT
PIOFIRSTR:      DS      1                   ;FIRST RECORDWE TRIED TO READ/WRITE
PIOLASTR:       DS      1                   ;LAST RECORD WE TRIED TO (OR DID) READ/WRITE
OPTYPE:         DS      1                   ;R/W OP TYPE FOR GENSTAT 80H=READ, 40H=WRITE
RWTYPE:         DS      1                   ;0=NORMAL, 1=DIRECTORY, 2=SEQ WRITE
RLINE5:         DS      1                   ;NON-ZERO IF 5" DRIVES HAVE READY LINE

SEEKDEV:        DS      1                   ;KEEP in      LOGICAL DEVICE FROM HOST
SEEKTRK:        DS      2                   ;ORDER        LOGICAL TRACK FROM HOST
SEEKHD:         DS      1                   ;FOR WD       HEAD NUMBER FROM HOST (NOT FOR R/W)
SEEKSEC:        DS      1                   ;TABLE        LOGICAL SECTOR FROM HOST
LWDP            SET     $-SEEKDEV
SEEKDMALO:      DS      1                   ;S100 DMA ADDRESS FROM HOST, BITS 7-0
SEEKDMAHI:      DS      1                   ;S100 DMA ADDRESS FROM HOST, BITS 15-8
SEEKDMAEX:      DS      1                   ;S100 DMA ADDRESS FROM HOST, BITS 23-16
MODE:           DS      2                   ;DMA MODE + DMA PRIORITY (ONE BYTE)
CURLCONT:       EQU     MODE+1              ;RAM COPY OF WHAT WAS LAST SENT TO LOCCONT
FWTA:           DS      2                   ;ADRS OF BUFTAG FOR WRITE FAILURE (OR =0 IF OK)

WDDEV:          DS      LWDP+1              ;WD COPY OF SEEK... STUFF
WDCYL           EQU     WDDEV+1
WDHEAD          EQU     WDCYL+2
WDSEC           EQU     WDHEAD+1
WDBMOD          EQU     WDSEC+1             ;WD BUFFER MODIFIED FLAG

;        READ/WRITE SECTOR IN ERROR PLUS
;        7-BYTE RESULT PHASE VECTOR

GENSTAT:        DS      1                   ;GENERAL STATUS BYTE
PIOERSECT:      DS      1                   ;PHYS SECTOR THAT HAD ERROR (=0 IF NO ERROR)
RES$ST0:        DS      1                   ; **
RES$ST1:        DS      1                   ; ** SEE BOOK FOR MEANING OF VARIOUS BITS
RES$ST2:        DS      1                   ; **
RES$C:          DS      1                   ;>
RES$H:          DS      1                   ;>>
RES$R:          DS      1                   ;>>>  SEE BOOK FOR MEANING OF
RES$N:          DS      1                   ;>>>> CHRN AT RESULT PHASE
LENESL          EQU     $-GENSTAT           ;LENGTH OF EXTENDED STATUS LIST

CPS$SECTOR:     DS      1                   ;PHYSICAL SECTOR FROM CPS
CPS$TRKS:       DS      2                   ;FOR "LHLD" OF FOLLOWING
CPS$TRACK       EQU     CPS$TRKS            ;TRACK NUMBER AS COMPUTED BY CPS
CPS$SIDE        EQU     CPS$TRKS+1          ;SIDE NUMBER (0 OR 1) AS COMPUTED BY CPS
CPS$BUFADR:     DS      2                   ;ADDRESS OF LOGICAL SECTOR WITHIN BUF
CPS$PSECT:      DS      2                   ;NUMBER OF BYTES IN PHYSICAL SECTOR
PFIOFLAG:       DS      1                   ;PHYSICAL FMT I/O FLAG

;        WORKING AREA FOR R/W RETRY -- SEE ALSO SEEKRETRY1 & 2

RETRYC1:        DS      3                   ;TIMES LEFT TO RETRY BEFORE SEEK
RETRYC2         EQU     RETRYC1+1           ;TIMES LEFT TO RETRY USING SEEK
RETRYC3         EQU     RETRYC1+2           ;SEEK STATE: 3=NEXT SEEK UP, 2=RECAL, 1=DOWN

CURLDTADRS:     DS      2                   ;CURRENT LDT ADDRESS
CURLOGDEV:      DS      1                   ;CURRENT LOGICAL DEVICE

CURPDTADRS:     DS      2
CURPHYSDEV:     DS      1                   ;CURRENT PHYSICAL DEVICE
CURPDT:
CURPDTLDN:      DS      1
CURPDTNPD:      DS      1
CURPDTFLG:      DS      1
CURPDTTRK:      DS      1
CURPDTPSS:      DS      1
CURPDTNST:      DS      1
CURPDTGPL:      DS      1
CURPDTLSS:      DS      1
CURPDTNBH:      DS      1
CURPDTNBC:      DS      1
CURPDTSKEW:     DS      2                   ;ADDRESS OF SKEW LIST

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   LOGICAL DEVICE TABLE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;

LOGDEVTBL:
                DS      1                   ;FIRST PHYSICAL DEVICE (OR 00 IF NONE)
                DS      1                   ;FLAGS
                DS      1                   ;LOGICAL SECTOR SIZE (0=128, 1=256,,,6=8196)
                DS      1                   ;NUMBER OF LOGICAL SECTORS/TRACK
                DS      1                   ;NUMBER OF LOGICAL HEADS
                DS      2                   ;NUMBER OF LOGICAL CYLINDERS
                DS      7*15                ;SPACE FOR LOGICAL DEVICES 01-0F (CP/M B: TO P:)

;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;   PHYSICAL DEVICE TABLE
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;

REORG           SET     $
                ORG     0
PDTLDN:         DS      1                   ;LOGICAL DEVICE NUMBER
PDTNPD:         DS      1                   ;NEXT PHYSICAL DEV IN SAME LOGICAL DEV (OR 00 IF LAST)
PDTFLG:         DS      1                   ;FLAGS:
                                            ;80 RECAL REQUIRED BEFORE FIRST SEEK
                                            ;40 MFM, 00 FM
                                            ;20 WRITE PROTECT (PHYSICAL)
                                            ;10
                                            ;08
                                            ;04 DOUBLE SIDED
                                            ;02 ** BOTH OF THESE BITS ARE USED AS MEDIA CHANGE
                                            ;01 ** STATE TABLE VALUES -- SEE TABLE BELOW
;
;   -----------------------MEDIA CHANGE STATUS TABLES---------------
;                                                            (MEDIA
; CODE & NAME   COME   DROP    GOOD   FAILED  GET M CH 8<==>  CHANGE
; ------------  READY  READY   GETDPB GETDPB  STAT     SWAP   STATUS)
; 00 IPL STATE  00     00      10     00      00       01     -1
; 01 DONT KNOW  01     01      10     00      01       01      0
; 10 LIVE UNIT  10     01      10     00      10       01     +1
;
;        IF DROP READY DOES "ANI NOT 02"
;                COME READY AND GET MEDIA CHANGED STATUS DO NOT CHANGE FLAGS
;                GOOD GET GETDPB DOES "ANI NOT 03, ORI 02"
;                FAILED GETDPB DOES "ANI NOT 03"
;                8<==>5 SWAP DOES "ANI NOT 03, ORI 01"
;
;        THE ABOVE IS FOR FLOPPY DISK, REMOVEABLE MEDIA.
;
;        FOR HARD DISK AND MEMORY DISK, FIXED MEDIA, THE
;        FOLLOWING APPLYS:
;                        DEVICE TABLE FLAG BITS ARE NOT USED
;                        MEDIA CHANGE STATUS =+1 ALLWAYS AND FOREVER
;
;        SPECIAL NOTE FOR 5" FLOPPY DRIVES:
;                        MANY 5" DRIVES DO NOT HAVE A "READY" LINE.
;                        FOR THESE DRIVES, A FAKED "READY" APPEARS ON ALL 4 5" UNITS.
;                        FOR THESE DRIVES, HEAD UNLOAD SETS FLAGS SAME AS DROP READY.
;
;                        SOME NEWER 5" DRIVES HAVE A "READY" LINE.
;                        FOR THESE DRIVES, "READY" COMES FROM THE DRIVE ITSELF.
;
;                        FOR MIXED 5" TYPES THE BOARD MUST BE WIRED TO FAKE "READY".
;
;
PDTTRK:         DS      1                   ;"C" CURRENT TRACK (IF SEEKING = DESTINATION TRACK)
                                            ;"H" & "R" ARE NOT IN THIS TABLE
PDTPSS:         DS      1                   ;"N" PHYSICAL SECTOR SIZE (0=128, 1=256,,,6=8196)
PDTNST:         DS      1                   ;"EOT" SECTORS/TRACK
PDTGPL:         DS      1                   ;"GPL" GAP LENGTH FOR READ/WRITE
PDTLSS:         DS      1                   ;LOGICAL SECTORS/SIDE (128-BYTE SIZE)
PDTNBH:         DS      1                   ;PHYSICAL NUMBER OF HEADS (1 OR 2 FOR FLOPPY)
PDTNBC:         DS      1                   ;PHYSICAL NUMBER OF CYL
                DS      0                   ;SKEW LIST BEGINS HERE
LENPDTH         EQU     $                   ;LENGTH OF PDT HEADER (FOR FLOPPY)
                                            ;   SKEW FACTOR LIST FOLLOWS
                                            ;   FOLLOWED BY A SKEW LIST

                ORG     REORG

LST8            EQU     52                  ;LENGTH OF SKEW TABLE FOR 8" DRIVES
LST5            EQU     18                  ;LENGTH OF SKEW TABLE FOR 5" DRIVES

PHYSDEVTBL:
FD800:          DS      LENPDTH+NFMT8+LST8  ;8" 00
FD801:          DS      LENPDTH+NFMT8+LST8  ;8" 01
FD810:          DS      LENPDTH+NFMT8+LST8  ;8" 10
FD811:          DS      LENPDTH+NFMT8+LST8  ;8" 11
FD500:          DS      LENPDTH+NFMT5+LST5  ;5" 00
FD501:          DS      LENPDTH+NFMT5+LST5  ;5" 01
FD510:          DS      LENPDTH+NFMT5+LST5  ;5" 10
FD511:          DS      LENPDTH+NFMT5+LST5  ;5" 11

REORG           SET     $
                ORG     0                   ;HARD DISK PHYSICAL DEVICE TABLE STRUCTURE
                DS      1                   ;LOGICAL DEV #
                DS      1                   ;NEXT DEVICE IN SET (NO REAL SUPPORT FOR THIS)
                DS      1                   ;FLAGS (NO USE ...YET)
PDTHHEADS:      DS      1                   ;NUMBER OF HEADS ON THIS DEVICE
PDTHPCMP:       DS      1                   ;PRECOMP CYLINDER FOR THIS DEVICE
PDTHSRATE:      DS      1                   ;STEP RATE FOR THIS DEVICE
PDTHDEV:        DS      1                   ;DEVICE SELECT CODE
PDTHOFFSET:     DS      2                   ;"HARDWARE" OFFSET
PDTHOSLEN:      DS      1                   ;LENGTH OF FOLLOWING OS TABLE
                DS      25                  ;RESERVE SPACE FOR HARD DISK DEVICE TABLE
LENHDDT         EQU     $                   ;LENGTH OF HARD DISK DEVICE TABLE

                ORG     REORG

HD00:           DS      LENHDDT             ;HARD DISK 0 NOTE -- FORMAT NOT THE SAME AS FD
HD01:           DS      LENHDDT             ;HARD DISK 1
HD02:           DS      LENHDDT             ;HARD DISK 2
HD03:           DS      LENHDDT             ;HARD DISK 3

MEMDISK:
                DS      1                   ;LOGICAL DEVICE NUMBER
                DS      1                   ;NEXT PHYSICAL DEVICE IN SET (OR 00 IF LAST)
                DS      1                   ;FLAGS
MD$INT$FLG      DS      1                   ;INIT FLAG FOR MEMORY DISK
MD$LEP:         DS      8                   ;(4 SETS OF) LENGTH/(END ADDRESS + 1) PARAMETER
MD$LOSB:        DS      1                   ;LENGTH OF OS BLOCK FOR MEMORY DISK
MD$OSB:         DS      25                  ;OS BLOCK (DPB OR EQUIV) AS SENT FROM HOST

; FPYTAB DEFINED
;
;FLAGS:         DS      1                   ;XXXX XXXX
;                                           ;^ ^^  ^
;                                           ;| ||  \-- DOUBLE SIDED
;                                           ;| |\----- Double-Step (48TPI in 96TPI DRIVE)
;                                           ;| \------ 96TPI
;                                           ;\-------- ACTIVE
;FDRELPOS:      DS      1                   ;RELITIVE POSITION IN FDRELPOS
;SECTOFF:       DS      2                   ;SECTOR OFFSET FOR SIDE 0, SIDE 1
;SIDEOFF:       DS      2                   ;SIDE I.D. OFFSET FOR SIDE 0, SIDE 1
;SKEW:          DS      1                   ;SKEW FACTOR, 0 = NO CHANGE
;LENDPB:        DS      1                   ;LENGTH OF DPB TO FOLLOW
;DPB:           DS      20                  ;ROOM FOR MAX SIZE DPB AND THEN SOME
FPYTABSIZ       EQU     27
;
FPYTAB:         DS      FPYTABSIZ*8         ;8 FLOPPY UNITS
CURFPYTAB:      DS      2                   ;CURRENT FPYTAB ADDRESS
CURRAMDPB:      DS      2                   ;POINTER TO CURRENT RAM DPB, 0=NONE
RAMDPBSKEW:     DS      1                   ;SKEW FACTOR IF RAMDPB VALID

RID$SIDE:       DS      1                   ;KK USED BY RID
RTRY$TRACK:     DS      2                   ;KK CALCULATED CYLINDER FOR RWRETRY, FROM SMS
VFYSEC:         DS      1                   ;KK USED BY VERIFY FORMAT AS OPTION (VERS 1.1)
BOOTTRK:        DS      2                   ;KK TRACK COUNTER FOR BOOT

DEBUGA:         DS      2
DEBUGB:         DS      1
DEBUGC          EQU     ($+15) AND 0FFF0H

STACK           EQU     RAMEND-80H          ;STACK BASE
MISCBUF         EQU     RAMEND-80H          ;BUFFER USED FOR MEMDISK AND DMA MOVE

                ORG     MISCBUF
;
;   ORG FOR VARIOUS SCRAP AREAS THAT ARE NOT NEEDED OUTSIDE THE
;   ROUTINE THAT SETS THEM.  BE CARFULE AS THIS IS ALSO THE
;   DMA SCRAP BUFFER.
;
PRWA:           DS      2                   ;TEMP STORAGE FOR PRW

FMT$NUM:        DS      1                   ;FORMAT NUMBER
FMT$CNTL:       DS      1                   ;FORMAT CONTROL
FMT$RELADRS     DS      2                   ;TEMP AREA FOR FMTTRK

SSPU:           DS      1                  ;1 SET SKEW (LOGICAL OR) PHYSICAL UNIT
SSDL:           DS      1                  ; 2 SET SKEW DENSITY AND SECTOR LEN
SSNS:           DS      1                  ;  3 SET SKEW NUMBER OF SECTORS (0=DONT CARE)
SSFACT:         DS      1                  ;   4 SET SKEW FACTOR (0 ==> DEFAULT)

                END
