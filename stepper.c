#include <avr/io.h>
#include <avr/interrupt.h>
#include <util.h>

#ifndef F_CPU
#define F_CPU 16000000UL
#endif

// 16MHz/(Prescaler + (1 + OCR1A))
// output compare register timer 1
#define TIMER1_COMP_VAL 999 


#define STEP_PORT   PORTA
#define STEP_DDR    DDRA // data directin register
#define STEP_PIN    PA0

#define DIR_PORT    PORTA
#define DIR_DDR     DDRA
#define DIR_PIN     PA1

#define ENABLE_PORT PORTE
#define ENABLE_DDR  DDRE
#define ENABLE_PIN  PE7

ISR(TIMER1_COMPA_vect){
    // left shifts step pin 
    STEP_PORT |= (1<<STEP_PIN);
    // 1us delay from Allegro A4982 datasheet
    _delay_us(1);
    STEP_PORT &= ~(1<<STEP_PIN);
}


int main(void){
    // enable stepper drivers
    // set data direction as output (high)
    ENABLE_DDR |= (1<<ENABLE_PIN);
    ENABLE_PORT |= (1<<ENABLE_PIN);

    // set data direction as output for direction
    DIR_DDR |= (1<<DIR_PIN);
    DIR_PORT |= (1<<DIR_PIN);

    // set data direction as output for step
    STEP_DDR |= (1<<);

    // configure timer1 16 bit
    // WMG12 sets CTC mode - CS10 | CS12 sets 1024 prescaler
    TCCR1A = 0; 
    TCCR1B = 0;

    TCCR1B = (1 << WGM12) | (1 << CS12) | (1 << CS10);
    
    // load the comparison value into the output compare register
    OCR1A = TIMER_COMP_VAL;

    // interrupt configuration
    TIMSK1 |= (1 << OCIE1A);
    
    // enable global interrupts 
    sei();

    while (1){
        // main program loop
    }
    return 0;
}