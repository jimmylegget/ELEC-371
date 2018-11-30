#ifndef _HEX_DISPLAYS_H_
#define _HEX_DISPLAYS_H_


// Define pointer macro for accessing the HEX displays data register
#define HEX_DISPLAYS	((volatile unsigned int *) 0x10000020)

// LEDs number mappings
unsigned int hex_table[] = {
	0x3F, 0x06, 0x5B, 0x4F,
	0x66, 0x6D, 0x7D, 0x07,
	0x7F, 0x6F, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00
};

#endif /* _HEX_DISPLAYS_H_ */
