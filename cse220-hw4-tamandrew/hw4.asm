######### Andrew Tam ##########
######### 114532406 ##########
######### actam ##########

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

.globl create_network
create_network:
  blt $a0, $0, create_network_error
  blt $a1, $0, create_network_error

  add $t0, $a0, $a1 #bytes to store I + J
  sll $t0, $t0, 2 #4 * (i + j)
  addi $t0, $t0, 16 #16 more bytes for 4 ints

  move $t1, $a0 #save i and j
  move $t2, $a1

  move $a0, $t0
  li $v0, 9
  syscall

  sra $t3, $t0, 2 #div by 4, num of words to set to 0
  move $t4, $v0  

  fill_network_zeros:
    beq $t3, $0, done_fill_network_zeros
    sw $0, 0($t4)
    addi $t4, $t4, 4
    addi $t3, $t3, -1
    j fill_network_zeros

  done_fill_network_zeros:
    sw $t1, 0($v0) #store i and j in heap
    sw $t2, 4($v0)
    j done_create_network

  create_network_error:
  li $v0, -1

  done_create_network:
  jr $ra

.globl add_person
add_person:

  addi $sp, $sp, -12
  sw $a0, 0($sp)
  sw $a1, 4($sp)
  sw $ra, 8($sp)

  jal get_person #check for dupe

  lw $a0, 0($sp)
  lw $a1, 4($sp)
  lw $ra, 8($sp)
  addi $sp, $sp, 12

  li $t0, -1
  bne $v0, $t0, add_person_error #make sure not node is not already in there
  bne $v1, $t0, add_person_error

  lb $t0, 0($a1) #first char
  beq $t0, $0, add_person_error #empty string since first char is \0


  lw $t0, 0($a0) #total nodes  
  lw $t1, 8($a0) #nodes in network

  move $t8, $a0 #network return later

  beq $t0, $t1, add_person_error #nodes at capacity

  sll $t2, $t1, 2 #multiply current nodes by 4
  addi $t2, $t2, 16 #offset for this node
  add $t9, $t2, $a0 #address to save this node

  addi $t1, $t1, 1
  sw $t1, 8($a0) #increment current nodes count

  move $t3, $a1 #string

  li $t0, 0 #k
  count_chars_string:
    lb $t1, 0($t3) #current char
    beq $t1, $0, k_found

    addi $t0, $t0, 1 #k++
    addi $t3, $t3, 1 #increment string pointer
    j count_chars_string

  k_found:
  addi $a0, $t0, 5 #k + 4 + 1 bytes
  li $v0, 9 
  syscall

  sw $v0, 0($t9) #store pointer to node

  sw $t0, 0($v0) #store k
  addi $v0, $v0, 4
  move $t0, $a1 #string first char

  copy_string_loop:
    lb $t1, 0($t0)
    sb $t1, 0($v0)
    beq $t1, $0, done_copy_k

    addi $t0, $t0, 1
    addi $v0, $v0, 1
    j copy_string_loop
  
  done_copy_k:
    move $v0, $t8 #network address
    li $v1, 1

    j done_add_person


  add_person_error:
  li $v0, -1
  li $v1, -1

  done_add_person:
  jr $ra

.globl get_person
get_person:
  lw $t0, 0($a0) #total nodes  
  lw $t1, 8($a0) #nodes in network

  li $t2, -1 #count, becomes 0 on first ieration
  addi $t3, $a0, 12 #current node address. becomes 16 on first iteration

  nodes_loop:
    addi $t3, $t3, 4 #increment node address
    addi $t2, $t2, 1 #increment counter

    beq $t2, $t1, name_not_found #once counter == nodes, done
    lw $t4, 0($t3) #load node from node address

    addi $t4, $t4, 4 #start of string

    move $t5, $a1
    compare_strings_loop:
      lb $t6, 0($t4) #current char of node
      lb $t7, 0($t5) #current char of string

      bne $t6, $t7, nodes_loop

      beq $t6, $0, found_person #reach both \0 and never found differing chars

      addi $t4, $t4, 1
      addi $t5, $t5, 1

    j compare_strings_loop

    found_person:
      lw $v0, 0($t3) #get node address
      li $v1, 1

      j done_get_person
    
  j nodes_loop

  name_not_found:
  li $v0, -1 #not found
  li $v1, -1

  done_get_person:
  jr $ra

.globl add_relation
add_relation:
  addi $sp, $sp, -28
  sw $a0, 0($sp)
  sw $a1, 4($sp)
  sw $a2, 8($sp)
  sw $a3, 12($sp)
  sw $ra, 16($sp)
  sw $s0, 20($sp)
  sw $s1, 24($sp)


  blt $a3, $0, add_relation_error
  li $t0, 3
  bgt $a3, $t0, add_relation_error
  
  lw $t0, 4($a0) #total edges
  lw $t1, 12($a0) #current edges

  beq $t0, $t1, add_relation_error

  move $t4, $a1
  move $t5, $a2

  check_same_name_loop:
    lb $t6, 0($t4) #current char of node
    lb $t7, 0($t5) #current char of string

    bne $t6, $t7, not_equal_names
    beq $t6, $0, add_relation_error #reached end, both null and never had different chars

    addi $t4, $t4, 1
    addi $t5, $t5, 1

  j check_same_name_loop


  not_equal_names:
    li $t2, -1 #current edge counter, becomes 0 on first iteration

    lw $t0, 0($a0) #num nodes
    sll $t0, $t0, 2 #nodes * 4
    add $t0, $t0, $a0
    addi $t0, $t0, 12 #address of first edge, becomes + 16 in first iteration

    dupe_edge_check_loop:
      addi $t2, $t2, 1 #increment edge counter
      addi $t0, $t0, 4 #next edge address
      beq $t2, $t1, proceed_with_add_relation #reached end of edges
    
      lw $t4, 0($t0) #get edge

      #check if first node == first arg && secondnode == second arg ||
      #check if first node == second arg && secondnode == firstarg
      check_1_1:
        lw $t5, 0($t4) #address of first node
        addi $t5, $t5, 4 #first char of first node name
        move $t6, $a1 #first char of first arg name

        check_1_1_loop:
          lb $t7, 0($t5)
          lb $t8, 0($t6)

          bne $t7, $t8, check_1_2 #chars are different, so first node != first arg
          beq $t7, $0, check_2_2 #reached end, first node == first arg

          addi $t5, $t5, 1
          addi $t6, $t6, 1
          j check_1_1_loop

      check_2_2:
        lw $t5, 4($t4) #address of second node
        addi $t5, $t5, 4 #first char of second node name
        move $t6, $a2 #first char of second arg name

        check_2_2_loop:
          lb $t7, 0($t5)
          lb $t8, 0($t6)

          bne $t7, $t8, dupe_edge_check_loop #chars are different, so second node != second arg
          beq $t7, $0, add_relation_error #reached end, second node == second arg

          addi $t5, $t5, 1
          addi $t6, $t6, 1
          j check_2_2_loop

      check_1_2:
        lw $t5, 0($t4) #address of first node
        addi $t5, $t5, 4 #first char of first name
        move $t6, $a2 #first char of second arg name

        check_1_2_loop:
          lb $t7, 0($t5)
          lb $t8, 0($t6)

          bne $t7, $t8, dupe_edge_check_loop #chars are different, so second node != second arg
          beq $t7, $0, check_2_1 #reached end, second node == second arg

          addi $t5, $t5, 1
          addi $t6, $t6, 1
          j check_1_2_loop

      check_2_1:
        lw $t5, 4($t4) #address of second node
          addi $t5, $t5, 4 #first char of second name
          move $t6, $a1 #first char of first arg name

          check_2_1_loop:
            lb $t7, 0($t5)
            lb $t8, 0($t6)

            bne $t7, $t8, dupe_edge_check_loop #chars are different, so second node != second arg
            beq $t7, $0, add_relation_error #reached end, second node == second arg

            addi $t5, $t5, 1
            addi $t6, $t6, 1
            j check_2_1_loop

  proceed_with_add_relation:
   

    jal get_person #get node of person 1
    li $t0, -1
    lw $ra, 16($sp)
    beq $v0, $t0, add_relation_error
    move $s0, $v0

    move $a1, $a2
    jal get_person #get node of person 2
    li $t0, -1
    lw $ra, 16($sp)
    beq $v0, $t0, add_relation_error
    move $s1, $v0

    li $a0, 12
    li $v0, 9
    syscall

    lw $a0, 0($sp)

    lw $t0, 0($a0) #total num nodes
    sll $t0, $t0, 2 #nodes * 4
    
    lw $t1, 12($a0) #num edges
    
    sll $t2, $t1, 2 #edges * 4
    
    add $t0, $t0, $t2
    add $t0, $t0, $a0 
    addi $t0, $t0, 16

    sw $v0, 0($t0) #store pointer to edge


    addi $t1, $t1, 1
    sw $t1, 12($a0) #increment num edges

    sw $s0, 0($v0)
    sw $s1, 4($v0)
    sw $a3, 8($v0)

    move $v0, $a0
    li $v1, 1
    
    j done_add_relation

  add_relation_error:
  li $v0, -1
  li $v1, -1

  done_add_relation:
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp)
    lw $a3, 12($sp)
    lw $ra, 16($sp)
    lw $s0, 20($sp)
    lw $s1, 24($sp)
    addi $sp, $sp, 28

  jr $ra

.globl get_distant_friends
get_distant_friends:
  addi $sp, $sp, -32
  sw $s0, 0($sp)
  sw $s1, 4($sp)
  sw $s2, 8($sp)
  sw $s3, 12($sp)
  sw $s4, 16($sp)
  sw $s5, 20($sp)
  sw $s6, 24($sp)
  sw $s7, 28($sp)

  move $t8, $sp

  addi $sp, $sp, -4
  sw $ra, 0($sp)

  jal get_person #get the node of this person

  lw $ra, 0($sp)
  addi $sp, $sp, 4

  li $t0, -1 
  beq $v0, $t0, distant_friends_person_not_in
  beq $v1, $t0, distant_friends_person_not_in #if name not found, error


  move $s0, $v0 #store the root node address in s0

  move $s1, $sp #start of the visited status array
  addi $s1, $s1, -4

  
  lw $t0, 0($a0) #num nodes
  addi $t1, $a0, 16 #first node

  init_visited:
    beq $t0, $0, done_init_visited

    addi $sp, $sp, -8
    lw $t2, 0($t1) #get pointer to node
    sw $t2, 4($sp) #store the node ptr in stack
    sw $0, 0($sp) #store a 0 to indicate not visited yet

    addi $t0, $t0, -1
    addi $t1, $t1, 4
    j init_visited

  done_init_visited:

  move $s2, $sp #bottom of the edges stack
  addi $s2, $s2, -4

  lw $t1, 4($a0) #num edges
  lw $t0, 0($a0) #num nodes
  sll $t0, $t0, 2 #nodes * 4
 
  addi $t0, $t0, 16 #nodes * 4 + 16 offset
  add $t0, $t0, $a0  #effective address of first edge

  copy_edges_first_time:
    addi $sp, $sp, -4

    beq $t1, $0, done_copy_edges_first
    lw $t2, 0($t0)
    sw $t2, 0($sp)
   
    addi $t0, $t0, 4 #next edge
    addi $t1, $t1, -1 #edges left to copy decrement
    j copy_edges_first_time
  
  done_copy_edges_first:


  move $s3, $sp #bottom of dfs stack

  #s0 points to the root node.
  #s1 points to the start of the visited array
  #s2 points to the start of the current edges.
  #s3 points to bottom of dfs stack

  addi $sp, $sp, -4
  sw $s0, 0($sp) #push first node into stack

  
  #0 = not visited
  #1 = visited
  #-1 visited, neighbour of root
  dfs_loop:
    beq $sp, $s3, done_with_dfs #once the stack is empty, done

    lw $s4, 0($sp) #popped node
    addi $sp, $sp, 4 #pop from stack

    addi $t1, $s1, 8 #moving address 8 gets undone in first ieration

    mark_visited_loop:
      addi $t1, $t1, -8
      beq $t1, $s2, distant_friends_person_not_in #if it reaches the start of the current edges and not found, then some error?
      
      lw $t2, 0($t1)
      beq $t2, $s4, set_node_visited
      
      j mark_visited_loop

    set_node_visited:
      lw $t3, -4($t1)
      bne $t3, $0, continue_dfs #if this node was already visited, then just continue_dfs 0 = not visited
    
      li $t3, 1

      addi $t7, $t1, -4 #address of visited flag
      sw $t3, 0($t7) #mark as visited


    #look for neighbours and push them

    move $t0, $s2 #current edge moving address
    look_for_neighbours_loop:
      beq $t0, $s3, continue_dfs #once we reach the end, jump out
      lw $t1, 0($t0) #pointer to edge
      addi $t0, $t0, -4 #move forward

      beq $t1, $0, look_for_neighbours_loop #if the edge is already used, don't go again (i.e. pointer is 0)

      lw $t2, 8($t1) #relationship
      li $t3, 1
      bne $t2, $t3, look_for_neighbours_loop #if they aren't friends, continue
      
      lw $t2, 0($t1) #node1
      lw $t3, 4($t1) #node2

      beq $t2, $s4, node1_is_current #if node1 == current node
      beq $t3, $s4, node2_is_current #if node2 == current node

      j look_for_neighbours_loop #this edge is unrelated

      node1_is_current:
        addi $sp, $sp, -4
        sw $t3, 0($sp) #push node 2
        j used_edge

      node2_is_current:
        addi $sp, $sp, -4
        sw $t2, 0($sp) #push node 1

      used_edge:
      sw $0, 4($t0) #once we use this edge, mark it as used (set to 0)
      
      j look_for_neighbours_loop

    continue_dfs:
    j dfs_loop


  done_with_dfs:
  li $s7, 0 #prev friend node's pointer
  create_friend_nodes:
    move $s6, $a0
    addi $t0, $s1, 8 #scan visited nodes, 8 gets undone in first iteration

    friend_node_loop:
      addi $t0, $t0, -8 #increment address
      beq $t0, $s2, done_fnodes
      lw $s5, 0($t0) #get current node


      lw $t1, -4($t0) #get visited status
      beq $t1, $0, friend_node_loop #if this node was not visited, then continue

      lw $t1, 0($t0) #get node pointer
      beq $t1, $s0, friend_node_loop #if root, continue



      lw $t3, 0($s6) #nodes
      sll $t3, $t3, 2 #nodes * 4
      addi $t3, $t3, 16
      add $t3, $t3, $s6 #eff address

      lw $t4, 12($s6) #current edges

      check_root_neighbour:
        beq $t4, $0, not_root_neighbour

        lw $t5, 0($t3)
        lw $t6, 0($t5) #node1
        lw $t7, 4($t5) #node2

        addi $t3, $t3, 4
        addi $t4, $t4, -1
        

        beq $t6, $s5, check_node2_root 
        beq $t7, $s5, check_node1_root 

        j check_root_neighbour

        check_node2_root:
          beq $t7, $s0, check_if_direct_friend #connection between this node and root
          j check_root_neighbour

        check_node1_root:
          beq $t6, $s0, check_if_direct_friend #connection between this node and root
          j check_root_neighbour    

        check_if_direct_friend:
          lw $t6, 8($t5)
          li $t7, 1
          beq $t6, $t7, friend_node_loop #if connection is 1, continue
          j check_root_neighbour

      not_root_neighbour:
        lw $t1, 0($s5) #get k

        addi $t1, $t1, 1
        li $t2, 4 #check if k + 1 mod 4 == 0
        div $t1, $t2
        mfhi $t2
        beq $t2, $t0, already_mult_4
        #make mult 4
        li $t3, 4
        sub $t2, $t3, $t2
        add $t1, $t1, $t2

        already_mult_4:
        addi $a0, $t1, 4 #4 for the next pointer

        addi $t1, $s5, 4 #first char

        li $v0, 9
        syscall #allocate memory for friendnode

        beq $s7, $0, store_first_fnode #if this is the first node, don't connect it to prev
        
        #else connect to prev fnode
        sw $v0, 0($s7)
        j copy_name_to_fnode

        store_first_fnode:
          move $s3, $v0 

        copy_name_to_fnode:
          lb $t2, 0($t1)
          sb $t2, 0($v0)
          addi $t1, $t1, 1 #next char
          addi $v0, $v0, 1 #next char
          beq $t2, $0, done_name_copy #once char = 0, done
          j copy_name_to_fnode    

        done_name_copy:
          li $t3, 4
          div $v0, $t3
          mfhi $t3 #remainder
          beq $t3, $0, already_aligned
          li $t4, 4
          sub $t3, $t4, $t3
          add $v0, $v0, $t3 #align to word

          already_aligned:
            sw $0, 0($v0) #null ptr
            move $s7, $v0 #store address to store pointer of next
            j friend_node_loop

      done_fnodes:
        beq $s7, $0, no_distant_friends #if the prev pointer is still null, then no distant friends
        move $v0, $s3 #pointer to first friendnode
        j done_distant_friends


 
  no_distant_friends:
  li $v0, -1
  j done_distant_friends

  distant_friends_person_not_in:
  li $v0, -2

  done_distant_friends:
  move $sp, $t8
  lw $s0, 0($sp)
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)
  lw $s4, 16($sp)
  lw $s5, 20($sp)
  lw $s6, 24($sp)
  lw $s7, 28($sp)
  addi $sp, $sp, 32

  jr $ra
