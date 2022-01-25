\ Embedded Systems - Sistemi Embedded - 17873
\ I2C Driver  
\ Università degli Studi di Palermo
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo gpio.f

\ Ci sono otto master Broadcom Serial Controller (BSC) all'interno di BCM2711,
\ BSC2 e BSC7 sono dedicati all'uso da parte delle interfacce HDMI, qui utilizziamo BSC1 all'indirizzo: 0xFE804000  

\ Per utilizzare l'interfaccia I2C, basta aggiungere i seguenti offset all'indirizzo del registro BCS1.
\ Ogni registro è lungo 32 bit

\ 0x0 -> Control Register ( usato per abilitare gli interrupt, cancellare il FIFO, definire un'operazione di lettura o scrittura e avviare un trasferimento )
\ 0x4 -> Status Register ( usato per registrare lo stato delle attività, gli errori e le richieste di interruzione )
\ 0x8 -> Data Length Register ( definisce il numero di byte di dati da trasmettere o ricevere nel trasferimento I2C )
\ 0xc -> Slave Address Register ( specifica l'indirizzo slave e il tipo di ciclo )
\ 0x10 -> Data FIFO Register ( utilizzato per accedere al FIFO )
\ 0x14 -> Clock Divider Register ( usato per definire la velocità di clock della periferica BSC )
\ 0x18 -> Data Delay Register ( fornisce un controllo accurato sul punto di campionamento/lancio dei dati )
\ 0x1c -> Clock Stretch Timeout Register ( fornisce un timeout su quanto tempo il master può attende lo slave, così da allungare il timeout, prima di decretarne la caduta )

\ I2C REGISTER ADDRESSES
\ BASE 804000 + -> I2C_CONTROL_REGISTER_ADDRESS
\ BASE 804004 + -> I2C_STATUS_REGISTER_ADDRESS
\ BASE 804008 + -> I2C_DATA_LENGTH_REGISTER_ADDRESS
\ BASE 80400C + -> I2C_SLAVE_ADDRESS_REGISTER_ADDRESS
\ BASE 804010 + -> I2C_DATA_FIFO_REGISTER_ADDRESS
\ BASE 804014 + -> I2C_CLOCK_DIVIDER_REGISTER_ADDRESS
\ BASE 804018 + -> I2C_DATA_DELAY_REGISTER_ADDRESS
\ BASE 80401C + -> I2C_CLOCK_STRETCH_TIMEOUT_REGISTER_ADDRESS

\ I pin GPIO-2 (SDA) e GPIO-3 (SCL) devono prendere la ALTERNATIVE FUNCTION 0
\ quindi dobbiamo configurare il GPFSEL0 che viene utilizzato per definire il funzionamento dei primi 10 pin GPIO.
\ ogni 3-bit del gpfsel rappresentano un pin GPIO, così per indirizzare GPIO-2 e GPIO-3
\ nel campo GPFSEL0 (32-bits), dobbiamo operare sui bit in posizione 8-7-6 (GPIO-2) e 11-10-9 (GPIO-3)
\ di conseguenza dobbiamo scrivere (0000 0000 0000 0000 0000 1001 0000 0000) ovvero in HEX (0x00000900)
\ su GPFSEL0 per settare la ALTERNATIVE FUNCTION 0

: SETUP_I2C 
  900 GPFSEL0 @ OR GPFSEL0 ! ;


\ Ripristina lo Status Register utilizzando I2C_STATUS_REGISTER (BASE 804004 +)
\ HEX (0x00000302) è (0000 0000 0000 0000 0000 0011 0000 0010) in BIN
\ Il bit 1 è 1 -> Cancella campo DONE
\ Il bit 8 è 1 -> Cancella campo ERR
\ Il bit 9 è 1 -> Cancella campo CLKT 
: RESET_S 
  302 BASE 804004 + ! ;

\ Ripristina FIFO utilizzando I2C_CONTROL_REGISTER (BASE 804000 +)
\ HEX (0x00000010) è (0000 0000 0000 0000 0000 0000 0001 0000) in BIN
\ Il bit 4 è 1 -> Cancella FIFO 
: RESET_FIFO
  10 BASE 804000 + ! ;

\ Imposta l'indirizzo SLAVE 0x00000027 ( perché il nostro modello DRIVE è PCF8574T )
\ in I2C_SLAVE_ADDRESS_REGISTER (BASE 80400C +) 
: SET_SLAVE 
  27 BASE 80400C + ! ;

\ Stores data into I2C_DATA_FIFO_REGISTER_ADDRESS (BASE 804010 +)
: STORE_DATA
  BASE 804010 + ! ;

\ Starts a new transfer using I2C_CONTROL_REGISTER (BASE 804000 +)
\ (0x00008080) is (0000 0000 0000 0000 1000 0000 1000 0000) in BINARY
\ Bit 0 is 0 -> Write Packet Transfer
\ Bit 7 is 1 -> Start a new transfer
\ Bit 15 is 1 -> BSC controller is enabled
: SEND 
  8080 BASE 804000 + ! ;

\ The main word to write 1 byte at a time
: >I2C
  RESET_S
  RESET_FIFO
  1 BASE 804008 + !
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
