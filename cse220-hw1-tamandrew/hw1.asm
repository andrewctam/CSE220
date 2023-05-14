################# Andrew Tam #################
################# actam #################
################# 114532406 #################
################# DON'T FORGET TO ADD GITHUB USERNAME IN BRIGHTSPACE #################

################# DO NOT CHANGE THE DATA SECTION #################

.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "Invalid Arguments\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
invalid_hand_msg: .asciiz "Loot Hand Invalid\n"
newline: .asciiz "\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""

.text
.globl hw_main
hw_main:
    sw $a0, num_args
    sw $a1, arg1_addr
    addi $t0, $a1, 2
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	li $t0, 2 #should be 2 args
	lw $t1, num_args #load num_args
	bne $t0, $t1, num_arg_error #check if num_args == 2
	
	
	#loop through arg_1 and make sure it is length 2
	lw $t0, arg1_addr #starting address
	li $t2, 0 #counter
	li $t3, 2 #correct length
	
loop_for_arg1_len:
	lbu $t1, 0($t0) #load char from address	
	addi $t0, $t0, 1 #get next char address
	addi $t2, $t2, 1 #incrememnt counter
	bne $t1, $0, loop_for_arg1_len #if not null, keep looping.
	
	bne $t2, $t3, arg_error #if len != 2, error
	
	#check "D", "O", "S", "T", "E", "H", "U", "F", or "L"
	lw $t0, arg1_addr #load arg1
	lbu $t1, 0($t0) #store char
	
	li $t2, 68 #D
	beq $t2, $t1, valid_char_D

	li $t2, 79 #O
	beq $t2, $t1, valid_char_O

	li $t2, 83 #S
	beq $t2, $t1, valid_char_S

	li $t2, 84 #T
	beq $t2, $t1, valid_char_T

	li $t2, 69 #E
	beq $t2, $t1, valid_char_E

	li $t2, 72 #H
	beq $t2, $t1, valid_char_H

	li $t2, 85 #U
	beq $t2, $t1, valid_char_U

	li $t2, 70 #F
	beq $t2, $t1, valid_char_F

	li $t2, 76 #L
	beq $t2, $t1, valid_char_L

	#Invalid argument
	j arg_error
	
valid_char_D:
	lw $t0, arg2_addr #load address
	lbu $t1, 0($t0) #holds current char
	
	beq $t1, $0, arg_error #check if len 0 i.e. first is null terminated 
	li $t2, 0 #counter
	li $t3, 32 #max len
	li $t4, 0 #resulting num
	li $t5, 48 #"0"
	li $t6, 49 #"1"
	
loop_binary:
	lbu $t1, 0($t0) #load current char
	beq $t1, $0, exit_loop_binary #exit if end (null)

	bge $t2, $t3, arg_error #if i >= 32 error. should only be [0. 31]
	
	addi $t0, $t0, 1 #increment address
	addi $t2, $t2, 1 #increment counter
	
	beq $t1, $t5, is_0 # "0"
	beq $t1, $t6, is_1 # "1"
	j arg_error #not 0 or 1, error
	
 is_0:
 	sll $t4, $t4, 1 #if 0, just shift left by 1.
 	j loop_binary
 is_1:
  	sll $t4, $t4, 1 #shift left by 1.
 	ori $t4, $t4, 0x0001 #add a 1 at the end

 	j loop_binary
 	
exit_loop_binary:
	li $v0, 1 #print the decimal val of twos complement
	add $a0, $0, $t4
	syscall
	
	j end

valid_char_O:
	li $t8, 26 #start pos
	li $t9, 6 #len of opcode
	j process_hex
valid_char_S:
	li $t8, 21 #start pos
	li $t9, 5 #len of rs
	j process_hex
valid_char_T:
	li $t8, 16 #start pos
	li $t9, 5 #len of rt
	j process_hex
valid_char_E:
	li $t8, 11 #start pos
	li $t9, 5 #len of rd
	j process_hex
valid_char_H:
	li $t8, 6 #start pos
	li $t9, 5 #len of shamt
	j process_hex
valid_char_U:
	li $t8, 0 #start pos
	li $t9, 6 #len of funct
	j process_hex


process_hex:
	#check for 0x
	lw $t0, arg2_addr #load address of arg2
	lbu $t1, 0($t0) #load first byte
	li $t2, 48 #"0"
	bne $t2, $t1, arg_error #first must be 0
	
	lbu $t1, 1($t0) #load second byte
	li $t2, 120 #"x"
	bne $t2, $t1, arg_error #second must be "x"
	
	
	#parse hex to binary
	addi $t0, $t0, 2 #address of start of hex string, base + 2
	lbu $t1, 0($t0)
	beq $t1, $0, arg_error #length == 0 since null char at 2
	
	li $t2, 0 #parsed hex to binary
	li $t3, 0 #counter
	
	li $t4, 8 #max len of hex
	
	
parse_hex_loop:
	lbu $t1, 0($t0) #current char
	beq $t1, $0, exit_parse_hex_loop #exit if null
	bge $t3, $t4, arg_error #if counter >= max len, argument error

	addi $t3, $t3, 1 #increment counter
	addi $t0, $t0, 1 #increment address next byte
		
	#test AF
	li $t5, 65 #"A" lower bound
	li $t6, 70 #"F" upper bound
	li $t7, 10 #decimal value of A
	blt $t1, $t5, test_09 #less than 65 so test lower than lower bound
	bgt $t1, $t6, test_af #greater than 70 so test higher than upper bound
	j valid_hex_char
	
	test_09:
	li $t5, 48 #"0"
	li $t6, 57 #"9"
	li $t7, 0 #decimal value of 0
	blt $t1, $t5, arg_error
	bgt $t1, $t6, arg_error
	j valid_hex_char
	
	test_af:
	li $t5, 97 #"a"
	li $t6, 102 #"f"
	li $t7, 10 #decimal value of a
	blt $t1, $t5, arg_error
	bgt $t1, $t6, arg_error 
	j valid_hex_char 
	
	valid_hex_char:
	sll $t2, $t2, 4 #shift 4 bits to left
	add $t1, $t1, $t7 #add 0 or 10
	sub $t1, $t1, $t5 #subtract char by lower bound to get offset
	
	or $t2, $t2, $t1 #combile lsb

	j parse_hex_loop

exit_parse_hex_loop:
	li $t5, 5
	beq $t9, $t5, mask_five #if field is 5 bits long
	#else, mask is 6 bits long.
	li $t5, 0x0000003f #000...0 0011 1111
	j mask_shift
	
	mask_five:
	li $t5, 0x0000001f #000...0 0001 1111
	
	mask_shift:
	sllv $t5, $t5, $t8 #shift mask to start pos of field
	
	and $t2, $t2, $t5 #bitwise and using mask
	
	li $t0, 6 #start for shamt
	beq $t8, $t0, sign_extend
	srlv $a0, $t2, $t8 #undo shift, no sign extend, move bits to lsbs. Store it in a0 for printing
	j print_r
	
	sign_extend:
	sll $t2, $t2, 21 #shift to left to get sign in msb
	sra $a0, $t2, 27 #sign extend for shamt
	
	print_r:
	li $v0, 1
	syscall
	
	j end
		
	
valid_char_F:
	lw $t0, arg2_addr
	
	lbu $t1, 0($t0) #first byte
	beq $t1, $0, arg_error #length == 0 since null char at 2
	
	li $t2, 0 #parsed hex to binary
	li $t3, 0 #counter
	
	li $t4, 8 #max len of hex
parse_hexfloat_loop:
	lbu $t1, 0($t0) #current char
	beq $t1, $0, exit_parse_hexfloat_loop #exit if null
	bge $t3, $t4, arg_error #if counter >= max len, argument error

	addi $t3, $t3, 1 #increment counter
	addi $t0, $t0, 1 #increment address next byte
		
	#test AF
	li $t5, 65 #"A" lower bound
	li $t6, 70 #"F" upper bound
	li $t7, 10 #decimal value of A
	blt $t1, $t5, test_hexfloat_09 #less than 65 so test lower than lower bound
	bgt $t1, $t6, test_hexfloat_af #greater than 70 so test higher than upper bound
	j valid_hexfloat_char
	
	test_hexfloat_09:
	li $t5, 48 #"0"
	li $t6, 57 #"9"
	li $t7, 0 #decimal value of 0
	blt $t1, $t5, arg_error
	bgt $t1, $t6, arg_error
	j valid_hexfloat_char
	
	test_hexfloat_af:
	li $t5, 97 #"a"
	li $t6, 102 #"f"
	li $t7, 10 #decimal value of a
	blt $t1, $t5, arg_error
	bgt $t1, $t6, arg_error 
	j valid_hexfloat_char
	
	valid_hexfloat_char:
	sll $t2, $t2, 4 #shift 4 bits to left
	add $t1, $t1, $t7 #add 0 or 10
	sub $t1, $t1, $t5 #subtract char by lower bound to get offset
	
	or $t2, $t2, $t1 #combile lsb

	j parse_hexfloat_loop
exit_parse_hexfloat_loop:

	bne $t3, $t4, arg_error #if its not 8 bytes long, error 
	#check special cases
	li $t8, 0x00000000
	beq $t8, $t2, zero_error
	li $t8, 0x80000000 
	beq $t8, $t2, zero_error
	li $t8, 0xFF800000
	beq $t8, $t2, inf_neg_error
	li $t8, 0x7F800000
	beq $t8, $t2, inf_pos_error
	
	
	#check if ff800001 -> ffffffff
	#   some negative number  -> -1
	li $t8, 0xff800001
	ble $t2, $t8, check_nan_range_2 #if less than the negative number, not in range so check 2nd range
	li $t8, 0xffffffff
	bgt $t2, $t8, check_nan_range_2 #if greater than -1, not in range, check 2nd range.
	
	j nan_error# in range
	
	check_nan_range_2:
	#check if 7f800001 -> 7FFFFFFF
	#          - num   -> smaller - num
	
	li $t8, 0x7f800001
	ble $t2, $t8 valid_hexfloat #if less than the lower bound, valid
	
	li $t8, 0x7FFFFFFF #if greater than the upper bound, valid
	bge $t2, $t8, valid_hexfloat
	
	j nan_error #in range
	
valid_hexfloat:
	li $t3, 0x7F800000 #0111 1111 1000...000 exponent mask
	and $a0, $t2, $t3 #extract the exponent from $t2, store in $a0
	srl $a0, $a0, 23 #shift the exponent to lsbs
	li $t3, 127
	sub $a0, $a0, $t3 #subtract bias
	
	li $t3, 0x003FFFFFF #0000 0000 0011 11111..111 mantissa mask
	and $t0, $t2, $t3 #extract the mantissa from $t2, store in $t0.
	sll $t0, $t0, 9 #move bits to msbs
	
	li $t4, 0x80000000 #10...00 sign mask for extracting msb
	and $t9, $t2, $t4 #extract the sign from $t2, store in $t9.
	
	la $a1, mantissa #load mantissa base address  
	
	beq $t9, $0, pos #sign is 0
	#else, sign is 1, negative so store -

	li $t1, 45 #"-"
	sb $t1, 0($a1) #store -
	addi $a1, $a1, 1
	
	pos: #skip adding sign
	li $t1, 49 #"1"
	sb $t1, 0($a1) #store 1
	addi $a1, $a1, 1
	
	li $t1, 46 #"."
	sb $t1, 0($a1) #store .
	addi $a1, $a1, 1
	
	li $t2, 0 #counter
	li $t3, 23 #limit 23 bytes

	
loop_parse_string:
	beq $t2, $t3, exit_loop_binary_to_string
	addi $t2, $t2, 1 #increment counter by 1
	
	and $t5, $t0, $t4 #extract msb into $t5
	sll $t0, $t0, 1 #shift mantissa by 1 to left
	
	beq $t5, $t4, msb_is_1 #compare to 100000....0
	#else, lsb is 0
	li $t6, 48 #"0"
	sb $t6, 0($a1)
	addi $a1, $a1, 1 #increment address by 1
	j loop_parse_string 
	
	msb_is_1:
	li $t6, 49 #"1"
	sb $t6, 0($a1)
	addi $a1, $a1, 1 #increment address by 1
	j loop_parse_string 
	
	
exit_loop_binary_to_string:
	sb $0, 0($a1) #store null
	la $a1, mantissa
	j end
	
valid_char_L:
	lw $t0, arg2_addr #load arg2
	
	li $t2, 0 #number of merchant ships
	li $t3, 0 #number of pirate ships
	
	li $t4, 0 #counter
	li $t5, 12 #length of the hand string
	
	verify_hand_loop:
	beq $t4, $t5, exit_hand_loop #exit loop once counter is 12
	
	lbu $t1, 0($t0) #load char
	addi $t0, $t0, 1 #increment address
	addi $t4, $t4, 1 #increment counter
	
	li $t6, 77 #"M"
	beq $t1, $t6, is_merchant #if the char is M
	
	li $t6, 80
	beq $t1, $t6, is_pirate #if the char is P
	
	j invalid_hand_error #not M or P
	
	is_merchant:
	lbu $t7, 0($t0) #load char, should be num between 3 and 8
	addi $t0, $t0, 1 #increment addrress
	addi $t4, $t4, 1 #increment counter
	li $t6, 51 #"3"
	blt $t7, $t6, invalid_hand_error #less than 3, invalid
	li $t6, 56 #"8"
	bgt $t7, $t6, invalid_hand_error #greater than 8, invalid
	
	addi $t2, $t2, 1 #increment merchant ships
	j verify_hand_loop
	
	is_pirate:
	lbu $t7, 0($t0) #load char
	addi $t0, $t0, 1 #increment address
	addi $t4, $t4, 1 #increment counter
	
	li $t6, 49 #"1"
	blt $t7, $t6, invalid_hand_error #if less than 1, invalid
	li $t6, 52 #"4"
	bgt $t7, $t6, invalid_hand_error #if greater than 4, invalid
	
	addi $t3, $t3, 1 #increment pirate ships	
	j verify_hand_loop
	
	exit_hand_loop:
	lbu $t7, 0($t0) #load next char, should be a null char
	bne $t7, $0, invalid_hand_error #if there are more than 6 cards, error
	
	sll $t2, $t2, 3 #move merchant count to left 3 bits.
	or $t2, $t2, $t3 #combine the two counts
	
	
	li $t1, 0x20 
	and $t0, $t2, $t1 #00...0100000 to mask sign
	
	beq $t0, $0, print_hand #if 0, then no sign extend necessary
	#else, sign extend since 1
	li $t0, 0xffffffc0
	or $t2, $t2, $t0 #or with 111...1100 0000 to sign extend
	
	print_hand:
	add $a0, $t2, $0
	li $v0, 1
	syscall
	
	j end
	
	
	
num_arg_error:
	li $v0, 4 #print string
	la $a0, args_err_msg # store error message
	syscall #print the error message
	j end
arg_error:
	li $v0, 4 #print string
	la $a0, invalid_arg_msg # store error message
	syscall #print the error message
	j end

zero_error:
	li $v0, 4
	la $a0, zero
	syscall
	j end
inf_neg_error:
	li $v0, 4
	la $a0, inf_neg
	syscall
	j end
inf_pos_error:
	li $v0, 4
	la $a0, inf_pos
	syscall
	j end
nan_error:
	li $v0, 4
	la $a0, nan
	syscall
	j end
invalid_hand_error:
	li $v0, 4
	la $a0, invalid_hand_msg
	syscall
	j end
	
end:
	li $v0, 10 
	syscall
