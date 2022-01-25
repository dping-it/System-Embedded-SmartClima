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
