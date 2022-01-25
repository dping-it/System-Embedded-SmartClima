\ Embedded Systems - Sistemi Embedded - 17873
\ Setting GPIO 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Must be INCLUDEd after ans.f

\ GPIO definitions
HEX
FE000000 CONSTANT DEVBASE
DEVBASE 200000 + CONSTANT GPFSEL0
DEVBASE 200004 + CONSTANT GPFSEL1
DEVBASE 200008 + CONSTANT GPFSEL2
DEVBASE 200040 + CONSTANT GPEDS0
DEVBASE 20001C + CONSTANT GPSET0
DEVBASE 200028 + CONSTANT GPCLR0
DEVBASE 200034 + CONSTANT GPLEV0
DEVBASE 200058 + CONSTANT GPFEN0

\ Applies Logical Left Shift of 1 bit on the given value
\ Returns the shifted value
\ Usage: 2 MASK
  \ 2(BINARY 0010) -> 4(BINARY 0100)
: MASK 1 SWAP LSHIFT ;

\ Sets the given GPIO pin to HIGH if configured as output
\ Usage: 12 HIGH -> Sets the GPIO-18 to HIGH
: HIGH 
  MASK GPSET0 ! ;

\ Clears the given GPIO pin if configured as output
\ Usage: 12 LOW -> Clears the GPIO-18
: LOW 
  MASK GPCLR0 ! ;

\ Tests the actual value of GPIO pins 0..31
\ 0 -> GPIO pin n is low
\ 1 -> GPIO pin n is high
\ Usage: 12 TPIN (Test GPIO-18)
: TPIN GPLEV0 @ SWAP RSHIFT 1 AND ;

: DELAY 
  BEGIN 1 - DUP 0 = UNTIL DROP ;
