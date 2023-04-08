Counter1
    clrf    Count1	; reset counter
waitPress1
    btfss   PORTC, 0		; check for green press
    goto    GreenPress		; if yes, go to GreenPress state
    btfss   PORTC, 1		; if no check for red press (solenoid engaged)
    goto    RedPress1		; if red pressed, go to RedPress1
    goto    waitPress1		; if no check for green press again
RedPress1
    call    SwitchDelay		; let switch debounce
    btfsc   PORTC, 1		; check if red still pressed
    goto    waitPress		; noise - not pressed - keep checking
RedRelease1
    btfss   PORTC, 1		; see if red button released
    goto    RedRelease1		; no, keep waiting
AtoD1
    call    initAD		; call to initialize A/D
    call    SetupDelay
    bsf	    ADCON0, GO
;
; &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
; Wait loop

waitLoop1
    btfsc   ADCON0, GO		; check if A/D is finished
    goto    waitLoop1		; loop right here until A/D finished
    
; get value 
    
    btfsc   ADCON0, GO
    goto    waitLoop1
    movf    ADRESH, W
    
    
    ; if yes check for red release (solenoid disengaged)
            ; if no check for red release
            ; if yes read value on potentiometer           
                ; if value = 0, error LED light up
                ; if value > 0 turn on main transistor
                ; check for red press
                    ; if yes check for red release 
                    ; if no check time
                        ; if time is done turn off main transistor
                        ; if time isn't done check for red press
