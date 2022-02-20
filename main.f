
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
