40 byte-array: bits
5  byte-array: bytes
2  init-variable: var-dht-pin \ default D4, wemos d1 mini dht22 shield, use dht-pin! to override
exception: ECHECKSUM

: dht-pin  ( -- gpio-pin ) var-dht-pin @ ;
: dht-pin! ( gpio-pin -- ) var-dht-pin ! ;

: init ( -- )
    dht-pin GPIO_LOW gpio-write
    20000 us
    dht-pin GPIO_HIGH gpio-write
    200 GPIO_HIGH dht-pin pulse-len
    drop ;
   
\ high pulse for 26-28 us is bit0, high pulse for 70 us is bit1    
: fetch ( -- )    
    40 0 do
        150 GPIO_HIGH dht-pin pulse-len
        50 > 
        i bits c!
    loop ;

: measure ( -- )
    os-enter-critical
    { init fetch } catch 
    os-exit-critical
    throw ;

: bit-at ( i -- bit )
    bits c@ if 1 else 0 then ;
    
: bytes-clear ( -- )
    5 0 do 
        0 i bytes c! 
    loop ;
    
: process ( -- )
    bytes-clear
    40 0 do        
        i 3 rshift bytes c@ 1 lshift
        i 3 rshift bytes c!        
        i 3 rshift bytes c@ i bit-at or
        i 3 rshift bytes c!
    loop ;

: checksum ( -- )    
    0 bytes c@
    1 bytes c@ +
    2 bytes c@ +
    3 bytes c@ + 255 and ;
    
: validate ( -- | throws:ECHECKSUM )
    checksum 4 bytes c@ <> if 
        ECHECKSUM throw 
    then ;

: convert ( lsb-byte msb-byte -- value )
    { 16r7F and 8 lshift or } keep
    128 and 0<> if
        0 swap -
    then ;
    
: humidity ( -- humidity%-x-10 ) 1 bytes c@ 0 bytes c@ convert ;
: temperature ( -- celsius-x-10 ) 3 bytes c@ 2 bytes c@ convert ;
    
\ measures temperature and humidity using DHT22 sensor
\ temperature and humidity values are multiplied with 10
: dht-measure ( -- celsius-x-10 humidity%-x-10 )
    dht-pin GPIO_OUT_OPEN_DRAIN gpio-mode
    measure
    process
    validate
    temperature humidity ;