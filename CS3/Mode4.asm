;***********************************************************
;     Mode 4: Recovery from Error
;     
;***********************************************************
	list p=16F747
	title "Mode 4"
	
    #include <p16F747.INC>
	
    __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
    __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
  
	    ;     Variable declarations

Count	    equ     20h     ; the counter
Temp	    equ     21h     ; temporary register
State	    equ     22h     ; the program state register
ADvalue	    equ	    23h	    ; A/D value
	    
Timer0	    equ	    10h	    ;
Timer1	    equ	    11h	    ;
Timer2	    equ	    12h	    ;
TimerState  equ	    13h	    ; Timer	    
	    
Green	    equ     18h     ; the mode switching button
Control	    equ     16h     ; value for red button (control active or inactive)
Mod	    equ     14h     ; the mode  

	    org     00h          ; interrupt vector
            goto    SwitchCheck  ; goto interrupt service routine

            org     04h          ; interrupt vector
            goto    isrService  ; goto indicate fault routine

            org     15h          ; beginning of program storage

SwitchCheck
	call initPort        ; initialize ports


; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;

;     Mode 4
Mode4
    movlw   B'00000100'	    ; move "4" to W register
    movwf   PORTB	    ; display mode 4 on LEDs

waitPress
    call    SolenoidDisengaged
    btfss   PORTC, 7	    ; check for green press
    goto    GreenPress	    ; if green button is pressed, go to GreenPress
    btfss   PORTC, 6	    ; if not, check for red press (procesed to read A/D time)
    goto    RedPress	    ; if red button pressed, go to RedPress
    goto    waitPress	    ; repeat waitPress if neither buttons have been pressed
    
GreenPress
    call    SwitchDelay	    ; let switch debounce
    btfsc   PORTC, 7	    ; check if green is still pressed (low active) [skip next line if true]
    goto    waitPress	    ; button was not properly pressed, go back to waitPress

GreenRelease
    btfss   PORTC, 7	    ; check if green button is released [skip next line if true]
    goto    GreenRelease    ; repeat check
    
RedPress
    call    SwitchDelay	    ; let switch debounce
    btfsc   PORTC, 6	    ; check if red still pressed (low active) [skip next line if true]
    goto    waitPress	    ; button was not properly pressed, go back to waitPress
    
RedRelease
    btfss   PORTC, 6	    ; check if red button is released [skip next line if true]
    goto    RedRelease	    ; repeat check
    
; -------------Read A/D for time-----------

AtoDInit
    call    initAD	    ; call A/D pin initialization(s)
    call    SetupDelay	    ; delay for TAD prior to A/D
    
ReadAD
    bsf	    ADCON0, GO	    ; set (to 1) GO pin in ADCON0 and begin A/D conversion

waitloop4
    btfsc   ADCON0, GO	    ; check if A/D conversion is complete (cleared), skip next line if true
    goto    waitloop4	    ; keep waiting

    
    movf    ADRESH, W	    ; move the value from AD to W
    movwf   ADvalue	    ; move value form W to variable ADvalue

checkADzero
    movlw   B'00000000'
    bcf	    STATUS,Z	    ; Clear Z in Status
    xorwf   ADvalue,0	    ; xor values between (ADvalue and 0)
    btfsc   STATUS,Z	    ; skip next line if output XOR(ADvalue,0) = 1 [Z=0]
    goto    ErrorDetected


; ------------ Turn on Main Transistor & reset timer ----------

Restart4
    call    SolenoidEngaged
    clrf    TimerState

CheckSensor
    btfsc   PORTC,0	    ; check optical sensor
    goto    Continue4	    ; second set of checks 

checkElapsed
    call    Timer	    ; Start timer
    bcf	    STATUS,Z
    subwf   TimerState,D'10'    ; Subtracts the current TimerState by 10
    btfsc   STATUS,Z	    ; If, TimerState - 10 < 0, skip next line [proceed to error when greater than 10]
    goto    ErrorDetected ; 10s has elapsed, go to error
    goto    CheckSensor	    ; Keep checking sensor until 10s has elapsed
    
    
    
; ------------ 'Continue 4' ---------------------------

Continue4
    bsf	    PORTD,6	    ; Turn on Reduced Transistor
    call    Timer	    ; Wait a little
    bcf	    PORTD,7	    ; Turn off main transistor

    bcf	    STATUS,C	    ;
    RRF	    ADRESH,F	    ;
    bcf	    STATUS,0	    ;
    RRF	    ADRESH,F	    ;
    movf    ADRESH,W	    ;
    movwf   Count	    ;
    clrf    TimerState	
    call    decLoop
    
    bcf	    PORTD,6	    ; Turn off reduced transistor
    
    bcf	    State,1	    ; Reset Restart Counter
    bcf	    State,0
    
    clrf    TimerState	    ;
    
CheckOff4
    btfsc   PORTC,0	    ; check if sensor is low
    call    checkElapsed2   ; repeat checks for 10seconds
    call    Mode4
    
checkElapsed2
    call    Timer
    subwf   TimerState,D'10'
    btfsc   STATUS,Z
    goto    ErrorDetected
    goto    CheckOff4
    
    

    

; ---------------- Timer for 1/4 of potentiometer time -----------------
decLoop
    call    Timer
    btfss   PORTC,0	    ; sensor check
    call    checkRestart    ; Check if this is first restart
    decfsz  Count,F	    ;
    goto    decLoop	    ;
    return

checkRestart
    btfsc   State,1	    ; check if this is first restart
    goto    ErrorDetected   ;
    bsf	    State,1	    ; indicate no longer first restart
    goto    Restart4	    ; Restart4
    
    
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; ------------- Setup Timer ---------------
Timer
    incf TimerState
    goto timeLoop
    
timeLoop
    movlw   06h
    movwf   Timer2
    movlw   16h
    movwf   Timer1
    movlw   15h
    movwf   Timer0
    
timeLoopDelay
    decfsz  Timer0,F
    goto    timeLoopDelay
    decfsz  Timer1,F
    goto    delay
    decfsz  Timer2,F
    goto    timeLoopDelay
    
    return
    


; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; Initialize Ports
initPort
    clrf  PORTB
    clrf  PORTC
    clrf  PORTD
    clrf  PORTE

    bsf   STATUS, RP0
    movlw B'11110000'
    movwf TRISB
    movlw B'11111111'
    movwf TRISC
    movlw B'00011100'
    movwf TRISD
    movlw B'00000111'
    movwf TRISE
    bcf	  STATUS, RP0

    return
      
      
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;  InitializeAD - initializes and sets up the A/D hardware.
;  Select AN0 to AN3 as analog inputs, proper clock period, and read AN0.
initAD
    bsf     STATUS,RP0      ; select register bank 1
    movlw   B'00001110'     ; RA0 analog input, all other digital
    movwf   ADCON1          ; move to special function A/D register
    bcf     STATUS,RP0      ; select register bank 0
    movlw   B'01000001'     ; select 8 * oscillator, analog input 0, turn on
    movwf   ADCON0          ; move to special function A/D register
    return


; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; Switch Delay

SwitchDelay 
    movlw   D'20'		    ; load Temp with decimal 20
    movwf   Temp
    
delay
    decfsz  Temp, F		    ; 60 usec delay loop
    goto    delay		    ; loop until count equals zero
    return			    ; return to calling routine
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
; 
;  This routine is a software delay of 10uS required for the A/D setup.
;  At a 4Mhz clock, the loop takes 3uS, so initialize the register Temp with
;  a value of 3 to give 9uS, plus the move etc. should result in
;  a total time of > 10uS.

SetupDelay 
    movlw   03h              ; load Temp with hex 3
    movwf   Temp

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; Solenoid Engaged / Disengaged

SolenoidEngaged
    ;bsf	   PORTD,6	    ;
    bsf    PORTD, 7	    ; turn on main transistor
    ;bsf	    State,0	    ;
    return
SolenoidDisengaged
    ;bcf	    PORTD,6	    ;
    bcf	    PORTD,7	    ;
    ;bcf	    State,0	    ;
    return
     

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
;   Note: This is a dummy interrupt service routine. It is  good programming 
;   practice to have it. If interrupts are enables (which they should not be)
;   and if an interrupt occurs (which should not happen), this routine safely
;   hangs up the micro computer in an infinite loop.

ErrorDetected
    movlw  B'00000100'
    movwf  PORTB
    clrf   PORTD
ErrorFlash
    bsf    PORTB, 3
    call   OneSecFlash
    bcf    PORTB, 3
    call   OneSecFlash
    goto   ErrorFlash
OneSecFlash
    movlw  06h
    movwf  Timer2
    movlw  16h
    movwf  Timer1
    movlw  15h
    movwf  Timer0
    call   delay3
    return
delay3
    decfsz Timer0, F
    goto   delay3
    decfsz Timer1, F
    goto   delay3
    decfsz Timer2, F
    goto   delay3
    return
     
isrService
    goto   isrService		; error -- stay here

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
    end