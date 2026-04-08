.section .text
.globl make_node
.globl insert
.globl get
.globl getAtMost

.extern malloc

.equ val, 0
.equ left, 8
.equ right, 16
.equ node, 24


# CREATING NODE
make_node:      # a0 = val
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)        #saving the value

    addi s0, a0, 0      #saving a0 to s0 using addi
    addi a0, zero, node
    jal ra, malloc      #giving 24bytes space by mallocing

    sw s0, val(a0)      

    addi t1, zero, 0
    sd t1, left(a0)    
    sd t1, right(a0)    #making the node (val,left,right)

    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    jalr zero, ra, 0


# INSERTING NODE
# a0 = root, a1 = val
insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)

    addi s0, a0, 0      # store the root to use as current node
    addi s1, a1, 0      # store the target val
    addi s2, a0, 0      # store the original root node

    beq s0, zero, pre_make_node

loop_for_insert:
    lw t2, val(s0)
    blt s1, t2, insert_go_left_node   

insert_go_right_node:
    ld t3, right(s0)
    beq t3, zero, attach_to_right_node

    addi s0, t3, 0
    beq zero, zero, loop_for_insert # base jump instruction

insert_go_left_node:
    ld t3, left(s0)
    beq t3, zero, attach_to_left_node

    addi s0, t3, 0
    beq zero, zero, loop_for_insert

attach_to_left_node:
    addi a0, s1, 0
    jal ra, make_node
    sd a0, left(s0)
    addi a0, s2, 0
    beq zero, zero, insert_return

attach_to_right_node:
    addi a0, s1, 0
    jal ra, make_node
    sd a0, right(s0)
    addi a0, s2, 0
    beq zero, zero, insert_return

pre_make_node:
    addi a0, s1, 0
    jal ra, make_node

insert_return:
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    jalr zero, ra, 0


# GETTING NODE
get:        # a0 = root, a1 = val
    beq a0, zero, get_return_null
    
    addi t5, a1, 0    # store the required value in t5
    addi t0, a0, 0    # store the current node in t0

loop_to_get:
    beq t0, zero, get_return_null

    lw t2, val(t0)   
    beq t2, t5, return_get_answer

    blt t5, t2, get_go_left_node

get_go_right_node:
    ld t3, right(t0)
    addi t0, t3, 0
    beq zero, zero, loop_to_get

get_go_left_node:
    ld t3, left(t0)
    addi t0, t3, 0
    beq zero, zero, loop_to_get

return_get_answer:
    addi a0, t0, 0
    jalr zero, ra, 0

get_return_null:
    addi a0, zero, 0
    jalr zero, ra, 0


# GET FLOOR
getAtMost:      # a0 = val a1 = root
    addi t3, zero, -1   
    addi t5, a0, 0    
    addi t0, a1, 0    

loop_to_getAtMost:
    beq t0, zero, return_getAtMost_answer

    lw t4, val(t0)  
    bgt t4, t5, go_for_left_node    

go_for_right_node:  
    addi t3, t4, 0
    ld t2, right(t0)
    addi t0, t2, 0
    beq zero, zero, loop_to_getAtMost

go_for_left_node:   
    ld t2, left(t0)
    addi t0, t2, 0
    beq zero, zero, loop_to_getAtMost

return_getAtMost_answer:
    addi a0, t3, 0
    jalr zero, ra, 0
