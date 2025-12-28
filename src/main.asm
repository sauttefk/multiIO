;******************************************************************************
; turn off crossing page boundary message
   ; ERRORLEVEL -306, -302

#define         revision    4
; Device ID can be overridden with -D device=0xXX
#ifndef device
#define         device      0x01
#endif
#define         bits89      8
#define         baudrate    .38400
;#define         baudrate    .115200

 ifdef  __DEBUG
    __CONFIG    0x03f4      ; debugger
    messg   "Debug mode"
 else
    __CONFIG    0x13c4      ; w/o debugger
 endif


#include        <p16f946.inc>

#include        "defines.asm"
#include        "variables.asm"
#include        "macros.asm"

;**********************************************************************
                org     0x000           ; processor reset vector
                nop                     ; required for the ICD
                lgoto   main            ; go to initialisation of program

;**************** Interrupt service routine **************************
                org     0x004           ; interrupt vector location
#include        "interrupt.asm"
                ;{
                org     0x0800          ; second page
main
                clrf    STATUS          ; ensure we are at bank0
                clrf    INTCON          ; ensure int reg is clear
                clrf    PIR1            ; clear peripheral irqs
                clrf    PIR2            ; dito

                ; make sure all individual irqs are disabled
                movlw   PIE1            ; get address for peripheral irq enable
                movwf   FSR             ; setup fsr
                clrf    INDF            ; and clear irq enable flags

                movlw   PIE2            ; get address for second peripheral irq enable
                movwf   FSR             ; setup fsr
                clrf    INDF            ; and clear irq enable flags

                banksel OSCCON
                movlw   0x71            ; speedup to 8 MHz
                movwf   OSCCON

#if baudrate == .115200
		banksel OSCTUNE
;		movlw	.15		; increase speed by  15 = 8.889MHz for better baudrate accuracy
;		movlw	.14		; increase speed by  14 = 8.831MHz for better baudrate accuracy
;		movlw	.13		; increase speed by  13 = 8.768MHz for better baudrate accuracy
;		movlw	.12		; increase speed by  12 = 8.709MHz for better baudrate accuracy
;		movlw	.11		; increase speed by  11 = 8.650MHz for better baudrate accuracy
;		movlw	.10		; increase speed by  10 = 8.592MHz for better baudrate accuracy
;		movlw	.9		; increase speed by   9 = 8.529MHz for better baudrate accuracy
;		movlw	.8		; increase speed by   8 = 8.470MHz for better baudrate accuracy
;		movlw	.7		; increase speed by   7 = 8.414MHz for better baudrate accuracy
;		movlw	.6		; increase speed by   6 = 8.355MHz for better baudrate accuracy
;		movlw	.5		; increase speed by   5 = 8.293MHz for better baudrate accuracy
;		movlw	.4		; increase speed by   4 = 8.234MHz for better baudrate accuracy
;		movlw	.3		; increase speed by   3 = 8.175MHz for better baudrate accuracy
;		movlw	.2		; increase speed by   2 = 8.117MHz for better baudrate accuracy
;		movlw	.1		; increase speed by   1 = 8.054MHz for better baudrate accuracy
;		movlw	.0		; normal speed      0 = 7.994MHz
;		movlw	-.1		; reduce speed by  -1 = 7.946MHz for better baudrate accuracy
;		movlw	-.2		; reduce speed by - 2 = 7.887MHz for better baudrate accuracy
;		movlw	-.3		; reduce speed by  -3 = 7.824MHz for better baudrate accuracy
;		movlw	-.4		; reduce speed by  -4 = 7.766MHz for better baudrate accuracy
;		movlw	-.5		; reduce speed by  -5 = 7.708MHz for better baudrate accuracy
;		movlw	-.6		; reduce speed by  -6 = 7.650MHz for better baudrate accuracy
;		movlw	-.7		; reduce speed by  -7 = 7.587MHz for better baudrate accuracy
;		movlw	-.8		; reduce speed by  -8 = 7.528MHz for better baudrate accuracy
;		movlw	-.9		; reduce speed by  -9 = 7.473MHz for better baudrate accuracy
;		movlw	-.10		; reduce speed by -10 = 7.415MHz for better baudrate accuracy
		movlw	-.11		; reduce speed by -11 = 7.352MHz for better baudrate accuracy
;		movlw	-.12		; reduce speed by -12 = 7.294MHz for better baudrate accuracy
;		movlw	-.13		; reduce speed by -13 = 7.236MHz for better baudrate accuracy
;		movlw	-.14		; reduce speed by -14 = 7.178MHz for better baudrate accuracy
;		movlw	-.15		; reduce speed by -15 = 7.116MHz for better baudrate accuracy
;		movlw	-.16		; reduce speed by -16 = 7.058MHz for better baudrate accuracy
                movwf   OSCTUNE
#define         XTAL_FREQ   .7352000	; OSC freq in Hz
#else
#if baudrate == .57600
		banksel OSCTUNE
		movlw	.5		; increase speed by   5 = 8.293MHz for better baudrate accuracy
                movwf   OSCTUNE
#define         XTAL_FREQ   .8293000	; OSC freq in Hz
#else
		banksel OSCTUNE
		movlw	.0		; normal speed      0 = 7.994MHz (nominal 8.000MHz)
                movwf   OSCTUNE
#define         XTAL_FREQ   .8000000	; OSC freq in Hz
#endif
#endif
; TODO: Fix messg directive syntax
; messg   Selected CPU Frequency : XTAL_FREQ MHz
 #define rate	CALC_HIGH_BAUD(baudrate)
; TODO: Fix messg directive syntax
; messg   rate

                scall   initPorts
                scall   clearRam
                scall   initParams
                scall   initTimer0
;               scall   initTimer1
                scall   initTimer2
                scall   initUart
                scall   initPlvd
                enableirq

                banksel funcUber
                bsf     funcUber,6      ; call function dispatcher in service mode
                pcall   dispatch

parseRx
;               banksel PIR2
;               btfsc   PIR2,LVDIF      ; detect low voltage
;               goto    powerDown

                movfw   cfgTxCnt        ; check if we are still sending a config frame
                bz      parseRx0

                movfw   txNum
                xorlw   BUFSIZE         ; check if there is free space in the ringbuffer
                bz      parseRx0        ; wait for free space

                movfw   cfgTxCnt
                longcall    eeRead      ; read config eeprom
                banksel cfgTxCnt
                pcall   putTx           ; send config
                banksel cfgTxCnt
                incf    cfgTxCnt,f      ; increment config transmit counter

parseRx0        movfw   skipRxCnt       ; check if we are still skipping a config frame
                bnz     parseRx         ; don't read other commands

                movfw   rxCount
                xorlw   0x00
                bnz     parseRx1

                pcall   getRx
                bz      parseRxX

                xorlw   STARTBYTE       ; check if byte0 == 0
                skpnz
                incf    rxCount,f
                movfw   rxCount

parseRx1        xorlw   0x01
                bnz     parseRx2

                pcall   getRx
                bz      parseRxX

                movwf   rxByte1         ; store byte1
                tstf    rxByte1
                bz      parseRxE
                incf    rxCount,f
                movfw   rxCount

parseRx2        pcall   getRx
                bz      parseRxX

                movwf   rxByte2         ; store byte2

                movfw   rxByte1
                andlw   0xf0
                xorlw   CMDPEDGE        ; check for positive edge on input (0x1Y)
                bz      parseRx3        ; positive edge detected
                xorlw   CMDPEDGE|CMDNEDGE   ; check for negative edge on input (0x2Y)
                bnz     parseRx4        ; no negative edge detected

parseRx3        movfw   rxByte1         ; edge detected
                movwf   rxInput
                movfw   rxByte2
                movwf   rxDevID
                clrf    funcSemaphore
;               clrf    funcService
                bcf     funcUber,6      ; set message dispatcher to non service mode
                pcall   dispatch
                goto    parseRxE
                                        ; neither positive nor negative edge
parseRx4        movfw   rxByte1
                xorlw   CMDOFF          ; check for power off command
                bz      fPowerOff

                movfw   rxByte1
                xorlw   CMDRESET        ; check for reset command
                bz      fReset

                movfw   rxByte1
                xorlw   CMDID           ; check for poll command
                bz      fPoll

                movfw   rxByte1
                xorlw   CMDTSET         ; check for write time
                bz      fWrTime

                movfw   rxByte1
                xorlw   CMDTGET         ; check for read time command
                bz      fRdTime

                movfw   rxByte1
                xorlw   CMDTGACK        ; check for read time answer
                bnz     parseRx5
                movlw   0x05
                movwf   skipRxCnt       ; 5 bytes to skip
                goto    parseRxE

parseRx5        movfw   rxByte1
                xorlw   CMDCGET         ; check for read config command
                bz      fRdConfig

                movfw   rxByte1
                xorlw   CMDCSET         ; check for write config command
                bz      fWrConfig

                movfw   rxByte1
                xorlw   CMDOWR          ; check for write outputs command
                bz      fWrOutputs

                movfw   rxByte1
                xorlw   CMDIRD          ; check for read inputs command
                bz      fRdInputs

                movfw   rxByte1
                xorlw   CMDORD          ; check for read outputs command
                bz      fRdOutputs

                movfw   rxByte1
                xorlw   CMDIOANS        ; check for read inputs/outputs answer
                bnz     parseRx6
                movlw   0x02
                movwf   skipRxCnt       ; 2 bytes to skip
                goto    parseRxE

parseRx6        movfw   rxByte1
                andlw   0xf0
                xorlw   CMDI            ; read input Y on device ID
                bz      fRdInput

                movfw   rxByte1
                andlw   0xf0
                xorlw   CMDO            ; read output Y on device ID
                bz      fRdOutput

                movfw   rxByte1
                andlw   0xf0
                xorlw   CMDOC           ; clear output Y on device ID
                bz      fCOutput

                movfw   rxByte1
                andlw   0xf0
                xorlw   CMDOS           ; set output Y on device ID
                bz      fSOutput

                movfw   rxByte1
                andlw   0xe0
                xorlw   CMDSOFF         ; check for blinds up/windows close/lights off command
                bz      fOff

                movfw   rxByte1
                andlw   0xe0
                xorlw   CMDSON          ; check for blinds down/windows open/lights on command
                bz      fOn

parseRxE        clrf    rxCount
parseRxX
                banksel funcUber
                bsf     funcUber,6      ; call function dispatcher in service mode
                pcall   dispatch

mainLoop1
                banksel msgNum
                tstf    msgNum          ; check if there are messages in the ringbuffer queue
                bz      mainLoop2       ; queue is empty

                movfw   msgGetPtr       ; current queue read pointer
                addlw   LOW(msgBuf)     ; base address of message buffer queue
                bankisel    msgBuf
                movwf   FSR             ; set FSR to current queue read position
                movff   INDF,msgLo      ; get
                incf    FSR,F
                movff   INDF,msgHi
                incf    FSR,F
                movfw   INDF
                andwf   msgLo,F
                incf    FSR,F
                movfw   INDF
                andwf   msgHi,F
                iorwf   msgLo,W
                bz      genMessage2

                movlw   0xff
                movwf   msgID           ; initialise bit counter

genMessage1     incf    msgID,F
                movfw   msgID
                xorlw   0x10
                bz      genMessage2     ; exit if all 16 bits checked
                rrf     msgHi,F
                rrf     msgLo,F
                bnc     genMessage1     ; no change in this bit continue with next

                movlw   0x00
                pcall   putTx
                movfw   msgID
                iorlw   0x10            ; positive edge
                pcall   putTx
                movfw   deviceID
                pcall   putTx
                goto    genMessage1

genMessage2     movfw   msgGetPtr       ; current read pointer
                addlw   LOW(msgBuf)     ; base address of message buffer
                movwf   FSR             ; set FSR to current read position
                movfw   INDF
                xorlw   0xff
                movwf   msgLo
                incf    FSR,F
                movfw   INDF
                xorlw   0xff
                movwf   msgHi
                incf    FSR,F
                movfw   INDF
                andwf   msgLo,F
                incf    FSR,F
                movfw   INDF
                andwf   msgHi,F
                iorwf   msgLo,W
                bz      genMessage4

                movlw   0xff
                movwf   msgID           ; initialise bit counter

genMessage3     incf    msgID,F
                movfw   msgID
                xorlw   0x10
                bz      genMessage4     ; exit if all 16 bits checked
                rrf     msgHi,F
                rrf     msgLo,F
                bnc     genMessage3     ; no change in this bit continue with next

                movlw   0x00
                pcall   putTx
                movfw   msgID
                iorlw   0x20            ; negative edge
                pcall   putTx
                movfw   deviceID
                pcall   putTx
                goto    genMessage3

genMessage4     movlw   0x04
                addwf   msgGetPtr,F     ; increment write pointer by 4
                movlw   (MSGBUFSIZE)-1  ; MSGBUFSIZE must be a power of 2
                andwf   msgGetPtr,F     ; mask write pointer to get easy wrap around
                movlw   -0x04
                addwf   msgNum,F        ; decrement number of bytes in ringbuffer

mainLoop2       goto    parseRx


powerDown       disableirq
                bcf     PIR2,LVDIF      ; clear low voltage detection bit
                pcall   safeOutput
                banksel WDTCON
                movlw   0x13
                movwf   WDTCON
                enableirq
endless         goto    parseRx         ;}


#include        "dispatch.asm"
#include        "functions.asm"
#include        "uberfunctions.asm"
#include        "serial.asm"
#include        "utils.asm"
#include        "eeprom.asm"
                org     0x1800          ; third page
#include        "init.asm"
#include        "parameter.asm"

;
;           PIC16CXX SPECIAL INSTRUCTION MNEMONICS
;
;     Name                Mnemonic       Equivalent       Status
;                                       Operation(s)
;Clear Carry                CLRC        BCF      3,0        -
;Clear Digit Carry          CLRDC       BCF      3,1        -
;Set Digit Carry            SETDC       BSF      3,1        -
;Clear Zero                 CLRZ        BCF      3,2        -
;Set Zero                   SETZ        BSF      3,2        -
;Skip on Carry              SKPC        BTFSS    3,0        -
;Skip on No Carry           SKPNC       BTFSC    3,0        -
;Skip on Digit Carry        SKPDC       BTFSS    3,1        -
;Skip on No Digit Carry     SKPNDC      BTFSC    3,1        -
;Skip on Zero               SKPZ        BTFSS    3,2        -
;Skip on Non Zero           SKPNZ       BTFSC    3,2        -
;Test File                  TSTF f      MOVF     f,1        Z
;Move File to W             MOVFW f     MOVF     f,0        Z
;Negate File                NEGF f,d    COMF     f,1
;                                       INCF     f,d        Z
;Add Carry to File          ADDCF f,d   BTFSC    3,0
;                                       INCF     f,d        Z
;Subtract Carry from File   SUBCF f,d   BTFSC    3,0
;                                       DECF     f,d        Z
;Add Digit Carry to File    ADDDCF f,d  BTFSC    3,1
;                                       INCF     f,d        Z
;Subtract Digit             SUBDCF f,d  BTFSC    3,1
;Carry from File                        DECF     f,d        Z
;Branch                     B k         GOTO     k          -
;Branch on Carry            BC k        BTFSC    3,0
;                                       GOTO     k          -
;Branch on No Carry         BNC k       BTFSS    3,0
;                                       GOTO     k          -
;Branch on Digit Carry      BDC k       BTFSC    3,1
;                                       GOTO     k          -
;Branch on No Digit Carry   BNDC k      BTFSS    3,1
;                                       GOTO     k          -
;Branch on Zero             BZ k        BTFSC    3,2
;                                       GOTO     k          -
;Branch on Non Zero         BNZ k       BTFSS    3,2
;                                       GOTO     k          -
;Call across page boundary  LCALL k     BCF 3,5 or BSF 3,5
;                                       BCF 3,6 or BSF 3,6
;                                       CALL     k
                end
