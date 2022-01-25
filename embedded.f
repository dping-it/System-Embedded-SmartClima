\ Embedded Systems - Sistemi Embedded - 17873
\ some dictionary definitions
\ from  pijFORTHos
\ modificated by Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

: ':' [ CHAR : ] LITERAL ;
: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

: ( IMMEDIATE 1 BEGIN KEY DUP '(' = IF DROP 1+ ELSE ')' = IF 1- THEN THEN DUP 0= UNTIL DROP ;
: SPACES BEGIN DUP 0> WHILE SPACE 1- REPEAT DROP ;
: WITHIN -ROT OVER <= IF > IF TRUE ELSE FALSE THEN ELSE 2DROP FALSE THEN ;
: ALIGNED 3 + 3 INVERT AND ;
: ALIGN HERE @ ALIGNED HERE ! ;
: C, HERE @ C! 1 HERE +! ;
: S" IMMEDIATE ( -- addr len )
	STATE @ IF
		' LITS , HERE @ 0 ,
		BEGIN KEY DUP '"'
                <> WHILE C, REPEAT
		DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN
	ELSE
		HERE @
		BEGIN KEY DUP '"'
                <> WHILE OVER C! 1+ REPEAT
		DROP HERE @ - HERE @ SWAP
	THEN
;

: ." IMMEDIATE ( -- )
	STATE @ IF
		[COMPILE] S" ' TELL ,
	ELSE
		BEGIN KEY DUP '"' = IF DROP EXIT THEN EMIT AGAIN
	THEN
;


: JF-HERE   HERE ;
: JF-CREATE   CREATE ;
: JF-FIND   FIND ;
: JF-WORD   WORD ;

: HERE   JF-HERE @ ;
: ALLOT   HERE + JF-HERE ! ;

: [']   ' LIT , ; IMMEDIATE
: '   JF-WORD JF-FIND >CFA ;

: CELL+  4 + ;

: ALIGNED   3 + 3 INVERT AND ;
: ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

: DOES>CUT   LATEST @ >CFA @ DUP JF-HERE @ > IF JF-HERE ! ;

: CREATE   JF-WORD JF-CREATE DOCREATE , ;
: (DODOES-INT)  ALIGN JF-HERE @ LATEST @ >CFA ! DODOES> ['] LIT ,  LATEST @ >DFA , ;
: (DODOES-COMP)  (DODOES-INT) ['] LIT , , ['] FIP! , ;
: DOES>COMP   ['] LIT , HERE 3 CELLS + , ['] (DODOES-COMP) , ['] EXIT , ;
: DOES>INT   (DODOES-INT) LATEST @ HIDDEN ] ;
: DOES>   STATE @ 0= IF DOES>INT ELSE DOES>COMP THEN ; IMMEDIATE
: UNUSED ( -- n ) PAD HERE @ - 4/ ;

DROP

: AUTHOR
	S" TEST-MODE" FIND NOT IF
		." AUTHOR DAVIDE PROIETTO " VERSION . CR
		UNUSED . ." CELLS REMAINING" CR
		." OK "
	THEN
;
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
\ Embedded Systems - Sistemi Embedded - 17873
\ Setting commands 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Must be INCLUDEd after lcd.f and pad.f

\ The constant to define the position of a command validator
\ For this project a valid command contains a special character in the 3rd position of that command
\ Example: 12A# is a valid command as it contains the predefined special character on the 3rd position
\          06B3 is not a valid command as it does not contain the predefined special character
\             on the 3rd position
DEC

CONSTANT OK_POS 3

\ The constant to define the position of an operation type
\ A -> Device on
\ B -> Device off
\ Example: 12A# turns the device 12 on
\          12B# turns the device 12 off
CONSTANT OP_POS 2

\ The constant to define the position of a command validator
\ For this project a valid command contains a special character in the 3rd position of that command
\ Example: 12A# is a valid command as it contains the special character # (23 in HEX) on the 3rd position
\          06B* is not a valid command as it does not contain the predefined special character # (23 in HEX)
\             on the 3rd position
CONSTANT OK_C 23

\ Contants to define on and off operations
\ Example: 12A# -> Device no 12 is ON
\          12B# -> Device no 12 is OFF
CONSTANT ON_C A
CONSTANT OFF_C B
CONSTANT GET_C C

\ The number of the devices that the system supports (in HEX)
\ Example: DEV_NO A will define the CONSTANT as 10 in DECIMAL
CONSTANT DEV_NO 99

\ Variable to store the (OK_POS + 1) length commands
\ Changing the OK_POS CONSTANT will provide different length arrays
CREATE D_CMDS
D_CMDS OK_POS CELLS ALLOT

\ Variable to store (DEV_NO) number of devices (in HEX)
CREATE DEVS
DEVS DEV_NO 1 - CELLS ALLOT

\ Fetches the first 2 values stored in D_CMDS and converts it to a device number
\ Example: D_CMDS-0 contains 3
\          D_CMDS-1 contains E
\          Leaves 3E on TOS
: 2DEV 
  D_CMDS @ 4 LSHIFT
  D_CMDS CELL+ @ 
  OR ;

\ Sets a device on/off
\ Example: ON_C D_SET -> Sets the device on
\          OFF_C D_SET -> Sets the device off
: D_SET 
  >R DEVS 2DEV 4 * + R> SWAP ;

\ Opens the given device
\ Example: 1A >OPEN
: >OPEN 
  ON_C D_SET ! ;

\ Closes the given device
\ Example: 1A >CLOSE
: >CLOSE 
  OFF_C D_SET ! ;

\ Returns the state of the given device, which tells you if it's open or closed
\ Example: 1A <STATE
: <STATE 
  DEVS 2DEV 4 * + @ ;

\ Decides if a given command is OK or not by checking the OK_C
\   on the position OK_POS of that command
\ Example: 64B# ?CMD
: ?CMD
  D_CMDS OK_POS 4 * + @ OK_C = ;

: OP_TYPE 
  D_CMDS OP_POS 4 * + @ DUP 
  ON_C = IF 
    DROP >OPEN
  ELSE DUP OFF_C = IF 
    DROP >CLOSE
  ELSE GET_C = IF
    <STATE
  THEN THEN THEN ;

\ Resets the D_CMDS VARIABLE by writing 0's
CREATE AUX_I
: RES_CMD 
  0 AUX_I !
  BEGIN 
  D_CMDS AUX_I @ 4 * + ! 
  AUX_I @ 1 + AUX_I !
  AUX_I @ OK_POS 1 + = UNTIL ;

\ Executes the given command if it is valid, else prints NOT_VALID on the screen
: XCMD 
  ?CMD IF 
    OP_TYPE 
    1000 DELAY 4F >LCD
    1000 DELAY 4B >LCD
  ELSE 
    CLEAR 
    1000 DELAY NOT_VALID 
    3000 DELAY CLEAR
  THEN 
;

\ Embedded Systems - Sistemi Embedded - 17873
\ Keypad 
\ Università degli Studi di Palermo
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Must be INCLUDEd after lcd.f

\ For each row send an output
\ For each column control the values
\ If event detection bit is read we found the pressed key
  \ in row-column format
\ GPIO-18 -> Row-1 (1-2-3-A)
\ GPIO-23 -> Row-2 (4-5-6-B)
\ GPIO-24 -> Row-3 (7-8-9-C)
\ GPIO-25 -> Row-4 (*-0-#-D)
\ GPIO-16 -> Column-1 (A-B-C-D)
\ GPIO-22 -> Column-2 (3-6-9-#)
\ GPIO-27 -> Column-3 (2-5-8-0)
\ GPIO-10 -> Column-4 (1-4-7-*)

\ Enables falling edge detection for the pins which control the rows
  \ by writing 1 into corresponding pin positions (GPIO-18, 23, 24, 25)
\ (0x03840000) is (0000 0011 1000 0100 0000 0000 0000 0000) in BINARY
: SETUP_ROWS 
  3840000 GPFEN0 ! ;

\ Row pins are output, column pins are input 
\ GPFSEL1 field is used to define the operation of the pins GPIO-10 - GPIO-19
\ GPFSEL2 field is used to define the operation of the pins GPIO-20 - GPIO-29
\ Each 3-bits of the GPFSEL represents a GPIO pin
\ In order to address GPIO-10, GPIO-16, and GPIO-18 we should operate on the bits position 
  \ 2-1-0(GPIO-10), 20-19-18(GPIO-16) and 26-25-24(GPIO-18) storing the value into GPFSEL1
\ In order to address GPIO-22, GPIO-23, GPIO-24, GPIO-25, and GPIO-27 we should operate on the bits position 
  \ 8-7-6(GPIO-22), 11-10-9(GPIO-23), 14-13-12(GPIO-24), 17-16-15(GPIO-25), and 23-22-21(GPIO-27)
  \ storing the value into GPFSEL2
\ GPIO-18 is output -> 001
\ GPIO-23 is output -> 001
\ GPIO-24 is output -> 001
\ GPIO-25 is output -> 001
\ GPIO-16 is input -> 000
\ GPIO-22 is input -> 000
\ GPIO-27 is input -> 000
\ GPIO-10 is input -> 000
\ As a result we should write 
\   (0001 0000 0000 0000 0000 0000 0000) into GPFSEL1_REGISTER_ADDRESS IN HEX(0x1000000)
\   (0000 1001 0010 0000 0000) into GPFSEL2_REGISTER_ADDRESS IN HEX(0x9200)
: SETUP_IO 
  1000000 GPFSEL1 @ OR GPFSEL1 ! 
  9200 GPFSEL2 @ OR GPFSEL2 ! ;

\ Clear GPIO-18, GPIO-23, GPIO-24, and GPIO-25 using GPCLR0 register
  \ by writing 1 into the corresponding positions
\ (0x3840000) is (0011 1000 0100 0000 0000 0000 0000) in BINARY
: CLEAR_ROWS 
  3840000 GPCLR0 ! ;

\ Helper WORD to setup the keypad 
: SETUP_KEYPAD 
  SETUP_ROWS 
  SETUP_IO 
  CLEAR_ROWS ;

\ Tests a pin, if it is pressed leaves 1 on the stack else 0
: PRESSED 
  TPIN 1 = IF 1 ELSE 0 THEN ;

CREATE COUNTER

\ Increments the COUNTER variable by 1
: COUNTER++ 
  COUNTER @ 1 + COUNTER ! ;

\ Stores the HEX value of a character in D_CMDS array and emits it to LCD
\ Dupplicate the TOS and emit it
\ Leave D_CMDS address on TOS
\ Leave COUNTER value on TOS
\ Leave the address of the COUNTER'th index of D_CMDS array on TOS
\ Finally store the emitted HEX value to that address
\ Example: 42 EMIT_STORE -> Prints B on LCD and stores it into D_CMDS[COUNTER_current_value]
: EMIT_STORE 
  DUP 500 DELAY >LCD 
  D_CMDS
  COUNTER @ CELL+ * ! ;

\ Emits one of the chars found on Column-1 checking the given Row number
\ Example: 12 EMITC1 emits A (41 in HEX) to lcd
\          19 EMITC1 emits D (44 in HEX) to lcd
: EMITC1 
  DUP 12 = IF 41 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 42 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 43 DUP EMIT_STORE DROP ELSE 
  19 = IF 44 DUP EMIT_STORE 
  THEN THEN THEN THEN ;

\ Emits one of the chars found on Column-2 checking the given Row number
\ Example: 12 EMITC2 emits 3 (33 in HEX) to lcd
\          17 EMITC2 emits 6 (36 in HEX) to lcd
: EMITC2 
  DUP 12 = IF 33 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 36 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 39 DUP EMIT_STORE DROP ELSE 
  19 = IF 23 DUP EMIT_STORE 
  THEN THEN THEN THEN ;

\ Emits one of the chars found on Column-3 checking the given Row number
\ Example: 18 EMITC3 emits 8 (38 in HEX) to lcd
\          19 EMITC3 emits 0 (30 in HEX) to lcd
: EMITC3 
  DUP 12 = IF 32 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 35 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 38 DUP EMIT_STORE DROP ELSE 
  19 = IF 30 DUP EMIT_STORE 
  THEN THEN THEN THEN ;

\ Emits one of the chars found on Column-4 checking the given Row number
\ Example: 12 EMITC4 emits 1 (31 in HEX) to lcd
\          18 EMITC4 emits 7 (37 in HEX) to lcd
: EMITC4 
  DUP 12 = IF 31 DUP EMIT_STORE DROP ELSE 
  DUP 17 = IF 34 DUP EMIT_STORE DROP ELSE 
  DUP 18 = IF 37 DUP EMIT_STORE DROP ELSE 
  19 = IF 2A DUP EMIT_STORE 
  THEN THEN THEN THEN ;

\ Emits the given Row-Column char combination using the corresponding EMITC1/C2/C3/C4 WORD
\ Example: 12 10 EMIT_R
: EMIT_R
  DUP 10 = IF DROP EMITC1 ELSE 
  DUP 16 = IF DROP EMITC2 ELSE 
  DUP 1B = IF DROP EMITC3 ELSE 
  A = IF EMITC4 
  THEN THEN THEN THEN ;

\ Checks if a key of the given row is pressed, waits for it to be released
\   and emits the corresponding HEX value to LCD
: CHECK_CL 
  DUP DUP
    PRESSED 1 = IF 1000 DELAY 
    PRESSED 0 = IF 1000 DELAY 
      EMIT_R
      COUNTER++ 
    ELSE DROP DROP 
    THEN
    ELSE DROP DROP DROP 
  THEN ;

\ Checks the given Row by setting it to HIGH, checking its Columns and setting it to LOW finally
\ Example usage -> 12 CHECK_ROW (Checks the first row)
\               -> 17 CHECK_ROW (Checks the second row)
\               -> 18 CHECK_ROW (Checks the third row)
\               -> 19 CHECK_ROW (Checks the fourth row)
: CHECK_ROW
  DUP DUP DUP DUP DUP 
  HIGH  
    10 CHECK_CL 
    16 CHECK_CL
    1B CHECK_CL
    A CHECK_CL
  LOW ;

: ?CTR 
  COUNTER @ 4 = ;

: RES_CTR 
  0 COUNTER ! ;

\ The main WORD to detect any press/release event and eventually to emit the 
\   corresponding char to LCD
\ This WORD is called automatically when the SETUP WORD is called,
\   so unless you set the Rows to LOW you do not need to use this WORD
: DETECT
  0 COUNTER !
  BEGIN 
    12 CHECK_ROW
    17 CHECK_ROW
    18 CHECK_ROW
    19 CHECK_ROW
  ?CTR UNTIL 
;
: INIT
  SETUP_I2C
  SETUP_LCD
  SETUP_KEYPAD
  WELCOME
  LINE2
  SMARTS
  30000 DELAY
  CLEAR
  BEGIN
    RES_CMD
    DETECT
    1 0 = UNTIL
    ;

