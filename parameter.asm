				org		0x2100			; 256 bytes of eeprom
PARAMBASE		equ		$	;{
	
eeDeviceID		equ		$-PARAMBASE
				de		device
eeOutputLo		equ		$-PARAMBASE
				de		0x00
eeOutputHi		equ		$-PARAMBASE	
				de		0x00	;}
				
actionbase		equ		$-PARAMBASE

; mode 0 - 1 exit
; mode 1 - 4 passthrough
; mode 2 - 2 always off
; mode 3 - 2 always on
; mode 4 - 4 toggle light
; mode 5 - 4 light toogle dual outputs
; mode 6 - 5 two stage light (output1: 1st stage output2 2nd stage)
; mode 7 - 1 nop
; mode 8 - 5 retriggerable timer
; mode 9 - 5 stopable timer
; mode a - 1 nop
; mode b - 1 nop
; mode c - 1 nop
; mode d - 6 awning (output1: on/off output2: open/close)
; mode e - 6 blind (output1: on/off output2: up/down
; mode f - 6 window (output1: down output2: close)
; prescale+mode | output | input | device1 | delay(opt) | device2


 if device == 0x01
;Input	Raum Position		Output	Relais	Raum Position
;I01.0	Technik Tür A		O01.0	Ra01	Technik Decke 1
;I01.1	Technik Tür B		O01.1	Ra02	Technik Decke 2
;I01.2	Treppe UG West A	O01.2	Ra03	Treppe UG Downlights
;I01.3	Treppe UG West B	O01.3	Ra04	Treppe UG Unter Podest
;I01.4	Treppe UG Ost A		O01.4	Ra05	Treppe UG Wand West
;I01.5	Treppe UG Ost B		O01.5	Ra06	Treppe UG Wand Ost
;I01.6	Vorrat Tür A		O01.6	Ra07	Vorrat Decke 1
;I01.7	Hobby Tür A			O01.7	Ra08	Vorrat Decke 2
;I01.8	Hobby Tür B			O01.8	Ra09	Hobby Downlights 1
;I01.9	Hobby Tür C			O01.9	Ra10	Hobby Downlights 2
;I01.A	Hobby Tür D			O01.A	Ra11	Hobby – reserve –
;I01.B	Werkstatt Tür A		O01.B	Ra12	Werken Decke 1 (L1)
;I01.C	Werkstatt Tür B		O01.C	Ra13	Werken Decke 2 (L2)
;I01.D	Arbeiten Tür A		O01.D	Ra14	Werken Decke 3 (L3)
;I01.E	Arbeiten Tür B		O01.E	Ra15	Arbeiten Downlights 1
;I01.F	Arbeiten Tür C		O01.F	Ra16	Arbeiten Downlights 2
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x56,0x10,0x00,0x01,0x28		; Technik Decke 1&2

	de	0xa4,0x02,0x01,0x01,0xe1		; Treppe UG Downlights - Technik Tür B
	de	0xa4,0x02,0x02,0x01,0xe1		; Treppe UG Downlights - Treppe UG West A
	de	0xa4,0x02,0x05,0x01,0xe1		; Treppe UG Downlights - Treppe UG Ost B
	de	0xa4,0x02,0x0a,0x01,0xe1		; Treppe UG Downlights - Hobby Tür D
	de	0xa4,0x02,0x0d,0x01,0xe1		; Treppe UG Downlights - Arbeiten Tür A
	de	0xa4,0x02,0x02,0x02,0xe1		; Treppe UG Downlights - Garderobe Tür B
	de	0xa4,0x02,0x04,0x02,0xe1		; Treppe UG Downlights - Treppe EG Ost B
	de	0xa4,0x02,0x08,0x02,0xe1		; Treppe UG Downlights - Treppe EG Süd B
	de	0xa4,0x02,0x02,0x03,0xe1		; Treppe UG Downlights - Treppe EG West H

	de	0xa4,0x03,0x03,0x01,0xe1		; Treppe UG Unter Podest - Treppe UG West B - 30min
	de	0xa4,0x03,0x04,0x01,0xe1		; Treppe UG Unter Podest - Treppe UG Ost A - 30min

	de	0xa5,0x54,0x01,0x01,0xe1		; Treppe UG Wand West/Ost - Technik Tür B
	de	0xa5,0x54,0x02,0x01,0xe1		; Treppe UG Wand West/Ost - Treppe UG West A
	de	0xa5,0x54,0x05,0x01,0xe1		; Treppe UG Wand West/Ost - Treppe UG Ost B
	de	0xa5,0x54,0x0a,0x01,0xe1		; Treppe UG Wand West/Ost - Hobby Tür D
	de	0xa5,0x54,0x0d,0x01,0xe1		; Treppe UG Wand West/Ost - Arbeiten Tür A
	de	0xa5,0x54,0x02,0x02,0xe1		; Treppe UG Wand West/Ost - Garderobe Tür B
	de	0xa5,0x54,0x04,0x02,0xe1		; Treppe UG Wand West/Ost - Treppe EG Ost B
	de	0xa5,0x54,0x08,0x02,0xe1		; Treppe UG Wand West/Ost - Treppe EG Süd B
	de	0xa5,0x54,0x02,0x03,0xe1		; Treppe UG Wand West/Ost - Treppe EG West H

	de	0x56,0x76,0x06,0x01,0x28		; Vorrat Decke 1&2
	de	0x56,0x98,0x08,0x01,0x28		; Hobby Downlights 1&2
	de	0x56,0x89,0x07,0x01,0x28		; Hobby Downlights 2&1
	de	0x56,0x98,0x0c,0x01,0x28		; Hobby Downlights 1&2
	de	0x02,0x0a						; Hobby – reserve –
	de	0x56,0xcb,0x0b,0x01,0x28		; Werken Decke 1&2 (L1&2)
	de	0x04,0x0d,0x0b,0x01				; Werken Decke 3 (L3)
	de	0x04,0x0e,0x0f,0x01				; Arbeiten Downlights 1
	de	0x04,0x0f,0x00,0x02				; Arbeiten Downlights 2
 endif

 if device == 0x02
;Input	Raum	Position	Output	Relais	Raum Position
;I02.0	Arbeiten Tür D		O02.0	Ra17	Arbeiten Downlights 3		
;I02.1	Garderobe Tür A		O02.1	Ra18	Arbeiten – reserve –		
;I02.2	Garderobe Tür B		O02.2	Ra19	Garderobe Decke		
;I02.3	Treppe EG Ost A		O02.3	Ra20	WC Spiegel		
;I02.4	Treppe EG Ost B		O02.4	Ra21	WC Decke		
;I02.5	Treppe EG Ost C		O02.5	Ra22	Windfang Downlights		
;I02.6	Treppe EG Ost D		O02.6	Ra23	Küche Downlights 1		
;I02.7	Treppe EG Süd A		O02.7	Ra24	Küche Downlights 2		
;I02.8	Treppe EG Süd B		O02.8	Ra25	Küche Downlights 3		
;I02.9	Treppe EG Süd C		O02.9	Ra26	Küche – reserve – 		
;I02.A	Treppe EG Süd D		O02.A	Ra27	Küche – reserve –		
;I02.B	Treppe EG West A	O02.B			Treppe EG West LED	2	
;I02.C	Treppe EG West B	O02.C	Ra28	Essen Decke Tisch	
;I02.D	Treppe EG West C	O02.D	Ra29	Essen Downlights Tisch		
;I02.E	Treppe EG West D	O02.E	Ra30	Essen Downlights Nord	
;I02.F	Treppe EG West E	O02.F	Rb01	Treppe EG Downlights
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x04,0x00,0x0e,0x01
	de	0x02,0x01
	de	0x04,0x02,0x01,0x02
	de	0x04,0x03,0x04,0x03
	de	0x02,0x04
	de	0x04,0x05,0x03,0x03
	de	0x04,0x05,0x0a,0x03
	de	0x04,0x05,0x06,0x02
	de	0x04,0x06,0x04,0x04
	de	0x56,0x76,0x0d,0x04,0x28
	de	0x04,0x07,0x03,0x04
	de	0x56,0x78,0x0c,0x04,0x28
	de	0x04,0x08,0x02,0x04
	de	0x02,0x09
	de	0x02,0x0a
	de	0x03,0x0b
	de	0x04,0xdc,0x0b,0x02				; Essen Decke 1 & Downlights 1 - Treppe West A
;	de	0x04,0xdc,0x05,0x04				; Essen Decke 1 & Downlights 1 - Küche Ost H
	de	0x04,0xdc,0x0d,0x05				; Essen Decke 1 & Downlights 1 - Essen West N
	de	0x04,0x0c,0x0e,0x04
	de	0x56,0xed,0x0f,0x04,0x28
	de	0x04,0x0e,0x0a,0x02
	de	0x04,0x0f,0x05,0x02
	de	0x04,0x0f,0x09,0x02
 endif


 if device == 0x03
;Input	Raum Position		Output	Relais	Raum Position
;I03.0	Treppe EG West F	O03.0	Rb02	Essen Steckdose Nord 
;I03.1	Treppe EG West G	O03.1	Rb03	Essen – reserve –	
;I03.2	Treppe EG West H	O03.2	Rb04	Wohnen Downlights 1
;I03.3	WC Tür A			O03.3	Rb05	Wohnen Downlights 2
;I03.4	WC Tür B			O03.4	Rb06	Wohnen Steckdose West
;I03.5	WC Fenster			O03.5	Rb07	Wohnen Wand Nord
;I03.6	Windfang Tür A		O03.6			Winddfang Tür LED 1
;I03.7	Windfang Tür B		O03.7			Winddfang Tür LED 2
;I03.8	Windfang Tür C		O03.8			Winddfang Tür LED 3
;I03.9	Windfang Tür D		O03.9			Winddfang Tür LED 4
;I03.A	Windfang Tür E		O03.A	Rb08	Wohnen Wand Ost-Nord
;I03.B	Windfang Tür F		O03.B	Rb09	Wohnen Wand Ost-Süd
;I03.C	Windfang Tür G		O03.C	Rb10	Schrank Downlights
;I03.D	Windfang Tür H		O03.D	Rb11	Elternbad Spiegel
;I03.E	Küche Ost A			O03.E	Rb12	Elternbad Decke 1
;I03.F	Küche Ost B			O03.F	Rb13	Elternbad Decke 2
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x04,0x00,0x0c,0x05				; Essen Steckdose Nord - Essen West M
	de	0x04,0x00,0x0c,0x02				; Essen Steckdose Nord - Treppe EG West B
	de	0x02,0x01						; Essen – reserve – - Dauer aus
	de	0x56,0x32,0x02,0x0f,0x28		; Wohnen DL 1/2 - Wohnen Süd B
	de	0x56,0x32,0x07,0x05,0x28		; Wohnen DL 1/2 - Essen West H
	de	0x04,0x04,0x03,0x0f				; Wohnen Steckdose West - Wohnen Süd D
	de	0x04,0x04,0x08,0x06				; Wohnen Steckdose West - Wohnen Nord A
	de  0x04,0x04,0x06,0x05				; Wohnen Steckdose West - Essen West G
	de	0x56,0x5a,0x09,0x06,0x28		; Wohnen Wand Nord/Ost-Nord - Wohnen Nord B
	de	0x04,0x05,0x0a,0x0f				; Wohnen Wand Nord - Wohnen Süd I
	de	0xb4,0x06,0x05,0x0e,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Garage C - 80min
	de	0x74,0x06,0x04,0x0e,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Garage B - 5min
	de	0x74,0x06,0x06,0x03,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Windfang Tür B - 5min
	de	0x03,0x07						; Windfang Tür LED 2 - Dauer ein
	de	0xb4,0x08,0x08,0x03,0xe1		; Windfang Tür LED 3 - Windfang Tür C - Kontrolle Außen NO - 120min
	de	0xb4,0x09,0x09,0x03,0xe1		; Windfang Tür LED 4 - Windfang Tür D - Kontrolle Außen Eingang - 120min
    de  0x04,0x0a,0x09,0x0f				; Wohnen Wand Ost-Nord - Wohnen Süd J
    de  0x04,0x0b,0x08,0x0f				; Wohnen Wand Ost-Süd - Wohnen Süd K
	de	0xa4,0x0c,0x07,0x07,0xe1		; Schrank Downlights - Schrank Tür A 1h
	de	0x04,0x0d,0x0c,0x07				; Elternbad Spiegel
	de	0x02,0x0e						; Elternbad Decke 1
	de	0x02,0x0f						; Elternbad Decke 2
 endif
 

 if device == 0x04
;Input	Raum Position		Output	Relais	Raum Position
;I04.0	Küche Ost C			O04.0			Küche Ost LED 1
;I04.1	Küche Ost D			O04.1			Küche Ost LED 2
;I04.2	Küche Ost E			O04.2			Küche Ost LED 3
;I04.3	Küche Ost F			O04.3			Küche Ost LED 4
;I04.4	Küche Ost G			O04.4	Rb14	Eltern Decke 1	
;I04.5	Küche Ost H			O04.5	Rb15	Eltern Decke 2	
;I04.6	Küche Fenster		O04.6	Rb16	Eltern Wand Nordwest
;I04.7	Essen Fenster		O04.7	Rb17	Eltern Wand Nordost	
;I04.8	Essen Ost A			O04.8			Essen Ost LED 1
;I04.9	Essen Ost B			O04.9			Essen Ost LED 2
;I04.A	Essen Ost C			O04.A			Essen Ost LED 3
;I04.B	Essen Ost D			O04.B			Essen Ost LED 4
;I04.C	Essen Ost E			O04.C	Rb18	Treppe OG Wand West
;I04.D	Essen Ost F			O04.D	Rb19	Treppe OG Wand Ost	
;I04.E	Essen Ost G			O04.E	Rb20	Flur OG	Wand Süd 1	
;I04.F	Essen Ost H			O04.F	Rb21	Flur OG	Wand Süd 2	
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00						; Küche Ost LED 1 - Dauer aus
	de	0x03,0x01						; Küche Ost LED 2 - Dauer ein
	de	0x02,0x02						; Küche Ost LED 3 - Dauer aus
	de	0x39,0x03,0x09,0x0e,0x01,0x40	; Küche Ost LED 4 - Garagentor offen blink
	de	0x05,0x54,0x00,0x08				; Eltern Decke 1&2 - Eltern Tür A
	de	0x56,0x54,0x0d,0x08,0x28		; Eltern Decke 1&2 - Eltern NW F
	de	0x56,0x54,0x01,0x09,0x28		; Eltern Decke 1&2 - Eltern NO B
	de	0x56,0x54,0x0d,0x07,0x28		; Eltern Decke 1&2 - Elternbad B
	de	0x04,0x06,0x02,0x08				; Eltern Wand NW - Eltern Tür C
	de	0x04,0x06,0x0c,0x08				; Eltern Wand NW - Eltern NW E
	de	0x04,0x06,0x0e,0x07				; Eltern Wand NW - Elternbad Tür G
	de	0x04,0x07,0x03,0x08				; Eltern Wand NO - Eltern Tür D
	de	0x04,0x07,0x00,0x09				; Eltern Wand NO - Eltern NW E
	de	0x04,0x07,0x0f,0x07				; Eltern Wand NO - Elternbad Tür H
	de	0x02,0x08						; Essen Ost LED 1 - Dauer aus
	de	0x03,0x09						; Essen Ost LED 2 - Dauer ein
	de	0x02,0x0a						; Essen Ost LED 3 - Dauer aus
	de	0x02,0x0b						; Essen Ost LED 4 - Dauer aus
	de	0x05,0xdc,0x03,0x02				; Podest Eltern Ost&West - Treppe EG Ost A
	de	0x05,0xdc,0x00,0x03				; Podest Eltern Ost&West - Treppe EG West F
	de	0x05,0xdc,0x07,0x02				; Podest Eltern Ost&West - Treppe EG Süd A
	de	0x05,0xdc,0x01,0x08				; Podest Eltern Ost&West - Eltern Tür B
	de	0x05,0xdc,0x0b,0x09				; Podest Eltern Ost&West - Flur OG Ost D
	de	0x05,0xdc,0x0d,0x09				; Podest Eltern Ost&West - Flur OG Süd B
	de	0xa5,0xfe,0x0a,0x09,0xe1		; Flur OG Wand Süd 1/2 - Flur OG Ost C - 60min
	de	0xa5,0xfe,0x0c,0x09,0xe1		; Flur OG Wand Süd 1/2 - Flur OG Süd A -60min
	de	0xa5,0xfe,0x03,0x0a,0xe1		; Flur OG Wand Süd 1/2 - Kinderbad D - 60min
	de	0xa5,0xfe,0x03,0x0b,0xe1		; Flur OG Wand Süd 1/2 - Kind 1 Tür D - 60min
	de	0xa5,0xfe,0x07,0x0c,0xe1		; Flur OG Wand Süd 1/2 - Kind 2 Tür H - 60min
	de	0xa5,0xfe,0x0f,0x02,0xe1		; Flur OG Wand Süd 1/2 - Treppe EG West E - 60min
 endif


 if device == 0x05
;Input	Raum Position		Output	Relais	Raum Position
;I05.0	Essen West A		O05.0			Essen West LED 1
;I05.1	Essen West B		O05.1			Essen West LED 2
;I05.2	Essen West C		O05.2			Essen West LED 3
;I05.3	Essen West D		O05.3			Essen West LED 4
;I05.4	Essen West E		O05.4			Essen West LED 9
;I05.5	Essen West F		O05.5			Essen West LED A
;I05.6	Essen West G		O05.6			Essen West LED B
;I05.7	Essen West H		O05.7			Essen West LED C
;I05.8	Essen West I		O05.8	Rb22	Flur – reserve –	
;I05.9	Essen West J		O05.9	Rb23	Kinderbad Spiegel	
;I05.A	Essen West K		O05.A	Rb24	Kinderbad Wand	
;I05.B	Essen West L		O05.B	Rb25	Kinderbad Decke
;I05.C	Essen West M		O05.C	Rb26	Kind 1 Decke	
;I05.D	Essen West N		O05.D	Rb27	Kind 1 Wand Südost	
;I05.E	Essen West O		O05.E	Rb28	Kind 1 Wand Bett	
;I05.F	Essen West P		O05.F	Rb29	Kind 1 Steckdose Ost
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00						; Essen West LED 1 - Dauer aus
	de	0x03,0x01						; Essen West LED 2 - Dauer ein
	de	0x02,0x02						; Essen West LED 3 - Dauer aus
	de	0x02,0x03						; Essen West LED 4 - Dauer aus
	de	0x02,0x04						; Essen West LED 9 - Dauer aus
	de	0xb4,0x05,0x09,0x05,0xe1		; Essen West LED A - Essen West J - Kontrolle Außen Wa Süd - 120min
	de	0xc4,0x06,0x0a,0x05,0xe1		; Essen West LED B - Essen West K - Kontrolle Außen Wa Südterrasse - 240min
	de	0xc4,0x07,0x0b,0x05,0xe1		; Essen West LED C - Essen West L - Kontrolle Außen St Südterrasse - 240min
	de	0x02,0x08						; Flur – reserve – Dauer aus
	de	0xa4,0x09,0x00,0x0a,0xe1		; Kinderbad Spiegel - Kinderbad Tür A - 60min
	de	0xa4,0x0a,0x01,0x0a,0xe1		; Kinderbad Wand    - Kinderbad Tür B - 60min
	de	0xa4,0x0b,0x02,0x0a,0xe1		; Kinderbad Decke   - Kinderbad Tür C - 60min
	de	0x04,0x0c,0x00,0x0b				; Kind 1 Decke - Kind 1 Tür A
	de	0x04,0x0c,0x08,0x0b				; Kind 1 Decke - Kind 1 Bett E
	de	0x02,0x0d						; Kind 1 Wand Südost - Dauer aus
	de	0xc4,0x0e,0x01,0x0b,0xe1		; Kind 1 Wand Bett - Kind 1 Tür B - 240min
	de	0xc4,0x0e,0x09,0x0b,0xe1		; Kind 1 Wand Bett - Kind 1 Tür B - 240min
	de	0xc4,0x0f,0x02,0x0b,0xe1		; Kind 1 Steckdoese Ost - Kind 1 Tür C - 240min
	de	0xc4,0x0f,0x0a,0x0b,0xe1		; Kind 1 Steckdoese Ost - Kind 1 Tür C - 240min

 endif
 

 if device == 0x06
;Input	Raum Position		Output	Relais	Raum Position
;I06.0	– reserve –			O06.0			Wohnen Süd LED 1
;I06.1	– reserve –			O06.1			Wohnen Süd LED 2
;I06.2	– reserve –			O06.2			Wohnen Süd LED 2
;I06.3	– reserve –			O06.3			Wohnen Süd LED 4
;I06.4	– reserve –			O06.4	Rb30	Kind 1 – reserve –	
;I06.5	– reserve –			O06.5	Rc01	Kind 2 Decke	
;I06.6	– reserve –			O06.6	Rc02	Kind 2 Wand Südwest	
;I06.7	– reserve –			O06.7	Rc03	Kind 2 Wand Bett	
;I06.8	Wohnen Nord A		O06.8			Wohnen Nord LED 1
;I06.9	Wohnen Nord B		O06.9			Wohnen Nord LED 2
;I06.A	Wohnen Nord C		O06.A			Wohnen Nord LED 3
;I06.B	Wohnen Nord D		O06.B			Wohnen Nord LED 4
;I06.C	Wohnen Nord E		O06.C	Rc04	Kind 2 Steckdose West
;I06.D	Wohnen Nord F		O06.D	Rc05	Kind 2 – reserve –	
;I06.E	Wohnen Nord G		O06.E	Rc06	Kind 3 Downlights 1	
;I06.F	Wohnen Nord H		O06.F	Rc07	Kind 3 Downlights 2
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00						; Wohnen Süd LED 1 - aus
	de	0x03,0x01						; Wohnen Süd LED 2 - ein
	de	0x02,0x02						; Wohnen Süd LED 3 - aus
	de	0x02,0x03						; Wohnen Süd LED 4 - aus
	de	0x02,0x04						; Kind 1 – reserve – aus
	de	0x04,0x05,0x04,0x0c				; Kind 2 Decke - Kind2 Tür E
	de	0x04,0x05,0x08,0x0c				; Kind 2 Decke - Kind2 Bett E
	de	0x04,0x05,0x0d,0x0c				; Kind 2 Decke - Kind2 Bett J
	de	0x02,0x06						; Kind 2 Wand Südwest – aus
	de	0x04,0x07,0x05,0x0c				; Kind 2 Wand Bett - Kind2 Tür G
	de	0x04,0x07,0x09,0x0c				; Kind 2 Wand Bett - Kind2 Bett G
	de	0x04,0x07,0x0e,0x0c				; Kind 2 Wand Bett - Kind2 Bett L
	de	0x02,0x08						; Wohnen Nord LED 1 - aus
	de	0x03,0x09						; Wohnen Nord LED 2 - ein
	de	0xc4,0x0a,0x0a,0x06,0xe1		; Wohnen Nord LED 3 - Wohnen Nord C - Kontrolle Außen Wa Nordterrasse - 240min
	de	0xc4,0x0b,0x0b,0x06,0xe1		; Wohnen Nord LED 4 - Wohnen Nord D - Kontrolle Außen St Nordterrasse - 240min
	de	0xc4,0x0c,0x06,0x0c,0xe1		; Kind 2 Steckdose West - Kind2 Tür F
	de	0xc4,0x0c,0x0a,0x0c,0xe1		; Kind 2 Steckdose West - Kind2 Bett F
	de	0xc4,0x0c,0x0f,0x0c,0xe1		; Kind 2 Steckdose West - Kind2 Bett Ks
	de	0x02,0x0d						; Kind 2 – reserve – aus
	de	0x04,0x0e,0x04,0x0d				; Kind 3 Downlights 1
	de	0x04,0x0e,0x0c,0x0d				; Kind 3 Downlights 1
	de	0x04,0x0f,0x05,0x0d				; Kind 3 Downlights 2
	de	0x04,0x0f,0x0d,0x0d				; Kind 3 Downlights 2
 endif
 

 if device == 0x07
;Input	Raum Position		Output	Relais	Raum Position
;I07.0	Wohnen Fenster Süd	O07.0	Rc08	Kind 3	Downlights 3	
;I07.1	Wohnen Fenster Nord	O07.1	Rc09	Kind 3 	Wand Bett	
;I07.2	Elternbad Fenster	O07.2	Rc10	Kind 3	– reserve –	
;I07.3	Arbeiten Fenster	O07.3	Rc11	Abstellkammer Decke
;I07.4	Garderobe Fenster	O07.4	Rc12	untere Bühne Decke
;I07.5	Eltern Fenster		O07.5	Rc13	obere Bühne Decke
;I07.6	Eltern Fenster		O07.6	Rc14	Aussen	Eingang
;I07.7	Schrank Tür A		O07.7	Rc15	Aussen	Wand Süd
;I07.8	Elternbad Tür A		O07.8			Elternbad	Tür LED	2	
;I07.9	Elternbad Tür B		O07.9	Rc16	Südterrasse	Wand Süd	
;I07.A	Elternbad Tür C		O07.A	Rc17	Südterrasse Steckdose
;I07.B	Elternbad Tür D		O07.B	Rc18	Nordterrase	Wand N/O	
;I07.C	Elternbad Tür E		O07.C	Rc19	Nordterrase	Steckdose	
;I07.D	Elternbad Tür F		O07.D	Rc20	Aussen	Nord
;I07.E	Elternbad Tür G		O07.E	Rc21	Aussen	Nordost
;I07.F	Elternbad Tür H	 	O07.F	Rc22	Aussen	Garage
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x04,0x00,0x06,0x0d
	de	0x04,0x00,0x0e,0x0d
	de	0x04,0x01,0x07,0x0d
	de	0x04,0x01,0x0f,0x0d
	de	0x02,0x02
	de	0x04,0x03,0x00,0x0e
	de	0x04,0x04,0x01,0x0e
	de	0x04,0x05,0x02,0x0e
	de	0xb4,0x06,0x09,0x03,0xe1		; Außen Wa Eingang - Windfang Tür D - 120min
	de	0xb4,0x07,0x09,0x05,0xe1		; Außen Wa Süd - Essen West J - 120min
	de	0x03,0x08						; Elternbad	Tür LED	2 - ein
	de	0xc4,0x09,0x0a,0x05,0xe1		; Außen Wa Südterrasse - Essen West K - 240min
	de	0xc4,0x0a,0x0b,0x05,0xe1		; Außen St Südterrasse - Essen West L - 240min
	de	0xc4,0x0b,0x0a,0x06,0xe1		; Außen Wa Nordterrasse - Wohnen Nord C - 240min
	de	0xc4,0x0c,0x0b,0x06,0xe1		; Außen St Nordterrasse - Wohnen Nord D - 240min
	de	0xb4,0x0d,0x08,0x03,0xe1		; Außen Wa Nord - Windfang C - 120min
	de	0xb4,0x0e,0x08,0x03,0xe1		; Außen Wa NO - Windfang C - 120min
	de	0x02,0x0f						; Außen Garage
 endif
 

 if device == 0x08
;Input	Raum Position		Output	Relais	Raum Position
;I08.0	Eltern Tür A		O08.0			Eltern Tür LED 1
;I08.1	Eltern Tür B		O08.1			Eltern Tür LED 2
;I08.2	Eltern Tür C		O08.2			Eltern Tür LED 3
;I08.3	Eltern Tür D		O08.3			Eltern Tür LED 4
;I08.4	Eltern Tür E		O08.4			Eltern Tür LED 5
;I08.5	Eltern Tür F		O08.5			Eltern Tür LED 6
;I08.6	Eltern Tür G		O08.6			Eltern Tür LED 7
;I08.7	Eltern Tür H		O08.7			Eltern Tür LED 8
;I08.8	Eltern Bett NW A	O08.8			Eltern Bett NW LED 1
;I08.9	Eltern Bett NW B	O08.9			Eltern Bett NW LED 2
;I08.A	Eltern Bett NW C	O08.A			Eltern Bett NW LED 3
;I08.B	Eltern Bett NW D	O08.B			Eltern Bett NW LED 4
;I08.C	Eltern Bett NW E	O08.C	Rc23	Garage	Decke 1
;I08.D	Eltern Bett NW F	O08.D	Rc24	Garage	Decke 2
;I08.E	Eltern Bett NW G	O08.E	Rc25	Zysterne Pumpe	
;I08.F	Eltern Bett NW H	O08.F	Rc26	– reserve –	
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00						; Eltern Tür LED 1 - Dauer aus
	de	0x03,0x01						; Eltern Tür LED 2 - Dauer ein
	de	0x02,0x02						; Eltern Tür LED 3 - Dauer aus
	de	0x02,0x03						; Eltern Tür LED 4 - Dauer aus
	de	0x02,0x04						; Eltern Tür LED 5 - Dauer aus
	de	0x02,0x05						; Eltern Tür LED 6 - Dauer aus
	de	0x02,0x06						; Eltern Tür LED 7 - Dauer aus
	de	0x02,0x07						; Eltern Tür LED 8 - Dauer aus
	de	0x02,0x08						; Eltern Bett NW LED 1 - Dauer aus
	de	0x03,0x09						; Eltern Bett NW LED 2 - Dauer ein
	de	0x02,0x0a						; Eltern Bett NW LED 3 - Dauer aus
	de	0x02,0x0b						; Eltern Bett NW LED 4 _ Dauer aus
	de	0xb4,0x0c,0x05,0x0e,0x96		; Garage Decke 1 - Garage C - 80min
	de	0x74,0x0c,0x04,0x0e,0x96		; Garage Decke 1 - Garage B - 5min
	de	0x74,0x0c,0x06,0x03,0x96		; Garage Decke 1 - Windfang Tür B - 5min
	de	0x04,0x0d,0x05,0x0e				; Garage Decke 2 - Garage C - toggle
	de	0x74,0x0d,0x04,0x0e,0x81		; Garage Decke 2 - Garage B - 4.5min
	de	0x74,0x0d,0x06,0x03,0x81		; Garage Decke 2 - Windfang Tür B - 4.5min
	de	0x64,0x0d,0x0A,0x0e,0x96		; Garage Decke 2 - Antrieb Licht - 2.5min
	de	0xb4,0x0e,0x06,0x0e,0xa9		; Pumpe Zysterne - Garage D (oben) - 90min
	de	0x02,0x0f						; Rc26	– reserve –	 -  Dauer aus
 endif
 

 if device == 0x09
;Input	Raum Position		Output	Relais	Raum Position
;I09.0	Eltern Bett NO A	O09.0			Eltern Bett NO LED 1
;I09.1	Eltern Bett NO B	O09.1			Eltern Bett NO LED 2
;I09.2	Eltern Bett NO C	O09.2			Eltern Bett NO LED 3
;I09.3	Eltern Bett NO D	O09.3			Eltern Bett NO LED 4
;I09.4	Eltern Bett NO E	O09.4	Rc27	– reserve –	
;I09.5	Eltern Bett NO F	O09.5	Rc28	– reserve –	
;I09.6	Eltern Bett NO G	O09.6	Rc29	– reserve –	
;I09.7	Eltern Bett NO H	O09.7	Rc30	– reserve –	
;I09.8	Treppe OG Ost A		O09.8	Oc01	Garagentor Up/Stop/Down			
;I09.9	Treppe OG Ost B		O09.9	Oc02	Garagentor Reversieren		
;I09.A	Treppe OG Ost C		O09.A			
;I09.B	Treppe OG Ost D		O09.B				
;I09.C	Flur OG Süd A		O09.C	Rd01	J Küche	Ost Power		
;I09.D	Flur OG Süd B		O09.D	Re01	J Küche	Ost D/U		
;I09.E	Flur OG Süd C		O09.E	Rd02	J Küche	Süd Power		
;I09.F	Flur OG Süd D		O09.F	Re02	J Küche	Süd D/U		
; prescale+mode | output | input | device1 | delay(opt) | device2/delay2
	de	0x02,0x00						; Eltern Bett NO LED 1 - Dauer aus
	de	0x03,0x01						; Eltern Bett NO LED 2 - Dauer ein
	de	0x02,0x02						; Eltern Bett NO LED 3 - Dauer aus
	de	0x02,0x03						; Eltern Bett NO LED 4 - Dauer aus
	de	0x02,0x04						; Rc27	– reserve – - Dauer aus
	de	0x02,0x05						; Rc28	– reserve – - Dauer aus
	de	0x02,0x06						; Rc29	– reserve – - Dauer aus
	de	0x02,0x07						; Rc30	– reserve – - Dauer aus
	de	0x01,0x08,0x05,0x04				; Garagentor U/S/D - Küche Ost H
	de	0x01,0x08,0x03,0x0e				; Garagentor U/S/D - Garage A
	de	0x01,0x08,0x07,0x0e				; Garagentor U/S/D - Schlüsselschalter
	de	0x09,0x09,0x08,0x0e,0x01,0x0d	; Garagentor Lichtschranke
	de	0x02,0x0a						; Dauer aus
	de	0x02,0x0b						; Dauer aus
	de	0x5e,0xdc,0x98,0x04,0x81,0x04	; J Küche O
	de	0x5e,0xdc,0xfe,0x03,0x81,0x03	; J Küche O
	de	0x5e,0xdc,0xed,0x02,0x81,0x02	; J Küche O
 	de	0x5e,0xdc,0x76,0x09,0x81,0x09	; J Küche O - Eltern Bett NO GH
 	de	0x5e,0xdc,0x0e,0x0e,0x81,0xf0	; J Küche O - Wind auf
	de	0x5e,0xfe,0x98,0x04,0x81,0x04	; J Küche S
	de	0x5e,0xfe,0x10,0x04,0x81,0x04	; J Küche S
	de	0x5e,0xfe,0xed,0x02,0x81,0x02	; J Küche S
 	de	0x5e,0xfe,0x76,0x09,0x81,0x09	; J Küche S - Eltern Bett NO GH
 	de	0x5e,0xfe,0x0e,0x0e,0x81,0xf0	; J Küche S - Wind auf
 endif
 

 if device == 0x0a
;Input	Raum Position		Output	Relais	Raum Position
;I0A.0	Kinderbad Tür A		O0A.0			Kinderbad Tür LED 1
;I0A.1	Kinderbad Tür B		O0A.1			Kinderbad Tür LED 2
;I0A.2	Kinderbad Tür C		O0A.2			Kinderbad Tür LED 3
;I0A.3	Kinderbad Tür D		O0A.3			Kinderbad Tür LED 4
;I0A.4	Kinderbad Tür E		O0A.4	Rd03	J Essen Süd Power	
;I0A.5	Kinderbad Tür F		O0A.5	Re03	J Essen Süd D/U	
;I0A.6	Kinderbad Tür G		O0A.6	Rd04	J Essen SW Power	
;I0A.7	Kinderbad Tür H		O0A.7	Re04	J Essen SW D/U	
;I0A.8	Kinderbad Fenster	O0A.8	Rd05	J Essen NW Power	
;I0A.9	Kind1 Fenster O		O0A.9	Re05	J Essen NW D/U	
;I0A.A	Kind1 Fenster S		O0A.A	Rd06	J Wohnen SO Power	
;I0A.B	Kind2 Fenster S		O0A.B	Re06	J Wohnen SO D/U	
;I0A.C	Kind2 Fenster W		O0A.C	Rd07	J Wohnen SW Power	
;I0A.D	Kind3 Fenster S		O0A.D	Re07	J Wohnen SW D/U	
;I0A.E	Kind3 Fenster W		O0A.E	Rd08	J Wohnen NW D/U	
;I0A.F	Fenster Sabotage	O0A.F	Re08	J Wohnen NW Power	
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00
	de	0x03,0x01
	de	0x02,0x02
	de	0x02,0x03
	de	0x5e,0x54,0xba,0x04,0x81,0x04	; J Essen S
	de	0x5e,0x54,0x32,0x05,0x81,0x05	; J Essen S
	de	0x5e,0x54,0xed,0x02,0x81,0x02	; J Essen S
 	de	0x5e,0x54,0x76,0x09,0x81,0x09	; J Essen S - Eltern Bett NO GH
 	de	0x5e,0x54,0x0e,0x0e,0x81,0xf0	; J Essen S - Wind auf*
	de	0x5e,0x76,0xba,0x04,0x81,0x04	; J Essen SW
	de	0x5e,0x76,0xed,0x02,0x81,0x02	; J Essen SW
	de	0x5e,0x76,0x10,0x05,0x81,0x05	; J Essen SW
 	de	0x5e,0x76,0x76,0x09,0x81,0x09	; J Essen SW - Eltern Bett NO GH
 	de	0x5e,0x76,0x0e,0x0e,0x81,0xf0	; J Essen SW - Wind auf*
	de	0x5e,0x98,0xba,0x04,0x81,0x04	; J Essen NW
	de	0x5e,0x98,0x54,0x05,0x81,0x05	; J Essen NW
	de	0x5e,0x98,0xed,0x02,0x81,0x02	; J Essen NW
 	de	0x5e,0x98,0x76,0x09,0x81,0x09	; J Essen NW - Eltern Bett NO GH
 	de	0x5e,0x98,0x0e,0x0e,0x81,0xf0	; J Essen NW - Wind auf*
	de	0x5e,0xba,0x10,0x0f,0x81,0x0f	; J Wohnen SO
	de	0x5e,0xba,0xed,0x02,0x81,0x02	; J Wohnen SO
	de	0x5e,0xba,0x76,0x0f,0x81,0x0f	; J Wohnen SO
 	de	0x5e,0xba,0x76,0x09,0x81,0x09	; J Wohnen SO - Eltern Bett NO GH
 	de	0x5e,0xba,0x0e,0x0e,0x81,0xf0	; J Wohnen SO - Wind auf*
	de	0x5e,0xdc,0x54,0x0f,0x81,0x0f	; J Wohnen SW
	de	0x5e,0xdc,0x76,0x0f,0x81,0x0f	; J Wohnen SW
	de	0x5e,0xdc,0xed,0x02,0x81,0x02	; J Wohnen SW
 	de	0x5e,0xdc,0x76,0x09,0x81,0x09	; J Wohnen SW - Eltern Bett NO GH
 	de	0x5e,0xdc,0x0e,0x0e,0x81,0xf0	; J Wohnen SW - Wind auf*
	de	0x5e,0xfe,0x76,0x0f,0x81,0x0f	; J Wohnen NW
	de	0x5e,0xfe,0xdc,0x06,0x81,0x06	; J Wohnen NW
	de	0x5e,0xfe,0xed,0x02,0x81,0x02	; J Wohnen NW
 	de	0x5e,0xfe,0x76,0x09,0x81,0x09	; J Wohnen NW - Eltern Bett NO GH
 	de	0x5e,0xfe,0x0e,0x0e,0x81,0xf0	; J Wohnen NW - Wind auf*
 endif


 if device == 0x0b
;Input	Raum Position		Output	Relais	Raum Position
;I0B.0	Kind1 Tür A			O0B.0			Kind1 Tür LED 1
;I0B.1	Kind1 Tür B			O0B.1			Kind1 Tür LED 2
;I0B.2	Kind1 Tür C			O0B.2			Kind1 Tür LED 3
;I0B.3	Kind1 Tür D			O0B.3			Kind1 Tür LED 4
;I0B.4	Kind1 Tür E			O0B.4	Rd09	J Wohnen Nord Power	
;I0B.5	Kind1 Tür F			O0B.5	Re09	J Wohnen Nord D/U	
;I0B.6	Kind1 Tür G			O0B.6	Rd10	J Elternbad Power	
;I0B.7	Kind1 Tür H			O0B.7	Re10	J Elternbad D/U	
;I0B.8	Kind1 Bett E		O0B.8			Kind1 Bett LED 1
;I0B.9	Kind1 Bett F		O0B.9			Kind1 Bett LED 2
;I0B.A	Kind1 Bett G		O0B.A			Kind1 Bett LED 3
;I0B.B	Kind1 Bett H		O0B.B			Kind1 Bett LED 4
;I0B.C	Kind1 Bett I		O0B.C	Rd11	J Eltern Power	
;I0B.D	Kind1 Bett J		O0B.D	Re11	J Eltern D/U	
;I0B.E	Kind1 Bett K		O0B.E	Rd12	J Kinderbad Power	
;I0B.F	Kind1 Bett L		O0B.F	Re12	J Kinderbad D/U	
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x02,0x00
	de	0x03,0x01
	de	0x02,0x02
	de	0x02,0x03
	de	0x5e,0x54,0x76,0x0f,0x81,0x0f	; J Wohnen Nord
	de	0x5e,0x54,0xfe,0x06,0x81,0x06	; J Wohnen Nord
	de	0x5e,0x54,0xed,0x02,0x81,0x02	; J Wohnen Nord
 	de	0x5e,0x54,0x76,0x09,0x81,0x09	; J Wohnen Nord - Eltern Bett NO GH
 	de	0x5e,0x54,0x0e,0x0e,0x81,0xf0	; J Wohnen Nord - Wind auf
	de	0x5e,0x76,0x98,0x07,0x81,0x07	; J Elternbad
	de	0x5e,0x76,0x76,0x08,0x81,0x08	; J Elternbad
 	de	0x5e,0x76,0x76,0x09,0x81,0x09	; J Elternbad - Eltern Bett NO GH
 	de	0x5e,0x76,0x0e,0x0e,0x81,0xf0	; J Elternbad - Wind auf
	de	0x02,0x08
	de	0x03,0x09
	de	0x02,0x0a
	de	0x02,0x0b
	de	0x5e,0xdc,0xba,0x07,0x81,0x07	; J Eltern
	de	0x5e,0xdc,0x54,0x08,0x81,0x08	; J Eltern
	de	0x5e,0xdc,0xfe,0x08,0x81,0x08	; J Eltern
	de	0x5e,0xdc,0x32,0x09,0x81,0x09	; J Eltern
 	de	0x5e,0xdc,0x76,0x09,0x81,0x09	; J Eltern - Eltern Bett NO GH
 	de	0x5e,0xdc,0x0e,0x0e,0x81,0xf0	; J Eltern - Wind auf
	de	0x5e,0xfe,0x54,0x0a,0x81,0x0a	; J Kinderbad
 	de	0x5e,0xfe,0x76,0x09,0x81,0x09	; J Kinderbad - Eltern Bett NO GH
 	de	0x5e,0xfe,0x0e,0x0e,0x81,0xf0	; J Kinderbad - Wind auf

 endif
 

 if device == 0x0c
;Input	Raum Position		Output	Relais	Raum Position
;I0C.0	Kind2 Tür&Bett A	O0C.0			Kind2 Tür LED 1
;I0C.1	Kind2 Tür&Bett B	O0C.1			Kind2 Tür LED 2
;I0C.2	Kind2 Tür&Bett C	O0C.2			Kind2 Tür LED 3
;I0C.3	Kind2 Tür&Bett D	O0C.3			Kind2 Tür LED 4
;I0C.4	Kind2 Tür E			O0C.4	Rd13	J Kind1	Ost Power	
;I0C.5	Kind2 Tür F			O0C.5	Re13	J Kind1	Ost D/U	
;I0C.6	Kind2 Tür G			O0C.6	Rd14	J Kind1	Süd Power	
;I0C.7	Kind2 Tür H			O0C.7	Re14	J Kind1	Süd D/U	
;I0C.8	Kind2 Bett E		O0C.8			Kind2 Bett LED 1
;I0C.9	Kind2 Bett F		O0C.9			Kind2 Bett LED 2
;I0C.A	Kind2 Bett G		O0C.A			Kind2 Bett LED 3
;I0C.B	Kind2 Bett H		O0C.B			Kind2 Bett LED 4
;I0C.C	Kind2 Bett I		O0C.C	Rd15	J Kind2	Süd Power	
;I0C.D	Kind2 Bett J		O0C.D	Re15	J Kind2	Süd D/U	
;I0C.E	Kind2 Bett K		O0C.E	Rd16	J Kind2	West Power	
;I0C.F	Kind2 Bett L		O0C.F	Re16	J Kind2	West D/U	
; prescale+mode | output | input | device1 | delay(opt) | device2
 	de	0x02,0x00
 	de	0x03,0x01
 	de	0x02,0x02
 	de	0x02,0x03
 	de	0x5e,0x54,0x54,0x0b,0x81,0x0b	; J Kind1 Ost
 	de	0x5e,0x54,0xdc,0x0b,0x81,0x0b	; J Kind1 Ost
 	de	0x5e,0x54,0x76,0x09,0x81,0x09	; J Kind1 Ost - Eltern Bett NO GH
 	de	0x5e,0x54,0x0e,0x0e,0x81,0xf0	; J Kind1 Ost - Wind auf
 	de	0x5e,0x76,0x76,0x0b,0x81,0x0b	; J Kind1 Süd
 	de	0x5e,0x76,0xfe,0x0b,0x81,0x0b	; J Kind1 Süd
 	de	0x5e,0x76,0x76,0x09,0x81,0x09	; J Kind1 Süd - Eltern Bett NO GH
 	de	0x5e,0x76,0x0e,0x0e,0x81,0xf0	; J Kind1 Süd - Wind auf
 	de	0x02,0x08
 	de	0x03,0x09
 	de	0x02,0x0a
 	de	0x02,0x0b
 	de	0x5e,0xdc,0x10,0x0c,0x81,0x0c	; J Kind2 Süd
 	de	0x5e,0xdc,0x76,0x09,0x81,0x09	; J Kind2 Süd - Eltern Bett NO GH
 	de	0x5e,0xdc,0x0e,0x0e,0x81,0xf0	; J Kind2 Süd - Wind auf
 	de	0x5e,0xfe,0x32,0x0c,0x81,0x0c	; J Kind2 West
 	de	0x5e,0xfe,0x76,0x09,0x81,0x09	; J Kind2 West - Eltern Bett NO GH
 	de	0x5e,0xfe,0x0e,0x0e,0x81,0xf0	; J Kind2 West - Wind auf
 endif
 

 if device == 0x0d
;Input	Raum Position		Output	Relais	Raum Position
;I0D.0	Kind3 Tür A			O0D.0			Kind3 Tür LED 1
;I0D.1	Kind3 Tür B			O0D.1			Kind3 Tür LED 2
;I0D.2	Kind3 Tür C			O0D.2			Kind3 Tür LED 3
;I0D.3	Kind3 Tür D			O0D.3			Kind3 Tür LED 4
;I0D.4	Kind3 Tür E			O0D.4	Rd17	J Kind3	Süd Power	
;I0D.5	Kind3 Tür F			O0D.5	Re17	J Kind3	Süd D/U	
;I0D.6	Kind3 Tür G			O0D.6	Re18	J Kind3	West Power	
;I0D.7	Kind3 Tür H			O0D.7	Re18	J Kind3	West D/U	
;I0D.8	Kind3 Bett A		O0D.8			Kind3 Bett LED 1
;I0D.9	Kind3 Bett B		O0D.9			Kind3 Bett LED 2
;I0D.A	Kind3 Bett C		O0D.A			Kind3 Bett LED 3
;I0D.B	Kind3 Bett D		O0D.B			Kind3 Bett LED 4
;I0D.C	Kind3 Bett E		O0D.C	Rd19	Sonnensegel	Power	
;I0D.D	Kind3 Bett F		O0D.D	Re19	Sonnensegel	O/C	
;I0D.E	Kind3 Bett G		O0D.E	Rd20	F Kinderbad	zu	
;I0D.F	Kind3 Bett H		O0D.F	Re20	F Kinderbad	auf	
; prescale+mode | output | input | device1 | delay(opt) | device2
 	de	0x02,0x00
 	de	0x03,0x01
 	de	0x02,0x02
 	de	0x02,0x03
 	de	0x5e,0x54,0x10,0x0d,0x81,0x0d	; J Kind3 Süd
 	de	0x5e,0x54,0x98,0x0d,0x81,0x0d	; J Kind3 Süd
 	de	0x5e,0x54,0x76,0x09,0x81,0x09	; J Kind3 Süd - Eltern Bett NO GH
 	de	0x5e,0x54,0x0e,0x0e,0x81,0xf0	; J Kind3 Süd - Wind auf
 	de	0x5e,0x76,0x32,0x0d,0x81,0x0d	; J Kind3 West
 	de	0x5e,0x76,0xba,0x0d,0x81,0x0d	; J Kind3 West
 	de	0x5e,0x76,0x76,0x09,0x81,0x09	; J Kind3 West - Eltern Bett NO GH
 	de	0x5e,0x76,0x0e,0x0e,0x81,0xf0	; J Kind3 West - Wind auf
 	de	0x02,0x08
 	de	0x03,0x09
 	de	0x02,0x0a
 	de	0x02,0x0b
 	de	0x5d,0xdc,0xef,0x05,0x81,0x05	; J Sonnensegel - Esszimmer P/O
 	de	0x5d,0xdc,0xe0,0xf0,0x81,0x0e	; J Sonnensegel - Wind zu
;	de	0x5f,0xef,0x76,0x0a,0x81,0x0a	; F Kinderbad - Tür Kinderbad G/H
	de	0x5f,0xef,0x98,0x08,0x81,0x08	; F Kinderbad
	de	0x5f,0xef,0xd0,0xf0,0x81,0x0e	; F Kinderbad - Regen zu
	de	0x5f,0xef,0xe0,0xf0,0x81,0x0e	; F Kinderbad - Wind zu
 endif
 

 if device == 0x0e
;Input	Raum Position		Output	Relais	Raum Position
;I0E.0	Abstellk. Tür A		O0E.0	Rd21	F Flur OG SO zu
;I0E.1	untere Bühne Tür A	O0E.1	Re21	F Flur OG SO auf
;I0E.2	obere Bühne Tür A	O0E.2	Rd22	F Flur OG S zu
;I0E.3	Garage Tür A		O0E.3	Rd23	F Flur OG S auf
;I0E.4	Garage Tür B		O0E.4	Rd23	F Flur OG SW zu
;I0E.5	Garage Tür C		O0E.5	Re23	F Flur OG SW auf
;I0E.6	Garage Tür D		O0E.6			
;I0E.7	Garage Schlüssel	O0E.7			
;I0E.8	Garage Lichtschr.	O0E.8	Garage EinfahrLED		
;I0E.9	Garage Endposition	O0E.9			
;I0E.A	Garage Antriebsl.	O0E.A			
;I0E.B	Wächter Sonne		O0E.B			
;I0E.C	Wächter Dämmerung	O0E.C			
;I0E.D	Wächter Regen		O0E.D			
;I0E.E	Wächter Wind		O0E.E			
;I0E.F	Wächter Frost		O0E.F			
; prescale+mode | output | input | device1 | delay(opt) | device2
;	de	0x5f,0x01,0xa9,0x0c,0x81,0x0c
;	de	0x5f,0x23,0xa9,0x0c,0x81,0x0c
;	de	0x5f,0x45,0xa9,0x0c,0x81,0x0c
;	de	0x5f,0x01,0xfe,0x09,0x81,0x09
;	de	0x5f,0x23,0xfe,0x09,0x81,0x09
;	de	0x5f,0x45,0xfe,0x09,0x81,0x09
	de	0x5f,0x01,0xba,0x08,0x81,0x08	; F Flur OG SO
	de	0x5f,0x01,0xd0,0xf0,0x81,0x0e	; F Flur OG SO - Regen zu
	de	0x5f,0x01,0xe0,0xf0,0x81,0x0e	; F Flur OG SO - Wind zu
	de	0x5f,0x23,0xba,0x08,0x81,0x08	; F Flur OG S
	de	0x5f,0x23,0xd0,0xf0,0x81,0x0e	; F Flur OG S - Regen zu
	de	0x5f,0x23,0xe0,0xf0,0x81,0x0e	; F Flur OG S - Wind zu
	de	0x5f,0x45,0xba,0x08,0x81,0x08	; F Flur OG SW
	de	0x5f,0x45,0xd0,0xf0,0x81,0x0e	; F Flur OG SW - Regen zu
	de	0x5f,0x45,0xe0,0xf0,0x81,0x0e	; F Flur OG SW - Wind zu
	de	0x02,0x06
	de	0x02,0x07
	de	0x49,0x08,0x08,0x0e,0x01,0x0d	; Garage EinfahrLED - Garage Lichtschranke
	de	0x02,0x09
	de	0x02,0x0a
	de	0x02,0x0b
	de	0x02,0x0c
	de	0x02,0x0d
	de	0x02,0x0e
	de	0x02,0x0f
 endif
 

 if device == 0x0f
;Input	Raum Position		Output	Relais	Raum Position
;I0F.0	Wohnen Süd A		O0F.0			Wohnen Süd LED 1
;I0F.1	Wohnen Süd B		O0F.1			Wohnen Süd LED 2
;I0F.2	Wohnen Süd C		O0F.2			Wohnen Süd LED 2
;I0F.3	Wohnen Süd D		O0F.3			Wohnen Süd LED 4
;I0F.4	Wohnen Süd E		O0F.4			Wohnen Süd LED 9
;I0F.5	Wohnen Süd F		O0F.5			Wohnen Süd LED A
;I0F.6	Wohnen Süd G		O0F.6			Wohnen Süd LED B
;I0F.7	Wohnen Süd H		O0F.7			Wohnen Süd LED C	
;I0F.8	Wohnen Süd I		O0F.8
;I0F.9	Wohnen Süd J		O0F.9
;I0F.A	Wohnen Süd K		O0F.A
;I0F.B	Wohnen Süd L		O0F.B
;I0F.C	Wohnen Süd M		O0F.C
;I0F.D	Wohnen Süd N		O0F.D
;I0F.E	Wohnen Süd O		O0F.E
;I0F.F	Wohnen Süd P		O0F.F
; prescale+mode | output | input | device1 | delay(opt) | device2
 	de	0x02,0x00
 	de	0x03,0x01
 	de	0x02,0x02
 	de	0x02,0x03
 	de	0x02,0x04
 	de	0x02,0x05
 	de	0x02,0x06
 	de	0x02,0x07
 endif



; mode 0 - 1 exit
; mode 1 - 4 passthrough
; mode 2 - 2 always off
; mode 3 - 2 always on
; mode 4 - 4 toggle light
; mode 5 - 4 light toogle dual outputs
; mode 6 - 5 two stage light (output1: 1st stage output1+2 2nd stage)
; mode 7 - 1 nop
; mode 8 - 5 retriggerable timer
; mode 9 - 5 blinker
; mode a - 1 nop
; mode b - 1 nop
; mode c - 1 nop
; mode d - 1 nop
; mode e - 6 blind (output1: on/off output2: up/down
; mode f - 6 window (output1: up output2: down)

 if device == 0x4d
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x04,0x00,0x0c,0x05				; Essen Steckdose Nord - Essen West M
	de	0x02,0x01						; Essen – reserve – - Dauer aus
	de	0x56,0x32,0x02,0x0f,0x28		; Wohnen DL 1/2 - Wohnen Süd B
	de	0x56,0x32,0x07,0x05,0x28		; Wohnen DL 1/2 - Essen West H
	de	0x04,0x04,0x03,0x0f				; Wohnen Steckdose West - Wohnen Süd D
	de	0x04,0x04,0x08,0x06				; Wohnen Steckdose West - Wohnen Nord A
	de  0x04,0x04,0x06,0x05				; Wohnen Steckdose West - Essen West G
	de	0x56,0x5a,0x00,0x4d,0x28		; Wohnen Wand Nord/Ost-Nord - Wohnen Nord B
	de	0x56,0xa5,0x01,0x4d,0x28		; Wohnen Wand Nord/Ost-Nord - Wohnen Nord B
	de	0x04,0x05,0x02,0x4d				; Wohnen Wand Nord - Wohnen Süd I
	de	0xb4,0x06,0x05,0x0e,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Garage C - 80min
	de	0x74,0x06,0x04,0x0e,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Garage B - 5min
	de	0x74,0x06,0x06,0x03,0x96		; Windfang Tür LED 1 - Garage Decke 1 - Windfang Tür B - 5min
	de	0x03,0x07						; Windfang Tür LED 2 - Dauer ein
	de	0xb4,0x08,0x08,0x03,0xe1		; Windfang Tür LED 3 - Windfang Tür C - Kontrolle Außen NO - 120min
	de	0xb4,0x09,0x09,0x03,0xe1		; Windfang Tür LED 4 - Windfang Tür D - Kontrolle Außen Eingang - 120min
    de  0x04,0x0a,0x03,0x4d				; Wohnen Wand Ost-Nord - Wohnen Süd J
    de  0x04,0x0b,0x04,0x4d				; Wohnen Wand Ost-Süd - Wohnen Süd K
	de	0x56,0xed,0x05,0x4d,0x28		; Wohnen Wand Nord/Ost-Nord - Wohnen Nord B
	de	0x56,0xef,0x06,0x4d,0x28		; Wohnen Wand Nord/Ost-Nord - Wohnen Nord B
 endif


 if device == 0x4e
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x04,0x0f,0x00,0x4f
	de	0x04,0x0e,0x01,0x4f
	de	0x04,0x0d,0x02,0x4f
	de	0x04,0x0c,0x03,0x4f
	de	0x04,0x0b,0x04,0x4f
 	de	0x04,0x0a,0x05,0x4f
	de	0x04,0x09,0x06,0x4f
	de	0x04,0x08,0x07,0x4f
	de	0x04,0x07,0x08,0x4f
	de	0x04,0x06,0x09,0x4f
	de	0x04,0x05,0x0a,0x4f
	de	0x04,0x04,0x0b,0x4f
	de	0x04,0x03,0x0c,0x4f
	de	0x04,0x02,0x0d,0x4f
	de	0x04,0x01,0x0e,0x4f
	de	0x04,0x00,0x0f,0x4f
 endif


 if device == 0x4f
; prescale+mode | output | input | device1 | delay(opt) | device2
	de	0x01,0x00,0x00,0x4f
;	de	0x02,0x01
;	de	0x03,0x02
	de	0x58,0x01,0x01,0x4f,0x28
	de	0x59,0x02,0x02,0x4f,0x28
	de	0x54,0x03,0x01,0x4f,0x20
	de	0x04,0x04,0x02,0x4f
	de	0x04,0x05,0x03,0x4f
	de	0x05,0x54,0x04,0x4f
	de	0x55,0x54,0x05,0x4f,0x10
	de	0x56,0x76,0x06,0x4f,0x28
	de	0x5e,0x98,0x89,0x4f,0x81,0x4f
	de	0x5f,0xba,0xab,0x4f,0x81,0x4f
	de	0x54,0x0c,0x0c,0x4f,0x20
	de	0x54,0x0c,0x0d,0x4f,0x10
;	de	0x09,0x0e,0x0e,0x4f,0x01,0x0d
;	de	0x49,0x0f,0x0f,0x4f,0x01,0x0d
 	de	0x5d,0xfe,0xef,0x4f,0x81,0x4f	; J Sonnensegel - Esszimmer P/O
 endif


	de	0x00					; termination
 
 if		($ > 0x21ff )
				error	"Action table is to long" 
 endif	;}