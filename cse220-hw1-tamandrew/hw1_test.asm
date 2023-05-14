################# Change args and n to test hw1.asm with different inputs #################
.data
args: .asciiz "L" "M3P4M6M5M4P2P2"
n: .word 2

.text
main:
 lw $a0, n
 la $a1, args
 j hw_main

.include "hw1.asm"
