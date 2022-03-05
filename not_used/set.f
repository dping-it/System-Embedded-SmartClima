\ Embedded Systems - Sistemi Embedded - 17873
\ Setting commands 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Must be INCLUDEd after lcd.f and pad.f

\ La costante per definire la posizione di un validatore di comandi
\ Per questo progetto un comando valido contiene un carattere speciale nella terza posizione di quel comando
\ Esempio: 12A# è un comando valido in quanto contiene il carattere speciale predefinito in 3a posizione
\ 06B3 non è un comando valido in quanto non contiene il carattere speciale predefinito
\ in 3a posizione
DEC

CONSTANT OK_POS 3

\ La costante per definire la posizione di un validatore di comandi
\ Per questo progetto un comando valido contiene un carattere speciale nella terza posizione di quel comando
\ Esempio: 12A# è un comando valido in quanto contiene il carattere speciale in 3a posizione
\ 06B3 non è un comando valido in quanto non contiene il carattere speciale predefinito
\ in posizione 3a
CONSTANT OP_POS 2

\ La costante per definire la posizione di un validatore di comandi
\ Per questo progetto un comando valido contiene un carattere speciale nella terza posizione di quel comando
\ Esempio: 12A# è un comando valido in quanto contiene il carattere speciale # (23 in esadecimale) in 3a posizione
\ 06B* non è un comando valido in quanto non contiene il carattere speciale predefinito # (23 in HEX)
\ in 3a posizione
CONSTANT OK_C 23

\ Contanti per definire le operazioni di attivazione e disattivazione
\ Esempio: 12A# -> Il dispositivo n. 12 è acceso
\ 12B# -> Il dispositivo n. 12 è SPENTO 
CONSTANT ON_C A
CONSTANT OFF_C B
CONSTANT GET_C C

\ Il numero dei dispositivi supportati dal sistema (in esadecimale)
\ Esempio: DEV_NO A definirà la COSTANTE come 10 in DECIMAL
\ The number of the devices that the system supports (in HEX)
\ Example: DEV_NO A will define the CONSTANT as 10 in DECIMAL
CONSTANT DEV_NO 99

\ Variabile per memorizzare i comandi di lunghezza (OK_POS + 1).
\ La modifica di OK_POS CONSTANT fornirà array di lunghezza diversa
\ Variable to store the (OK_POS + 1) length commands
\ Changing the OK_POS CONSTANT will provide different length arrays
CREATE D_CMDS
D_CMDS OK_POS CELLS ALLOT

\ Variabile per memorizzare (DEV_NO) numero di dispositivi (in HEX)
\ Variable to store (DEV_NO) number of devices (in HEX)
CREATE DEVS
DEVS DEV_NO 1 - CELLS ALLOT

\ Recupera i primi 2 valori memorizzati in D_CMDS e li converte in un numero di dispositivo
\ Esempio: D_CMDS-0 contiene 3
\ D_CMDS-1 contiene E
\ Lascia 3E su TOS 
\ Fetches the first 2 values stored in D_CMDS and converts it to a device number
\ Example: D_CMDS-0 contains 3
\          D_CMDS-1 contains E
\          Leaves 3E on TOS
: 2DEV 
  D_CMDS @ 4 LSHIFT
  D_CMDS CELL+ @ 
  OR ;

\ Attiva/disattiva un dispositivo
\ Esempio: ON_C D_SET -> Accende il dispositivo
\ OFF_C D_SET -> Spegne il dispositivo
\ Sets a device on/off
\ Example: ON_C D_SET -> Sets the device on
\          OFF_C D_SET -> Sets the device off
: D_SET 
  >R DEVS 2DEV 4 * + R> SWAP ;

\ Apre il dispositivo specificato
\ Esempio: 1A >APERTO
\ Opens the given device
\ Example: 1A >OPEN
: >OPEN 
  ON_C D_SET ! ;

\ Chiude il dispositivo specificato
\ Esempio: 1A >CHIUDI
\ Closes the given device
\ Example: 1A >CLOSE
: >CLOSE 
  OFF_C D_SET ! ;

\ Restituisce lo stato del dispositivo specificato, che ti dice se è aperto o chiuso
\ Esempio: 1A <STATO
\ Returns the state of the given device, which tells you if it's open or closed
\ Example: 1A <STATE
: <STATE 
  DEVS 2DEV 4 * + @ ;

\ Decide se un determinato comando è OK o meno controllando OK_C
\ nella posizione OK_POS di quel comando
\ Esempio: 64B# ?CMD
\ Decides if a given command is OK or not by checking the OK_C
\   on the position OK_POS of that command
\ Example: 64B# ?CMD
: ?CMD
  D_CMDS OK_POS 4 * + @ OK_C = ;

: OP_TYPE 
  D_CMDS OP_POS 4 * + @ DUP 
  ON_C = IF 
    DROP >OPEN
  ELSE DUP OFF_C = IF 
    DROP >CLOSE
  ELSE GET_C = IF
    <STATE
  THEN THEN THEN ;

\ Reimposta la VARIABILE D_CMDS scrivendo 0
\ Resets the D_CMDS VARIABLE by writing 0's
CREATE AUX_I
: RES_CMD 
  0 AUX_I !
  BEGIN 
  D_CMDS AUX_I @ 4 * + ! 
  AUX_I @ 1 + AUX_I !
  AUX_I @ OK_POS 1 + = UNTIL ;

\ Esegue il comando dato se è valido, altrimenti stampa NOT_VALID sullo schermo
\ Executes the given command if it is valid, else prints NOT_VALID on the screen
: XCMD 
  ?CMD IF 
    OP_TYPE 
    1000 DELAY 4F >LCD
    1000 DELAY 4B >LCD
  ELSE 
    CLEAR 
    1000 DELAY NOT_VALID 
    3000 DELAY CLEAR
  THEN 
;

: SETCODE ( n -- ) ;

: BUSY_DISP 
  CLEAR
  YELLOWLED GPON!
  3000 DELAY 
  YELLOWLED GPOFF!
  ;

: READY_DISP 
  CLEAR
  BEGIN
  GREENLED GPON!
  ?CMD UNTIL
  GREENLED GPOFF!
  ;
