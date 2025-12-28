eeWrite ;{
; write a byte to eeprom
; in:   W       address pointer into eeprom
; in:   eeByte  data to be stored
; out:  -
; mod:  W
                banksel EECON1          ; select bank 3
eeWrite_1:      btfsc   EECON1,WR       ; wait for last write to complete
                goto    eeWrite_1
                bcf     STATUS,RP0      ; select bank 2
                movwf   EEADR           ; setup address
                banksel eeByte
                movfw   eeByte          ; get byte
                banksel EEDATA
                movwf   EEDATA          ; setup byte to write
                bsf     STATUS,RP0      ; select bank 3
                bcf     EECON1,EEPGD    ; set to data eeprom
                bsf     EECON1,WREN     ; enable writes
                disableirq              ; disable irqs

                movlw   0x55            ; required sequence !!
                movwf   EECON2
                movlw   0xAA
                movwf   EECON2
                bsf     EECON1,WR       ; begin write procedure

                enableirq               ; enable irqs again

                bcf     EECON1,WREN     ; disable writes (does not affect current write cycle)

                return  ;}

eeRead  ;{
; read a byte from eeprom
; in:   W       address pointer into eeprom
; out:  W       read byte
                banksel EECON1
eeRead_1        btfsc   EECON1,WR
                goto    eeRead_1        ; wait for last write to complete
                bcf     STATUS,RP0      ; bank2 !!
                movwf   EEADR           ; set up address reg.
                bsf     STATUS,RP0      ; bank3 !!
                bcf     EECON1,EEPGD    ; set to read eeprom
                bsf     EECON1,RD       ; set bit to read
                bcf     STATUS,RP0      ; bank2 !!
                movf    EEDATA,W        ; move data to W
                return  ;}
