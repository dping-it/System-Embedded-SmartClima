
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

: PARTIAL GPEDS0 @ 4000000 = IF ." PREMUTO TASTO AVVIO DEL SISTEMA " CR SETUP THEN 0 GPEDS0 ! ;

: START
    SETUP_BUTTON
    GPAREN!
    BEGIN
      WHILE
        PARTIAL
      REPEAT
    0 GPEDS0 !
;

START