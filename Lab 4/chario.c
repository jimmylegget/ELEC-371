#include "chario.h"

void PrintChar(unsigned int c) {
	
	// Wait for JTAG UART to be ready to accept more characters
	unsigned int writeStatus;
	do {
		writeStatus = (*JTAG_UART_STATUS) & WRITE_STATUS_MASK;
	} while(!writeStatus);
	
	// Write the character to the JTAG UART
	*JTAG_UART_DATA = c;
	
}


void PrintString(char *s) {
	
	// Print all the characters in the string
	int i = 0;
	while(s[i] != '\0') {
		PrintChar(s[i++]);
	}
	
}
