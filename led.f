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
