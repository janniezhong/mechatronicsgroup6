	list p=16F737
	title "Long Timer Program"
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
;    sets the watchdog timer off, sets the power up timer on, sets the system
;    clear on (which enables the reset pin) and turns code protect off. 
    
;    Variable declarations

State	equ	201h	    ; the program state register
Timer2	equ	21h	    ; timer storage variable
Timer1	equ	22h	    ; timer storage variable
Timer0	equ	23h	    ; timer storage variable
	
	
	org	00h	    ; interrupt vector
	goto	SwitchCheck	    ; jump to interrupt service routine (dummy)
	
	org	04h		    ; interrupt vector
	goto	isrService	    ; jump to interrupt service routine (dummy)
	
	org	15h		    ; beginning of program storage
SwitchCheck
	call	initPort	    ; initialize ports

;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;

Timer
	clrf	PORTB		    ; turn off all LEDs

checkSwitch
	btfsc	PORTC, 5	    ; read speed switch
	goto	HalfTime	    ; goto 1/2 second loop
	
timeLoop
	movlw	06h		    ; get most significant hex value +1
	movwf	Timer2		    ; store it in count register
	movlw	16h		    ; get most significant hex value
	movwf	Timer1		    ; store it in count register
	movlw	15h		    ; get least significant hex value
	movwf	Timer0		    ; store it in count register
	
delay
	decfsz	Timer0, F	    ; delay loop Timer0
	goto	delay
	decfsz	Timer1, F	    ; delay loop Timer1
	goto	delay
	decfsz	Timer2, F	    ; delay loop Timer2
	goto	delay
	
;	Increment LEDs
	
	incf	PORTB, F	    ; increment port B
	goto	checkSwitch	    ; check slide switch
	
HalfTime
	movlw	03h		    ; get most significant hex value +1
	movwf	Timer2		    ; store it in count register
	movlw	8Bh		    ; get most significant hex value
	movwf	Timer1		    ; store it in count register
	movlw	0Ah		    ; get least significant hex value
	movwf	Timer0		    ; store it in count register
	goto	delay		    ; count down
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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