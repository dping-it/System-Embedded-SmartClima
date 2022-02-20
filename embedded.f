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

: IS_CMD 
  DUP 8 RSHIFT 1 = ;

\ Decide se stiamo inviando un comando o un dato a I2C
\ Commands ha un 1 in più nel bit più significativo rispetto ai dati
\ Un input come 101 >LCD sarebbe considerato un COMANDO per cancellare lo schermo
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
\ Led Drive 
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
\ Aziona il Sistema Illuminazione
: GO_LIGHT 
  REDLED GPOFF!
  STOPWIND
  CLEAR
  SYSTEM
  LIGHT
  SYSTEMLIGHT
  ;

\ Aziona il Sistema Ventilazione
: GO_WIND 
  REDLED GPOFF!
  STOPLIGHT
  CLEAR
  SYSTEM
  WIND
  SYSTEMWIND
  ;

\ Sistema Arrestato
: STOP_DISP 
  ALL_LED_ON
  CLEAR
  SYSTEM
  STOP
  ;

\ Esecuzione attuatori per 4 cicli. Il Flag viene modificato al 4 ciclio.
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


\ Main WORD che contiene settaggi di base e avvio del ciclo principale
: SETUP
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
  10000 DELAY
  CLEAR
  INSERT TIME
  30000 DELAY
    BEGIN
    FLAGON
    DETECT 
    1 
    RUN 20000 DELAY
    ?CTF UNTIL 
    ;


\ Solo setup Hardware per testing
  : ONLY_SETUP
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
