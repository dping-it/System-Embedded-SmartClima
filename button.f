\ Embedded Systems - Sistemi Embedded - 17873)
\ LCD Setup paraole per la compilazione di messaggi su LCD 1602 )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo pad.f

\ Word per il controllo del bottone d'avvio


\ Dichiarazione dell'indirizzo del registro GPAREN0 come costante
FE20007C CONSTANT GPAREN0

: SETUP_BUTTON 
  40000 GPFSEL2 @ OR GPFSEL2 ! 

\ Rendiamo sensibile ai fronti di salita le GPIO26 a cui è associati il pulsante, quindi
\ avremo 1000 0000 0000 0000 0000 0000 0000 che equivale a 4000000 in decimale o 0x63 in esadecimale
\ : GPAREN! 4000000 GPAREN0 ! ;
: GPAREN! 4000000 GPAREN0 @ OR GPAREN0 ! ;
