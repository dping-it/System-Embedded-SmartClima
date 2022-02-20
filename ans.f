\ Embedded Systems - Sistemi Embedded - 17873
\ some dictionary definitions
\ from  pijFORTHos and prof. D. Peri
\ modificated by Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ '\n'	newline character (10)
: '\n' 10 ;
\ BL	blank character (32)
: BL 32 ;

: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

\ ?IMMEDIATE	( entry -- p )	get IMMEDIATE flag from dictionary entry
\ ( comment text ) 	( -- )	comment inside definition
\ SPACES	( n -- )	print n spaces
\ WITHIN	( a b c -- p )	where p = ((a >= b) && (a < c))
\ ALIGNED	( addr -- addr' )	round addr up to next 4-byte boundary
\ ALIGN	( -- )	align the HERE pointer
\ C,	( c -- )	write a byte from the stack at HERE
\ S" string"	( -- addr len )	create a string value
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

\ ." string"	( -- )	print string
: ." IMMEDIATE ( -- )
    STATE @ IF
        [COMPILE] S" ' TELL ,
    ELSE
        BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
    THEN
;

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

\ JF-WORDS	( -- )	print all the words defined in the dictionary
: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

\ ['] name	( -- xt )	compile LIT
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
: UNUSED ( -- n ) PAD HERE @ - 4/ ;

\ Control Structures
\ Word	Stack	Description
\ EXIT	( -- )	restore FIP and return to caller
\ BRANCH offset	( -- )	change FIP by following offset
\ 0BRANCH offset	( p -- )	branch if the top of the stack is zero
\ IF true-part THEN	( p -- )	conditional execution
\ IF true-part ELSE false-part THEN	( p -- )	conditional execution
\ UNLESS false-part ...	( p -- )	same as NOT IF
\ BEGIN loop-part p UNTIL	( -- )	post-test loop
\ BEGIN loop-part AGAIN	( -- )	infinite loop (until EXIT)
\ BEGIN p WHILE loop-part REPEAT	( -- )	pre-test loop
\ CASE cases... default ENDCASE	( selector -- )	select case based on selector value
\ value OF case-body ENDOF	( -- )	execute case-body if (selector == value)

DROP

\ Ritorna informazioni sull'autore delle modifiche
: AUTHOR
    S" TEST-MODE" FIND NOT IF
        ." AUTHOR DAVIDE PROIETTO " VERSION . CR
        UNUSED . ." CELLS REMAINING" CR
        ." OK "
    THEN
;
