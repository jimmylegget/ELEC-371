#ifndef _BUTTONS_H_
#define _BUTTONS_H_


/* define pointer macro for accessing the buttons interface registers */
#define BUTTONS_MASK_REGISTER	((volatile unsigned int *) 0x10000058)
#define BUTTONS_EDGE_REGISTER	((volatile unsigned int *) 0x1000005C)

// Pattern to represent the bit in proc. ienable reg. for recognizing interrupts from buttons hardware 
#define IENABLE_BUTTONS_IE		0x2

#endif /* _BUTTONS_H_ */
