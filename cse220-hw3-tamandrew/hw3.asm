######### Andrew Tam ##########
######### 114532406 ##########
######### actam ##########

######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########
######## DO NOT ADD A DATA SECTION ##########

.text
.globl initialize
initialize:
    addi $sp, $sp, -4
    move $t0, $a1 #save buffer address to t0
    li $a1, 0 #0 for reading
    li $a2, 0
    li $v0, 13
    syscall

    blt $v0, $0, fileioerror

    move $a0, $v0 #move file descriptor
    
    li $t1, -1 #i
    li $t2, -1 #j
    li $t3, 0 #boolean for if we saw \r or a space already, 1 for r 2 for space
    li $t4, 0 #running total value of parsed int
    li $t5, '0' #holds comparrisons
    li $t7, 0 #rows
    li $t8, 0 #cols
    move $t9, $t0

    
    
    parsing_loop:
        sw $0, 0($sp) #get rid of garbade in $sp

        li $v0, 14 #read file
        move $a1, $sp #use stack as input buffer
        li $a2, 1 #read one character
        syscall #get next character

        blt $v0, $0, fileioerror
        beq $v0, $0, done_parse

        lw $t6, 0($sp) #get char that was read
       

        li $t5, 10 #\n
        beq $t6, $t5, foundNewLine #equal to new line

        li $t5, 1
        beq $t3, $t5, fileioerror #if we found a r (t3 = 1), and this is not a new line immedietly after, fileioerror

        li $t5, 32 #space
        beq $t6, $t5, foundSpace

        li $t5, 13 #\r
        beq $t6, $t5, foundR #found \r

        li $t3, 0 #else not an r or a space = false

        li $t5, '0'
        blt $t6, $t5, fileioerror #if < '0', fileio error
        li $t5, '9'
        bgt $t6, $t5, fileioerror #if > '9', fileio error

        li $t5, 10
        mult $t4, $t5 #multiply current running total by 10
        mflo $t4

        li $t5, '0'
        sub $t6, $t6, $t5 #get difference from '0'
        add $t4, $t4, $t6 #add current char int value to running total

        j parsing_loop
            
        foundR:
            li $t3, 1 #found r (1) = true
            j parsing_loop

        foundSpace:
            li $t5, 2
            beq $t3, $t5, fileioerror #(if we already have seen a space (t3 = 2), then space space is an error)
            li $t3, 2 #found space (2) = true

            store_in_buffer:
                sw $t4, 0($t0) #store in buffer
                li $t4, 0 #reset running total
                addi $t0, $t0, 4 #increment buffer counter to next
                j parsing_loop
         
        foundNewLine:
            li $t5, 2
            beq $t3, $t5, fileioerror #(if we already have seen a space (t3 = 2), then space \n is an error)

            li $t5, -1
            beq $t1, $t5, init_rowcount #if i == -1, intialize row count
            beq $t2, $t5, init_colcount #if j == -1, intialize col count

            sw $t4, 0($t0) #store in buffer
            li $t4, 0 #reset running total
            addi $t0, $t0, 4 #increment buffer counter to next
            
            bgt $t2, $t8, fileioerror #if j > num cols, error

            addi $t1, $t1, 1 #i++
            bgt $t1, $t7, fileioerror #if i > num rows, error

            li $t2, 0 #cols = 0
            j parsing_loop
            
            init_rowcount:
                li $t5, 10 
                bgt $t4, $t5, fileioerror
                li $t5, 1
                blt $t4, $t5, fileioerror

                move $t7, $t4 #store row count
                li $t1, 0 #i = 0
                j store_in_buffer


            init_colcount:
                li $t5, 10 
                bgt $t4, $t5, fileioerror
                li $t5, 1
                blt $t4, $t5, fileioerror

                move $t8, $t4 #store col count
                li $t2, 0 #j = 0
                j store_in_buffer



    done_parse:
        li $v0, 1
        sub $t0, $t0, $t9 #get num of nums we parsed
        sra $t0, $t0, 2 #divide by 4
        addi $t0, $t0, -2 #subtract off 2 for first 2 lines

        mult $t7, $t8
        mflo $t1 #expected

        bne $t1, $t0, fileioerror
        j exit_init

    fileioerror:
        li $v0, -1 #error

        li $t1, 102 #number of bytes to reset
        li $t2, 0 #counter
        undo_loop: #undo any side effects by filling buffer with 0s
            beq $t2, $t1, exit_init
            sw $0, 0($t9) #save a 0
            addi $t9, $t9, 4 #increment buffer address
            addi $t2, $t2, 1 #increment counter
            j undo_loop


    exit_init:
        move $t0, $v0
        li $v0, 16
        syscall
        move $v0, $t0

        addi $sp, $sp, 4
        jr $ra

.globl write_file
write_file:
    move $t0, $a1 #store buffer address
    #a0 already file name
    li $a1, 1 #1 for write  
    li $a2, 0
    li $v0, 13
    syscall

    blt $v0, $0, filewriteerror
    move $a0, $v0 #store file desc. in a0

    li $t1, 0 #counter for chars changed
    li $t2, -1 #i
    li $t3, -1 #j
    li $t4, -1 #rows - 1
    li $t5, -1 #cols - 1


    file_write_loop:
        lw $t6, 0($t0) #get current num
        addi $t0, $t0, 4 #move buffer address forward
        
        num_to_string_loop:
            li $t7, -1

            bne $t2, $t7, rows_alr_defined #i = -1
            move $t4, $t6 #init rows
            addi $t4, $t4, -1 #rows - 1
            j cols_alr_defined

            rows_alr_defined:
            li $t7, -1
            bne $t3, $t7, cols_alr_defined #j = -1
            move $t5, $t6 #init cols
            addi $t5, $t5, -1 #cols - 1
            
            cols_alr_defined:

            move $t9, $sp

            bne $t6, $0, reverse_number
            li $a2, 1 #write 1 character
            li $v0, 15 
            addi $sp, $sp, -4
            li $t7, '0'
            sw $t7, 0($sp)
            move $a1, $sp #use stack as input buffer
            syscall

            blt $v0, $0, filewriteerror #if < 0, some error

            addi $sp, $sp, 4
            addi $t1, $t1, 1 #increment char changed counter
            
            j done_to_string
            reverse_number:
                beq $t6, $0, done_reversing #once the num is 0, we are done
                li $t7, 10 #temp register
                
                div $t6, $t7 #num / 10

                mflo $t6 #quotient becomes new num
                mfhi $t8 #remainder is added to be reversed

                li $t7, '0'
                add $t8, $t8, $t7 #get ascii value of current num

                addi $sp, $sp, -4
                sw $t8, 0($sp)
                j reverse_number
            done_reversing:
                li $a2, 1 #write 1 character

                write_reversed:
                    beq $sp, $t9, done_to_string #once the sp is back, done                  
                    

                    li $v0, 15 
                    move $a1, $sp #use stack as input buffer
                    syscall
                    addi $sp, $sp, 4

                    addi $t1, $t1, 1 #increment char changed counter
                    
                    blt $v0, $0, filewriteerror #if < 0, some error
                    j write_reversed
        
        done_to_string:
            li $t7, -1
            beq $t2, $t7, newline_init_row #i = -1, rows not init yet
            beq $t3, $t7, newline_init_col #j = -1, cols not init yet

            blt $t3, $t5, go_next_col #j < cols - 1
            blt $t2, $t4, go_next_row #j = cols - 1 && i < rows - 1

            j exit_write #i = rows, exit

        newline_init_row:
            li $t2, 0 #i = 0
            j write_newline

        newline_init_col:
            li $t3, 0 #j = 0
            j write_newline

        go_next_col:
            addi $t3, $t3, 1 #j++
            j write_space

        go_next_row:
            addi $t2, $t2, 1 #i++
            li $t3, 0 #j = 9
            j write_newline

        write_space:
        li $v0, 15
        li $t7, 32 #space
        addi $sp, $sp, -4
        sw $t7, 0($sp) #use stack as input buffer
        move $a1, $sp
        syscall
        addi $sp, $sp, 4

        addi $t1, $t1, 1 #increment char written

        j file_write_loop


        write_newline:
        li $v0, 15
        li $t7, 10 #\n
        addi $sp, $sp, -4
        sw $t7, 0($sp) #use stack as input buffer
        move $a1, $sp
        syscall
        addi $sp, $sp, 4

        addi $t1, $t1, 1 #increment char written

        j file_write_loop


    filewriteerror:
    li $v0, -1

    exit_write:
        li $v0, 16
        syscall

        move $v0, $t1
        jr $ra


.globl rotate_clkws_90
rotate_clkws_90:
    lw $t2, 0($a0) #get rows
    lw $t3, 4($a0) #get cols

    sw $t3, 0($a0) #cols become rows
    sw $t2, 4($a0) #rows become cols

    li $t0, 0 #i = 0
    move $t1, $t3 #j = cols - 1
    addi $t1, $t1, -1

    addi $a0, $a0, 8 #move to entries

    #from top right, go down and left
    rotate_90_outer:  
        rotate_90_inner:
            beq $t0, $t2, end_rotate_90_inner #if i = rows, done

            #get eff address 4(cols * i + j)
            mult $t0, $t3
            mflo $t4
            add $t4, $t4, $t1
            sll $t4, $t4, 2 #multiply by 4
            add $t4, $t4, $a0 #eff address

            lw $t4, 0($t4)

            addi $sp, $sp, -4 #store on stack
            sw $t4, 0($sp)
        
            addi $t0, $t0, 1 #i++
            j rotate_90_inner
            
        end_rotate_90_inner:
        addi $t1, $t1, -1 #j--
        li $t0, 0 #i = 0

        li $t9, -1
        beq $t1, $t9, end_rotate_90_outer #when j = -1, done
        j rotate_90_outer


    end_rotate_90_outer:
        mult $t2, $t3
        mflo $t0 #iterations of stack to undo

        move $t1, $a0 #moving address

    rotate_90_undo_stack:
        beq $t0, $0, write_rotate_90
        lw $t2, 0($sp) #get from stack
        addi $sp, $sp, 4  
        sw $t2, 0($t1) #store on buffer
        addi $t1, $t1, 4
        addi $t0, $t0, -1 #dec count
        j rotate_90_undo_stack

    write_rotate_90:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $a0, $a0, -8 #undo entry shift
        move $t0, $a1 #temp = a1
        move $a1, $a0 #a1 = a0
        move $a0, $t0 #a0 = temp
        jal write_file

        lw $ra, 0($sp)
        addi $sp, $sp, 4

        jr $ra

.globl rotate_clkws_180
rotate_clkws_180:
    lw $t2, 0($a0) #get rows
    lw $t3, 4($a0) #get cols

    li $t0, 0 #i = 0
    li $t1, 0 #j = 0

    addi $a0, $a0, 8 #move to entries

    #traverse normal
    rotate_180_outer:  
        rotate_180_inner:
            beq $t1, $t3, end_rotate_180_inner #if j = cols, done

            #get eff address 4(cols * i + j)
            mult $t0, $t3
            mflo $t4
            add $t4, $t4, $t1
            sll $t4, $t4, 2 #multiply by 4
            add $t4, $t4, $a0 #eff address

            lw $t4, 0($t4)

            addi $sp, $sp, -4 #store on stack
            sw $t4, 0($sp)
        
            addi $t1, $t1, 1 #j++
            j rotate_180_inner
            
        end_rotate_180_inner:
        addi $t0, $t0, 1 #i++
        li $t1, 0 #j = 0

        beq $t0, $t2, end_rotate_180_outer #when i = rows, done
        j rotate_180_outer


    end_rotate_180_outer:
        mult $t2, $t3
        mflo $t0 #iterations of stack to undo
        move $t1, $a0 #moving address

    rotate_180_undo_stack:
        beq $t0, $0, write_rotate_180
        lw $t2, 0($sp) #get from stack
        addi $sp, $sp, 4  
        sw $t2, 0($t1) #store on buffer
        addi $t1, $t1, 4
        addi $t0, $t0, -1 #dec count
        j rotate_180_undo_stack

    write_rotate_180:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $a0, $a0, -8 #undo entry shift
        move $t0, $a1 #temp = a1
        move $a1, $a0 #a1 = a0
        move $a0, $t0 #a0 = temp
        jal write_file

        lw $ra, 0($sp)
        addi $sp, $sp, 4

        jr $ra

.globl rotate_clkws_270
rotate_clkws_270:
    lw $t2, 0($a0) #get rows
    lw $t3, 4($a0) #get cols

    sw $t3, 0($a0) #cols become rows
    sw $t2, 4($a0) #rows become cols

    move $t0, $t2 #i = rows - 1
    addi $t0, $t0, -1

    li $t1, 0 #j = 0

    addi $a0, $a0, 8 #move to entries

    #from bottom left go up and right
    rotate_270_outer:  
        rotate_270_inner:
            li $t9, -1
            beq $t0, $t9, end_rotate_270_inner #if i = -1, done

            #get eff address 4(cols * i + j)
            mult $t0, $t3
            mflo $t4
            add $t4, $t4, $t1
            sll $t4, $t4, 2 #multiply by 4
            add $t4, $t4, $a0 #eff address

            lw $t4, 0($t4)

            addi $sp, $sp, -4 #store on stack
            sw $t4, 0($sp)
        
            addi $t0, $t0, -1 #i--
            j rotate_270_inner
            
        end_rotate_270_inner:
        addi $t1, $t1, 1 #j++
        move $t0, $t2 #i = rows - 1
        addi $t0, $t0, -1

        beq $t1, $t3, end_rotate_270_outer #when j = cols, done
        j rotate_270_outer


    end_rotate_270_outer:
        mult $t2, $t3
        mflo $t0 #iterations of stack to undo
        

        move $t1, $a0 #moving address

    rotate_270_undo_stack:
        beq $t0, $0, write_rotate_270
        lw $t2, 0($sp) #get from stack
        addi $sp, $sp, 4  
        sw $t2, 0($t1) #store on buffer
        addi $t1, $t1, 4
        addi $t0, $t0, -1 #dec count
        j rotate_270_undo_stack

    write_rotate_270:
        addi $sp, $sp, -4
        sw $ra, 0($sp)

        addi $a0, $a0, -8 #undo entry shift
        move $t0, $a1 #temp = a1
        move $a1, $a0 #a1 = a0
        move $a0, $t0 #a0 = temp
        jal write_file

        lw $ra, 0($sp)
        addi $sp, $sp, 4

        jr $ra


.globl mirror
    mirror:
    li $t0, 0 #i
    li $t1, 0 #j

    lw $t2, 0($a0) #get rows
    lw $t3, 4($a0) #get cols
    addi $a0, $a0, 8

    sra $t8, $t3, 1 #divide by 2 to get cols / 2 

    mirror_outer:  
        mirror_inner:
            bge $t1, $t8, end_mirror_inner # if j >= cols / 2, then done

            #get eff address 4(cols * i + j)
            mult $t0, $t3
            mflo $t4
            add $t4, $t4, $t1
            sll $t4, $t4, 2 #multiply by 4
            add $t4, $t4, $a0 #eff address

            #get eff address 4(cols * i + cols - 1 - j)
            mult $t0, $t3
            mflo $t5
            add $t5, $t5, $t3
            sub $t5, $t5, $t1
            addi $t5, $t5, -1 #-1
            sll $t5, $t5, 2 #multiply by 4
            add $t5, $t5, $a0 #eff address


            lw $t7, 0($t4)
            lw $t6, 0($t5) #temp

            sw $t7, 0($t5)
            sw $t6, 0($t4) #swap

            addi $t1, $t1, 1
            j mirror_inner
            
        end_mirror_inner:
        addi $t0, $t0, 1 #i++
        li $t1, 0 #j = 0

        bne $t0, $t2, mirror_outer

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    addi $a0, $a0, -8 #undo entry shift
    move $t0, $a1 #temp = a1
    move $a1, $a0 #a1 = a0
    move $a0, $t0 #a0 = temp
    jal write_file

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    jr $ra
    

.globl duplicate
duplicate:
    li $t0, 0 #current int
    lw $t1, 0($a0) #get rows
    lw $t2, 4($a0) #get cols

    sll $t3, $t1, 2 #4 * rows
    sub $sp, $sp, $t3 #allocate stack


    li $t3, 0 #i
    li $t4, 0 #j
    addi $a0, $a0, 8 #move buffer forward

   
    dupe_outer:
        dupe_inner:
            beq $t4, $t2, end_dupe_inner #stop once j = cols

            lw $t5, 0($a0) #get bit
            addi $a0, $a0, 4 #move buffer forward

            sll $t0, $t0, 1
            or $t0, $t0, $t5 #combine

            addi $t4, $t4, 1 #j++
            j dupe_inner

        end_dupe_inner:

        addi $t3, $t3, 1 #i++ 
        li $t4, 0 #j = 0

        addi $sp, $sp, 4
        sw $t0, 0($sp)
        li $t0, 0 #reset current int

        beq $t3, $t1, end_dupe_outer #stop once i = rows
        j dupe_outer

    end_dupe_outer:
    li $v0, -1
    li $v1, 0


    sll $t3, $t1, 2 #4 * rows
    sub $t0, $sp, $t3 #point $t0 to start of where we added to stack

    li $t3, 1 #i = 1
    li $t4, 0 #j = 0


    dupe_check_outer:
        move $t6, $t3 #address of i
        sll $t6, $t6, 2 # multiply by 4
        add $t6, $t0, $t6 #$t0 + 4i

        lw $t8, 4($t6) #ith num

        dupe_check_inner:
            beq $t3, $t4, end_dupe_check_inner #stop once j = i

            move $t7, $t4 #address of j
            sll $t7, $t7, 2 # multiply by 4
            add $t7, $t0, $t7 #$t0 + 4j
            lw $t9, 4($t7) #jth num

            bne $t8, $t9, not_dupes
            
            li $v0, 1
            addi $v1, $t3, 1 #i + 1 for 1 index
            j exit_dupe
            
            not_dupes:
            addi $t4, $t4, 1 #j++
            j dupe_check_inner

        end_dupe_check_inner:

        addi $t3, $t3, 1 #i++ 
        li $t4, 0 #j = 0

        beq $t3, $t1, exit_dupe #stop once i = rows
        j dupe_check_outer
    
    exit_dupe:
    jr $ra
