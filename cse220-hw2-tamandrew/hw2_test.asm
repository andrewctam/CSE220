.data
str: .asciiz "Seawolves let's go!"

.text
main:
 la $a0,str
 jal hash

 add $a0,$v0,$0
 li $a1,107
 li $a2,157
 jal encrypt
 add $a0,$v0,$0
 add $a1,$v1,$0
 li $a2,107
 li $a3,157
 jal decrypt
 add $a0,$v0,$0
 li $v0,1
 syscall
 li $v0, 10
 syscall

.include "hw2.asm"
