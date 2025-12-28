setpclath       macro   PCLATH_34   ;{
;   setpclath 'help' macro for LONG_call
;   sets/clears PCLATH bits 3:4 according to
;   'variable' PCLATH_34
                if(PCLATH_34&0x10)
                    bsf PCLATH,4
                else
                    bcf PCLATH,4
                endif
                if(PCLATH_34&0x08)
                    bsf PCLATH,3
                else
                    bcf PCLATH,3
                endif
                endm    ;}

setpclath4      macro   PCLATH_4    ;{
;   setpclath4 'help' macro for LONG/SHORT_call
;   sets/clears PCLATH bit 4 according to
;   'variable' PCLATH_4
                if(PCLATH_4&0x10)
                    bsf PCLATH,4
                else
                    bcf PCLATH,4
                endif
                endm    ;}

setpclath3      macro   PCLATH_3    ;{
;   setpclath3 'help' macro for LONG/SHORT_call
;   sets/clears PCLATH bit 3 according to
;   'variable' PCLATH_3
                if(PCLATH_3&0x08)
                    bsf PCLATH,3
                else
                    bcf PCLATH,3
                endif
                endm    ;}

tabj        macro
;{
;   TABLE_JUMP Calculates an eventual table boundary crossing
;   sets up the PCLATH register correctly
;   Offset must be in w-reg, offset 0 jumps to the next instr.
                movwf   tabTemp         ; save wanted offset
                movlw   LOW($+8)        ; get low address ( of first instr. after macro )
                addwf   tabTemp,f       ; add offset
                movlw   HIGH($+6)       ; get highest 5 bits ( of first instr. after macro )
                skpnc                   ; page crossed ? ( 256 byte )
                addlw   0x01            ; Yes add one to high address
                movwf   PCLATH          ; load high address in latch
                movf    tabTemp,w       ; get computed address
                movwf   PCL             ; And jump
                endm    ;}

itabj           macro
;{
;   TABLE_JUMP Calculates an eventual table boundary crossing
;   sets up the PCLATH register correctly
;   Offset must be in w-reg, offset 0 jumps to the next instr.
                movwf   iTabTemp        ; save wanted offset
                movlw   LOW($+8)        ; get low address ( of first instr. after macro )
                addwf   iTabTemp,f      ; add offset
                movlw   HIGH($+6)       ; get highest 5 bits ( of first instr. after macro )
                skpnc                   ; page crossed ? ( 256 byte )
                addlw   0x01            ; Yes add one to high address
                movwf   PCLATH          ; load high address in latch
                movf    iTabTemp,w      ; get computed address
                movwf   PCL             ; And jump
                endm    ;}

longcall        macro   LABEL   ;{
;   LONG_call long call, sets the page bits 4:5 of PCLATH
;   so call can cross ANY page boundary, resets PCLATH after call.
;   w-reg is left untouched.

                local   DEST_HIGH, SOURCE_HIGH, DIFF_HIGH

DEST_HIGH       set (HIGH(LABEL)&0x18)      ; save bits 4:5 of dest address
SOURCE_HIGH     set (HIGH($)&0x18)          ; --- || ---  source address
DIFF_HIGH       set DEST_HIGH ^ SOURCE_HIGH ; get difference ( XOR )

                if  (DIFF_HIGH == 0) ; same page, SHOULD generate no extra code, delta 0 pages
                    messg   "Call on same page, replace longcall with pcall", LABEL
                    nop     ; redundant nops
                    nop
                    call    LABEL
                    nop
                    nop
                else    ; test if both bits must be set ? i.e. page0<->page3 or page2<->page3
                    if  (DIFF_HIGH == 0x18) ; difference in BOTH bits, delta 2 pages
                        ;messg  "Setting page bits for long page crossing call"
                        setpclath   DEST_HIGH   ; set both bits in PCLATH
                        call    LABEL
                        setpclath   SOURCE_HIGH ; reset both bits in pclath
                    else
                        ; if we end up here then one bsf/bcf is enough, i.e. delta 1 page
                        ; i.e. page0<->1 or page2<->3
                        messg   "Call only one page, replace longcall with scall", LABEL
                        if  (DIFF_HIGH == 0x10) ; diff in high bit
                            nop ; redundant nop
                            setpclath4  DEST_HIGH ; set high(4) bit of PCLATH
                            call    LABEL
                            setpclath4  SOURCE_HIGH
                            nop ; redundant nop
                        else
                            ; lowest bit only
                            nop ; redundant nop
                            setpclath3  DEST_HIGH ; set low(3) bit of PCLATH
                            call    LABEL
                            setpclath3  SOURCE_HIGH
                            nop
                        endif
                    endif
                endif
                endm    ;}

scall           macro   LABEL   ;{
;   SHORT_call short call, code for calling between page0<->1 or page2<->3
;   Resets PCLATH after call.
;   w-reg is left untouched.
                local   DEST_HIGH, SOURCE_HIGH, DIFF_HIGH
DEST_HIGH       set (HIGH(LABEL)&0x18)          ; save bits 4:5 of dest address
SOURCE_HIGH     set (HIGH($)&0x18)              ; --- || ---  source address
DIFF_HIGH       set DEST_HIGH ^ SOURCE_HIGH     ; get difference ( XOR )

                if  (DIFF_HIGH == 0) ; same page, SHOULD generate no extra code, delta 0 pages
                    messg   "Call on same page, replace scall with pcall", LABEL
                    nop     ; redundant nops
                    call    LABEL
                    nop
                else    ; for safety check so we do not require LONG_call
                    if  ((DIFF_HIGH&0x18)==0x18)
                        messg   " WARNING ! Replace scall with longcall", LABEL
                    endif

                    ;messg  "Setting page bits for short page crossing call"
                    if  (DIFF_HIGH == 0x10) ; diff in high bit
                        setpclath4  DEST_HIGH ; set high(4) bit of PCLATH
                        call    LABEL
                        setpclath4  SOURCE_HIGH
                    else    ; lowest bit only
                        setpclath3  DEST_HIGH ; set low(3) bit of PCLATH
                        call    LABEL
                        setpclath3  SOURCE_HIGH
                    endif
                endif
                endm    ;}

pcall           macro   LABEL   ;{
;   Pcall page call, code for calling on same page
;   outputs messages if LONG/SHORT call could/must be used
                local   DEST_HIGH, SOURCE_HIGH, DIFF_HIGH
DEST_HIGH       set (HIGH(LABEL)&0x18)          ; save bits 4:5 of dest address
SOURCE_HIGH     set (HIGH($)&0x18)              ; --- || ---  source address
DIFF_HIGH       set DEST_HIGH ^ SOURCE_HIGH     ; get difference ( XOR )

                if  (DIFF_HIGH == 0) ; same page, call ok
                    call    LABEL
                else    ; for safety check so we do not require LONG_call
                    if  ((DIFF_HIGH&0x18)==0x18)
                        messg   " WARNING ! Replace pcall with longcall", LABEL
                        call    LABEL   ; INCORRECT Call !!!
                    else
                        messg   " WARNING ! Replace pcall with scall", LABEL
                        call    LABEL
                    endif
                endif
                endm    ;}

movff           macro   source, destination ;{
; ---------------------------
; Macro: MOV FileReg to FileReg
; ---------------------------
                movfw   source
                movwf   destination
                endm    ;}

movlf           macro   literal, destination ;{
; ---------------------------
; Macro: MOV Literal to FileReg
; ---------------------------
                movlw   literal
                movwf   destination
                endm    ;}

bittog          macro   destination, bitno ;{
; ---------------------------
; Macro: Bit-Toggle
; ---------------------------
                movlw   1<<bitno        ; move 1 to bit position
                xorwf   destination
                endm    ;}

disableirq      macro   ;{
;   disableirq disable global irq
                local   STOP_INT
STOP_INT        bcf     INTCON,GIE      ; disable global interrupt
                btfsc   INTCON,GIE      ; check if disabled
                goto    STOP_INT        ; nope, try again
                endm    ;}

enableirq       macro   ;{
                bsf     INTCON,GIE      ; enable global interrupt
                endm    ;}

tstbnd          macro   LABEL   ;{
                IF ((HIGH ($)) != (HIGH (LABEL+1)))
                    ERROR LABEL CROSSES PAGE BOUNDARY!
                ENDIF
                endm    ;}

outputOn        macro   ;{              ; switch output on
                movfw   bitmaskLo
                iorwf   outputLo,f
                movfw   bitmaskHi
                iorwf   outputHi,f
                endm    ;}

outputOff       macro   ;{              ; switch output off
                comf    bitmaskLo,w
                andwf   outputLo,f
                comf    bitmaskHi,w
                andwf   outputHi,f
                endm    ;}

outputToggle    macro   ;{              ; toggle output
                movfw   bitmaskLo
                xorwf   outputLo,f
                movfw   bitmaskHi
                xorwf   outputHi,f
                endm    ;}
