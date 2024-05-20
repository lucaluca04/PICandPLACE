;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F73. This file contains the basic code                *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    xxx.asm                                           *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F73.INC                                       *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f73		; list directive to define processor
	#include	<p16f73.inc>	; processor specific variable definitions
	
	errorlevel  2          ; suppress message 302 from list file
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.




;***** VARIABLE DEFINITIONS
; Bank 0 speicherplatz 0x20 Bis 0x7F  96 Bytes
; Bank 1 speicherplatz 0xA0 Bis 0xFF  96 Bytes
;---------------------------------
;***** VARIABLE BANK 0
;---------------------------------
stepperdelay	equ	0x20
stepperdelay1	equ	0x21
stepps			equ	0x22

stepps1			equ	0x23	;0,1mm
stepps2			equ	0x24	;1mm
stepps3			equ	0x25	;10mm
stepps4			equ	0x26	;100mm
stepp			equ	0x27	;0,1mm

rx1				equ	0x28
rx2				equ	0x29
rx3				equ	0x2A
rx4				equ	0x2B
rx5				equ	0x2C
rx6				equ	0x3D

x4cur			equ	0x2D
x3cur			equ	0x2E
x2cur			equ	0x2F
x1cur			equ	0x30

motdrcon		equ	0x31

rxac			equ	0x32

motorselect		equ	0x33

y4cur			equ	0x34
y3cur			equ	0x35
y2cur			equ	0x36
y1cur			equ	0x37

z4cur			equ	0x38
z3cur			equ	0x39
z2cur			equ	0x3A
z1cur			equ	0x3B

graber			equ	0x3C




;---------------------------------
	temp	equ	0x7F
;---------------------------------
;		PIN DEFINTIONS
;---------------------------------
	#define	DEBUGLED	PORTC,2
	#define	ST1			PORTB,0
	#define	DIR1		PORTB,1
	#define	ST2			PORTB,2
	#define	DIR2		PORTB,3
	#define	ST3			PORTB,4
	#define	DIR3		PORTB,5
	#define	pump		PORTC,2	
;**********************************************************************
	ORG     0x00            ; processor reset vector
goto		init
	ORG		0x04			; reset vector

;---------------------------------
getcode
;	lehrzeihen
	retlw		0x00
	retlw		0x00
	retlw		0x00
	retlw		0x00
	retlw		0x00
	retlw		0x00
	retlw		0x00
	retlw		0x00	
return
;---------------------------------
;		Start routine PWM
;---------------------------------	
	movlw		B'00000100'
	movwf		T2CON
	movlw		B'00001111'
	movwf		CCP1CON
	movlw		B'00001111'
	movwf		CCP2CON
	movlw		0xFF
	movwf		PR2
	clrf		CCPR1L
	clrf		CCPR2L
	movlw		.37					; linke seite
	movwf		CCPR1L
	movlw		.40					; rechte seite
	movwf		CCPR2L
;---------------------------------
;		Start routine ADC
;---------------------------------	
	movlw		B'01000001'
	movwf		ADCON0
;---------------------------------
;		Start routine PIC
;---------------------------------
init
	clrf		PORTB
	clrf		PORTA
	clrf		PORTC

	bsf 		STATUS,RP0		;Bank 1
	movlw		B'00100011' ;Porta alles output ganz rechts ist bit 0 
	movwf 		TRISA
	movlw		B'00000000' ;Portb alles output ganz rechts ist bit 0
	movwf		TRISB
	movlw		B'10000000' ;Portc alles output ganz rechts ist bit 0
	movwf		TRISC
	movlw		B'00000100'
	movwf		ADCON1
;	movlw		B'00100010'		; 600 baudrate
	movlw		B'00100110'		;9600 baudrate
	movwf		TXSTA
;	movlw		.207			; 600 baudrate
	movlw		.51				;9600 bautrate
	movwf		SPBRG
	bcf    		STATUS, RP0	; Bank 0
	movlw		B'10010000'	
	movwf		RCSTA
	clrf		PORTB
	clrf		rxac
	clrf		motdrcon
	clrf		x4cur
	clrf		x3cur
	clrf		x2cur
	clrf		x1cur
	clrf		motorselect
	clrf		y4cur
	clrf		y3cur
	clrf		y2cur
	clrf		y1cur
	clrf		z4cur
	clrf		z3cur
	clrf		z2cur
	clrf		z1cur
	
goto    Main              ; go to beginning of program

;stepps				equ	0x23	;0,1mm
;stepps2			equ	0x24	;1mm
;stepps3			equ	0x25	;10mm
;stepps4			equ	0x26	;100mm

;---------------------------------
;		MAIN
;---------------------------------
Main

	clrf		rx1
	clrf		rx2
	clrf		rx3	
	clrf		rx4
	clrf		rx5
	btfss		rxac,0
	goto		rxfirstrx
	bcf			rxac,0
			
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x4F
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x4B
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x0D
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x0A
	movwf	TXREG
rxfirstrx
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx1
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx2
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx3
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx4
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx5
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout	
	nop	
	btfss	PIR1,RCIF
goto		$-1
	movfw	RCREG
	movwf	rx6
	sublw	0x0A
	btfsc	STATUS,Z
	goto	rxout	
rxout	
	movlw	0x0F
	andwf	rx2,f
	andwf	rx3,f
	andwf	rx4,f
	andwf	rx5,f
		
	movfw	rx1
	sublw	'X'
	btfsc	STATUS,Z
	call	Xcallcul
finxcall
	movfw	rx1
	sublw	'Y'
	btfsc	STATUS,Z
	call	Ycallcul
finycall
	movfw	rx1
	sublw	'Z'
	btfsc	STATUS,Z
	call	Zcallcul
finzcall
	movfw	rx1
	sublw	'G'
	btfsc	STATUS,Z
	call	Gcallcul
	nop
fincallcul
	bsf		rxac,0
Veerioninfo
	movfw	rx1
	sublw	'V'
	btfsc	STATUS,Z
	call	Sendversion
goto		Main

;x4cur			equ	0x2D
;x3cur			equ	0x2E
;x2cur			equ	0x2F
;x1cur			equ	0x30

;motdrcon		equ	0x31
;---------------------------------
;		Xrechnen
;---------------------------------
Gcallcul
	movlw	.0
	subwf	rx2
	btfsc	STATUS,Z
	bcf		pump
	movlw	.1
	subwf	rx2
	btfsc	STATUS,Z
	bsf		pump
goto		fincallcul
;---------------------------------
;		Xrechnen
;---------------------------------
Xcallcul
	movfw	rx2			;1
	subwf	x4cur,w		;1-5=253
	btfsc	STATUS,Z	;nein
goto		Xcallcul2	;nein
	btfsc	STATUS,C	;wird gesprungen
goto		xcallneg1	;wird gesprungen
	movfw	x4cur		;5
	subwf	rx2,w		;5-1=4	
	movwf	stepps3		;4
	movfw	rx2			;1
	movwf	x4cur		;1
	bsf		motdrcon,0	;direcon
goto		xmovingall1	;
xcallneg1
	movwf	stepps3		;1	
	bcf		motdrcon,0	;richtung
	movfw	rx2			;1
	movwf	x4cur		;curpos
xmovingall1	
	bsf		motorselect,0
	call	x100mmrechs
	bcf		motorselect,0
;---------------------------------
Xcallcul2
	movfw	rx3
	subwf	x3cur,w
	btfsc	STATUS,Z
goto		Xcallcul3
	btfsc	STATUS,C
goto		xcallneg2
	movfw	x3cur
	subwf	rx3,w
	movwf	stepps2
	movfw	rx3
	movwf	x3cur
	bsf		motdrcon,0
goto		xmovingall2
xcallneg2
	movwf	stepps2
	bcf		motdrcon,0
	movfw	rx3
	movwf	x3cur
xmovingall2
	bsf		motorselect,0
	call	x10mmrechs	
	bcf		motorselect,0
;---------------------------------
Xcallcul3
	movfw	rx4
	subwf	x2cur,w
	btfsc	STATUS,Z
goto		Xcallcul4
	btfsc	STATUS,C
goto		xcallneg3
	movfw	x2cur
	subwf	rx4,w
	movwf	stepps1
	movfw	rx4
	movwf	x2cur
	bsf		motdrcon,0
goto		xmovingall3
xcallneg3
	movwf	stepps1
	bcf		motdrcon,0
	movfw	rx4
	movwf	x2cur
xmovingall3
	bsf		motorselect,0
	call	x1mmrechs
	bcf		motorselect,0
;---------------------------------
Xcallcul4
	movfw	rx5
	subwf	x1cur,w
	btfsc	STATUS,Z
goto		finxcall
	btfsc	STATUS,C
goto		xcallneg4
	movfw	x1cur
	subwf	rx5,w
	movwf	stepps
	movfw	rx5
	movwf	x1cur
	bsf		motdrcon,0
goto		xmovingall4
xcallneg4
	movwf	stepps
	bcf		motdrcon,0
	movfw	rx5
	movwf	x1cur	
xmovingall4	
	bsf		motorselect,0
	call 	x01mmrechs
	bcf		motorselect,0
goto		finxcall
;---------------------------------
;		Sendverson
;---------------------------------
Sendversion
	movlw	'V'
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	'1'
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	'.'
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	'0'
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	'1'
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x0D
	movwf	TXREG
	nop
	btfss	PIR1,TXIF
goto		$-1
	movlw	0x0A
	movwf	TXREG
	btfss	PIR1,TXIF
goto		$-1
return
;---------------------------------
;		Yrechnen
;---------------------------------
Ycallcul
	movfw	rx2			;1
	subwf	y4cur,w		;1-5=253
	btfsc	STATUS,Z	;nein
goto		Ycallcul2	;nein
	btfsc	STATUS,C	;wird gesprungen
goto		ycallneg1	;wird gesprungen
	movfw	y4cur		;5
	subwf	rx2,w		;5-1=4	
	movwf	stepps3		;4
	movfw	rx2			;1
	movwf	y4cur		;1
	bsf		motdrcon,1	;direcon
goto		ymovingall1	;
ycallneg1
	movwf	stepps3		;1	
	bcf		motdrcon,1	;richtung
	movfw	rx2			;1
	movwf	y4cur		;curpos
ymovingall1	
	bsf		motorselect,1
	call	x100mmrechs
	bcf		motorselect,1
;---------------------------------
Ycallcul2
	movfw	rx3
	subwf	y3cur,w
	btfsc	STATUS,Z
goto		Ycallcul3
	btfsc	STATUS,C
goto		ycallneg2
	movfw	y3cur
	subwf	rx3,w
	movwf	stepps2
	movfw	rx3
	movwf	y3cur
	bsf		motdrcon,1
goto		ymovingall2
ycallneg2
	movwf	stepps2
	bcf		motdrcon,1
	movfw	rx3
	movwf	y3cur
ymovingall2
	bsf		motorselect,1
	call	x10mmrechs	
	bcf		motorselect,1
;---------------------------------
Ycallcul3
	movfw	rx4
	subwf	y2cur,w
	btfsc	STATUS,Z
goto		Ycallcul4
	btfsc	STATUS,C
goto		ycallneg3
	movfw	y2cur
	subwf	rx4,w
	movwf	stepps1
	movfw	rx4
	movwf	y2cur
	bsf		motdrcon,1
goto		ymovingall3
ycallneg3
	movwf	stepps1
	bcf		motdrcon,1
	movfw	rx4
	movwf	y2cur
ymovingall3
	bsf		motorselect,1
	call	x1mmrechs
	bcf		motorselect,1
;---------------------------------
Ycallcul4
	movfw	rx5
	subwf	y1cur,w
	btfsc	STATUS,Z
goto		finycall
	btfsc	STATUS,C
goto		ycallneg4
	movfw	y1cur
	subwf	rx5,w
	movwf	stepps
	movfw	rx5
	movwf	y1cur
	bsf		motdrcon,1
goto		xmovingall4
ycallneg4
	movwf	stepps
	bcf		motdrcon,1
	movfw	rx5
	movwf	y1cur	
ymovingall4	
	bsf		motorselect,1
	call 	x01mmrechs
	bcf		motorselect,1
goto		finycall
;---------------------------------
;		Zrechnen
;---------------------------------
Zcallcul
	movfw	rx2			;1
	subwf	z4cur,w		;1-5=253
	btfsc	STATUS,Z	;nein
goto		Zcallcul2	;nein
	btfsc	STATUS,C	;wird gesprungen
goto		zcallneg1	;wird gesprungen
	movfw	z4cur		;5
	subwf	rx2,w		;5-1=4	
	movwf	stepps3		;4
	movfw	rx2			;1
	movwf	z4cur		;1
	bsf		motdrcon,2	;direcon
goto		zmovingall1	;
zcallneg1
	movwf	stepps3		;1	
	bcf		motdrcon,2	;richtung
	movfw	rx2			;1
	movwf	z4cur		;curpos
zmovingall1	
	bsf		motorselect,2
	call	x100mmrechs
	bcf		motorselect,2
;---------------------------------
Zcallcul2
	movfw	rx3
	subwf	z3cur,w
	btfsc	STATUS,Z
goto		Zcallcul3
	btfsc	STATUS,C
goto		zcallneg2
	movfw	z3cur
	subwf	rx3,w
	movwf	stepps2
	movfw	rx3
	movwf	z3cur
	bsf		motdrcon,2
goto		zmovingall2
zcallneg2
	movwf	stepps2
	bcf		motdrcon,2
	movfw	rx3
	movwf	z3cur
zmovingall2
	bsf		motorselect,2
	call	x10mmrechs	
	bcf		motorselect,2
;---------------------------------
Zcallcul3
	movfw	rx4
	subwf	z2cur,w
	btfsc	STATUS,Z
goto		Zcallcul4
	btfsc	STATUS,C
goto		zcallneg3
	movfw	z2cur
	subwf	rx4,w
	movwf	stepps1
	movfw	rx4
	movwf	z2cur
	bsf		motdrcon,2
goto		zmovingall3
zcallneg3
	movwf	stepps1
	bcf		motdrcon,2
	movfw	rx4
	movwf	z2cur
zmovingall3
	bsf		motorselect,2
	call	x1mmrechs
	bcf		motorselect,2
;---------------------------------
Zcallcul4
	movfw	rx5
	subwf	z1cur,w
	btfsc	STATUS,Z
goto		finzcall
	btfsc	STATUS,C
goto		zcallneg4
	movfw	z1cur
	subwf	rx5,w
	movwf	stepps
	movfw	rx5
	movwf	z1cur
	bsf		motdrcon,2
goto		zmovingall4
zcallneg4
	movwf	stepps
	bcf		motdrcon,2
	movfw	rx5
	movwf	z1cur	
zmovingall4	
	bsf		motorselect,2
	call 	x01mmrechs
	bcf		motorselect,2
goto		finzcall
;---------------------------------
;		Motor X drehen 100mm
;---------------------------------
x100mmrechs
	movfw		stepps3
	sublw		.0
	btfsc		STATUS,Z
return
x100mmrechsloop
	movlw		.10
	movwf		stepps2
	call		x10mmrechs
	decfsz		stepps3
goto			x100mmrechsloop
return
;---------------------------------
;		Motor X drehen 10mm
;---------------------------------
x10mmrechs
	movfw		stepps2
	sublw		.0
	btfsc		STATUS,Z
return
x10mmrechsloop
	movlw		.10
	movwf		stepps1
	call		x1mmrechs
	decfsz		stepps2
goto			x10mmrechsloop
return
;---------------------------------
;		Motor X drehen 1mm
;---------------------------------
x1mmrechs
	movfw		stepps1
	sublw		.0
	btfsc		STATUS,Z
return
x1mmrechsloop
	movlw		.10
	movwf		stepps
	call		x01mmrechs
	decfsz		stepps1
goto			x1mmrechsloop
return
;---------------------------------
;		Motor X drehen 01mm
;---------------------------------
x01mmrechs
	movfw		stepps
	sublw		.0
	btfsc		STATUS,Z
return
x01mmrechsloop
	call		x001mmrechs
	decfsz		stepps
goto			x01mmrechsloop
return
;---------------------------------
;		Motor X drehen 01mm
;---------------------------------
x001mmrechs
	btfsc		motdrcon,0
	bsf			DIR1
	btfss		motdrcon,0
	bcf			DIR1
	btfsc		motdrcon,1
	bcf			DIR2
	btfss		motdrcon,1
	bsf			DIR2
	btfsc		motdrcon,2
	bsf			DIR3
	btfss		motdrcon,2
	bcf			DIR3
	nop
	nop
	movlw		.8
	movwf	stepp
	btfss	motorselect,2
goto		x001mmrechsloop
	movlw	.32
	addwf	stepp

;	motorselect
x001mmrechsloop
	btfsc		motorselect,0
	bsf			ST1
	btfsc		motorselect,1
	bsf			ST2
	btfsc		motorselect,2
	bsf			ST3
	call		stepdelay
	bcf			ST1
	bcf			ST2
	bcf			ST3
	call		stepdelay
	decfsz		stepp
goto			x001mmrechsloop	
	bcf		motorselect,2
return
;---------------------------------
;		stepper min 2mS delay
;---------------------------------
stepdelay
	movlw	0xF0
	movwf	stepperdelay
	movlw	0x01
	movwf	stepperdelay1
steppdelayloop
	decfsz	stepperdelay,f
	goto	steppdelayloop
	decfsz	stepperdelay1,f
	goto	steppdelayloop	
return
;---------------------------------
	END                       ; directive 'end of program'

