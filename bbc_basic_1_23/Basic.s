; This source code in this file is licensed to You by Castle Technology
; Limited ("Castle") and its licensors on contractual terms and conditions
; ("Licence") which entitle you freely to modify and/or to distribute this
; source code subject to Your compliance with the terms of the Licence.
; 
; This source code has been made available to You without any warranties
; whatsoever. Consequently, Your use, modification and distribution of this
; source code is entirely at Your own risk and neither Castle, its licensors
; nor any other person who has contributed to this source code shall be
; liable to You for any loss or damage which You may suffer as a result of
; Your use, modification or distribution of this source code.
; 
; Full details of Your rights and obligations are set out in the Licence.
; You should have received a copy of the Licence with this source code file.
; If You have not received a copy, the text of the Licence is available
; online at www.castle-technology.co.uk/riscosbaselicence.htm
; 
;> Basic
        ^       0
WRITEC                          #       1
WRITES                          #       1
WRITE0                          #       1
NEWLINE                         #       1
READC                           #       1
CLI                             #       1
BYTE                            #       1
WORD                            #       1
FILE                            #       1
ARGS                            #       1
BGET                            #       1
BPUT                            #       1
MULTIPLE                        #       1
OPEN                            #       1
READLINE                        #       1
CONTROL                         #       1
GETENV                          #       1
EXIT                            #       1
SETENV                          #       1
INTON                           #       1
INTOFF                          #       1
CALLBACK                        #       1
ENTERSWI                        #       1
BREAKPT                         #       1
BREAKCT                         #       1
UNUSEDSWI                       #       1
SETMEMC                         #       1
SETCALLBACK                     #       1
MOUSE                           #       1                      ;<-
HEAP                            #       1
MODULE                          #       1
CLAIM                           #       1
RELEASE                         #       1
READUNSIGNED                    #       1
GENERATEEVENT                   #       1
READVARVAL                      #       1
SETVARVAL                       #       1
GSINIT                          #       1
GSREAD                          #       1
GSTRANS                         #       1
BINARYTODECIMAL                 #       1
FSCONTROL                       #       1
CHANGEDYNAMICAREA               #       1
GENERATEERROR                   #       1
READESCAPESTATE                 #       1
EVALUATEEXPRESSION              #       1
SPRITEOP                        #       1
READPALETTE                     #       1
SERVICECALL                     #       1
READVDUVARIABLES                #       1
READPOINT                       #       1
UPCALL                          #       1
CALLAVECTOR                     #       1
READMODEVARIABLE                #       1
REMOVECURSORS                   #       1
RESTORECURSORS                  #       1
SWINUMBERTOSTRING               #       1
SWINUMBERFROMSTRING             #       1

SOUNDSWIBASE                    *       &40140
SOUNDCONFIGURE                  *       SOUNDSWIBASE
SOUNDENABLE                     *       SOUNDSWIBASE+1
SOUNDSTEREO                     *       SOUNDSWIBASE+2

SOUNDCONTROL                    *       SOUNDSWIBASE+&40+6
SOUNDVOICE                      *       SOUNDSWIBASE+&40+10

SOUNDEVENTQSCHEDULE             *       SOUNDSWIBASE+&80+1
SOUNDEVENTTEMPO                 *       SOUNDSWIBASE+&80+5
SOUNDEVENTQBEAT                 *       SOUNDSWIBASE+&80+6

XOSPLOT                         *       &20045
XOSSYNCHRONISECODEAREAS         *       &2006E
WRITEN                          *       &46
SCREENMODE                      *       &65
WIMPSLOT                        *       &400EC
COLOURTRANSSETGCOL              *       &40743
COLOURTRANSSETTEXTCOLOUR        *       &40761
OSCHANGEENV                     *       &20040
BASICTrans_HELP                 *       &62C80
BASICTrans_Error                *       &62C81
BASICTrans_Message              *       &62C82
Territory_ReadCalendarInformation                               *       &4305F

WRITEI                          *       256

;allocation relative to vars/ARGP
        ^       -&700
ERRORS                          #       256
STRACC                          #       256
OUTPUT                          #       512
FREELIST                        #       256                    ;one word for sizes 4..252(3,4,5) bytes
PROCPTR                         #       4
VARPTR                          #       4*("z"+1-"A")          ;arranged s.t. 4*(ch-"@") is right
FNTEMPLOC                       *       PROCPTR+4*("["-"@")    ;4 words for the secret use of FN/PROC
;these four words must be zero for lvar to work!
RECPTR                          #       4
FNPTR                           #       4
DATAP                           #       4
TALLY                           #       4
WIDTHLOC                        #       4                      ;immediately before intvar
INTVAR                          #       4*27                   ;-&100 from ARGP
ASSPC                           *       4*("P"-"@")+INTVAR
PAGE                            #       4                      ;ALWAYS immediately after INTVAR
TOP                             #       4
FSA                             #       4
LOMEM                           #       4
HIMEM                           #       4
ERRNUM                          #       4
ERRORH                          #       4
ERRSTK                          #       4
ERRLIN                          #       4
ESCWORD                         #       4
ESCFLG                          *       ESCWORD
TRCFLG                          *       ESCWORD+1
TRCNUM                          #       4
TRACEFILE                       #       4
LOCALARLIST                     #       4
INSTALLLIST                     #       4
LIBRARYLIST                     #       4
OVERPTR                         #       4                      ;pointer to array of overlay information
MEMLIMIT                        #       4
OLDERR                          #       4*9
 [ STRONGARM = 1
SWICODE                         #       8
 ]
SEED                            #       5
LISTOP                          #       1
BYTESM                          #       1

CALLEDNAME                      #       0-(BYTESM+1)

 [ FP=0
CACHESIZE                       *       128
CACHEMASK                       *       2_11111110
CACHESHIFT                      *       3
CACHECHECK                      *       4*2                    ;address where check value held
 |
CACHESIZE                       *       256
CACHEMASK                       *       2_11111111
CACHESHIFT                      *       4
CACHECHECK                      *       4*2                    ;address where check value held
 ]

VCACHE                          #       CACHESIZE*16

FREE                            #       0                      ;start of everything else
;GOSUB.RETURN is TRETURN, ADDR
;REPEAT.UNTIL is TUNTIL, ADDR
;WHILE.ENDWHILE is TENDWH, block start ADDR, expr start ADDR
;integer FOR.NEXT is TNEXT, varaddr, ADDR, step, limit
;fp FOR.NEXT is TFOR, varaddr, ADDR, step (8), limit (8)
;FN is n words on stack, the bottom being TFN
;PROC is n words on stack, the bottom being TPROC
;LOCAL A(X) is 256+{4,5,128}, linklist, address, numbytes, arraylist

;Cache structure:
;variable   IACC, MOVEBY, CHECK, TYPE
;number     IACC, MOVEBY, CHECK, TYPE
;GOTO       R1,   MOVEBY, CHECK
;THENline   R1,         , CHECK
;FN/PROC    IACC, MOVEBY, CHECK, ( or not

CFLAG                           *       &20000000
SAFECRUNCH                      *       15

MODULEMAIN

 [ DO32BIT = 1
        MRS     R1,CPSR
        BIC     R1,R1,#&CF             ; IRQs+FIQs on, USR26/32 mode
        MSR     CPSR_c,R1
 |
        TEQP    PC,#0
 ]
        SWI     GETENV
        SUB     R1,R1,#VARS
        SUBS    R1,R1,#FREE+256
        BPL     MAIN
        ADR     R0,SEVEREERROR
        SWI     GENERATEERROR
        SWI     EXIT
SEVEREERROR
        &       11
        =       "Not enough application memory to start $Name.",0
        ALIGN
 [ FP=0
FACC    RN      R0
FACCX   RN      R1
FGRD    RN      R2
FSIGN   RN      R3
FWACC   RN      R4
FWACCX  RN      R5
FWGRD   RN      R6
FWSIGN  RN      R7
 |
FACC    FN      0
F1      FN      1
F2      FN      2
F7      FN      7
 ]
IACC    RN      R0
CLEN    RN      R2                     ;actually contains STRACC+CLEN
ARGP    RN      R8
TYPE    RN      R9
AELINE  RN      R11
LINE    RN      R12
SP      RN      R13
SOURCE  RN      R1
DEST    RN      R2
MODE    RN      R3
CONSTA  RN      R4                     ;0 for none, tconst for allowed
SMODE   RN      R5

TINTEGER                        *       &40000000              ;string TYPE is 0
TFP                             *       &80000000
 [ FP=0
TFPLV                           *       5
 |
TFPLV                           *       8
 ]
;pull and junk n items from stack
        MACRO
$L      PULLJ   $N
$L      ADD     SP,SP,#4*$N
        MEND
;allow space for n items from stack
        MACRO
$L      PUSHJ   $N
$L      SUB     SP,SP,#4*$N
        MEND
;load misaligned word using 2 other registers $DEST MUST BE < $W2
;$DEST may be $ADDR
        MACRO
$L      LOAD    $DEST,$ADDR,$W1,$W2
$L      BIC     $W2,$ADDR,#3
        AND     $W1,$ADDR,#3
        LDMIA   $W2,{$DEST,$W2}
        MOVS    $W1,$W1,LSL #3
        MOVNE   $DEST,$DEST,LSR $W1
        RSBNE   $W1,$W1,#32
        ORRNE   $DEST,$DEST,$W2,LSL $W1
        MEND
 [ FP=0
;save fp acc to address in TYPE [Format 2 only]
        MACRO
$L      FSTA    $ADDR
$L      ORR     FGRD,FSIGN,FACCX
        STMIA   $ADDR,{FACC,FGRD}
        MEND
        MACRO
$L      FPUSH
$L      ORR     FGRD,FSIGN,FACCX
        STMFD   SP!,{FACC,FGRD}
        MEND
        MACRO
$L      FLDA    $ADDR
$L      LDMIA   $ADDR,{FACC,FACCX}
        AND     FSIGN,FACCX,#&80000000
        AND     FACCX,FACCX,#255
        MEND
 |
        MACRO
$L      FPUSH
$L      STFD    FACC,[SP,#-8]!
        MEND
 ]
OSESCR  MOV     R11,R11,LSL #1
        AND     R11,R11,#&80
        MOV     R12,#VARS
        STRB    R11,[R12,#ESCFLG]
OSESCRT MOV     PC,R14
OSERRR
        MOV     R14,#VARS
        ADD     R14,R14,#STRACC
        ADD     R14,R14,#4
        B       MSGERR
OSUPCR  CMP     R0,#256
        MOVNE   PC,R14
PUTBACKHAND
        STMFD   SP!,{R0-R3,R14}
        LDR     R1,[R12,#TRACEFILE-OLDERR] ;tracefile handle
        TEQ     R1,#0
        MOV     R0,#0
        STR     R0,[R12,#TRACEFILE-OLDERR] ;kill handle!
        SWINE   OPEN+&20000            ;XOSCLOSE
        MOV     R0,#6
        LDMIA   R12!,{R1,R2,R3}
        SWI     OSCHANGEENV
        MOV     R0,#9
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        MOV     R0,#11
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        MOV     R0,#16
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        LDMFD   SP!,{R0-R3,PC}
OSQUITR LDR     R1,[R12,#TRACEFILE-OLDERR] ;tracefile handle
        TEQ     R1,#0
        MOV     R0,#0
        STR     R0,[R12,#TRACEFILE-OLDERR] ;kill handle!
        SWINE   OPEN+&20000            ;XOSCLOSE
        MOV     R0,#6
        LDMIA   R12!,{R1,R2,R3}
        SWI     OSCHANGEENV
        MOV     R0,#9
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        MOV     R0,#11
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        MOV     R0,#16
        LDMIA   R12!,{R1,R2}
        SWI     OSCHANGEENV
        SWI     EXIT
MYNAME  =       "ARW!"
MAIN    MOV     ARGP,#VARS
 [ STRONGARM = 1
        ;Create the SWI 0              ;MOV PC, R14 in the SWICODE data area
        ;and    then do a SYNCHRONISECODEAREAS, ranged.
        MOV     R0, #&EF000000         ;SWI 0
        LDR     R2, OSESCRT            ;A handy MOV PC,LR
        ADD     R1, ARGP, #SWICODE
        STMIA   R1,{R0,R2}
        ADD     R2, R1, #8             ;Size of SWICODE area
        MOV     R0, #1
        SWI     XOSSYNCHRONISECODEAREAS
 ]
 [ FP=1
        MOV     R0,#&70000
        WFS     R0
 ]
        ADD     R9,ARGP,#OLDERR
        MOV     R0,#6
        ADR     R1,OSERRR
        MOV     R2,#0
        ADD     R3,ARGP,#STRACC
        SWI     OSCHANGEENV
        STMIA   R9!,{R1,R2,R3}
        MOV     R0,#9
        ADR     R1,OSESCR
        MOV     R2,#0
        SWI     OSCHANGEENV
        STMIA   R9!,{R1,R2}
        MOV     R0,#11
        ADR     R1,OSQUITR
        ADD     R2,ARGP,#OLDERR
        SWI     OSCHANGEENV
        STMIA   R9!,{R1,R2}
        MOV     R0,#16
        ADR     R1,OSUPCR
        ADD     R2,ARGP,#OLDERR
        SWI     OSCHANGEENV
        STMIA   R9!,{R1,R2}
        ADD     R0,ARGP,#FREE          ;lomem
        STR     R0,[ARGP,#PAGE]
        SWI     GETENV
        MOV     SP,R1                  ;get himem limit
        STR     SP,[ARGP,#HIMEM]
        STR     SP,[ARGP,#MEMLIMIT]
        MOV     R0,#0
        STR     R0,[ARGP,#ERRLIN]
        STR     R0,[ARGP,#ERRNUM]
        STR     R0,[ARGP,#ESCWORD]
        STR     R0,[ARGP,#LOCALARLIST]
        STR     R0,[ARGP,#INSTALLLIST]
        STR     R0,[ARGP,#TRACEFILE]
        STR     R0,[ARGP,#TALLY]
        STRB    R0,[ARGP,#LISTOP]
        MVN     R0,#0
        STR     R0,[ARGP,#WIDTHLOC]
        STRB    R0,[ARGP,#BYTESM]
        MOV     R0,#10
        ORR     R0,R0,#&900
        STR     R0,[ARGP,#INTVAR]      ;set @%
        LDR     R0,[ARGP,#SEED]
        LDRB    R1,[ARGP,#SEED+4]
        ORRS    R0,R0,R1,LSL #31       ;gets bottom bit
        LDREQ   R0,MYNAME
        STREQ   R0,[ARGP,#SEED]
        ADR     R0,REPSTR
        ADD     R2,ARGP,#ERRORS
ENTRYL  LDRB    R1,[R0],#1
        STRB    R1,[R2],#1
        TEQ     R1,#0
        BNE     ENTRYL
        BL      FROMAT
        BL      SETFSA
        BL      ORDERR
        ADD     LINE,ARGP,#STRACC
        LDR     SP,[ARGP,#HIMEM]
        MOV     R0,#0
;to stop pops getting carried away
        STMFD   SP!,{R0-R9}
        STR     SP,[ARGP,#ERRSTK]
;see if there's a name waiting to be read in
        SWI     GETENV
        ADD     R3,ARGP,#CALLEDNAME
ENTRE1  LDRB    R2,[R0],#1
        STRB    R2,[R3],#1
        TEQ     R2,#0
        BEQ     CLRSTKTITLE
        CMP     R2,#" "
        BHI     ENTRE1
        MOV     R2,#0
        STRB    R2,[R3,#-1]
ENTRE2  LDRB    R2,[R0],#1
        CMP     R2,#" "
        BEQ     ENTRE2
        MOV     R9,#2                  ;set to chain
        CMP     R2,#"-"
        BEQ     ENTRYKEYW
        BL      TITLE
        TEQ     R2,#0
        BEQ     CLRSTK
        TEQ     R2,#"@"
        BNE     ENTRYF
        MOV     R9,#0                  ;no chain
ENTRYCONT
        BL      RDHEX                  ;incore text file
        MOV     R6,R5
        TEQ     R2,#","
        BNE     BADIPHEX
        BL      RDHEX
        TEQ     R2,#0
        BNE     BADIPHEX
        CMP     R5,R6
        BLS     BADIPHEX
        MOV     R1,R6
        MOV     R7,R6
        BL      LOADFILEINCORE
ENTRYFINAL
        TST     R9,#2
        BEQ     FSASET
        LDRB    R0,[ARGP,#CALLEDNAME]
        TEQ     R0,#0
        BNE     RUNNER                 ;not QUIT so just run
 [ CHECKCRUNCH=1
        BL      CRUNCHCHK
        BEQ     RUNNER
 ]
        MOV     R0,#SAFECRUNCH
        LDR     R1,[ARGP,#PAGE]
        BL      CRUNCHROUTINE
        STR     R2,[ARGP,#TOP]
        B       RUNNER
 [ CHECKCRUNCH=1
CRUNCHCHK
        STMFD   SP!,{R0,R1,R2,R3,R4,R14}
        ADR     R0,CRUNCHSTR
        MOV     R1,#-1
        MOV     R2,#-1
        MOV     R3,#0
        MOV     R4,#0
        SWI     READVARVAL+&20000
        TEQ     R2,#0                  ;if zero, variable DOES NOT exist (EQ status)
        LDMFD   SP!,{R0,R1,R2,R3,R4,PC}
CRUNCHSTR
        =       "BASIC$Crunch"
        =       0
        ALIGN
 ]
TITLE   STMFD   SP!,{R0-R14}
        SWI     WRITES
REPSTR  =       "ARM BBC BASIC V"
 [ FP=1
        =       "I"
 ]
        =       " version $Version (C) Acorn 1989",10,13,0
 [ RELEASEVER=0
        SWI     WRITES
        =       " a ",0
        BL      PATOUT
        =       &3F,&61,&D1,&BF,&B0,&B9,&B6,&E2
        =       &00,&80,&80,&3C,&47,&C6,&CE,&78
        =       &00,&00,&1E,&33,&73,&3F,&03,&06
        =       &00,&1E,&33,&3E,&F8,&0F,&00,&00
        =       &01,&07,&0C,&38,&E0,&80,&00,&00
        =       &C0,&60,&20,&00,&00,&00,&00,&00
        SWI     WRITES
        =       "prog",10,13,0
 ]
        LDR     R1,[ARGP,#HIMEM]
        LDR     R0,[ARGP,#PAGE]
        ADD     R0,R0,#4               ;to agree with value for END (=LOMEM)
        SUB     R1,R1,R0
        MOV     R0,#22
        SWI     BASICTrans_Message
        LDMVCFD SP!,{R0-R13,PC}
        SWI     WRITES
        =       10,13,"Starting with ",0
        MOV     R0,R1
        MOV     R7,#0
        BL      CARDINALPRINT
        SWI     WRITES
        =       " bytes free.",10,13,0
        BL      NLINE
        LDMFD   SP!,{R0-R13,PC}
ENTRYKEYW
        BL      RDCOMCH
        CMP     R2,#"H"
        BEQ     ENTRYKEYW2
        CMP     R2,#"L"
        BEQ     ENTRYKEYW3
        CMP     R2,#"Q"
        BEQ     ENTRYKEYW4
        CMP     R2,#"C"
        BL      RDCOMCHER
        CMP     R2,#"H"
        BL      RDCOMCHER
        CMP     R2,#"A"
        BL      RDCOMCHER
        CMP     R2,#"I"
        BL      RDCOMCHER
        CMP     R2,#"N"
        BL      RDCOMCHER
        CMP     R2,#" "
        BNE     ENTRYUNK
ENTRYCHAIN
        BL      TITLE
ENTRYCHAIN1
        CMP     R2,#" "
        LDREQB  R2,[R0],#1
        BEQ     ENTRYCHAIN1
        TEQ     R2,#0
        BEQ     CLRSTK
        TEQ     R2,#"@"
        BEQ     ENTRYCONT
ENTRYF  ADD     R4,ARGP,#STRACC
ENTRF1  STRB    R2,[R4],#1
        LDRB    R2,[R0],#1
        CMP     R2,#" "
        BHI     ENTRF1
        MOV     R5,#13
        STRB    R5,[R4],#1
;OK have set up name in STRACC. Call internals of TEXTLOAD
        BL      LOADFILEFINAL
        B       ENTRYFINAL
ENTRYKEYW4
        BL      RDCOMCH
        CMP     R2,#"U"
        BL      RDCOMCHER
        CMP     R2,#"I"
        BL      RDCOMCHER
        CMP     R2,#"T"
        BL      RDCOMCHER
        CMP     R2,#" "
        BNE     ENTRYUNK
        MOV     R1,#0                  ;set QUIT flag
        STRB    R1,[ARGP,#CALLEDNAME]
        B       ENTRYCHAIN1
ENTRYKEYW3
        BL      RDCOMCH
        CMP     R2,#"O"
        BL      RDCOMCHER
        CMP     R2,#"A"
        BL      RDCOMCHER
        CMP     R2,#"D"
        BL      RDCOMCHER
        CMP     R2,#" "
        BNE     ENTRYUNK
        MOV     R9,#0
        B       ENTRYCHAIN
ENTRYKEYW2
        BL      RDCOMCH
        CMP     R2,#"E"
        BL      RDCOMCHER
        CMP     R2,#"L"
        BL      RDCOMCHER
        CMP     R2,#"P"
        BL      RDCOMCHER
        BL      TITLE
        MOV     R0,#17+FP
        SWI     BASICTrans_Message
        BVC     ENTRYHELP
        SWI     WRITES
        =       "$Name. -help activated (use HELP at the > prompt for more help):",10,13,0
        B       ENTRYHELP
ENTRYUNK
        BL      TITLE
        MOV     R0,#19
        SWI     BASICTrans_Message
        BVC     ENTRYHELP
        SWI     WRITES
        =       "Unknown keyword.",10,13,10,13,0
        ALIGN
ENTRYHELP
        MOV     R0,#20+FP
        SWI     BASICTrans_Message
        BVC     FSASET
        SWI     WRITES
        =       "$Name. [-chain] <filename> to run a file (text/tokenised).",10,13
        =       "$Name. -quit <filename> to run a file (text/tokenised) and quit when done.",10,13
        =       "$Name. -load <filename> to start with a file (text/tokenised).",10,13
        =       "$Name. @xxxxxxxx,xxxxxxxx to start with in-core text/tokenised program.",10,13
        =       "$Name. -chain @xxxxxxxx,xxxxxxxx to run in-core text/tokenised program.",10,13,0
        B       FSASET
RDHEX   MOV     R5,#0
        MOV     R4,#32-4
RDHEX1  LDRB    R2,[R0],#1
        CMP     R2,#"0"
        BCC     BADIPHEX
        CMP     R2,#"9"+1
        BCC     RDHEX2
        CMP     R2,#"A"
        BCC     BADIPHEX
        CMP     R2,#"F"+1
        BCS     BADIPHEX
        SUB     R2,R2,#"A"-"9"-1
RDHEX2  AND     R2,R2,#&F
        ORR     R5,R5,R2,LSL R4
        SUBS    R4,R4,#4
        BPL     RDHEX1
        LDRB    R2,[R0],#1
        MOV     PC,R14
RDCOMCHER
        BNE     ENTRYUNK
RDCOMCH LDRB    R2,[R0],#1
        CMP     R2,#"a"
        BICCS   R2,R2,#" "
        MOV     PC,R14
NEW     BL      DONES
        BL      FROMAT
FSASET  BL      SETFSA
        B       CLRSTK
CLRSTKTITLE
        BL      TITLE
CLRSTK  MOV     ARGP,#VARS
        ADD     LINE,ARGP,#STRACC
        LDR     R0,[ARGP,#HIMEM]
        BL      POPLOCALAR
        LDR     SP,[ARGP,#HIMEM]
        MOV     R0,#0
        STMFD   SP!,{R0-R9}            ;to stop pops getting carried away
        MVN     R0,#0
        STRB    R0,[ARGP,#BYTESM]
        STR     SP,[ARGP,#ERRSTK]
        BL      ORDERR
        LDRB    R0,[ARGP,#CALLEDNAME]
        CMP     R0,#0
        SWIEQ   EXIT
        BL      FLUSHCACHE
        SWI     WRITEI+">"
        BL      INLINE                 ;R1=STRACC
        BL      SETVAR
        BL      MATCH
        ADD     LINE,ARGP,#OUTPUT
        BL      SPTSTN
        BNE     DC
        STMFD   SP!,{SMODE}
        MOV     R4,R0
        BL      INSRT
        LDMFD   SP!,{SMODE}
        CMP     SMODE,#&1000
        BCC     WARNC
        MOV     R0,#0
        SWI     BASICTrans_Message
        BVC     WARNC
        SWI     WRITES
        =       "Warning: unmatched ()",10,13,0
        ALIGN
WARNC   TST     SMODE,#256
        BEQ     WARNQ
        MOV     R0,#1
        SWI     BASICTrans_Message
        BVC     WARNQ
        SWI     WRITES
        =       "Warning: line number too big",10,13,0
        ALIGN
WARNQ   AND     SMODE,SMODE,#255
        TEQ     SMODE,#1
        BNE     FSASET
        MOV     R0,#2
        SWI     BASICTrans_Message
        BVC     FSASET
        SWI     WRITES
        =       "Warning: unmatched """,10,13,0
        ALIGN
        B       FSASET
DC      MOV     R3,#255
        STRB    R3,[R2]                ;limit end of immmediate mode line
        CMP     R10,#TESCCOM
        BNE     DISPAT
        LDRB    R10,[LINE],#1
        CMP     R10,#TTWOCOMMLIMIT
        BCS     ERSYNT
        SUBS    R4,R10,#&8E
        BCC     ERSYNT
        LDR     R4,[PC,R4,LSL #2]
        ADD     PC,PC,R4
AJ2                             *       .+4
        &       APPEND-AJ2
        &       AUTO-AJ2
        &       CRUNCH-AJ2
        &       DELETE-AJ2
        &       EDIT-AJ2
        &       HELP-AJ2
        &       LIST-AJ2
        &       LOAD-AJ2
        &       LVAR-AJ2
        &       NEW-AJ2
        &       OLD-AJ2
        &       RENUM-AJ2
        &       SAVE-AJ2
        &       TEXTLOAD-AJ2
        &       TEXTSAVE-AJ2
        &       TWIN-AJ2
        &       TWINO-AJ2
        &       INSTALL-AJ2
DOSTAR  MOV     R0,LINE                ;do oscli
        BL      OSCLIREGS
        SWI     CLI
        B       REM
GOTLTEND2
        CMP     R10,#TELSE
        BNE     ERSYNT
        BL      STORE
DATA
DEF
REM     LDRB    R10,[LINE],#1
        CMP     R10,#13
        BEQ     CRLINE
        LDRB    R10,[LINE],#1
        CMP     R10,#13
        BNE     REM
        B       CRLINE
GOTLTEND1
        CMP     R10,#13
        BNE     GOTLTEND2
        BL      STORE
        LDRB    R10,[LINE],#3
        CMP     R10,#&FF
        BEQ     CLRSTK                 ;check for program end
        LDR     R4,[ARGP,#ESCWORD]     ;check for exceptional conditions
        CMP     R4,#0
        BEQ     STMT                   ;nothing exceptional
        BL      DOEXCEPTION
        B       STMT
ENDIF
ENDCA
DONXTS  LDRB    R10,[LINE],#1
DONEXT  CMP     R10,#" "
        BEQ     DONXTS
        CMP     R10,#":"
        BEQ     STMT
        CMP     R10,#13
        BEQ     CRLINE
        CMP     R10,#TELSE
        BEQ     REM
        B       ERSYNT
MINUSBC BL      EXPR
        TEQ     TYPE,#0
        BEQ     ERTYPEINT
        RSBPL   IACC,IACC,#0
 [ FP=0
        BPL     PLUSBC
        TEQ     FACC,#0
        EORNE   FSIGN,FSIGN,#&80000000
 |
        RSFMID  FACC,FACC,#0
 ]
        B       PLUSBC
GOTLT2  CMP     R10,#"-"
        TEQCC   R10,#"+"
        BNE     MISTAK
ATGOTLT2
        LDRB    R10,[AELINE],#1
        TEQ     R10,#"="
        BNE     MISTAK
        BCS     MINUSBC
        BL      EXPR
PLUSBC  BL      AEDONE
        LDMFD   SP!,{R4,R5}
        CMP     R5,#TFPLV
        BEQ     PLUSBCFP
        BCS     PLUSBCSTRING
        BL      INTEGY
        MOV     R7,IACC
        MOV     IACC,R4
        MOV     TYPE,R5
        BL      VARIND
        ADD     IACC,IACC,R7
        BL      STOREANINT
NXT     CMP     R10,#":"
        BEQ     STMT
        CMP     R10,#13
        BNE     REM                    ;if not CR, then ELSE
CRLINE  LDRB    R10,[LINE],#3
        CMP     R10,#&FF
        BEQ     CLRSTK                 ;check for program end
        LDR     R4,[ARGP,#ESCWORD]     ;check for exceptional conditions
        CMP     R4,#0
        BEQ     STMT                   ;nothing exceptional
        BL      DOEXCEPTION
        B       STMT
PLUSBCSTRING
        CMP     R5,#256
        BCS     ARRAYPLUSBC
        TEQ     TYPE,#0
        BNE     ERTYPESTR
        ADD     R0,ARGP,#STRACC
        SUBS    R1,CLEN,R0
        BEQ     NXT                    ;nothing to be added!
        MOV     R7,R1                  ;keep additional length
        MOV     AELINE,R4              ;original address used by SPUSH
        BL      SPUSHLARGE             ;push string to be added
        MOV     IACC,AELINE            ;original address
        CMP     R5,#128                ;check source type
        BL      VARNOTNUM              ;TYPE=0 currently!
        ADD     SP,SP,#4               ;discard length on stack
        ADD     R6,ARGP,#STRACC
        SUB     R6,CLEN,R6
        ADD     R6,R7,R6               ;new length
        CMP     R6,#256
        BCS     ERLONG
PLUSBCLP
        LDRB    R6,[SP],#1
        STRB    R6,[CLEN],#1
        SUBS    R7,R7,#1
        BNE     PLUSBCLP
        ADD     SP,SP,#3
        BIC     SP,SP,#3
        MOV     R4,AELINE
        BL      STSTOR                 ;TYPE still 0
        B       NXT
PLUSBCFP

        BL      FLOATY
 [ FP=0
        MOV     TYPE,R4
        BL      FTOW
        BL      F1LDA
        BL      FADDW
        BL      F1STA
 |
        LDFD    F1,[R4]
        ADFD    FACC,F1,FACC
        STFD    FACC,[R4]
 ]
        B       NXT
LETSTNOTCACHE
        MOV     AELINE,LINE
        BL      LVNOTCACHE
        BLEQ    GOTLTCREATE            ;taken if EQ (note tricky DONEXT call)
GOTLT   STMFD   SP!,{IACC,TYPE}
GOTLT1  LDRB    R10,[AELINE],#1
        CMP     R10,#" "
        BEQ     GOTLT1
        CMP     R10,#"="
        BNE     GOTLT2
        CMP     TYPE,#256
        BCC     EXPRSTORESTMT
        B       LETARRAY
LETSTCACHEARRAY
        BIC     AELINE,AELINE,#TFP
        BL      ARLOOKCACHE
        BNE     GOTLT
        B       MISTAK
LETST   AND     R1,LINE,#CACHEMASK
        ADD     R1,ARGP,R1,LSL #CACHESHIFT
        LDMIA   R1,{IACC,R1,R4,TYPE}
        CMP     R4,LINE
        BNE     LETSTNOTCACHE
        ADDS    AELINE,LINE,R1
        BMI     LETSTCACHEARRAY
        STMFD   SP!,{IACC,TYPE}
LETSTSPACE
        LDRB    R10,[AELINE],#1
        CMP     R10,#" "
        BEQ     LETSTSPACE
        CMP     R10,#"="
        BNE     GOTLT2                 ;cannot possibly be array stuff
EXPRSTORESTMT
        BL      EXPR
        MOV     LINE,AELINE
        CMP     R10,#":"
        BNE     GOTLTEND1
        BL      STORE
STMT    LDRB    R10,[LINE],#1
; CMP R10,#" "
; BEQ STMT
;go to value of token in R10, using r4
DISPAT  LDR     R4,[PC,R10,LSL #2]
        ADD     PC,PC,R4
AJ                              *       .+4
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       CRLINE-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       STMT-AJ
        &       LETSTNOTCACHE-AJ
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       LETSTNOTCACHE-AJ       ; 24
        &       LETST-AJ               ; 25
        &       LETST-AJ               ; 26
        &       LETST-AJ               ; 27
        &       LETST-AJ               ; 28
        &       LETST-AJ               ; 29
        &       DOSTAR-AJ
        &       LETST-AJ               ; 2B
        &       LETST-AJ               ; 2C
        &       LETST-AJ               ; 2D
        &       LETST-AJ               ; 2E
        &       LETST-AJ               ; 2F
        &       LETST-AJ               ; 30
        &       LETST-AJ               ; 31
        &       LETST-AJ               ; 32
        &       LETST-AJ               ; 33
        &       LETST-AJ               ; 34
        &       LETST-AJ               ; 35
        &       LETST-AJ               ; 36
        &       LETST-AJ               ; 37
        &       LETST-AJ               ; 38
        &       LETST-AJ               ; 39
        &       STMT-AJ
        &       LETST-AJ               ; 3B
        &       LETST-AJ               ; 3C
        &       FNRET-AJ
        &       LETST-AJ               ; 3E
        &       LETSTNOTCACHE-AJ       ; 3F
        &       ASSIGNAT-AJ
        &       LETST-AJ               ; 41
        &       LETST-AJ               ; 42
        &       LETST-AJ               ; 43
        &       LETST-AJ               ; 44
        &       LETST-AJ               ; 45
        &       LETST-AJ               ; 46
        &       LETST-AJ               ; 47
        &       LETST-AJ               ; 48
        &       LETST-AJ               ; 49
        &       LETST-AJ               ; 4A
        &       LETST-AJ               ; 4B
        &       LETST-AJ               ; 4C
        &       LETST-AJ               ; 4D
        &       LETST-AJ               ; 4E
        &       LETST-AJ               ; 4F
        &       LETST-AJ               ; 50
        &       LETST-AJ               ; 51
        &       LETST-AJ               ; 52
        &       LETST-AJ               ; 53
        &       LETST-AJ               ; 54
        &       LETST-AJ               ; 55
        &       LETST-AJ               ; 56
        &       LETST-AJ               ; 57
        &       LETST-AJ               ; 58
        &       LETST-AJ               ; 59
        &       LETST-AJ               ; 5A
        &       ASS-AJ                 ; 5B
        &       LETST-AJ               ; 5C
        &       LETST-AJ               ; 5D
        &       LETST-AJ               ; 5E
        &       LETST-AJ               ; 5F
        &       LETST-AJ               ; 60
        &       LETST-AJ               ; 61
        &       LETST-AJ               ; 62
        &       LETST-AJ               ; 63
        &       LETST-AJ               ; 64
        &       LETST-AJ               ; 65
        &       LETST-AJ               ; 66
        &       LETST-AJ               ; 67
        &       LETST-AJ               ; 68
        &       LETST-AJ               ; 69
        &       LETST-AJ               ; 6A
        &       LETST-AJ               ; 6B
        &       LETST-AJ               ; 6C
        &       LETST-AJ               ; 6D
        &       LETST-AJ               ; 6E
        &       LETST-AJ               ; 6F
        &       LETST-AJ               ; 70
        &       LETST-AJ               ; 71
        &       LETST-AJ               ; 72
        &       LETST-AJ               ; 73
        &       LETST-AJ               ; 74
        &       LETST-AJ               ; 75
        &       LETST-AJ               ; 76
        &       LETST-AJ               ; 77
        &       LETST-AJ               ; 78
        &       LETST-AJ               ; 79
        &       LETST-AJ               ; 7A
        &       ERSYNT-AJ
        &       LETSTNOTCACHE-AJ       ; |
        &       ERSYNT-AJ
        &       ERSYNT-AJ
        &       OTHER-AJ
        &       ERSYNT-AJ              ; AND
        &       ERSYNT-AJ              ; DIV
        &       ERSYNT-AJ              ; EOR
        &       ERSYNT-AJ              ; MOD
        &       ERSYNT-AJ              ; OR
        &       LERROR-AJ
        &       LINEST-AJ
        &       CURSOFF-AJ
        &       ERSYNT-AJ              ; STEP
        &       ERSYNT-AJ              ; SPC
        &       ERSYNT-AJ              ; TAB
        &       REM-AJ                 ; ELSE
        &       ERSYNT-AJ              ; THEN
        &       ERSYNT-AJ              ; 8D
        &       ERSYNT-AJ              ; OPENU

        &       LPTR-AJ
        &       LPAGE-AJ
        &       LTIME-AJ
        &       LLOMEM-AJ
        &       LHIMEM-AJ

        &       ERSYNT-AJ              ; ABS
        &       ERSYNT-AJ              ; ACS
        &       ERSYNT-AJ              ; ADC
        &       ERSYNT-AJ              ; ASC
        &       ERSYNT-AJ              ; ASN
        &       ERSYNT-AJ              ; ATN
        &       ERSYNT-AJ              ; BBGET
        &       ERSYNT-AJ              ; COS
        &       ERSYNT-AJ              ; COUNT
        &       ERSYNT-AJ              ; DEG
        &       ERSYNT-AJ              ; ERL
        &       ERSYNT-AJ              ; ERR
        &       ERSYNT-AJ              ; EVAL
        &       ERSYNT-AJ              ; EXP
        &       LEXT-AJ                ; EXT
        &       ERSYNT-AJ              ; FALSE
        &       ERSYNT-AJ              ; FN
        &       ERSYNT-AJ              ; GET
        &       ERSYNT-AJ              ; INKEY
        &       ERSYNT-AJ              ; INSTR
        &       ERSYNT-AJ              ; INT
        &       ERSYNT-AJ              ; LEN
        &       ERSYNT-AJ              ; LN
        &       ERSYNT-AJ              ; LOG
        &       ERSYNT-AJ              ; NOT
        &       ERSYNT-AJ              ; OPENI
        &       ERSYNT-AJ              ; OPENO
        &       ERSYNT-AJ              ; PI
        &       ERSYNT-AJ              ; POINT
        &       ERSYNT-AJ              ; POS
        &       ERSYNT-AJ              ; RAD
        &       ERSYNT-AJ              ; RND
        &       ERSYNT-AJ              ; SGN
        &       ERSYNT-AJ              ; SIN
        &       ERSYNT-AJ              ; SQR
        &       ERSYNT-AJ              ; TAN
        &       ERSYNT-AJ              ; TO
        &       ERSYNT-AJ              ; TRUE
        &       ERSYNT-AJ              ; USR
        &       ERSYNT-AJ              ; VAL
        &       ERSYNT-AJ              ; VPOS
        &       ERSYNT-AJ              ; CHRD
        &       ERSYNT-AJ              ; GETD
        &       ERSYNT-AJ              ; INKED
        &       LLEFTD-AJ
        &       LMIDD-AJ
        &       LRIGHTD-AJ
        &       ERSYNT-AJ              ; STRD
        &       ERSYNT-AJ              ; STRND
        &       ERSYNT-AJ              ; EOF

        &       ERSYNT-AJ              ;functions disallowed
        &       ERSYNT-AJ              ;commands disallowed
        &       TWOSTMT-AJ             ;two byte statements

        &       WHEN-AJ
        &       ERSYNT-AJ              ;OF
        &       ENDCA-AJ
        &       ELSE2-AJ
        &       ENDIF-AJ
        &       ENDWH-AJ
        &       LPTR-AJ
        &       LPAGE-AJ
        &       LTIME-AJ
        &       LLOMEM-AJ
        &       LHIMEM-AJ
        &       SOUND-AJ
        &       BBPUT-AJ
        &       CALL-AJ
        &       CHAIN-AJ
        &       CLEAR-AJ
        &       CLOSE-AJ
        &       CLG-AJ
        &       CLS-AJ
        &       DATA-AJ
        &       DEF-AJ
        &       DIM-AJ
        &       DRAW-AJ
        &       END-AJ
        &       ENDPR-AJ
        &       ENVEL-AJ
        &       FOR-AJ
        &       GOSUB-AJ
        &       GOTO-AJ
        &       GCOL-AJ
        &       IF-AJ
        &       INPUT-AJ
        &       LET-AJ
        &       LOCAL-AJ
        &       MODES-AJ
        &       MOVE-AJ
        &       NEXT-AJ
        &       ON-AJ
        &       VDU-AJ
        &       PLOT-AJ
        &       PRINT-AJ
        &       PROC-AJ
        &       READ-AJ
        &       REM-AJ
        &       REPEAT-AJ
        &       REPORT-AJ
        &       RESTORE-AJ
        &       RETURN-AJ
        &       RUN-AJ
        &       STOP-AJ
        &       COLOUR-AJ
        &       TRACE-AJ
        &       UNTIL-AJ
        &       WIDTH-AJ
        &       OSCL-AJ
TWOSTMT LDRB    R10,[LINE],#1
        CMP     R10,#TTWOSTMTLIMIT
        BCS     ERSYNT
        SUBS    R4,R10,#&8E
        BCC     ERSYNT
        LDR     R4,[PC,R4,LSL #2]
        ADD     PC,PC,R4
AJ3                             *       .+4
        &       CASE-AJ3
        &       CIRCLE-AJ3
        &       FILL-AJ3
        &       ORGIN-AJ3
        &       PSET-AJ3
        &       RECT-AJ3
        &       SWAP-AJ3
        &       WHILE-AJ3
        &       WAIT-AJ3
        &       DOMOUSE-AJ3
        &       QUIT-AJ3
        &       SYS-AJ3
        &       INSTALLBAD-AJ3
        &       LIBRARY-AJ3
        &       DOTINT-AJ3
        &       ELLIPSE-AJ3
        &       BEATS-AJ3
        &       TEMPO-AJ3
        &       VOICES-AJ3
        &       VOICE-AJ3
        &       STEREO-AJ3
        &       OVERLAY-AJ3

;clear text
FROMAT  MOV     R0,#13
        LDR     R1,[ARGP,#PAGE]
        STRB    R0,[R1],#1
        MOV     R0,#&FF
        STRB    R0,[R1],#1             ;post index to get value for TOP
        STR     R1,[ARGP,#TOP]
        MOV     R0,#0
        STR     R0,[ARGP,#TRCNUM]
        MOV     PC,R14
SETFSA  LDR     R0,[ARGP,#TOP]
        ADD     R0,R0,#3
        BIC     R0,R0,#3
        STR     R0,[ARGP,#LOMEM]
        STR     R0,[ARGP,#FSA]
        MOV     R6,#0
        ADD     R1,ARGP,#FREELIST
        ADD     R2,R1,#256
SETFREEL
        STR     R6,[R1],#4
        CMP     R1,R2
        BCC     SETFREEL
        MOV     R6,R14                 ;save return address
        BL      SETVAR
        MOV     R14,R6
SETVAL  ADD     R1,ARGP,#PROCPTR
        ADD     R2,R1,#(FNPTR+4-PROCPTR)
        MOV     R0,#0
        STR     R0,[ARGP,#LIBRARYLIST]
        STR     R0,[ARGP,#OVERPTR]
SETVRL  STR     R0,[R1],#4
        TEQ     R1,R2
        BNE     SETVRL
        ADD     R1,ARGP,#VCACHE
        ADD     R2,R1,#CACHESIZE*16
SETCACHE0
        STR     R0,[R1],#4
        TEQ     R1,R2
        BNE     SETCACHE0
        MOV     PC,R14
SETVAR  LDR     R0,[ARGP,#PAGE]
        STR     R0,[ARGP,#DATAP]
        MOV     PC,R14
FLUSHCACHE
        ADD     R1,ARGP,#VCACHE+CACHECHECK
        MOV     R0,#0
        ADD     R2,R1,#CACHESIZE*16
FLUSHCACHE1
        STR     R0,[R1],#16
        TEQ     R1,R2
        BNE     FLUSHCACHE1
        MOV     PC,R14
;empty any cache entry which lies in the range R4 to AELINE
;Uses R5, R6, R7 and R10
;Must preserve PSR flags
PURGECACHE

 [ DO32BIT = 1
        STMFD   SP!,{R14}
        MRS     R14,CPSR
 ]
        MOV     R5,#0
        SUB     R10,AELINE,R4
        CMP     R10,#256
        BCS     PURGECACHEB1
;algorithm 1: kill entries that might be matched
 [ (CACHEMASK :AND: 1) = 1
;bottom bit valid
        MOV     R6,R4
PURGECACHEA1
        AND     R7,R6,#CACHEMASK
        ADD     R7,ARGP,R7,LSL #CACHESHIFT
        LDR     R10,[R7,#CACHECHECK]
        CMP     R10,R6
        STREQ   R5,[R7,#CACHECHECK]
        ADD     R6,R6,#1
        CMP     R6,AELINE
        BLE     PURGECACHEA1
 |
        BIC     R6,R4,#1
PURGECACHEA1
        AND     R7,R6,#CACHEMASK
        ADD     R7,ARGP,R7,LSL #CACHESHIFT
        LDR     R10,[R7,#CACHECHECK]
        CMP     R10,R6
        ADD     R6,R6,#1
        CMPNE   R10,R6
        STREQ   R5,[R7,#CACHECHECK]
        ADD     R6,R6,#1
        CMP     R6,AELINE
        BLE     PURGECACHEA1
 ]
 [ DO32BIT = 1
        MSR     CPSR_f,R14
        LDMFD   SP!,{PC}
 |
        MOVS    PC,R14
 ]
;algorithm 2: go through whole cache killing entries in range
PURGECACHEB1
        ADD     R6,ARGP,#VCACHE+CACHECHECK
        ADD     R7,R6,#CACHESIZE*16
PURGECACHEB2
        LDR     R10,[R6],#16
        CMP     R10,R4
        CMPCS   AELINE,R10
        STRCS   R5,[R6,#-16]
        CMP     R6,R7
        BNE     PURGECACHEB2
 [ DO32BIT = 1
        MSR     CPSR_f,R14
        LDMFD   SP!,{PC}
 |
        MOVS    PC,R14
 ]
 [ OWNERRORS=0
NOERRORMSG
        =       "No string from BASICTrans",0
        ALIGN
 ]
MSG     BIC     R4,R14,#&FC000000      ;byte error
        ADD     R14,ARGP,#STRACC
        MOV     R1,R14
        LDRB    R2,[R4],#1             ;move error number
        STR     R2,[R1],#4
        LDRB    R0,[R4],#1             ;unique error number
 [ OWNERRORS=0
        ADR     R4,NOERRORMSG          ;error message in case of none
 ]
        ADD     R5,R14,#4              ;copy my error message
MSGBYTE LDRB    R2,[R4],#1
        STRB    R2,[R5],#1
        CMP     R2,#0
        BNE     MSGBYTE
        SWI     BASICTrans_Error       ;overwrite with foreign one
MSGERR  MOV     ARGP,#VARS             ;cardinal error from outside world
        MOV     R7,R14                 ;keep error pointer
        BL      FLUSHCACHE
        MOV     R0,#&DA
        MOV     R1,#0
        MOV     R2,#0
        SWI     BYTE
        MOV     R0,#&7E
        SWI     BYTE
        MOV     R0,#0
; STRB R0,[ARGP,#TRCFLG] ;disable any tracing     ;****CHANGE
        SUB     LINE,LINE,#2           ;seems a good idea
        LDR     R1,[ARGP,#PAGE]        ;OK: find good base to start search
        LDR     R2,[ARGP,#LIBRARYLIST]
        BL      MSGSEARCHLIST
        LDR     R2,[ARGP,#INSTALLLIST]
        BL      MSGSEARCHLIST
        LDR     R2,[ARGP,#OVERPTR]
        TEQ     R2,#0
        BEQ     MSG0START
        ADD     R3,R2,#12
        CMP     R3,LINE                ;test if prog start < error pos: true=CC
        CMPCC   R1,R3                  ;test if prog start > previous prog start: true=CC
        MOVCC   R1,R3                  ;keep r3 if prog start < error pos and prog start > previous start
MSG0START
        MOV     AELINE,R1              ;keep pointer to start of program section
MSG0    CMP     R1,LINE
        BHI     MSG1
        LDRB    R2,[R1,#1]
        CMP     R2,#&FF
        BEQ     MSG1
        LDRB    R0,[R1,#2]
        ADD     R0,R0,R2,LSL #8
        LDRB    R2,[R1,#3]
        ADD     R1,R1,R2
        B       MSG0
MSG1    STR     R0,[ARGP,#ERRLIN]
        ADD     R1,ARGP,#ERRORS
        ADD     R4,R1,#255             ;end of buffer
        ADR     LINE,ERRHAN
        LDR     R0,[R7],#4
        STR     R0,[ARGP,#ERRNUM]
        CMP     R0,#0
        LDRNE   LINE,[ARGP,#ERRORH]
        STREQ   LINE,[ARGP,#ERRORH]
MSGA    LDRB    R0,[R7],#1
        TEQ     R0,#0
        STRNEB  R0,[R1],#1
        BNE     MSGA                   ;save error message
        LDR     R2,[ARGP,#PAGE]
        CMP     R2,AELINE
        BEQ     MSGLIBRARYDONE         ;not in a strange bit
        ADD     AELINE,AELINE,#4
        BL      AESPAC
        CMP     R10,#TREM
        BNE     MSGLIBRARYDONE         ;no REM statement found
        BL      AESPAC
        CMP     R10,#">"
        BLEQ    AESPAC
        CMP     R10,#13
        BEQ     MSGLIBRARYDONE         ;empty
        BL      MSGADDONENDSPC
        MOV     R3,#"i"
        BL      MSGADDONEND
        MOV     R3,#"n"
        BL      MSGADDONEND
        BL      MSGADDONENDSPC
        MOV     R3,#""""
        BL      MSGADDONEND
        MOV     R3,R10
MSGLIBRARYNAME
        BL      MSGADDONEND
        LDRB    R3,[AELINE],#1
        CMP     R3,#" "
        BCS     MSGLIBRARYNAME         ;HI if " " is end of insert
        MOV     R3,#""""
        BL      MSGADDONEND
MSGLIBRARYDONE
        STRB    R0,[R1]                ;write in last 0
; BL SETVAR                                       ;****CHANGE
        LDR     R0,[ARGP,#ERRSTK]
        LDR     R1,[ARGP,#MEMLIMIT]
        CMP     R1,R0
        CMPCS   R0,SP
        BCS     MSGSP1
        MOV     R0,#3
        SWI     BASICTrans_Message
        BVC     MSGSP2
        SWI     WRITES
        =       "Attempt to use badly nested error handler (or corrupt R13).",10,13,0
        ALIGN
MSGSP2  LDR     R1,[ARGP,#HIMEM]
        SUB     R1,R1,#10*4
        STR     R1,[ARGP,#ERRSTK]
        ADR     LINE,ERRHAN
        STR     LINE,[ARGP,#ERRORH]
MSGSP1  BL      POPLOCALAR
        LDR     SP,[ARGP,#ERRSTK]
        B       STMT
MSGADDONENDSPC
        MOV     R3,#" "
MSGADDONEND
        CMP     R1,R4
        STRCCB  R3,[R1],#1
        MOV     PC,R14
MSGSEARCHLIST
        TEQ     R2,#0                  ;end of list
        MOVEQ   PC,R14
        ADD     R3,R2,#4               ;start of prog
        LDR     R2,[R2]                ;next link
        CMP     R3,LINE                ;test if prog start < error pos: true=CC
        CMPCC   R1,R3                  ;test if prog start > previous prog start: true=CC
        MOVCC   R1,R3                  ;keep r3 if prog start < error pos and prog start > previous start
        B       MSGSEARCHLIST
INLINE  ADD     R0,ARGP,#STRACC
        MOV     R1,#238
        MOV     R2,#" "
        MOV     R3,#255
        SWI     READLINE
        BCS     ESCAPE
        ADD     R1,ARGP,#STRACC
        B       CTALLY
NLINE   SWI     NEWLINE
CTALLY  MOV     R2,#0
        STR     R2,[ARGP,#TALLY]
        MOV     PC,R14
ORDERR  ADR     R0,ERRHAN
        STR     R0,[ARGP,#ERRORH]
        MOV     PC,R14
ERRHAN  =       TTRACE,TOFF,":"
        =       TIF,TESCSTMT,TQUIT,TERROR,TEXT,TERR,",",TREPORT,"$",TELSE
        =       TRESTORE,":!(",THIMEM,"-4)=@%:"
        =       TESCSTMT,TSYS,"&62c82,24,",TERL,",",TREPORT,"$",TTO,";@%:"
        =       TIF,"(@%",TAND,"1)=0",":@%=!(",THIMEM,"-4):",TEND,TELSE
        =       "@%=&900:",TREPORT,":",TIF,TERL
        =       TPRINT,""" at line """,TERL,TELSE,TPRINT,13,0,0,0
        =       "@%=!(",THIMEM,"-4):",TEND,13
        ALIGN
;remove from line number in r4 to line number in r5
REMOVE  MOV     R0,R4
        STMFD   SP!,{R14}
        BL      FNDLNO
        MOV     R6,R1
        ADD     R0,R5,#1               ;next line plus one
        BL      FNDLNONEXT             ;continue from where we are now
        CMP     R1,R6
        LDMLSFD SP!,{PC}               ;very easy
        LDR     R0,[ARGP,#TOP]
REMOVL  LDRB    R2,[R1],#1             ;pick up a byte from high up
        STRB    R2,[R6],#1             ;put it low down
        CMP     R1,R0
        BNE     REMOVL
        STR     R6,[ARGP,#TOP]
        LDMFD   SP!,{PC}
INSERT  STMFD   SP!,{R14}              ;insert at end of text
        LDR     R1,[ARGP,#TOP]
        SUB     R1,R1,#2               ;address of cr
        B       INSRTS
;insert the line whose number is in R4, whose first char is ptd to by LINE
INSRT   STMFD   SP!,{R14}
        MOV     R5,R4
        BL      REMOVE
        LDRB    R0,[LINE]
        CMP     R0,#13
        LDMEQFD SP!,{PC}
        MOV     R0,R4
        BL      FNDLNO                 ;get position to R1
        LDRB    R0,[ARGP,#LISTOP]
        TEQ     R0,#0
        BEQ     INSRTS
        BL      SPACES
        SUB     LINE,LINE,#1
INSRTS  MOV     AELINE,LINE
LENGTH  LDRB    R0,[AELINE],#1
        CMP     R0,#13
        BNE     LENGTH
        SUB     AELINE,AELINE,#1
TRALSP  LDRB    R0,[AELINE,#-1]!
        CMP     AELINE,LINE
        BLS     TRALEX
        CMP     R0,#" "
        BEQ     TRALSP
TRALEX  MOV     R0,#13
        STRB    R0,[AELINE,#1]!
        SUB     R6,AELINE,LINE         ;raw length 0..n
        ADD     R6,R6,#4               ;length as desired
        CMP     R6,#256
        BCS     ERLINELONG
        LDR     R2,[ARGP,#TOP]
        ADD     R3,R2,R6               ;calc new TOP
        STR     R3,[ARGP,#TOP]
MOVEUP  LDRB    R0,[R2,#-1]!
        STRB    R0,[R3,#-1]!
        TEQ     R2,R1
        BNE     MOVEUP
        STRB    R4,[R1,#2]
        MOV     R5,R4,LSR #8
        STRB    R5,[R1,#1]             ;lo and hi bytes of line number
        STRB    R6,[R1,#3]!            ;length
INSLP1  LDRB    R0,[LINE],#1
        STRB    R0,[R1,#1]!
        CMP     R0,#" "
        BEQ     INSLP1
        TEQ     R0,#13
        LDMEQFD SP!,{PC}
        TEQ     R0,#TELSE
        MOVEQ   R0,#TELSE2
        STREQB  R0,[R1]
INSLP2  LDRB    R0,[LINE],#1
        STRB    R0,[R1,#1]!
        TEQ     R0,#13
        BNE     INSLP2
        LDMFD   SP!,{PC}
 [ RELEASEVER=0
PATOUT  BIC     R2,R14,#&FC000003
        BL      PATA
        BL      PATA
        BL      PATA
        BL      PATA
        BL      PATA
        BL      PATA
        SWI     WRITEI+23
        SWI     WRITEI+" "
        MOV     R1,#8
        BL      ZEROX                  ;8 zeroes
        MOV     PC,R2
PATA    LDR     R0,[R2],#4
        SWI     WRITEI+23
        SWI     WRITEI+" "
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        LDR     R0,[R2],#4
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        MOV     R0,R0,ROR #8
        SWI     WRITEC
        SWI     WRITEI+" "
        MOV     PC,R14
 ]
        ^       &7F                    ;single byte tokens
TOTHER                          #       1
TAND                            #       1                      ;expression binary operators
TDIV                            #       1
TEOR                            #       1
TMOD                            #       1
TOR                             #       1

TERROR                          #       1                      ;miscellaneous words
TLINE                           #       1
TOFF                            #       1
TSTEP                           #       1
TSPC                            #       1
TTAB                            #       1
TELSE                           #       1
TTHEN                           #       1

TCONST                          #       1                      ;(8D)

TOPENU                          #       1

TPTR                            #       1                      ;polymorphics as functions
TPAGE                           #       1
TTIME                           #       1
TLOMEM                          #       1
THIMEM                          #       1
TABS                            #       1                      ;expression class of unary operators
TACS                            #       1
TADC                            #       1
TASC                            #       1
TASN                            #       1
TATN                            #       1
TBGET                           #       1
TCOS                            #       1
TCOUNT                          #       1
TDEG                            #       1
TERL                            #       1
TERR                            #       1
TEVAL                           #       1
TEXP                            #       1
TEXT                            #       1
TFALSE                          #       1
TFN                             #       1
TGET                            #       1
TINKEY                          #       1
TINSTR                          #       1
TINT                            #       1
TLEN                            #       1
TLN                             #       1
TLOG                            #       1
TNOT                            #       1
TOPENI                          #       1
TOPENO                          #       1
TPI                             #       1
TPOINT                          #       1
TPOS                            #       1
TRAD                            #       1
TRND                            #       1
TSGN                            #       1
TSIN                            #       1
TSQR                            #       1
TTAN                            #       1
TTO                             #       1
TTRUE                           #       1
TUSR                            #       1
TVAL                            #       1
TVPOS                           #       1
TCHRD                           #       1                      ;string expression class of unary operators
TGETD                           #       1
TINKED                          #       1
TLEFTD                          #       1
TMIDD                           #       1
TRIGHTD                         #       1
TSTRD                           #       1
TSTRND                          #       1
TEOF                            #       1

TESCFN                          #       1                      ;Escape for Functions
TESCCOM                         #       1                      ;Escape for Commands
TESCSTMT                        #       1                      ;Escape for Statements

TWHEN                           #       1                      ;statements
TOF                             #       1
TENDCA                          #       1
TELSE2                          #       1
TENDIF                          #       1
TENDWH                          #       1

TPTR2                           #       1                      ;polymorphic again
TPAGE2                          #       1
TTIME2                          #       1
TLOMM2                          #       1
THIMM2                          #       1

TBEEP                           #       1
TBPUT                           #       1
TCALL                           #       1
TCHAIN                          #       1
TCLEAR                          #       1
TCLOSE                          #       1
TCLG                            #       1
TCLS                            #       1
TDATA                           #       1
TDEF                            #       1
TDIM                            #       1
TDRAW                           #       1
TEND                            #       1
TENDPR                          #       1
TENVEL                          #       1
TFOR                            #       1
TGOSUB                          #       1
TGOTO                           #       1
TGRAPH                          #       1
TIF                             #       1
TINPUT                          #       1
TLET                            #       1
TLOCAL                          #       1
TMODE                           #       1
TMOVE                           #       1
TNEXT                           #       1
TON                             #       1
TVDU                            #       1
TPLOT                           #       1
TPRINT                          #       1
TPROC                           #       1
TREAD                           #       1
TREM                            #       1
TREPEAT                         #       1
TREPORT                         #       1
TRESTORE                        #       1
TRETURN                         #       1
TRUN                            #       1
TSTOP                           #       1
TTEXT                           #       1
TTRACE                          #       1
TUNTIL                          #       1
TWIDTH                          #       1
TOSCL                           #       1                      ;this must be <=&FF (!)

        ^       &8E                    ;Two byte function tokens
TSUM                            #       1
TBEAT                           #       1
TTWOFUNCLIMIT                   #       0

        ^       &8E                    ;Two byte Statement tokens
TCASE                           #       1
TCIRCLE                         #       1
TFILL                           #       1
TORGIN                          #       1
TPSET                           #       1
TRECT                           #       1
TSWAP                           #       1
TWHILE                          #       1
TWAIT                           #       1
TMOUSE                          #       1
TQUIT                           #       1
TSYS                            #       1
TINSTALLBAD                     #       1                      ;a silly blunder
TLIBRARY                        #       1
TTINT                           #       1
TELLIPSE                        #       1
TBEATS                          #       1
TTEMPO                          #       1
TVOICES                         #       1
TVOICE                          #       1
TSTEREO                         #       1
TOVERLAY                        #       1
TTWOSTMTLIMIT                   #       0

        ^       &8E                    ;Two byte Command tokens
TAPPEND                         #       1
TAUTO                           #       1
TCRUNCH                         #       1
TDELET                          #       1
TEDIT                           #       1
THELP                           #       1
TLIST                           #       1
TLOAD                           #       1
TLVAR                           #       1
TNEW                            #       1
TOLD                            #       1
TRENUM                          #       1
TSAVE                           #       1
TTEXTLOAD                       #       1
TTEXTSAVE                       #       1
TTWIN                           #       1
TTWINO                          #       1
TINSTALL                        #       1
TTWOCOMMLIMIT                   #       0

        LNK     s.Fp
