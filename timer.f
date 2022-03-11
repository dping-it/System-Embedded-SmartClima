HEX
FE003004 CONSTANT CLO

\ Dichiarazione della costante che indica un secondo e che ha valore 1 000 000 usec in decimale o
\ F4240 in hex
F4240 CONSTANT SEC

\ Variabile che memorizza il valore attuale del CLO + 1 secondo
VARIABLE COMP0

VARIABLE COUNTER
0 COUNTER !

\ Inizializzazione delle variabili utilizzate
0 COMP0 !



\ La Mod Swap Word restituisce il MOD 60 di un numero passato, il cui valore e inizialmente espresso in secondi. 
\ La MSW quindi pone sullo stack il resto e il quoto della divisione per 60  ed effettua successivamente uno swap.
 (n1 -- n3 n2)
: MSW 60 /MOD SWAP ;

\ Memorizza il valore attuale del CLO + 1 secondo in COMP0
: INC NOW SEC + COMP0 ! ;

: DECCOUNT COUNTER @ 1 - COUNTER ! ;

\ Segnala ogni qual volta e passato un secondo confrontando CLO con COMP0
: SLEEPS HEX INC BEGIN NOW COMP0 @ < WHILE REPEAT CR ." Passato 1 sec " DROP DECIMAL ;

: INCCOUNT COUNTER @ 1 + COUNTER ! ;

DECIMAL 
: CICLOCONT COUNTER ! begin CR COUNTER @ U. SLEEPS DECCOUNT COUNTER @ 0 = until CR
CR ." fine " DROP ;

HEX
