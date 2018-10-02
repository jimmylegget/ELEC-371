#-----------------------------------------------------------------------------
# template source file for ELEC 371 Lab 1 Part 2
#-----------------------------------------------------------------------------

	.text			# inform assembler that code section begins
				#   (but note that in this course, we also
				#    place "data" in what would normally be
				#    a section with only instructions)
	.global _start		# export _start symbol for linker

#-----------------------------------------------------------------------------
# define symbols for memory-mapped I/O register addresses and use them in code
#-----------------------------------------------------------------------------

	.equ	SWITCHES_DATA_REGISTER, 0x10000040
	.equ	HEX_DISPLAYS_DATA_REGISTER, 0x10000020
	.equ	LAST_RAM_WORD,	0x007FFFFC

#-----------------------------------------------------------------------------

	.org 0			# place first instruction below at address 0
_start:				# start of main() routine in this case
		
	movia	sp, LAST_RAM_WORD	# initialize stack pointer
    
mainloop:
	
    call	ReadSwitches
    call 	WriteHexDisplays
    
	br 		mainloop

#-----------------------------------------------------------------------------

ReadSwitches:
	subi    sp, sp, 4
    stw     r3, 0(sp)	# Address of switches
    
    movia	r3, SWITCHES_DATA_REGISTER
	ldwio	r2, 0(r3)	# Read the switches
    
    ldw     r3, 0(sp)
    addi    sp, sp, 4
	ret

#-----------------------------------------------------------------------------

WriteHexDisplays:
	subi    sp, sp, 4
    stw     r3, 0(sp)	# Address of HEX displays
    
    movia	r3, HEX_DISPLAYS_DATA_REGISTER
	stwio	r2, 0(r3)	# Write to the HEX displays
    
    ldw     r3, 0(sp)
    addi    sp, sp, 4
	ret
  
	.end
