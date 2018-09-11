.global _start

.equ	LAST_RAM_WORD,	0x007FFFFC

_start:

	movia	sp, LAST_RAM_WORD	# Set stack pointer address
	
	movia	r4, LIST			# Move address of LIST in r4
    movia	r5, 7				# Set 7 as value to scan for
    movia 	r6, 10				# Set 10 as Number of elements
    
    call 	ListValueCount		# Call the ListValueCount subroutine
    							# Now, r2 should contain 3 (occurances of 7)
    
_end:
	br _end
	
# ==================== LIST VALUE COUNT FUNCTION ====================
    
# In  r4: Pointer to list
# In  r5: Value to scan for
# In  r6: Number of elements in lists
# Out r2: Number of elements copied
ListValueCount:
	subi    sp, sp, 4*4
    stw     r3, 4*0(sp)					# Number of occurances
    stw     r4, 4*1(sp)					# Pointer to list1
    stw     r7, 4*2(sp)					# Current index
    stw     r8, 4*4(sp)					# Current value
    
    mov		r3, r0						# Number of occurances is 0
    mov		r7, r0						# Current index is 0
    
ListValueCountLoop:
	ldb		r8, 0(r4)					# Current value = Get value in LIST[Current index]
	
    bne		r8, r5, ContinueLoop		# If Current value != value to scan for, don't count it
    addi	r3, r3, 1					# Increment Number of occurances by 1
    
ContinueLoop:
	addi	r7, r7, 1					# Add to current index
    addi	r4, r4, 1					# Add to current address 1
    blt		r7, r6, ListValueCountLoop	# If current index < number of elements, loop again

	mov r2, r3							# Set output Number of occurances (r2) to internal Number of occurances counter (r3)

    ldw     r3, 4*0(sp)
    ldw     r4, 4*1(sp)
    ldw     r7, 4*2(sp)
    ldw     r8, 4*3(sp)
    addi    sp, sp, 4*4
	ret

# ==================== DATA ====================
    
.org	0x00000800
LIST:	.byte	7,6,7,-3,16,22,0,7,24,11
    
.end
	