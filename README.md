# ProgrammerbareKrinsar

Buckle your fuckles and get ready for the README of a lifetime. This was made with intense hatred, copious amounts of caffeine and lots of love. Please enjoy. If you don't, please contact us at 1-800-KILL-ME or by carrier pidgeon.

## Krav til CTRL-modul 1
- Tar inn 8-databits og konverterer til ett Hexadesimalt tall
- Tallet skal tilsvare ASCII karakter
- Viser dette tallet tre 7-segmentdisplays
- Skal blinke en LED på RS-232 ved mottatt melding
![ASCII-Table-wide svg](https://github.com/Jawny-E/ProgrammerbareKrinsar/assets/94108006/f68f5f9c-886a-44af-b687-88f2303978a9)

Resultat: 
![Skjermbilde 2023-10-23 174015](https://github.com/Jawny-E/ProgrammerbareKrinsar/assets/94108006/71760a93-11c5-45e7-8342-b9c92ca81c6e)

## Krav til RX-modul 1
- UART protokoll 8 data-bit, 1 stop-bit og 0 paritets-bit
- Skal kunne bruke 9600 baudrate (justerbar)
- Skal kun vidareføre korrekt mottatt byte
- Oversampling med 8 gonger raskare hastigheit, bruk bit 3 eller 4
  - Her bør det være enkelt nok å gjennomføre majoritetsvalg i staden vha. ein funksjon
- Sender ut eit signal ved mottatt data
- Vil gjerne: PARITETSBIT
 
Resultat:

<img width="693" alt="Results" src="https://github.com/Jawny-E/ProgrammerbareKrinsar/assets/94108006/0ffd3171-0160-40c2-b6b4-ec48f064d0b5">

Pinout:

<img width="631" alt="Pins" src="https://github.com/Jawny-E/ProgrammerbareKrinsar/assets/94108006/9ddb34d5-ad3c-42e1-a3a9-48a55c5920f0">
