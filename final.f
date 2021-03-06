
: '\n' 10 ;
: BL 32 ;

: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;

: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;

: SPACES BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;

: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;

: ALIGNED 3 + 3 INVERT AND ;

: ALIGN HERE @ ALIGNED HERE ! ;

: C, HERE @ C! 1 HERE +! ;

: S" IMMEDIATE ( -- addr len )
    STATE @ IF
        ' LITS , HERE @ 0 ,
        BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
        DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
    ELSE
        HERE @
        BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
        DROP HERE @ - HERE @ SWAP
    THEN
;

: ." IMMEDIATE ( -- )
    STATE @ IF
        [COMPILE] S" ' TELL ,
    ELSE
        BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
    THEN
;

: DICT WORD FIND ;
: VALUE ( n -- ) WORD CREATE DOCOL , ' LIT , , ' EXIT , ;
: TO IMMEDIATE ( n -- )
        DICT >DFA 4+
	STATE @ IF ' LIT , , ' ! , ELSE ! THEN
;
: +TO IMMEDIATE
        DICT >DFA 4+
	STATE @ IF ' LIT , , ' +! , ELSE +! THEN
;
: ID. 4+ COUNT F_LENMASK AND BEGIN DUP 0> WHILE SWAP COUNT EMIT SWAP 1- REPEAT 2DROP ;
: ?HIDDEN 4+ C@ F_HIDDEN AND ;
: ?IMMEDIATE 4+ C@ F_IMMED AND ;
: WORDS LATEST @ BEGIN ?DUP WHILE DUP ?HIDDEN NOT IF DUP ID. SPACE THEN @ REPEAT CR ;
: FORGET DICT DUP @ LATEST ! HERE ! ;
: CFA> LATEST @ BEGIN ?DUP WHILE 2DUP SWAP < IF NIP EXIT THEN @ REPEAT DROP 0 ;
: SEE
	DICT HERE @ LATEST @
	BEGIN 2 PICK OVER <> WHILE NIP DUP @ REPEAT
	DROP SWAP ':' EMIT SPACE DUP ID. SPACE
	DUP ?IMMEDIATE IF ." IMMEDIATE " THEN
	>DFA BEGIN 2DUP
        > WHILE DUP @ CASE
		' LIT OF 4 + DUP @ . ENDOF
		' LITS OF [ CHAR S ] LITERAL EMIT '"' EMIT SPACE
			4 + DUP @ SWAP 4 + SWAP 2DUP TELL '"' EMIT SPACE + ALIGNED 4 -
		ENDOF
		' 0BRANCH OF ." 0BRANCH ( " 4 + DUP @ . ." ) " ENDOF
		' BRANCH OF ." BRANCH ( " 4 + DUP @ . ." ) " ENDOF
		' ' OF [ CHAR ' ] LITERAL EMIT SPACE 4 + DUP @ CFA> ID. SPACE ENDOF
		' EXIT OF 2DUP 4 + <> IF ." EXIT " THEN ENDOF
		DUP CFA> ID. SPACE
	ENDCASE 4 + REPEAT
	';' EMIT CR 2DROP
;
: :NONAME 0 0 CREATE HERE @ DOCOL , ] ;
: ['] IMMEDIATE ' LIT , ;
: EXCEPTION-MARKER RDROP 0 ;
: CATCH ( xt -- exn? ) DSP@ 4+ >R ' EXCEPTION-MARKER 4+ >R EXECUTE ;
: THROW ( n -- ) ?DUP IF
    RSP@ BEGIN DUP R0 4-
        < WHILE DUP @ ' EXCEPTION-MARKER 4+
        = IF 4+ RSP! DUP DUP DUP R> 4- SWAP OVER ! DSP! EXIT THEN
    4+ REPEAT DROP
    CASE
        0 1- OF ." ABORTED" CR ENDOF
        ." UNCAUGHT THROW " DUP . CR
    ENDCASE QUIT THEN
;
: ABORT ( -- ) 0 1- THROW ;

: JF-HERE   HERE ;
: JF-CREATE   CREATE ;
: JF-FIND   FIND ;

: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

: [']   ' LIT , ; IMMEDIATE
: '   JF-WORD JF-FIND >CFA ;

: CELL+  4 + ;

: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

: DOES>CUT   LATEST @ >CFA @ DUP JF-HERE @ > IF JF-HERE ! ;

: CREATE   JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT)  ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ;
: (DODOES-COMP)  (DODOES-INT) ['] LIT , , ['] FIP! , ;
: DOES>COMP   ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT   (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES>   STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE

: PRINT-STACK-TRACE
	RSP@ BEGIN DUP R0 4-
        < WHILE DUP @ CASE
		' EXCEPTION-MARKER 4+ OF ." CATCH ( DSP=" 4+ DUP @ U. ." ) " ENDOF
		DUP CFA> ?DUP IF 2DUP ID. [ CHAR + ] LITERAL EMIT SWAP >DFA 4+ - . THEN
	ENDCASE 4+ REPEAT DROP CR
;

: UNUSED ( -- n ) PAD HERE @ - 4/ ;


: AUTHOR
    S" TEST-MODE" FIND NOT IF
        ." AUTHOR DAVIDE PROIETTO " VERSION . CR
        UNUSED . ." CELLS REMAINING" CR
        ." OK "
    THEN
;


HEX

FE000000 CONSTANT BASE  

BASE 200000 + CONSTANT GPFSEL0 
BASE 200004 + CONSTANT GPFSEL1
BASE 200008 + CONSTANT GPFSEL2

BASE 200040 + CONSTANT GPEDS0

BASE 20001C + CONSTANT GPSET0

BASE 200028 + CONSTANT GPCLR0

BASE 200034 + CONSTANT GPLEV0

BASE 200058 + CONSTANT GPFEN0

BASE 20007C + CONSTANT GPAREN0

: MASK 1 SWAP LSHIFT ;

: HIGH 
  MASK GPSET0 ! ;

: LOW 
  MASK GPCLR0 ! ;

: TPIN GPLEV0 @ SWAP RSHIFT 1 AND ;

: DELAY 
  BEGIN 1 - DUP 0 = UNTIL DROP ;

DECIMAL

: GPIO DUP 30 > IF ABORT THEN ;

: MODE 10 /MOD 4 * GPFSEL0 + SWAP 3 * DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

: OUTPUT 1 SWAP LSHIFT OR SWAP ! ;

: INPUT 1 SWAP LSHIFT INVERT AND SWAP ! ;



: ON 1 SWAP LSHIFT GPSET0 ! ;

: OFF 1 SWAP LSHIFT GPCLR0 ! ;

: LEVEL 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

: GPFSELOUT! GPIO MODE OUTPUT ;

: GPFSELIN! GPIO MODE INPUT ;

: GPON! GPIO ON ;

: GPOFF! GPIO OFF ;

: GPLEV@ GPIO LEVEL ;

: GPAFEN! GPIO 1 SWAP LSHIFT GPFEN0 ! ;

HEX







: SETUP_I2C 
  900 GPFSEL0 @ OR GPFSEL0 ! ;

: RESET_S 
  302 BASE 804004 + ! ;

: RESET_FIFO
  10 BASE 804000 + ! ;

: SET_SLAVE 
  27 BASE 80400C + ! ;

: STORE_DATA
  BASE 804010 + ! ;

: SEND 
  8080 BASE 804000 + ! ;

: >I2C
  RESET_S
  RESET_FIFO
  1 BASE 804008 + !
  SET_SLAVE
  STORE_DATA
  SEND ;

: 4BM>LCD 
  F0 AND DUP ROT
  D + OR >I2C 1000 DELAY
  8 OR >I2C 1000 DELAY ;

: 4BL>LCD 
  F0 AND DUP
  D + OR >I2C 1000 DELAY
  8 OR >I2C 1000 DELAY ;

: >LCDL
 DUP 4 RSHIFT 4BL>LCD
 4BL>LCD ;

: >LCDM
  OVER OVER F0 AND 4BM>LCD
  F AND 4 LSHIFT 4BM>LCD ;

: IS_CMD 
  DUP 8 RSHIFT 1 = ;

: >LCD 
  IS_CMD SWAP >LCDM 
;


: WELCOME
    57 >LCD 
    45 >LCD
    4C >LCD
    43 >LCD  
    4F >LCD
    4D >LCD
    45 >LCD 
    20 >LCD ;

: SMART 
    53 >LCD 
    4D >LCD
    41 >LCD
    52 >LCD  
    54 >LCD
    20 >LCD ;

: CLIMA 
    43 >LCD 
    4C >LCD
    49 >LCD
    4D >LCD  
    41 >LCD
    20 >LCD ;

  : SYSTEM 
    53 >LCD
    59 >LCD  
    53 >LCD
    54 >LCD
    45 >LCD
    4D >LCD
    20 >LCD ;

: READY 
    52 >LCD 
    45 >LCD
    41 >LCD
    44 >LCD  
    59 >LCD 
    20 >LCD ;

: BUSY 
    42 >LCD 
    55 >LCD
    53 >LCD
    59 >LCD 
    20 >LCD ;

: LIGHT 
    4C >LCD 
    49 >LCD
    47 >LCD
    48 >LCD 
    54 >LCD
    20 >LCD ;

: WIND 
    57 >LCD 
    49 >LCD
    4E >LCD
    44 >LCD 
    20 >LCD ;

: STOP 
    53 >LCD 
    54 >LCD
    4F >LCD
    50 >LCD 
    20 >LCD ;

: INSERT 
    49 >LCD
    4E >LCD
    53 >LCD 
    45 >LCD
    52 >LCD
    54 >LCD
    20 >LCD ;

: TIME 
    54 >LCD
    49 >LCD
    4D >LCD 
    45 >LCD
    20 >LCD ;


: CLEAR
  101 >LCD ;

: >LINE2
  1C0 >LCD ;

: SETUP_LCD 
  102 >LCD ;


5 CONSTANT YELLOWLED
6 CONSTANT REDLED
C CONSTANT GREENLED

: SETUP_LED 
    REDLED GPFSELOUT! 
    YELLOWLED GPFSELOUT!
    GREENLED GPFSELOUT! ;

: ALL_LED_ON 
  REDLED GPON!
  YELLOWLED GPON!
  GREENLED GPON!
;

: SYSTEMLIGHT YELLOWLED GPON! ;

: SYSTEMWIND GREENLED GPON! ;

: TURNOFF ( pin -- ) GPOFF! ;

: STOPLIGHT YELLOWLED GPOFF! ;

: STOPWIND GREENLED GPOFF! ;

VARIABLE LIGHTIME 
VARIABLE WINDTIME

1 LIGHTIME !
1 WINDTIME !




: SETUP_ROWS 
  3840000 GPFEN0 ! ;





: SETUP_IO 
  1000000 GPFSEL1 @ OR GPFSEL1 ! 
  9200 GPFSEL2 @ OR GPFSEL2 ! ;

: CLEAR_ROWS 
  3840000 GPCLR0 ! ;

: SETUP_KEYPAD 
  SETUP_ROWS 
  SETUP_IO 
  CLEAR_ROWS ;

: PRESSED 
  TPIN 1 = IF 1 ELSE 0 THEN ;

3 CONSTANT RANGE 

VARIABLE FLAG
VARIABLE CAS
VARIABLE COS
VARIABLE CASS
VARIABLE COSS

1 FLAG !

: FLAGOFF  0 FLAG ! ; 

: FLAGON  1 FLAG ! ; 

CREATE COUNTER

: COUNTER++ 
  COUNTER @ 1 + COUNTER ! ;

: EMIT_STORE 
  COUNTER @ 0 = IF LIGHT 1000 DELAY ELSE
  COUNTER @ 2 = IF >LINE2 WIND 1000 DELAY
  THEN THEN
  DUP 500 DELAY >LCD 
  DUP 30 -  \ . CONSUMA LO STACK
  DUP .
  DUP -15 = IF CLEAR ALL_LED_ON SYSTEM STOP 30000 DELAY ." EXIT TO END PROGRAM " FLAGOFF CR AUTHOR CR CR EXIT ELSE 

  DUP COUNTER @ 0 = IF DUP CAS ! DUP 4 LSHIFT LIGHTIME ! ELSE
  DUP COUNTER @ 1 = IF DUP CASS ! DUP LIGHTIME @ + LIGHTIME ! ELSE
  DUP COUNTER @ 2 = IF DUP COS ! DUP 4 LSHIFT WINDTIME !  ELSE
  DUP COUNTER @ 3 = IF DUP COSS ! DUP WINDTIME @ + WINDTIME ! 
  THEN THEN THEN THEN THEN
  ;

: EMITC1 
  DUP 11 = IF 2A DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 5E DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 5F DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 1B DUP EMIT_STORE DROP ELSE 
  19 = IF D DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

: EMITC2 
  DUP 11 = IF 23 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 33 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 36 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 39 DUP EMIT_STORE DROP ELSE 
  19 = IF 3E DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

: EMITC3 
  DUP 11 = IF 25 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 32 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 35 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 38 DUP EMIT_STORE DROP ELSE 
  19 = IF 30 DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

: EMITC4 
  DUP 11 = IF 24 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 31 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 34 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 37 DUP EMIT_STORE DROP ELSE 
  19 = IF 3C DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

: EMIT_R
  DUP 10 = IF DROP EMITC1 ELSE 
  DUP 16 = IF DROP EMITC2 ELSE 
  DUP 1B = IF DROP EMITC3 ELSE 
  A = IF EMITC4 
  THEN THEN THEN THEN ;

: CHECK_CL 
  DUP DUP
    PRESSED 1 = IF 1000 DELAY 
    PRESSED 0 = IF 1000 DELAY 
      EMIT_R
      COUNTER++ 
    ELSE DROP DROP 
    THEN
    ELSE DROP DROP DROP 
  THEN ;

: CHECK_ROW
  DUP DUP DUP DUP DUP 
  HIGH  
    10 CHECK_CL 
    16 CHECK_CL
    1B CHECK_CL
    A CHECK_CL
  LOW ;

: ?CTR 
  COUNTER @ 4 = ;

: RES_CTR 
  0 COUNTER ! ;

: ?CTF 
  FLAG @ 0 = ;

: DETECT
  CLEAR
  0 COUNTER !
  BEGIN 
    11 CHECK_ROW
    12 CHECK_ROW
    17 CHECK_ROW
    18 CHECK_ROW
    19 CHECK_ROW
  ?CTR UNTIL 
  0  CR \ LIGHTIME @ . ." <- LIGHTIME " CR WINDTIME @ . ." <- WINDTIME " CR 
  ." RUN SYSTEM . . . " CR
  ." SETTING TIME LIGHT >>>    "  CAS @ . CASS @ . ."    SECONDS " CR  
  ." SETTING TIME WIND >>>    "  COS @ . COSS @ . ."    SECONDS " CR CR ;  


HEX


: 4DROP DROP DROP DROP DROP ;

00FFFFFF CONSTANT WHITE
00000000 CONSTANT BLACK
00FF0000 CONSTANT RED
00FFFF00 CONSTANT YELLOW
0000FF00 CONSTANT GREEN
000000FF CONSTANT BLUE

3E8FA000 CONSTANT FRAMEBUFFER

VARIABLE DIM

VARIABLE COUNTERH


: RESETCOUNTERH 0 COUNTERH ! ;

: +COUNTERH COUNTERH @ 1 + COUNTERH ! ;

VARIABLE NLINE
: RESETNLINE 1 NLINE ! ;
: +NLINE NLINE @ 1 + NLINE ! ;

( -- addr )
: CENTER FRAMEBUFFER 200 4 * + 180 1000 * + ;

( color addr -- color addr_col+1 )
: RIGHT 2DUP ! 4 + ;


( color addr -- color addr_row+1 )
: DOWN 2DUP ! 1000 + ;


( color addr -- color addr_col-1 )
: LEFT 2DUP ! 4 - ;


( addr_endline_right -- addr )
: RIGHTRESET COUNTERH @ 4 * - ;


( addr_endline_left -- addr )
: LEFTRESET COUNTERH @ 4 * + ;


: RIGHTDRAW
    BEGIN COUNTERH @ DIM @ < WHILE +COUNTERH RIGHT REPEAT RIGHTRESET RESETCOUNTERH ;

: LEFTDRAW
    BEGIN COUNTERH @ DIM @ < WHILE +COUNTERH LEFT REPEAT LEFTRESET RESETCOUNTERH ;


: DRAWSQUARE
    80 DIM !
    CENTER 140 - RIGHTDRAW
    BEGIN NLINE @ 70 <
        WHILE
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

: DRAWSTARTWIND
    GREEN CENTER 80 -
    BEGIN NLINE @ 70 <=
        WHILE
            NLINE @ 37 <= IF
            NLINE @ DIM !
                ELSE
                    70 NLINE @ - DIM !
            THEN
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

: DRAWSTARTLIGHT
    YELLOW CENTER 80 -
    BEGIN NLINE @ 70 <=
        WHILE
            NLINE @ 37 <= IF
            NLINE @ DIM !
                ELSE
                    70 NLINE @ - DIM !
            THEN
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

: DRAWSTOP RED DRAWSQUARE ;

: CLEAN BLACK DRAWSQUARE ;

: DRAWITAFLAG

    WHITE DRAWSQUARE
    30 DIM !
    RED CENTER RIGHTDRAW
    GREEN CENTER 80 - LEFTDRAW
    BEGIN NLINE @ 70 <
        WHILE
            DOWN LEFTDRAW
            2SWAP
            DOWN RIGHTDRAW
            2SWAP
            +NLINE
        REPEAT
    4DROP RESETNLINE
;


HEX 

BASE 003004 + CONSTANT CLO

F4240 CONSTANT SEC

VARIABLE COMP0

VARIABLE TIME_COUNTER

0 TIME_COUNTER !

0 COMP0 !

( -- clo_value )
: NOW CLO @ ;
( delay_sec -- )
: DELAY_SEC NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;

: PARSE_DEC_HEX ( n1 -- n3 n2 ) 10 /MOD A * SWAP + DUP . ." >> SECONDS " ;

: INC NOW SEC + COMP0 ! ;



: SLEEPS DECIMAL INC BEGIN NOW COMP0 @ < WHILE REPEAT DUP U. ." | " DROP DECIMAL ;

: DECCOUNT TIME_COUNTER @ 1 - TIME_COUNTER ! ;
: INCCOUNT TIME_COUNTER @ 1 + TIME_COUNTER ! ;


DECIMAL : TIMER PARSE_DEC_HEX TIME_COUNTER ! CR begin TIME_COUNTER @ SLEEPS DECCOUNT TIME_COUNTER @ 0 = until CR
 ." END EROGATION " CR CR DROP ;

HEX



HEX

: SETUP_BUTTON 
  40000 GPFSEL2 @ OR GPFSEL2 ! 
;



: GPAREN! 4000000 GPAREN0 @ OR GPAREN0 ! ;


HEX
: GO_LIGHT 
  REDLED GPOFF!
  STOPWIND
  CLEAR
  CLEAN
  DRAWSTARTLIGHT
  SYSTEM
  LIGHT
  SYSTEMLIGHT
  ;

: GO_WIND 
  REDLED GPOFF!
  STOPLIGHT
  CLEAR
  CLEAN
  DRAWSTARTWIND
  SYSTEM
  WIND
  SYSTEMWIND
  ;

: STOP_DISP 
  ALL_LED_ON
  CLEAR
  CLEAN
  DRAWSTOP
  SYSTEM
  STOP
  ;

: RUN 0 COUNTER ! 
  BEGIN                   
    FLAG @ 1 = WHILE 
      GO_LIGHT ." SYSTEM LIGHT "  LIGHTIME @ TIMER 
      GO_WIND ." SYSTEM WIND " WINDTIME @ TIMER 
      COUNTER++ 
      COUNTER @ 4 = IF  FLAGOFF THEN
      ." Cycle n. " 
      COUNTER @ .
      ." Flag setting " 
      FLAG @ .
      CR CR
    REPEAT
  ?CTF UNTIL FLAGON STOP_DISP 10000 DELAY ." END AUTOMATIC CYCLE " CR CLEAR INSERT TIME 10000 DELAY ; \ Riutilizzo di flag per gestire il ciclo principale.


: SETUP
  CLEAN
  DRAWITAFLAG
  SETUP_I2C
  SETUP_LCD
  SETUP_KEYPAD
  SETUP_LED
  CLEAR
  WELCOME
  >LINE2
  SMART
  CLIMA
  50000 DELAY
  CLEAR
  STOP_DISP 
  20000 DELAY
  CLEAR
  INSERT TIME
  40000 DELAY
    BEGIN
    FLAGON
    DETECT 
    1 
    RUN 20000 DELAY
    ?CTF UNTIL 
    ;


  : ONLY_SETUP
  CLEAN
  DRAWITAFLAG
  SETUP_I2C
  SETUP_LCD
  SETUP_KEYPAD
  SETUP_LED
  CLEAR
  WELCOME
  >LINE2
  SMART
  CLIMA
  30000 DELAY
  CLEAR
  STOP_DISP
  ;

: POWER_ON GPEDS0 @ 4000000 = IF ." PREMUTO TASTO AVVIO DEL SISTEMA " CR SETUP THEN 0 GPEDS0 ! ;

: START
    SETUP_BUTTON
    GPAREN!
    BEGIN
      WHILE
        POWER_ON
      REPEAT
    0 GPEDS0 !
;

START
