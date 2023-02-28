	list p=16F737
	title "A/D Testing Program"
;****************************************************************
;
;
;
;
;
;
;
;****************************************************************
	
	#include <P16F737.INC>
    __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
    __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
    
;    Note: the format for the CONFIG directive starts with a double underscore.
;    The above directive sets the oscillator to an external high speed clock,
;    sets the watchdog timer off, sets the power up timer on, sdets the system 
;    clear on (which enables the reset pin) and turns code protect off.
    
;    Variable declarations
State	equ	22h	    ; the program state register
Temp	equ	23h	    ; the timer register
	
	org	00h	    ; interrupt vector
	goto	SwitchCheck	; jump to interrupt service routine
	
	org	04h	    ; interrupt vector
	goto isrService	    ; jump to interrupt service routine
	
	org	15h	    ; Beginning of program storage

SwitchCheck
	call	initPort

AtoD
	call	initAD		; call to initialize A/D
	call	SetupDelay	; delay for Tad (see data sheet) prior to A/D start
	bsf	ADCON0, GO	; start A/D conversion
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
; Wait loop

waitLoop
	btfsc	ADCON0, GO	    ; check if A/D is finished
	goto	waitLoop	    ; loop right here until A/D finished

; Get value and display on LEDs
	
	btfsc	ADCON0, GO	    ; make sure A/D finished
	goto	waitLoop	    ; A/D not finished, continue to loop
	movf	ADRESH, W	    ; get A/D value
	movwf	PORTB		    ; display on LEDs 
	bsf	ADCON0, GO	    ; restart A/D conversion
	goto	waitLoop	    ; return to loop

;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;   InitializeAD - initializes and sets up the A/D hardware
;   Select AN0 to AN3 as analog inputs, proper clock period and read AN0

initAD
	bsf	STATUS, RP0
	movlw	B'00001110'
	movwf	ADCON1
	bcf	STATUS, RP0
	movlw	B'01000001'
	movwf	ADCON0
	return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
;

SetupDelay
	movlw	03h	; load Temp with hex 3
	movwf	Temp
delay2
	decfsz	Temp,F	; Delay loop
	goto	delay2
	return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; Port Initialization Subroutine
initPort
	    clrf    PORTB
	    clrf    PORTC
	    bsf	    STATUS, RP0
	    clrf    TRISB
	    movlw   B'11111111'
	    movwf   TRISC
	    movlw   B'00001110'
	    movwf   ADCON1
	    bcf	    STATUS, RP0
	    return
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;	    Note: this is a dummy interrupt service routine. it is good programming
;	    practice to have it. If interrupts are enabled (which they should not be)
;	    and if an interrupt occurs (which should not happen), this routine safely
;	    hangs up the microcomputer in an infinite loop.
	    
isrService
	    goto    isrService		   ; error - - stay here
	    
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	    
	    end
	    
	    
