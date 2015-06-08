fPowerOff		;{
; turns off all outputs (except alwaysOn)
				movfw	rxByte2
				xorlw	0xff			; global power off
				bz		fPowerOff1
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				skpz
				goto	parseRxE

fPowerOff1		clrf	outputLo
				clrf	outputHi
				scall	clearRam2
				goto	parseRxE
				;}

fReset			;{
				movfw	rxByte2
				xorlw	0xff			; global reset
				bz		fReset1
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				skpz
				goto	parseRxE

fReset1			pcall	safeOutput
				goto	0x0000
				;}

fPoll			;{
; return ACK if we are polled
				movfw	rxByte2
				xorwf	deviceID,w		; our deviceID
				bnz		parseRxE		; no

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDACK			; send ACK
				pcall	putTx
				movfw	deviceID		; our deviceID
				pcall	putTx

				goto	parseRxE
				;}

fOff			;{
				movfw	rxByte1
				andlw	0xf0
				xorlw	CMDSOFF			; dedicated output on our device
				bnz		fOff1
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us
				movfw	rxByte1
				andlw	0x0f			; get output number
				movwf	funcUber
				bsf		funcUber,4		; use the output
				goto	fOff2

fOff1			movfw	rxByte2
				andlw	0x01
				skpz
				bsf		funcSemaphore,1	; lights off global
				movfw	rxByte2
				andlw	0x02
				skpz
				bsf		funcSemaphore,2	; blinds up global
				movfw	rxByte2
				andlw	0x04
				skpz
				bsf		funcSemaphore,4	; window close global
				movfw	rxByte2
				andlw	0x08
				skpz
				bsf		funcSemaphore,6	; awning close global

fOff2			bcf		funcUber,7		; set off mode
				bsf		funcUber,6		; set service mode
				pcall	dispatch
				clrf	funcSemaphore
				clrf	funcUber		; set non service mode
				goto	parseRxE
				;}

fOn				;{
				movfw	rxByte1
				andlw	0xf0
				xorlw	CMDSON			; dedicated output on our device
				bnz		fOn1
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us
				movfw	rxByte1
				andlw	0x0f			; get output number
				movwf	funcUber
				bsf		funcUber,4		; use the output
				goto	fOn2

fOn1			movfw	rxByte2
				andlw	0x01
				skpz
				bsf		funcSemaphore,0	; lights on global
				movfw	rxByte2
				andlw	0x02
				skpz
				bsf		funcSemaphore,3	; blinds down global
				movfw	rxByte2
				andlw	0x04
				skpz
				bsf		funcSemaphore,5	; window open global
				movfw	rxByte2
				andlw	0x08
				skpz
				bsf		funcSemaphore,7	; awning open global

fOn2			bsf		funcUber,7		; set on mode
				bsf		funcUber,6		; set service mode
				pcall	dispatch
				clrf	funcSemaphore
				clrf	funcUber		; set non service mode
				goto	parseRxE
				;}

fRdTime			;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDTGACK		; send ACK
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx
				movfw	time			; send time
				pcall	putTx
				movfw	time+1			; send time
				pcall	putTx
				movfw	time+2			; send time
				pcall	putTx
				movfw	time+3			; send time
				pcall	putTx
				movfw	time+4			; send time
				pcall	putTx

				goto	parseRxE
				;}

fWrTime			;{
				movfw	rxByte2
				xorlw	0xff			; global write time
				bz		fWrTime1

				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

fWrTime1		pcall	getRx			; receive time
				bz		fWrTime1
				movwf	time
fWrTime2		pcall	getRx			; receive time
				bz		fWrTime2
				movwf	time+1
fWrTime3		pcall	getRx			; receive time
				bz		fWrTime3
				movwf	time+2
fWrTime4		pcall	getRx			; receive time
				bz		fWrTime4
				movwf	time+3
fWrTime5		pcall	getRx			; receive time
				bz		fWrTime5
				movwf	time+4
				goto	parseRxE

fWrTime6		movlw	0x05
				movwf	skipRxCnt		; 5 bytes to skip
				goto	parseRxE
				;}

fRdConfig		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDCGACK		; send ACK
				pcall	putTx
				movfw	deviceID		; send Device ID (this is also the first byte in the eeprom)
				pcall	putTx
				movlw	0x01
				movwf	cfgTxCnt		; init config transmit counter

				goto	parseRxE
				;}

fWrConfig		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		fWrConfig7		; not us

				clrf	cfgRxCnt
fWrConfig1		pcall	getRx
				bz		fWrConfig1
				movwf	eeByte
				movfw	cfgRxCnt
				movwf	displayram+7
				pcall	eeWrite
				banksel	cfgRxCnt
				incf	cfgRxCnt,f
				movfw	cfgRxCnt
				andlw	0x0f
				bnz		fWrConfig1

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDACK			; send ACK
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx

fWrConfig3		pcall	getRx
				bz		fWrConfig3
fWrConfig4		pcall	getRx
				bz		fWrConfig4
fWrConfig5		pcall	getRx
				bz		fWrConfig5
				movfw	cfgRxCnt
				bnz		fWrConfig1
				goto	main


fWrConfig7		movlw	0x10
				movwf	cfgRxCnt
fWrConfig8		movfw	cfgRxCnt
				movwf	displayram+7
				movlw	0x13
				movwf	skipRxCnt
fWrConfig9		tstf	skipRxCnt		; wait until chunk and ack read
				bnz		fWrConfig9
				decfsz	cfgRxCnt,f
				goto	fWrConfig8
				goto	parseRxE
				;}

fCOutput		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movfw	rxByte1
				andlw	0x0f
				pcall	genBitmask		; generate bitmask for output
				outputOff

				goto	parseRxE
				;}

fSOutput		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movfw	rxByte1
				andlw	0x0f
				pcall	genBitmask		; generate bitmask for output
				outputOn

				goto	parseRxE
				;}

fWrOutputs		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		fWrOutputs3		; not us

fWrOutputs1		pcall	getRx
				bz		fWrOutputs1
				movwf	outputLo
fWrOutputs2		pcall	getRx
				bz		fWrOutputs2
				movwf	outputHi
				goto	parseRxE

fWrOutputs3		pcall	getRx
				bz		fWrOutputs3
fWrOutputs4		pcall	getRx
				bz		fWrOutputs4

				goto	parseRxE
				;}

fRdInput		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDIOANS		; send answer
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx

				movfw	rxByte1
				andlw	0x0f
				pcall	genBitmask		; generate bitmask for output

				movfw	iInputLo		; check lo input
				andwf	bitmaskLo,w
				bnz		fRdInput1

				movfw	iInputHi		; check hi input
				andwf	bitmaskHi,w
				bnz		fRdInput1

				clrw
				pcall	putTx
				clrw
				pcall	putTx
				goto	parseRxE

fRdInput1		movlw	0xff
				pcall	putTx
				movlw	0xff
				pcall	putTx
				goto	parseRxE
				;}

fRdInputs		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDIOANS		; send answer
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx
				movfw	iInputLo		; send Lo Input
				pcall	putTx
				movfw	iInputHi		; send Hi Input
				pcall	putTx

				goto	parseRxE
				;}

fRdOutput		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDIOANS		; send answer
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx

				movfw	rxByte1
				andlw	0x0f
				pcall	genBitmask		; generate bitmask for output

				movfw	outputLo		; check lo output
				andwf	bitmaskLo,w
				bnz		fRdOutput1

				movfw	outputHi		; check hi output
				andwf	bitmaskHi,w
				bnz		fRdOutput1

				clrw
				pcall	putTx
				clrw
				pcall	putTx
				goto	parseRxE

fRdOutput1		movlw	0xff
				pcall	putTx
				movlw	0xff
				pcall	putTx
				goto	parseRxE
				;}

fRdOutputs		;{
				movfw	rxByte2
				xorwf	deviceID,w		; only this device
				bnz		parseRxE		; not us

				movlw	STARTBYTE		; startByte
				pcall	putTx
				movlw	CMDIOANS		; send answer
				pcall	putTx
				movfw	deviceID		; send Device ID
				pcall	putTx
				movfw	outputLo		; send Lo Output
				pcall	putTx
				movfw	outputHi		; send Hi Output
				pcall	putTx

				goto	parseRxE
				;}