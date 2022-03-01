\ Embedded Systems - Sistemi Embedded - 17873)
\ LCD Setup paraole per la compilazione di messaggi su LCD 1602 )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo i2c.f

\ Set di words che genera le parole da visualizzare su LCD
\ I due esadecimali rappresentano gli otto bit del blocco data per visualizzare la lettera 
\ così come devinira nella CGRAM
\ Stampa "welcome" a display
: WELCOME
    57 >LCD 
    45 >LCD
    4C >LCD
    43 >LCD  
    4F >LCD
    4D >LCD
    45 >LCD 
    20 >LCD ;

\ Stampa "SMART" a display
: SMART 
    53 >LCD 
    4D >LCD
    41 >LCD
    52 >LCD  
    54 >LCD
    20 >LCD ;

\ Stampa "CLIMA" a display
: CLIMA 
    43 >LCD 
    4C >LCD
    49 >LCD
    4D >LCD  
    41 >LCD
    20 >LCD ;

\ Stampa "SYSTEM"  a display
  : SYSTEM 
    53 >LCD
    59 >LCD  
    53 >LCD
    54 >LCD
    45 >LCD
    4D >LCD
    20 >LCD ;

\ Stampa "READY" a display
: READY 
    52 >LCD 
    45 >LCD
    41 >LCD
    44 >LCD  
    59 >LCD 
    20 >LCD ;

\ Stampa "BUSY" a display
: BUSY 
    42 >LCD 
    55 >LCD
    53 >LCD
    59 >LCD 
    20 >LCD ;

\ Stampa "LIGHT" a display
: LIGHT 
    4C >LCD 
    49 >LCD
    47 >LCD
    48 >LCD 
    54 >LCD
    20 >LCD ;

\ Stampa "WIND" a display
: WIND 
    57 >LCD 
    49 >LCD
    4E >LCD
    44 >LCD 
    20 >LCD ;

\ Stampa "STOP" a display
: STOP 
    53 >LCD 
    54 >LCD
    4F >LCD
    50 >LCD 
    20 >LCD ;

\ Stampa "INSERT" a display
: INSERT 
    49 >LCD
    4E >LCD
    53 >LCD 
    45 >LCD
    52 >LCD
    54 >LCD
    20 >LCD ;

\ Stampa "TIME" a display
: TIME 
    54 >LCD
    49 >LCD
    4D >LCD 
    45 >LCD
    20 >LCD ;

\ Set di words che accede al blocco funzioni del LCD
\ Il nono bit impostato a 1 abilita ENABLE vedi datasheet 1602
\ Cancella il display
: CLEAR
  101 >LCD ;

\ Muove il cursore sulla seconda linea
: >LINE2
  1C0 >LCD ;

\ Visualizza il cursore sulla prima linea
: SETUP_LCD 
  102 >LCD ;
