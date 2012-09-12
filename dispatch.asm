dispatch
; iterates through parameter table and checks for matching deviceIDs and inputs
				banksel	paramPtr1
				movlw	actionbase		; initialise variables
				movwf	paramPtr1
				movlw	low(functionRam)
				movwf	paramPtr2
				clrf	funcTypeInput
				clrf	funcDevID1
				clrf	funcDevID2

				btfsc	funcUber,6		; test if in service mode
				clrf	rxInput			; clear if in service mode

										; loop start
dispatchLoop	movlw	prescale_Mode
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcPrescMode
				movwf	funcPrescMode	; function mode (low nibble), delay prescaler (high nibble)
				skpnz
				return					; exit if mode is zero (regular exit)

				pcall	numParameter	; number of eeprom parameters
				movwf	temp1

				bcf		funcUber,5		; clear second input matched semaphore
				
				movlw	output
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcOutBits
				movwf	funcOutBits		; output byte (lower nibble output 1, upper nibble output 2)
				andlw	0x0f			; get pointer to parameter ram of output 1
				movwf	paramPtr2
				rlf		paramPtr2,f
				addwf	paramPtr2,f
				rlf		paramPtr2,f
				movlw	low(functionRam)
				addwf	paramPtr2,f
				movfw	paramPtr2
				addlw	-0x6e
				bnc		dispatchLoop1
				movlw	0x32	
				addwf	paramPtr2,f
				
dispatchLoop1	swapf	funcOutBits,w	; get pointer to parameter ram of output 2
				andlw	0x0f
				movwf	paramPtr3
				rlf		paramPtr3,f
				addwf	paramPtr3,f
				rlf		paramPtr3,f
				movlw	low(functionRam)
				addwf	paramPtr3,f
				movfw	paramPtr3
				addlw	-0x6e
				bnc		dispatchLoop2
				movlw	0x32	
				addwf	paramPtr3,f

dispatchLoop2	movfw	temp1			; number of eeprom parameters
				xorlw	0x02
				bz		dispatchLoop5	; already got 2 parameters

				btfsc	funcUber,6		; test if in service mode
				goto	dispatchLoop4	; we are in service mode => no device id parameters nedded

				movlw	devID1
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcDevID1
				movwf	funcDevID1		; device ID 1
				xorwf	rxDevID,w
				bnz		dispatchLoop3

				movlw	input
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcTypeInput
				movwf	funcTypeInput	; input port1 (low nibble), input port2 (high nibble)
				xorwf	rxInput,w
				andlw	0x0f
				bz		dispatchLoop4
				
dispatchLoop3	movfw	temp1			; number of eeprom parameters
				xorlw	0x06
				bnz		dispatchCont	; no device ID2 parameter needed
				
				movlw	devID2
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcDevID2
				movwf	funcDevID2		; device ID 2
				xorwf	rxDevID,w
				bnz		dispatchCont

				swapf	funcTypeInput,w	; input port1 (low nibble), input port2 (high nibble)
				xorwf	rxInput,w
				andlw	0x0f
				bnz		dispatchCont

				bsf		funcUber,5		; set second input matched semaphore
				
dispatchLoop4	movfw	temp1
				addlw	-0x05
				bnc		dispatchLoop5	; less than 5 parameters needed

				movlw	delay
				addwf	paramPtr1,w
				longcall	eeRead
				banksel	funcDelay
				movwf	funcDelay		; delay (value is prescaled)

dispatchLoop5	movfw	funcPrescMode
				andlw	0x0f
				tabj
				return					; mode 0 - exit
				goto	fPassThrough	; mode 1 - passthrough
				goto	fAlwaysOff		; mode 2 - always off
				goto	fAlwaysOn		; mode 3 - always on
				goto	fToggle			; mode 4 - toggle light
				goto	fToggleDual		; mode 5 - light toogle dual outputs
				goto	fTwoStage		; mode 6 - two stage light (output1: 1st stage output2 2nd stage)
				return					; mode 7 - nop
				goto	fTimerR			; mode 8 - retriggerable timer
				goto	fBlinker		; mode 9 - blinker
				return					; mode a - nop
				return					; mode b - nop
				return					; mode c - nop
				goto	fAwning			; mode d - awning (output1: on/off output2: open/close)
				goto	fBlind			; mode e - blind (output1: on/off output2: up/down)
				goto	fWindow			; mode f - window (output1: down output2: close)

dispatchCont	pcall	numParameter
				addwf	paramPtr1,f
				goto	dispatchLoop
				
numParameter	clrf	temp2
				movfw	funcPrescMode
				andlw	0xf0
				skpz	
				bsf		temp2,4
				movfw	funcPrescMode
				andlw	0x0f
				iorwf	temp2,w
				tabj
				;prescale not set
				retlw	0x00			; mode 0 - exit
				retlw	0x04			; mode 1 - passthrough
				retlw	0x02			; mode 2 - always off
				retlw	0x02			; mode 3 - always on
				retlw	0x04			; mode 4 - toggle light
				retlw	0x04			; mode 5 - light toogle dual outputs
				retlw	0x04			; mode 6 - two stage light (output1: 1st stage output2 2nd stage)
				retlw	0x00			; mode 7 - nop
				retlw	0x05			; mode 8 - retriggerable timer
				retlw	0x06			; mode 9 - blinker
				retlw	0x00			; mode a - nop
				retlw	0x00			; mode b - nop
				retlw	0x00			; mode c - nop
				retlw	0x06			; mode d - awning (output1: on/off output2: open/close)
				retlw	0x06			; mode e - blind (output1: on/off output2: up/down)
				retlw	0x06			; mode f - window (output1: down output2: close)
				;prescale set
				retlw	0x00			; mode 0+ - exit
				retlw	0x04			; mode 1+ - passthrough
				retlw	0x02			; mode 2+ - always off
				retlw	0x02			; mode 3+ - always on
				retlw	0x05			; mode 4+ - toggle light
				retlw	0x05			; mode 5+ - light toogle dual outputs
				retlw	0x05			; mode 6+ - two stage light (output1: 1st stage output2 2nd stage)
				retlw	0x00			; mode 7+ - nop
				retlw	0x05			; mode 8+ - retriggerable timer
				retlw	0x06			; mode 9+ - blinker
				retlw	0x00			; mode a+ - nop
				retlw	0x00			; mode b+ - nop
				retlw	0x00			; mode c+ - nop
				retlw	0x06			; mode d+ - awning (output1: on/off output2: open/close)
				retlw	0x06			; mode e+ - blind (output1: on/off output2: up/down)
				retlw	0x06			; mode f+ - window (output1: down output2: close)