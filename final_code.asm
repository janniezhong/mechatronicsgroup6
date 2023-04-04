	list p=16F747
	title "On / Off Control"

;***********************************************************
; Case Study #3 - On Off Control Program
;
; On this microcomputer board, Port B is connected to 4 LED's which are used to
; display the mode of the program operation and any errors (indicator LEDs). 
; Upon reset, the program jumps to an initialization routine (init label). 
; The program then waits for the green button (pushbutton connected to 
; Port C pin 0) to be pressed. The indicator LEDs will indicate 0h. 
; The octal switch to Port E is used to indicate the mode.
; It is read when the green button is pressed and released and the
; mode of operation will be started. The indicator LEDs will 
; indicate the mode. All modes other than 1-4 inclusive will indicate a fault
; by the LED connected to Port B pin 3.
;
; If there is no fault after the previous operation has completed, the mode bits
; are read when the green button is pressed and that mode of operation is
; engaged. For correct modes, the fault LED is off. After any fault, pressing
; the green button will not cause any bits to be read. The processor must be 
; reset with the black reset switch. The state of the program is stored in State.
; The Solenoid transistors and "Ready" LED (used in Mode 3) are connected to
; Port D (pins 6, 7 and 2 respectively).
;
; This program switches between four modes which mimic common use case scenarios
; of on/off control. 
;
; Mode 1 is a basic test to ensure the solenoid functions and its associated
; sensors. Mode 2 mimics a toaster oven application with basic timing control.
; It uses the control precision potentiometer (Port A pin 0) to set a time and 
; counts down. Mode 3 mimics an air conditioning application with basic 
; feedback control. Mode 4 mimics a sump pump application with feedback, a 
; backup circuit, fault detenction, and fault recovery.
;
;***********************************************************
	
    #include <p16F747.INC>
	
    __config _CONFIG1, _FOSC_HS & _CP_OFF & _DEBUG_OFF & _VBOR_2_0 & _BOREN_0 & _MCLR_ON & _PWRTE_ON & _WDT_OFF
    __config _CONFIG2, _BORSEN_0 & _IESO_OFF & _FCMEN_OFF
    
;       Variable Declarations
Timer2	    equ	    20h		    ; timer storage variable
Timer1	    equ	    21h		    ; timer storage variable
Timer0	    equ	    22h		    ; timer storage variable
Temp	    equ	    24h		    ; the timer register
ADvalue	    equ	    23h		    ; A/D value 
Count	    equ     26h		    ; the counter
State	    equ     25h             ; the program state register
SolStatus   equ     27h             ; status of the solenoid (engaged/disengaged)
TimerState  equ	    13h		    ; Timer	    
Control	    equ     16h		    ; value for red button (control active/inactive)
	    
	    org	    00h		    ; interrupt vector
	    goto    SwitchCheck	    ; jump to interrupt service routine (dummy)
	    
	    org	    04h		    ; interrupt vector
	    goto    isrService	    ; jump to interrupt service routine (dummy)
	    
	    org	    15h		    ; beginning of storage program
SwitchCheck
	call    initPort	    ; initialize ports
; 
;-------------------Mode Classifying / Initialization---------------------
;
ResetProgram                        ; turn off transistors, reset LEDs
    clrf    Count		    ; zero the counter
    clrf    Temp                    ; zero the temporary register
    clrf    State                   ; zero the state
    clrf    SolStatus               ; set solenoid status to disengaged
    andlw   B'00000000'
    movwf   SolStatus
waitGreenPress
    btfss   PORTC,7		    ; see if green button is pressed
    goto    GreenPress		    ; green button is pressed - goto routine
    goto    waitGreenPress          ; keep checking
GreenPress
    call    SwitchDelay		    ; let switch debounce 
    btfsc   PORTC,7		    ; see if green button is released
    goto    GreenRelease            ; green button not pressed - goto routine
GreenRelease
    btfss   PORTC,7		    ; see if green button is pressed
    goto    GreenRelease	    ; green button pressed - keep waiting

    bcf     PORTD, 7                ; clear solenoid transistors and 'ready' LED
    andlw   B'00000000'            
    movwf   SolStatus

    goto    ReadMode                ; read the mode set on the octal switch
	    
ReadMode
    comf    PORTE, W		    ; flip all bits from octal switch, store in W
    andlw   B'00000111'             ; subtract upper bits
    movwf   State		    ; store mode in State
    movwf   PORTB                   ; move state to port B to display

    movlw    B'00000000'            ; set W to 0 to check for mode 0
    bcf      STATUS,Z               ; clear Z register
    xorwf    State, 0		    ; XOR mode value with W to check for equivalency
    btfsc    STATUS, Z		    ; skip next line if clear (comparison)
    goto     ErrorDetected          ; xor result says State == mode 0

    movf    State, W		    ; move state value to W
    andlw   B'11111110'		    ; bitwise and mode 1 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ModeOne

    movf    State, W		    ; move state to W
    andlw   B'11111101'		    ; bitwise and mode 2 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ModeTwo

    movf    State, W		    ; move state to W
    andlw   B'11111100'		    ; bitwise and mode 3 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ModeThree

    movf    State, W		    ; move state to W
    andlw   B'11111011'		    ; bitwise and mode 4 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ModeFour

    movf    State, W		    ; move state to W
    andlw   B'11111010'		    ; bitwise and mode 5 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ErrorDetected

    movf    State, W		    ; move state to W
    andlw   B'11111001'		    ; bitwise and mode 6 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ErrorDetected

    movf    State, W		    ; move state to W
    andlw   B'11111000'		    ; bitwise and mode 7 complement to W
    btfsc   STATUS, Z		    ; skip if clear (comparison)
    goto    ErrorDetected

    goto    waitGreenPress          ; wait for change of mode
      
;       Main Code
; 
;---------------------------- Mode 1 --------------------------------------
;
ModeOne   
    btfss    SolStatus, 0           ; SolStatus is 0 if on
    bcf      PORTD, 2               ; turn off solenoid; skips if off
    btfsc    SolStatus, 0           ; SolStatus is 1 if off
    bsf      PORTD, 2               ; turn on solenoid; skips if on
    call     waitPress              ; wait for press to engage/disengage or exit
CheckRedStatus
    movlw    B'00000000'            ; Set W to 0
    bcf      STATUS,Z               ; Clear Z register for XOR operation
    xorwf    SolStatus, 0	    ; XOR SolStatus w/ W for equivalency
    btfsc    STATUS, Z		    ; skip if clear (comparison)
    bsf      PORTD, 7               ; turn on solenoid if SolStatus indicates off

    movlw    B'00000001'            ; Set W to 1
    bcf      STATUS,Z               ; clear Z register for XOR operation
    xorwf    SolStatus, 0	    ; XOR SolStatus w/ W for equivalency
    btfsc    STATUS, Z		    ; skip if clear (comparison)
    bcf      PORTD, 7               ; turn off solenoid if SolStatus indicates on

    comf    SolStatus, W            ; complement SolStatus and store in W
    xorlw   B'11111110'             ; XOR the complement of 1 with W, store in W
    movwf   SolStatus               ; set SolStatus equal to result (alternated)
    
    goto    ModeOne                 ; stay in Mode 1
;
;---------------------------- Mode 2 --------------------------------------
;
ModeTwo
    movlw   B'00000010'		    ; moving "2" to W register
    movwf   PORTB		    ; displaying mode 2 on LEDs
Restart
    call    SolenoidDisengaged	    ; disengage solenoid when restarting
GreenCheckRedCheck
    call    waitPress		    ; check green and red button pressed
ADInitialization
    call    AtoDInit		    ; initialize AD 
CheckError
    call    ZeroError		    ; check if potentiometer value is 0
    call    SolenoidEngaged	    ; if status, z is not 0, engage solenoid
ADCountDown
    btfss   PORTC, 6		    ; check if red button pressed
    call    GreenCheckRedCheck	    ; if pressed, need to restart
    call    timeLoopQuart	    ; AD value not 0, continue 1/4 second time program
    decfsz  ADvalue		    ; count down AD value from potentiometer
    goto    ADCountDown		    ; AD value not zero, keep going
    goto    Restart		    ; AD value has reached zero, start over
; 
;---------------------------- Mode 3 --------------------------------------
;
ModeThree
    call    waitPress		    ; red button pressed == activate control
    movlw   B'00000100'             ; turn on 'ready' LED - set value in W
    movwf   PORTD                   ; turn on 'ready' LED - move W to port
    goto    AtoD                    ; read control potentiometer value  
ClearLEDandSol
    clrf    PORTD                   ; turn off 'ready' LED and solenoid
    goto    ModeThree	            ; restart Mode 3
AtoD
    call    AtoDInit                ; initialize AD
Engage
; check for error
    movlw   0h                      ; set W to 0
    bcf	    STATUS,Z                ; clear the register to compare
    xorwf   ADvalue,0               ; is the value of pot == 0?
    btfsc   STATUS,Z                ; if 0 --> goto error
    goto    ErrorDetected
	     
; compare if greater than or less than 70h
    movlw   70h                     ; move 70h to W  
    bcf	    STATUS,C                ; clear the C register to compare
    subwf   ADvalue,0               ; subtract Control from 70h
    btfsc   STATUS,C                ; if result positive --> turn on solenoid
    call    SolenoidEngaged

    btfss   STATUS,C                ; if result negative --> turn off solenoid
    call    SolenoidDisengaged

    btfss   PORTC,6                 ; check if red button pressed
    goto    Mode3RedPress           ; alternate control btwn active/inactive 
    goto    AtoD                    ; restart loop to keep reading pot val
;
;---------------------------- Mode 4 --------------------------------------
;
ModeFour
    movlw   B'00000100'	            ; move "4" to W register
    movwf   PORTB	            ; display mode 4 on LEDs
    call    waitPress               ; wait to exit mode or engage w/ solenoid
; Read A/D for time
    call    AtoDInit                ; initialize AD
; AD Checking Error
    call    ZeroError               ; check if control pot is reading 0

; Turn on Main Transistor & reset timer 
Restart4
    bsf	    PORTD,7	            ; Turn on main transistor
    clrf    TimerState              ; reset TimerState
CheckSensor
    btfsc   PORTC,0	            ; check optical sensor
    goto    Continue4	            ; second set of checks 
checkElapsed
    call    Timer	            ; Start timer
    movlw   D'10'                   ; move 10 decimal to W
    bcf	    STATUS,Z                ; clear Z register for operations
    subwf   TimerState, W           ; Subtracts the current TimerState by 10
    btfsc   STATUS,Z	            ; If, TimerState - 10 < 0, skip next line
    goto    ErrorDetected           ; 10s has elapsed, go to error
    goto    CheckSensor	            ; Keep checking sensor until 10s has elapsed
;
; 'Continue 4'
Continue4
    bsf	    PORTD,6	            ; Turn on Reduced Transistor
    call    timeLoopOne	            ; Wait a little
    bcf	    PORTD,7	            ; Turn off main transistor

    movf    ADRESH,W	            ; Control pot value to W
    movwf   Count	            ; W to Count
    clrf    TimerState	            ; reset TimerState
    call    decLoop                 ; start countdown
    
    bcf	    PORTD,6	            ; Turn off reduced transistor
    
    bcf	    State,1	            ; Reset Restart Counter
    bcf	    State,0         
    
    clrf    TimerState	            ; reset TimerState
    
CheckOff4
    btfsc   PORTC,0	            ; check if sensor is low, skip if low
    call    checkElapsed2           ; repeat checks for 10seconds
    call    ModeFour                ; reset Mode
    
checkElapsed2
    call    Timer                   ; increment timer value goal
    movlw   D'10'                   ; Set W to 10
    bcf	    STATUS, Z               ; Clear Z register for operation
    subwf   TimerState, W           ; Subtract current TimerState by 10
    btfsc   STATUS,Z                ; If, TimerState - 10 < 0, skip next line 
    goto    ErrorDetected           ; 10s has elapsed, go to error
    goto    CheckOff4               ; Check if sensor is low

;
;       Timer for 1/4 of potentiometer time 
;
decLoop
    call    timeLoopQuart
    btfss   PORTC,0	            ; sensor check
    call    checkRestart            ; Check if this is first restart
    decfsz  Count,F	            ; decrement counter 
    goto    decLoop	            ; repeat
    return

checkRestart
    btfsc   State,1	            ; check if this is first restart
    goto    ErrorDetected          
    bsf	    State,1	            ; indicate no longer first restart
    bcf	    PORTD,6	            ; Turn off reduced transistor
    goto    Restart4	            ; Restart4
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
    
;
;---------------------------- Universal Functions;----------------------------
; 
waitPress
    btfss   PORTC, 7	            ; check for green press
    goto    GreenPress	            ; if green button is pressed, go to GreenPress
    btfss   PORTC, 6	            ; if not, check for red press 
    goto    RedPress	            ; if red button pressed, go to RedPress
    goto    waitPress	            ; repeat waitPress if neither buttons pressed
    
RedPress
    call    SwitchDelay	            ; let switch debounce
    btfsc   PORTC, 6	            ; check if red still pressed (low active)
    goto    waitPress	            ; button not properly pressed, go back
    
RedRelease
    btfss   PORTC, 6	            ; check if red button is released 
    goto    RedRelease	            ; repeat check
    return

; Mode 3 Red Press
Mode3RedPress
    call    RedPress                ; confirm RedPress
    btfsc   PORTD, 2                ; check whether control active or inactive
    goto    ClearLEDandSol          ; if inactive, turn off solenoid and 'ready' LED
    return

; AD Conversion
AtoDInit
    call    initAD		    ; call to initialize A/D
    call    SetupDelay		    ; delay for TAD prior to A/D start
    bsf	    ADCON0, GO		    ; start A/D conversion
waitLoop
    btfsc   ADCON0, GO		    ; check if A/D is finished
    goto    waitLoop		    ; loop right here until A/D finished  
; get value 
    btfsc   ADCON0, GO		    ; make sure A/D finished
    goto    waitLoop		    ; A/D not finished, continue to loop
    movf    ADRESH, W		    ; get A/D value
    movwf   ADvalue		    ; move AD value to AtoD1 from W register
    return
; AD Checking Error
ZeroError   
    movlw   B'00000000'		    ; moving "0" to the W register
    bcf	    STATUS, Z		    ; set status, z to zero
    xorwf   ADvalue,0		    ; XOR value of A/D reading & W reg, stored in W
    btfsc   STATUS, Z		    ; check if status, z is 1 or zero
    goto    ErrorDetected           ; go to error detect if status, z is 0
    return
    
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;       Port/AD Initialization Subroutine
initPort    
    clrf    PORTB	            ; clearing port B output latches (LEDs)
    clrf    PORTC		    ; clearing port C output latches (green button)
    clrf    PORTD		    ; clearing port D output latches (main transistors)
    clrf    PORTE		    ; clearing port E output latches (switches)

    bsf	    STATUS, RP0		    ; Set bit in status register for Bank 1
    movlw   B'11110000'		    ; load binary number onto W register (pins 0-3)
    movwf   TRISB		    ; configure port B pins 0-3 as outputs
    movlw   B'00111000'		    ; load binary number onto W register 
    movwf   TRISD		    ; configure port D pins 6 & 7 as outputs
    movlw   B'11111111'		    ; load binary number onto W register
    movwf   TRISC		    ; configure port C as all inputs 			   
    movlw   B'00001010'		    ; load binary number onto W register
    movwf   ADCON1		    ; loaded to A/D conversion settings
    movlw   B'00000111'		    ; load binary number onto W register
    movwf   TRISE		    ; configure port E pins 0-2 as inputs
    bcf	    STATUS, RP0		    ; clear bit in STATUS register for bank 0
    bcf	    State,1		    ; Reset Restart Counter
    return
initAD
     bsf    STATUS, RP0		    ; select register bank 1
     movlw  B'00001110'		    ; RA0 analog input, all other digital
     movwf  ADCON1		    ; move to special function A/D register
     bcf    STATUS, RP0		    ; select register bank 0
     movlw  B'01000001'		    ; select 8 * oscillator, analog input 0, turn on
     movwf  ADCON0		    ; move to special function A/D register
     return
;
; A/D Setup Delay 
; This routing is a software delay of 10uS required for the A/D Setup.
; At a 4Mhz clock, the loop takes 3uS, so initialize the register Temp with
; a value of 3 to give 9uS, plus the move etc. should result in 
; a total time of > 10uS
SetupDelay
     movlw   03h		    ; load Temp with hex 3
     movwf   Temp
delay2
     decfsz  Temp, F		    ; delay loop
     goto    delay2
     return
; Switch Debounce
SwitchDelay
     movlw   D'20'		    ; load Temp with decimal 20
     movwf   Temp
delay1
     decfsz  Temp, F		    ; 60 usec delay loop
     goto    delay1		    ; loop until count equals zero
     return			    ; return to calling routine
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
     
;
;---------------------------- Timers ----------------------------
;
     
; Setup 1/4s Timer  
timeLoopQuart
    movlw   02h
    movwf   Timer2
    movlw   45h
    movwf   Timer1
    movlw   85h
    movwf   Timer0
    
timeLoopDelayQuart
    decfsz  Timer0,F
    goto    timeLoopDelayQuart
    decfsz  Timer1,F
    goto    timeLoopDelayQuart
    decfsz  Timer2,F
    goto    timeLoopDelayQuart
    return
; Setup 1s Timer 
Timer
    incf TimerState, F
    goto timeLoopOne
    
timeLoopOne
    movlw   06h
    movwf   Timer2
    movlw   16h
    movwf   Timer1
    movlw   15h
    movwf   Timer0
    
timeLoopOneDelay
    decfsz  Timer0,F
    goto    timeLoopOneDelay
    decfsz  Timer1,F
    goto    timeLoopOneDelay
    decfsz  Timer2,F
    goto    timeLoopOneDelay
    return
;
;------------------ Solenoid Engage/Disengage -----------------------
;
SolenoidEngaged
     bsf    PORTD, 7		    ; turn on main transistor
     return
SolenoidDisengaged		    ; turn off main transistor
     bcf    PORTD, 7
     return
;
;---------------------------- ERROR  -----------------------
;
ErrorDetected
     clrf   PORTD		    ; disengage solenoid
ErrorFlash			    ; flash the error LED
     bsf    PORTB, 3		    ; set port B pin 3 to "1" to light up error LED
     call   timeLoopOne		    ; go through 1 second timer
     bcf    PORTB, 3		    ; clear port B pin 3 to "0" to clear error LED
     call   timeLoopOne		    ; 1s Timer
     goto   ErrorFlash		    ; go through error flash again until reset
     
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; 
;   Note: This is a dummy interrupt service routine. It is  good programming 
;   practice to have it. If interrupts are enables (which they should not be)
;   and if an interrupt occurs (which should not happen), this routine safely
;   hangs up the micro computer in an infinite loop.
     
isrService
     goto   isrService		    ; error -- stay here
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     end 