	list p=16F737
	title "Up/Down Counter program"
; ***************************************************
;
;	This program runs on the Exercise PC board.
;	On this microcomputer board, Port B is connected to 8 LEDs.
;	Port C is connected to 2 switches, both of which will be used.
;	Port C is also connected to an octal switch.
;	
;	The first program increments an internal file register
;	Count every time the green pushbutton switch (PortC pin 7) is 
;	pressed. The program decrements the file register Count every time 
;	The value of Count is displayed on the LEDs connected
;	to Port B in binary.
;	
;	This routine produces 3 messages when assembled.
;	
; ***************************************************
	
	#include <p16F737.INC>
	
    __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
    __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
	
;	Note: the format for the CONFIG directive starts with a double underscore.
;	The above directive sets the oscillator to an external high speed clock, 
;	sets the watchdog timer off, sets the power timer on, sets the system
;	clear on (which enables the reset pin) and turns code protect off among 
;	other things.
;	
;	Variable declarations
	
Count	equ	20h		; the counter
Temp	equ	21h		; a temporary register
State	equ	22h		; the program state register
	
	    org	    00h			; interrupt vector
	    goto    SwitchCheck		; goto interrupt service routine
	    org	    04h			; interrupt vector
	    goto    isrService		; goto interrupt service routine (dummy)
	    
	    org	    15h			; Beginning of program storage
SwitchCheck
	    call    initPort		; initialize ports
	    
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
	    
;	    Counter Program
;	    
;	    The first part is a program which increments an internal file register
;	    Count every time the green pushbutton switch (PortC pin 7) is
;	    pressed. The program decrements the file register Count every time
;	    the red pushbutton switch (PortC pin 6) is pressed. 
;	    The value of Count is displayed on the LEDs connected 
;	    to Port B.
;	    
;	    The net result is that LEDs should increment or decrement 
;	    in a binary manner every time a switch is pressed. This 
;	    checks the buttons and LEDs.
;	    
;	    
Counter
	    clrf    Count		    ; zero the counter
waitPress
	    btfss   PORTC,7		    ; see if green button pressed
	    goto    GreenPress		    ; green button is pressed - goto routine
	    btfss   PORTC,6		    ; see if red button pressed
	    goto    RedPress		    ; red button is pressed - goto routine
	    goto    waitPress		    ; keep checking
GreenPress
	    call    SwitchDelay		    ; let switch debounce 
	    btfsc   PORTC,7		    ; see if green button still pressed
	    goto    waitPress		    ; noise - not pressed - keep checking
GreenRelease
	    btfss   PORTC,7		    ; see if green button released
	    goto    GreenRelease	    ; no - keep waiting
	    
	    goto    IncCount		    ; increment the counter & output
RedPress
	    call    SwitchDelay		    ; let switch debounce
	    btfsc   PORTC,6		    ; see if red button still pressed
	    goto    waitPress		    ; noise - not pressed - keep checking
RedRelease
	    btfss   PORTC,6
	    goto    RedRelease
	    
	    decf    Count, F		    ; decrement count - store in register
	    goto    outCount		    ; output the count on the PORTD LEDs
IncCount
	    incf    Count, F		    ; increment count - store in register
outCount
	    movf    Count, W		    ; move the count to the W register
	    movwf   PORTB		    ; display cound on port B LEDs
	    
	    goto    waitPress		    ; wait for next button press
SwitchDelay 
	    movlw   D'20'		    ; load Temp with decimal 20
	    movwf   Temp
delay
	    decfsz  Temp, F		    ; 60 usec delay loop
	    goto    delay		    ; loop until count equals zero
	    return			    ; return to calling routine
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;	    
;	    Port Initialization Subroutine
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
	    
	    

	    