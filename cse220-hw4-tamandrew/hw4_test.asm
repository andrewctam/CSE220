############################ CHANGE THIS FILE AS YOU DEEM FIT ############################
############################ Add more names if needed ####################################

.data

Name1: .asciiz "Jane"
Name2: .asciiz "Joey"
Name3: .asciiz "Alit"
Name4: .asciiz "Veen"
Name5: .asciiz "Stan"
I: .word 5
J: .word 10

.text
main:
    lw $a0, I
    lw $a1, J
    jal create_network
    add $s0, $v0, $0		# network address in heap

    add $a0, $0, $s0		# pass network address to add_person
    la $a1, Name1
    jal add_person
    
    #write test code


exit:
    li $v0, 10
    syscall
.include "hw4.asm"
