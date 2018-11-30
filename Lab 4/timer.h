#ifndef _TIMER_H_
#define _TIMER_H_

#define CPU_CLOCK	50000000 // 50 MHz

/* define pointer macros for accessing the timer interface registers */

#define TIMER_STATUS	((volatile unsigned int *) 0x10002000)
#define TIMER_CONTROL	((volatile unsigned int *) 0x10002004)
#define TIMER_START_LO	((volatile unsigned int *) 0x10002008)
#define TIMER_START_HI	((volatile unsigned int *) 0x1000200C)
#define TIMER_SNAP_LO	((volatile unsigned int *) 0x10002010)
#define TIMER_SNAP_HI	((volatile unsigned int *) 0x10002014)

#define TIMER_T0_STATUS		((volatile unsigned int *) 0x10004000)
#define TIMER_T0_CONTROL	((volatile unsigned int *) 0x10004004)
#define TIMER_T0_START_LO	((volatile unsigned int *) 0x10004008)
#define TIMER_T0_START_HI	((volatile unsigned int *) 0x1000400C)

#define TIMER_T1_STATUS		((volatile unsigned int *) 0x10004020)
#define TIMER_T1_CONTROL	((volatile unsigned int *) 0x10004024)
#define TIMER_T1_START_LO	((volatile unsigned int *) 0x10004028)
#define TIMER_T1_START_HI	((volatile unsigned int *) 0x1000402C)

/* define a bit pattern reflecting the position of the timeout (TO) bit
   in the timer status register */

#define TIMER_TO_BIT 0x1

/* define a bit pattern reflecting the position of the timer interrupt enable bit
   in the processor status register */

#define TIMER_PROC_STATUS_BIT 0x1 // Bit 0
#define TIMER_T0_PROC_STATUS_BIT 0x2000 // Bit 13
#define TIMER_T1_PROC_STATUS_BIT 0x4000 // Bit 14

#endif /* _TIMER_H_ */