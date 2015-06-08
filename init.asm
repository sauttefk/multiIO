;
;********** initialisation part of code ********************************
initPorts       ;{
 if revision >= 3
                banksel PORTA           ; Init PORTA
                movlw   0x00
                movwf   PORTA

                banksel CMCON0
                movlw   0x07
                movwf   CMCON0

                banksel ANSEL
                movlw   0x00
                movwf   ANSEL

                banksel TRISA
;//             movlw   0xc0
                movlw   0x40            ; #######
                movwf   TRISA           ; RA0:O: O2.7
                                        ; RA1:O: O2.6
                                        ; RA2:O: O2.5
                                        ; RA3:O: O2.4
                                        ; RA4:O: COL8
                                        ; RA5:O: COL9
                                        ; RA6:I: STATUS1
                                        ; RA7:I: STATUS2

                banksel PORTB           ; Init PORTB
                movlw   0x00
                movwf   PORTB

                banksel TRISB
                movlw   0x80
                movwf   TRISB           ; RB0:I: COL2
                                        ; RB1:I: COL3
                                        ; RB2:I: COL4
                                        ; RB3:I: COL5
                                        ; RB4:O: COL6
                                        ; RB5:O: COL7
                                        ; RB6:I: ICSPCLK
                                        ; RB7:I: ICSPDAT

                banksel PORTC           ; Init PORTC
                movlw   0x00
                movwf   PORTC

                banksel LCDCON
                movlw   0x00
                movwf   LCDCON

                banksel TRISC
                movlw   0x80
                movwf   TRISC           ; RC0:O: O1.3
                                        ; RC1:O: O1.2
                                        ; RC2:0: O1.1
                                        ; RC3:O: O1.0
                                        ; RC4:O: DC
                                        ; RC5:O: RS485TE
                                        ; RC6:O: RS485TX
                                        ; RC7:I: RS485RX

                banksel PORTD           ; Init PORTD
                movlw   0x00
                movwf   PORTD

                banksel TRISD
                movlw   0xFF
                movwf   TRISD           ; RD0:I: I1.0
                                        ; RD1:I: I1.1
                                        ; RD2:I: I1.2
                                        ; RD3:I: I1.3
                                        ; RD4:I: I1.4
                                        ; RD5:I: I1.5
                                        ; RD6:I: I1.6
                                        ; RD7:I: I1.7

                banksel PORTE           ; Init PORTE
                movlw   0x00
                movwf   PORTE

                banksel TRISE
                movlw   0x0F
                movwf   TRISE           ; RE0:I: MV1
                                        ; RE1:I: MV2
                                        ; RE2:I: MV3
                                        ; RE3:I: /MCLR
                                        ; RE4:O: O2.3
                                        ; RE5:O: O2.2
                                        ; RE6:O: O2.1
                                        ; RE7:O: O2.0

                banksel PORTF           ; Init PORTF
                movlw   0x00
                movwf   PORTF

                banksel TRISF
                movlw   0x0F
                movwf   TRISF           ; RF0:I: I2.4
                                        ; RF1:I: I2.5
                                        ; RF2:I: I2.6
                                        ; RF3:I: I2.6
                                        ; RF4:O: O1.7
                                        ; RF5:O: O1.6
                                        ; RF6:O: O1.5
                                        ; RF7:O: O1.4

                banksel PORTG           ; Init PORTG
                movlw   0x0F
                movwf   PORTG

                banksel TRISG
                movlw   0x0F
                movwf   TRISG           ; RG0:I: I2.0
                                        ; RG1:I: I2.1
                                        ; RG2:I: I2.2
                                        ; RG3:I: I2.3
                                        ; RG4:O: COL0
                                        ; RG5:O: COL1
 else   ; revision >= 3
                banksel PORTA           ; Init PORTA
                movlw   0x00
                movwf   PORTA

                banksel CMCON0
                movlw   0x07
                movwf   CMCON0

                banksel ANSEL
                movlw   0x00
                movwf   ANSEL

                banksel TRISA
                movlw   0x00
                movwf   TRISA           ; RA0:O: O2.7
                                        ; RA1:O: O2.6
                                        ; RA2:O: O2.5
                                        ; RA3:O: O2.4
                                        ; RA4:O: LED1x
                                        ; RA5:O: LED1y
                                        ; RA6:O: TP1
                                        ; RA7:O: TP2

                banksel PORTB           ; Init PORTB
                movlw   0x00
                movwf   PORTB

                banksel TRISB
                movlw   0xCF
                movwf   TRISB           ; RB0:I: I1.3
                                        ; RB1:I: I1.2
                                        ; RB2:I: I1.1
                                        ; RB3:I: I1.0
                                        ; RB4:O: LED2x
                                        ; RB5:O: LED2y
                                        ; RB6:I: ICSPCLK
                                        ; RB7:I: ICSPDAT

                banksel PORTC           ; Init PORTC
                movlw   0x00
                movwf   PORTC

                banksel LCDCON
                movlw   0x00
                movwf   LCDCON

                banksel TRISC
                movlw   0x90
                movwf   TRISC           ; RC0:O: O1.3
                                        ; RC1:O: O1.2
                                        ; RC2:0: O1.1
                                        ; RC3:O: O1.0
                                        ; RC4:I: n.c.
                                        ; RC5:O: RS485TE
                                        ; RC6:O: RS485TX
                                        ; RC7:I: RS485RX

                banksel PORTD           ; Init PORTD
                movlw   0x00
                movwf   PORTD

                banksel TRISD
                movlw   0xFF
                movwf   TRISD           ; RD0:I: ID0
                                        ; RD1:I: ID1
                                        ; RD2:I: ID2
                                        ; RD3:I: ID3
                                        ; RD4:I: I2.7
                                        ; RD5:I: I2.6
                                        ; RD6:I: I2.5
                                        ; RD7:I: I2.4

                banksel PORTE           ; Init PORTE
                movlw   0x00
                movwf   PORTE

                banksel TRISE
                movlw   0x0F
                movwf   TRISE           ; RE0:I: 1WIRE
                                        ; RE1:I: STATUS2
                                        ; RE2:I: STATUS1
                                        ; RE3:I: /MCLR
                                        ; RE4:O: O2.3
                                        ; RE5:O: O2.2
                                        ; RE6:O: O2.1
                                        ; RE7:O: O2.0

                banksel PORTF           ; Init PORTF
                movlw   0x00
                movwf   PORTF

                banksel TRISF
                movlw   0x0F
                movwf   TRISF           ; RF0:I: I1.7
                                        ; RF1:I: I1.6
                                        ; RF2:I: I1.5
                                        ; RF3:I: I1.4
                                        ; RF4:O: O1.7
                                        ; RF5:O: O1.6
                                        ; RF6:O: O1.5
                                        ; RF7:O: O1.4

                banksel PORTG           ; Init PORTG
                movlw   0x0F
                movwf   PORTG

                banksel TRISG
                movlw   0x0F
                movwf   TRISG           ; RG0:I: I2.3
                                        ; RG1:I: I2.2
                                        ; RG2:I: I2.1
                                        ; RG3:I: I2.0
                                        ; RG4:O: LED3x
                                        ; RG5:O: LED3y
 endif  ; revision >= 3
                return  ;}

clearRam        ;{
;  clearRam - Reset all general purpose ram to 0s
;  Note ! does not clear watchdog, add CLRWDT where appropiate if enabled
                bcf     STATUS,RP0
                bcf     STATUS,RP1
                bcf     STATUS,IRP      ; select bank0/1 ( with indirect adressing )
                movlw   0x20            ; start ram bank0
                movwf   FSR
clearBank0      clrf    INDF            ; Clear a register pointed to be FSR
                incf    FSR,F
                movlw   0x80            ; Test if at top of memory bank0
                subwf   FSR,W
                bnz     clearBank0      ; Loop until all cleared

                movlw   0xa0            ; start ram bank1
                movwf   FSR
clearBank1      clrf    INDF            ; Clear a register pointed to be FSR
                incf    FSR,F
                movlw   0xf0            ; Test if at top of memory bank1
                subwf   FSR,W
                bnz     clearBank1      ; Loop until all cleared

clearRam2       bcf     STATUS,RP0
                bsf     STATUS,RP1
                bsf     STATUS,IRP      ; select bank2/3 ( with indirect adressing )

                movlw   0x20            ; start ram bank2
                movwf   FSR
clearBank2      clrf    INDF            ; Clear a register pointed to be FSR
                incf    FSR,F
                movlw   0x70            ; Test if at top of memory bank2
                subwf   FSR,W
                bnz     clearBank2      ; Loop until all cleared

                movlw   0xa0            ; start ram bank3
                movwf   FSR
clearBank3      clrf    INDF            ; Clear a register pointed to be FSR
                incf    FSR,F
                movlw   0xf0            ; Test if at top of memory bank3
                subwf   FSR,W
                bnz     clearBank3      ; Loop until all cleared

                bcf     STATUS,RP0
                bcf     STATUS,RP1
                bcf     STATUS,IRP      ; select bank0/1 ( with indirect adressing )

                return  ;}

initUart        ;{
;  INIT_UART - Initialises UART
;  enables receiver and transmitter
; make sure pins are setup before calling this routine
; TRISC:6 and TRISC:7 must be set ( as for OUTPUT, but operates as input/OUTPUT )
; furthermore its advised that interrupts are disabled during this routine

                ; setup baudrate
;               movlw   CALC_HIGH_BAUD(57600)   ; BAUD_57600 ; get baudrate
;               movlw   BAUD_57600
                movlw   BAUD_38400
;               movlw   BAUD_19200
                banksel SPBRG
                movwf   SPBRG

                ; enable transmitter
 if bits89 == 9
                movlw   (1<<TXEN)|(1<<BRGH)|(1<<TX9)    ; preset enable transmitter, high speed, 9 bit
 else
                movlw   (1<<TXEN)|(1<<BRGH)             ; preset enable transmitter, high speed, 8 bit
 endif
                banksel TXSTA
                movwf   TXSTA

                ; enable recevier
 if bits89 == 9
                movlw   (1<<SPEN)|(1<<CREN)|(1<<RX9)    ; enable serial receiver, continous recevie, 9 bit
 else
                movlw   (1<<SPEN)|(1<<CREN)             ; enable serial receiver, continous recevie, 8 bit
 endif
                banksel RCSTA
                movwf   RCSTA           ; set it

                ; enable receiver interrupt
                banksel PIE1
;               bsf     PIE1,TXIE       ; enable transmitter irq
                bsf     PIE1,RCIE       ; enable receiver irq
                bsf     INTCON,PEIE     ; and peripheral irq must also be enabled

                return  ;}

initTimer0      ;{
;  initTimer0 - Initialises Timer1 module
                clrwdt
                banksel OPTION_REG
                movlw   b'11010000'     ; 1:2 prescale
                movwf   OPTION_REG
                return  ;}

initTimer1      ;{
;  initTimer1 - Initialises Timer1 module
                banksel T1CON
                movlw   T1CON           ; get adress for timer1 control reg
                movwf   FSR             ; setup fsr
                movlw   b'00110000'     ; 1:8 prescale, 100mS rollover
                movwf   INDF            ; initialize Timer1

                movlw   LOW(CALC_TIMER(D'100'))
                movwf   TMR1L           ; initialize Timer1 low
                movlw   HIGH(CALC_TIMER(D'100'))
                movwf   TMR1H           ; initialize Timer1 high
                bcf     PIR1,TMR1IF     ; ensure flag is reset
                bsf     T1CON,TMR1ON    ; turn on Timer1 module

                ; enable TIMER1 interrupt
                movlw   PIE1            ; get adress for periphial irqs
                movwf   FSR             ; setup fsr
                bsf     INDF,TMR1IE     ; enable TIMER1 irq
                bsf     INTCON,PEIE     ; and peripheral irq must also be enabled
                return  ;}

initTimer2      ;{
;  initTimer2 - Initialises timer2 module
;  prescaler and timer2 set to 500µs => 2kHz
;  postscaler 1:4 => 500Hz
                banksel PR2
                movlw   0xf9            ; 249 => 1:250
                movwf   PR2
                banksel T2CON
                movlw   0x19            ; 1:4 prescale ; 1:5 postscale; timer2 off
                movwf   T2CON
                banksel PIR1
                bcf     PIR1,TMR2IF     ; clear timer2 interrupt flag
                bsf     T2CON,TMR2ON    ; turn on timer2 module
                movlw   PIE1
                movwf   FSR
                bsf     INDF,TMR2IE     ; enable timer2 interrupt
                bsf     INTCON,PEIE     ; peripheral interrupt enabled
                return  ;}


initPlvd        ;{
                banksel LVDCON
                movlw   0x17
                movwf   LVDCON
                bcf     PIR2,LVDIF      ; clear low voltage detection bit
                return  ;}

initParams      ;{
;  INIT_PARAMS - Initialises user ram with parameters stored in EEPROM
                movlw   eeDeviceID
                scall   eeRead          ; get device id byte from eeprom
                banksel deviceID
                movwf   deviceID

                movlw   eeOutputLo
                scall   eeRead          ; get low byte of output from eeprom
                banksel outputLo
                movwf   outputLo

                movlw   eeOutputHi
                scall   eeRead          ; get high byte of output from eeprom
                banksel outputHi
                movwf   outputHi

 if revision >= 4
                bsf     PORTB,6         ; reset display counter
                bcf     PORTB,6
 else
                bsf     PORTA,7         ; reset display counter
                bcf     PORTA,7
 endif
                banksel iDisplayCount
                movlw   0x07
                movwf   iDisplayCount   ; reset our internal counter
                return  ;}
