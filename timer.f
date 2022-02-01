\ Embedded Systems - Sistemi Embedded - 17873
\ Setting commands 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Must be INCLUDEd after lcd.f and pad.f


\ Le costanti sono:
\ CS = 0x3F003000 → Registro di controllo / stato del System
\ Timer
\ CLO = 0x3F003004 → Registro contenente i 32 bit inferiori del
\ System Timer Counter
\ CHI = 0x3F003008 → Registro contenente i 32 bit superiori del
\ System Timer Counter
\ C0 = 0x3F003010 → Indirizzo del registro del System Timer
\ Compare 0
\ Il timer è stato usato per temporizzare il sistema per passare da un
\ colore di sfondo ad un altro.
\ E’ possibile personalizzarlo levando il valore 20000 e richiamare la word
\ passando come parametro un valore a propria scelta.
  ( TIMER )
  FE003000 constant CS 
  FE003004 constant CLO
  FE003008 constant CHI
  FE00300C constant C0
  : delay CLO @ + C0 ! BEGIN CS @ 1 = UNTIL ;

  : TIMER ( -- )
  20000 delay
  ;