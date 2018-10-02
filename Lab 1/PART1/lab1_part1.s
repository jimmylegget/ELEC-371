.global _start

.equ	LAST_RAM_WORD,	0x007FFFFC
.equ	NUM_ELEMENTS,	6
.equ	MIN_VALUE,		0
.equ	MAX_VALUE,		9

_start:

	movia	sp, LAST_RAM_WORD	# Set stack pointer address
	
	movia	r2, LIST1			# Move address of LIST1 in r4
    movia	r3, LIST2			# Move address of LIST2 in r5
	movia	r4, MIN_VALUE		# Set 0 as the minimum value
	movia	r5, MAX_VALUE		# Set 9 as the maximum value
    movia 	r6, NUM_ELEMENTS	# Set 6 as number of elements
    
    call 	ListClip			# Call the ListClip subroutine
								# Now, LIST2 is copy of the clipped elements in LIST1
								# And r2 contains the number of elements that were clipped
    
_end:
	br _end
	
# ==================== LIST CLIP FUNCTION ====================
    
# In  r2: Pointer to list1
# In  r3: Pointer to list2
# In  r4: Min value
# In  r5: Max value
# In  r6: Number of elements in lists
# Out r2: Number of elements clipped
ListClip:
	subi    sp, sp, 4*7
    stw     r3, 4*0(sp)				# Number of elements copied
    stw     r4, 4*1(sp)				# Pointer to list1
    stw     r5, 4*2(sp)				# Pointer to list2
	stw     r6, 4*3(sp)				# Loop Count
    stw     r7, 4*4(sp)				# Clip Count
    stw     r8, 4*5(sp)				# Current value
	stw     r9, 4*6(sp)				# Current Original Value
    
    mov		r7, r0					# set clip_count to 0
	
STARTFOR:	
    beq		r6, r0, ENDFOR			# Check to exit for loop
	ldw		r8, 0(r2)				# val = list_ptr[i]
	ldw		r9, 0(r2)				# valOrig = list_ptr[i]
	bge 	r8, r4, NOTLESSTHAN		# If val >= min, don't do if statement
	mov		r8, r4					# Set val = min
	br		ENDIF					
	
NOTLESSTHAN:
	ble		r8, r5,NOTGREATERTHAN	# If val <= max, don't do if statement
	mov		r8, r5					# Set val = max
	br		ENDIF
	
NOTGREATERTHAN:
ENDIF:

	beq 	r8, r9, ENDIF2			# If val == valOrig, don't do if statement
	addi 	r7, r7,1				# Increment number of elements clipped
	
ENDIF2:
	stw		r8,0(r3)				# Set list2[i] = val
    addi	r2, r2,4				# Increment pointer to list1
	addi	r3, r3,4				# Increment pointer to list2
	subi	r6, r6,1				# Decrement loop counter
	br 		STARTFOR
	
ENDFOR:

	mov 	r2, r7					# Set r2 return value to clip_count in r7

	ldw     r3, 4*0(sp)				# Number of elements copied
    ldw     r4, 4*1(sp)				# Pointer to list1
    ldw     r5, 4*2(sp)				# Pointer to list2
	ldw     r6, 4*3(sp)				# Loop Count
    ldw     r7, 4*4(sp)				# Clip Count
    ldw     r8, 4*5(sp)				# Current value
	ldw     r9, 4*6(sp)				# Current Original Value
	
    addi    sp, sp, 4*7
	ret

# ==================== DATA ====================
    
.org	0x00001000
N_CLIP:	.word
LIST1:	.word	-7, 2, 8, -3, 10, 5
LIST2:	.skip	6*4

.end