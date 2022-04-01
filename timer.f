\ Embedded Systems - Sistemi Embedded - 17873)
\ Timer di Sistema e definizione di unità temporale )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo hdmi.f

HEX 

\ Clock Register
BASE 003004 + CONSTANT CLO

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

\ Converte il valore decimal in secondi a hexadecimal per darlo in pasto al tic. La word pone sullo stack il resto 
\ e il quoto della divisione per 10 moltiflica il quoto per A (10 in HEX) somma il resto ed effettua successivamente uno swap.
: PARSE_DEC_HEX ( n1 -- n3 n2 ) 10 /MOD A * SWAP + DUP . ." >> SECONDS " ;

\ Memorizza il valore attuale del CLO + 1 secondo in COMP0
: INC NOW SEC + COMP0 ! ;


\ Segnala ogni qual volta e passato un secondo confrontando CLO con COMP0

: SLEEPS DECIMAL INC BEGIN NOW COMP0 @ < WHILE REPEAT DUP U. ." | " DROP DECIMAL ;

\ Words di incremento e decremento contatore
: DECCOUNT TIME_COUNTER @ 1 - TIME_COUNTER ! ;
: INCCOUNT TIME_COUNTER @ 1 + TIME_COUNTER ! ;

\ Word che imposta un conto alla rovescia in secondi a partire dal n passato fino a zero.  

DECIMAL : TIMER PARSE_DEC_HEX TIME_COUNTER ! CR begin TIME_COUNTER @ SLEEPS DECCOUNT TIME_COUNTER @ 0 = until CR
 ." END EROGATION " CR CR DROP ;

HEX
