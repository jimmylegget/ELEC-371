#include "nios2_control.h"
#include "leds.h"
#include "timer.h"

extern volatile char flag;

void interrupt_handler(void) {
	
	/* read current value in ipending register */
	unsigned int ipending = NIOS2_READ_IPENDING();

	// If pending interrupt is from orig. timer
	if(ipending & TIMER_PROC_STATUS_BIT) {
		
		 // Clear interrupt bit in timer status register
		unsigned int timerStatus = *TIMER_STATUS;
		timerStatus &= ~TIMER_TO_BIT;
		*TIMER_STATUS = timerStatus;
		
		// Toggle least significant LED
		*LEDS = *LEDS ^ 0x1;

		// Set the flag
		flag = 1;
	
	}

	// If pending interrupt is from timer 0
	if(ipending & TIMER_T0_PROC_STATUS_BIT) {
		
		 // Clear interrupt bit in timer status register
		unsigned int timerStatus = *TIMER_T0_STATUS;
		timerStatus &= ~TIMER_TO_BIT;
		*TIMER_T0_STATUS = timerStatus;
		
		// Toggle LED #2
		*LEDS = *LEDS ^ 0x2;

		// Set the flag
		flag = 1;
	
	}
	
}
