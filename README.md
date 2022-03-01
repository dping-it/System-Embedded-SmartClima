**Corso di Laurea Magistrale in Ingegneria Informatica – progetto Embedded** **System**
#


















**Project Work : Soluzione Bare Metal** 

**per la gestione del clima ideale in un sistema “serra”.**
# **
# Sommario
[	1](#_Toc95566912)

[**Descrizione del progetto**	4](#_Toc95566913)

[**Prerequisiti concettuali**	4](#_Toc95566914)

[**Componenti Hardware**	4](#_Toc95566915)

[**Schema del sistema**	5](#_Toc95566916)

[**Schema di collegamento Header**	5](#_Toc95566917)

[**Il targhet: RaspBerry PI 4 B**	6](#_Toc95566918)

[**Componenti Software**	6](#_Toc95566919)

[**Preparazione dell’ambiente di sviluppo**	6](#_Toc95566920)

[**Preparazione della SD e dell’interprete**	7](#_Toc95566921)

[**Descrizione dei componenti**	9](#_Toc95566922)

[***FTDI 232-USB Interfaccia UART***	9](#_Toc95566923)

[***Modulo LCD 1602 con Drive I^2C PCF85741/3***	9](#_Toc95566924)

[**Tastierino KeyPad a matrice 5x4**	12](#_Toc95566925)

[**Modulo relay HL-52s**	13](#_Toc95566926)

[**Sistema LED**	14](#_Toc95566927)

[**Flusso degli eventi**	15](#_Toc95566928)

[**Il codice**	15](#_Toc95566929)

[**Dettaglio files sorgenti**	15](#_Toc95566930)

[**Testing**	35](#_Toc95566931)

[**Conclusioni**	40](#_Toc95566932)




**
## **Descrizione del progetto**
Realizzazione di una interfaccia di controllo per la gestione del clima ottimale in un sistema “serra”. Ovviamente il progetto è realizzato su dimensioni ridotte, ma è comunque riproducibile su larga scala con i dovuti accorgimenti. Il sistema è realizzato con il **target scelto “Raspberry PI 4 B**”, consente di gestire in maniera automatizzata il controllo della ventilazione e dell’irraggiamento luminoso alle colture presenti nella serra. Una volta impostati i parametri di temporizzazione da tastiera il sistema “bare metal” gestisce l’azione degli attuatori riportando a display le relative informazioni, in maniera del tutto autonoma, come vedremo nel dettaglio più avanti. 

## **Prerequisiti concettuali**
Per lo sviluppo di un progetto di questa tipologia si utilizza un approccio bottom up. Il target va scelto in funzione alle aspettative del sistema: scegliere una CPU General Purpose piuttosto che una CPU Embedded e viceversa è una scelta che deve tenere conto di tanti aspetti: la possibilità di interazione con i sensori del sistema, l’utilizzo di hardware specializzato, le caratteristiche relative al tempo medio nei confronti delle istruzioni necessarie al funzionamento, il fattore economico costo *componenti – effetto ottenuto*, e, non da poco, l’aspetto del consumo energetico che oggi giorno è preponderante. Per la realizzazione di un Software embedded possiamo scegliere tra tre tipologie di programmazione:

- Compilazione su una macchina target che richiede il supporto di un OS per l’utilizzo dei toolchain.
- La compilazione incrociata “Cross-compilation” che prevede l’uso di una macchina di sviluppo collegata al target o ad un emulatore con l’ausilio di software di supporto.
- Programmazione interattiva sul target: il codice sorgente viene inviato direttamente all’interprete (*PIJForthOS* nel nostro caso) che lo compila nello stesso target.

Inoltre risulta essere molto utile testare i meccanismi e le connessioni dei i sensori con un linguaggio ad alto livello, se disponibile, prima di cimentarsi allo sviluppo di codice specializzato a basso livello. 
## **Componenti Hardware**
Per la realizzazione del progetto è necessario il seguente materiale:

- Raspberry Pi 4B 2 GB con alimentatore;
- MicroSD 16 GB;
- FT232RL USB Interfaccia Seriale UART;
- Sharp TC1602B-01 VER:00 16x2 LCD BLU;
- Philips PCF8574AT Remote 8-bit I/O espansione per I2C-bus;
- Relay Module HL-52s;
- Lampada piatta Led 10 W 220v con interruttore;
- Ventola 12V  15\*15 cm;
- 5x4 Keypad Matrix;
- BreadBoard e Cavi connessione M/F e M/M;
- 3 Led vari colori;
- 3 Resistori ceramidi da 200 ohm;
- Personal Computer;
- Cavo USB – miniUSB M/M;
- Vaso, terra, piante e rivestimento pellicola.

## **Schema del sistema**

## **Schema di collegamento Header**


|***FUN***|***CONN***|***HEADER***|***PIN***|***PIN***|***HEADER***|***CONN***|***FUN***|
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
||||**1**|**2**|5V VCC|LCD/I2C VCC||
|I2C1 SDA|SERIAL DATA (SDA)|GPIO 2|**3**|**4**|5V VCC|BREADBOARD||
|I2C1 SCL|SERIAL CLOCK (SCL)|GPIO 3|**5**|**6**|GND|BREADBOARD||
||||**7**|**8**|UART TX|FTDI RX||
||||**9**|**10**|UART RX|FTDI TX||
||PAD ROW 1|GPIO 17|**11**|**12**|GPIO 18|PAD ROW 2||
||PAD COL 3|GPIO 27|**13**|**14**|GND|LCD/I2C GND||
||PAD COL 2|GPIO 22|**15**|**16**|GPIO 23|PAD ROW 3||
||||**17**|**18**|GPIO 24|PAD ROW 4||
||PAD COL 4|GPIO 10|**19**|**20**||||
||||**21**|**22**|GPIO 25|PAD ROW 5||
||||**23**|**24**||||
||||**25**|**26**||||
||||**27**|**28**||||
||LED BUSY WIND|GPIO 5|**29**|**30**||||
||LED STOP|GPIO 6|**31**|**32**|GPIO 12|LED READY LIGHT||
||||**33**|**34**||||
||||**35**|**36**|GPIO 16|PAD COL 1||
||||**37**|**38**||||
||||**39**|**40**||||
## **Il targhet: RaspBerry PI 4 B**
Il Raspberry Pi 4 Model B monta un microcontrollore ARM Broadcom BCM2711 quad-core Cortex-A72 a 1.5 Ghz.

Questo target è molto potente poiché può essere programmato dalle applicazioni embedded più semplici come il “blinking led” ad ospitare a bordo interi sistemi operativi Linux e Windows con interfacce grafiche.


Specifiche:

Broadcom **BCM2711**, Quad core Cortex-A72 

(ARM v8) 64-bit SoC @ 1.5GHz

` `2GB, 4GB or 8GB LPDDR4-3200 SDRAM 

` `2.4 GHz and 5.0 GHz IEEE 802.11ac wireless, Bluetooth 5.0, BLE

` `Gigabit Ethernet

` `2 USB 3.0 ports; 2 USB 2.0 ports.

` `**Raspberry Pi standard 40 pin GPIO header** (fully backwards compatible with previous boards)

`    `2 × micro-HDMI ports (up to 4kp60 supported)

`    `2-lane MIPI DSI display port

`    `2-lane MIPI CSI camera port

`    `4-pole stereo audio and composite video port

`    `H.265 (4kp60 decode), H264 (1080p60 decode, 1080p30 encode)

`    `OpenGL ES 3.1, Vulkan 1.0

` `Micro-SD card slot for loading operating    system and data storage

`    `5V DC via USB-C connector (minimum 3A\*)

`    `5V DC via GPIO header (minimum 3A\*)

`    `Power over Ethernet (PoE) enabled 

` `Operating temperature: 0 – 50 degrees C 



## **Componenti Software**
•     Distro linux ( Mint 20.3 LTS )  con installato G-Forth, Minicom e Picocom;

( sudo picocom --b 115200 /dev/ttyUSB0 --send "ascii-xfr -sv -l100 -c10" --imap delbs )

- PijFORTHOS  1. 8  ( gentile concessione Prof D. Peri ) un interprete Forth per soluzioni Bare Metal;


## **Preparazione dell’ambiente di sviluppo**
L’invio del codice sorgente avviene tramite terminale con protocollo FTDI RS-232.

A tal scopo dobbiamo installare dei tool per la comunicazione e l’interprete Forth per comodità. Da terminale:

- sudo apt-get install -y gcc-arm-none-eabi 
- sudo apt-get install -y picocom
- sudo apt-get install -y minicom

Al fine di stabilire la connessione con il target useremo picocom digitando la stringa che ci permette di avviare la comunicazione, permettere l’invio di file con il supporto ASCII e formattare il terminale in maniera corretta:

sudo picocom --b 115200 /dev/**ttyUSB0** --send "ascii-xfr -sv -l100 -c10" --imap delbs
##
## **Preparazione della SD e dell’interprete**
La soluzione migliore per preparare il Raspberry è quella di formattare ed installare il Sistema operativo base di Rasbian PI OS Lite con il programma Raspberry Pi Imager <https://www.raspberrypi.com/software/> . Questo ci permetterà al primo avvio, di partizionare la SD in modo corretto e nello stesso tempo verranno caricati tutti i files necessari al bootstrapping del nostro target. Scendendo nel dettaglio tra tutti i files presenti, solo alcuni sono utilizzati al nostro scopo. La prima fase di boot è svolta dal VideoCore che carica il primo strato dei file d’avvio. 

Per i files bootcode.bin e fixup.dat dobbiamo utilizzare quelli generati durante la preparazione della sd. È necessario eliminare tutti gli kernel*X*.img . A questo punto scarichiamo e copiamo sulla sd i file dell’interprete Forth che sono 





presenti nel repo <https://github.com/organix/pijFORTHos> ( o versione modificata prof D. Peri ).

Forth ha già definiti nel proprio dizionario un potente set di comandi standard, e fornisce dei meccanismi con cui si possono definire i nuovi comandi. Questo processo strutturale di costruzione *di definizioni su definizioni precedenti* rende Forth al pari di un linguaggio ad alto livello. Le words possono essere definite direttamente nei mnemonici assembler. Tutti i comandi sono interpretati dallo stesso interprete e compilati dallo stesso compilatore, conferendo al linguaggio estrema flessibilità. Questo interprete va caricato nel kernel.


Poiché usiamo un sistema a 32bit chiameremo il file blob kernel7.img. Per la produzione di questo file si può usare lo strumento di cross-compiling **gcc-arm-none-eabi** Toolchain <https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads> .

Per rendere possibile la comunicazione tra l’interprete Forth e l’interfaccia di programmazione dobbiamo abilitare la UART del PI.






Nel file config.txt inseriamo la stringa di abilitazione come in figura:

*enable\_uart=1*


**
## **Descrizione dei componenti**
##
## ***FTDI 232-USB Interfaccia UART***
` `La "USB to Serial Adapter with FT232RL" permette di collegare i PC con qualsiasi sistema a microcontrollore attraverso la porta USB. Usa l’integrato FT232RL della FTDI, dotato di buffer in ricezione da 128 byte e buffer in trasmissione da 256 byte che garantiscono robustezza in trasmissioni ad alta velocità fino a 3Mbaud/s. Oltre ai segnali TX e RX, sono presenti anche le linee CTS, RTS e le altre linee di handshaking. Collegando la scheda alla porta USB, il PC la riconoscerà come una VirtualCOM Port seriale(VCP) attraverso la quale possiamo stabilire la connessione con il targhet emulando la porta seriale RS232, senza bisogno di alcuna modifica. Per il collegamento è sufficiente fornire la linea di alimentazione dalla breadboard e collegare le linee segnale **TX ed RX** alle rispettive **RX e TX** del PI come da tabella. Dato che si tratta di un collegamento SPI Asincrono doppiamo specificare i parametri di sincronizzazione, come la velocità di trasmissione che sarà 115200 e la dimensione del Frame che sarà di un byte.

## ***Modulo LCD 1602 con Drive I^2C PCF85741/3***
Questo progetto utilizza un LCD 16x2 (16 righe x 2 colonne) con un modulo I2C integrato. L'LCD è in grado di visualizzare caratteri, lettere, numeri e simboli ASCII.  Infatti, comunichiamo con il display LCD semplicemente inviando il codice ASCII del carattere che vogliamo mostrare, in HEX.

L'utilizzo di un'interfaccia I2C che collega l'ingresso seriale e la modalità di uscita parallela all'LCD consente di farlo utilizzare solo 4 linee per comunicare con il display LCD. Il chip IC utilizzato è PCF8574AT e per poter ricavare l’indirizzo dello slave si può utilizzare il sistema operativo Raspbian digitando da terminale il comando *i2cdetect -y* *1* per recuperare le due cifre in esadecimale.

` `Il Bus I2C è un:

- sincrono
- multimaster
- multislave
- commutazione di pacchetto
- single-ended

|**SCHEMA PARALLELO I2C<->LCD**|
| :-: |
|**On board PC8574T**|**Attached LCD 2004A**|
|P0|RS|
|P1|RW|
|P2|E|
|P3|Backlight|
|P4|D4|
|P5|D5|
|P6|D6|
|P7|D7|

` `Questo tipo di bus seriale è generalmente utilizzato per collegare circuiti integrati periferici a bassa velocità a processori/microcontrollori a breve distanza.

I cavi Serial Data (SDA) e Serial Clock (SCL) trasportano i dati in un bus I2C.

Usando il meccanismo di Open-Drain per la comunicazione bidirezionale possiamo trasferire il livello logico 0 tirando giù la linea data, il livello logico 1  lasciandola “fluttuante”, grazie al resistore di pull-up.

Descrizione del funzionamento del bus I2C:

- Il master inizia la comunicazione inviando:
  - Start Condition
  - L’ indirizzo slave (7 bit)
  - 0 per la scrittura R/W (1 bit)

- Lo slave invia l’ ACK per confermare la ricezione
- Il master invia l'indirizzo del registro in cui scrivere
- Lo slave invia l’ ACK per confermare la ricezione del registro
- Il master inizia a inviare i dati effettivi
- Il master invia la Stop Condition per terminare la comunicazione

In questo caso il master è il Raspberry Pi 4 e lo slave è il modulo LCD I2C.

Mentre l'SCL è alto, una transizione da alto a basso sulla linea SDA con SCL alto definisce una “Start Condition” condizione d’avvio, e alla transizione da basso ad alto sulla linea SDA con SCL alto si definisce “Stop Condition” condizione di arresto. Durante ogni impulso di clock del SCL, un bit di dati viene trasmesso tramite SDA. È possibile trasferire un numero qualsiasi di byte di dati tra la Condizioni di avvio e arresto. I dati vengono trasferiti inviando per primo il bit più significativo.

Ogni byte di dati riceve una risposta ACK (riconoscimento) dal ricevente. Per ricevere l’ACK, il mittente deve rilasciare la linea SDA, in modo che il destinatario possa tirare la linea SDA verso il basso che diventa stabilmente basso durante la fase alta del periodo di clock ACK.

Il collegamento seriale è gestito direttamente dal bus i2c.

La WORD **>I2C** del nostro codice scrive un byte relativo all’indirizzo del bus I2C nel master Broadcom Serial Controller (BSC). In questo progetto utilizziamo il secondo indirizzo master, che otteniamo sommando l'offset 804008 all'indirizzo del dispositivo di base. La parola **>LCD** controlla se vogliamo inviare un comando o una parte di dati, il bus decodifica e serializza un byte di cui i bit sono posizionati in modo significativo. Per ad esempio, il comando 2C >LCD produce (0x2C = 0010 1100) sul bus I2C:

per la comunicazione seriale all’LCD avremo i 4 bit di selezione e le impostazioni

D7=0, D6=0, D5=1, D4=0, Retroilluminazione=1, Abilita=1, R/W’=0, RS=0

Il comando 28 >LCD produce (0x2C = 0010 1000) sul bus I2C:

D7=0, D6=0, D5=1, D4=0, Retroilluminazione=1, Abilita=0, R/W’=0, RS=0

Questa sequenza di comandi viene interpretata come il comando Function Set (0x20 = 0010 0000) con il parametro DL=0. Di conseguenza, possiamo passare il bus alla modalità a 4 bit. Utilizzando la modalità a 4 bit, per inviare 1 byte a LCD dobbiamo scrivere 4 volte sul bus I2C:

- 4 bit più significativi con Enable = 1
- 4 bit più significativi con Enable = 0
- 4 bit meno significativi con Enable = 1
- 4 bit meno significativi con Enable = 0

Dopo questa configurazione si può inviare qualsiasi carattere ASCII digitando il suo codice HEX e chiamando >LCD word; ad esempio 45 >LCD (che invia A all'LCD). 
## **Tastierino KeyPad a matrice 5x4**
Questo Keypad è composto da una matrice di linee circuitali 5 righe x 4 colonne. Utilizzando uno dei metodi di scansione delle righe o un metodo di scansione della colonna possiamo rilevare se il tasto è stato premuto. 

A tale scopo si configurano:

- i pin GPIO che controllano le righe come output (pin GPIO 17, 18, 23, 24, 25) 
- ` `i pin GPIO che controllano le colonne come input (pin GPIO 16, 22, 27, 10)
- ` `Si abilita il rilevamento del fronte di discesa per i pin che controllano le righe al fine di verificare il valore corrente del segnale rispetto al valore che aveva un passo temporale precedente ovvero il registro GPFEN0
- ` `Il registro GPFSEL1 viene utilizzato per definire il funzionamento dei pin GPIO-10 - GPIO-19
- ` `Il registro GPFSEL2 viene utilizzato per definire il funzionamento dei pin GPIO-20 - GPIO-29
- Ogni riga può essere cancellata utilizzando il registro GPCLR corrispondente.

Ad ogni iterazione

- Impostiamo HIGH sulla riga che vogliamo controllare utilizzando il registro GPSET corrispondente
- Premiamo un tasto qualsiasi della riga impostata su HIGH
- Il ciclo di scansione controlla il valore del pin GPIO che controlla la colonna del tasto premuto, tramite il registro GPLEV corrispondente: se il valore è HIGH l'evento press è stato rilevato correttamente.

La configurazione dei pin non è vincolante, basta essere certi di controllare la resistenza Pull Up/Pull Down dei pin selezionati.

Per avviare queste configurazioni oltre ad aver definito i registri con costanti simboliche adatte, basta chiamare la WORD **SETUP\_KEYPAD** per abilitare la tastiera.


## **Modulo relay HL-52s**
Possiamo controllare i dispositivi elettronici ad alta tensione usando i relè. Un relè è in realtà un interruttore che è azionato elettricamente da un elettromagnete. L’elettromagnete viene attivato con una bassa tensione, nel nostro caso 5 volt da dal microcontrollore del PI che chiude un contatto per fare erogare o interrompere un circuito ad alta tensione.
Il modulo relè HL-52S a 2 canali ha 2 relè con portata di 10A @ 250 e 125 V AC e 10A @ 30 e 28 V DC. Il connettore di uscita ad alta tensione ha 3 pin, quello centrale è il pin comune e come si vede dalle marcature uno degli altri due pin è per la connessione normalmente aperta e l’altro per la connessione normalmente chiusa.
Dall’altro lato del modulo abbiamo 2 gruppi di pin. Il primo ha 4 pin, una massa e un pin VCC per alimentare il modulo e 2 pin di ingresso In1 e In2 ai rispettivi relè. Il secondo set di pin ha 3 pin con un ponticello tra il JDVcc e il pin Vcc. 


In questa configurazione l’elettromagnete del relè è alimentato direttamente dal Raspberry. I carichi di alimentazione degli attuatori, **lampada e ventola**, arrivano da sorgenti esterne, che in uno scenario ecosostenibile potrebbero derivare direttamente da fonti rinnovabili. 


## **Sistema LED**
Il sistema led è composto da 3 led di colore diverso e da 3 resistori ceramici da 200 ohm che servono da protezione agli stessi led.

Ogni led è collegato ad un GPIO specifico che ne abilita l’emissione luminosa e lo stesso GPIO gestisce il NC dell’attivazione di un relè.

I GPIO 5, 6, e il 12 sono configurati come OUT.

Quando lo stato passa ad alto, il circuito si chiude a massa, ed il led si accende. Se ciò avviene il contatto NC del relè si interrompe e l’attuatore collegato viene disattivato.

Per cui abbiamo il seguente schema:

|**FUNZ**|**GPIO**|**LED**|**STATO**|**ATTUATORE**|
| :-: | :-: | :-: | :-: | :-: |
|STOP SISTEMA|6|ROSSO|ON|STOP|
|ATTIVA LUCE|5|GIALLO|ON|VENTOLA|
|ATTIVA VENTO|12|VERDE|ON|LAMPADA LED|

Per utilizzare in maniera corretta i sensori sono state create delle WORD che rappresentano la configurazione a semaforo dei tre led:

*Davide Proietto 0739290 – Anno Accademico 2021/22 		pag. 39**

: GO\_LIGHT 

`  `REDLED GPOFF!

`  `STOPWIND

`  `CLEAR

`  `SYSTEM

`  `LIGHT

`  `SYSTEMLIGHT

`  `;

: GO\_WIND 

`  `REDLED GPOFF!

`  `STOPLIGHT

`  `CLEAR

`  `SYSTEM

`  `WIND

`  `SYSTEMWIND

`  `;

: STOP\_DISP 

`  `ALL\_LED\_ON

`  `CLEAR

`  `SYSTEM

`  `STOP

`  `;

## **Flusso degli eventi**
All’avvio (digitando la WORD “SETUP”) il sistema si inizializza e visualizza il nome del dispositivo e lo stato attuale. 

A questo punto sarà necessario l’immissione dei dati di temporizzazione espresso in secondi da 0 a 99: le prime due cifre per il SISTEMA ILLUMINAZIONE e altre due per quello di VENTILAZIONE. Si tratta di definire così i tempi relativi agli attuatori “Illuminazione” e “Ventilazione” tutto ciò sarà reso possibile attraverso il keypad.

Una volta inserito questo dato il sistema inizia un ciclo di 4 scambi, controllato da una variabile COUNTER che alterna l’utilizzo del SYSTEM LIGHT al SYSTEM WIND e da una variabile FLAG che viene settata al termine degli scambi.

Il sistema alternerà l’utilizzo degli attuatori in base al delay inserito. Questo processo è inserito in un ciclo infinito.

Nel caso di anomalie o manutenzione il sistema potrà essere disabilitato premendo il tasto ESC in fase di digitazione tempi.

## **Il codice**
Il codice sorgente è suddiviso e commentato in singoli file per area tematica. Ma in fase di caricamento è opportuno unificare e pulire il codice dal commento per aumentare la velocità di caricamento. Ovvero verrà inviato tramite picocom con la scorciatoia CTRL +A +S in un unico file con nome final.f realizzato dal comando make:

EMBEDDED: ans.f gpio.f i2c.f lcd.f led.f pad.f main.f

`  `rm -f embedded.f

`  `rm -f final.f

`  `cat ans.f >> embedded.f

`  `cat gpio.f >> embedded.f

`  `cat i2c.f >> embedded.f

`  `cat lcd.f >> embedded.f

`  `cat led.f >> embedded.f

`  `cat pad.f >> embedded.f

`  `cat main.f >> embedded.f

`  `grep -v '^ \*\\' embedded.f > final.f

## **Dettaglio files sorgenti**
Ans.f: Inserisce nel dizionario dell’interprete forth alcune WORDS necessarie alla compilazione dei sorgenti

gpio.f: Questo è il file di configurazione principale, dove vengono settatele costanti dei registri necessari al funzionamento dei vari GPIO e vi sono definite alcune WORDS necessarie a modificare e testare questi dati.

I2c.f: Questo è il file che definisce la comunicazione tra il PI e il modulo i2c collegato all’LCD 1602.

lcd.f: In questo file sono definite le WORDS che, tramite successione di esadecimali corrispondenti a caratteri ASCII, costruiscono le stringhe di testo che verranno visualizzate a display.

led.f: In questo file sono assegnati i GPIO ai LED, e definite le WORDS per l’attivazione e la disattivazione degli attuatori.

pad.f: In questo file sono descritte ed implementate le logiche per il controllo input dalla tastiera e il meccanismo per immagazzinare le variabili temporali.

main.f: Questo è il file che contiene le WORDS in linguaggio comprensivo che permettono di inizializzare il sistema **SETUP**, di avviare il ciclo principale **RUN**, oltre a quelle che descrivono i vari comportamenti.


## **Testing**
Per la programmazione una volta avviato il terminale e attivata la connessione con l’interfaccia seriale, possiamo dare alimentazione al Raspberry PI 4. Dopo pochi secondi comparirà la console a riga di comando dell’interprete.






Digitando la combinazione di tasti per inviare il file al target CTRL +a +s, basterà digitare il nome del file sorgente e premere invio.

Il codice verrà inviato al target alla velocità stabilita nei parametri di connessione. 





A questo punto digitando la WORD “SETUP” il sistema si configura attivando tutto l’hardware e presentando il messaggio di benvenuto.


All’inizio il sistema sarà in fase di SYSTEM STOP e quindi sarà acceso il led rosso e tutti gli attuatori saranno disattivati.

A questo punto si potrà digitare dalla tastiera il valore di temporizzazione espresso in secondi da 0 a 99, con due cifre decimali per il tempo di illuminazione e altre due per quello di ventilazione.





D’ora in avanti il sistema entra in un ciclo perpetuo di alternanza tra le funzioni.

Quando sarà in fase di SYSTEM LIGHT sarà acceso il led giallo e il sistema di illuminazione sarà in funzione.

Quando sarà in fase di SYSTEM WIND sarà acceso il led verde e il sistema di ventilazione sarà in funzione.

In caso di anomalia o manutenzione può essere premuto il tasto ESC per interrompere il programma.




##

**
##
## **Conclusioni**
Nella realizzazione di questo progetto le difficoltà iniziali sono state legate al fatto di avere a che fare con componenti che solitamente siamo già messi in condizione di utilizzarli senza troppi fronzoli. In realtà quando si crea un software che deve descrivere i comportamenti di un hardware così a basso livello si comincia ad apprezzare in maniera concreta la validità dello stesso.

Questo progetto potrebbe evolversi: ad esempio si potrebbero applicare numerosi sensori ed attuatori per rendere veramente autonomo lo stesso sistema; come dei meccanismi di irrigazione controllati, piuttosto che dei sensori crepuscolari o altro.

Potrebbe benissimo trovare applicazione in altri ambiti semplicemente modificando gli attuatori e le WORDS di controllo degli stessi.

Inoltre la programmazione così gestita “*a blocchi*” rende riutilizzabile il codice anche su altri target con le dovute pre-configurazioni.

*Non è possibile non sottolineare quanto, alla fine della realizzazione e della stesura di questo progetto, sono rimasto affascinato da questo ambito dell’ingegneria informatica.* 



*Davide Proietto*
