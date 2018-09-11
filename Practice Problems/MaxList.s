.global _start

.equ	LAST_RAM_WORD,	0x007FFFFC

_start:

	movia	sp, LAST_RAM_WORD	# Set stack pointer address
	
	movia	r5, LIST			# Move address of List in r5
    movia 	r6, 10				# Set 10 as Number of elements
    
    call 	MaxList				# Call the MaxList subroutine
    							# Now, r4 should contain 24
    
_end:
	br _end
	
# ==================== FIND MAX FUNCTION ====================
    
# In  r5: Pointer to list
# In  r6: Number of elements in list
# Out r4: Maximum number
MaxList:
	subi    sp, sp, 4*6
    stw     r2, 4*0(sp)			# Temporary Num 1
    stw     r3, 4*1(sp)			# Temporary Num 2
    stw     r5, 4*2(sp)			# Pointer to list
    stw     r7, 4*3(sp)			# Current index
    stw     r8, 4*4(sp)			# Current max
	stw 	ra, 4*5(sp)
    
    mov		r7, r0				# Current index is 0
    movi	r8, 0				# Smallest byte value
    
MaxListLoop:
	ldb		r2, 0(r5)			# Num 1 = Get value in List[Current index]
	mov		r3, r8				# Num2 = Current max
    
	call Max					# Determine max
	
    bgt		r4, r8, SetNewMax	# If current number in list > current max
    							# Current max = current number
	
    br MaxListCheckToLoop		# Check to loop again
    
SetNewMax:
	mov		r8, r4
    
MaxListCheckToLoop:
	addi	r7, r7, 1			# Add to current index
    addi	r5, r5, 1			# Add to current address
	blt		r7, r6, MaxListLoop	# If current index < number of elements, loop again
    
MaxListDone:
	
    mov		r4, r8				# Set return value (r4) to max element

    ldw     r2, 4*0(sp)
    ldw     r3, 4*1(sp)
    ldw     r5, 4*2(sp)
    ldw     r7, 4*3(sp)
    ldw     r8, 4*4(sp)
    ldw     ra, 4*5(sp)
    addi    sp, sp, 4*6
	ret
    
# ==================== MAX FUNCTION ====================
    
# In  r2: Num 1
# In  r3: Num 2
# Out r4: Maximum number
Max:
	bgt 	r2, r3, Num1_Larger	# If Num 1 > Num 2, go to Num1_Larger
    br 		Num2_Larger			# Otherwise, Num 1 <= Num 2, go to Num2_Larger
Num1_Larger:
	mov 	r4, r2
    ret
Num2_Larger:
	mov 	r4, r3
    ret
    
# ==================== DATA ====================
    
.org	0x00000800
LIST:	.byte	4,6,8,-3,16,22,0,7,24,11
    
.end
	