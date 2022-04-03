\ Embedded Systems - Sistemi Embedded - 17873)
\ Bottone POWER ON )
\ Università degli Studi di Palermo )
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo timer.f

\ Word per il controllo del bottone d'avvio

HEX

\ Impostiamo il GPIO26 come output ( 001 ) sul bit 20:18 con 40000 in HEX a cui è associati il pulsante di accenzione.
: SETUP_BUTTON 
  40000 GPFSEL2 @ OR GPFSEL2 ! 
;

\ I registri di abilitazione del rilevamento del fronte di salita asincrono definiscono i pin per i quali è verificata la presenza di 
\ un fronte di salita asincrono: la transizione imposta un bit nei registri di stato di rilevamento eventi (GPEDSn).
\ Asincrono significa che il segnale in ingresso non è campionato dall'orologio di sistema. Tali fronti di salita si possono verificarsi 
\ in tempi molto brevi, in qualunque istante ed è possibile rilevare la durata. 

\ Rendiamo sensibile ai fronti di salita il GPIO26 a cui è associati il pulsante, quindi
\ avremo 1000 0000 0000 0000 0000 0000 0000 che equivale a 4000000 in decimale o 0x63 in esadecimale
\ l'OR logico ci permette di aggiornare e di non cancellare precedenti settaggi.

: GPAREN! 4000000 GPAREN0 @ OR GPAREN0 ! ;

