########### Andrew Tam ############
########### actam ################
########### 114532406 ################

###################################
##### DO NOT ADD A DATA SECTION ###
###################################

.text
.globl hash
hash:
	li $v0, 0 #hash to return
	move $t0, $a0 #current address
	
	loop_hash:
	lb $t1, 0($t0) #load current char
	beq $t1, $0, exit_loop_hash #exit once we hit the null char
	add $v0, $v0, $t1 #add to ascii value to the hash
	addi $t0, $t0, 1 #increment address
	j loop_hash
	exit_loop_hash:
	jr $ra

.globl isPrime
isPrime:
	li $v0, 0 #false unless set to true.
	li $t0, 2
	ble $a0, $t0, exit_isPrime #all ints <= 2 are not prime
	
	li $t0, 3
	isPrime_loop:
	beq $t0, $a0, exit_isPrime_loop #exit once equal to the input.
	div $a0, $t0 #divide the input by current int
	mfhi $t1 #move remainder to $t1
	beq $t1, $0, exit_isPrime
	addi $t0, $t0, 2 #increment int by 2 (not 1 since evens not prime)
	j isPrime_loop #keep looping
	
	exit_isPrime_loop:
	li $v0, 1 #not divis, so is prime
	
	exit_isPrime:
	jr $ra

.globl lcm
lcm:
	addi $sp, $sp, -4 #allocate a word for ra
	sw $ra, 0($sp) #save ra to stack
	jal gcd #calculate gcd
	lw $ra, 0($sp) #load ra back
	addi $sp, $sp, 4 #unallocate
	
	mult $a0, $a1 #x * y
	mflo $t0
	
	div $t0, $v0 #x * y / gcd
	mflo $v0 #get quotient
	
	jr $ra

.globl gcd
gcd:
	bge $a1, $a0, swap_xy#is y < x, swap
	move $t0, $a0
	move $t1, $a1
	j gcd_loop
	
	swap_xy:
	move $t0, $a1 #swap
	move $t1, $a0
	
	gcd_loop:
	beq $t0, $0, x_0 #if either is 0, the other is the gcd
	beq $t1, $0, y_0 
	
	div $t1, $t0 #y / x
	move $t1, $t0 #move x into y
	mfhi $t0 #move remainder into x
	j gcd_loop #loop
	
	
	x_0:
	move $v0, $t1
	jr $ra
	
	y_0:
	move $v0, $t0
	jr $ra
	
.globl pubkExp
pubkExp:
	addi $sp, $sp, -4 #allocate a word for saving $ra
	sw $ra, 0($sp) #store original return address
	move $a1, $a0 #move z into $a1 for random
	
	while_not_relprime:	
	addi $a1, $a1, -2 #range is now [0, z - 2) 
	li $v0, 42
	syscall #get random int in a0
	addi $a0, $a0, 2 #move range from [0, z - 2) to [2, z) = (1, z)
	
	addi $a1, $a1, 2 #undo add from z
	#random num stored in $a0
	#z stored in $a1
	jal gcd
	li $t3, 1
	bne $v0, $t3, while_not_relprime #if gcd in $v0 != 1, go generate another
	#otherwise good.
	
	
	move $v0, $a0 #move random num in $a0 to return it
	lw $ra, 0($sp) #get the original return address
	addi $sp, $sp, 4 #unallocate stack 
  	jr $ra

.globl prikExp
prikExp:
	move $t9, $a1 #store default y
	addi $sp, $sp, -4 #allocate a word to store $ra
	sw $ra, 0($sp) #store ra in stack
	jal gcd #check if x and y are coprime
	li $t1, 1
	beq $v0, $t1, valid_prikExp #check gcd == 1
	li $v0, -1 #if the gcd is not 1, then return -1
	j done_prikExp

	valid_prikExp:
	li $t0, 0 #p0
	li $t1, 1 #p1
	
	li $t2, 0 #counter
	
	li $t5, 0 #q - 2
	li $t6, 0 #q - 1
	
	prik_loop:
	div $a1, $a0 #y / x
	mflo $t3 #quotient
	mfhi $t4 #remainder
	
	move $a1, $a0 #the x becomes y
	move $a0, $t4 #the remainder becomes new x	
	
	
	move $t5, $t6 #move q - 1 to q - 2
	move $t6, $t3 #move q to q - 1
	
	
	beq $t4, $0, done_prik_loop #if the remainder is 0, done looping
		
	li $t8, 1
	blt $t2, $t8 skip_p #skip calculating p for first 2 iterations.

	#calculate p
	mult $t1, $t5 #p-1 * q-2
	mflo $t7 #new p
 	sub $t7, $t0, $t7 #p-2 - product above
	move $t0, $t1 #p-1 becomes p-2
	move $t1, $t7 #new p becomes p-1
	
	add $t1, $t1, $t9 #need to make negative pos before modding
	div $t1, $t9 #p mod y
	
	mfhi $t1
	
	bge $t1, $0, pos_mod #if positive mod, don't need to add
	add $t1, $t1, $t9
	pos_mod:
	skip_p:
	addi $t2, $t2, 1 #increment counter
	
	j prik_loop
	
	done_prik_loop:
	mult $t1, $t5 #p-1 * q-2
	mflo $t7
	sub $v0, $t0, $t7 #p-2 - product above, store in v0 for returning
	add $v0, $v0, $t9 #make negative pos before modding
	div $v0, $t9
	mfhi $v0 #p mod y
	
	bge $v0, $0, done_prikExp #make pos if necessary
	add $v0, $v0, $t9
	done_prikExp:
	lw $ra, 0($sp) #get original ra
	addi $sp, $sp, 4 #unallocate stack	
 	jr $ra

.globl encrypt
encrypt:
	addi $sp, $sp, -16 #store original $ra
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	li $t1, 1
	sub $a0, $a1, $t1 #p - 1
	sub $a1, $a2, $t1 #q - 1
	
	jal lcm #calculate K = lcm(p-1, q-1)
	move $a0, $v0 #move lcm to z
	
	jal pubkExp #calculate exponent 
	
	move $v1, $v0 #move e for return
	move $t0, $v0 #move exponent to t0
	
	mult $s1, $s2 #p * q
	mflo $t1  #n
	
	#s0 is b
	li $t2, 1 #c = 1
	li $t3, 0 #e' = 0
	
	mem_eff_loop:
	bge $t3, $t0, done_eff_loop #if e' >= e, done loop
	
	addi $t3, $t3, 1 #e' += 1
	mult $s0, $t2 #b * c
	mflo $t2 #c = bc
	div $t2, $t1 #mod n
	mfhi $t2 #move remainder, thus c = bc mod n
	j mem_eff_loop
	
	done_eff_loop:
	move $v0, $t2 #return
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16 #unallocate stack
	
	jr $ra

.globl decrypt
decrypt:
	addi $sp, $sp, -20 #store original $ra and args
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	move $s0, $a0 #store args in s registers
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	li $t1, 1
	sub $a0, $a2, $t1 #p - 1
	sub $a1, $a3, $t1 #q - 1
	
	jal lcm #lcm(p-1, q-1)
	
	move $a1, $v0 #move lcm K
	move $a0, $s1 #move public key c
	
	jal prikExp #calculate exponent 

	move $t0, $v0 #move exponent to t0
	
	mult $s2, $s3 #p * q
	mflo $t1  #n
	
	#s0 is b
	li $t2, 1 #c = 1
	li $t3, 0 #e' = 0
	
	mem_eff_dec_loop:
	bge $t3, $t0, done_eff_dec_loop #if e' >= e, done loop
	
	addi $t3, $t3, 1 #e' += 1
	mult $s0, $t2 #b * c
	mflo $t2 #c = bc
	div $t2, $t1 #mod n
	mfhi $t2 #move remainder, thus c = bc mod n
	j mem_eff_dec_loop
	done_eff_dec_loop:
	move $v0, $t2
	
	#restore preserved registers
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20 #unallocate stack 
		
	jr $ra
  
exit:
	li $v0, 10
	syscall
