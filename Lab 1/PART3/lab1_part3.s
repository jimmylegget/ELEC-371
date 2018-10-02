#-----------------------------------------------------------------------------
# template source file for ELEC 371 Lab 1 Part 3
#-----------------------------------------------------------------------------

	.text		# start a code segment 

	.global	_start	# export _start symbol for linker 

#-----------------------------------------------------------------------------
# define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

	.equ	BUTTONS_MASK_REGISTER, 0x10000058
	.equ	BUTTONS_EDGE_REGISTER, 0x1000005C

	.equ	LEDS_DATA_REGISTER, 0x10000010

	.equ	LAST_RAM_WORD,	0x007FFFFC
    
#-----------------------------------------------------------------------------

	.org	0x0000	# this is the _reset_ address 
_start:
	br	main	# branch to actual start of main() routine 

	.org	0x0020	# this is the _exception/interrupt_ address
 
	br	isr	# branch to start of interrupt service routine 
			# (rather than placing all of the service code here) 

#-----------------------------------------------------------------------------

main:

	movia	sp, LAST_RAM_WORD	# initialize stack pointer

	call	Init
    mov		r3, r0				# Initialize counter to 0

mainloop:

	addi	r3, r3, 1			# Increment counter
    
	br mainloop

#-----------------------------------------------------------------------------

Init:
	
    subi	sp, sp, 4*2
    stw		r4, 4*0(sp)	# Button interrupt mask register address
    stw		r5, 4*1(sp)	# Stores values that are written to control registers
    
    movia	r4, BUTTONS_MASK_REGISTER
	movi	r5, 0b0011
	stwio	r5, 0(r4)	# Enable interrupts on pushbutton 0
    
    movia	r4, BUTTONS_EDGE_REGISTER
	movi	r5, 1
    stwio	r5, 0(r4)	# Clear the buttons egde register to prevent false interrupts
    
    movi	r5, 0b0010
	wrctl	ienable, r5	# Enable processor to recognize pushbutton 0 interrupt
    
	movi	r5, 1
	wrctl	status, r5	# Enable processor to respond to all interrupts
    
    ldw     r4, 4*0(sp)
    ldw     r5, 4*1(sp)
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

	andi	r4, et, 0b0010		# Check for button interrupt
	beq		r4, r0, end_isr		# If interrupt was not caused buttons, exit
    
	movia	r4, BUTTONS_EDGE_REGISTER
    ldwio	r5, 0(r4)			# Read the buttons egde register
    stwio	r5, 0(r4)			# Clear the buttons egde register to prevent more interrupts
    
    andi	r5, r5, 0b0010		# Check if button 0 is pressed
	beq		r5, r0, end_isr		# If button 0 was not pressed, exit
    
    movia	et, LEDS_DATA_REGISTER
    ldwio	r5, 0(et)			# Read LED status
    xori	r5, r5, 1			# Toggle the LED status
    stwio	r5, 0(et)			# Set LED status
    
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
