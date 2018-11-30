#include "nios2_control.h"
#include "leds.h"
#include "timer.h"
#include "buttons.h"
#include "hex_displays.h"

volatile char flag;
volatile char run = 1;

volatile int minutes_tens, minutes_ones, seconds_tens, seconds_ones;

void HandleOrigTimer() {
	
	// Clear interrupt bit in timer status register
	unsigned int timerStatus = *TIMER_STATUS;
	timerStatus &= ~TIMER_TO_BIT;
	*TIMER_STATUS = timerStatus;
	
	// Set the flag
	flag = 1;
	
	// Increment seconds_ones
	seconds_ones++;
	
	// If it becomes 10, reset it to 0 and increment seconds_tens
	if(seconds_ones >= 10) {
		seconds_ones = 0;
		seconds_tens++;
	}
	
	// If seconds_tens becomes 6, reset it to 0 and increment minutes_ones
	if(seconds_tens >= 6) {
		seconds_tens = 0;
		minutes_ones++;
	}
	
	// If minutes_ones becomes 10, reset it to 0 and increment minutes_tens
	if(minutes_ones >= 10) {
		minutes_ones = 0;
		minutes_tens++;
	}
	
	// If minutes_tens becomes 6, reset it to 0
	if(minutes_tens >= 6) {
		minutes_tens = 0;
	}
	
	// If not running, don't do anything with the LEDS
	if(!run) {
		return;
	}
	
	// Display the time
	*HEX_DISPLAYS =
	(hex_table[minutes_tens] << 24) |
	(hex_table[minutes_ones] << 16) |
	(hex_table[seconds_tens] << 8) |
	(hex_table[seconds_ones]);
	
}

void HandleTimer0() {
	
	// Clear interrupt bit in timer status register
	unsigned int timerStatus = *TIMER_T0_STATUS;
	timerStatus &= ~TIMER_TO_BIT;
	*TIMER_T0_STATUS = timerStatus;
	
	// If not running, don't do anything with the LEDS
	if(!run) {
		return;
	}
	
	// Get the current LEDs turned on status
	unsigned int currentLEDsValue = *LEDS;
	
	// If leftmost LED is turned on
	if(currentLEDsValue & 0x200) {
		currentLEDsValue &= ~(0x3C0);		// Clear 4 leftmost LEDs
		currentLEDsValue |= (0xC0); 		// Turn on leftmost LED pattern to 0011
		//currentLEDsValue = 0;
	}
	// Otherwise
	else {
		currentLEDsValue &= ~(0x3C0);		// Clear 4 leftmost LEDs
		currentLEDsValue |= (0x300); 		// Turn on leftmost LED pattern to 1100
		//currentLEDsValue = 0x3FF;
	}
	
	// Set the LEDs to the required pattern
	*LEDS = currentLEDsValue;
	
}

void HandleTimer1() {
	
	// Clear interrupt bit in timer status register
	unsigned int timerStatus = *TIMER_T1_STATUS;
	timerStatus &= ~TIMER_TO_BIT;
	*TIMER_T1_STATUS = timerStatus;
	
	// If not running, don't do anything with the LEDS
	if(!run) {
		return;
	}
	
	// Get the current LEDs turned on status
	unsigned int currentLEDsValue = *LEDS;
	
	// If none of the rightmost 4 LEDs are turned on
	if(!(currentLEDsValue & 0xF)) {
		currentLEDsValue |= 8;				// Turn on 4th LED from the right
	}
	// Otherwise
	else {
		
		// Shift current turned on LED right
		unsigned int currentRightmost4LEDsValue = currentLEDsValue & 0xF;
		currentRightmost4LEDsValue = currentRightmost4LEDsValue >> 1;
		
		currentLEDsValue &= ~(0xF);		// Clear 4 rightmost LEDs
		currentLEDsValue |= currentRightmost4LEDsValue;
		
		// Handle wraparound
		if(!(currentLEDsValue & 0xF)) {
			currentLEDsValue |= 8;			// Turn on 4th LED from the right
		}
		
	}
	
	// Set the LEDs to the required pattern
	*LEDS = currentLEDsValue;
	
}

void HandleButtons() {
	
	// Clear interrupt bit in buttons edge status register by writing to it
	*BUTTONS_EDGE_REGISTER = *BUTTONS_EDGE_REGISTER;
	
	// Toggle run flag
	run = !run;
	
}
	
void interrupt_handler(void) {
	
	// Read current value in ipending register 
	unsigned int ipending = NIOS2_READ_IPENDING();

	// If pending interrupt is from original DE0 timer
	if(ipending & TIMER_PROC_STATUS_BIT) {
		
		// Handle interrupt from original DE0 timer
		HandleOrigTimer();
		
	}

	// If pending interrupt is from timer 0
	if(ipending & TIMER_T0_PROC_STATUS_BIT) {
		
		// Handle interrupt from timer 0
		HandleTimer0();
		
	}
	
	// If pending interrupt is from timer 1
	if(ipending & TIMER_T1_PROC_STATUS_BIT) {
		
		// Handle interrupt from timer 1
		HandleTimer1();
		
	}
	
	// If pending interrupt is from buttons
	if(ipending & IENABLE_BUTTONS_IE) {
		
		// Handle interrupt from buttons
		HandleButtons();
		
	}
	
}
