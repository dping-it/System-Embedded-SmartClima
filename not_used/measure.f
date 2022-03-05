exception: EGAVEUP
variable: data
variable: server

: measure ( -- temperature humidity | throws:EGAVEUP )
    10 0 do
        ['] dht-measure catch ?dup if ex-type cr 5000 ms else unloop exit then
    loop
    EGAVEUP throw ;

: data! ( temperature humidity -- ) 16 lshift swap or data ! ;
: connect ( -- ) 8005 "192.168.0.10" TCP netcon-connect server ! ;
: dispose ( -- ) server @ netcon-dispose ;
: send ( -- ) server @ data 4 netcon-write-buf ;
: log ( temperature humidity -- ) data! connect ['] send catch dispose throw ;
: log-measurement ( -- ) { measure log } catch ?dup if ex-type cr then ;
: main ( -- ) log-measurement 50 ms 120000000 deep-sleep ;