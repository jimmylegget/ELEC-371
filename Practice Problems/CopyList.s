.global _start

.equ	LAST_RAM_WORD,	0x007FFFFC

_start:

	movia	sp, LAST_RAM_WORD	# Set stack pointer address
	
	movia	r4, LIST1			# Move address of LIST1 in r4
    movia	r5, LIST2			# Move address of LIST2 in r5
    movia 	r6, 10				# Set 10 as Number of elements
    
    call 	CopyList			# Call the CopyList subroutine
    							# Now, LIST2 is copy of LIST1
    
_end:
	br _end
	
# ==================== COPY LIST FUNCTION ====================
    
# In  r4: Pointer to list1
# In  r5: Pointer to list2
# In  r6: Number of elements in lists
CopyList:
	subi    sp, sp, 4*4
    stw     r4, 4*0(sp)				# Pointer to list1
    stw     r5, 4*1(sp)				# Pointer to list2
    stw     r7, 4*2(sp)				# Current index
    stw     r8, 4*3(sp)				# Current value
    
    mov		r7, r0					# Current index is 0
    
CopyListLoop:
	ldb		r8, 0(r4)				# Current value = Get value in LIST1[Current index]
	stb		r8, 0(r5)				# Set value in LIST2[Current index] to Current value
    
	addi	r7, r7, 1				# Add to current index
    addi	r4, r4, 1				# Add to current address 1
    addi	r5, r5, 1				# Add to current address 2
	blt		r7, r6, CopyListLoop	# If current index < number of elements, loop again

    ldw     r4, 4*0(sp)
    ldw     r5, 4*1(sp)
    ldw     r7, 4*2(sp)
    ldw     r8, 4*3(sp)
    addi    sp, sp, 4*4
	ret

# ==================== DATA ====================
    
.org	0x00000800
LIST1:	.byte	4,6,8,-3,16,22,0,7,24,11
LIST2:	.skip	10
    
.end
	