;==============================================================================
; stepper.asm
; target: AT90USB1286
; compiler: 
;==============================================================================
.include "at90usb1286.inc"

.equ TIMER_COMP_VAL, 15624

.org 0x0000
    rjmp main

.org 0x0022
    rjmp TIMER1_COMPA_ISR

;==============================================================================
; Main Program
;==============================================================================
main:
    ;initialize stack pointer
    ;load low ramend into r16
    ldi r16, lo8(RAMEND)
    ;store r16 in stack pointer low
    sts SPL, r16
    ldi r16, hi8(RAMEND)
    sts SPH, r16

    ;setup data diretion register for port A pins
    in r16, DDRA ; DDRA IO ADDR | PA0_AD0 - x step | PA1_AD1 - x dir
    ori r16, 0x03 ; sets bits 0 and 1
    out DDRA, r16

    ;set stepper direction
    in r16, PORTA ; PORTA
    andi r16, 0xFD
    out PORTA, r16

    ;setup timer1 16 bit 
    ldi r16, 0x00
    sts TCCR1A, r16

    ;configure prescaler mux
    ;clk, clk/8, clk/64, clk/256, clk/1024, falling edge, rising, edge
    ;WGM sets CTC mode 
    ldi r16, 0x0D  
    sts TCCR1B, r16

    ;load compare value
    ldi r16, lo8(TIMER_COMP_VAL)
    sts OCR1AL, r16
    ldi r16, hi8(TIMER_COMP_VAL)
    sts OCR1AH, r16

    ;enable output compare interrupt
    ldi r16, 0x02 ;enable OCIE1A
    sts TIMSK1, r16

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
    ldi r17, 0x01 ; x step bit mask
    eor r16, r17 ;xor bit toggle
    out PORTA, r16 ;write new state back to GPIO

    ;restore context
    pop r16
    out SREG, r16
    pop  r16

    reti ;return from interrupt

