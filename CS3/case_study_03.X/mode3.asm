	 list p=16F747
	 title "Case Study 3 Program - Mode 3 Test"
; ***************************************************
; 
; This program runs on Case Study 3 Board. Bottom 4 bits of Port B
; connect to Four LEDs. Bits 2, 6, and 7 of Port D are ready and drive LEDs.
; Port C is connected to two switches (PortC pin 7 is green)
; (PortC pin 6 is red pushutton). Port E is potentiometer (all inputs).
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
; Variable declarations    
         Count equ 20h ; the counter(for modes 2 and 4)
         Temp equ 21h ; a temporary register
         State equ 22h ; the program state register
         Mode equ 23h ; what mode we are in
         Control equ 24h ; control value (of potentiometer)

	     org 00h                    ; interrupt vector
	     goto SwitchCheck           ; initialize ports
             
;	     org 04h
;	     goto isrServie             ; goto interrupt service routine
	     
	     org 15h			; Beginning of program storage

SwitchCheck
	     call initPort		; initialize ports
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
;	    CS3 Program
; 
ResetProgram
	     clrf Count		        ; zero the counter
	     clrf Temp                  ; zero the temporary register
	     clrf State                 ; zero the state
	     clrf Control               ; zero potentiometer value
	     
	     movlw D'3'                 ; load Mode with decimal 3
	     movwf Mode                 ; LATER REPLACE w/ octal reading, cmple
	     
	     movlw B'00000011'          ; set LED to indicate mode 3
	     movwf PORTB
	     
WaitPress
	     clrf PORTD                 ; turn off solenoid and ready LED
	     btfss PORTC,7		; skip if green button pressed
	     goto GreenPress	        ; green button is pressed - goto routine
	     
	     btfss PORTC,6              ; see if red button pressed
	     goto RedPress              ; red button pressed - goto routine
	     	     
	     goto WaitPress             ; keep checking   
	     
GreenPress  
	     btfsc PORTC,7              ; see if green button pressed	  
	     goto WaitPress  

GreenRelease
	     btfss PORTC,7              ; see if green button released
	     goto GreenRelease	        ; no - keep waiting
	     
	     call SwitchDelay           ; let switch debounce
;	     goto ResetProgram          ; change the mode or reset the mode
	    
RedPress
	     btfsc PORTC,6              ; check if red button pressed
	     goto WaitPress             ; no - keep waiting
	     
RedRelease
	     btfss PORTC,6              ; skip if red button pressed
	     goto RedRelease
	     
	     btfsc PORTD,2              ; if ready light active
	     goto WaitPress
	     
	     call SwitchDelay           ; let switch debounce

Main
	     btfsc PORTC, 6             ; red button pressed == activate control
	     
	     movlw B'00000100'          ; turn on Ready LED
	     movwf PORTD                ; CHECKPOINT passed
	     
	     goto AtoD                  ; read control potentiometer value  
	     
AtoD
	     call initAD                ; initialize A/D
	     call SetupDelay            ; delay for Tad
	     bsf ADCON0,GO              ; start A/D conversion
	     call waitLoop
	     
waitLoop
	     btfsc ADCON0,GO            ; check if A/D is finished
	     goto waitLoop              ; loop right here until A/D finished
	     
	     btfsc ADCON0,GO            ; check if A/D is finished
	     goto waitLoop              ; not finished, keep looping
	     movf ADRESH,W              ; get A/D value
	     movwf Control              ; store value in Control var
	     
	     goto Engage
	     
Engage
; check for error
	     movlw 0h  
	     bcf STATUS,Z               ; clear the register to compare
	     xorwf Control,0            ; is the value of pot == 0?
	     btfsc STATUS,Z             ; if 0 --> goto error
	     goto SensorFault
	     
; compare if greater than or less than 70h
	     movlw 70h                  ; move 70h to W  
	     bcf STATUS,C               ; clear the C register to compare
	     subwf Control,0            ; subtract Control from 70h
	     btfsc STATUS,C             ; if result positive --> turn on solenoid
	     bsf PORTD, 7
	     
	     btfss STATUS,C             ; if result negative --> turn off solenoid
	     bcf PORTD, 7
             
	     btfss PORTC,6              ; check if red button pressed
	     goto RedPress              ; if red button pressed, goto RedPress
	     
	     goto AtoD                  ; restart loop to keep reading pot val
     
	          
	    
SolenoidOn
	     bsf PORTD, 7		; turn on main transistor
	     return
	     
SolenoidOff
	     bcf PORTD, 7                ; turn off main transistor
	     return
	     	     
SwitchDelay
	     movlw D'20'                 ; load Temp with decimal 20
	     movwf Temp
	     return
	     
SensorFault
	     movlw B'00001011'          ; turn on error on mode 3 lights
	     movwf PORTB
	     clrf PORTD                 ; turn off solenoid and RDY light
	     goto isrService
       
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
; Port Initialization Subroutine
initPort
	     clrf PORTB ; 0-2/3 pins for mode/fault indication respectively (output)
	     clrf PORTC ; octal switch, 6,7 pins for green/red pushbutton	    
	     clrf PORTD ; 2, 6, 7 for LEDs and transistors
	     clrf PORTE ; 0-2 pins for the octal input (complement of the mode) (input)

	     bsf STATUS, RP0 ; Set bit in STATUS register for bank 1
	     
	     movlw B'11110000' ; load binary number onto W registry (pins 0-3 out)
	     movwf TRISB ; load W into TRISB
	    
	     movlw B'11111111' ; load binary number onto W registry (all inputs)
	     movwf TRISC ; Configure Port C as all inputs
	    
	     movlw B'00111000' ; load binary number onto W registry (pins 2, 6, 7)
	     movwf TRISD ; load W into TRISD
	    
	     movlw B'00000111' ; load binary number onto W registry (0-2 input)
	     movwf TRISE ; load W into TRISE
	     
	     movlw B'00001010' ; RA0 analog input, all other digital
	     movwf ADCON1 ; move to special function A/D register
	     
	     bcf STATUS, RP0 ; Clear bit in STATUS register for bank 0
	     return
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;  InitializeAD - initializes and sets up the A/D hardware.
;  Select AN0 to AN3 as analog inputs, proper clock period, and read AN0.
;
initAD
             bsf STATUS,RP0             ; select register bank 1
             movlw B'00001110'          ; RA0 analog input, all other digital
             movwf ADCON1               ; move to special function A/D register
             bcf STATUS,RP0             ; select register bank 0
             movlw B'01000001'          ; select 8 * oscillator, analog input 0, turn on
             movwf ADCON0               ; move to special function A/D register
             return

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; 
;  This routine is a software delay of 10uS required for the A/D setup.
;  At a 4Mhz clock, the loop takes 3uS, so initialize the register Temp with
;  a value of 3 to give 9uS, plus the move etc. should result in
;  a total time of > 10uS.

SetupDelay 
             movlw 03h              ; load Temp with hex 3
             movwf Temp	     
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

