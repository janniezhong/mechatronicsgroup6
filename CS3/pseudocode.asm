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
; check for green press
    ; if yes, go to GreenPress state
    ; if no check for red press (solenoid engaged)
        ; if no check for green press
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

; ** mode 2

; ** mode 3

; ** mode 4


; ** faults: if fault triggered, turn the fault LED on, then wait for the black reset switch

; ** if reset, jump to init
