#include "nios2_control.h"
#include "adc.h"
#include "leds.h"
#include "timer.h"
#include "chario.h"
#include "buttons.h"

extern volatile char flag;

void Init (void) {

  // Initialize timing variables
  float timerPeriod = 1; // s
  float timerT0Period = 0.5; // s
  float timerT1Period = 0.25; // s

  // ========================= Orig. Timer =========================
  
  /* set timer start value for interval of HALF SECOND (0.5 sec) */
  *TIMER_START_LO = (long)(timerPeriod * CPU_CLOCK) & 0xFFFF;
  *TIMER_START_HI = (long)(timerPeriod * CPU_CLOCK) >> 16;

  /* clear extraneous timer interrupt */
  *TIMER_STATUS = 0x0;

  /* set ITO, CONT, and START bits of timer control register */
  *TIMER_CONTROL = 0x7;
  
  // ========================= Timer 0 =========================
  
  /* set timer start value for interval of HALF SECOND (0.5 sec) */
  *TIMER_T0_START_LO = (long)(timerT0Period * CPU_CLOCK) & 0xFFFF;
  *TIMER_T0_START_HI = (long)(timerT0Period * CPU_CLOCK) >> 16;

  /* clear extraneous timer interrupt */
  *TIMER_T0_STATUS = 0x0;

  /* set ITO, CONT, and START bits of timer control register */
  *TIMER_T0_CONTROL = 0x7;
  
  // ========================= Timer 1 =========================
  
  /* set timer start value for interval of HALF SECOND (0.5 sec) */
  *TIMER_T1_START_LO = (long)(timerT1Period * CPU_CLOCK) & 0xFFFF;
  *TIMER_T1_START_HI = (long)(timerT1Period * CPU_CLOCK) >> 16;

  /* clear extraneous timer interrupt */
  *TIMER_T1_STATUS = 0x0;

  /* set ITO, CONT, and START bits of timer control register */
  *TIMER_T1_CONTROL = 0x7;
  

  // ========================= Buttons =========================
  
  //  Enable interrupts on pushbutton 0
  *BUTTONS_MASK_REGISTER = 0x3;
  
  // Clear the buttons edge register to prevent false interrupts
  *BUTTONS_EDGE_REGISTER = 0x1;

  // ========================= Processor =========================
  
  /* set device-specific bit for timers and buttons in Nios II ienable register */
  NIOS2_WRITE_IENABLE(TIMER_PROC_STATUS_BIT | TIMER_T0_PROC_STATUS_BIT | TIMER_T1_PROC_STATUS_BIT | IENABLE_BUTTONS_IE);

  /* set IE bit in Nios II status register */
  NIOS2_WRITE_STATUS(NIOS2_STATUS_IE_BIT);

}


int	main (void) {

  // Perform initialization
  Init ();
  
  // Print a string to the JTAG UART
  PrintString("ELEC371 Lab 4\n");
  
  // Set up the ADC companion board to read in data from analog potentiometer port
  InitADC(2, 2);

  // Print one blank space character
  PrintChar(' ');
  
  // Main loop
  while (1) {
	  
	// Read data from analog potentiometer port and write it out to the LEDs
	unsigned int analogValue = ADConvert();
	//*LEDS = analogValue;
	
	// If the flag is set by the timer interrupt
	if(flag) {
		
		// Print a backspace character
		PrintChar('\b');
		
		// Print the value
		PrintChar('0' + (analogValue >> 5));
		
		// Clear the flag
		flag = 0;
		
	}
	
  }

  // Never reached, but needed to avoid compiler warning
  return 0; 
  
}
