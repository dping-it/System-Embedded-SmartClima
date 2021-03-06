\ Embedded Systems - Sistemi Embedded - 17873
\ Configurazione dei registri General Purpose e funzioni sui GPIO 
\ Università degli Studi di Palermo 
\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 

\ Includere dopo il flie ans.f

\ GPIO Mapping
HEX

\ Indirizzo base dei registri GPIO in VMU FE200000 
FE000000 CONSTANT BASE  

\ I registri di selezione della funzione vengono utilizzati per definire il funzionamento dei pin di I/O generici e delle funzioni
\ alternative relative.
BASE 200000 + CONSTANT GPFSEL0 
BASE 200004 + CONSTANT GPFSEL1
BASE 200008 + CONSTANT GPFSEL2

\ Registro dello stato di rilevamento degli eventi, utilizzato per registrare gli eventi di livello e
\ di onda sui pin GPIO.
BASE 200040 + CONSTANT GPEDS0

\ Registro del set di output utilizzato per impostare un pin GPIO. Ogni bit definisce il comportamento del pin GPIO da impostare ( bit 1 = GPIO0 )
\ Se il pin GPIO viene utilizzato come input (per impostazione predefinita), il valore nel campo SETn è ignorato.
\ Tuttavia, se il pin viene successivamente definito come uscita, il bit verrà impostato in base all'ultimo operazione di set/cancellazione.
BASE 20001C + CONSTANT GPSET0

\ Registro di cancellazione dell'uscita viene utilizzati per cancellare un pin GPIO. Ogni bit corrisponde ad un pin GPIO da cancellare ( bit 1 = GPIO0 )
\ Se il pin GPIO viene utilizzato come input (per impostazione predefinita), il valore nel campo CLRN è ignorato.
\ Tuttavia, se il pin viene successivamente definito come uscita, il bit verrà impostato in base all'ultimo operazione di set/cancellazione.
BASE 200028 + CONSTANT GPCLR0

\ Registro del livello del pin:  restituisce il valore effettivo del pin. Il campo LEVn fornisce il valore del rispettivo pin GPIO.
BASE 200034 + CONSTANT GPLEV0

\ Registro di abilitazione del rilevamento del fronte di discesa definisce i pin per i quali una transizione del fronte di discesa imposta 
\ un bit nell'evento di rilevamento registri di stato (GPEDSn). Il registro GPFENn utilizza il rilevamento del fronte sincrono. Questo
\ significa che il segnale di ingresso viene campionato utilizzando il clock di sistema e quindi cerca un pattern "100" sul segnale.
BASE 200058 + CONSTANT GPFEN0

\ Registro di abilitazione del rilevamento del fronte di salita asincrono sui pin GPIO dove è abilitato 
\ il controllo di stato di rilevamento eventi.
BASE 20007C + CONSTANT GPAREN0

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

\ GPIO ( n -- n ) prende il numero pin GPIO e verifica se è inferiore a 27, altrimenti interrompe
: GPIO DUP 30 > IF ABORT THEN ;

\ MODE ( n -- a b c) prende il numero del pin GPIO e lascia nello stack il numero del bit di spostamento a sinistra (a) richiesto per impostare i corrispondenti bit di controllo GPIO di GPFSELN,
\ dove N è il numero del registro, insieme all'indirizzo del registro GPFSELN (b) e al valore corrente memorizzato in (c) cancellato da una MASCHERA;
\ N ad (a) sono calcolati dividendo il numero GPIO per 10; N è il quoziente moltiplicato per 4 mentre a è il promemoria. Quindi GPFSELN viene calcolato da GPFSEL0 + N
\ (es. GPIO 21 è controllato da GPFSEL2 quindi 21 / 10 --> N = 2 * 4, a = 1 --> GPFSEL0 + 8 = GPFSEL2 )
\ MASK viene utilizzato per cancellare i 3 bit del registro GPFSEL che controlla gli stati GPIO utilizzando INVERT AND e il valore (a)
\ La maschera si ottiene spostando a sinistra 7 (111 binary ) di 3 * (resto di 10 divisioni), ad esempio 21 / 10 -> 3 * 1 -> 7 spostato a sinistra di 3 ).
: MODE 10 /MOD 4 * GPFSEL0 + SWAP 3 * DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

\ OUTPUT (a b c -- ) attiva l'uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come uscita.
\ Il bit GPFSELN che controlla l'uscita GPIO è impostato dall'operazione OR tra il valore corrente di GPFSELN, cancellato dalla maschera, e un 1 spostato a sinistra dal promemoria di 10
\ divisione moltiplicata per 3. (il valore 001 nella posizione del bit corrispondente di GPFSELN imposta GPIO come OUTPUT)
\ es. con GPIO 21 AND @GPFSEL2: 011010--> 111000 011010 INVERT AND --> 000010 001000 OR --> 001010
: OUTPUT 1 SWAP LSHIFT OR SWAP ! ;

\ INPUT (a b c -- ) attiva l'uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come input.
\ Uguale a OUTPUT ma elimina il valore di spostamento non necessario e il bit GPFSELN che controlla l'ingresso GPIO è impostato dal
\ INVERTE AND operazione tra il valore corrente di GPFSELN, azzerato dalla maschera,
: INPUT 1 SWAP LSHIFT INVERT AND SWAP ! ;

\ GPIO On e Off
\ : ON ( pin -- ) 1 SWAP LSHIFT GPSET0 ! ;
\ : OFF ( pin -- ) 1 SWAP LSHIFT GPCLR0 ! ;


\ ON ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPCLR0
: ON 1 SWAP LSHIFT GPSET0 ! ;

\ OFF ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPSET0
: OFF 1 SWAP LSHIFT GPCLR0 ! ;

\ LEVEL ( n -- b ) prende il numero pin GPIO, sposta a sinistra 1 di questo numero, ottiene il valore corrente del registro GPLEV0 e lascia nello stack il valore del corrispondente
\ Bit numero pin GPIO
: LEVEL 1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

\ GPFSELOUT! scorciatoia per impostare gpio come output
: GPFSELOUT! GPIO MODE OUTPUT ;

\ GPFSELIN! scorciatoia per impostare gpio come input
: GPFSELIN! GPIO MODE INPUT ;

\ GPFSELOUT! scorciatoia per impostare gpio HIGH
: GPON! GPIO ON ;

\ GPFSELOUT! scorciatoia per impostare gpio low
: GPOFF! GPIO OFF ;

\ GPFSELOUT! scorciatoia per ottenere il livello gpio
: GPLEV@ GPIO LEVEL ;

\ GPAFEN ( n -- ) imposta il registro GPAFEN0 per il pin gpio n per l'evento di caduta asincrono
: GPAFEN! GPIO 1 SWAP LSHIFT GPFEN0 ! ;

HEX
