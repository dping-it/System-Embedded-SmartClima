\ Embedded Systems - Sistemi Embedded - 17873
\ I2C Driver  
\ Università degli Studi di Palermo
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Must be INCLUDEd after gpio.f

\ 3 Broadcom Serial Controller (BSC) masters exist, we use the 2nd one
\ BSC1 register address: 0xFE804000 (Because our model is Rpi 4B)
\ To use the I2C interface add the following offsets to BCS1 register address
\ Each register is 32-bits long
\ 0x0  -> Control Register (used to enable interrupts, clear the FIFO, define a read or write operation and start a transfer)
\ 0x4  -> Status Register (used to record activity status, errors and interrupt requests)
\ 0x8  -> Data Length Register (defines the number of bytes of data to transmit or receive in the I2C transfer)
\ 0xc  -> Slave Address Register (specifies the slave address and cycle type)
\ 0x10 -> Data FIFO Register (used to access the FIFO)
\ 0x14 -> Clock Divider Register (used to define the clock speed of the BSC peripheral)
\ 0x18 -> Data Delay Register (provides fine control over the sampling/launch point of the data)
\ 0x1c -> Clock Stretch Timeout Register (provides a timeout on how long the master waits for the slave
\                                         to stretch the clock before deciding that the slave has hung)

\ I2C REGISTER ADDRESSES
\ DEVBASE 804000 + -> I2C_CONTROL_REGISTER_ADDRESS
\ DEVBASE 804004 + -> I2C_STATUS_REGISTER_ADDRESS
\ DEVBASE 804008 + -> I2C_DATA_LENGTH_REGISTER_ADDRESS
\ DEVBASE 80400C + -> I2C_SLAVE_ADDRESS_REGISTER_ADDRESS
\ DEVBASE 804010 + -> I2C_DATA_FIFO_REGISTER_ADDRESS
\ DEVBASE 804014 + -> I2C_CLOCK_DIVIDER_REGISTER_ADDRESS
\ DEVBASE 804018 + -> I2C_DATA_DELAY_REGISTER_ADDRESS
\ DEVBASE 80401C + -> I2C_CLOCK_STRETCH_TIMEOUT_REGISTER_ADDRESS

\ GPIO-2(SDA) AND GPIO-3(SCL) PINS SHOULD TAKE ALTERNATE FUNCTION 0
\ SO WE SHOULD CONFIGURE GPFSEL0 FIELD AS IT IS USED TO DEFINE THE OPERATION OF THE FIRST 10 GPIO PINS
\ EACH 3-BITS OF THE GPFSEL REPRESENTS A GPIO PIN, SO IN ORDER TO ADDRESS THE GPIO-2 AND GPIO-3
\   IN THE GPFSEL0 FIELD (32-BITS), WE SHOULD OPERATE ON THE BITS POSITION 8-7-6(GPIO-2) AND 11-10-9(GPIO-3)
\ AS A RESULT WE SHOULD WRITE (0000 0000 0000 0000 0000 1001 0000 0000) 
\   TO GPFSEL0_REGISTER_ADDRESS IN HEX(0x00000900)
: SETUP_I2C 
  900 GPFSEL0 @ OR GPFSEL0 ! ;

\ Resets Status Register using I2C_STATUS_REGISTER (DEVBASE 804004 +)
\ (0x00000302) is (0000 0000 0000 0000 0000 0011 0000 0010) in BINARY
\ Bit 1 is 1 -> Clear Done field
\ Bit 8 is 1 -> Clear ERR field
\ Bit 9 is 1 -> Clear CLKT field
: RESET_S 
  302 DEVBASE 804004 + ! ;

\ Resets FIFO using I2C_CONTROL_REGISTER (DEVBASE 804000 +)
\ (0x00000010) is (0000 0000 0000 0000 0000 0000 0001 0000) in BINARY
\ Bit 4 is 1 -> Clear FIFO
: RESET_FIFO
  10 DEVBASE 804000 + ! ;

\ Sets slave address 0x00000027 (Because our expander model is PCF8574T BLUE)
\ into I2C_SLAVE_ADDRESS_REGISTER (DEVBASE 80400C +)
: SET_SLAVE 
  27 DEVBASE 80400C + ! ;

\ Stores data into I2C_DATA_FIFO_REGISTER_ADDRESS (DEVBASE 804010 +)
: STORE_DATA
  DEVBASE 804010 + ! ;

\ Starts a new transfer using I2C_CONTROL_REGISTER (DEVBASE 804000 +)
\ (0x00008080) is (0000 0000 0000 0000 1000 0000 1000 0000) in BINARY
\ Bit 0 is 0 -> Write Packet Transfer
\ Bit 7 is 1 -> Start a new transfer
\ Bit 15 is 1 -> BSC controller is enabled
: SEND 
  8080 DEVBASE 804000 + ! ;

\ The main word to write 1 byte at a time
: >I2C
  RESET_S
  RESET_FIFO
  1 DEVBASE 804008 + !
  SET_SLAVE
  STORE_DATA
  SEND ;

\ Sends 4 most significant bits left of TOS
: 4BM>LCD 
  F0 AND DUP ROT
  D + OR >I2C 1000 DELAY
  8 OR >I2C 1000 DELAY ;

\ Sends 4 least significant bits left of TOS
: 4BL>LCD 
  F0 AND DUP
  D + OR >I2C 1000 DELAY
  8 OR >I2C 1000 DELAY ;

: >LCDL
 DUP 4 RSHIFT 4BL>LCD
 4BL>LCD ;

: >LCDM
  OVER OVER F0 AND 4BM>LCD
  F AND 4 LSHIFT 4BM>LCD ;

: IS_CMD 
  DUP 8 RSHIFT 1 = ;

\ Decides if we are sending a command or a data to I2C
\ Commands has an extra 1 at the most significant bit compared to data
\ An input like 101 >LCD would be considered a COMMAND to clear the screen
\   wheres an input like 41 >LCD would be considered a DATA to send the A CHAR (41 in hex)
\   to the screen
: >LCD 
  IS_CMD SWAP >LCDM 
;
