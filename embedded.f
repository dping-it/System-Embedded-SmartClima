\ Embedded Systems - Sistemi Embedded - 17873
\ some dictionary definitions
\ from  pijFORTHos
\ modificated by Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ '\n'	newline character (10)
: '\n' 10 ;
\ BL	blank character (32)
: BL 32 ;

\ STANDARD CHAR
: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;

\ ?IMMEDIATE	( entry -- p )	get IMMEDIATE flag from dictionary entry
\ ( comment text ) 	( -- )	comment inside definition
: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;

\ SPACES	( n -- )	print n spaces
: SPACES BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;

\ WITHIN	( a b c -- p )	where p = ((a >= b) && (a < c))
: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;

\ ALIGNED	( addr -- addr' )	round addr up to next 4-byte boundary
: ALIGNED 3 + 3 INVERT AND ;

\ ALIGN	( -- )	align the HERE pointer
: ALIGN HERE @ ALIGNED HERE ! ;

\ C,	( c -- )	write a byte from the stack at HERE
: C, HERE @ C! 1 HERE +! ;

\ S" string"	( -- addr len )	create a string value
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

\ ." STRING"	( -- )	print string
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

: PRINT-STACK-TRACE
	RSP@ BEGIN DUP R0 4-
        < WHILE DUP @ CASE
		' EXCEPTION-MARKER 4+ OF ." CATCH ( DSP=" 4+ DUP @ U. ." ) " ENDOF
		DUP CFA> ?DUP IF 2DUP ID. [ CHAR + ] LITERAL EMIT SWAP >DFA 4+ - . THEN
	ENDCASE 4+ REPEAT DROP CR
;
: BINARY ( -- ) 2 BASE ! ;
: OCTAL ( -- ) 8 BASE ! ;
: 2# BASE @ 2 BASE ! WORD NUMBER DROP SWAP BASE ! ;
: 8# BASE @ 8 BASE ! WORD NUMBER DROP SWAP BASE ! ;
: # ( b -- n ) BASE @ SWAP BASE ! WORD NUMBER DROP SWAP BASE ! ;

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

\ Ritorna informazioni sull'autore delle modifiche
: AUTHOR
    S" TEST-MODE" FIND NOT IF
        ." AUTHOR DAVIDE PROIETTO " VERSION . CR
        UNUSED . ." CELLS REMAINING" CR
        ." OK "
    THEN
;
\ Embedded Systems - Sistemi Embedded - 17873
\ Settaggi GPIO 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie ans.f

\ GPIO Mapping
HEX
FE000000 CONSTANT BASE  \ Indirizzo base dei registri
BASE 200000 + CONSTANT GPFSEL0  \ Spazio dei registri GPIO FE200000 
BASE 200004 + CONSTANT GPFSEL1
BASE 200008 + CONSTANT GPFSEL2
BASE 200040 + CONSTANT GPEDS0
BASE 20001C + CONSTANT GPSET0
BASE 200028 + CONSTANT GPCLR0
BASE 200034 + CONSTANT GPLEV0
BASE 200058 + CONSTANT GPFEN0

\ Applica lo spostamento logico sinistro di 1 bit sul valore dato
\ e restituisce il valore spostato
\ Utilizzo: 2 MASK
   \ 2( BIN 0010 ) -> 4( BIN 0100 ) 
: MASK 1 SWAP LSHIFT ;

\ Imposta il pin GPIO specificato su HIGH se configurato come output
\ Utilizzo: 12 ( pin fisico ) HIGH -> Imposta il GPIO-18 su HIGH 
: HIGH 
  MASK GPSET0 ! ;

\ Resetta il pin GPIO specificato se configurato come output
\ Utilizzo: 12 ( pin fisico ) LOW -> Resetta il GPIO-18 
: LOW 
  MASK GPCLR0 ! ;

\ Verifica il valore effettivo dei pin GPIO 0..31
\ 0 -> Il pin GPIO n è LOW
\ 1 -> Il pin GPIO n è HIGH
\ Utilizzo: 12 TPIN (Test GPIO-18) 
: TPIN GPLEV0 @ SWAP RSHIFT 1 AND ;

\ Crea un tempo di attesa in millisecondi
\ Utilizzo: 1000 DELAY
: DELAY 
  BEGIN 1 - DUP 0 = UNTIL DROP ;

DECIMAL

\ GPIO ( n -- n ) prende il numero pin GPIO e verifica se è inferiore a 27, altrimenti interrompe
: GPIO DUP 30 > IF ABORT THEN ;

\ MODE ( n -- a b c) prende il numero del pin GPIO e lascia nello stack il numero del bit di spostamento a sinistra (a) richiesto per impostare i corrispondenti bit di controllo GPIO di GPFSELN,
\ dove N è il numero del registro, insieme all'indirizzo del registro GPFSELN (b) e al valore corrente memorizzato in (c) cancellato da una MASCHERA;
\ N ad (a) sono calcolati dividendo il numero GPIO per 10; N è il quoziente moltiplicato per 4 mentre a è il promemoria. Quindi GPFSELN viene calcolato da GPFSEL0 + N
\ (es. GPIO 21 è controllato da GPFSEL2 quindi 21 / 10 --> N = 2 * 4, a = 1 --> GPFSEL0 + 8 = GPFSEL2 )
\ MASK viene utilizzato per cancellare i 3 bit del registro GPFSEL che controlla gli stati GPIO utilizzando INVERT AND e il valore (a)
\ La maschera si ottiene spostando a sinistra 7 (111 binary ) di 3 * (resto di 10 divisioni), ad esempio 21 / 10 -> 3 * 1 -> 7 spostato a sinistra di 3 ).
: MODE 10 /MOD 4 * GPFSEL0 + SWAP 3 * DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

\ OUTPUT (a b c -- ) attiva l'uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come uscita.
\ Il bit GPFSELN che controlla l'uscita GPIO è impostato dall'operazione OR tra il valore corrente di GPFSELN, cancellato dalla maschera, e un 1 spostato a sinistra dal promemoria di 10
\ divisione moltiplicata per 3. (il valore 001 nella posizione del bit corrispondente di GPFSELN imposta GPIO come OUTPUT)
\ es. con GPIO 21 AND @GPFSEL2: 011010--> 111000 011010 INVERT AND --> 000010 001000 OR --> 001010
: OUTPUT 1 SWAP LSHIFT OR SWAP ! ;

\ INPUT (a b c -- ) attiva l'uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come input.
\ Uguale a OUTPUT ma elimina il valore di spostamento non necessario e il bit GPFSELN che controlla l'ingresso GPIO è impostato dal
\ INVERTE AND operazione tra il valore corrente di GPFSELN, azzerato dalla maschera,
: INPUT 1 SWAP LSHIFT INVERT AND SWAP ! ;

\ ON ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPCLR0
: ON 1 SWAP LSHIFT GPSET0 ! ;

\ OFF ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPSET0
: OFF 1 SWAP LSHIFT GPCLR0 ! ;

\ LEVEL ( n -- b ) prende il numero pin GPIO, sposta a sinistra 1 di questo numero, ottiene il valore corrente del registro GPLEV0 e lascia nello stack il valore del corrispondente
\ Bit numero pin GPIO
: LEVEL 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

\ GPFSELOUT! scorciatoia per impostare gpio come output
: GPFSELOUT! GPIO MODE OUTPUT ;

\ GPFSELIN! scorciatoia per impostare gpio come input
: GPFSELIN! GPIO MODE INPUT ;

\ GPFSELOUT! scorciatoia per impostare gpio HIGH
: GPON! GPIO ON ;

\ GPFSELOUT! scorciatoia per impostare gpio low
: GPOFF! GPIO OFF ;

\ GPFSELOUT! scorciatoia per ottenere il livello gpio
: GPLEV@ GPIO LEVEL ;

\ GPAFEN ( n -- ) imposta il registro GPAFEN0 per il pin gpio n per l'evento di caduta asincrono
: GPAFEN! GPIO 1 SWAP LSHIFT GPFEN0 ! ;

HEX
\ Embedded Systems - Sistemi Embedded - 17873
\ I2C Driver  
\ Università degli Studi di Palermo
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo gpio.f

\ Ci sono otto master Broadcom Serial Controller (BSC) all'interno di BCM2711,
\ BSC2 e BSC7 sono dedicati all'uso da parte delle interfacce HDMI, qui utilizziamo BSC1 all'indirizzo: 0xFE804000  

\ Per utilizzare l'interfaccia I2C, basta aggiungere i seguenti offset all'indirizzo del registro BCS1.
\ Ogni registro è lungo 32 bit

\ 0x0 -> Control Register ( usato per abilitare gli interrupt, cancellare il FIFO, definire un'operazione di lettura o scrittura e avviare un trasferimento )
\ 0x4 -> Status Register ( usato per registrare lo stato delle attività, gli errori e le richieste di interruzione )
\ 0x8 -> Data Length Register ( definisce il numero di byte di dati da trasmettere o ricevere nel trasferimento I2C )
\ 0xc -> Slave Address Register ( specifica l'indirizzo slave e il tipo di ciclo )
\ 0x10 -> Data FIFO Register ( utilizzato per accedere al FIFO )
\ 0x14 -> Clock Divider Register ( usato per definire la velocità di clock della periferica BSC )
\ 0x18 -> Data Delay Register ( fornisce un controllo accurato sul punto di campionamento/lancio dei dati )
\ 0x1c -> Clock Stretch Timeout Register ( fornisce un timeout su quanto tempo il master può attende lo slave, così da allungare il timeout, prima di decretarne la caduta )

\ I2C REGISTER ADDRESSES
\ BASE 804000 + -> I2C_CONTROL_REGISTER_ADDRESS
\ BASE 804004 + -> I2C_STATUS_REGISTER_ADDRESS
\ BASE 804008 + -> I2C_DATA_LENGTH_REGISTER_ADDRESS
\ BASE 80400C + -> I2C_SLAVE_ADDRESS_REGISTER_ADDRESS
\ BASE 804010 + -> I2C_DATA_FIFO_REGISTER_ADDRESS
\ BASE 804014 + -> I2C_CLOCK_DIVIDER_REGISTER_ADDRESS
\ BASE 804018 + -> I2C_DATA_DELAY_REGISTER_ADDRESS
\ BASE 80401C + -> I2C_CLOCK_STRETCH_TIMEOUT_REGISTER_ADDRESS

\ I pin GPIO-2 (SDA) e GPIO-3 (SCL) devono prendere la ALTERNATIVE FUNCTION 0
\ quindi dobbiamo configurare il GPFSEL0 che viene utilizzato per definire il funzionamento dei primi 10 pin GPIO.
\ ogni 3-bit del gpfsel rappresentano un pin GPIO, così per indirizzare GPIO-2 e GPIO-3
\ nel campo GPFSEL0 (32-bits), dobbiamo operare sui bit in posizione 8-7-6 (GPIO-2) e 11-10-9 (GPIO-3)
\ di conseguenza dobbiamo scrivere (0000 0000 0000 0000 0000 1001 0000 0000) ovvero in HEX (0x00000900)
\ su GPFSEL0 per settare la ALTERNATIVE FUNCTION 0

: SETUP_I2C 
  900 GPFSEL0 @ OR GPFSEL0 ! ;

\ Ripristina lo Status Register utilizzando I2C_STATUS_REGISTER (BASE 804004 +)
\ HEX (0x00000302) è (0000 0000 0000 0000 0000 0011 0000 0010) in BIN
\ Il bit 1 è 1 -> Cancella campo DONE
\ Il bit 8 è 1 -> Cancella campo ERR
\ Il bit 9 è 1 -> Cancella campo CLKT 
: RESET_S 
  302 BASE 804004 + ! ;

\ Ripristina FIFO utilizzando I2C_CONTROL_REGISTER (BASE 804000 +)
\ HEX (0x00000010) è (0000 0000 0000 0000 0000 0000 0001 0000) in BIN
\ Il bit 4 è 1 -> Cancella FIFO 
: RESET_FIFO
  10 BASE 804000 + ! ;

\ Imposta l'indirizzo SLAVE 0x00000027 ( perché il nostro modello DRIVE è PCF8574T )
\ in I2C_SLAVE_ADDRESS_REGISTER (BASE 80400C +) 
: SET_SLAVE 
  27 BASE 80400C + ! ;

\ Memorizza i dati in I2C_DATA_FIFO_REGISTER_ADDRESS (BASE 804010 +)
: STORE_DATA
  BASE 804010 + ! ;

\ Avvia un nuovo trasferimento utilizzando I2C_CONTROL_REGISTER (BASE 804000 +)
\ (0x00008080) è (0000 0000 0000 0000 1000 0000 1000 0000) in BINARIO
\ Il bit 0 è 0 -> Scrivi trasferimento pacchetti
\ Il bit 7 è 1 -> Avvia un nuovo trasferimento
\ Il bit 15 è 1 -> Il controller BSC è abilitato
: SEND 
  8080 BASE 804000 + ! ;

\ La parola principale per scrivere 1 byte alla volta
: >I2C
  RESET_S
  RESET_FIFO
  1 BASE 804008 + !
  SET_SLAVE
  STORE_DATA
  SEND ;

\ Invia i 4 bit più significativi rimasti di TOS
: 4BM>LCD 
  F0 AND DUP ROT
  D + OR >I2C 1000 DELAY
  8 OR >I2C 1000 DELAY ;

\ Invia 4 bit meno significativi rimasti di TOS
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

\ Per verificare che si tratti di un comando controllo se il 9 bit è 1 (lo shift elimina gli otto precedenti) 
: IS_CMD 
  DUP 8 RSHIFT 1 = ;

\ Decide se stiamo inviando un comando o un dato a I2C
\ Commands ha un 1 in più nel bit più significativo rispetto ai dati
\ Un input come 101 >LCD sarebbe considerato un COMANDO per cancellare lo schermo  0000 0001
\ dove un input come 41 >LCD sarebbe considerato un DATA per inviare A CHAR (41 in esadecimale)
\ allo schermo
: >LCD 
  IS_CMD SWAP >LCDM 
;
\ Embedded Systems - Sistemi Embedded - 17873)
\ LCD Setup paraole per la compilazione di messaggi su LCD 1602 )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo i2c.f

\ Set di words che genera le parole da visualizzare su LCD
\ I due esadecimali rappresentano gli otto bit del blocco data per visualizzare la lettera 
\ così come devinira nella CGRAM
\ Stampa "welcome" a display
: WELCOME
    57 >LCD 
    45 >LCD
    4C >LCD
    43 >LCD  
    4F >LCD
    4D >LCD
    45 >LCD 
    20 >LCD ;

\ Stampa "SMART" a display
: SMART 
    53 >LCD 
    4D >LCD
    41 >LCD
    52 >LCD  
    54 >LCD
    20 >LCD ;

\ Stampa "CLIMA" a display
: CLIMA 
    43 >LCD 
    4C >LCD
    49 >LCD
    4D >LCD  
    41 >LCD
    20 >LCD ;

\ Stampa "SYSTEM"  a display
  : SYSTEM 
    53 >LCD
    59 >LCD  
    53 >LCD
    54 >LCD
    45 >LCD
    4D >LCD
    20 >LCD ;

\ Stampa "READY" a display
: READY 
    52 >LCD 
    45 >LCD
    41 >LCD
    44 >LCD  
    59 >LCD 
    20 >LCD ;

\ Stampa "BUSY" a display
: BUSY 
    42 >LCD 
    55 >LCD
    53 >LCD
    59 >LCD 
    20 >LCD ;

\ Stampa "LIGHT" a display
: LIGHT 
    4C >LCD 
    49 >LCD
    47 >LCD
    48 >LCD 
    54 >LCD
    20 >LCD ;

\ Stampa "WIND" a display
: WIND 
    57 >LCD 
    49 >LCD
    4E >LCD
    44 >LCD 
    20 >LCD ;

\ Stampa "STOP" a display
: STOP 
    53 >LCD 
    54 >LCD
    4F >LCD
    50 >LCD 
    20 >LCD ;

\ Stampa "INSERT" a display
: INSERT 
    49 >LCD
    4E >LCD
    53 >LCD 
    45 >LCD
    52 >LCD
    54 >LCD
    20 >LCD ;

\ Stampa "TIME" a display
: TIME 
    54 >LCD
    49 >LCD
    4D >LCD 
    45 >LCD
    20 >LCD ;

\ Set di words che accede al blocco funzioni del LCD
\ Il nono bit impostato a 1 abilita ENABLE vedi datasheet 1602
\ 0x80 → Indirizzo di memoria della DDRAM del display LCD per la linea 1
\ 0xC0 → Indirizzo di memoria della DDRAM del display LCD per la linea 2

\ Cancella il display
: CLEAR
  101 >LCD ;

\ Muove il cursore sulla seconda linea
: >LINE2
  1C0 >LCD ;

\ Visualizza il cursore sulla prima linea
: SETUP_LCD 
  102 >LCD ;
\ Embedded Systems - Sistemi Embedded - 17873
\ Leds Drive 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie gpio.f e ans.f

\ LED GPIO SETTING IN HEX
5 CONSTANT YELLOWLED
6 CONSTANT REDLED
C CONSTANT GREENLED

\ GPIO On e Off
: ON ( pin -- ) 1 SWAP LSHIFT GPSET0 ! ;
: OFF ( pin -- ) 1 SWAP LSHIFT GPCLR0 ! ;

\ Setup Led abilita i GPIO come output
: SETUP_LED 
    REDLED GPFSELOUT! 
    YELLOWLED GPFSELOUT!
    GREENLED GPFSELOUT! ;

\ Accende tutti i led disattivando tutti gli attuatori ( NC interdetto )
: ALL_LED_ON 
  REDLED GPON!
  YELLOWLED GPON!
  GREENLED GPON!
;

\Questa WORD attiva il led giallo
: SYSTEMLIGHT YELLOWLED GPON! ;
\Questa WORD attiva il led verde
: SYSTEMWIND GREENLED GPON! ;

\Questa WORD disattiva un pin
: TURNOFF ( pin -- ) GPOFF! ;

\Questa WORD disattiva il led giallo
: STOPLIGHT YELLOWLED GPOFF! ;

\Questa WORD disattiva il led verde
: STOPWIND GREENLED GPOFF! ;

\ Variabili temporali
VARIABLE LIGHTIME 
VARIABLE WINDTIME

\Settaggi di default luce e vento in ms 800000 37SEC  400000 19SEC  200000 9SEC 
420000 LIGHTIME !
420000 WINDTIME !
\ Embedded Systems - Sistemi Embedded - 17873
\ Keypad 
\ Università degli Studi di Palermo
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo led.f

\ Per ogni riga inviare un output
\ Per ogni colonna controllare i valori
\ Se viene letto il bit di rilevamento dell'evento, abbiamo trovato il tasto premuto
   \ nel formato RIGA-COLONNA

   \ MATRIX 5x4
\ GPIO-17 -> Riga-1 (F1-F2-#-*)
\ GPIO-18 -> Riga-1 (1-2-3-SU)
\ GPIO-23 -> Riga-2 (4-5-6-GIU)
\ GPIO-24 -> Riga-3 (7-8-9-ESC)
\ GPIO-25 -> Riga-4 (SX-0-DX-ENT)
\ GPIO-16 -> Colonna-1 (*-SU-GIU-ESC-ENT)
\ GPIO-22 -> Colonna-2 (#-3-6-9-DX)
\ GPIO-27 -> Colonna-3 (F2-2-5-8-0)
\ GPIO-10 -> Colonna-4 (F1-1-4-7-SX) 

\ Abilita il rilevamento del fronte di discesa per i pin che controllano le RIGHE
   \ scrivendo 1 nelle posizioni dei pin corrispondenti (GPIO-18, 23, 24, 25)
\ HEX (0x03840000) che è (0000 0011 1000 0100 0000 0000 0000 0000) in BIN 
: SETUP_ROWS 
  3840000 GPFEN0 ! ;

\ I pin RIGA sono impostati come output , i pin colonna sono impostati come input
\ Il campo GPFSEL1 viene utilizzato per definire il funzionamento dei pin GPIO-10 - GPIO-19
\ Il campo GPFSEL2 viene utilizzato per definire il funzionamento dei pin GPIO-20 - GPIO-29

\ Ogni 3 bit di GPFSEL rappresenta un pin GPIO
\ Per indirizzare GPIO-10, GPIO-17, GPIO-16 e GPIO-18 dovremmo operare sulla posizione dei bit
   \ 2-1-0(GPIO-10), X-Y-Z(GPIO-17), 20-19-18(GPIO-16) e 26-25-24(GPIO-18) che memorizzano il valore in GPFSEL1

\ Per indirizzare GPIO-22, GPIO-23, GPIO-24, GPIO-25 e GPIO-27 dovremmo operare sulla posizione dei bit
   \ 8-7-6(GPIO-22), 11-10-9(GPIO-23), 14-13-12(GPIO-24), 17-16-15(GPIO-25) e 23-22- 21(GPIO-27)
   \ memorizzazione del valore in GPFSEL2 

\ GPIO-17 settato in output -> 001
\ GPIO-18 settato in output -> 001
\ GPIO-23 settato in output -> 001
\ GPIO-24 settato in output -> 001
\ GPIO-25 settato in output -> 001
\ GPIO-16 settato in input -> 000
\ GPIO-22 settato in input -> 000
\ GPIO-27 settato in input -> 000
\ GPIO-10 settato in input -> 000

\ Di conseguenza dovremmo scrivere
\ (0001 0000 0000 0000 0000 0000 0000) in GPFSEL1_REGISTER_ADDRESS che è in HEX(0x1000000)
\ (0000 1001 0010 0000 0000) in GPFSEL2_REGISTER_ADDRESS che è in HEX(0x9200) 
: SETUP_IO 
  1000000 GPFSEL1 @ OR GPFSEL1 ! 
  9200 GPFSEL2 @ OR GPFSEL2 ! ;

\ Cancella GPIO-17, GPIO-18, GPIO-23, GPIO-24 e GPIO-25 utilizzando il registro GPCLR0
   \ scrivendo 1 nelle posizioni corrispondenti
\ HEX (0x3840000) che è (0011 1000 0100 0000 0000 0000 0000) in BIN 
: CLEAR_ROWS 
  3840000 GPCLR0 ! ;

\ Definizione della WORD per inizializzare la tastiera 
: SETUP_KEYPAD 
  SETUP_ROWS 
  SETUP_IO 
  CLEAR_ROWS ;

\ Testa un pin, se viene premuto lascia 1 sullo stack altrimenti 0 
: PRESSED 
  TPIN 1 = IF 1 ELSE 0 THEN ;

3 CONSTANT RANGE 

\ Variabile gestisce la terminazione del ciclo.
VARIABLE FLAG
\ Variabile per memorizzare il tempo decine di secondi.
VARIABLE CAS
VARIABLE COS
\ Variabile per memorizzare il tempo unità di secondi.
VARIABLE CASS
VARIABLE COSS

1 FLAG !

\ Questo flag permette di gestire l'avvio del ciclo.
: FLAGOFF  0 FLAG ! ; 

\ Questo flag permette di gestire l'arresto del ciclo.
: FLAGON  1 FLAG ! ; 

\ Variabile Contatore
CREATE COUNTER

\ Incrementa di 1 la variabile COUNTER 
: COUNTER++ 
  COUNTER @ 1 + COUNTER ! ;

 \ Memorizza il valore in decimale di un numero nell'array D_CMDS e lo emette su LCD
\ Duplica il TOS ed emettilo
\ Lascia l'indirizzo D_CMDS su TOS
\ Lascia il valore COUNTER su TOS
\ Lasciare l'indirizzo del COUNTER'esimo indice dell'array D_CMDS su TOS
\ Infine memorizzare il valore DEC emesso a quell'indirizzo
\ Esempio: 30 EMIT_STORE -> Stampa 0 su LCD e lo memorizza in D_CMDS[COUNTER_current_value] 
: EMIT_STORE 
  COUNTER @ 0 = IF LIGHT 1000 DELAY ELSE
  COUNTER @ 2 = IF >LINE2 WIND 1000 DELAY
  THEN THEN
  DUP 500 DELAY >LCD 
  DUP 30 -  \ . CONSUMA LO STACK
  DUP .
\ Termina Programma con la pressione del tasto ESC
  DUP -15 = IF CLEAR ALL_LED_ON SYSTEM STOP 30000 DELAY ." EXIT TO END PROGRAM " FLAGOFF CR AUTHOR CR ABORT ELSE 

  DUP COUNTER @ 0 = IF DUP CAS ! DUP 2 * 4 LSHIFT LIGHTIME ! ELSE
  DUP COUNTER @ 1 = IF DUP CASS ! DUP LIGHTIME @ + 8 LSHIFT 8 LSHIFT LIGHTIME ! ELSE
  DUP COUNTER @ 2 = IF DUP COS ! DUP 2 * 4 LSHIFT WINDTIME !  ELSE
  DUP COUNTER @ 3 = IF DUP COSS ! DUP WINDTIME @ + 8 LSHIFT 8 LSHIFT WINDTIME !
  THEN THEN THEN THEN THEN
  ;

\ Stampa uno dei caratteri trovati nella Colonna 1 controllando il numero di riga specificato con un ciclo condizionale
\ Pin fisico Riga -> EMIT-Colonna
\ Esempio: 12 EMTC1 stampa A (41 in HEX) su lcd
\ 19 EMTC1 stampa D (44 in HEX) su lcd 
\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO17 = 11
: EMITC1 
  DUP 11 = IF 2A DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 5E DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 5F DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 1B DUP EMIT_STORE DROP ELSE 
  19 = IF D DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

\ Stampa uno dei caratteri trovati sulla Colonna 2 controllando il numero di riga specificato con un ciclo condizionale
\ Pin fisico Riga -> EMIT-Colonna
\ Esempio: 32 EMTC2 stampa # (23 in HEX) su lcd
\ 17 EMTC2 stampa 6 (36 in HEX) su lcd 
\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO18 = 12
: EMITC2 
  DUP 11 = IF 23 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 33 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 36 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 39 DUP EMIT_STORE DROP ELSE 
  19 = IF 3E DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

\ Stampa uno dei caratteri trovati sulla Colonna 3 controllando il numero di riga specificato con un ciclo condizionale
\ Pin fisico Riga -> EMIT-Colonna
\ Esempio: 18 EMTC2 stampa 8 (38 in HEX) su lcd
\ 19 EMTC2 stampa 0 (30 in HEX) su lcd 
\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO17 = 11
: EMITC3 
  DUP 11 = IF 25 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 32 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 35 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 38 DUP EMIT_STORE DROP ELSE 
  19 = IF 30 DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

\ Stampa uno dei caratteri trovati sulla Colonna 4 controllando il numero di riga specificato con un ciclo condizionale
\ Pin fisico Riga -> EMIT-Colonna
\ Esempio: 12 EMTC2 stampa 1 (31 in HEX) su lcd
\ 18 EMTC2 stampa 7 (37 in HEX) su lcd 
\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO18 = 12
: EMITC4 
  DUP 11 = IF 24 DUP EMIT_STORE DROP ELSE
  DUP 12 = IF 31 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 34 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 37 DUP EMIT_STORE DROP ELSE 
  19 = IF 3C DUP EMIT_STORE 
  THEN THEN THEN THEN THEN ;

\ Stampa la combinazione di caratteri Riga-Colonna specificata utilizzando la corrispondente WORD EMTC1/C2/C3/C4
\ Esempio: 12 10 EMIT_R
: EMIT_R
  DUP 10 = IF DROP EMITC1 ELSE 
  DUP 16 = IF DROP EMITC2 ELSE 
  DUP 1B = IF DROP EMITC3 ELSE 
  A = IF EMITC4 
  THEN THEN THEN THEN ;

\ Verifica se un tasto della riga data è premuto, attende il suo rilascio,
\ e stampa il valore esadecimale corrispondente sull'LCD 
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

\ TODO
\ Controlla la riga data impostandola su HIGH, controllandone le colonne e infine impostandola su LOW
\ Esempio -> 32 CHECK_ROW (Controlla la prima riga)
\         -> 12 CHECK_ROW (Controlla la seconda riga)
\         -> 17 CHECK_ROW (Controlla la terza riga)
\         -> 18 CHECK_ROW (Controlla la quarta riga)
\         -> 19 CHECK_ROW (Controlla la quinta riga) 
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

\ La main WORD per rilevare qualsiasi evento di PRESS/RELASE ed eventualmente stampa il
\ carattere corrispondente su LCD
\ Questa WORD deve essere chiamata all'avvio del SETUP,
\ quindi, a meno che non si impostino le righe su LOW, non è necessario utilizzare questa WORD 
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
  0  CR LIGHTIME @ . ." <- LIGHTIME " CR WINDTIME @ . ." <- WINDTIME " CR ." RUN . . . " CR
  ." SETTING TIME LIGHT >>>    "  CAS @ . CASS @ . ."    SECONDS " CR  
  ." SETTING TIME WIND >>>    "  COS @ . COSS @ . ."    SECONDS " CR ;  
HEX

\ IMPOSTAZIONI  DEL FRAMEBUFFER SU INTERPRETE
\ Initializing frame buffer
\ framebuffer at 0x3E8FA000 width 00000400 height 00000300 depth 00000020 pitch 00001000

\ Svuota tutto
: 4DROP DROP DROP DROP DROP ;

\ Dichiarazione dei colori in esadecimale (formato ARGB)
00FFFFFF CONSTANT WHITE
00000000 CONSTANT BLACK
00FF0000 CONSTANT RED
00FFFF00 CONSTANT YELLOW
0000FF00 CONSTANT GREEN
000000FF CONSTANT BLUE

\ Dichiarazione del base address del framebuffer
3E8FA000 CONSTANT FRAMEBUFFER

VARIABLE DIM
\ Contatore utilizzato nei cicli per disegnare le linee orizzontali

VARIABLE COUNTERH


\ RESETCOUNTERH
: RESETCOUNTERH 0 COUNTERH ! ;

\ Contatore utilizzato nei cicli per tenere traccia del numero di riga corrente
: +COUNTERH COUNTERH @ 1 + COUNTERH ! ;

\ RESETNLINE
\ Restituisce l'indirizzo del punto centrale dello schermo. Coordinata ((larghezza-1)/2, (altezza-1)/2)
VARIABLE NLINE
: RESETNLINE 1 NLINE ! ;
: +NLINE NLINE @ 1 + NLINE ! ;

( -- addr )
: CENTER FRAMEBUFFER 200 4 * + 180 1000 * + ;
\ Colora, con il colore presente sullo stack, il pixel corrispondente all'indirizzo
\ presente sullo stack,
\ dopodiche punta al pixel a destra

( color addr -- color addr_col+1 )
: RIGHT 2DUP ! 4 + ;

\ Colora, con il colore presente sullo stack, il pixel corrispondente all'indirizzo
\ presente sullo stack,
\ dopodiche punta al pixel in basso

( color addr -- color addr_row+1 )
: DOWN 2DUP ! 1000 + ;

\ Colora, con il colore presente sullo stack, il pixel corrispondente all'indirizzo
\ presente sullo stack,
\ dopodiche punta al pixel a sinistra

( color addr -- color addr_col-1 )
: LEFT 2DUP ! 4 - ;

\ Ripristina il valore di partenza dell'indirizzo a seguito di COUNTERH * 4 spostamenti a
\ destra

( addr_endline_right -- addr )
: RIGHTRESET COUNTERH @ 4 * - ;

\ Ripristina il valore di partenza dell'indirizzo a seguito di COUNTERH * 4 spostamenti a
\ sinistra

( addr_endline_left -- addr )
: LEFTRESET COUNTERH @ 4 * + ;


\ Disegna una linea verso destra di dimensione pari a 48 pixel
: RIGHTDRAW
    BEGIN COUNTERH @ DIM @ < WHILE +COUNTERH RIGHT REPEAT RIGHTRESET RESETCOUNTERH ;

\ Disegna una linea verso sinistra di dimensione pari a 48 pixel
: LEFTDRAW
    BEGIN COUNTERH @ DIM @ < WHILE +COUNTERH LEFT REPEAT LEFTRESET RESETCOUNTERH ;


\ Disegna o il simbolo di stop o pulisce la porzione di schermo su cui disegnamo.
\ Partendo da CENTER-32px-48px, quindi CENTER-80px, e poiche ogni spostamento di 1px su
\ una riga
\ vale 4, abbiamo 320 in dec e cioe 140 in hex
: DRAWSQUARE
    80 DIM !
    CENTER 140 - RIGHTDRAW
\ Ciclo che disegna un simbolo di stop di altezza 105 pixel
    BEGIN NLINE @ 70 <
        WHILE
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

\ Disegna il simbolo di start.
: DRAWSTARTWIND
    GREEN CENTER 80 -
    BEGIN NLINE @ 70 <=
        WHILE
\ Permette di rappresentare le linee del triangolo superiore del simbolo start
            NLINE @ 37 <= IF
            NLINE @ DIM !
\ Permette di rappresentare le linee del triangolo inferiore del simbolo start
                ELSE
                    70 NLINE @ - DIM !
            THEN
\ Disegna una linea verso destra di dimensione variabile e dipendente dal numero di riga \ memorizzato in NLINE.
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

\ Disegna il simbolo di start.
: DRAWSTARTLIGHT
    YELLOW CENTER 80 -
    BEGIN NLINE @ 70 <=
        WHILE
\ Permette di rappresentare le linee del triangolo superiore del simbolo start
            NLINE @ 37 <= IF
            NLINE @ DIM !
\ Permette di rappresentare le linee del triangolo inferiore del simbolo start
                ELSE
                    70 NLINE @ - DIM !
            THEN
\ Disegna una linea verso destra di dimensione variabile e dipendente dal numero di riga \ memorizzato in NLINE.
            DOWN RIGHTDRAW
            +NLINE
        REPEAT
    2DROP RESETNLINE
;

: DRAWSTOP RED DRAWSQUARE ;

: CLEAN BLACK DRAWSQUARE ;

\ Disegna la bandiera
: DRAWITAFLAG

    WHITE DRAWSQUARE
    30 DIM !
\ Disegna la prima linea della seconda pipe
    RED CENTER RIGHTDRAW
\ Disegna la prima linea della prima pipe, spostandosi di 32 pixel a sinistra
    GREEN CENTER 80 - LEFTDRAW
\ Ciclo che disegna due pipe, distanziate, di altezza 105 pixel
    BEGIN NLINE @ 70 <
        WHILE
\ Disegna l'n-esima linea della prima pipe
            DOWN LEFTDRAW
            2SWAP
\ Disegna l'n-esima linea della seconda pipe
            DOWN RIGHTDRAW
            2SWAP
            +NLINE
        REPEAT
    4DROP RESETNLINE
;
HEX
FE003004 CONSTANT CLO

\ Dichiarazione della costante che indica un secondo e che ha valore 1 000 000 usec in decimale o
\ F4240 in hex
F4240 CONSTANT SEC

\ Variabile che memorizza il valore attuale del CLO + 1 secondo
VARIABLE COMP0

VARIABLE COUNTER
0 COUNTER !

\ Inizializzazione delle variabili utilizzate
0 COMP0 !

\ Restituisce il valore attuale del registro CLO
( -- clo_value )
: NOW CLO @ ;
\ Setta un ritardo corrispondente al valore presente sullo stack
( delay_sec -- )
: DELAY_SEC NOW + BEGIN DUP NOW - 0 <= UNTIL DROP ;

\ La Mod Swap Word restituisce il MOD 60 di un numero passato, il cui valore e inizialmente espresso in secondi. 
\ La MSW quindi pone sullo stack il resto e il quoto della divisione per 60  ed effettua successivamente uno swap.
 ( n1 -- n3 n2 )
: MSW 60 /MOD SWAP ;

\ Memorizza il valore attuale del CLO + 1 secondo in COMP0
: INC NOW DUP . SEC + COMP0 ! ;

: DECCOUNT COUNTER @ 1 - COUNTER ! ;

\ Segnala ogni qual volta e passato un secondo confrontando CLO con COMP0
: SLEEPS HEX INC BEGIN NOW COMP0 @ < WHILE REPEAT CR ." Passato 1 sec " DROP DECIMAL ;

: INCCOUNT COUNTER @ 1 + COUNTER ! ;

DECIMAL 
: CICLOCONT COUNTER ! begin CR COUNTER @ U. SLEEPS DECCOUNT COUNTER @ 0 = until CR
CR ." fine " DROP ;

HEX

HEX
\ Aziona il Sistema Illuminazione
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

\ Aziona il Sistema Ventilazione
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

\ Sistema Arrestato
: STOP_DISP 
  ALL_LED_ON
  CLEAR
  CLEAN
  DRAWSTOP
  SYSTEM
  STOP
  ;

\ Esecuzione attuatori per 4 cicli. Il Flag di fine procedura viene modificato al 4 ciclio.
\ Al termine il programma si rimette in configurazione d'immissione dati.
: RUN 0 COUNTER ! 
  BEGIN                   
    FLAG @ 1 = WHILE GO_LIGHT ." SYSTEM LIGHT "  LIGHTIME @ DELAY 
      GO_WIND ." SYSTEM WIND " WINDTIME @ DELAY 
      COUNTER++ 
      COUNTER @ 4 = IF  FLAGOFF THEN
      ." Cycle n° " 
      COUNTER @ .
      ." Flag setting " 
      FLAG @ .
      CR
    REPEAT 
  ?CTF UNTIL FLAGON STOP_DISP 10000 DELAY ." FINE PROGRAMMA " CLEAR INSERT TIME 10000 DELAY ; \ Riutilizzo di flag per gestire il ciclo principale.


\ Main WORD che contiene settaggi di base e avvio del ciclo principale:
\ Vengono avviati i setup per il Bus I2C per inizializzare l'LCD, la Keypad, led e gli attuatori.
\ A questo punto parte il messaggio di benvenuto e inizia il ciclo infinito:
\ Sarà necessario introdurre il tempo di esecuzione degli adattatori espresso in secondi ( 2 cifre per illuminazione e 2 cifre per il vento);
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


\ Solo setup Hardware per testing
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
