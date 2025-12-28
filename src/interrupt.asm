INT             ;{
                movwf   safedW          ; save W register
                swapf   STATUS,w        ; the swapf instruction, unlike the movf, affects NO status bits, which is why it is used here.
                clrf    STATUS          ; sets to BANK0
                movwf   safedSTATUS     ; save status reg
                movfw   PCLATH
                movwf   safedPCLATH     ; save pclath
                clrf    PCLATH
                movfW   FSR
                movwf   safedFSR        ; save fsr reg

;               btfss   INTCON,INTF     ; test for external interrupt
;               goto    iTestRxIrq      ; nope check next interrupt source
;               pcall   IRQ_INT_HANDLER ; external irq handler
;               clrf    STATUS
;               bcf     INTCON,INTF     ; clear int pin flag

iTestRxIrq      pcall   iRxHandler      ; rx irq handler
                pcall   iSkipRx


iTestTxIrq      btfss   PIR1,TXIF       ; test for serial transmit interrupt
                goto    iTestTimer2     ; nope check next interrupt source
                pcall   iTxHandler      ; tx irq handler
                clrf    STATUS
                bcf     PIR1,TXIF       ; clear tx int flag

iTestTimer2     btfss   PIE1,TMR2IE     ; test if timer2 500Hz interrupt is enabled
                goto    iExit           ; no, so exit ISR
                bcf     STATUS,RP0      ; select SFR bank
                btfss   PIR1,TMR2IF     ; test if timer2 rollover occurred
                goto    iExit           ; no so exit isr
                bcf     PIR1,TMR2IF     ; clear timer2 H/W flag

                bcf     time,0          ; make sure bit 0 is zero
                incf    time,f
                incf    time,f          ; simulate 1kHz timebase with 500Hz interrupt
                bnz     iTimeEnd
                incf    time+1,f
                bnz     iTimeEnd
                incf    time+2,f
                bnz     iTimeEnd
                incf    time+3,f
                bnz     iTimeEnd
                incf    time+4,f

iTimeEnd        incf    iCount,f
                pcall   iDisplay
                pcall   iHeartBeat
                pcall   iOutput

                movfw   iCount
                andlw   0x07
                bnz     iExit

                pcall   iGetInput
                pcall   iDebounce
                pcall   iQueueMsg
                pcall   iShowState

;               movfw   iEdgeAux
;               andwf   iInputAux,w
;               bz      iExit
;               movlw   0x01
;               xorwf   needCfg,f

;               movlw   0x00
;               btfsc   needCfg,0
;               movlw   0x78
;               movwf   displayram+5
;               movwf   displayram+7
;               movwf   displayram+9

iExit
                banksel TXSTA
                btfss   TXSTA,TRMT      ; test for empty transmit shift register
                goto    iExit1
                banksel PORTC
                bcf     PORTC,5         ; disable RS485 transmitter

iExit1          clrf    STATUS
                movf    safedFSR,w      ; get saved fsr reg
                movwf   FSR             ; restore
                movf    safedPCLATH,w   ; get saved pclath
                movwf   PCLATH          ; restore
                swapf   safedSTATUS,w   ; get saved status in w
                movwf   STATUS          ; restore status ( and bank )
                swapf   safedW,f        ; reload into self to set status bits
                swapf   safedW,w        ; and restore
                retfie                  ; return from interrupt
;}


iSkipRx         ;{
                banksel skipRxCnt
                tstf    skipRxCnt       ; check if we are still skipping a config frame
                skpnz
                return

                movfw   rxNum           ; check if there is a character in the ringbuffer
                skpnz
                return

                incf    rxGetPtr,f      ; increment read pointer
                movlw   (BUFSIZE)-1     ; BUFSIZE must be to the power of 2
                andwf   rxGetPtr,f      ; mask read pointer to get easy wrap around
                decf    rxNum,f         ; decrement number of bytes in ringbuffer
                decf    skipRxCnt,f     ; decrement skip rx counter
                goto    iSkipRx         ;}


iDisplay        ;{
 if revision >= 3
                banksel PORTC
                decf    iDisplayCount,f
                bnz     iDisplay1

 if revision >= 4
                bsf     PORTB,6         ; reset frame counter
                bcf     PORTB,6
 else
                bsf     PORTA,7         ; reset frame counter
                bcf     PORTA,7
 endif

                movlw   0x08
                movwf   iDisplayCount   ; reset frame counter
iDisplay1       clrc
                rlf     iDisplayCount,w
                addlw   displayram-3
                movwf   FSR
                movlw   0x03
                andwf   INDF,w
                movwf   iTemp1
                swapf   iTemp1,f
                banksel PORTG
                movlw   0xcf
                andwf   PORTG,w
                banksel iTemp1
                iorwf   iTemp1,f        ; col0-1 prepared

                movlw   0xfc
                andwf   INDF,w
                movwf   iTemp2
                clrc
                rrf     iTemp2,f
                rrf     iTemp2,f
                movlw   0xc0
                andwf   PORTB,w
                iorwf   iTemp2,f        ; col2-7 prepared

                decf    FSR,f           ; upper byte of display row
                movlw   0x03
                andwf   INDF,w
                movwf   iTemp3
                swapf   iTemp3,f
                movlw   0xcf
                andwf   PORTA,w
                iorwf   iTemp3,f        ; col8-9 prepared

                movfw   iTemp1
                banksel PORTG
                movwf   PORTG
                banksel iTemp2
                movfw   iTemp2
                movwf   PORTB
                movfw   iTemp3
                movwf   PORTA

                bsf     PORTC,4         ; increment counter
                bcf     PORTC,4

                movfw   iDisplayCount
                xorlw   0x01
                bnz     iDisplay2

                rrf     time+1,w
                movwf   iTemp1
                rrf     time,w
                movwf   iTemp2
                rrf     iTemp1,f
                rrf     iTemp2,w
                andlw   0xfc
                bz      iDisplay2
                sublw   0x50
                bz      iDisplay2

                bsf     PORTC,4         ; increment counter
                bcf     PORTC,4

iDisplay2
 endif
                return  ;}

iGetInput       ;{
 if revision >= 3
; get input of port1
                banksel iInSampleLo
                movfw   PORTD
                movwf   iInSampleLo

; get input of port 1 low nibble
                banksel PORTF
                swapf   PORTF,w
                banksel iInSampleHi
                andlw   0xf0
                movwf   iInSampleHi

; get input of port 2 high nibble
                banksel PORTG
                movfw   PORTG
                banksel iInSampleHi
                andlw   0x0f
                iorwf   iInSampleHi,f
; get input of aux port
                banksel PORTB
                movlw   0x00
                btfss   PORTB,7
                movlw   0x01
                banksel iInSampleAux
                movwf   iInSampleAux

 else   ; revision 2
; get input of port1 low nibble
                banksel iInSampleLo
                clrf    iInSampleLo
                movfw   PORTD
                andlw   0xf0
                movwf   iInSampleLo

; get input of port 1 high nibble
                banksel PORTG
                movfw   PORTG
                banksel iInSampleLo
                andlw   0x0f
                iorwf   iInSampleLo,f
                swapf   iInSampleLo,f   ; swap to nibbles into the right place
                comf    iInSampleLo,f   ; inverted logic

; get input of port 2 high nibble
                clrf    iInSampleHi
                movfw   PORTB
                andlw   0x0f
                movwf   iInSampleHi
                swapf   iInSampleHi,f

; get input of port 2 low nibble
                banksel PORTF
                movfw   PORTF
                banksel iInSampleHi
                andlw   0x0f
                iorwf   iInSampleHi,f
                comf    iInSampleHi,f   ; inverted logic
 endif
                return  ;}

iDebounce       ;{
; debounces the input 1 by waiting 4 cycles before assuming an input has changed
; using a vertical counter http://www.dattalo.com/technical/software/pic/iDebounce.html

                banksel iDebounceLoA
                movfw   iDebounceLoB    ; Increment the vertical counter
                xorwf   iDebounceLoA,f
                comf    iDebounceLoB,f

                movfw   iInSampleLo     ; See if any changes occurred
                xorwf   iInputLo,w

                andwf   iDebounceLoB,f  ; Reset the counter if no change has occurred
                andwf   iDebounceLoA,f

;If there is a pending change and the count has
;rolled over to 0, then the change has been filtered
                xorlw   0xff            ; Invert the changes
                iorwf   iDebounceLoA,w  ; If count is 0, both A and B
                iorwf   iDebounceLoB,w  ; bits are 0

;Any bit in W that is clear at this point means that the input
;has changed and the count has rolled over.

                xorlw   0xff            ; Now W holds the state of inputs that have just been filtered to a new state. Update the changes:
                xorwf   iInputLo,f
                movwf   iEdgeLo         ; detected edges (state changes)

                movfw   iDebounceHiB    ; Increment the vertical counter
                xorwf   iDebounceHiA,f
                comf    iDebounceHiB,f

                movfw   iInSampleHi     ; See if any changes occurred
                xorwf   iInputHi,w

                andwf   iDebounceHiB,f  ; Reset the counter if no change has occurred
                andwf   iDebounceHiA,f

;If there is a pending change and the count has
;rolled over to 0, then the change has been filtered
                xorlw   0xff            ; Invert the changes
                iorwf   iDebounceHiA,w  ; If count is 0, both A and B
                iorwf   iDebounceHiB,w  ; bits are 0

;Any bit in W that is clear at this point means that the input
;has changed and the count has rolled over.

                xorlw   0xff            ; Now W holds the state of inputs that have just been filtered to a new state. Update the changes:
                xorwf   iInputHi,f
                movwf   iEdgeHi         ; detected edges (state changes)

                movfw   iDebounceAuxB   ; Increment the vertical counter
                xorwf   iDebounceAuxA,f
                comf    iDebounceAuxB,f

                movfw   iInSampleAux    ; See if any changes occurred
                xorwf   iInputAux,w

                andwf   iDebounceAuxB,f ; Reset the counter if no change has occurred
                andwf   iDebounceAuxA,f

;If there is a pending change and the count has
;rolled over to 0, then the change has been filtered
                xorlw   0xff            ; Invert the changes
                iorwf   iDebounceAuxA,w ; If count is 0, both A and B
                iorwf   iDebounceAuxB,w ; bits are 0

;Any bit in W that is clear at this point means that the input
;has changed and the counter has rolled over.

                xorlw   0xff            ; now W holds the state of inputs that have just been filtered to a new state. Update the changes:
                xorwf   iInputAux,f
                movwf   iEdgeAux        ; detected edges (state changes)

                return  ;}

iOutput         ;{
                banksel PORTC
                movfw   PORTC
                andlw   0xf0            ; keep other OUTPUT pins' status
                movwf   iTemp1
                movfw   outputLo        ; get lower part of OUTPUT
                call    iReverseNibble
                iorwf   iTemp1,w
                movwf   PORTC

                banksel PORTF
                movfw   PORTF
                andlw   0x0f            ; keep other OUTPUT pins' status
                banksel iTemp1
                movwf   iTemp1
                swapf   outputLo,w      ; get upper part of OUTPUT
                call    iReverseNibble
                swapf   iTemp1,f
                iorwf   iTemp1,f
                swapf   iTemp1,w
                banksel PORTF
                movwf   PORTF

                banksel PORTE
                movfw   PORTE
                andlw   0x0f
                movwf   iTemp1
                movfw   outputHi        ; get lower part of OUTPUT
                call    iReverseNibble
                swapf   iTemp1,f
                iorwf   iTemp1,f
                swapf   iTemp1,w
                movwf   PORTE

                movfw   PORTA
                andlw   0xf0
                movwf   iTemp1
                swapf   outputHi,w      ; get upper part of OUTPUT
                call    iReverseNibble
                iorwf   iTemp1,w
                movwf   PORTA

                return  ;}

iShowState      ;{
 if revision >= 3
                clrc
                clrf    displayram+0x0a
                clrf    displayram+0x0b
                movfw   iInputLo
                pcall   iReverseNibble
                movwf   displayram+0x0b
                swapf   displayram+0x0b,f
                swapf   iInputLo,w
                pcall   iReverseNibble
                iorwf   displayram+0x0b,f
                rlf     displayram+0x0b,f
                rlf     displayram+0x0a,f
                rlf     displayram+0x0b,f
                rlf     displayram+0x0a,f

                clrf    displayram+0x0c
                clrf    displayram+0x0d
                movfw   iInputHi
                pcall   iReverseNibble
                movwf   displayram+0x0d
                swapf   displayram+0x0d,f
                swapf   iInputHi,w
                pcall   iReverseNibble
                iorwf   displayram+0x0d,f

                clrc
                clrf    displayram+0x00
                clrf    displayram+0x01
                movfw   outputLo
                pcall   iReverseNibble
                movwf   displayram+0x01
                swapf   displayram+0x01,f
                swapf   outputLo,w
                pcall   iReverseNibble
                iorwf   displayram+0x01,f
                rlf     displayram+0x01,f
                rlf     displayram+0x00,f
                rlf     displayram+0x01,f
                rlf     displayram+0x00,f

                clrf    displayram+0x02
                movfw   outputHi
                pcall   iReverseNibble
                movwf   displayram+0x03
                swapf   displayram+0x03,f
                swapf   outputHi,w
                pcall   iReverseNibble
                iorwf   displayram+0x03,f

;               bcf     displayram+0x07,4
;               bcf     displayram+0x07,5
;               rrf     TIME+1,w
;               movwf   iTemp1
;               rrf     TIME,w
;               movwf   iTemp2
;               rrf     iTemp1,f
;               rrf     iTemp2,f
;               swapf   iTemp2,w
;               andlw   0x0f
;               bnz     iShowState1
;               bsf     displayram+0x07,4
;               bsf     displayram+0x07,5
;iShowState1        sublw   0x05
;               bnz     iShowState2
;               bsf     displayram+0x07,4
;               bsf     displayram+0x07,5
 endif
iShowState2;        movlw   0x00
;               btfsc   iInputAux,0
;               movlw   0xff
;               movwf   displayram+0x04
;               movwf   displayram+0x05
;               movfw   RXPUTPTR            ;xx
;               movwf   displayram+0x05     ;xx
;               movfw   RXGETPTR            ;xx
;               movwf   displayram+0x09     ;xx
;               movfw   RXNUM               ;xx
;               movwf   displayram+0x07     ;xx
                return  ;}


iHeartBeat      ;{
 if revision >= 3
                return
 else
                banksel PORTB
                movwf   PORTB
                andlw   0xcf
                movfw   iTemp3
                pcall   HEARTCODE
                iorwf   iTemp3,w
                movwf   PORTB
                return

HEARTCODE
                rrf     time+1,w
                movwf   iTemp1
                rrf     time,w
                movwf   iTemp2
                rrf     iTemp1,f
                rrf     iTemp2,f
                swapf   iTemp2,w
                andlw   0x0f
                itabj
                retlw   0x10
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x20
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
                retlw   0x00
 endif          ;}


iQueueMsg       ;{
                banksel iEdgeLo
                movfw   iEdgeLo         ; test for any changes
                iorwf   iEdgeHi,w
                skpnz
                return                  ; deflect when no change occurred

                movfw   msgNum
                xorlw   MSGBUFSIZE      ; check if there is free space in the ringbuffer
                skpnz
                return                  ; discard if buffer full

                movfw   msgPutPtr       ; current write pointer
                addlw   LOW(msgBuf)     ; base address of tx buffer
                movwf   FSR             ; set FSR to current write position
                bankisel    msgBuf
                movff   iInputLo,INDF   ; store into ringbuffer
                incf    FSR,f
                movff   iInputHi,INDF   ; store into ringbuffer
                incf    FSR,f
                movff   iEdgeLo,INDF    ; store into ringbuffer
                incf    FSR,f
                movff   iEdgeHi,INDF    ; store into ringbuffer
                movlw   0x04
                addwf   msgNum,f        ; increment number of bytes in ringbuffer
                addwf   msgPutPtr,f     ; increment write pointer by 4
                movlw   (MSGBUFSIZE)-1  ; MSGBUFSIZE must be a power of 2
                andwf   msgPutPtr,f     ; mask write pointer to get easy wrap around
                return  ;}

iReverseNibble  ;{
                andlw   0x0f
                itabj
                retlw   0x00        ; 0x00
                retlw   0x08        ; 0x01
                retlw   0x04        ; 0x02
                retlw   0x0c        ; 0x03
                retlw   0x02        ; 0x04
                retlw   0x0a        ; 0x05
                retlw   0x06        ; 0x06
                retlw   0x0e        ; 0x07
                retlw   0x01        ; 0x08
                retlw   0x09        ; 0x09
                retlw   0x05        ; 0x0a
                retlw   0x0d        ; 0x0b
                retlw   0x03        ; 0x0c
                retlw   0x0b        ; 0x0d
                retlw   0x07        ; 0x0e
                retlw   0x0f        ; 0x0f
;}

iTxHandler      ;{
; ===============================================================
;  iTxHandler - handles the transmission of bytes on serial com
;  called on transmitter and cyclic interrupt.
;  recovers byte from ringbuffer
; ===============================================================
                banksel txNum
                tstf    txNum           ; check if there is a character in the ringbuffer
                bz      iTxHandler1

                movfw   txGetPtr        ; current read pointer
                addlw   LOW(txBuf)      ; base address of tx buffer
                movwf   FSR             ; set FSR to current read position
                bankisel    txBuf
                movfw   INDF            ; store get char from ringbuffer
                bsf     PORTC,5         ; enable RS485 transmitter
                movwf   TXREG           ; send char
                incf    txGetPtr,f      ; increment read pointer
                movlw   (BUFSIZE)-1     ; BUFSIZE must be to the power of 2
                andwf   txGetPtr,f      ; mask read pointer to get easy wrap around
                decf    txNum,f         ; increment number of bytes in ringbuffer
                return

iTxHandler1     movlw   PIE1            ; get address for tx irq enable
                movwf   FSR             ; setup fsr
                bcf     INDF,TXIE       ; and disable tx irq
                return  ;}


iRxHandler  ;{
                btfss   PIR1,RCIF       ; test for serial receive interrupt
                return

                banksel RCSTA
                btfss   RCSTA,OERR      ; test for overrun error
                goto    rxCheckFraming  ; when overrun, uart will stop receiving the continuous
                                        ; receive bit must then be reset
                bcf     RCSTA,CREN      ; clear continuous receive bit
                bsf     RCSTA,CREN      ; and set it again

rxCheckFraming
                btfsc   RCSTA,FERR      ; check from framing errors
                goto    rxDiscardByte   ; framing error do not store this byte
                                        ; read rx reg and discard byte
rxCheckBuffer
                movfw   rxNum
                addlw   -BUFSIZE+1      ; check if there is free space in the ringbuffer
                bz      rxBufferFull

                movfw   rxPutPtr        ; current write pointer
                addlw   LOW(rxBuf)      ; base address of rx buffer
                movwf   FSR             ; set FSR to current write position
                bankisel    rxBuf
                movff   RCREG,INDF      ; store char into ringbuffer
                incf    rxNum,f         ; increment number of bytes in ringbuffer
                incf    rxPutPtr,f      ; increment write pointer
                movlw   (BUFSIZE)-1     ; BUFSIZE must be to the power of 2
                andwf   rxPutPtr,f      ; mask write pointer to get easy wrap around
                return

rxBufferFull                            ; no room for more bytes, set overrun flag
;               bsf     _BufferOverrun
rxDiscardByte                           ; optional an error flag could be set to indicate comm error.
                tstf    RCREG           ; read byte and discard
                return  ;}
