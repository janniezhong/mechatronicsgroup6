	 list p=16F747
	 title "Case Study 3 Program - Mode 3 Test"
; ***************************************************
; 
; This program runs on Case Study 3 Board. Bottom 4 bits of Port B
; connect to Four LEDs. Bits 2, 6, and 7 of Port D are ready and drive LEDs.
; Port C is connected to an octal switch and two switches (PortC pin 7 is green)
; (PortC pin 6 is red pushutton).
;
; ***************************************************
	
	 #include <p16F747.INC>
	
     __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
     __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
     
; Note: the format for the CONFIG directive starts with a double underscore.
; The above directive sets the oscillator to an external high speed clock,
; sets the watchdog timer off, sets the power up timer on, sets the system
; clear on (which enables the reset pin) and turns code protect off among
; other things.
;	
;	Variable declarations    
     Count	equ	20h		; the counter(for modes 2 and 4)
     Temp	equ	21h		; a temporary register
     State	equ	22h		; the program state register
     Mode       equ     23h             ; what mode we are in

	     org 00h                    ; interrupt vector
	     goto SwitchCheck           ; initialize ports
             
	     org 04h
	     goto isrServie             ; goto interrupt service routine
	     
	     org 15h			; Beginning of program storage

SwitchCheck
	     call initPort		; initialize ports
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
;	    CS3 Program
; 
ResetProgram
	     clrf    Count		    ; zero the counter
	     clrf    Temp                    ; zero the temporary register
	     clrf    State                   ; zero the state
waitPress
	     btfss   PORTC,0		    ; see if green button pressed
	     goto    GreenPress		    ; green button is pressed - goto routine
	     goto    waitPress		    ; keep checking
GreenPress
	     clrf    Control		    ; set  contrl to inactve (0)
	     movwf   PORTB		    ; turn off LED
	    
	     call    SwitchDelay		    ; let switch debounce 
	     btfsc   PORTC,0		    ; see if green button still pressed
	     goto    waitPress		    ; noise - not pressed - keep checking
	  

GreenRelease
	     btfss   PORTC,0		    ; see if green button released
	     goto    GreenRelease	    ; no - keep waiting
	    
	    ;goto    IncCount		    ; increment the counter & output
	   
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; Port Initialization Subroutine
initPort
	     ;clrf PORTA ; for the potentiometer
	     clrf PORTB ; 0-2/3 pins for mode/fault indication respectively (output)
	     clrf PORTC ; 0/1 pins for green/red pushbutton respectively (input)	    
	     clrf PORTD ; 0-1 pins for the solenoid (output), #2 pin for the sensor (input) -- describe this in our general comments
	     clrf PORTE ; 0-2 pins for the octal input (complement of the mode) (input)

	     bsf STATUS, RP0 ; Set bit in STATUS register for bank 1
	     clrf TRISB ; configure Port B as all outputs
	     
	     movlw   B'00001110' ; RA0 analog input, all other digital
	     movwf   ADCON1 ; move to special function A/D register

	     movlw B'00001111'; load binary number onto W registry (all except 0-3)
	     movwf TRISB ; load W into TRISB
	    
	     movlw B'11111111'; load binary number onto W registry (all inputs)
	     movwf TRISC ; Configure Port C as all inputs
	    
	     movlw B'01000110'; load binary number onto W registry (all input)
	     movwf TRISD ; load W into TRISD
	    
	     movlw B'11111111'; load binary number onto W registry (all input)
	     movwf TRISE ; load W into TRISE
	     
	     bcf STATUS, RP0 ; Clear bit in STATUS register for bank 0
	     return
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Note: this is a dummy interrupt service routine. It is good programming
; practice to have it. If interrupts are enabled (which they should not be)
; and if an interrupt occurs (which should not happen), this routine safely
; hangs up the microcomputer in an infinite loop.
isrService
             goto isrService ; error - - stay here
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
             end