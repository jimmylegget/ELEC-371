#--------------------------------------------------------------------------
# ELEC 371 file for basic use of timer interrupt + buttons interrupt
# (the original timer interface from the DE0 computer system is used)
#--------------------------------------------------------------------------

# directives to define symbolic labels for addresses/constants 

	.equ	INITIAL_STACK_TOP, 0x007FFFFC		# Start of stack in RAM 

	.equ	LEDS, 0x10000010					# LED output port address 

	.equ	HEX_DISPAYS, 0x10000020				# HEX displays output port address 
	
	.equ 	JTAG_UART_BASE, 0x10001000 			# address of first JTAG UART register
	.equ 	DATA_OFFSET, 0 						# offset of JTAG UART data register
	.equ 	STATUS_OFFSET, 4 					# offset of JTAG UART status register
	.equ 	WRITE_MASK, 0xFFFF 					# used in ANDHI operation to check valid status
	.equ 	READ_MASK, 0x8000 					# used in ANDI operation to check valid data
	.equ 	DATA_MASK, 0xFF 					# used in ANDI operation to get data
	
	.equ	SWITCHES_DATA, 0x10000040				# switches data register 
	
	.equ	BUTTONS_MASK_REGISTER, 0x10000058	# buttons mask register 
	.equ	BUTTONS_EDGE_REGISTER, 0x1000005C	# buttons edge register 
	
	.equ	IENABLE_BUTTONS_IE, 0x2				# pattern to represent the bit in procr ienable reg. for recognizing interrupts from buttons hardware 
			
	.equ	TIMER_STATUS, 0x10002000			# timer status register 
	.equ	TIMER_CONTROL, 0x10002004			# timer control register 
	.equ	TIMER_START_LO, 0x10002008			# low bits of start value 
	.equ	TIMER_START_HI, 0x1000200C			# high bits of start value 
	.equ	TIMER_SNAP_LO, 0x10002010			# low bits of count value 
	.equ	TIMER_SNAP_HI, 0x10002014			# high bits of count value 
		
    .equ	TIMER_START_VALUE, 10000000			# 10000000 = 0.2s at 50MHz
	
	.equ 	TIMER_TO_BIT, 0x1					# pattern to represent the bit in timer status register that is set on timeout (when count reaches zero)
	.equ	IENABLE_TIMER_IE, 0x1				# pattern to represent the bit in procr ienable reg. for recognizing interrupts from timer hardware 
		
	.equ	NIOS2_IE, 0x1						# pattern to represent the bit in procr status reg. for global recognition of all interrupts 

#--------------------------------------------------------------------------

	.text			# start a code segment 

	.global	_start	# export _start symbol for linker 

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main		# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr			# branch to start of interrupt service routine 
					# (rather than placing all of the service code here) 

#--------------------------------------------------------------------------


main:
	# initialize stack pointer (make it a habit to always do this)
	movia 	sp, INITIAL_STACK_TOP

	# perform initialization
	call Init

	# main loop
mloop:
	
	call GetChar				# Read in a character and store it into r2
	
	movia	r3, SWITCHES_DATA
	ldwio 	r3, 0(r3) 			# Read the switches
	andi	r3, r3, 0x1			# Get the first switch status bit (SW0)
	beq		r3, r0, mloop		# If the first is not set, don't print
	
	call PrintChar				# Write out the character from r2
	
	br	mloop

#--------------------------------------------------------------------------

PrintChar:
	subi 	sp, sp, 4*2 			
	stw 	r3, 4*0(sp) 			# Stores JTAG base address
	stw 	r4, 4*1(sp) 			# Stores temp value
	
	movia 	r3, JTAG_UART_BASE 		# JTAG base address
	
pcw_loop:
	ldwio 	r4, STATUS_OFFSET(r3) 	# Read bits from status register
	andhi 	r4, r4, WRITE_MASK 		# Mask off lower bits to isolate upper bits
	beq 	r4, r0, pcw_loop 		# If upper bits are zero, JTAG port is busy so loop again
	stwio	r2, DATA_OFFSET(r3) 	# Otherwise, write character from r2 to data register

	ldw 	r3, 4*0(sp) 				
	ldw 	r4, 4*1(sp) 				
	addi 	sp, sp, 4*2				
	ret 							

#--------------------------------------------------------------------------

GetChar:
	subi 	sp, sp, 4*3 			
	stw 	r3, 4*0(sp) 			# Stores JTAG base address
	stw 	r4, 4*1(sp) 			# Stores character value
	stw 	r5, 4*2(sp) 			# Stores valid bit value
	
	movia 	r3, JTAG_UART_BASE 		# JTAG base address
	
pcr_loop:
	ldwio 	r4, DATA_OFFSET(r3) 	# Read bits from data register
	andi 	r5, r4, READ_MASK 		# Check is valid bit is set
	beq 	r5, r0, pcr_loop 		# If valid bit is zero, JTAG port does not have valid data so loop again
	andi	r2, r4, DATA_MASK		# Otherwise, store lower 8 bits of character from data register to r2

	ldw 	r3, 4*0(sp) 				
	ldw 	r4, 4*1(sp) 			
	ldw 	r5, 4*2(sp) 					
	addi 	sp, sp, 4*3				
	ret 		
#--------------------------------------------------------------------------

Init:
	subi	sp, sp, 4*2
    stw		r3, 4*0(sp)				# Stores temp value
    stw		r4, 4*1(sp)				# Stores addresses
    stw		r5, 4*2(sp)				# Stores values
      
	movia	r4, LEDS				# Store the LEDs data register address
	movia	r5, 0x300				# Store the initial LEDS on status (top 2)
    stwio	r5, 0(r4)				# Write to LEDs to turn on the top 2
	
	movia	r4, HEX_DISPAYS			# Store the HEX displays data register address
    stwio	r0, 0(r4)				# Write 0 to HEX displays to turn them off
	
	movia	r4, BUTTONS_MASK_REGISTER
	movi	r5, 0b0011
	stwio	r5, 0(r4)				# Enable interrupts on pushbutton 0
    
    movia	r4, BUTTONS_EDGE_REGISTER
	movi	r5, 1
    stwio	r5, 0(r4)				# Clear the buttons edge register to prevent false interrupts
    
    movi	r5, IENABLE_BUTTONS_IE	# Store the buttons IE bit
    wrctl	ienable, r5				# Write the buttons IE bit to the ienable control register
   
    movia	r4, TIMER_STATUS		# Store the timer status register address
    ldwio	r5, 0(r4)				# Read the timer status register
    movia	r3, ~TIMER_TO_BIT		# Store the inverse of the timer status TO bit as a bitmask
    and		r5, r5, r3				# Clear the timer status TO bit
   	stwio	r5, 0(r4)				# Write 0 to timer status to clear interrupt bit
    
    movia	r4, TIMER_START_LO		# Store the timer start lo register address
    movia	r5, TIMER_START_VALUE 	# Store start value to set
    stwio	r5, 0(r4)				# Store the lower 16 bits in start lo register
    srli	r5, r5, 16				# Shift the start value 16 bits to the right
    stwio	r5, 4(r4)				# Store the upper 16 bits in start hi register
      
    movia	r4, TIMER_CONTROL		# Store the timer control register address
    movi	r5, 0x7					# Store 0x7 to set the lowers 3 bits to 1 (0b0111)
    stwio	r5, 0(r4)				# Set the lowest 3 bits in timer control register to start timer, enable continuous mode, and enable interrupt
    
	rdctl	r5, ienable				# Read the ienable control register
	ori		r5, r5, IENABLE_TIMER_IE
    wrctl	ienable, r5				# Add the timer IE bit to the ienable control register
   
    movi	r5, NIOS2_IE			# Store the NIOS2 IE bit
    wrctl	status, r5				# Write the NIOS2 IE bit to the status control register
      
    ldw     r3, 4*0(sp)
    ldw     r4, 4*1(sp)
    ldw     r5, 4*2(sp)
    addi    sp, sp, 4*2          
	ret

#-----------------------------------------------------------------------------
# The code for the interrupt service routine is below. Note that the branch
# instruction at 0x0020 is executed first upon recognition of interrupts,
# and that branch brings the flow of execution to the code below.
# This exercise involves only hardware-generated interrupts. Therefore, the
# return-address adjustment on the ea register is performed unconditionally.
#-----------------------------------------------------------------------------

isr:
	subi	sp, sp, 4*3
    stw		et, 4*0(sp)					# Temporary
    stw		r4, 4*1(sp)					# Button interrupt mask register address
    stw		r5, 4*2(sp)					# Stores values that are written to control registers
			
    rdctl 	et, ipending				# Read pending interrupts
    beq 	et, r0, end_isr 			# If this is not a hardware interrupt, exit
			
	addi	ea, ea, -4					# This is _required_ for hardware interrupts

	andi	r4, et, IENABLE_TIMER_IE	# Check for timer interrupt
	beq		r4, r0, not_timer			# If interrupt was not caused by timer, check if interrupt was caused by buttons
    
	movia	et, TIMER_STATUS			# Store the timer status register address
    ldwio	r4, 0(et)					# Read the timer status register
    movia	r5, ~TIMER_TO_BIT			# Store the inverse of the timer status TO bit as a bitmask
    and		r4, r4, r5					# Clear the timer status TO bit
   	stwio	r4, 0(et)					# Write 0 to timer status to clear interrupt bit
			
    movia	et, LEDS		
    ldwio	r4, 0(et)					# Read LED status
    srli	r4, r4, 0x2					# Shift the LEDs that are on right by 2, wrapping around
	bne		r4, r0, skip_start_state	# If the shift has turned all the LEDs off, restore the start state (top 2 on)
	movia	r4, 0x300					# Store the initial LEDS on status (top 2)
skip_start_state:
	stwio	r4, 0(et)					# Set LED status
    
not_timer:

    rdctl 	et, ipending				# Read pending interrupts
	andi	r4, et, IENABLE_BUTTONS_IE	# Check for button interrupt
	beq		r4, r0, end_isr				# If interrupt was not caused buttons, exit
    
	movia	r4, BUTTONS_EDGE_REGISTER
    ldwio	r5, 0(r4)					# Read the buttons edge register
    stwio	r5, 0(r4)					# Clear the buttons edge register to prevent more interrupts
			
    andi	r5, r5, IENABLE_BUTTONS_IE	# Check if button 0 is pressed
	beq		r5, r0, end_isr				# If button 0 was not pressed, exit
    
    movia	et, HEX_DISPAYS
	movia	r5, 0xFFFFFFFF
    ldwio	r4, 0(et)					# Read HEX displays status
    xor		r4, r4, r5					# Toggle all the HEX displays status
    stwio	r4, 0(et)					# Set HEX displays status
	
	#movia	r5, 0xFFFFFFFF
    #ldwio	r4, 8(et)					# Read HEX displays status
    #xor		r4, r4, r5					# Toggle all the HEX displays status
    #stwio	r4, 8(et)					# Set HEX displays status
	
end_isr:
	ldw		et, 4*0(sp)
    ldw     r4, 4*1(sp)
    ldw     r5, 4*2(sp)
    addi    sp, sp, 4*3
    
	eret		# interrupt service routines end _differently_
				# than normal subroutines; the eret goes back
				# to wherever execution was at the time the
				# interrupt request triggered invocation of
				# the service routine

	.end
