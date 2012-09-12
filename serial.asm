putTx			;{	
				movwf	temp1			; temporarily save the char to be sent
				banksel	txNum
putTx1			movfw	txNum			
				xorlw	BUFSIZE			; check if there is free space in the ringbuffer
				bz		putTx1			; wait for free space
				
				movfw	txPutPtr		; current write pointer
				addlw	LOW(txBuf)		; base adress of tx buffer
				movwf	FSR				; set FSR to current write position
				bankisel	txBuf
				movff	temp1,INDF		; store char into ringbuffer
				incf	txPutPtr,f		; increment write pointer
				movlw	(BUFSIZE)-1		; BUFSIZE must be to the power of 2
				andwf	txPutPtr,f		; mask write pointer to get easy wrap around
				incf	txNum,f			; increment number of bytes in ringbuffer
				movlw	PIE1			; get adress for periphial irq
				movwf	FSR				; setup fsr
				bsf		INDF,TXIE		; and enable tx irq
				return	;}

	
getRx			;{
				disableirq
				banksel rxNum
				movfw	rxNum			; check if there is a character in the ringbuffer
				bz		getRx1
				
				movfw	rxGetPtr		; curret read pointer
				addlw	LOW(rxBuf)		; base adress of rx buffer
				movwf	FSR				; set FSR to current read position
				bankisel	rxBuf
				incf	rxGetPtr,f		; increment read pointer
				movlw	(BUFSIZE)-1		; BUFSIZE must be to the power of 2
				andwf	rxGetPtr,f		; mask read pointer to get easy wrap around
				movfw	INDF			; get char from ringbuffer
				decf	rxNum,f			; decrement number of bytes in ringbuffer
				enableirq
				clrz					; clear zero flag
				return
				
getRx1			enableirq
				setz					; set zero flag
				return	;}


