.global _start
_start:
	
    movia r2, 4				# Set 4 as Num 1
    movia r3, 7				# Set 7 as Num 2
    
    call Max				# Call the Max subroutine
    						# Now, r4 should contain 7
    
    movia r2, 17			# Set 17 as Num 1
    movia r3, 2				# Set 2 as Num 2
    
    call Max				# Call the Max subroutine
    						# Now, r4 should contain 17
    
    movia r2, -1			# Set -1 as Num 1
    movia r3, 99			# Set 99 as Num 2
    
    call Max				# Call the Max subroutine
    						# Now, r4 should contain 99
    
    movia r2, 50			# Set 50 as Num 1
    movia r3, 50			# Set 50 as Num 2
    
    call Max				# Call the Max subroutine
    						# Now, r4 should contain 50
    
_end:
	br _end
	
# ==================== MAX FUNCTION ====================
    
# In  r2: Num 1
# In  r3: Num 2
# Out r4: Maximum number
Max:
	bgt r2, r3, Num1_Larger	# If Num 1 > Num 2, go to Num1_Larger
    br Num2_Larger			# Otherwise, Num 1 <= Num 2, go to Num2_Larger
Num1_Larger:
	mov r4, r2
    ret
Num2_Larger:
	mov r4, r3
    ret

.end
	