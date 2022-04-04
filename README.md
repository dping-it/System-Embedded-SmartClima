**Corso di Laurea Magistrale in Ingegneria Informatica – progetto EmbeddedSystem**

# 
# **Embedded System**

![Shape2](RackMultipart20220404-4-jl89na_html_d389ac9649619294.gif)

# **: SmartClima-2.0 ;**

![](RackMultipart20220404-4-jl89na_html_3693a0d02377592b.jpg)

**Project Work :**  **Soluzione Bare Metal**

![Shape4](RackMultipart20220404-4-jl89na_html_bb5483ab5e17d254.gif) ![Shape5](RackMultipart20220404-4-jl89na_html_3b78c19cdc634318.gif) ![Shape3](RackMultipart20220404-4-jl89na_html_2ad58fbc6dca623.gif)

## **Davide Proietto**

## **- matr. 0739290**

## **Embedded System 2021/22 – prof. D. Peri**

# **d**

**per la gestione del clima ideale in un sistema &quot;serra&quot;.**

#

# Sommario

[1](#_Toc99813059)

[**Descrizione del progetto** 4](#_Toc99813060)

[**Prerequisiti concettuali** 4](#_Toc99813061)

[**Componenti Hardware** 4](#_Toc99813062)

[**Schema del sistema** 5](#_Toc99813063)

[**Schema di collegamento Header** 5](#_Toc99813064)

[**Il targhet: RaspBerry PI 4 B** 6](#_Toc99813065)

[**Componenti Software** 6](#_Toc99813066)

[**Preparazione dell&#39;ambiente di sviluppo** 6](#_Toc99813067)

[_ **Procedura con Windows 10 e Zoc8 Terminal** _ 7](#_Toc99813068)

[_ **Procedura con Linux Mint e Picocom** _ 7](#_Toc99813069)

[**Preparazione della SD e dell&#39;interprete** 8](#_Toc99813070)

[**Descrizione dei componenti** 10](#_Toc99813071)

[_ **FTDI 232-USB Interfaccia UART** _ 10](#_Toc99813072)

[_ **Modulo LCD 1602 con Drive I^2C PCF85741/3** _ 10](#_Toc99813073)

[**Tastierino KeyPad a matrice 5x4** 14](#_Toc99813074)

[**Modulo relay HL-52s** 15](#_Toc99813075)

[**Sistema LED** 16](#_Toc99813076)

[**HDMI e FrameBuffer** 17](#_Toc99813077)

[**Timer** 17](#_Toc99813078)

[**Pulsante On** 18](#_Toc99813079)

[**Flusso degli eventi** 18](#_Toc99813080)

[**Il codice** 18](#_Toc99813081)

[**Dettaglio files sorgenti** 19](#_Toc99813082)

[**Testing** 48](#_Toc99813083)

![](RackMultipart20220404-4-jl89na_html_da1d8ae1078e1288.jpg)[**Conclusioni** 58](#_Toc99813084)

## **Descrizione del progetto**

Realizzazione di una interfaccia di controllo per la gestione del clima ottimale in un sistema &quot;serra&quot;. Ovviamente il progetto è realizzato su dimensioni ridotte, ma è comunque riproducibile su larga scala con i dovuti accorgimenti. Il sistema è realizzato con il target scelto **&quot;Raspberry PI 4 B**&quot;, che consente di gestire in maniera automatizzata il controllo della ventilazione e dell&#39;irraggiamento luminoso alle colture presenti nella serra. Una volta impostati i parametri di temporizzazione da tastiera il sistema &quot;bare metal&quot; gestisce l&#39;azione degli attuatori riportando a display le relative informazioni ed a schermo lo stato del sistema, in maniera del tutto autonoma, come vedremo nel dettaglio più avanti.

## **Prerequisiti concettuali**

Per lo sviluppo di un progetto di questa tipologia si utilizza un approccio bottom up nella stesura del codice. Il target va scelto in funzione alle aspettative del sistema: scegliere una CPU General Purpose piuttosto che una CPU Embedded e viceversa è una scelta che deve tenere conto di tanti aspetti: la possibilità di interazione con i sensori del sistema, l&#39;utilizzo di hardware specializzato, le caratteristiche relative al tempo medio nei confronti delle istruzioni necessarie al funzionamento, il fattore economico &quot;costo _componenti – effetto ottenuto&quot;_, e non da poco, l&#39;aspetto del consumo energetico che oggi giorno è preponderante.

Per la realizzazione di un Software embedded possiamo scegliere tra tre tipologie di programmazione:

- Compilazione su una macchina target che richiede il supporto di un OS per l&#39;utilizzo dei toolchain.
- La compilazione incrociata &quot;Cross-compilation&quot; che prevede l&#39;uso di una macchina di sviluppo collegata al target o ad un emulatore con l&#39;ausilio di software di supporto.
- Programmazione interattiva sul target: il codice sorgente viene inviato direttamente all&#39;interprete (_PIJForthOS_ nel nostro caso) che lo compila nello stesso target.

Inoltre risulta essere molto utile testare i meccanismi e le connessioni dei i sensori con un linguaggio ad alto livello, se disponibile, prima di cimentarsi allo sviluppo di codice specializzato a basso livello.

## **Componenti Hardware**

Per la realizzazione del progetto è necessario il seguente materiale:

- Raspberry Pi 4B 2 GB con alimentatore;
- MicroSD 16 GB;
- FT232RL USB Interfaccia Seriale UART;
- Sharp TC1602B-01 VER:00 16x2 LCD BLU;
- Philips PCF8574AT Remote 8-bit I/O espansione per I2C-bus;
- Relay Module HL-52s;
- Lampada piatta Led 1 W 5v con interruttore;
- Ventola 12V 8\*8 cm;
- 5x4 Keypad Matrix;
- BreadBoard e Cavi connessione M/F e M/M;
- 3 Led vari colori;
- 3 Resistori ceramidi da 200 ohm;
- Personal Computer;
- Monitor/Tv con ingresso HDMI e adattatore;
- Cavo USB – miniUSB M/M;
- Cavo HDMI
- Vaso, terra, piante e supporto attuatori.

## ![](RackMultipart20220404-4-jl89na_html_2b38572c32ac740b.png) **Schema del sistema**


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
||POWER ON BUTTON|GPIO 26|**37**|**38**||||
||||**39**|**40**||||
## **Il targhet: RaspBerry PI 4 B**

![](RackMultipart20220404-4-jl89na_html_527249630ca019f9.jpg)Il Raspberry Pi 4 Model B monta un microcontrollore ARM Broadcom BCM2711 quad-core Cortex-A72 a 1.5 Ghz.

Questo target è molto potente poiché può essere programmato dalle applicazioni embedded più semplici come il &quot;blinking led&quot; ad ospitare a bordo interi sistemi operativi Linux e Windows con interfacce grafiche.

![](RackMultipart20220404-4-jl89na_html_8d97430c5ee2f909.png)

Specifiche:

Broadcom **BCM2711** , Quad core Cortex-A72

![](RackMultipart20220404-4-jl89na_html_27f84933520c4fd0.png)(ARM v8) 64-bit SoC @ 1.5GHz

2GB, 4GB or 8GB LPDDR4-3200 SDRAM

2.4 GHz and 5.0 GHz IEEE 802.11ac wireless, Bluetooth 5.0, BLE

Gigabit Ethernet

2 USB 3.0 ports; 2 USB 2.0 ports.

**Raspberry Pi standard 40 pin GPIO header** (fully backwards compatible with previous boards)

2 × micro-HDMI ports (up to 4kp60 supported)

2-lane MIPI DSI display port

2-lane MIPI CSI camera port

4-pole stereo audio and composite video port

H.265 (4kp60 decode), H264 (1080p60 decode, 1080p30 encode)

OpenGL ES 3.1, Vulkan 1.0

Micro-SD card slot for loading operating system and data storage

5V DC via USB-C connector (minimum 3A\*)

5V DC via GPIO header (minimum 3A\*)

Power over Ethernet (PoE) enabled

Operating temperature: 0 – 50 degrees C

## **Componenti Software**

- Pc Windows 10 con installato G-Forth, e ZOC8 Terminal;

- (In Alternativa) Distro linux ( Mint 20.3 LTS ) con installato G-Forth, Minicom e Picocom;

- PijFORTHOS 1. 8 ( gentile concessione Prof D. Peri ) un interprete Forth per soluzioni Bare Metal;

## **Preparazione dell&#39;ambiente di sviluppo**

L&#39;invio del codice sorgente avviene tramite terminale con protocollo FTDI RS-232.

### _ **Procedura con Windows 10 e Zoc8 Terminal** _

ZOC è un software di emulazione terminale professionale per Windows e macOS.

Queta procedura verrà utilizzata durante l&#39;esposizione del progetto ed è riportata a pagina 49.

### _ **Procedura con Linux Mint e Picocom** _

Installare dei tool per la comunicazione e l&#39;interprete Forth per comodità. Da terminale:

- sudo apt-get install -y gcc-arm-none-eabi
- sudo apt-get install -y picocom
- sudo apt-get install -y minicom

Al fine di stabilire la connessione con il target useremo picocom digitando la stringa che ci permette di avviare la comunicazione, permettere l&#39;invio di file con il supporto ASCII e formattare il terminale in maniera corretta:

sudo picocom --b 115200 /dev/ **ttyUSB0** --send &quot;ascii-xfr -sv -l100 -c10&quot; --imap delbs

Minicom è un software di emulazione di terminale per sistemi operativi simili a Unix. Viene comunemente utilizzato durante la configurazione di una console seriale remota.

Picocom è, in linea di principio, molto simile a minicom. È stato progettato come un semplice strumento manuale di configurazione, test e debug del modem.

In effetti, picocom non è un &quot;emulatore&quot; di per sé. È un semplice programma che apre, configura, gestisce una porta seriale (dispositivo tty) e le sue impostazioni, e ad essa collega l&#39;emulatore di terminale già in uso.

#### Parametri PICOCOM:

ASCII-XFR[@ASCII] è stato scelto per inviare il file sorgente al Raspberry perché consente un ritardo tra ogni carattere e la riga inviata.

Questa caratteristica è vantaggiosa perché la comunicazione UART è asincrona: se, mentre il ricevente è impegnato a compilare o eseguire FORTH word, il mittente sta trasmettendo dati, c&#39;è il pericolo di un errore e i caratteri in ingresso andranno persi, con conseguenze disastrose per la corretta esecuzione del programma.

Tramite il comando picocom --b 115200 /dev/tyyUSB0 --imap delbs -s &quot;ascii-xfr -sv -l100 -c10&quot; picocom viene lanciato sulla macchina di sviluppo con gli stessi parametri VCP del Pi UART:

--b 115200: velocità in bit 115200 bit/s.

--imap delbs: consente l&#39;uso di backspace per eliminare un carattere.

-s &quot;ascii-xfr -sv -l100 -c10&quot;: specifica ascii-xfr è un comando esterno da usare per trasmettere file.

-sv: modalità di invio dettagliata.

-l100: imposta un ritardo di 100 millisecondi dopo l&#39;invio di ogni riga, questo di solito dà abbastanza tempo per eseguire un comando ed essere pronto per la riga successiva in tempo.

-c10: attende 10 millisecondi tra ogni carattere inviato.

## **Preparazione della SD e dell&#39;interprete**

![](RackMultipart20220404-4-jl89na_html_9ff28b523e6f34d2.png)La soluzione migliore per preparare il Raspberry è quella di formattare ed installare il Sistema operativo base di Rasbian PI OS Lite con il programma Raspberry Pi Imager [https://www.raspberrypi.com/software/](https://www.raspberrypi.com/software/) . Questo ci permetterà al primo avvio, di partizionare la SD in modo corretto e nello stesso tempo verranno caricati tutti i files necessari al bootstrapping del nostro target. Scendendo nel dettaglio tra tutti i files presenti, solo alcuni sono utilizzati al nostro scopo. La prima fase di boot è svolta dal VideoCore che carica il primo strato dei file d&#39;avvio.

Per i files bootcode.bin e fixup.dat dobbiamo utilizzare quelli generati durante la preparazione della sd. È necessario eliminare tutti gli kernel_X_.img . A questo punto scarichiamo e copiamo sulla sd i file dell&#39;interprete Forth che sono

presenti nel repo [https://github.com/organix/pijFORTHos](https://github.com/organix/pijFORTHos) ( o versione modificata prof D. Peri ).

Forth ha già definiti nel proprio dizionario un potente set di comandi standard, e fornisce dei meccanismi con cui si possono definire i nuovi comandi. Questo processo strutturale di costruzione _di definizioni su definizioni precedenti_ rende Forth al pari di un linguaggio ad alto livello. Le words possono essere definite direttamente nei mnemonici assembler. Tutti i comandi sono interpretati dallo stesso interprete e compilati dallo stesso compilatore, conferendo al linguaggio estrema flessibilità. Questo interprete va caricato nel kernel.

![](RackMultipart20220404-4-jl89na_html_893dab7ffd66ad3a.png)Poiché usiamo un sistema a 32bit chiameremo il file blob kernel7.img. Per la produzione di questo file si può usare lo strumento di cross-compiling **gcc-arm-none-eabi** Toolchain [https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads) .

Per rendere possibile la comunicazione tra l&#39;interprete Forth e l&#39;interfaccia di programmazione dobbiamo abilitare la UART del PI.

Nel file config.txt inseriamo la stringa di abilitazione come in figura:

![](RackMultipart20220404-4-jl89na_html_eb6f8f4c24248760.png)_enable\_uart=1_

## **Descrizione dei componenti**

##

## _ **FTDI 232-USB Interfaccia UART** _

![](RackMultipart20220404-4-jl89na_html_7fbee28061df9662.png) La &quot;USB to Serial Adapter with FT232RL&quot; permette di collegare i PC con qualsiasi sistema a microcontrollore attraverso la porta USB. Usa l&#39;integrato FT232RL della FTDI, dotato di buffer in ricezione da 128 byte e buffer in trasmissione da 256 byte che garantiscono robustezza in trasmissioni ad alta velocità fino a 3Mbaud/s. Oltre ai segnali TX e RX, sono presenti anche le linee CTS, RTS e le altre linee di handshaking. Collegando la scheda alla porta USB, il PC la riconoscerà come una VirtualCOM Port seriale(VCP) attraverso la quale possiamo stabilire la connessione con il targhet emulando la porta seriale RS232, senza bisogno di alcuna modifica. Per il collegamento è sufficiente fornire la linea di alimentazione dalla breadboard e collegare le linee segnale **TX ed RX** alle rispettive **RX e TX** del PI come da tabella. Dato che si tratta di un collegamento SPI Asincrono doppiamo specificare i parametri di sincronizzazione, come la velocità di trasmissione che sarà 115200 e la dimensione del Frame che sarà di un byte.

## _ **Modulo LCD 1602 con Drive I^2C PCF85741/3** _

Questo progetto utilizza un LCD 16x2 (16 righe x 2 colonne) con un modulo I2C integrato. L&#39;LCD è in grado di visualizzare caratteri, lettere, numeri e simboli ASCII. Infatti, comunichiamo con il display LCD semplicemente inviando il codice ASCII del carattere che vogliamo mostrare, in HEX.

L&#39;utilizzo di un&#39;interfaccia I2C che collega l&#39;ingresso seriale e la modalità di uscita parallela all&#39;LCD consente di farlo utilizzare solo 4 linee per comunicare con il display LCD. Il chip IC utilizzato è PCF8574AT e per poter ricavare l&#39;indirizzo dello slave si può utilizzare il sistema operativo Raspbian digitando da terminale il comando _i2cdetect -y__1_ per recuperare le due cifre in esadecimale.

![](RackMultipart20220404-4-jl89na_html_318c3c45a2401da7.png) Il Bus I2C è un:

- sincrono
- multimaster
- multislave
- commutazione di pacchetto
- single-ended

| **SCHEMA PARALLELO I2C\&lt;-\&gt;LCD** |
| --- |
| **On board PC8574T** | **Attached LCD 2004A** |
| P0 | RS |
| P1 | RW |
| P2 | E |
| P3 | Backlight |
| P4 | D4 |
| P5 | D5 |
| P6 | D6 |
| P7 | D7 |


Questo tipo di bus seriale è generalmente utilizzato per collegare circuiti integrati periferici a bassa velocità a processori/microcontrollori a breve distanza.

I cavi Serial Data (SDA) e Serial Clock (SCL) trasportano i dati in un bus I2C.

Usando il meccanismo di Open-Drain per la comunicazione bidirezionale possiamo trasferire il livello logico 0 tirando giù la linea data, il livello logico 1 lasciandola &quot;fluttuante&quot;, grazie al resistore di pull-up.

Descrizione del funzionamento del bus I2C:

- Il master inizia la comunicazione inviando:

    - Start Condition
    - L&#39; indirizzo slave (7 bit)
    - 0 per la scrittura R/W (1 bit)

- Lo slave invia l&#39; ACK per confermare la ricezione
- Il master invia l&#39;indirizzo del registro in cui scrivere
- Lo slave invia l&#39; ACK per confermare la ricezione del registro
- Il master inizia a inviare i dati effettivi
- Il master invia la Stop Condition per terminare la comunicazione

In questo caso il master è il Raspberry Pi 4 e lo slave è il modulo LCD I2C.

Mentre l&#39;SCL è alto, una transizione da alto a basso sulla linea SDA con SCL alto definisce una &quot;Start Condition&quot; condizione d&#39;avvio, e alla transizione da basso ad alto sulla linea SDA con SCL alto si definisce &quot;Stop Condition&quot; condizione di arresto. Durante ogni impulso di clock del SCL, un bit di dati viene trasmesso tramite SDA. È possibile trasferire un numero qualsiasi di byte di dati tra la Condizioni di avvio e arresto. I dati vengono trasferiti inviando per primo il bit più significativo.

[![](RackMultipart20220404-4-jl89na_html_52665e2217fe0e2.png)](https://user-images.githubusercontent.com/33685811/125796047-7c024fdb-3333-44a1-b8ce-67d84374d436.png)[![](RackMultipart20220404-4-jl89na_html_a124bdd0fe23ecbd.png)](https://user-images.githubusercontent.com/33685811/125796234-cc9f899c-035d-4a70-87cd-5848cb6b4f32.png)O[![](RackMultipart20220404-4-jl89na_html_a91d14c17f8dc498.png)
](https://user-images.githubusercontent.com/33685811/125796435-ea23d4fa-6e44-44d9-b65b-2a2e8b13f876.png) gni byte di dati riceve una risposta ACK (riconoscimento) dal ricevente. Per ricevere l&#39;ACK, il mittente deve rilasciare la linea SDA, in modo che il destinatario possa tirare la linea SDA verso il basso che diventa stabilmente basso durante la fase alta del periodo di clock ACK.

Il collegamento seriale è gestito direttamente dal bus i2c.

Prima di poter visualizzare i caratteri sull&#39;LCD, dobbiamo inviare diversi comandi per la configurazione dell&#39;LCD. Questo è il passaggio in cui vogliamo inviare un comando al display LCD:

Impostare l&#39;interruttore RS su logico basso (non premuto).

Impostare il dip switch sul comando desiderato.

Premere il pulsante Abilita (che &quot;abilita&quot; il chip ad accettare il comando).

Il primo comando che invieremo è function set. Questo comando serve per impostare la modalità interfaccia, la modalità linea e il tipo di carattere.

Utilizzeremo l&#39;interfaccia a 8 bit, la modalità a 2 righe e il tipo di carattere 5 × 7 punti. Pertanto impostiamo il comando su 0b00111000 o 0x38 in esadecimale. Impostare il pin RS su basso e quindi premere il pulsante di abilitazione.

Dopo aver premuto il pulsante di abilitazione, il modello predefinito sul display LCD verrà cancellato.

Il secondo comando da inserire è display on/off e cursore. Con questo comando accendiamo il display LCD e impostiamo lo stile del cursore (sottolineatura e cursore lampeggiante on/off).

Pertanto impostiamo il comando su 0b00001111 o 0x0F per attivare il display LCD, il cursore sottolineato e il cursore lampeggiante. Impostare il pin RS su basso e quindi premere il pulsante di abilitazione. Dopo aver premuto il pulsante di abilitazione, il display LCD visualizzerà la sottolineatura e il cursore lampeggiante sulla prima riga.

Successivamente, possiamo iniziare a inserire i dati dei caratteri. Per inserire un carattere nell&#39;LCD dobbiamo usare questo passaggio:

1. Impostare l&#39;interruttore RS su logico alto (premuto).
2. Impostare il dip switch sui dati ASCII desiderati.
3. Premere il pulsante Abilita (che &quot;abilita&quot; il chip ad accettare i dati).

Ad esempio, vogliamo visualizzare il carattere &quot;A&quot; sull&#39;LCD. Innanzitutto, impostiamo i dati su 0b01000001 o 0x41 in esadecimale. Quindi imposta il pin RS su alto e infine premi il pulsante di abilitazione. Dopo aver premuto il pulsante di abilitazione, verrà visualizzato il carattere &quot;A&quot; e il cursore si sposta sulla colonna successiva.

Per cancellare il display LCD, possiamo inviare il comando 0b00000001 o 0x01 impostare il pin RS su basso (perché vogliamo inviare il comando), quindi premere il pulsante di abilitazione.

Nel nostro caso utilizziamo la modalità a 4 bit e usiamo una funzione per definire che tipo di informazione stiamo inviando all&#39;LCD.

La WORD **\&gt;I2C** del nostro codice scrive un byte relativo all&#39;indirizzo del bus I2C nel master Broadcom Serial Controller (BSC). In questo progetto utilizziamo il secondo indirizzo master, che otteniamo sommando l&#39;offset 804008 all&#39;indirizzo del dispositivo di base.

La WORD **\&gt;LCD** controlla se vogliamo inviare un comando o una parte di dati, il bus decodifica e serializza un byte di cui i bit sono posizionati in modo significativo.

Il comando ha un 1 in più nel bit più significativo rispetto ai dati. Infatti un input come 101 \&gt;LCD sarebbe considerato un COMANDO per cancellare lo schermo 0000 0001, altrimenti se 0 ( ad esempio un input come 41 \&gt;LCD ) sarebbe considerato un DATA per inviare A CHAR (41 in esadecimale) allo schermo.

Se RS è HIGH 1 inviamo un Data Signal, se LOW 0 un Istruction Signal.

Per ad esempio, il comando 2C \&gt;LCD produce (0x2C = 0010 1100) sul bus I2C:

per la comunicazione seriale all&#39;LCD avremo i 4 bit di selezione e le impostazioni

D7=0, D6=0, D5=1, D4=0, Retroilluminazione=1, Abilita=1, R/W&#39;=0, RS=0

Il comando 28 \&gt;LCD produce (0x2C = 0010 1000) sul bus I2C:

D7=0, D6=0, D5=1, D4=0, Retroilluminazione=1, Abilita=0, R/W&#39;=0, RS=0

Questa sequenza di comandi viene interpretata come il comando Function Set (0x20 = 0010 0000) con il parametro DL=0. Di conseguenza, possiamo passare il bus alla modalità a 4 bit. Utilizzando la modalità a 4 bit, per inviare 1 byte a LCD dobbiamo scrivere 4 volte sul bus I2C:

- 4 bit più significativi con Enable = 1
- 4 bit più significativi con Enable = 0
- 4 bit meno significativi con Enable = 1
- 4 bit meno significativi con Enable = 0

![](RackMultipart20220404-4-jl89na_html_214fd01e3bae2a83.png)Dopo questa configurazione si può inviare qualsiasi carattere ASCII digitando il suo codice HEX e chiamando \&gt;LCD word; ad esempio 41 \&gt;LCD (che invia A all&#39;LCD).

## **Tastierino KeyPad a matrice 5x4**

Questo Keypad è composto da una matrice di linee circuitali 5 righe x 4 colonne. Utilizzando uno dei metodi di scansione delle righe o un metodo di scansione della colonna possiamo rilevare se il tasto è stato premuto.

A tale scopo si configurano:

- ![](RackMultipart20220404-4-jl89na_html_72e22c7a56bd5d91.jpg)i pin GPIO che controllano le righe come output (pin GPIO 17, 18, 23, 24, 25)
- i pin GPIO che controllano le colonne come input (pin GPIO 16, 22, 27, 10)
- Si abilita il rilevamento del fronte di discesa per i pin che controllano le righe al fine di verificare il valore corrente del segnale rispetto al valore che aveva un passo temporale precedente ovvero il registro GPFEN0
- Il registro GPFSEL1 viene utilizzato per definire il funzionamento dei pin GPIO-10 - GPIO-19
- Il registro GPFSEL2 viene utilizzato per definire il funzionamento dei pin GPIO-20 - GPIO-29
- Ogni riga può essere cancellata utilizzando il registro GPCLR corrispondente.

Ad ogni iterazione

- Impostiamo HIGH sulla riga che vogliamo controllare utilizzando il registro GPSET corrispondente
- Premiamo un tasto qualsiasi della riga impostata su HIGH
- Il ciclo di scansione controlla il valore del pin GPIO che controlla la colonna del tasto premuto, tramite il registro GPLEV corrispondente: se il valore è HIGH l&#39;evento press è stato rilevato correttamente.

La configurazione dei pin non è vincolante, basta essere certi di controllare la resistenza Pull Up/Pull Down dei pin selezionati.

![](RackMultipart20220404-4-jl89na_html_6f514ce1ff032623.png)Per avviare queste configurazioni oltre ad aver definito i registri con costanti simboliche adatte, basta chiamare la WORD **SETUP\_KEYPAD** per abilitare la tastiera.

## **Modulo relay HL-52s**

![](RackMultipart20220404-4-jl89na_html_c161fda4849ef8ba.png)Possiamo controllare i dispositivi elettronici ad alta tensione usando i relè. Un relè è in realtà un interruttore che è azionato elettricamente da un elettromagnete. L&#39;elettromagnete viene attivato con una bassa tensione, nel nostro caso 5 volt da dal microcontrollore del PI che chiude un contatto per fare erogare o interrompere un circuito ad alta tensione.
 Il modulo relè HL-52S a 2 canali ha 2 relè con portata di 10A @ 250 e 125 V AC e 10A @ 30 e 28 V DC. Il connettore di uscita ad alta tensione ha 3 pin, quello centrale è il pin comune e come si vede dalle marcature uno degli altri due pin è per la connessione normalmente aperta e l&#39;altro per la connessione normalmente chiusa.
 Dall&#39;altro lato del modulo abbiamo 2 gruppi di pin. Il primo ha 4 pin, una massa e un pin VCC per alimentare il modulo e 2 pin di ingresso In1 e In2 ai rispettivi relè. Il secondo set di pin ha 3 pin con un ponticello tra il JDVcc e il pin Vcc.

![](RackMultipart20220404-4-jl89na_html_d73a4c4ce282643f.png) ![](RackMultipart20220404-4-jl89na_html_b8ef100e47a4fe79.jpg)

In questa configurazione l&#39;elettromagnete del relè è alimentato direttamente dal Raspberry. I carichi di alimentazione degli attuatori, **lampada e ventola** , arrivano da sorgenti esterne, che in uno scenario ecosostenibile potrebbero derivare direttamente da fonti rinnovabili.

## **Sistema LED**

Il sistema led è composto da 3 led di colore diverso e da 3 resistori ceramici da 200 ohm che servono da protezione agli stessi led.

Ogni led è collegato ad un GPIO specifico che ne abilita l&#39;emissione luminosa e lo stesso GPIO gestisce il NC dell&#39;attivazione di un relè.

I GPIO 5, 6, e il 12 sono configurati come OUT.

![](RackMultipart20220404-4-jl89na_html_6048ca63ecb40b9d.png)Quando lo stato passa ad alto, il circuito si chiude a massa, ed il led si accende. Se ciò avviene il contatto NC del relè si interrompe e l&#39;attuatore collegato viene disattivato.

Per cui abbiamo il seguente schema:

| **FUNZ** | **GPIO** | **LED** | **STATO** | **ATTUATORE** |
| --- | --- | --- | --- | --- |
| STOP SISTEMA | 6 | ROSSO | ON | STOP |
| ATTIVA LUCE | 5 | GIALLO | ON | VENTOLA |
| ATTIVA VENTO | 12 | VERDE | ON | LAMPADA LED |

Per utilizzare in maniera corretta i sensori sono state create delle WORD che rappresentano la configurazione a semaforo dei tre led:

: GO\_LIGHT

REDLED GPOFF!

STOPWIND

CLEAR

SYSTEM

LIGHT

SYSTEMLIGHT

;

: GO\_WIND

REDLED GPOFF!

STOPLIGHT

CLEAR

SYSTEM

WIND

SYSTEMWIND

;

: STOP\_DISP

ALL\_LED\_ON

CLEAR

SYSTEM

STOP

;

## **HDMI e FrameBuffer**

Il display Pi HDMI è generato dal Videocore. Un pixel (picture element) si trova attraverso le sue coordinate xy ( da (0,0) a (-1,-1) ). Il colore di un pixel è controllato da un valore codificato in bit color\_depth. Quando si utilizza 32 bit per pixel (bpp), il colore del pixel è codificato come valore ARGB : 8 bit per ciascuno dei componenti red, green, blu colors 8 bit per il canale alfa utilizzato per gli effetti di trasparenza.

I valori dei pixel sono memorizzati in un framebuffer, che è una regione di memoria condivisa dal VC e dalla CPU. Il framebuffer è organizzato come la riga principale della matrice di color\_depth.

Il nostro interprete configura il display HDMI per 1024x768x32bpp all&#39;avvio e il colore del pixel x,y è controllato dal valore ARGB nella parola all&#39;offset del byte 4\*(1024\*y+x) dall&#39;indirizzo di base del framebuffer (ad esempio per il primo pixel bianco 00FFFFFF 3E8FA000).

Il FrameBuffer è inizializzato con i parametri:

framebuffer at 0x3E8FA000 width 00000400 height 00000300 depth 00000020 pitch 00001000

- framebuffer at 0x3E8FA000 indirizzo base del framebuffer
- width 00000400 height 00000300 dimensione del&#39;immagine
- depth 00000020 pitch 00001000 profondità colore

Al fine di disegnare i simboli necessari al sistema definiamo:

1. Le costanti dei colori necessari in esadecimale.
2. Delle variabili contatori per i cicli al fine disegnare le linee orizzontali e per tenere traccia del numero di riga corrente.
3. Le words necessarie per spostarsi nelle 4 direzioni partendo da CENTER e per colorare ciascun pixel con il colore passato.

Le Words di alto livello per disegnare i simboli dei vari eventi sono:

- DRAWSTARTWIND Simbolo di avvio ciclo di Ventilazione
- DRAWSTARTLIGHT Simbolo di avvio ciclo di Illuminazione
- DRAWSTOP Simbolo di arresto del sistema
- CLEAN Cancella lo schermo
- DRAWITAFLAG Simbolo della bandiera Italiana (Benvenuto)

![](RackMultipart20220404-4-jl89na_html_f347a4da92438e4e.jpg)

## **Timer**

Il Timer di sistema fornisce quattro canali timer a 32 bit e un singolo contatore a corsa libera a 64 bit.

L&#39;indirizzo di base fisico (hardware) per i timer di sistema è 0x7e003000.

Quando i due valori corrispondono, la periferica timer di sistema genera un segnale per indicare una corrispondenza per l&#39;appropriato canale. Il segnale di corrispondenza viene quindi inviato al controller di interruzione. La routine del servizio di interruzione legge quindi l&#39;output confronta il registro e aggiunge l&#39;offset appropriato per il prossimo tick del timer.

Per la gestione del tempo nel nostro sistema useremo il registro a 32 bit CLO. In particolare, definita la costante di un secondo (F4240 in HEX) la logica è che viene registrato il valore di CLO, e a questo viene aggiungo un secondo. Quando il valore attuale di CLO sarà uguale a CLO+1 secondo (ovvero CLO + F4240), allora effettivamente sarà passato un secondo e si potrà prendere questo nuovo valore come riferimento.

## **Pulsante On**

Il sistema di accensione è gestito da un interruttore miniatura da pannello con Pulsante Rosso:

![](RackMultipart20220404-4-jl89na_html_b42bc45a872f20ea.png) Tensione Nominale: 250 VAC

Corrente Nominale: 1 Ampere

Resistenza di contatto: ≤0.02Ω

Diametro foro di montaggio: 10mm.

Alla pressione del pulsante viene rilevato il fronte di salita asincrono sul pin GPIO dove è collegato tale pulsante: ovvero al GPIO26.

## **Flusso degli eventi**

All&#39;avvio il codice sorgente lancia un ciclo con la word &quot;START&quot; e rimane in attesa dell&#39;evento asincrono di pressione del pulsante POWER ON e il sistema si inizializza visualizza il a schermo il logo Italia e sul display il messaggio di benvenuto, visualizza il nome del dispositivo e lo stato attuale.

A questo punto sarà necessario l&#39;immissione dei dati di temporizzazione espresso in secondi da 0 a 99: le prime due cifre per il SISTEMA ILLUMINAZIONE e altre due per quello di VENTILAZIONE. Si tratta di definire così i tempi relativi agli attuatori &quot;Illuminazione&quot; e &quot;Ventilazione&quot; tutto ciò sarà reso possibile attraverso il keypad.

Una volta inserito questo dato il sistema inizia un ciclo di 4 scambi, controllato da una variabile COUNTER che alterna l&#39;utilizzo del SYSTEM LIGHT al SYSTEM WIND e da una variabile FLAG che viene settata al termine degli scambi.

Il sistema alternerà l&#39;utilizzo degli attuatori in base al delay inserito. Questo processo è inserito in un ciclo infinito.

Nel caso di anomalie o manutenzione il sistema potrà essere disabilitato premendo il tasto ESC in fase di digitazione tempi.

## **Il codice**

Il codice sorgente è suddiviso e commentato in singoli file per area tematica. Ma in fase di caricamento è opportuno unificare e pulire il codice dal commento per aumentare la velocità di caricamento. Ovvero verrà caricato in un unico file con nome final.f realizzato dal comando make:

EMBEDDED: ans.f gpio.f i2c.f lcd.f led.f pad.f hdmi.f timer.f button.f main.f

    rm -f embedded.f

    rm -f final.f

    cat ans.f \&gt;\&gt; embedded.f

    cat gpio.f \&gt;\&gt; embedded.f

    cat i2c.f \&gt;\&gt; embedded.f

    cat lcd.f \&gt;\&gt; embedded.f

    cat led.f \&gt;\&gt; embedded.f

    cat pad.f \&gt;\&gt; embedded.f

    cat hdmi.f \&gt;\&gt; embedded.f

    cat timer.f \&gt;\&gt; embedded.f

    cat button.f \&gt;\&gt; embedded.f

    cat main.f \&gt;\&gt; embedded.f

    grep -v &#39;^ \*\\&#39; embedded.f \&gt; final.f

## **Dettaglio files sorgenti**

ans.f: Inserisce nel dizionario dell&#39;interprete forth alcune WORDS necessarie al funzionamento dell&#39;interprete PiJForthOs.

\ Embedded Systems - Sistemi Embedded - 17873

\ definizione di alcune word per l&#39;interprete pijFORTHos

\ modificated by Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ &#39;\n&#39;  newline character (10)

:&#39;\n&#39;10;

\ BL    blank character (32)

:BL32;

\ STANDARD CHAR

:&#39;:&#39;[CHAR :] LITERAL ;

:&#39;;&#39;[CHAR;] LITERAL ;

:&#39;(&#39;[CHAR (] LITERAL ;

:&#39;)&#39;[CHAR)] LITERAL ;

:&#39;&quot;&#39;[CHAR &quot;] LITERAL ;

:&#39;.&#39;[CHAR .] LITERAL ;

:&#39;A&#39;[CHAR A] LITERAL ;

:&#39;0&#39;[CHAR0] LITERAL ;

:&#39;-&#39;[CHAR -] LITERAL ;

\ ?IMMEDIATE    ( entry -- p )  get IMMEDIATE flag from dictionary entry

\ ( comment text )  ( -- )  comment inside definition

:( IMMEDIATE 1BEGIN KEY DUP &#39;(&#39; = IF DROP 1+ ELSE&#39;)&#39; = IF 1- THENTHEN DUP 0= UNTIL DROP ;

\ SPACES    ( n -- )    print n spaces

:SPACESBEGIN DUP 0\&gt; WHILE SPACE 1- REPEAT DROP ;

\ WITHIN    ( a b c -- p )  where p = ((a \&gt;= b) &amp;&amp; (a \&lt; c))

:WITHIN -ROT OVER \&lt;= IF \&gt; IFTRUEELSEFALSETHENELSE 2DROP FALSETHEN;

\ ALIGNED   ( addr -- addr&#39; )   round addr up to next 4-byte boundary

:ALIGNED3 + 3 INVERT AND ;

\ ALIGN ( -- )  align the HERE pointer

:ALIGN HERE @ ALIGNED HERE ! ;

\ C,    ( c -- )    write a byte from the stack at HERE

:C, HERE @ C! 1 HERE +! ;

\ S&quot; string&quot;    ( -- addr len ) create a string value

:S&quot; IMMEDIATE ( -- addr len )

    STATE @ IF

        &#39; LITS , HERE @ 0 ,

        BEGIN KEY DUP &#39;&quot;&#39;

                \&lt;\&gt; WHILE C, REPEAT

        DROP DUP HERE @ SWAP - 4- SWAP ! ALIGN

    ELSE

        HERE @

        BEGIN KEY DUP &#39;&quot;&#39;

                \&lt;\&gt; WHILE OVER C! 1+ REPEAT

        DROP HERE @ - HERE @ SWAP

    THEN

;

\ .&quot; STRING&quot;    ( -- )  print string

:.&quot; IMMEDIATE ( -- )

    STATE @ IF

        [COMPILE] S&quot; &#39; TELL ,

    ELSE

        BEGIN KEY DUP &#39;&quot;&#39; = IF DROP EXIT THEN EMIT AGAIN

    THEN

;

:DICT WORD FIND ;

:VALUE( n -- ) WORD CREATE DOCOL , &#39; LIT , , &#39; EXIT , ;

:TO IMMEDIATE ( n -- )

        DICT \&gt;DFA 4+

    STATE @ IF&#39; LIT , , &#39; ! , ELSE ! THEN

;

:+TO IMMEDIATE

        DICT \&gt;DFA 4+

    STATE @ IF&#39; LIT , , &#39; +! , ELSE +! THEN

;

:ID. 4+ COUNT F\_LENMASK AND BEGIN DUP 0\&gt; WHILE SWAP COUNT EMIT SWAP 1- REPEAT 2DROP ;

:?HIDDEN 4+ C@ F\_HIDDEN AND ;

:?IMMEDIATE 4+ C@ F\_IMMED AND ;

:WORDS LATEST @ BEGIN ?DUP WHILE DUP ?HIDDEN NOT IF DUP ID. SPACE THEN @ REPEAT CR ;

:FORGET DICT DUP @ LATEST ! HERE ! ;

:CFA\&gt; LATEST @ BEGIN ?DUP WHILE 2DUP SWAP \&lt; IF NIP EXIT THEN @ REPEAT DROP 0;

:SEE

    DICT HERE @ LATEST @

    BEGIN2 PICK OVER \&lt;\&gt; WHILE NIP DUP @ REPEAT

    DROP SWAP &#39;:&#39; EMIT SPACE DUP ID. SPACE

    DUP ?IMMEDIATE IF .&quot; IMMEDIATE &quot;THEN

    \&gt;DFA BEGIN 2DUP

        \&gt; WHILE DUP @ CASE

        &#39; LIT OF4 + DUP @ . ENDOF

        &#39; LITS OF[CHAR S] LITERAL EMIT &#39;&quot;&#39; EMIT SPACE

            4 + DUP @ SWAP 4 + SWAP 2DUP TELL &#39;&quot;&#39; EMIT SPACE + ALIGNED 4 -

        ENDOF

        &#39; 0BRANCH OF .&quot; 0BRANCH ( &quot;4 + DUP @ . .&quot; ) &quot;ENDOF

        &#39; BRANCH OF .&quot; BRANCH ( &quot;4 + DUP @ . .&quot; ) &quot;ENDOF

        &#39;&#39;OF[CHAR&#39;] LITERAL EMIT SPACE 4 + DUP @ CFA\&gt; ID. SPACE ENDOF

        &#39; EXIT OF 2DUP 4 + \&lt;\&gt; IF .&quot; EXIT &quot;THENENDOF

        DUP CFA\&gt; ID. SPACE

    ENDCASE4 + REPEAT

    &#39;;&#39; EMIT CR 2DROP

;

::NONAME00CREATE HERE @ DOCOL , ] ;

:[&#39;] IMMEDIATE &#39; LIT , ;

:EXCEPTION-MARKER RDROP 0;

:CATCH( xt -- exn? ) DSP@ 4+ \&gt;R &#39; EXCEPTION-MARKER 4+ \&gt;R EXECUTE ;

:THROW( n -- ) ?DUP IF

    RSP@ BEGIN DUP R0 4-

        \&lt; WHILE DUP @ &#39; EXCEPTION-MARKER 4+

        = IF 4+ RSP! DUP DUP DUP R\&gt; 4- SWAP OVER ! DSP! EXIT THEN

    4+ REPEAT DROP

    CASE

        0 1- OF .&quot; ABORTED&quot; CR ENDOF

        .&quot; UNCAUGHT THROW &quot; DUP . CR

    ENDCASE QUIT THEN

;

:ABORT( -- )0 1- THROW ;

:JF-HERE   HERE ;

:JF-CREATE   CREATE;

:JF-FIND   FIND ;

\ JF-WORDS  ( -- )  print all the words defined in the dictionary

:JF-WORD   WORD ;

:HERE   JF-HERE @ ;

:ALLOT   HERE + JF-HERE ! ;

\ [&#39;] name  ( -- xt )   compile LIT

:[&#39;]   &#39; LIT , ; IMMEDIATE

:&#39;   JF-WORD JF-FIND \&gt;CFA ;

:CELL+  4 + ;

:ALIGN JF-HERE @ ALIGNED JF-HERE ! ;

:DOES\&gt;CUT   LATEST @ \&gt;CFA @ DUP JF-HERE @ \&gt; IF JF-HERE ! ;

:CREATE   JF-WORD JF-CREATE DOCREATE , ;

:(DODOES-INT)  ALIGN JF-HERE @ LATEST @ \&gt;CFA ! DODOES\&gt; [&#39;] LIT ,  LATEST @ \&gt;DFA , ;

:(DODOES-COMP)  (DODOES-INT) [&#39;] LIT , , [&#39;] FIP! , ;

:DOES\&gt;COMP   [&#39;] LIT , HERE 3 CELLS + , [&#39;] (DODOES-COMP) , [&#39;] EXIT , ;

:DOES\&gt;INT   (DODOES-INT) LATEST @ HIDDEN ] ;

:DOES\&gt;   STATE @ 0= IF DOES\&gt;INT ELSE DOES\&gt;COMP THEN; IMMEDIATE

:PRINT-STACK-TRACE

    RSP@ BEGIN DUP R0 4-

        \&lt; WHILE DUP @ CASE

        &#39; EXCEPTION-MARKER 4+ OF .&quot; CATCH ( DSP=&quot; 4+ DUP @ U. .&quot; ) &quot;ENDOF

        DUP CFA\&gt; ?DUP IF 2DUP ID. [CHAR +] LITERAL EMIT SWAP \&gt;DFA 4+ - . THEN

    ENDCASE 4+ REPEAT DROP CR

;

:UNUSED( -- n ) PAD HERE @ - 4/ ;

\ Control Structures

\ Word  Stack   Description

\ EXIT  ( -- )  restore FIP and return to caller

\ BRANCH offset ( -- )  change FIP by following offset

\ 0BRANCH offset    ( p -- )    branch if the top of the stack is zero

\ IF true-part THEN ( p -- )    conditional execution

\ IF true-part ELSE false-part THEN ( p -- )    conditional execution

\ UNLESS false-part ... ( p -- )    same as NOT IF

\ BEGIN loop-part p UNTIL   ( -- )  post-test loop

\ BEGIN loop-part AGAIN ( -- )  infinite loop (until EXIT)

\ BEGIN p WHILE loop-part REPEAT    ( -- )  pre-test loop

\ CASE cases... default ENDCASE ( selector -- ) select case based on selector value

\ value OF case-body ENDOF  ( -- )  execute case-body if (selector == value)

\ Ritorna informazioni sull&#39;autore delle modifiche

:AUTHOR

    S&quot; TEST-MODE&quot; FIND NOT IF

        .&quot; AUTHOR DAVIDE PROIETTO &quot; VERSION . CR

        UNUSED . .&quot; CELLS REMAINING&quot; CR

        .&quot; OK &quot;

    THEN

;

gpio.f: Questo è il file di configurazione principale, dove vengono settatele costanti dei registri necessari al funzionamento dei vari GPIO e vi sono definite alcune WORDS necessarie a modificare e testare questi dati.

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

\ Tuttavia, se il pin viene successivamente definito come uscita, il bit verrà impostato in base all&#39;ultimo operazione di set/cancellazione.

BASE 20001C + CONSTANT GPSET0

\ Registro di cancellazione dell&#39;uscita viene utilizzati per cancellare un pin GPIO. Ogni bit corrisponde ad un pin GPIO da cancellare ( bit 1 = GPIO0 )

\ Se il pin GPIO viene utilizzato come input (per impostazione predefinita), il valore nel campo CLRN è ignorato.

\ Tuttavia, se il pin viene successivamente definito come uscita, il bit verrà impostato in base all&#39;ultimo operazione di set/cancellazione.

BASE 200028 + CONSTANT GPCLR0

\ Registro del livello del pin:  restituisce il valore effettivo del pin. Il campo LEVn fornisce il valore del rispettivo pin GPIO.

BASE 200034 + CONSTANT GPLEV0

\ Registro di abilitazione del rilevamento del fronte di discesa definisce i pin per i quali una transizione del fronte di discesa imposta

\ un bit nell&#39;evento di rilevamento registri di stato (GPEDSn). Il registro GPFENn utilizza il rilevamento del fronte sincrono. Questo

\ significa che il segnale di ingresso viene campionato utilizzando il clock di sistema e quindi cerca un pattern &quot;100&quot; sul segnale.

BASE 200058 + CONSTANT GPFEN0

\ Registro di abilitazione del rilevamento del fronte di salita asincrono sui pin GPIO dove è abilitato

\ il controllo di stato di rilevamento eventi.

BASE 20007C + CONSTANT GPAREN0

\ Applica lo spostamento logico sinistro di 1 bit sul valore dato

\ e restituisce il valore spostato

\ Utilizzo: 2 MASK

   \ 2( BIN 0010 ) -\&gt; 4( BIN 0100 )

:MASK1 SWAP LSHIFT ;

\ Imposta il pin GPIO specificato su HIGH se configurato come output

\ Utilizzo: 12 ( pin fisico ) HIGH -\&gt; Imposta il GPIO-18 su HIGH

:HIGH

  MASK GPSET0 ! ;

\ Resetta il pin GPIO specificato se configurato come output

\ Utilizzo: 12 ( pin fisico ) LOW -\&gt; Resetta il GPIO-18

:LOW

  MASK GPCLR0 ! ;

\ Verifica il valore effettivo dei pin GPIO 0..31

\ 0 -\&gt; Il pin GPIO n è LOW

\ 1 -\&gt; Il pin GPIO n è HIGH

\ Utilizzo: 12 TPIN (Test GPIO-18)

:TPIN GPLEV0 @ SWAP RSHIFT 1 AND ;

\ Crea un tempo di attesa in millisecondi

\ Utilizzo: 1000 DELAY

:DELAY

  BEGIN1 - DUP 0 = UNTIL DROP ;

DECIMAL

\ GPIO ( n -- n ) prende il numero pin GPIO e verifica se è inferiore a 27, altrimenti interrompe

:GPIO DUP 30 \&gt; IF ABORT THEN;

\ MODE ( n -- a b c) prende il numero del pin GPIO e lascia nello stack il numero del bit di spostamento a sinistra (a) richiesto per impostare i corrispondenti bit di controllo GPIO di GPFSELN,

\ dove N è il numero del registro, insieme all&#39;indirizzo del registro GPFSELN (b) e al valore corrente memorizzato in (c) cancellato da una MASCHERA;

\ N ad (a) sono calcolati dividendo il numero GPIO per 10; N è il quoziente moltiplicato per 4 mentre a è il promemoria. Quindi GPFSELN viene calcolato da GPFSEL0 + N

\ (es. GPIO 21 è controllato da GPFSEL2 quindi 21 / 10 --\&gt; N = 2 \* 4, a = 1 --\&gt; GPFSEL0 + 8 = GPFSEL2 )

\ MASK viene utilizzato per cancellare i 3 bit del registro GPFSEL che controlla gli stati GPIO utilizzando INVERT AND e il valore (a)

\ La maschera si ottiene spostando a sinistra 7 (111 binary ) di 3 \* (resto di 10 divisioni), ad esempio 21 / 10 -\&gt; 3 \* 1 -\&gt; 7 spostato a sinistra di 3 ).

:MODE10 /MOD 4 \* GPFSEL0 + SWAP 3 \* DUP 7 SWAP LSHIFT ROT DUP @ ROT INVERT AND ROT ;

\ OUTPUT (a b c -- ) attiva l&#39;uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come uscita.

\ Il bit GPFSELN che controlla l&#39;uscita GPIO è impostato dall&#39;operazione OR tra il valore corrente di GPFSELN, cancellato dalla maschera, e un 1 spostato a sinistra dal promemoria di 10

\ divisione moltiplicata per 3. (il valore 001 nella posizione del bit corrispondente di GPFSELN imposta GPIO come OUTPUT)

\ es. con GPIO 21 AND @GPFSEL2: 011010--\&gt; 111000 011010 INVERT AND --\&gt; 000010 001000 OR --\&gt; 001010

:OUTPUT1 SWAP LSHIFT OR SWAP ! ;

\ INPUT (a b c -- ) attiva l&#39;uscita di MODE e quindi imposta il registro GPFSELN del GPIO corrispondente come input.

\ Uguale a OUTPUT ma elimina il valore di spostamento non necessario e il bit GPFSELN che controlla l&#39;ingresso GPIO è impostato dal

\ INVERTE AND operazione tra il valore corrente di GPFSELN, azzerato dalla maschera,

:INPUT1 SWAP LSHIFT INVERT AND SWAP ! ;

\ GPIO On e Off

\ : ON ( pin -- ) 1 SWAP LSHIFT GPSET0 ! ;

\ : OFF ( pin -- ) 1 SWAP LSHIFT GPCLR0 ! ;

\ ON ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPCLR0

:ON1 SWAP LSHIFT GPSET0 ! ;

\ OFF ( n -- ) prende il numero pin GPIO, sposta a sinistra 1 per questo numero e imposta il bit corrispondente del registro GPSET0

:OFF1 SWAP LSHIFT GPCLR0 ! ;

\ LEVEL ( n -- b ) prende il numero pin GPIO, sposta a sinistra 1 di questo numero, ottiene il valore corrente del registro GPLEV0 e lascia nello stack il valore del corrispondente

\ Bit numero pin GPIO

:LEVEL1 SWAP LSHIFT GPLEV0 @ SWAP AND ;

\ GPFSELOUT! scorciatoia per impostare gpio come output

:GPFSELOUT! GPIO MODE OUTPUT ;

\ GPFSELIN! scorciatoia per impostare gpio come input

:GPFSELIN! GPIO MODE INPUT ;

\ GPFSELOUT! scorciatoia per impostare gpio HIGH

:GPON! GPIO ON ;

\ GPFSELOUT! scorciatoia per impostare gpio low

:GPOFF! GPIO OFF ;

\ GPFSELOUT! scorciatoia per ottenere il livello gpio

:GPLEV@ GPIO LEVEL ;

\ GPAFEN ( n -- ) imposta il registro GPAFEN0 per il pin gpio n per l&#39;evento di caduta asincrono

:GPAFEN! GPIO 1 SWAP LSHIFT GPFEN0 ! ;

HEX

I2c.f: Questo è il file che definisce la comunicazione seriale tra il Rasberry PI 4 e il modulo i2c collegato all&#39;LCD 1602.

\ Embedded Systems - Sistemi Embedded - 17873

\ I2C Driver

\ Università degli Studi di Palermo

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo gpio.f

\ Ci sono otto master Broadcom Serial Controller (BSC) all&#39;interno di BCM2711,

\ BSC2 e BSC7 sono dedicati all&#39;uso da parte delle interfacce HDMI, qui utilizziamo BSC1 all&#39;indirizzo: 0xFE804000

\ Per utilizzare l&#39;interfaccia I2C, basta aggiungere i seguenti offset all&#39;indirizzo del registro BCS1.

\ Ogni registro è lungo 32 bit

\ 0x0 -\&gt; Control Register ( usato per abilitare gli interrupt, cancellare il FIFO, definire un&#39;operazione di lettura o scrittura e avviare un trasferimento )

\ 0x4 -\&gt; Status Register ( usato per registrare lo stato delle attività, gli errori e le richieste di interruzione )

\ 0x8 -\&gt; Data Length Register ( definisce il numero di byte di dati da trasmettere o ricevere nel trasferimento I2C )

\ 0xc -\&gt; Slave Address Register ( specifica l&#39;indirizzo slave e il tipo di ciclo )

\ 0x10 -\&gt; Data FIFO Register ( utilizzato per accedere al FIFO )

\ 0x14 -\&gt; Clock Divider Register ( usato per definire la velocità di clock della periferica BSC )

\ 0x18 -\&gt; Data Delay Register ( fornisce un controllo accurato sul punto di campionamento/lancio dei dati )

\ 0x1c -\&gt; Clock Stretch Timeout Register ( fornisce un timeout su quanto tempo il master può attende lo slave, così da allungare il timeout, prima di decretarne la caduta )

\ I2C REGISTER ADDRESSES

\ BASE 804000 + -\&gt; I2C\_CONTROL\_REGISTER\_ADDRESS

\ BASE 804004 + -\&gt; I2C\_STATUS\_REGISTER\_ADDRESS

\ BASE 804008 + -\&gt; I2C\_DATA\_LENGTH\_REGISTER\_ADDRESS

\ BASE 80400C + -\&gt; I2C\_SLAVE\_ADDRESS\_REGISTER\_ADDRESS

\ BASE 804010 + -\&gt; I2C\_DATA\_FIFO\_REGISTER\_ADDRESS

\ BASE 804014 + -\&gt; I2C\_CLOCK\_DIVIDER\_REGISTER\_ADDRESS

\ BASE 804018 + -\&gt; I2C\_DATA\_DELAY\_REGISTER\_ADDRESS

\ BASE 80401C + -\&gt; I2C\_CLOCK\_STRETCH\_TIMEOUT\_REGISTER\_ADDRESS

\ I pin GPIO-2 (SDA) e GPIO-3 (SCL) devono prendere la ALTERNATIVE FUNCTION 0

\ quindi dobbiamo configurare il GPFSEL0 che viene utilizzato per definire il funzionamento dei primi 10 pin GPIO.

\ ogni 3-bit del gpfsel rappresentano un pin GPIO, così per indirizzare GPIO-2 e GPIO-3

\ nel campo GPFSEL0 (32-bits), dobbiamo operare sui bit in posizione 8-7-6 (GPIO-2) e 11-10-9 (GPIO-3)

\ di conseguenza dobbiamo scrivere (0000 0000 0000 0000 0000 1001 0000 0000) ovvero in HEX (0x00000900)

\ su GPFSEL0 per settare la ALTERNATIVE FUNCTION 0

:SETUP\_I2C

  900 GPFSEL0 @ OR GPFSEL0 ! ;

\ Ripristina lo Status Register utilizzando I2C\_STATUS\_REGISTER (BASE 804004 +)

\ HEX (0x00000302) è (0000 0000 0000 0000 0000 0011 0000 0010) in BIN

\ Il bit 1 è 1 -\&gt; Cancella campo DONE

\ Il bit 8 è 1 -\&gt; Cancella campo ERR

\ Il bit 9 è 1 -\&gt; Cancella campo CLKT

:RESET\_S

  302 BASE 804004 + ! ;

\ Ripristina FIFO utilizzando I2C\_CONTROL\_REGISTER (BASE 804000 +)

\ HEX (0x00000010) è (0000 0000 0000 0000 0000 0000 0001 0000) in BIN

\ Il bit 4 è 1 -\&gt; Cancella FIFO

:RESET\_FIFO

  10 BASE 804000 + ! ;

\ Imposta l&#39;indirizzo SLAVE 0x00000027 ( perché il nostro modello DRIVE è PCF8574T )

\ in I2C\_SLAVE\_ADDRESS\_REGISTER (BASE 80400C +)

:SET\_SLAVE

  27 BASE 80400C + ! ;

\ Memorizza i dati in I2C\_DATA\_FIFO\_REGISTER\_ADDRESS (BASE 804010 +)

:STORE\_DATA

  BASE 804010 + ! ;

\ Avvia un nuovo trasferimento utilizzando I2C\_CONTROL\_REGISTER (BASE 804000 +)

\ (0x00008080) è (0000 0000 0000 0000 1000 0000 1000 0000) in BINARIO

\ Il bit 0 è 0 -\&gt; Scrivi trasferimento pacchetti

\ Il bit 7 è 1 -\&gt; Avvia un nuovo trasferimento

\ Il bit 15 è 1 -\&gt; Il controller BSC è abilitato

:SEND

  8080 BASE 804000 + ! ;

\ La parola principale per scrivere 1 byte alla volta

:\&gt;I2C

  RESET\_S

  RESET\_FIFO

  1 BASE 804008 + !

  SET\_SLAVE

  STORE\_DATA

  SEND ;

\ Invia i 4 bit più significativi rimasti di TOS

:4BM\&gt;LCD

  F0 AND DUP ROT

  D + OR \&gt;I2C 1000 DELAY

  8 OR \&gt;I2C 1000 DELAY ;

\ Invia 4 bit meno significativi rimasti di TOS

:4BL\&gt;LCD

  F0 AND DUP

  D + OR \&gt;I2C 1000 DELAY

  8 OR \&gt;I2C 1000 DELAY ;

:\&gt;LCDL

 DUP 4 RSHIFT 4BL\&gt;LCD

 4BL\&gt;LCD ;

:\&gt;LCDM

  OVER OVER F0 AND 4BM\&gt;LCD

  F AND 4 LSHIFT 4BM\&gt;LCD ;

\ Per verificare che si tratti di un comando controllo se il 9 bit è 1 (lo shift elimina gli otto precedenti)

:IS\_CMD

  DUP 8 RSHIFT 1 = ;

\ Controlla se stiamo inviando un comando o un dato a I2C

\ Il comando rispetto al dato ha un 1 in più nel bit più significativo rispetto ai \ dati. Un input come 101 \&gt;LCD sarebbe considerato un COMANDO per cancellare lo

\ schermo  0000 0001

\ altrimenti se 0 ( ad esempio un input come 41 \&gt;LCD ) sarebbe considerato un DATA \ per inviare A CHAR (41 in esadecimale)

\ allo schermo

:\&gt;LCD

  IS\_CMD SWAP \&gt;LCDM

;

lcd.f: In questo file sono definite le WORDS che, tramite successione di esadecimali corrispondenti a caratteri ASCII, costruiscono le stringhe di testo che verranno visualizzate a display, e quelle per intercettare i comandi all&#39;LCD.

\ Embedded Systems - Sistemi Embedded - 17873)

\ LCD Setup paraole per la compilazione di messaggi su LCD 1602 )

\ Università degli Studi di Palermo )

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo i2c.f

\ Set di words che genera le parole da visualizzare su LCD

\ I due esadecimali rappresentano gli otto bit del blocco data per visualizzare la lettera

\ così come devinira nella CGRAM

\ Stampa &quot;welcome&quot; a display

:WELCOME

    57 \&gt;LCD

    45 \&gt;LCD

    4C \&gt;LCD

    43 \&gt;LCD

    4F \&gt;LCD

    4D \&gt;LCD

    45 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;SMART&quot; a display

:SMART

    53 \&gt;LCD

    4D \&gt;LCD

    41 \&gt;LCD

    52 \&gt;LCD

    54 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;CLIMA&quot; a display

:CLIMA

    43 \&gt;LCD

    4C \&gt;LCD

    49 \&gt;LCD

    4D \&gt;LCD

    41 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;SYSTEM&quot;  a display

 :SYSTEM

    53 \&gt;LCD

    59 \&gt;LCD

    53 \&gt;LCD

    54 \&gt;LCD

    45 \&gt;LCD

    4D \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;READY&quot; a display

:READY

    52 \&gt;LCD

    45 \&gt;LCD

    41 \&gt;LCD

    44 \&gt;LCD

    59 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;BUSY&quot; a display

:BUSY

    42 \&gt;LCD

    55 \&gt;LCD

    53 \&gt;LCD

    59 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;LIGHT&quot; a display

:LIGHT

    4C \&gt;LCD

    49 \&gt;LCD

    47 \&gt;LCD

    48 \&gt;LCD

    54 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;WIND&quot; a display

:WIND

    57 \&gt;LCD

    49 \&gt;LCD

    4E \&gt;LCD

    44 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;STOP&quot; a display

:STOP

    53 \&gt;LCD

    54 \&gt;LCD

    4F \&gt;LCD

    50 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;INSERT&quot; a display

:INSERT

    49 \&gt;LCD

    4E \&gt;LCD

    53 \&gt;LCD

    45 \&gt;LCD

    52 \&gt;LCD

    54 \&gt;LCD

    20 \&gt;LCD ;

\ Stampa &quot;TIME&quot; a display

:TIME

    54 \&gt;LCD

    49 \&gt;LCD

    4D \&gt;LCD

    45 \&gt;LCD

    20 \&gt;LCD ;

\ Set di words che accede al blocco funzioni del LCD

\ Il bit più significativo impostato a 1 identifica una funzione anzicchè una dato

\ 0x80 → Indirizzo di memoria della DDRAM del display LCD per la linea 1

\ 0xC0 → Indirizzo di memoria della DDRAM del display LCD per la linea 2

\ Cancella il display

:CLEAR

  101 \&gt;LCD ;

\ Muove il cursore sulla seconda linea

:\&gt;LINE2

  1C0 \&gt;LCD ;

\ Visualizza il cursore sulla prima linea

:SETUP\_LCD

  102 \&gt;LCD ;

led.f: In questo file sono assegnati i GPIO ai LED, e definite le WORDS per l&#39;attivazione e la disattivazione degli attuatori.

\ Embedded Systems - Sistemi Embedded - 17873

\ Led Drive e Relè

\ Università degli Studi di Palermo

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo il flie gpio.f e ans.f

\ Il sistema led è composto da 3 led di colore diverso e da 3 resistori ceramici da 200 ohm che servono da protezione agli stessi led.

\ Ogni led è collegato ad un GPIO specifico che ne abilita l&#39;emissione luminosa e lo stesso GPIO gestisce il NC dell&#39;attivazione di un relè.

\ I GPIO 5, 6, e il 12 (in HEX C) sono configurati come OUT.

5CONSTANT YELLOWLED

6CONSTANT REDLED

C CONSTANT GREENLED

\ Setup Led abilita i GPIO come output

:SETUP\_LED

    REDLED GPFSELOUT!

    YELLOWLED GPFSELOUT!

    GREENLED GPFSELOUT! ;

\ Accende tutti i led disattivando tutti gli attuatori ( NC interdetto )

:ALL\_LED\_ON

  REDLED GPON!

  YELLOWLED GPON!

  GREENLED GPON!

;

\Questa WORD attiva il led giallo

:SYSTEMLIGHT YELLOWLED GPON! ;

\Questa WORD attiva il led verde

:SYSTEMWIND GREENLED GPON! ;

\Questa WORD disattiva un pin

:TURNOFF( pin -- ) GPOFF! ;

\Questa WORD disattiva il led giallo

:STOPLIGHT YELLOWLED GPOFF! ;

\Questa WORD disattiva il led verde

:STOPWIND GREENLED GPOFF! ;

\ Variabili temporali

VARIABLE LIGHTIME

VARIABLE WINDTIME

\ Le variabili temporali vengono inizializzate a 1

1 LIGHTIME !

1 WINDTIME !

pad.f: In questo file sono descritte ed implementate le logiche per il controllo input dalla tastiera e il meccanismo per memorizzare il valore delle variabili temporali.

\ Embedded Systems - Sistemi Embedded - 17873

\ Keypad

\ Università degli Studi di Palermo

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22

\ Includere dopo led.f

\ Per ogni riga inviare un output

\ Per ogni colonna controllare i valori

\ Se viene letto il bit di rilevamento dell&#39;evento, abbiamo trovato il tasto premuto

   \ nel formato RIGA-COLONNA

   \ MATRIX 5x4

\ GPIO-17 -\&gt; Riga-1 (F1-F2-#-\*)

\ GPIO-18 -\&gt; Riga-1 (1-2-3-SU)

\ GPIO-23 -\&gt; Riga-2 (4-5-6-GIU)

\ GPIO-24 -\&gt; Riga-3 (7-8-9-ESC)

\ GPIO-25 -\&gt; Riga-4 (SX-0-DX-ENT)

\ GPIO-16 -\&gt; Colonna-1 (\*-SU-GIU-ESC-ENT)

\ GPIO-22 -\&gt; Colonna-2 (#-3-6-9-DX)

\ GPIO-27 -\&gt; Colonna-3 (F2-2-5-8-0)

\ GPIO-10 -\&gt; Colonna-4 (F1-1-4-7-SX)

\ Abilita il rilevamento del fronte di discesa per i pin che controllano le RIGHE

   \ scrivendo 1 nelle posizioni dei pin corrispondenti (GPIO-18, 23, 24, 25)

\ HEX (0x03840000) che è (0000 0011 1000 0100 0000 0000 0000 0000) in BIN

:SETUP\_ROWS

  3840000 GPFEN0 ! ;

\ I pin RIGA sono impostati come output , i pin colonna sono impostati come input

\ Il campo GPFSEL1 viene utilizzato per definire il funzionamento dei pin GPIO-10 - GPIO-19

\ Il campo GPFSEL2 viene utilizzato per definire il funzionamento dei pin GPIO-20 - GPIO-29

\ Ogni 3 bit di GPFSEL rappresenta un pin GPIO

\ Per indirizzare GPIO-10, GPIO-17, GPIO-16 e GPIO-18 dovremmo operare sulla posizione dei bit

   \ 2-1-0(GPIO-10), X-Y-Z(GPIO-17), 20-19-18(GPIO-16) e 26-25-24(GPIO-18) che memorizzano il valore in GPFSEL1

\ Per indirizzare GPIO-22, GPIO-23, GPIO-24, GPIO-25 e GPIO-27 dovremmo operare sulla posizione dei bit

   \ 8-7-6(GPIO-22), 11-10-9(GPIO-23), 14-13-12(GPIO-24), 17-16-15(GPIO-25) e 23-22- 21(GPIO-27)

   \ memorizzazione del valore in GPFSEL2

\ GPIO-17 settato in output -\&gt; 001

\ GPIO-18 settato in output -\&gt; 001

\ GPIO-23 settato in output -\&gt; 001

\ GPIO-24 settato in output -\&gt; 001

\ GPIO-25 settato in output -\&gt; 001

\ GPIO-16 settato in input -\&gt; 000

\ GPIO-22 settato in input -\&gt; 000

\ GPIO-27 settato in input -\&gt; 000

\ GPIO-10 settato in input -\&gt; 000

\ Di conseguenza dovremmo scrivere

\ (0001 0000 0000 0000 0000 0000 0000) in GPFSEL1\_REGISTER\_ADDRESS che è in HEX(0x1000000)

\ (0000 1001 0010 0000 0000) in GPFSEL2\_REGISTER\_ADDRESS che è in HEX(0x9200)

:SETUP\_IO

  1000000 GPFSEL1 @ OR GPFSEL1 !

  9200 GPFSEL2 @ OR GPFSEL2 ! ;

\ Cancella GPIO-17, GPIO-18, GPIO-23, GPIO-24 e GPIO-25 utilizzando il registro GPCLR0

   \ scrivendo 1 nelle posizioni corrispondenti

\ HEX (0x3840000) che è (0011 1000 0100 0000 0000 0000 0000) in BIN

:CLEAR\_ROWS

  3840000 GPCLR0 ! ;

\ Definizione della WORD per inizializzare la tastiera

:SETUP\_KEYPAD

  SETUP\_ROWS

  SETUP\_IO

  CLEAR\_ROWS ;

\ Testa un pin, se viene premuto lascia 1 sullo stack altrimenti 0

:PRESSED

  TPIN 1 = IF1ELSE0THEN;

3CONSTANT RANGE

\ Variabile gestisce la terminazione del ciclo.

VARIABLE FLAG

\ Variabile per memorizzare il tempo decine di secondi.

VARIABLE CAS

VARIABLE COS

\ Variabile per memorizzare il tempo unità di secondi.

VARIABLE CASS

VARIABLE COSS

1 FLAG !

\ Questo flag permette di gestire l&#39;avvio del ciclo.

:FLAGOFF  0 FLAG ! ;

\ Questo flag permette di gestire l&#39;arresto del ciclo.

:FLAGON  1 FLAG ! ;

\ Variabile Contatore

CREATE COUNTER

\ Incrementa di 1 la variabile COUNTER

:COUNTER++

  COUNTER @ 1 + COUNTER ! ;

 \ Memorizza il valore in decimale di un numero nell&#39;array D\_CMDS e lo emette su LCD

\ Duplica il TOS ed emettilo

\ Lascia l&#39;indirizzo D\_CMDS su TOS

\ Lascia il valore COUNTER su TOS

\ Lasciare l&#39;indirizzo del COUNTER&#39;esimo indice dell&#39;array D\_CMDS su TOS

\ Infine memorizzare il valore DEC emesso a quell&#39;indirizzo

\ Esempio: 30 EMIT\_STORE -\&gt; Stampa 0 su LCD e lo memorizza in D\_CMDS[COUNTER\_current\_value]

:EMIT\_STORE

  COUNTER @ 0 = IF LIGHT 1000 DELAY ELSE

  COUNTER @ 2 = IF \&gt;LINE2 WIND 1000 DELAY

  THENTHEN

  DUP 500 DELAY \&gt;LCD

  DUP 30 -  \ . CONSUMA LO STACK

  DUP .

\ Termina Programma con la pressione del tasto ESC

  DUP -15 = IF CLEAR ALL\_LED\_ON SYSTEM STOP 30000 DELAY .&quot; EXIT TO END PROGRAM &quot; FLAGOFF CR AUTHOR CR CR EXIT ELSE

  DUP COUNTER @ 0 = IF DUP CAS ! DUP 4 LSHIFT LIGHTIME ! ELSE

  DUP COUNTER @ 1 = IF DUP CASS ! DUP LIGHTIME @ + LIGHTIME ! ELSE

  DUP COUNTER @ 2 = IF DUP COS ! DUP 4 LSHIFT WINDTIME !  ELSE

  DUP COUNTER @ 3 = IF DUP COSS ! DUP WINDTIME @ + WINDTIME !

  THENTHENTHENTHENTHEN

  ;

\ Stampa uno dei caratteri trovati nella Colonna 1 controllando il numero di riga specificato con un ciclo condizionale

\ Pin fisico Riga -\&gt; EMIT-Colonna

\ Esempio: 12 EMTC1 stampa A (41 in HEX) su lcd

\ 19 EMTC1 stampa D (44 in HEX) su lcd

\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO17 = 11

:EMITC1

  DUP 11 = IF2A DUP EMIT\_STORE DROP ELSE

  DUP 12 = IF5E DUP EMIT\_STORE DROP ELSE

  DUP 17 = IF5F DUP EMIT\_STORE DROP ELSE

  DUP 18 = IF1B DUP EMIT\_STORE DROP ELSE

  19 = IF D DUP EMIT\_STORE

  THENTHENTHENTHENTHEN;

\ Stampa uno dei caratteri trovati sulla Colonna 2 controllando il numero di riga specificato con un ciclo condizionale

\ Pin fisico Riga -\&gt; EMIT-Colonna

\ Esempio: 32 EMTC2 stampa # (23 in HEX) su lcd

\ 17 EMTC2 stampa 6 (36 in HEX) su lcd

\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO18 = 12

:EMITC2

  DUP 11 = IF23 DUP EMIT\_STORE DROP ELSE

  DUP 12 = IF33 DUP EMIT\_STORE DROP ELSE

  DUP 17 = IF36 DUP EMIT\_STORE DROP ELSE

  DUP 18 = IF39 DUP EMIT\_STORE DROP ELSE

  19 = IF3E DUP EMIT\_STORE

  THENTHENTHENTHENTHEN;

\ Stampa uno dei caratteri trovati sulla Colonna 3 controllando il numero di riga specificato con un ciclo condizionale

\ Pin fisico Riga -\&gt; EMIT-Colonna

\ Esempio: 18 EMTC2 stampa 8 (38 in HEX) su lcd

\ 19 EMTC2 stampa 0 (30 in HEX) su lcd

\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO17 = 11

:EMITC3

  DUP 11 = IF25 DUP EMIT\_STORE DROP ELSE

  DUP 12 = IF32 DUP EMIT\_STORE DROP ELSE

  DUP 17 = IF35 DUP EMIT\_STORE DROP ELSE

  DUP 18 = IF38 DUP EMIT\_STORE DROP ELSE

  19 = IF30 DUP EMIT\_STORE

  THENTHENTHENTHENTHEN;

\ Stampa uno dei caratteri trovati sulla Colonna 4 controllando il numero di riga specificato con un ciclo condizionale

\ Pin fisico Riga -\&gt; EMIT-Colonna

\ Esempio: 12 EMTC2 stampa 1 (31 in HEX) su lcd

\ 18 EMTC2 stampa 7 (37 in HEX) su lcd

\ IL RIFERIMENTO DEL GPIO LO ABBIAMO IN HEX ES. GPIO18 = 12

:EMITC4

  DUP 11 = IF24 DUP EMIT\_STORE DROP ELSE

  DUP 12 = IF31 DUP EMIT\_STORE DROP ELSE

  DUP 17 = IF34 DUP EMIT\_STORE DROP ELSE

  DUP 18 = IF37 DUP EMIT\_STORE DROP ELSE

  19 = IF3C DUP EMIT\_STORE

  THENTHENTHENTHENTHEN;

\ Stampa la combinazione di caratteri Riga-Colonna specificata utilizzando la corrispondente WORD EMTC1/C2/C3/C4

\ Esempio: 12 10 EMIT\_R

:EMIT\_R

  DUP 10 = IF DROP EMITC1 ELSE

  DUP 16 = IF DROP EMITC2 ELSE

  DUP 1B = IF DROP EMITC3 ELSE

  A = IF EMITC4

  THENTHENTHENTHEN;

\ Verifica se un tasto della riga data è premuto, attende il suo rilascio,

\ e stampa il valore esadecimale corrispondente sull&#39;LCD

:CHECK\_CL

  DUP DUP

    PRESSED 1 = IF1000 DELAY

    PRESSED 0 = IF1000 DELAY

      EMIT\_R

      COUNTER++

    ELSE DROP DROP

    THEN

    ELSE DROP DROP DROP

  THEN;

\ TODO

\ Controlla la riga data impostandola su HIGH, controllandone le colonne e infine impostandola su LOW

\ Esempio -\&gt; 32 CHECK\_ROW (Controlla la prima riga)

\         -\&gt; 12 CHECK\_ROW (Controlla la seconda riga)

\         -\&gt; 17 CHECK\_ROW (Controlla la terza riga)

\         -\&gt; 18 CHECK\_ROW (Controlla la quarta riga)

\         -\&gt; 19 CHECK\_ROW (Controlla la quinta riga)

:CHECK\_ROW

  DUP DUP DUP DUP DUP

  HIGH

    10 CHECK\_CL

    16 CHECK\_CL

    1B CHECK\_CL

    A CHECK\_CL

  LOW ;

:?CTR

  COUNTER @ 4 = ;

:RES\_CTR

  0 COUNTER ! ;

:?CTF

  FLAG @ 0 = ;

\ La main WORD per rilevare qualsiasi evento di PRESS/RELASE ed eventualmente stampa il

\ carattere corrispondente su LCD

\ Questa WORD deve essere chiamata all&#39;avvio del SETUP,

\ quindi, a meno che non si impostino le righe su LOW, non è necessario utilizzare questa WORD

:DETECT

  CLEAR

  0 COUNTER !

  BEGIN

    11 CHECK\_ROW

    12 CHECK\_ROW

    17 CHECK\_ROW

    18 CHECK\_ROW

    19 CHECK\_ROW

  ?CTR UNTIL

  0  CR \ LIGHTIME @ . .&quot; \&lt;- LIGHTIME &quot; CR WINDTIME @ . .&quot; \&lt;- WINDTIME &quot; CR

  .&quot; RUN SYSTEM . . . &quot; CR

  .&quot; SETTING TIME LIGHT \&gt;\&gt;\&gt;    &quot;  CAS @ . CASS @ . .&quot;    SECONDS &quot; CR

  .&quot; SETTING TIME WIND \&gt;\&gt;\&gt;    &quot;  COS @ . COSS @ . .&quot;    SECONDS &quot; CR CR ;

hdmi.f: In questo file sono descritti i parametri di funzionamento del framebuffer la definizione delle immagini da visualizzare nei vari stati del sistema.

\ Embedded Systems - Sistemi Embedded - 17873)

\ Gestione dell&#39;uscita HDMI del FrameBuffer)

\ Università degli Studi di Palermo )

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo pad.f

HEX

\ IMPOSTAZIONI  DEL FRAMEBUFFER SU INTERPRETE

\ Initializing frame buffer

\ framebuffer at 0x3E8FA000 width 00000400 height 00000300 depth 00000020 pitch 00001000

\ Svuota tutto

:4DROP DROP DROP DROP DROP ;

\ Dichiarazione dei colori in esadecimale (formato ARGB)

00FFFFFFCONSTANT WHITE

00000000CONSTANT BLACK

00FF0000CONSTANT RED

00FFFF00CONSTANT YELLOW

0000FF00CONSTANT GREEN

000000FFCONSTANT BLUE

\ Dichiarazione del base address del framebuffer ( definito nel kernel )

3E8FA000CONSTANT FRAMEBUFFER

VARIABLE DIM

\ Contatore utilizzato nei cicli per disegnare le linee orizzontali

VARIABLE COUNTERH

\ RESETCOUNTERH

:RESETCOUNTERH0 COUNTERH ! ;

\ Contatore utilizzato nei cicli per tenere traccia del numero di riga corrente

:+COUNTERH COUNTERH @ 1 + COUNTERH ! ;

\ RESETNLINE

\ Restituisce l&#39;indirizzo del punto centrale dello schermo. Coordinata ((larghezza-1)/2, (altezza-1)/2)

VARIABLE NLINE

:RESETNLINE1 NLINE ! ;

:+NLINE NLINE @ 1 + NLINE ! ;

( -- addr )

:CENTER FRAMEBUFFER 2004 \* + 1801000 \* + ;

\ Colora, con il colore presente sullo stack, il pixel corrispondente all&#39;indirizzo

\ presente sullo stack,

\ dopodichè punta al pixel a destra

( color addr -- color addr\_col+1 )

:RIGHT 2DUP ! 4 + ;

\ Colora, con il colore presente sullo stack, il pixel corrispondente all&#39;indirizzo

\ presente sullo stack,

\ dopodichè punta al pixel in basso

( color addr -- color addr\_row+1 )

:DOWN 2DUP ! 1000 + ;

\ Colora, con il colore presente sullo stack, il pixel corrispondente all&#39;indirizzo

\ presente sullo stack,

\ dopodichè punta al pixel a sinistra

( color addr -- color addr\_col-1 )

:LEFT 2DUP ! 4 - ;

\ Ripristina il valore di partenza dell&#39;indirizzo a seguito di COUNTERH \* 4 spostamenti a

\ destra

( addr\_endline\_right -- addr )

:RIGHTRESET COUNTERH @ 4 \* - ;

\ Ripristina il valore di partenza dell&#39;indirizzo a seguito di COUNTERH \* 4 spostamenti a

\ sinistra

( addr\_endline\_left -- addr )

:LEFTRESET COUNTERH @ 4 \* + ;

\ Disegna una linea verso destra di dimensione pari a 48 pixel

:RIGHTDRAW

    BEGIN COUNTERH @ DIM @ \&lt; WHILE +COUNTERH RIGHT REPEAT RIGHTRESET RESETCOUNTERH ;

\ Disegna una linea verso sinistra di dimensione pari a 48 pixel

:LEFTDRAW

    BEGIN COUNTERH @ DIM @ \&lt; WHILE +COUNTERH LEFT REPEAT LEFTRESET RESETCOUNTERH ;

\ Disegna o il simbolo di stop o pulisce la porzione di schermo su cui disegnamo.

\ Partendo da CENTER-32px-48px, quindi CENTER-80px, e poichè ogni spostamento di 1px su

\ una riga

\ vale 4, abbiamo 320 in dec e cioè 140 in hex

:DRAWSQUARE

    80 DIM !

    CENTER 140 - RIGHTDRAW

\ Ciclo che disegna un simbolo di stop di altezza 105 pixel

    BEGIN NLINE @ 70 \&lt;

        WHILE

            DOWN RIGHTDRAW

            +NLINE

        REPEAT

    2DROP RESETNLINE

;

\ Disegna il simbolo di start.

:DRAWSTARTWIND

    GREEN CENTER 80 -

    BEGIN NLINE @ 70 \&lt;=

        WHILE

\ Permette di rappresentare le linee del triangolo superiore del simbolo start

            NLINE @ 37 \&lt;= IF

            NLINE @ DIM !

\ Permette di rappresentare le linee del triangolo inferiore del simbolo start

                ELSE

                    70 NLINE @ - DIM !

            THEN

\ Disegna una linea verso destra di dimensione variabile e dipendente dal numero di riga \ memorizzato in NLINE.

            DOWN RIGHTDRAW

            +NLINE

        REPEAT

    2DROP RESETNLINE

;

\ Disegna il simbolo di start.

:DRAWSTARTLIGHT

    YELLOW CENTER 80 -

    BEGIN NLINE @ 70 \&lt;=

        WHILE

\ Permette di rappresentare le linee del triangolo superiore del simbolo start

            NLINE @ 37 \&lt;= IF

            NLINE @ DIM !

\ Permette di rappresentare le linee del triangolo inferiore del simbolo start

                ELSE

                    70 NLINE @ - DIM !

            THEN

\ Disegna una linea verso destra di dimensione variabile e dipendente dal numero di riga \ memorizzato in NLINE.

            DOWN RIGHTDRAW

            +NLINE

        REPEAT

    2DROP RESETNLINE

;

:DRAWSTOP RED DRAWSQUARE ;

:CLEAN BLACK DRAWSQUARE ;

\ Disegna la bandiera

:DRAWITAFLAG

    WHITE DRAWSQUARE

    30 DIM !

\ Disegna la prima linea della seconda pipe

    RED CENTER RIGHTDRAW

\ Disegna la prima linea della prima pipe, spostandosi di 32 pixel a sinistra

    GREEN CENTER 80 - LEFTDRAW

\ Ciclo che disegna due pipe, distanziate, di altezza 105 pixel

    BEGIN NLINE @ 70 \&lt;

        WHILE

\ Disegna l&#39;n-esima linea della prima pipe

            DOWN LEFTDRAW

            2SWAP

\ Disegna l&#39;n-esima linea della seconda pipe

            DOWN RIGHTDRAW

            2SWAP

            +NLINE

        REPEAT

    4DROP RESETNLINE

;

timer.f: Il file contiene il codice per la gestione del registro CLO che ci permette di effettuale un conteggio in secondi utilizzando un campione &quot; secondo&quot; in esadecimale.

\ Embedded Systems - Sistemi Embedded - 17873)

\ Timer di Sistema e definizione di unità temporale )

\ Università degli Studi di Palermo )

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo hdmi.f

HEX

\ Clock Register

BASE 003004 + CONSTANT CLO

\ Dichiarazione della costante che indica un secondo e che ha valore 1 000 000 usec in decimale o

\ F4240 in hex

F4240 CONSTANT SEC

\ Variabile che memorizza il valore attuale del CLO + 1 secondo

VARIABLE COMP0

VARIABLE TIME\_COUNTER

0 TIME\_COUNTER !

\ Inizializzazione delle variabili utilizzate

0 COMP0 !

\ Restituisce il valore attuale del registro CLO

( -- clo\_value )

:NOW CLO @ ;

\ Setta un ritardo corrispondente al valore presente sullo stack

( delay\_sec -- )

:DELAY\_SEC NOW + BEGIN DUP NOW - 0 \&lt;= UNTIL DROP ;

\ Converte il valore decimal in secondi a hexadecimal per darlo in pasto al tic. La word pone sullo stack il resto

\ e il quoto della divisione per 10 moltiflica il quoto per A (10 in HEX) somma il resto ed effettua successivamente uno swap.

:PARSE\_DEC\_HEX( n1 -- n3 n2 )10 /MOD A \* SWAP + DUP . .&quot; \&gt;\&gt; SECONDS &quot;;

\ Memorizza il valore attuale del CLO + 1 secondo in COMP0

:INC NOW SEC + COMP0 ! ;

\ Segnala ogni qual volta e passato un secondo confrontando CLO con COMP0

:SLEEPS DECIMAL INC BEGIN NOW COMP0 @ \&lt; WHILEREPEAT DUP U. .&quot; | &quot; DROP DECIMAL ;

\ Words di incremento e decremento contatore

:DECCOUNT TIME\_COUNTER @ 1 - TIME\_COUNTER ! ;

:INCCOUNT TIME\_COUNTER @ 1 + TIME\_COUNTER ! ;

\ Word che imposta un conto alla rovescia in secondi a partire dal n passato fino a zero.

DECIMAL :TIMER PARSE\_DEC\_HEX TIME\_COUNTER ! CR begin TIME\_COUNTER @ SLEEPS DECCOUNT TIME\_COUNTER @ 0 = until CR

 .&quot; END EROGATION &quot; CR CR DROP ;

HEX

button.f: Questo sorgente contiene le word per implementare il comportamento del pulsante di accensione asincrono.

\ Embedded Systems - Sistemi Embedded - 17873)

\ Bottone POWER ON )

\ Università degli Studi di Palermo )

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo timer.f

\ Word per il controllo del bottone d&#39;avvio

HEX

\ Impostiamo il GPIO26 come output ( 001 ) sul bit 20:18 con 40000 in HEX a cui è associati il pulsante di accenzione.

:SETUP\_BUTTON

  40000 GPFSEL2 @ OR GPFSEL2 !

;

\ I registri di abilitazione del rilevamento del fronte di salita asincrono definiscono i pin per i quali è verificata la presenza di

\ un fronte di salita asincrono: la transizione imposta un bit nei registri di stato di rilevamento eventi (GPEDSn).

\ Asincrono significa che il segnale in ingresso non è campionato dall&#39;orologio di sistema. Tali fronti di salita si possono verificarsi

\ in tempi molto brevi, in qualunque istante ed è possibile rilevare la durata.

\ Rendiamo sensibile ai fronti di salita il GPIO26 a cui è associati il pulsante, quindi

\ avremo 1000 0000 0000 0000 0000 0000 0000 che equivale a 4000000 in decimale o 0x63 in esadecimale

\ l&#39;OR logico ci permette di aggiornare e di non cancellare precedenti settaggi.

:GPAREN!4000000 GPAREN0 @ OR GPAREN0 ! ;

main.f: Questo è il file che contiene le WORDS in linguaggio comprensivo che permettono di inizializzare il sistema **SETUP** , di avviare il ciclo principale **RUN** , oltre a quelle che descrivono i vari comportamenti. Alla fine del caricamento viene lanciata la word **START** che mette il sistema in ascolto con un ciclo infinito: alla pressione del tasto **POWER ON** il sistema si avvia.

\ Embedded Systems - Sistemi Embedded - 17873)

\ Main Words )

\ Università degli Studi di Palermo )

\ Davide Proietto matr. 0739290 LM Ingegneria Informatica, 21-22 )

\ includere dopo tutti gli altri \*.f

HEX

\ Aziona il Sistema Illuminazione

:GO\_LIGHT

  REDLED GPOFF!

  STOPWIND

  CLEAR

  CLEAN

  DRAWSTARTLIGHT

  SYSTEM

  LIGHT

  SYSTEMLIGHT

  ;

\ Aziona il Sistema Ventilazione

:GO\_WIND

  REDLED GPOFF!

  STOPLIGHT

  CLEAR

  CLEAN

  DRAWSTARTWIND

  SYSTEM

  WIND

  SYSTEMWIND

  ;

\ Sistema Arrestato

:STOP\_DISP

  ALL\_LED\_ON

  CLEAR

  CLEAN

  DRAWSTOP

  SYSTEM

  STOP

  ;

\ Esecuzione attuatori per 4 cicli. Il Flag di fine procedura viene modificato al 4 ciclio.

\ Al termine il programma si rimette in configurazione d&#39;immissione dati.

:RUN0 COUNTER !

  BEGIN

    FLAG @ 1 = WHILE

      GO\_LIGHT .&quot; SYSTEM LIGHT &quot;  LIGHTIME @ TIMER

      GO\_WIND .&quot; SYSTEM WIND &quot; WINDTIME @ TIMER

      COUNTER++

      COUNTER @ 4 = IF  FLAGOFF THEN

      .&quot; Cycle n. &quot;

      COUNTER @ .

      .&quot; Flag setting &quot;

      FLAG @ .

      CR CR

    REPEAT

  ?CTF UNTIL FLAGON STOP\_DISP 10000 DELAY .&quot; END AUTOMATIC CYCLE &quot; CR CLEAR INSERT TIME 10000 DELAY ;\ Riutilizzo di flag per gestire il ciclo principale.

\ Main WORD che contiene settaggi di base e avvio del ciclo principale:

\ Vengono avviati i setup per il Bus I2C per inizializzare l&#39;LCD, la Keypad, led e gli attuatori.

\ A questo punto parte il messaggio di benvenuto e inizia il ciclo infinito:

\ Sarà necessario introdurre il tempo di esecuzione degli adattatori espresso in secondi ( 2 cifre per illuminazione e 2 cifre per il vento);

:SETUP

  CLEAN

  DRAWITAFLAG

  SETUP\_I2C

  SETUP\_LCD

  SETUP\_KEYPAD

  SETUP\_LED

  CLEAR

  WELCOME

  \&gt;LINE2

  SMART

  CLIMA

  50000 DELAY

  CLEAR

  STOP\_DISP

  20000 DELAY

  CLEAR

  INSERT TIME

  40000 DELAY

    BEGIN

    FLAGON

    DETECT

    1

    RUN 20000 DELAY

    ?CTF UNTIL

    ;

\ Solo setup Hardware per testing.

 :ONLY\_SETUP

  CLEAN

  DRAWITAFLAG

  SETUP\_I2C

  SETUP\_LCD

  SETUP\_KEYPAD

  SETUP\_LED

  CLEAR

  WELCOME

  \&gt;LINE2

  SMART

  CLIMA

  30000 DELAY

  CLEAR

  STOP\_DISP

  ;

\ Viene letto il valore del registro GPEDS0, che se ha valore 4000000 ( ovvero rilevato fronte sul GPIO26 ) fa partire il setup.

:POWER\_ON GPEDS0 @ 4000000 = IF .&quot; PREMUTO TASTO AVVIO DEL SISTEMA &quot; CR SETUP THEN0 GPEDS0 ! ;

\ Ciclo d&#39;avvio che mette il sistema in ascolto della premuta del tasto di accensione asincrono

:START

    SETUP\_BUTTON

    GPAREN!

    BEGIN

      WHILE

        POWER\_ON

      REPEAT

    0 GPEDS0 !

;

START

## **Testing**

![](RackMultipart20220404-4-jl89na_html_131ad8cb2efa4f31.jpg)

![](RackMultipart20220404-4-jl89na_html_992b120e0581f4cf.jpg)

Passiamo alla configurazione del TTY in ZOS8 impostando la connessione seriale come da immagini:

![](RackMultipart20220404-4-jl89na_html_48996089fea87ef4.png)

È possibile fare la scansione delle porte com disponibili per trovare quella alla quale è collegata la nostra interfaccia UART.

![](RackMultipart20220404-4-jl89na_html_d1b428edff47fcb6.png)

Settiamo anche i paramentri per le line del terminale Carrage Return e Line Feed.

![](RackMultipart20220404-4-jl89na_html_9849a45dd250bd48.png)

![](RackMultipart20220404-4-jl89na_html_acea50bfb8f39eb8.jpg)

Per la programmazione una volta avviato il terminale e attivata la connessione con l&#39;interfaccia seriale, possiamo dare alimentazione al Raspberry PI 4.

![](RackMultipart20220404-4-jl89na_html_d9ba9492842863b2.png)

Dopo pochi secondi comparirà la console a riga di comando dell&#39;interprete.

![](RackMultipart20220404-4-jl89na_html_72798d8ad673fd6f.png)

![](RackMultipart20220404-4-jl89na_html_da3c11e5f1c4ea09.png)

Dalla barra dei pulsanti selezioniamo il caricamento di un file sorgente.

Si aprirà la selezione file e a questo punto carichiamo il nostro final.f.

![](RackMultipart20220404-4-jl89na_html_245180263788553f.png)

![](RackMultipart20220404-4-jl89na_html_964354148d320324.png)

Il codice verrà inviato al target alla velocità stabilita nei parametri di connessione.

Terminato il caricamento viene lanciata automaticamente la WORD &quot;START&quot; che mette il sistema in ascolto alla pressione del tasto POWER ON

![](RackMultipart20220404-4-jl89na_html_15d5226c0b1b7849.jpg)

![](RackMultipart20220404-4-jl89na_html_dff6bde9954f57a8.jpg)

All&#39;inizio il sistema sarà in fase di SYSTEM STOP e quindi sarà acceso il led rosso e tutti gli attuatori saranno disattivati.

A questo punto si potrà digitare dalla tastiera il valore di temporizzazione espresso in secondi da 0 a 99, con due cifre decimali per il tempo di illuminazione e altre due per quello di ventilazione.

D&#39;ora in avanti il sistema entra in un ciclo composto da quattro scambi di alternanza tra le funzioni. Il tempo è scandito in secondi.

![](RackMultipart20220404-4-jl89na_html_209be33cdb21c399.png)

![](RackMultipart20220404-4-jl89na_html_45239c45181e0182.png) ![](RackMultipart20220404-4-jl89na_html_583c926ec0b1529a.png)

Quando sarà in fase di SYSTEM LIGHT sarà acceso il led giallo e il sistema di illuminazione sarà in funzione.

Quando sarà in fase di SYSTEM WIND sarà acceso il led verde e il sistema di ventilazione sarà in funzione.

![](RackMultipart20220404-4-jl89na_html_b5abeefe3c81c013.png) ![](RackMultipart20220404-4-jl89na_html_e4839f5ef357d89c.png)

In caso di anomalia o manutenzione può essere premuto il tasto ESC per interrompere il programma.

##

##

## **Conclusioni**

Nella realizzazione di questo progetto le difficoltà iniziali sono state legate al fatto di avere a che fare con componenti che solitamente siamo già messi in condizione di utilizzarli senza troppi fronzoli. In realtà quando si crea un software che deve descrivere i comportamenti di un hardware così a basso livello si comincia ad apprezzare in maniera concreta la validità dello stesso.

Questo progetto potrebbe evolversi: ad esempio si potrebbero applicare numerosi sensori ed attuatori per rendere veramente autonomo lo stesso sistema; come dei meccanismi di irrigazione controllati, piuttosto che dei sensori crepuscolari o altro.

Potrebbe benissimo trovare applicazione in altri ambiti semplicemente modificando gli attuatori e le WORDS di controllo degli stessi.

Inoltre la programmazione così gestita &quot;_a blocchi_&quot; rende riutilizzabile il codice anche su altri target con le dovute pre-configurazioni.

_Davide Proietto_

 ![Shape7](RackMultipart20220404-4-jl89na_html_aef9d8beb1a10ccd.gif)

_Davide Proietto 0739290 – Anno Accademico 2021/22__pag. 75_