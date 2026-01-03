genBitmask      ;{
                andlw   0x0f
                addlw   -8
                bc      genBitmask1
                call    bitTable
                movwf   bitmaskLo
                clrf    bitmaskHi
                return
genBitmask1     call    bitTable
                movwf   bitmaskHi
                clrf    bitmaskLo
genBitmask2     return  ;}

bitTable        ;{
                andlw   0x07
                tabj
bitTable1       retlw   0x01
                retlw   0x02
                retlw   0x04
                retlw   0x08
                retlw   0x10
                retlw   0x20
                retlw   0x40
                retlw   0x80    ;}


checkOutput     ;{
; compares outputs to bitmask
; in: outputLo/Hi
; in: bitmaskLo/Hi
; out: status-Z
                movfw   outputLo
                andwf   bitmaskLo,w
                skpz
                return
                movfw   outputHi
                andwf   bitmaskHi,w
                return  ;}


clrDelay        ;{
; zero out all delay bytes
; in: W pointer to delay bytes
                movwf   FSR
                bsf     STATUS,IRP
                clrf    INDF
                incf    FSR,f
                clrf    INDF
                incf    FSR,f
                clrf    INDF
                incf    FSR,f
                clrf    INDF
                incf    FSR,f
                clrf    INDF
                incf    FSR,f
                return  ;}


chkDelay        ;{
; check if all delay bytes are zero
; in: W pointer to delay bytes
; out: status-Z
                movwf   FSR
                bsf     STATUS,IRP
                movf    INDF,w
                incf    FSR,f
                iorwf   INDF,w
                incf    FSR,f
                iorwf   INDF,w
                incf    FSR,f
                iorwf   INDF,w
                incf    FSR,f
                iorwf   INDF,w
                return  ;}


genDelayF       ;{
                movwf   FSR             ; entry point for fast delays
                movfw   funcDelay
                movwf   temp1
                swapf   funcPrescMode,w
                andlw   0x0f
                addlw   2               ; smallest interval 1/250 second
                goto    genDelay0

genDelay        movwf   FSR             ; normal entry point
                movfw   funcDelay
                movwf   temp1
                swapf   funcPrescMode,w
                andlw   0x0f
                addlw   4               ; smallest interval 1/62.5 second
genDelay0       clrf    temp2
                clrf    temp3
                clrf    temp4
                clrf    temp5
genDelay1       clrc
                rlf     temp1,f
                rlf     temp2,f
                rlf     temp3,f
                addlw   -1
                bnz     genDelay1

                movf    time+0,w        ; add delay to current time
                addwf   temp1,f

                movf    time+1,w
                skpnc
                incfsz  time+1,w
                addwf   temp2,f

                movf    time+2,w
                skpnc
                incfsz  time+2,w
                addwf   temp3,f

                movf    time+3,w
                skpnc
                incfsz  time+3,w
                addwf   temp4,f

                movf    time+4,w
                skpnc
                incfsz  time+4,w
                addwf   temp5,f

                bsf     STATUS,IRP      ; store the result
                movfw   temp1
                movwf   INDF
                incf    FSR,f
                movfw   temp2
                movwf   INDF
                incf    FSR,f
                movfw   temp3
                movwf   INDF
                incf    FSR,f
                movfw   temp4
                movwf   INDF
                incf    FSR,f
                movfw   temp5
                movwf   INDF

                return  ;}


compareTime     ;{
                addlw   4
                movwf   FSR
                bsf     STATUS,IRP      ; upper ram
                movfw   time+4
                subwf   INDF,w          ; X>Y..zc,X<Y..zC,X=Y..ZC -
                bnc     TIMEisgreater   ; result: TIME>DELAY
                bnz     TIMEislower     ; result: TIME<DELAY
                decf    FSR,f
                movfw   time+3
                subwf   INDF,w          ; X>Y..zc,X<Y..zC,X=Y..ZC
                bnc     TIMEisgreater   ; result: TIME>DELAY
                bnz     TIMEislower     ; result: TIME<DELAY
                decf    FSR,f
                movfw   time+2
                subwf   INDF,w          ; X>Y..zc,X<Y..zC,X=Y..ZC
                bnc     TIMEisgreater   ; result: TIME>DELAY
                bnz     TIMEislower     ; result: TIME<DELAY
                decf    FSR,f
                movfw   time+1
                subwf   INDF,w          ; X>Y..zc,X<Y..zC,X=Y..ZC
                bnc     TIMEisgreater   ; result: TIME>DELAY
                bnz     TIMEislower     ; result: TIME<DELAY
                decf    FSR,f
                movfw   time+0
                subwf   INDF,w          ; X>Y..zc,X<Y..zC,X=Y..ZC
                bnc     TIMEisgreater   ; result: TIME>DELAY
                bnz     TIMEislower     ; result: TIME<DELAY
TIMEisequal     return                  ; Z=1;C=0
TIMEislower     return                  ; Z=0;C=1
TIMEisgreater   return                  ; Z=O;C=0
                ;}


safeOutput      ;{
                banksel outputLo
                movfw   outputLo
                banksel eeByte
                movwf   eeByte
                movlw   eeOutputLo
                pcall   eeWrite

                banksel outputHi
                movfw   outputHi
                banksel eeByte
                movwf   eeByte
                movlw   eeOutputHi
                goto    eeWrite
                ;}


CRC8            ;{
                xorwf   crc,f
                clrw
                btfsc   crc,0
                xorlw   0x5e
                btfsc   crc,1
                xorlw   0xbc
                btfsc   crc,2
                xorlw   0x61
                btfsc   crc,3
                xorlw   0xc2
                btfsc   crc,4
                xorlw   0x9d
                btfsc   crc,5
                xorlw   0x23
                btfsc   crc,6
                xorlw   0x46
                btfsc   crc,7
                xorlw   0x8c
                movwf   crc
                return
;}
