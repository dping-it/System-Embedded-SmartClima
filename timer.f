\ Embedded Systems - Sistemi Embedded - 17873
\ Setting commands 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Must be INCLUDEd after lcd.f and pad.f


\ Le costanti sono:
\ CS = 0x7E003000 → Registro di controllo / stato del System
\ Timer
\ CLO = 0x7E003004 → Registro contenente i 32 bit inferiori del
\ System Timer Counter
\ CHI = 0x7E003008 → Registro contenente i 32 bit superiori del
\ System Timer Counter
\ C0 = 0x7E003010 → Indirizzo del registro del System Timer
\ Compare 0
\ Il timer è stato usato per temporizzare il sistema per passare da un
\ colore di sfondo ad un altro.
\ E’ possibile personalizzarlo levando il valore 20000 e richiamare la word
\ passando come parametro un valore a propria scelta.

\ È stato utilizzato il Registro CLO23 cioè il System Timer Counter LOwer bits che è
\ un registro di sola lettura che restituisce il valore corrente dei 32 bit inferiori del
\ contatore.

  ( TIMER )
  HEX
  7E003000 constant CS 
  7E003004 constant CLO
  7E003008 constant CHI
  7E00300C constant C0
  : delay_ CLO @ + C0 ! BEGIN CS @ 1 = UNTIL ;

\ Time Conversions
DECIMAL
: uSECS ( n -- dt ) DECIMAL 1 * ;
: mSECS ( n -- dt ) DECIMAL 1000 * ;
: SECS


  : TIMER ( -- )
  20000 delay
  ;


: DELAY ( dt -- )
CLO @ + \ Timeout = Star_time + dt
BEGIN
DUP
CLO @ - \ Time_passed = Timeout - now
0<= \ Loop until we are over the timeout
UNTIL
DROP ;
: 250mDELAY ( -- ) 250 mSECS DELAY ;

: 10usDELAY ( -- )  10 uSECS DELAY ;
: 40usDELAY ( -- ) 40 uSECS DELAY ;
: 80usDELAY ( -- ) 80 uSECS DELAY ;