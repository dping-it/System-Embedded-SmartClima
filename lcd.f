\ Embedded Systems - Sistemi Embedded - 17873)
\ LCD Setup e messages for LCD 1602 )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ Must be INCLUDEd after i2c.f

\ Prints "welcome" to screen
: WELCOME
  57 >LCD 
  45 >LCD
  4C >LCD
  43 >LCD  
  4F >LCD
  4D >LCD
  45 >LCD ;

\ Prints "not valid" to screen
: NOT_VALID 
  4E >LCD
  4F >LCD
  54 >LCD
  20 >LCD
  56 >LCD
  41 >LCD
  4C >LCD
  49 >LCD
  44 >LCD ;

: SMARTS 
    53 >LCD 
    4D >LCD
    41 >LCD
    52 >LCD  
    54 >LCD
    20 >LCD
    53 >LCD
    59 >LCD  
    53 >LCD
    54 >LCD
    45 >LCD
    4D >LCD ;


\ Clears the screen
: CLEAR
  101 >LCD ;

\ Moves the blinking cursor to second line
: >LINE2
  1C0 >LCD ;

\ Shows a blinking cursor at first line
: SETUP_LCD 
  102 >LCD ;
