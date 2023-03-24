	list p=16F747
	title "Case Study 3 program"
; ***************************************************
;
;	
; ***************************************************
	
	#include <p16F747.INC>
	
    __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
    __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
	
;	Note: the format for the CONFIG directive starts with a double underscore.
;	The above directive sets the oscillator to an external high speed clock, 
;	sets the watchdog timer off, sets the power timer on, sets the system
;	clear on (which enables the reset pin) and turns code protect off among 
;	other things.
;	
;	Variable declarations
    
    	
Count	equ	20h		; the counter(for modes 2 and 4)
Temp	equ	21h		; a temporary register(? holds the value from the A/D register?)
State	equ	22h		; the program state register

	
	    org	    00h			; interrupt vector -- why indent like this
	    goto    SwitchCheck		; goto interrupt service routine
	    org	    04h			; interrupt vector
	    goto    isrService		; goto interrupt service routine (dummy)
	    
	    org	    15h			; Beginning of program storage
SwitchCheck
	    call    initPort		; initialize ports
	    
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
	    
;	    CS3 Program
;	    
ResetProgram ;turn off transistors, reset LEDs
	    clrf    Count		    ; zero the counter
	    clrf    Temp                    ; zero the temporary register
	    clrf    State                   ; zero the state
waitGreenPress
	    btfss   PORTC,7		        ; see if green button pressed
	    goto    GreenPress		    ; green button is pressed - goto routine
	    goto    waitGreenPress		    ; keep checking
GreenPress
	    call    SwitchDelay		    ; let switch debounce 
	    btfsc   PORTC,7		        ; see if green button still pressed
	    goto    waitGreenPress		    ; noise - not pressed - keep checking
		goto    GreenRelease
GreenRelease
	    btfss   PORTC,7		        ; see if green button released
	    goto    GreenRelease	    ; no - keep waiting
		goto    ReadMode
	    

ReadMode
	    movlw   PORTE                   ; read the mode switch from PORTE into W
	    comf    W, Temp		    ; flip all bits, store in Temp
	    andlw   B'00000111'             ; subtract upper bits
	    movwf   State		    ; store mode in State
	    movf    State, PORTB            ; move state to port B to display


		movf    State, w			; move state to W
	    xorlw   B'11111110'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeOne

		movf    State, w			; move state to W
	    xorlw   B'11111101'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeTwo
		
		movf    State, w			; move state to W
	    xorlw   B'11111100'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeThree

		movf    State, w			; move state to W
	    xorlw   B'11111011'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeFour


		movf    State, w			; move state to W
	    xorlw   B'11111111'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeFault

		movf    State, w			; move state to W
	    xorlw   B'11111010'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeFault

		movf    State, w			; move state to W
	    xorlw   B'11111011'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeFault

		movf    State, w			; move state to W
	    xorlw   B'11111000'		    ; bitwise and 11111111 to w -- i think. should check this
	    btfsc   STATUS, Z		    ; skip if clear (comparison). all bits should be set
	    goto	ModeFault
		
		goto    waitGreenPress

ModeOne
		bcf PORTB, 3
		goto waitModeOne


waitModeOne
		btfss PORTC, 7
		goto GreenPress             ; should make sure we turn off the main transistor here

		btfss PORTC, 6
		goto RedPress

		goto waitModeOne

RedPress
		call SwitchDelay
		btfsc PORTC, 6
		goto waitRedPress
		gotoRedRelease

waitRedPress
	    btfss   PORTC,6		        ; see if red button pressed
	    goto    GreenPress		    ; red button is pressed - goto routine
	    goto    waitGreenPress		    ; keep checking

RedRelease
	    btfss   PORTC,6		        ; see if green button released
	    goto    RedRelease	        ; no - keep waiting
		goto    ToggleTransistor    ; write subroutine to toggle transistor




	   

ModeFault
		bsf     PORTB, 3
		; turn off solenoids (transistors)
		goto    waitGreenPress           ; not sure about this? idk where the black reset switch is tho 
	    
	    
SwitchDelay 
	    movlw   D'10'		    ; load Temp with decimal 20
	    movwf   Temp
delay
	    decfsz  Temp, F		    ; 60 usec delay loop
	    goto    delay		    ; loop until count equals zero
	    return	                    ; return to calling routine
	   

ModeFault
		bsf     PORTB, 3

Fault
	    ; turn the fault LED on
	    ; wait for black reset switch

Reset

;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;	    
;	    Port Initialization Subroutine
initPort
	    clrf    PORTA ; for the potentiometer
	    clrf    PORTB ; 0-2/3 pins for mode/fault indication respectively (output)
	    clrf    PORTC ; 7/_ pins for green/red pushbutton respectively (input)	    
	    clrf    PORTD ; 0-1 pins for the solenoid (output), #_ pin for the sensor (input) -- describe this in our general comments
	    clrf    PORTE ; 0-2 pins for the octal input (complement of the mode) (input)

	    bsf	    STATUS, RP0 ; select status bank 1 <- or bank 0? not sure
	    
	    movlw   B'11111111' ; select analog input
	    movwf   TRISA ; set port A to analog input

	    movlw   B'11110000'; load binary number onto W registry (all input except 0-3)
	    movwf   TRISB ; load W into TRISB
	    movlw   B'11111111'; load binary number onto W registry (all input)
	    movwf   TRISC ; load W into TRISC
	    
	    movlw   B'00011100'; load binary number onto W registry (all input)
	    movwf   TRISD ; load W into TRISD
	    
	    movlw   B'00000111'; load binary number onto W registry (all input)
	    movwf   TRISE ; load W into TRISE
	    
		movlw   B'00001110' ; select analog input
	    movwf   ADCON1 ; set port A to analog input
	    bcf	    STATUS, RP0 ; clear bank 0

;		movlw   B'01000001'
;       movwf   ADCON0

	    return
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ; ** init: initalize ports, registers, determine output/inputs
; variables: mode, val in A/D converter, count (for modes 2 and 4), state(?)
; port B 0-3: indicator LEDs
; port E: octal switch


; ** after init, waiting for mode:
; check for green press
; if no, check for green press
; if yes, check for green release
    ; if no check for green release
    ; if yes read the mode switch (needs to be complemented, shows 001 for 6)


; ** switch mode:
; display mode on the LEDS, turn off the transistors
; go to mode (1-4)


; ** mode 1

; ** mode 2

; ** mode 3

; ** mode 4


; ** faults: if fault triggered, turn the fault LED on, then wait for the black reset switch

; ** if reset, jump to init