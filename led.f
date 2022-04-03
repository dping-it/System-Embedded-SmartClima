\ Embedded Systems - Sistemi Embedded - 17873
\ Led Drive e Relè 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie gpio.f e ans.f

\ Il sistema led è composto da 3 led di colore diverso e da 3 resistori ceramici da 200 ohm che servono da protezione agli stessi led.
\ Ogni led è collegato ad un GPIO specifico che ne abilita l’emissione luminosa e lo stesso GPIO gestisce il NC dell’attivazione di un relè.
\ I GPIO 5, 6, e il 12 (in HEX C) sono configurati come OUT.
5 CONSTANT YELLOWLED
6 CONSTANT REDLED
C CONSTANT GREENLED

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

\ Le variabili temporali vengono inizializzate a 1
1 LIGHTIME !
1 WINDTIME !
