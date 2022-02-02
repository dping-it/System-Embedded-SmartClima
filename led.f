\ Embedded Systems - Sistemi Embedded - 17873
\ Led Drive 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie gpio.f e ans.f

DECIMAL

13 COSTANT LED

: GPFSELn ( pinGPIO -- addrGPIO )
    10 / 4 * \ GPIO_Register_n * Offset
    GPFSEL0 + ; \ Base_Address + Offset
: TRIPLET ( pin -- bitToShift )
    10 mod 3 * ; \ How much shift for right the TRIPLET
: MASK ( pinGPIO -- pinMask)
    TRIPLET
    7 SWAP LSHIFT INVERT ; \ Create and Invert the Mask

\ ---------------------------------------------------------------------------------
\ Set one PIN in IN/OUT/ALTFUNCn MODE
\ Esempio d’uso: 13 PIN OUT MODE
: PIN ( pin -- pin pin_addr_value )
    DUP GPFSELn @ \ Fetch Value at the Pin_Address
    OVER MASK AND ; \ Clean the Pin triplet
: MODE ( pin pin_addr_value mode -- )
    2 PICK TRIPLET LSHIFT \ Move the GPIOmode to correct triplet
    OR \ pin_addr_value Update in MODE
    SWAP GPFSELn ! ; \ Store Value in pin_addr
\ ------------------------------------------------------------------------------
\ GPIO Input
: ON ( pin -- ) 1 SWAP LSHIFT GPSET0 ! ;
: OFF ( pin -- ) 1 SWAP LSHIFT GPCLR0 ! ;

\ GPIO Input
: ACTIVE  LED ON ;
: DEACTIVE LED OFF ;