# multiIO - Embedded Hausbus auf Basis RS485 und PIC16F946

Embedded-System für Hausautomatisierung basierend auf RS485-Kommunikation und PIC16F946 Mikrocontroller. Das System ermöglicht die zentrale Steuerung und Überwachung von I/O-Funktionen über ein serielles Busprotokoll.

## Hardware-Architektur

Die multiIO-Platine basiert auf dem **PIC16F946** Mikrocontroller und bietet eine vollständige I/O-Lösung für Hausautomatisierung:

### Hauptkomponenten

#### Zentraleinheit
- **IC1**: PIC16F946 - 64-Pin Mikrocontroller
  - 8K words (14-Bit) Flash-Speicher, 368 Bytes RAM, 256B EEPROM
  - Interner Oszillator mit präziser OSCTUNE-Kalibrierung (7.3-8.3 MHz)
  - Unterstützt 38.4k/57.6k/115.2k bps durch Frequenzanpassung
  - Alle 16 Ausgänge und 16 Eingänge voll ausgenutzt

#### Kommunikation
- **IC2**: MAX487CSA - RS485 Transceiver
  - Half-Duplex RS485 Kommunikation
  - Differentielle Signalübertragung ±7V
  - Automatic Direction Control über DE/RE-Pins
- **IC8**: MAX232ACSE - RS232 Interface (optional)
  - Zusätzliche serielle Schnittstelle für Debugging/Konfiguration
  - Spannungswandlung ±12V für RS232-Pegel

#### Ausgangssektion (16 High-Side-Treiber)
- **IC3/IC4**: 2× VN808CM-E - 8-Kanal High-Side Schalter
  - Intelligente Power-Switches für 16 Ausgänge (O1.0-O1.7, O2.0-O2.7)
  - Integrierte Schutzfunktionen: Übertemperatur, Kurzschluss, Überstrom
  - Status-Feedback über STATUS1/STATUS2-Pins
  - Bis zu 1A pro Kanal bei 12-48V Betriebsspannung

#### Eingangssektion (16 optoisolierte Eingänge)
- **16× TLP280-4**: Optokoppler für galvanische Trennung
  - 4-Kanal Optokoppler-Arrays (TLP280-4)
  - Eingangsspannungsbereich: 12-24V DC
  - 2,5kV Isolationsspannung
  - Pull-up Widerstände 47kΩ für sichere Schaltschwellen

#### LED-Matrix Display
- **IC6**: 74HC4017 - Dezimal-Zähler/Demultiplexer
- **IC5**: ULN2003AD - 7-Kanal Darlington-Array
- Matrixabtastung der 16 Eingänge über COL0-COL9 Spalten
- Reduziert Pin-Bedarf des Mikrocontrollers

### Spannungsversorgung

#### Primärversorgung
- **IC9**: MC34063A - Step-Down Switching Regulator
  - Eingangsspannung: 7-35V DC
  - Ausgangsspannung: 5V für Mikrocontroller-Logik
  - Hocheffiziente Schaltregler-Topologie

### Schutzbeschaltung

#### Überstromschutz
- **F1-F8**: Sicherungen für alle Aus- und Eingänge
- **D1-D4**: Schutzdioden gegen Verpolung und Überspannung
- **Entstörung**: 100nF Kondensatoren an allen kritischen Knoten

#### Galvanische Trennung
- Vollständige Optoisolierung aller 16 Eingänge
- Getrennte Massepotentiale (GNDA für Analogteil)

### Anschlusstechnik

#### Externe Verbindungen
- **X1, X8**: FK-MPT 10-polige Federkraftklemmen für I/O
- **X2**: FK-MPT 2-polige Klemme für RS485-Bus
- **X3, X4**: Zusätzliche I/O-Erweiterungen
- **SV1, SV2**: ICSP-Programmierschnittstelle

#### Konfiguration
- **JP1-JP10**: Jumper für Hardware-Konfiguration
  - Adressierung, Terminierung, Betriebsmodi
  - Pull-up/Pull-down Konfiguration
- **LED1**: Status-LED für Betriebsanzeige

### Hardware-Spezifikationen (Schaltplan-basiert)

- **Eingänge**: 16× optoisoliert, 12-24V DC, Matrix-gescannt
- **Ausgänge**: 16× High-Side-Switch, 1A@48V max pro Kanal
- **Versorgung**: 7-35V DC Eingang, interne 5V/12V/24V Erzeugung
- **Isolation**: 2,5kV zwischen Ein-/Ausgängen und Logik
- **Schutz**: Sicherungen, Überstrom-, Übertemperaturschutz
- **EMV**: Entstörfilter, differentielle RS485-Übertragung
- **Platinengröße**: Eurocard-Format (ca. 160×100mm)
- **Anschlüsse**: Federkraftklemmen für industrielle Anwendung

## Funktionen

- **RS485-Kommunikation**: Serielle Busverbindung für Multi-Device-Netzwerk
- **Multi-Device-Unterstützung**: 19 verschiedene Device-IDs für verschiedene Geräte
- **I/O-Steuerung**: Ein-/Ausgänge für Sensoren und Aktoren
- **Zeitfunktionen**: RTC-Funktionen für zeitgesteuerte Aktionen
- **Konfigurationsspeicher**: EEPROM-basierte Parameterspeicherung
- **Interrupt-gesteuert**: Effiziente serielle Datenverarbeitung

## Protokollbeschreibung

### Nachrichtenformat
```
[STARTBYTE] [COMMAND] [DEVICE_ID] [DATA...] [CHECKSUM]
```

- **STARTBYTE (0x00)**: Markiert Nachrichtenbeginn
- **COMMAND**: 8-Bit Kommandocode
- **DEVICE_ID**: Zielgerät (0x01-0xFF)
- **DATA**: Variable Nutzlast (0-254 Bytes)
- **CHECKSUM**: XOR-Prüfsumme aller Bytes

### Kommando-Kategorien

#### Systemkommandos
- **CMDOFF (0x01)**: Alle Ausgänge eines Geräts ausschalten
  - Format: `00 01 ID`
  - Schaltet alle Relais/Ausgänge des Zielgeräts aus (Notaus-Funktion)
- **CMDRESET (0x02)**: Gerät-Reset
  - Format: `00 02 ID`
  - Führt Soft-Reset des Mikrocontrollers durch
- **CMDID (0x04)**: Device-Poll
  - Format: `00 04 ID`
  - Prüft Erreichbarkeit eines Geräts, Antwort: CMDACK
- **CMDACK (0x03)**: Bestätigung
  - Format: `00 03 ID`
  - Standardantwort für erfolgreich verarbeitete Kommandos

#### I/O-Steuerung (Multi-Channel)
- **CMDOWR (0x05)**: Ausgänge setzen (16-Bit)
  - Format: `00 05 ID LO_BYTE HI_BYTE`
  - Setzt alle 16 Ausgänge gleichzeitig (Bit 0 = Ausgang 0, etc.)
- **CMDIRD (0x06)**: Eingänge lesen
  - Format: `00 06 ID`
  - Antwort: `00 08 ID LO_BYTE HI_BYTE` (16-Bit Eingangsstatus)
- **CMDORD (0x07)**: Ausgänge lesen
  - Format: `00 07 ID`
  - Antwort: `00 08 ID LO_BYTE HI_BYTE` (16-Bit Ausgangsstatus)

#### Einzelkanal-Steuerung
- **CMDOC (0x8Y)**: Einzelausgang löschen
  - Format: `00 8Y ID` (Y = Kanal 0-F)
  - Schaltet spezifischen Ausgang aus
- **CMDOS (0x9Y)**: Einzelausgang setzen
  - Format: `00 9Y ID` (Y = Kanal 0-F)
  - Schaltet spezifischen Ausgang ein
- **CMDO (0xAY)**: Einzelausgang lesen
  - Format: `00 AY ID` (Y = Kanal 0-F)
  - Antwort: `00 08 ID 00/01 00` (Ausgangszustand)
- **CMDI (0xBY)**: Einzeleingang lesen
  - Format: `00 BY ID` (Y = Kanal 0-F)
  - Antwort: `00 08 ID 00/01 00` (Eingangszustand)

#### Event-System (Edge-Detection)
- **CMDPEDGE (0x1Y)**: Positive Flanke
  - Format: `00 1Y ID` (Y = Kanal 0-F)
  - Wird automatisch gesendet bei steigender Flanke an Eingang Y
- **CMDNEDGE (0x2Y)**: Negative Flanke
  - Format: `00 2Y ID` (Y = Kanal 0-F)
  - Wird automatisch gesendet bei fallender Flanke an Eingang Y

#### Hausautomatisierung
- **CMDSOFF (0x4Y)**: Komfort-Aus
  - Format: `00 4Y ID` (Y = Kanal 0-F)
  - Kontext-abhängig: Jalousien↗️/Fenster🔒/Licht💡⬇️
- **CMDSON (0x6Y)**: Komfort-Ein
  - Format: `00 6Y ID` (Y = Kanal 0-F)
  - Kontext-abhängig: Jalousien⬇️/Fenster🔓/Licht💡⬆️
- **CMDGOFF (0x5G)**: Gruppensteuerung Aus
  - Format: `00 5G GG` (G = Gruppencode)
  - Schaltet alle Geräte einer Gruppe aus
- **CMDGON (0x7G)**: Gruppensteuerung Ein
  - Format: `00 7G GG` (G = Gruppencode)
  - Schaltet alle Geräte einer Gruppe ein
- **CMDAOFF (0x5F)**: Globaler Licht-Aus
  - Format: `00 5F 01`
  - Schaltet alle Lichter im System aus
- **CMDAON (0x7F)**: Globaler Licht-Ein
  - Format: `00 7F 01`
  - Schaltet alle Lichter im System ein

#### Zeit- und Konfiguration
- **CMDTSET (0x09)**: RTC Zeit setzen
  - Format: `00 09 ID SS MM HH DD MM` (5 Bytes: Sek/Min/Std/Tag/Monat)
- **CMDTGET (0x0A)**: RTC Zeit lesen
  - Format: `00 0A ID`
  - Antwort: `00 0B ID SS MM HH DD MM` (aktuelle Zeit)
- **CMDCGET (0x0C)**: Konfiguration lesen
  - Format: `00 0C ID`
  - Antwort: `00 0D ID [255 Config-Bytes]` (komplette EEPROM-Konfiguration)
- **CMDCSET (0x0E)**: Konfiguration schreiben
  - Format: `00 0E ID [256 Config-Bytes]` (vollständige EEPROM-Programmierung)

## Konfigurierbare Betriebsmodi

Jeder Ausgang kann individuell in verschiedenen Modi betrieben werden. Die Konfiguration erfolgt über EEPROM-Parameter:

### Grundmodi
- **Mode 0 - Exit (1 Ausgang)**
  - Einfacher Taster-Ausgang für Türöffner
  - Kurzer Impuls bei Aktivierung

- **Mode 1 - Passthrough (4 Ausgänge)**
  - Direkte 1:1 Weiterleitung von Eingängen zu Ausgängen
  - Ohne Verzögerung oder Logik

- **Mode 2 - Force Off (2 Ausgänge)**
  - Ausgänge werden permanent auf "Aus" gehalten
  - Für Sicherheitsschaltungen

- **Mode 3 - Force On (2 Ausgänge)**
  - Ausgänge werden permanent auf "Ein" gehalten
  - Für Always-On Geräte

### Lichtsteuerung
- **Mode 4 - Toggle Light (4 Ausgänge)**
  - Klassische Lichtschaltung mit Toggle-Funktion
  - Eingang schaltet Licht ein/aus

- **Mode 5 - Dual Toggle (4 Ausgänge)**
  - Zwei Ausgänge mit unabhängiger Toggle-Steuerung
  - Für Zwei-Kreis-Beleuchtung

- **Mode 6 - Dimmed Light (5 Ausgänge)**
  - Zweistufiges Licht (Output 1: Stufe 1, Output 1+2: Stufe 2)
  - Verschiedene Helligkeitsstufen

### Timer-Modi
- **Mode 8 - Retriggerable Timer (5 Ausgänge)**
  - Ausgang für konfigurierbare Zeit eingeschaltet
  - Bei erneutem Trigger wird Zeit zurückgesetzt
  - Ideal für Treppenhauslicht

- **Mode 9 - Blinker (5 Ausgänge)**
  - Kontinuierliches Blinken mit konfigurierbarer Frequenz
  - Für Signalgebung oder Warnleuchten

### Rollladen/Markisen-Steuerung
- **Mode D - Awning Control (6 Ausgänge)**
  - Output 1: Ein/Aus (Hauptschalter)
  - Output 2: Auf/Zu (Richtungssteuerung)
  - Endlagenerkennung über Eingänge
  - Automatische Zeitüberwachung

- **Mode E - Blind Control (6 Ausgänge)**
  - Output 1: Ein/Aus (Motorsteuerung)
  - Output 2: Hoch/Runter (Richtung)
  - Endschalter-Überwachung
  - Zwischenpositionen möglich

- **Mode F - Window Control (6 Ausgänge)**
  - Output 1: Auf (Fenster öffnen)
  - Output 2: Zu (Fenster schließen)
  - Für automatische Fensterlüftung
  - Wettersensor-Integration

### Konfigurationsparameter
Jeder Modus kann über EEPROM-Parameter angepasst werden:

```
Parameter-Layout (5-6 Bytes pro Ausgang):
[PrescaleMode] [OutputPin] [InputPin] [DeviceID1] [Delay] [DeviceID2]
```

- **PrescaleMode**: Modus + Zeitbasis (4 Bit Modus + 4 Bit Prescaler)
- **OutputPin**: Zugeordneter Ausgangspin (0x00-0x0F)
- **InputPin**: Zugeordneter Eingangspin (0x00-0x0F)
- **DeviceID1**: Primäre verknüpfte Geräte-ID
- **Delay**: Zeitwerte für Timer-Modi (optional)
- **DeviceID2**: Sekundäre verknüpfte Geräte-ID (optional)

## EEPROM-Konfigurationssystem (src/parameter.asm)

Die Datei `parameter.asm` implementiert ein cleveres **bedingte Kompilierungs-System** für EEPROM-Konfiguration:

### 🔧 Technische Funktionsweise

#### Bedingte EEPROM-Programmierung
```assembly
; In main.asm - Device-ID Definition:
#ifndef device
#define device 0x01         ; Standard-Device falls nicht definiert
#endif

; In parameter.asm - Bedingte Kompilierung:
org     0x2100              ; EEPROM-Startadresse (256 Bytes)
de      device              ; Byte 0: Aktuelle Device-ID

if device == 0x01           ; Nur für Device 0x01 kompiliert
    de  0x04,0x0d,0x0b,0x01 ; Konfigurationsdaten für 0x01
    de  0x56,0x10,0x00,0x01
    ...
endif

if device == 0x02           ; Nur für Device 0x02 kompiliert
    de  0x04,0x00,0x01,0x02 ; Andere Konfiguration für 0x02
    ...
endif
```

#### Build-Prozess Mechanismus
```bash
# build-all.sh kompiliert 19× die gleiche Firmware:
gpasm -D device=0x01 -o build/multiIO src/main.asm  # → multiIO.device0x01.hex
gpasm -D device=0x02 -o build/multiIO src/main.asm  # → multiIO.device0x02.hex
gpasm -D device=0x03 -o build/multiIO src/main.asm  # → multiIO.device0x03.hex
# ... für alle 19 Device-IDs
```

**Ergebnis:** Ein Source-Code → 19 verschiedene Firmwares mit jeweils optimierter EEPROM-Konfiguration

### 🎯 Vorteile dieses Systems

#### Memory-Effizienz
- **Ohne parameter.asm**: Firmware mit allen Konfigurationen + Runtime-Konditionierung
- **Mit parameter.asm**: Firmware enthält nur relevante EEPROM-Daten für eine Device-ID

#### Performance-Optimierung
- **Keine Runtime-Entscheidungen**: Kein `if (deviceID == 0x01)` zur Laufzeit
- **Direkte EEPROM-Zugriffe**: Konfiguration zur Compile-Time fest verdrahtet
- **Kleinere EEPROM-Images**: Nur benötigte Konfigurationsdaten pro Device

#### Wartbarkeit
- **Ein Source-Code** für alle Geräte-Varianten
- **Zentrale Konfiguration** in einer Datei
- **Bedingte Kompilierung** verhindert Konfigurationsfehler

### 📊 EEPROM-Memory-Layout

```
EEPROM-Adresse 0x2100-0x21FF (256 Bytes):
┌─────────────────┬─────────────────┬─────────────────┐
│ Byte 0: DeviceID│ Byte 1: OutLo   │ Byte 2: OutHi   │
├─────────────────┼─────────────────┼─────────────────┤
│ Byte 3: Action 0│ Byte 4: Action 0│ Byte 5: Action 0│
│ [Mode+Prescale] │ [Output Pin]    │ [Input Pin]     │
├─────────────────┼─────────────────┼─────────────────┤
│ Byte 6: DevID1  │ Byte 7: Delay   │ Byte 8: DevID2  │
├─────────────────┼─────────────────┼─────────────────┤
│ Byte 9: Action 1│ Byte 10:Action 1│ Byte 11:Action 1│
│ ...             │ ...             │ ...             │
└─────────────────┴─────────────────┴─────────────────┘
```

### 🏗️ Assemblierung-Prozess

```assembly
org     0x2100              ; Startet bei EEPROM-Adresse
PARAMBASE equ $             ; Merkt sich aktuelle Position (Base-Pointer)

eeDeviceID equ $-PARAMBASE  ; Offset 0 vom Base
de      device              ; Schreibt aktuelle Device-ID ins EEPROM

; Bedingte EEPROM-Programmierung:
if device == 0x01
    ; Diese Daten werden nur in multiIO.device0x01.hex geschrieben:
    de  0x56,0x10,0x00,0x01,0x28    ; Technik Decke 1&2
    de  0xa4,0x02,0x01,0x01,0xe1    ; Treppe UG Downlights (Timer)
    de  0x04,0x0d,0x0b,0x01         ; Werkstatt Decke 3 (Toggle)
endif

if device == 0x02
    ; Diese Daten werden nur in multiIO.device0x02.hex geschrieben:
    de  0x04,0x00,0x01,0x02         ; Andere Konfiguration
endif
```

### ⚡ Laufzeit-EEPROM-Zugriff

```assembly
; In der Firmware (eeprom.asm):
startup:
    call    readEEPROM      ; Liest Device-ID aus EEPROM Byte 0
    movwf   deviceID        ; Speichert gelesene Device-ID

    call    loadParameters  ; Lädt alle Action-Konfigurationen
    ; Firmware weiß jetzt sofort ihre Identität und Konfiguration
```

### 🎯 Das Geniale an diesem System

**Bedingte Kompilierung auf EEPROM-Ebene:**
- **Gleicher Code** wird 19× mit verschiedenen `-D device=0xXX` Parameters kompiliert
- **Jede Firmware** enthält nur ihre spezifischen Konfigurationsdaten
- **Zur Laufzeit** keine Device-ID-Prüfungen notwendig
- **EEPROM zur Compile-Time** gefüllt, nicht zur Runtime

**Beispiel-Installation:**
```
🏠 Device 0x01 - Untergeschoss: Technik, Werkstatt, Hobby
🏠 Device 0x02 - Erdgeschoss:   Küche, Wohnen, Essen
🏠 Device 0x03 - Obergeschoss:  Schlafzimmer, Bad
🏠 Device 0x4D - Sondergeräte:  Garage, Außenbeleuchtung
```

Dieses System ermöglicht eine **skalierbare Hausautomatisierung** mit **optimaler Speichernutzung** und **maximaler Performance**.

## Verzeichnisstruktur

```
multiIO/
  src/           # Assembly-Quelldateien (.asm)
  inc/           # Include-Dateien (.inc)
  build/         # Build-Artefakte (wird automatisch erstellt)
  Makefile       # Build-Konfiguration
  build-all.sh   # Skript zum Erstellen aller Device-Varianten
```

## Build-System

### Einzelnes Device bauen

```bash
make                    # Baut Device-ID 0x01 (Standard)
make DEVICE_ID=0x05     # Baut spezifische Device-ID
```

### Alle Device-Varianten bauen

```bash
./build-all.sh
```

Erstellt automatisch .hex-Dateien für alle in `src/parameter.asm` definierten Device-IDs im `build/` Verzeichnis.

### Aufräumen

```bash
make clean              # Löscht build/ Verzeichnis und temporäre Dateien
```

## Abhängigkeiten

- **gputils**: gpasm und gplink für PIC Assembly
- **PIC16F946**: Target-Mikrocontroller

## Build-Ausgaben

- `build/multiIO.hex` - Standard-Firmware (Device-ID 0x01)
- `build/multiIO.device0xXX.hex` - Spezifische Device-Varianten
- `build/multiIO.cod` - Code-Datei für Debugging
- `build/multiIO.lst` - Listing-Datei

## Technische Details

- **Mikrocontroller**: PIC16F946
- **Kommunikation**: RS485 bei 38.400 bps
- **Oszillator**: Intern mit OSCTUNE-Anpassung für präzise Baudrate
- **Firmware-Revision**: 4

## Firmware-Konfiguration

### Build-Varianten
- **Debug-Modus**: Mit ICSP-Debugging-Unterstützung (__DEBUG)
- **Release-Modus**: Optimiert für Produktionseinsatz
- **Baudrate-Optionen**: 38.4k (Standard), 57.6k, 115.2k bps

### OSCTUNE-Kalibrierung
- **Präzision**: ±0.16% Genauigkeit durch OSCTUNE-Register
- **Frequenzbereiche**:
  - 7.352 MHz für 115.2k bps
  - 8.000 MHz für 38.4k/57.6k bps
  - 8.293 MHz für erweiterte Modi

### Erweiterte Spezifikationen

#### Hardware-Details
- **Flash-Speicher**: 8K words (14-Bit) Programmspeicher
- **RAM**: 368 Bytes Datenspeicher + Register
- **EEPROM**: 256 Byte für persistente Konfiguration
- **I/O-Pins**: 16 konfigurierbare digitale Ein-/Ausgänge
- **Timer**: Timer0, Timer1, Timer2 für Zeitfunktionen
- **ADC**: 10-Bit A/D-Wandler für Analogeingänge
- **Interrupts**: UART, Timer, I/O-Change, LVD, ADC

#### Software-Architektur
- **Real-Time OS**: Interrupt-gesteuerte Verarbeitung (<1ms Response)
- **Message-Buffers**:
  - RX: 32-Byte Ringpuffer (BUFSIZE=0x20)
  - TX: 32-Byte Ringpuffer
  - Message-Queue: 16-Byte (MSGBUFSIZE=0x10)
- **Error-Handling**: Watchdog, XOR-Checksumme, 100ms Timeout, 3× Retry
- **Konfiguration**: 256-Byte EEPROM-basierte Parameterspeicherung
- **Debugging**: .cod/.lst Dateien für MPLAB/GPutils
- **Compiler**: gputils (gpasm/gplink) - Open Source PIC Toolchain

#### Protokoll-Eigenschaften
- **Busart**: Master-Slave
- **Startbyte**: 0x00 für Synchronisation
- **Adressraum**: 1-255 Geräte (0x01-0xFF)
- **Nachrichtenlänge**: 3-258 Bytes
- **Checksumme**: XOR aller Bytes
- **Timeout**: 100ms Antwortzeit
- **Retry**: 3x automatische Wiederholung