;==============================================================================
; stepper.asm
; target: AT90USB1286
; compiler: 
;==============================================================================
.include "at90usb1286.inc"

.equ TIMER_COMP_VAL 15624

.org 0x0000
    rjmp main

.org 0x0022
    rjmp TIMER1_COMPA_ISR

;==============================================================================
; Main Program
;==============================================================================
main:
    ;initialize stack pointer
    ldi r16, LOW(RAMEND) ;load low ramend into r16
    out SPL, r16 ;store r16 in stack pointer low
    ldi r16, HIGH(RAMEND)
    out SPH, r16

    ;setup data diretion register for port A pins
    sbi DDRA, 0 ; PA0_AD0 - x step
    sbi DDRA, 1 ; PA1_AD1 - x dir

    ;set stepper direction
    cbi PORTA, 1 

    ;setup timer1 16 bit 
    ldi r16, 0x00
    out TCCR1A, r16

    ;configure prescaler mux
    ;clk, clk/8, clk/64, clk/256, clk/1024, falling edge, rising, edge
    ;WGM sets CTC mode 
    ldi r16, (1<<WGM12) | (1<<CS12) | (1<<CS10)  
    out TCCR1B, r16

    ;load compare value
    ldi r16, LOW(TIMER_COMP_VAL)
    out OCR1AL, r16
    ldi r16, HIGH(TIMER_COMP_VAL)
    out OCR1AH, r16

    ;enable output compare interrupt
    ldi r16, (1<<OCIE1A)
    out TIMSK1, r16

    ;enable global interrupts
    sei 


;==============================================================================
; Main Loop
;==============================================================================
loop:
    rjmp loop

;==============================================================================
; Interrupt Service Routines (ISRs)
;==============================================================================
TIMER1_COMPA_ISR:
    ;save context
    push r16
    in r16, SREG
    push r16

    ;drive stepper
    in r16, PORTA ;read state of port A pins
    ldi r17, (1<<PA0) ; x step bit mask
    eor r16, r17 ;xor bit toggle
    out PORTA, r16 ;write new state back to GPIO

    ;restore context
    pop r16
    out SREG, r16
    pop  r16

    reti ;return from interrupt

