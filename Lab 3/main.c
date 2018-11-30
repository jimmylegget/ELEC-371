#include "nios2_control.h"
#include "timer.h"
#include "chario.h"
#include "switches.h"

volatile char flag;

void	Init (void) {

  /* initialize software variables */
  long timerCycles = 25000000;
  long timerT0Cycles = 12500000;

  // ========================= Orig. Timer =========================
  
  /* set timer start value for interval of HALF SECOND (0.5 sec) */
  *TIMER_START_LO = timerCycles & 0xFFFF;
  *TIMER_START_HI = timerCycles >> 16;

  /* clear extraneous timer interrupt */
  *TIMER_STATUS = 0x0;

  /* set ITO, CONT, and START bits of timer control register */
  *TIMER_CONTROL = 0x7;
  
  // ========================= Timer 0 =========================
  
  /* set timer start value for interval of HALF SECOND (0.5 sec) */
  *TIMER_T0_START_LO = timerT0Cycles & 0xFFFF;
  *TIMER_T0_START_HI = timerT0Cycles >> 16;

  /* clear extraneous timer interrupt */
  *TIMER_T0_STATUS = 0x0;

  /* set ITO, CONT, and START bits of timer control register */
  *TIMER_T0_CONTROL = 0x7;
  
  // ========================= Processor =========================
  
  /* set device-specific bit for timer in Nios II ienable register */
  NIOS2_WRITE_IENABLE(TIMER_PROC_STATUS_BIT | TIMER_T0_PROC_STATUS_BIT);

  /* set IE bit in Nios II status register */
  NIOS2_WRITE_STATUS(NIOS2_STATUS_IE_BIT);

}


int	main (void) {

  // Loop counter
  int i;

  /* perform initialization */
  Init ();
  
  // Print a string to the JTAG UART
  PrintString("ELEC371 Lab 3\n");
  PrintString("          ");

  /* main program prints an asteric character when the timer interrupt sets the flag */
  while (1) {
	if(flag) {
	  PrintString("\b\b\b\b\b\b\b\b\b\b");
	  
	  unsigned int switchesData = *SWITCHES;
	  
	  for(i = 9; i >= 0; i--) {
		  
		if(switchesData & (1<<i)) {
		  PrintChar('1');
		} else {
		  PrintChar('_');
		}
		  
	  }
	  
	  flag = 0;
	}
  }

  /* never reached, but needed to avoid compiler warning */
  return 0; 
  
}
