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
  DUP -15 = IF CLEAR ALL_LED_ON SYSTEM STOP 30000 DELAY ." EXIT TO END PROGRAM " FLAGOFF CR AUTHOR CR CR EXIT ELSE 

  DUP COUNTER @ 0 = IF DUP CAS ! DUP 4 LSHIFT LIGHTIME ! ELSE
  DUP COUNTER @ 1 = IF DUP CASS ! DUP LIGHTIME @ + LIGHTIME ! ELSE
  DUP COUNTER @ 2 = IF DUP COS ! DUP 4 LSHIFT WINDTIME !  ELSE
  DUP COUNTER @ 3 = IF DUP COSS ! DUP WINDTIME @ + WINDTIME ! 
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
  0  CR \ LIGHTIME @ . ." <- LIGHTIME " CR WINDTIME @ . ." <- WINDTIME " CR 
  ." RUN SYSTEM . . . " CR
  ." SETTING TIME LIGHT >>>    "  CAS @ . CASS @ . ."    SECONDS " CR  
  ." SETTING TIME WIND >>>    "  COS @ . COSS @ . ."    SECONDS " CR CR ;  
