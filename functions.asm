fAlwaysOff      ;{
; keeps an output pin always off
; in:   funcOutBits
; out:  outputLo | outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                movfw   funcOutBits     ; get output bit
                pcall   genBitmask      ; generate bitmask for output
                outputOff               ; switch output off
                goto    dispatchCont    ;}

fAlwaysOn       ;{
; keeps an output pin always off
; in:   funcOutBits
; out:  outputLo | outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                movfw   funcOutBits     ; get output bit
                pcall   genBitmask      ; generate bitmask for output
                outputOn                ; switch output on
                goto    dispatchCont    ;}

fPassThrough    ;{
; a single output pin follows the state of the corresponding input
; in:   rxInput
; in:   funcOutBits
; out:  outputLo | outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fPassThrough1

                btfss   rxInput,5       ; check for released key (negative edge)
                goto    dispatchCont

                movfw   funcOutBits     ; get output bit
                pcall   genBitmask      ; generate bitmask for output
                outputOff
                goto    dispatchCont

fPassThrough1   movfw   funcOutBits     ; get output bit
                pcall   genBitmask      ; generate bitmask for output
                outputOn
                goto    dispatchCont    ;}

fToggle         ;{
; toggles a single output pin when the corresponding key is pressed
; in:   rxInput
; in:   funcOutBits
; out:  outputLo | outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                bankisel    functionRam

                btfss   funcUber,4      ; need to check the output bit?
                goto    fToggleS1       ; no

                movfw   funcUber
                xorwf   funcOutBits,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

                btfsc   funcUber,7      ; test for on/off mode
                goto    fToggleS3       ; lights on
                goto    fToggleS5       ; lights off

fToggleS1       btfsc   funcSemaphore,0 ; check for lights on
                goto    fToggleS3       ; light on

                btfsc   funcSemaphore,1 ; check for lights off
                goto    fToggleS5       ; light off

fToggleS2       btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    fToggleS4       ; continue if no positive edge

                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer

                movfw   funcOutBits     ; check for output status
                pcall   genBitmask
                pcall   checkOutput
                bnz     fToggleS5       ; output is currently on => turn output off

                movfw   funcPrescMode
                andlw   0xf0
                bz      fToggleS3       ; no timer mode

                incf    paramPtr2,w
                pcall   genDelay        ; set delay after which we turn of the output

fToggleS3       movfw   funcOutBits
                pcall   genBitmask
                outputOn                ; switch output on

                goto    dispatchCont

fToggleS4       incf    paramPtr2,w
                pcall   compareTime     ; on-time already elapsed
                bc      dispatchCont    ; no

                incf    paramPtr2,w
                pcall   chkDelay
                bz      dispatchCont    ; continue if delay timer alreay cleared

                movfw   paramPtr2
                movwf   FSR
                btfsc   INDF,7          ; test twoStage status if key is still pressed
                goto    dispatchCont    ; there is also a twoStageToggle running

fToggleS5       incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer

                movfw   funcOutBits
                pcall   genBitmask
                outputOff               ; switch output off

                goto    dispatchCont    ;}


fToggleDual     ;{
; toggles two output pins when the corresponding key is pressed (output 1 is master)
; in:   rxInput
; in:   funcOutBits (lower and upper nibble)
; out:  outputLo &/| outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                bankisel    functionRam

                btfss   funcUber,4      ; need to check the output bit?
                goto    fToggleDual0    ; no

                movfw   funcOutBits
                xorwf   funcUber,w
                andlw   0x0f
                bz      fToggleDualA    ; one of our output bits we searched for

                swapf   funcOutBits,w
                xorwf   funcUber,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

fToggleDualA    btfsc   funcUber,7      ; test for on/off mode
                goto    fToggleDual3    ; lights on
                goto    fToggleDual1    ; lights off

fToggleDual0    btfsc   funcSemaphore,0 ; check for lights on
                goto    fToggleDual3

                btfsc   funcSemaphore,1 ; check for lights off
                goto    fToggleDual1

                btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    fToggleDual4

                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                incf    paramPtr3,w
                pcall   clrDelay        ; clear delay timer

                swapf   funcOutBits,w
                pcall   genBitmask      ; generate bitmask for output2
                pcall   checkOutput
                bz      fToggleDual2    ; output2 clear
                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output1
                pcall   checkOutput
                bz      fToggleDual2    ; output1 clear
fToggleDual1    movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output1
                outputOff
                swapf   funcOutBits,w
                pcall   genBitmask      ; generate bitmask for output2
                outputOff
                goto    dispatchCont

fToggleDual2    movfw   funcPrescMode
                andlw   0xf0
                bz      fToggleDual3

                incf    paramPtr2,w
                pcall   genDelay
                incf    paramPtr3,w
                pcall   genDelay

fToggleDual3    movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output1
                outputOn
                swapf   funcOutBits,w
                pcall   genBitmask      ; generate bitmask for output2
                outputOn
                goto    dispatchCont

fToggleDual4    incf    paramPtr2,w
                pcall   compareTime     ; time already elapsed
                bc      fToggleDual5    ; no

                incf    paramPtr2,w
                pcall   chkDelay
                bz      fToggleDual5    ; continue if delay timer alreay cleared

                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer

                movfw   funcOutBits
                pcall   genBitmask
                outputOff               ; switch output off

fToggleDual5    incf    paramPtr3,w
                pcall   compareTime     ; time already elapsed
                bc      dispatchCont    ; no

                incf    paramPtr3,w
                pcall   chkDelay
                bz      dispatchCont    ; continue if delay timer alreay cleared

                incf    paramPtr3,w
                pcall   clrDelay        ; clear delay timer

                swapf   funcOutBits,w
                pcall   genBitmask
                outputOff               ; switch output off

                goto    dispatchCont    ;}


fTwoStage       ;{
; toggles first output on short keypress, when the first output toggles on and the
; key is held for a longer time the second output turns on
; in:   rxInput
; in:   funcOutBits (lower and upper nibble)
; out:  outputLo &/| outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                bankisel    functionRam
                btfss   funcUber,4      ; need to check the output bit?
                goto    fTwoStage2      ; no

                movfw   funcOutBits
                xorwf   funcUber,w
                andlw   0x0f
                bz      fTwoStage1      ; one of our output bits we searched for

                swapf   funcOutBits,w
                xorwf   funcUber,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

fTwoStage1      btfsc   funcUber,7      ; test for on/off mode
                goto    fTwoStage6      ; lights on
                goto    fTwoStage7      ; lights off

fTwoStage2      btfsc   funcSemaphore,0 ; check for lights on
                goto    fTwoStage6

                btfsc   funcSemaphore,1 ; check for lights off
                goto    fTwoStage7

                btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fTwoStage3

                btfss   rxInput,5       ; check for released key (negative edge)
                goto    fTwoStage5

                movfw   paramPtr2
                movwf   FSR
                bcf     INDF,7          ; clear flag 'positive edge received' on twoStage status
                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                goto    dispatchCont

fTwoStage3      movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output
                pcall   checkOutput     ; check if output already set
                bnz     fTwoStage4

                outputOn                ; switch output 1 on (gang 1)
                movfw   paramPtr2
                movwf   FSR
                bsf     INDF,7          ; set flag 'positive edge received' on twoStage status
                movlw   0x01            ; we use only the prescaler for this delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay
                goto    dispatchCont

fTwoStage4      outputOff               ; switch output 1 off
                swapf   funcOutBits,w
                pcall   genBitmask
                outputOff               ; switch output 2 off
                goto    dispatchCont

fTwoStage5      movfw   paramPtr2
                movwf   FSR
                btfss   INDF,7          ; test twoStage status if key is still pressed
                goto    dispatchCont

                incf    paramPtr2,w
                pcall   compareTime
                bc      dispatchCont

                movfw   paramPtr2
                movwf   FSR
                bcf     INDF,7          ; clear flag 'positive edge received' on twoStage status
                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer

                movfw   funcOutBits     ; check if output 1 is already set
                pcall   genBitmask
                pcall   checkOutput
                bz      dispatchCont    ; no

                swapf   funcOutBits,w
                pcall   genBitmask
                outputOn                ; switch output 2 on (gang 2)
                goto    dispatchCont

fTwoStage6      movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output
                outputOn                ; switch output 1 on
                swapf   funcOutBits,w
                pcall   genBitmask
                outputOn                ; switch output 2 on
                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                goto    dispatchCont

fTwoStage7      movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for output
                outputOff               ; switch output 1 off
                swapf   funcOutBits,w
                pcall   genBitmask
                outputOff               ; switch output 2 off
                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                goto    dispatchCont    ;}


fTimerR         ;{
; retriggerable timer
; ouptut is turned on until delay time has elapsed
; in:   rxDevID
; in:   rxInput
; in:   funcOutBits lower nibble
; out:  outputLo &/| outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi
                bankisel    functionRam
                btfss   funcUber,4      ; need to check the output bit?
                goto    fTimerRa        ; no

                movfw   funcUber
                xorwf   funcOutBits,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

                btfsc   funcUber,7      ; test for on/off mode
                goto    fTimerR1        ; lights on
                goto    fTimerR0        ; lights off

fTimerRa        btfsc   funcSemaphore,0 ; check for lights on
                goto    fTimerR1

                btfsc   funcSemaphore,1 ; check for lights off
                goto    fTimerR0

                btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fTimerR1

                incf    paramPtr2,w
                pcall   compareTime     ; time already elapsed
                bc      dispatchCont    ; no

                incf    paramPtr2,w
                pcall   chkDelay
                bz      dispatchCont    ; continue if delay timer alreay cleared

fTimerR0        movfw   funcOutBits
                pcall   genBitmask
                outputOff               ; switch output off

                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                goto    dispatchCont

fTimerR1        incf    paramPtr2,w
                pcall   genDelay

                movfw   funcOutBits
                pcall   genBitmask
                outputOn                ; switch output on

                goto    dispatchCont    ;}

fBlinker            ;{
; blinker / inverted blinker
; toggles output with configurable frequency and duty cycle
; in:   rxDevID
; in:   rxInput
; in:   funcOutBits lower nibble
; in:   funcTypeInput bit 4 (inverted mode)
; out:  outputLo &/| outputHi
; mod:  bitmaskLo
; mod:  bitmaskHi

; 6.0ms cycle
; 0.5ms low
; 5.5ms high

                bankisel    functionRam
                movfw   paramPtr2
                movwf   FSR

                btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    fBlinker1
                bsf     INDF,0
                goto    fBlinker3

fBlinker1:      btfss   rxInput,5       ; check for released key (negative edge)
                goto    fBlinker2
                clrf    INDF

                incf    paramPtr2,w
                pcall   clrDelay        ; clear delay timer
                
                btfsc   funcTypeInput,4 ; test for inverted mode
                goto    fBlinkerOn

fBlinkerOff:    movfw   funcOutBits
                pcall   genBitmask
                outputOff               ; switch output off
                goto    dispatchCont

fBlinkerOn:     movfw   funcOutBits
                pcall   genBitmask
                outputOn                ; switch output on
                goto    dispatchCont

fBlinker2:      btfss   INDF,0
                goto    dispatchCont

                incf    paramPtr2,w
                pcall   compareTime     ; time already elapsed
                bc      dispatchCont    ; no

                movfw   paramPtr2
                movwf   FSR
                btfsc   INDF,1
                goto    fBlinker4

fBlinker3:      bsf     INDF,1

                incf    paramPtr2,w
                pcall   genDelayF       ; set up delay T1

                goto    fBlinkerOn

fBlinker4:      bcf     INDF,1

                movlw   devID2          ; we use funcDevID2 as T2 low phase
                addwf   paramPtr1,w
                longcall    eeRead
                banksel funcDelay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelayF       ; set up delay T2

                goto    fBlinkerOff



fAwning         ;{
;        +-----+  T3        T3  +-----+
;        |     |------+  +------|     |
;  +---->| S01 |  O+  |  |  C+  | S11 |<----+
;  |     |full |----->|  |<-----|full |     |
;  |     |close|  C+  |  |  O+  |open |     |
;  |     |     |----->|  |<-----|     |     |
;  |     +-----+      |  |      +-----+     |
;  |                  v  v                  |
;  |              +----------+              |
;  |              |    S02   |              |
;  |              |protection|              |
;  |              | interval |              |
;  |              +----------+              |
;  |                    |                   |
;  |                    | T4                |
;  |                    v                   |
;  |                +------+                |
;  |            C+  | S00  |  O+            |
;  +----------------| stop |----------------+
;                   |      |
;                   +------+


                bankisel    functionRam
                btfss   funcUber,4      ; need to check the output bit?
                goto    fAwningA        ; no

                movfw   funcOutBits
                xorwf   funcUber,w
                andlw   0x0f
                bz      fAwningB        ; one of our output bits we searched for

                swapf   funcOutBits,w
                xorwf   funcUber,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

fAwningB        btfsc   funcUber,7      ; test for open/close mode
                goto    fAwningO        ; open awning
                goto    fAwningC        ; close awning

fAwningA        btfsc   funcSemaphore,6 ; check for awning closing
                goto    fAwningC

                btfsc   funcSemaphore,7 ; check for awning opening
                goto    fAwningO

                movfw   paramPtr2
                movwf   FSR
                tstf    INDF            ; test for state 00
                bz      fAwningS00

                movlw   0x01
                xorwf   INDF,w          ; test for state 01
                bz      fAwningS01

                movlw   0x02
                xorwf   INDF,w          ; test for state 02
                bz      fAwningS02

                goto    fAwningStop     ; nothing matched; set state 00

fAwningS00      btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    dispatchCont

                movlw   0x01            ; next state S01
                movwf   INDF

                swapf   funcOutBits,w   ; generate bitmask for close/open (upper nibble)
                pcall   genBitmask
                btfsc   funcUber,5      ; test if second input key (close) matched
                goto    fAwningS00a     ; no, we are opening
                outputOff               ; switch close/open off (close)
                goto    fAwningS00b
fAwningS00a     outputOn                ; switch close/open on (open)
fAwningS00b     movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOn                ; switch power on

                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T3
                goto    dispatchCont

fAwningS01      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fAwningStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T3 has elapsed
                bc      dispatchCont    ; not yet

fAwningStop     movfw   paramPtr2
                movwf   FSR
                movlw   0x02            ; next state S02 (protection interval)
                movwf   INDF

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOff               ; switch power off
                swapf   funcOutBits,w   ; generate bitmask for close/open (upper nibble)
                pcall   genBitmask
                outputOff               ; switch close/open off (close)

                movfw   funcPrescMode   ; set up prescaler
                andlw   0x0f
                iorlw   0x10
                movwf   funcPrescMode
                movlw   0x05            ; set up delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T4
                goto    dispatchCont

fAwningS02      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fAwningStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fAwningStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T4 has elapsed
                bc      dispatchCont    ; not yet

                movfw   paramPtr2
                movwf   FSR
                clrf    INDF            ; next state is S00 (idle)
                goto    dispatchCont

fAwningC        swapf   funcOutBits,w   ; generate bitmask for close/open (upper nibble)
                pcall   genBitmask
                outputOff               ; switch close/open off (close)
                goto    fAwningS00b

fAwningO        swapf   funcOutBits,w   ; generate bitmask for close/open (upper nibble)
                pcall   genBitmask
                outputOn                ; switch close/open on (open)
                goto    fAwningS00b     ;}


fBlind          ;{
;        +-----+  U-        D-  +-----+
;        | S01 |------+  +------| S11 |
;  +---->|short|  D+  |  |  U+  |short|<----+
;  |     | up  |----->|  |<-----|down |     |
;  |     +-----+      |  |      +-----+     |
;  |        |         |  |         |        |
;  |        | T1      |  |      T1 |        |
;  |        v         |  |         v        |
;  |     +-----+  U-  |  |  D-  +-----+     |
;  |     | S02 |----->|  |<-----| S12 |     |
;  |     |short|  D+  |  |  U+  |short|     |
;  |     |stop |----->|  |<-----|stop |     |
;  |     +-----+      |  |      +-----+     |
;  |        |         |  |         |        |
;  |        | T2      |  |      T2 |        |
;  |        v         |  |         v        |
;  |     +-----+  T3  |  |  T3  +-----+     |
;  |     | S03 |----->|  |<-----| S13 |     |
;  |     |full |  D+  |  |  U+  |full |     |
;  |     | up  |----->|  |<-----|down |     |
;  |     +-----+      |  |      +-----+     |
;  |                  v  v                  |
;  |              +----------+              |
;  |              |    S04   |              |
;  |              |protection|              |
;  |              | interval |              |
;  |              +----------+              |
;  |                    |                   |
;  |                    | T4                |
;  |                    v                   |
;  |                +------+                |
;  |            U+  | S00  |  D+            |
;  +----------------| stop |----------------+
;                   |      |
;                   +------+

                bankisel    functionRam
                btfss   funcUber,4      ; need to check the output bit?
                goto    fBlindA         ; no

                movfw   funcOutBits
                xorwf   funcUber,w
                andlw   0x0f
                bz      fBlindB         ; one of our output bits we searched for

                swapf   funcOutBits,w
                xorwf   funcUber,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

fBlindB         btfsc   funcUber,7      ; test for down/up mode
                goto    fBlindD         ; blinds down
                goto    fBlindU         ; blinds up

fBlindA         btfsc   funcSemaphore,2 ; check for blinds up
                goto    fBlindU

                btfsc   funcSemaphore,3 ; check for blinds down
                goto    fBlindD

                movfw   paramPtr2
                movwf   FSR
                tstf    INDF            ; test for state 00
                bz      fBlindS00

                movlw   0x01
                xorwf   INDF,w          ; test for state 01
                bz      fBlindS01

                movlw   0x02
                xorwf   INDF,w          ; test for state 02
                bz      fBlindS02

                movlw   0x03
                xorwf   INDF,w          ; test for state 03
                bz      fBlindS03

                movlw   0x04
                xorwf   INDF,w          ; test for state 04
                bz      fBlindS04

                goto    fBlindStop      ; nothing matched; set state 00

fBlindS00       btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    dispatchCont

                movlw   0x01            ; next state S01
                movwf   INDF

                swapf   funcOutBits,w   ; generate bitmask for up/down (upper nibble)
                pcall   genBitmask
                btfsc   funcUber,5      ; test if second input key (up) matched
                goto    fBlindS00a      ; no, we move down
                outputOff               ; switch up/down off (up)
                goto    fBlindS00b
fBlindS00a      outputOn                ; switch up/down on (down)
fBlindS00b      movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOn                ; switch power on

                movfw   funcPrescMode   ; set up prescaler
                andlw   0x0f
                iorlw   0x70
                movwf   funcPrescMode
                movlw   0x01            ; set up delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T1
                goto    dispatchCont

fBlindS01       btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fBlindStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fBlindStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T1 has elapsed
                bc      dispatchCont    ; not yet

fBlindS01a      movfw   paramPtr2
                movwf   FSR
                movlw   0x02            ; next state S02
                movwf   INDF

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOff               ; switch power off

                movfw   funcPrescMode   ; set up prescaler
                andlw   0x0f
                iorlw   0x50
                movwf   funcPrescMode
                movlw   0x01            ; set up delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T2
                goto    dispatchCont

fBlindS02       btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fBlindStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fBlindStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T2 has elapsed
                bc      dispatchCont    ; not yet

fBlindS02a      movfw   paramPtr2
                movwf   FSR
                movlw   0x03            ; next state S03
                movwf   INDF

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOn                ; switch power on

                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T3
                goto    dispatchCont

fBlindS03       btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fBlindStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T3 has elapsed
                bc      dispatchCont    ; not yet

fBlindStop      movfw   paramPtr2
                movwf   FSR
                movlw   0x04            ; next state S04 (protection interval)
                movwf   INDF

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for power (lower nibble)
                outputOff               ; switch power off
                swapf   funcOutBits,w   ; generate bitmask for up/down (upper nibble)
                pcall   genBitmask
                outputOff               ; switch up/down off (up)

                movfw   funcPrescMode   ; set up prescaler
                andlw   0x0f
                iorlw   0x10
                movwf   funcPrescMode
                movlw   0x05            ; set up delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T4
                goto    dispatchCont

fBlindS04       btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fBlindStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fBlindStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T4 has elapsed
                bc      dispatchCont    ; not yet

                movfw   paramPtr2
                movwf   FSR
                clrf    INDF            ; next state is S00 (idle)
                goto    dispatchCont

fBlindU         swapf   funcOutBits,w   ; generate bitmask for up/down (upper nibble)
                pcall   genBitmask
                outputOff               ; switch up/down off (up)
                goto    fBlindS01a

fBlindD         swapf   funcOutBits,w   ; generate bitmask for up/down (upper nibble)
                pcall   genBitmask
                outputOn                ; switch up/down on (down)
                goto    fBlindS01a      ;}


fWindow         ;{
;        +-----+  U-        D-  +-----+
;        | S01 |------+  +------| S11 |
;  +---->|short|  D+  |  |  U+  |short|<----+
;  |     | up  |----->|  |<-----|down |     |
;  |     +-----+      |  |      +-----+     |
;  |        |         |  |         |        |
;  |        | T1      |  |      T1 |        |
;  |        v         |  |         v        |
;  |     +-----+  U-  |  |  D-  +-----+     |
;  |     | S02 |----->|  |<-----| S12 |     |
;  |     |short|  D+  |  |  U+  |short|     |
;  |     |stop |----->|  |<-----|stop |     |
;  |     +-----+      |  |      +-----+     |
;  |        |         |  |         |        |
;  |        | T2      |  |      T2 |        |
;  |        v         |  |         v        |
;  |     +-----+  T3  |  |  T3  +-----+     |
;  |     | S03 |----->|  |<-----| S13 |     |
;  |     |full |  D+  |  |  U+  |full |     |
;  |     | up  |----->|  |<-----|down |     |
;  |     +-----+      |  |      +-----+     |
;  |                  v  v                  |
;  |              +----------+              |
;  |              |    S04   |              |
;  |              |protection|              |
;  |              | interval |              |
;  |              +----------+              |
;  |                    |                   |
;  |                    | T4                |
;  |                    v                   |
;  |                +------+                |
;  |            U+  | S00  |  D+            |
;  +----------------| stop |----------------+
;                   |      |
;                   +------+

                bankisel    functionRam
                btfss   funcUber,4      ; need to check the output bit?
                goto    fWindowA        ; no

                movfw   funcOutBits
                xorwf   funcUber,w
                andlw   0x0f
                bz      fWindowB        ; one of our output bits we searched for

                swapf   funcOutBits,w
                xorwf   funcUber,w
                andlw   0x0f
                bnz     dispatchCont    ; not the output bit we searched for

fWindowB        btfsc   funcUber,7      ; test for open/close mode
                goto    fWindowO        ; windows open
                goto    fWindowC        ; windows close

fWindowA        btfsc   funcSemaphore,4 ; check for window close
                goto    fWindowC

                btfsc   funcSemaphore,5 ; check for windows open
                goto    fWindowO

                movfw   paramPtr2
                movwf   FSR
                tstf    INDF            ; test for state 00
                bz      fWindowS00

                movlw   0x01
                xorwf   INDF,w          ; test for state 01
                bz      fWindowS01

                movlw   0x11
                xorwf   INDF,w          ; test for state 11
                bz      fWindowS11

                movlw   0x02
                xorwf   INDF,w          ; test for state 02
                bz      fWindowS02

                movlw   0x12
                xorwf   INDF,w          ; test for state 12
                bz      fWindowS12

                movlw   0x03
                xorwf   INDF,w          ; test for state 03
                bz      fWindowS03

                movlw   0x04
                xorwf   INDF,w          ; test for state 04
                bz      fWindowS04

                goto    fWindowStop     ; nothing matched; set state 00

fWindowS00      btfss   rxInput,4       ; check for pressed key (positive edge)
                goto    dispatchCont

                movlw   0x04            ; we use only the prescaler for this delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T1

                movfw   paramPtr2
                movwf   FSR

                btfss   funcUber,5      ; test if second input key (close) matched
                goto    fWindowS00a     ; no, we are opening

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask open (lower nibble)
                outputOff               ; switch open off
                swapf   funcOutBits,w   ; generate bitmask close (upper nibble)
                pcall   genBitmask
                outputOn                ; switch close on

                movlw   0x01            ; next state S01
                movwf   INDF
                goto    dispatchCont

fWindowS00a     movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask open (lower nibble)
                outputOn                ; switch open on
                swapf   funcOutBits,w   ; generate bitmask close (upper nibble)
                pcall   genBitmask
                outputOff               ; switch close off

                movlw   0x11            ; next state S11
                movwf   INDF
                goto    dispatchCont

fWindowS01      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T1 has elapsed
                bc      dispatchCont    ; not yet

fWindowC        movfw   paramPtr2
                movwf   FSR
                movlw   0x02            ; next state S02
                movwf   INDF

                movfw   funcOutBits     ; generate bitmask open (lower nibble)
                pcall   genBitmask
                outputOff               ; switch open off

                swapf   funcOutBits,w   ; generate bitmask close (upper nibble)
                pcall   genBitmask
                outputOff               ; switch close off

                movlw   0x01            ; we use only the prescaler for this delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T2
                goto    dispatchCont

fWindowS11      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T1 has elapsed
                bc      dispatchCont    ; not yet

fWindowO        movfw   paramPtr2
                movwf   FSR
                movlw   0x12            ; next state S12
                movwf   INDF

                movfw   funcOutBits     ; generate bitmask open (lower nibble)
                pcall   genBitmask
                outputOff               ; switch open off

                swapf   funcOutBits,w   ; generate bitmask close (upper nibble)
                pcall   genBitmask
                outputOff               ; switch close off

                movlw   0x01            ; we use only the prescaler for this delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T2
                goto    dispatchCont

fWindowS02      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T2 has elapsed
                bc      dispatchCont    ; not yet

                movfw   paramPtr2
                movwf   FSR
                movlw   0x03            ; next state S03
                movwf   INDF

                swapf   funcOutBits,w   ; generate bitmask close (upper nibble)
                pcall   genBitmask
                outputOn                ; switch close on

                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T3
                goto    dispatchCont

fWindowS12      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T2 has elapsed
                bc      dispatchCont    ; not yet

                movfw   paramPtr2
                movwf   FSR
                movlw   0x03            ; next state S03
                movwf   INDF

                movfw   funcOutBits     ; generate bitmask open (lower nibble)
                pcall   genBitmask
                outputOn                ; switch open on

                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T3
                goto    dispatchCont

fWindowS03      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T3 has elapsed
                bc      dispatchCont    ; not yet

fWindowStop     movfw   paramPtr2
                movwf   FSR
                movlw   0x04            ; next state S04 (protection interval)
                movwf   INDF

                movfw   funcOutBits
                pcall   genBitmask      ; generate bitmask for open
                outputOff               ; switch open off
                swapf   funcOutBits,w   ; generate bitmask for close
                pcall   genBitmask
                outputOff               ; switch close off

                movlw   0x01            ; we use only the prescaler for this delay
                movwf   funcDelay
                incf    paramPtr2,w
                pcall   genDelay        ; set up delay T4
                goto    dispatchCont

fWindowS04      btfsc   rxInput,4       ; check for pressed key (positive edge)
                goto    fWindowStop
                btfsc   rxInput,5       ; check for released key (negative edge)
                goto    fWindowStop

                incf    paramPtr2,w
                pcall   compareTime     ; check if delay T4 has elapsed
                bc      dispatchCont    ; not yet

                movfw   paramPtr2
                movwf   FSR
                clrf    INDF            ; next state is S00 (idle)
                goto    dispatchCont    ;}
