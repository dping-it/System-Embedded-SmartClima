\ Embedded Systems - Sistemi Embedded - 17873
\ Setting GPIO 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie ans.f

\ GPIO Mapping
HEX
FE000000 CONSTANT BASE  \ Indirizzo base dei registri
BASE 200000 + CONSTANT GPFSEL0  \ Spazio dei registri GPIO FE200000 
BASE 200004 + CONSTANT GPFSEL1
BASE 200008 + CONSTANT GPFSEL2
BASE 200040 + CONSTANT GPEDS0
BASE 20001C + CONSTANT GPSET0
BASE 200028 + CONSTANT GPCLR0
BASE 200034 + CONSTANT GPLEV0
BASE 200058 + CONSTANT GPFEN0
BASE 00B214 + CONSTANT IRQ2

\ Applica lo spostamento logico sinistro di 1 bit sul valore dato
\ e restituisce il valore spostato
\ Utilizzo: 2 MASK
   \ 2( BIN 0010 ) -> 4( BIN 0100 ) 
: MASK 1 SWAP LSHIFT ;

\ Imposta il pin GPIO specificato su HIGH se configurato come output
\ Utilizzo: 12 ( pin fisico ) HIGH -> Imposta il GPIO-18 su HIGH 
: HIGH 
  MASK GPSET0 ! ;

\ Resetta il pin GPIO specificato se configurato come output
\ Utilizzo: 12 ( pin fisico ) LOW -> Resetta il GPIO-18 
: LOW 
  MASK GPCLR0 ! ;

\ Verifica il valore effettivo dei pin GPIO 0..31
\ 0 -> Il pin GPIO n è LOW
\ 1 -> Il pin GPIO n è HIGH
\ Utilizzo: 12 TPIN (Test GPIO-18) 
: TPIN GPLEV0 @ SWAP RSHIFT 1 AND ;

\ Crea un tempo di attesa in millisecondi
\ Utilizzo: 1000 DELAY
: DELAY 
  BEGIN 1 - DUP 0 = UNTIL DROP ;

DECIMAL

\ GPIO ( n -- n ) takes GPIO pin number and test if is lower then 27 otherwise abort
: GPIO DUP 30 > IF ABORT THEN ;

\ MODE ( n -- a b c) takes GPIO pin number and leaves on the stack the number of left shift bit (a) required to set the corresponding GPIO control bits of GPFSELN,
\  where N is the register number, along with the GPFSELN register address (b) and the current value stored at (c) cleared by a MASK;
\ N ad (a) are calculated by dividing GPIO number by 10; N is the quotient multiplied by 4 while a is the reminder. Then GPFSELN is calculated by GPFSEL0 + N
\ ( e.g. GPIO 21 is controlled by GPFSEL2 so 21 / 10 --> N = 2 * 4, a = 1 --> GPFSEL0 + 8 = GPFSEL2 )
\ MASK is used to clear the 3 bits of GPFSEL register which controls GPIO states using INVERT AND and the value (a)
\ The mask is obtained by left shifting 7 (111 binary ) by 3 * (remainder of 10 division), e.g 21 / 10 -> 3 * 1 -> 7 left shifted by 3 ).
: MODE 10 /MOD 4 * GPFSEL0 + SWAP 3 * DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

\ OUTPUT (a b c -- ) taskes the output of MODE and then set the GPFSELN register of the corresponding GPIO as output.
\ The GPFSELN bit which controls GPIO output is set by the OR operation between the current value of GPFSELN, cleared by the mask, and a 1 left shifted by the reminder of 10
\ division multiplyed by 3. (001 value in the corresponding bit position of GPFSELN set GPIO as OUTPUT)
\ e.g with GPIO 21 AND @GPFSEL2: 011010--> 111000 011010 INVERT AND --> 000010 001000 OR --> 001010
: OUTPUT 1 SWAP LSHIFT OR SWAP ! ;

\ INPUT (a b c -- ) taskes the output of MODE and then set the GPFSELN register of the corresponding GPIO as input.
\ Same as OUTPUT but drop the not necessary shift value and the GPFSELN bit which controls GPIO input is set by the 
\ INVERT AND operation between the current value of GPFSELN, cleared by the mask,
: INPUT 1 SWAP LSHIFT INVERT AND SWAP ! ;

\ ON ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPCLR0 register
: ON 1 SWAP LSHIFT GPSET0 ! ;

\ OFF ( n -- ) takes GPIO pin number, left shift 1 by this number and set the corresponding bit of GPSET0 register
: OFF 1 SWAP LSHIFT GPCLR0 ! ;

\ LEVEL ( n -- b ) takes GPIO pin number, left shift 1 by this number, get current value of GPLEV0 register and leaves on the stack the value of the corresponding 
\ GPIO pin number bit
: LEVEL 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

\ GPFSELOUT! shortcut for setting gpio as output
: GPFSELOUT! GPIO MODE OUTPUT ;

\ GPFSELOUT! shortcut for setting gpio as input
: GPFSELIN! GPIO MODE INPUT ;

\ GPFSELOUT! shortcut for setting gpio high
: GPON! GPIO ON ;

\ GPFSELOUT! shortcut for setting gpio low
: GPOFF! GPIO OFF ;

\ GPFSELOUT! shortcut for getting gpio level
: GPLEV@ GPIO LEVEL ;

\ GPAFEN ( n -- ) set GPAFEN0 register for gpio pin n for async fall event 
: GPAFEN! GPIO 1 SWAP LSHIFT GPAFEN0 ! ;

\ IRQGPIO! ( -- ) enables IRQ source for gpio interrupt for 1-30 GPIO
: IRQGPIO! 1 17 LSHIFT IRQ2 @ OR IRQ2 ! ;