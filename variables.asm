				cblock	0x20
VARIABLES		;{
deviceID:		1

iInSampleLo:	1
iInSampleHi:	1
iInSampleAux:	1
iInputLo:		1
iInputHi:		1
iInputAux:		1
iEdgeLo:		1
iEdgeHi:		1
iEdgeAux:		1
iDebounceLoA:	1
iDebounceHiA:	1
iDebounceAuxA:	1
iDebounceLoB:	1
iDebounceHiB:	1
iDebounceAuxB:	1

bitmaskLo:		1
bitmaskHi:		1
outputLo:		1
outputHi:		1

rxCount:		1
rxByte1:		1
rxByte2:		1
rxDevID:		1
rxInput:		1

paramPtr1:		1
paramPtr2:		1
paramPtr3:		1
funcPrescMode:	1
funcOutBits:	1
funcTypeInput:	1
funcDevID1:		1
funcDevID2:		1
funcDelay:		1
funcNumParams:	1
funcSemaphore:	1
funcUber:		1

txPutPtr:		1
txGetPtr:		1
txNum:			1

rxPutPtr:		1
rxGetPtr:		1
rxNum:			1

msgPutPtr:		1
msgGetPtr:		1
msgNum:			1

msgLo:			1
msgHi:			1
msgID:			1

cfgRxCnt:		1
cfgTxCnt:		1
skipRxCnt:		1

iCount:			1
iTemp1:			1
iTemp2:			1
iTemp3:			1

eeByte:			1

crc:			1

iDisplayCount:	1
displayram:		0x0e


ramOverFlow		; don't remove 
				endc

				if ramOverFlow > 70
					error "no more ram"
				endif

				cblock	0x70
safedW:			1
safedSTATUS:	1
safedPCLATH:	1
safedFSR:		1
time:			5
tabTemp:		1
iTabTemp:		1
temp1:			1
temp2:			1
temp3:			1
temp4:			1
temp5:			1
				endc
			
				cblock 0xa0
rxBuf:			BUFSIZE
txBuf:			BUFSIZE
msgBuf:			MSGBUFSIZE

				endc
				cblock	0xf0	; clone of 0xf0-0xff
clone70_7f_1:	0x10
				endc
	
				cblock	0x120
functionRam:	0x50
				endc
	
				cblock	0x170	; clone of 0x170-0x7f
clone70_7f_2:	0x10
				endc
				
				cblock	0x1a0
functionRam2:	0x50
				endc
				
				cblock	0x1f0	; clone of 0x1f0-0x1ff
clone70_7f_3:	0x10
				endc
;}
