#--------------------------------------------------------------------------
# ELEC 371 file for basic use of timer interrupt
# (the original timer interface from the DE0 computer system is used)
#--------------------------------------------------------------------------

# directives to define symbolic labels for addresses/constants 

	.equ	INITIAL_STACK_TOP, 0x007FFFFC	# start of stack in RAM 

	.equ	LEDS, 0x10000010					# LED output port address 

	.equ	TIMER_STATUS, 0x10002000			# timer status register 
	.equ	TIMER_CONTROL, 0x10002004			# timer control register 
	.equ	TIMER_START_LO, 0x10002008			# low bits of start value 
	.equ	TIMER_START_HI, 0x1000200C			# high bits of start value 
	.equ	TIMER_SNAP_LO, 0x10002010			# low bits of count value 
	.equ	TIMER_SNAP_HI, 0x10002014			# high bits of count value 
		
    .equ	TIMER_START_VALUE, 0x17D7840		# 25000000 = 0.5s at 50MHz
	
	.equ 	TIMER_TO_BIT, 0x1					# pattern to represent the bit in timer status register that is set on timeout (when count reaches zero)
	.equ	IENABLE_TIMER_IE, 0x1				# pattern to represent the bit in procr ienable reg. for recognizing interrupts from timer hardware 
		
	.equ	NIOS2_IE, 0x1						# pattern to represent the bit in procr status reg. for global recognition of all interrupts 

#--------------------------------------------------------------------------

	.text		# start a code segment 

	.global	_start	# export _start symbol for linker 

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			# (rather than placing all of the service code here) 

#--------------------------------------------------------------------------


main:
	# initialize stack pointer (make it a habit to always do this)
	movia 	sp, INITIAL_STACK_TOP

	# perform initialization
	call Init

	# main loop
mloop:
	br	mloop

#--------------------------------------------------------------------------

Init:
	subi	sp, sp, 4*2
    stw		r3, 4*0(sp)				# Stores temp value
    stw		r4, 4*1(sp)				# Stores addresses
    stw		r5, 4*2(sp)				# Stores values
      
	movia	r4, LEDS				# Store the LEDs data register address
    stwio	r0, 0(r4)				# Write 0 to LEDs to turn them all off
    
    movia	r4, TIMER_STATUS		# Store the timer status register address
    ldwio	r5, 0(r4)				# Read the timer status register
    movia	r3, ~TIMER_TO_BIT		# Store the inverse of the timer status TO bit as a bitmask
    and		r5, r5, r3				# Clear the timer status TO bit
   	stwio	r5, 0(r4)				# Write 0 to timer status to clear interrupt bit
    
    movia	r4, TIMER_START_LO		# Store the timer start lo register address
    movia	r5, TIMER_START_VALUE 	# Store start value to set
    stwio	r5, 0(r4)				# Store the lowest 16 bits in start lo register
    srli	r5, r5, 16				# Shift the start value 16 bits to the right
    stwio	r5, 4(r4)				# Store the upper 16 bits in start hi register
      
    movia	r4, TIMER_CONTROL		# Store the timer control register address
    movi	r5, 0x7					# Store 0x7 to set the lowers 3 bits to 1 (0b0111)
    stwio	r5, 0(r4)				# Set the lowest 3 bits in timer control register to start timer, enable continuous mode, and enable interrupt
    
    movi	r5, IENABLE_TIMER_IE	# Store the timer IE bit
    wrctl	ienable, r5				# Write the timer IE bit to the ienable control register
   
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
    stw		et, 4*0(sp)			# Temporary
    stw		r4, 4*1(sp)			# Button interrupt mask register address
    stw		r5, 4*2(sp)			# Stores values that are written to control registers
    
    rdctl 	et, ipending		# Read pending interrupts
    beq 	et, r0, end_isr 	# If this is not a hardware interrupt, exit
    
	addi	ea, ea, -4			# This is _required_ for hardware interrupts

	andi	r4, et, IENABLE_TIMER_IE	# Check for timer interrupt
	beq		r4, r0, end_isr				# If interrupt was not caused by timer, exit
    
	movia	et, TIMER_STATUS	# Store the timer status register address
    ldwio	r4, 0(et)			# Read the timer status register
    movia	r5, ~TIMER_TO_BIT	# Store the inverse of the timer status TO bit as a bitmask
    and		r4, r4, r5			# Clear the timer status TO bit
   	stwio	r4, 0(et)			# Write 0 to timer status to clear interrupt bit
    
    movia	et, LEDS
    ldwio	r4, 0(et)			# Read LED status
    xori	r4, r4, 1			# Toggle the LED status
    stwio	r4, 0(et)			# Set LED status
    
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
