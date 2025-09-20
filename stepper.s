;==============================================================================
; stepper.S
; Target: AT90USB1286
; This version uses the standard C preprocessor and modern assembly practices.
;==============================================================================
;#define __AVR_AT90USB1286__ 
#include <avr/io.h>

#define TIMER_COMP_VAL 1000

.global main
.global TIMER1_COMPA_ISR

.org 0x0000
    rjmp main

.org 0x0022
    rjmp TIMER1_COMPA_ISR

;==============================================================================
; Main Program
;==============================================================================
main:
    ; Initialize stack pointer
    ldi r16, hi8(RAMEND)
    sts SPH, r16
    ldi r16, lo8(RAMEND)
    sts SPL, r16

    ; --- Configure GPIO using Read-Modify-Write ---

    ; Enable stepper driver on PE7
    in r16, DDRE
    ori r16, (1 << DDE7)      ; Set PE7 as an output
    out DDRE, r16

    in r16, PORTE
    andi r16, ~(1 << PE7)     ; Pull PE7 LOW
    out PORTE, r16

    ; Set PA0 (STEP) and PA1 (DIR) as outputs
    in r16, DDRA
    ori r16, (1 << DDA0) | (1 << DDA1)
    out DDRA, r16

    ; Set direction (pull PA1 LOW)
    in r16, PORTA
    andi r16, ~(1 << PA1)
    out PORTA, r16

    ; --- Setup Timer1 in CTC Mode ---
    ldi r16, 0x00
    sts TCCR1A, r16

    ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
    sts TCCR1B, r16

    ; Load compare value
    ldi r16, lo8(TIMER_COMP_VAL)
    sts OCR1AL, r16
    ldi r16, hi8(TIMER_COMP_VAL)
    sts OCR1AH, r16

    ; Enable Timer1 Compare A Match Interrupt
    ldi r16, (1 << OCIE1A)
    sts TIMSK1, r16

    ; Enable global interrupts
    sei

;==============================================================================
; Main Loop
;==============================================================================
loop:
    rjmp loop

;==============================================================================
; Interrupt Service Routine
;==============================================================================
TIMER1_COMPA_ISR:
    ; Save context
    push r16
    in r16, _SFR_IO_ADDR(SREG)
    push r16
    push r17 ; We now need r17 as a temporary register

    ; --- Generate Step Pulse using Read-Modify-Write ---

    ; 1. Set step pin HIGH (rising edge)
    in r17, PORTA
    ori r17, (1 << PA0)
    out PORTA, r17

    ; 2. Delay for 1µs (16 NOPs @ 16MHz)
    nop; nop; nop; nop; nop; nop; nop; nop;
    nop; nop; nop; nop; nop; nop; nop; nop;

    ; 3. Set step pin LOW (falling edge)
    in r17, PORTA
    andi r17, ~(1 << PA0)
    out PORTA, r17

    ; Restore context
    pop r17
    pop r16
    out _SFR_IO_ADDR(SREG), r16
    pop r16

    reti
