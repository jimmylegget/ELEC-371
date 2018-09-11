.global _start

.equ	LAST_RAM_WORD,	0x007FFFFC

_start:

	movia	sp, LAST_RAM_WORD	# Set stack pointer address
	
	movia	r4, LIST1			# Move address of LIST1 in r4
    movia	r5, LIST2			# Move address of LIST2 in r5
    movia 	r6, 10				# Set 10 as Number of elements
    
    call 	NonZeroCopyList		# Call the NonZeroCopyList subroutine
    							# Now, LIST2 is copy of the non-zero elements in LIST1
    
_end:
	br _end
	
# ==================== NON-ZERO COPY LIST FUNCTION ====================
    
# In  r4: Pointer to list1
# In  r5: Pointer to list2
# In  r6: Number of elements in lists
# Out r2: Number of elements copied
NonZeroCopyList:
	subi    sp, sp, 4*5
    stw     r3, 4*0(sp)					# Number of elements copied
    stw     r4, 4*1(sp)					# Pointer to list1
    stw     r5, 4*2(sp)					# Pointer to list2
    stw     r7, 4*3(sp)					# Current index
    stw     r8, 4*4(sp)					# Current value
    
    mov		r3, r0						# Number of elements copied is 0
    mov		r7, r0						# Current index is 0
    
NonZeroCopyListLoop:
	ldb		r8, 0(r4)					# Current value = Get value in LIST1[Current index]
	
    beq		r8, r0, ContinueLoop		# If Current value = 0, don't copy it
    stb		r8, 0(r5)					# Set value in LIST2[Current index] to Current value
    addi	r5, r5, 1					# Add to current address 2
	addi	r3, r3, 1					# Increment Number of elements copied by 1
    
ContinueLoop:
	addi	r7, r7, 1					# Add to current index
    addi	r4, r4, 1					# Add to current address 1
    blt		r7, r6, NonZeroCopyListLoop	# If current index < number of elements, loop again

	mov r2, r3							# Set output  number of elements copied (r2) to internal number of elements copied counter (r3)

    ldw     r3, 4*0(sp)
    ldw     r4, 4*1(sp)
    ldw     r5, 4*2(sp)
    ldw     r7, 4*3(sp)
    ldw     r8, 4*4(sp)
    addi    sp, sp, 4*5
	ret

# ==================== DATA ====================
    
.org	0x00000800
LIST1:	.byte	0,6,0,-3,16,22,0,0,24,11
LIST2:	.skip	10
    
.end
	