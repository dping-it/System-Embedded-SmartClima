HEX
FE003004 CONSTANT CLO

\ Dichiarazione della costante che indica un secondo e che ha valore 1 000 000 usec in decimale o
\ F4240 in hex
F4240 CONSTANT SEC

\ Variabile che memorizza il valore attuale del CLO + 1 secondo
VARIABLE COMP0

VARIABLE TIME_COUNTER

0 TIME_COUNTER !

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

: DECCOUNT TIME_COUNTER @ 1 - TIME_COUNTER ! ;

\ Segnala ogni qual volta e passato un secondo confrontando CLO con COMP0

: SLEEPS  INC BEGIN NOW COMP0 @ < WHILE REPEAT CR ." TIC " DROP DECIMAL ;


: INCCOUNT TIME_COUNTER @ 1 + TIME_COUNTER ! ;

\ Word che imposta un conto alla rovescia in secondi a partire dal n passato fino a zero.  

DECIMAL : TIMER TIME_COUNTER ! begin CR TIME_COUNTER @ DUP U. SLEEPS DECCOUNT TIME_COUNTER @ 0 = until CR
CR ." fine " CR DROP ;


HEX
