.section .data
fmt_int: .string "%d "
fmt_new_line: .string "\n"

.section .text
.globl main

main:
    addi sp, sp, -64    # Allocating memory on stack
    sd ra, 56(sp)
    sd s0, 48(sp)       # Base address of input array
    sd s1, 40(sp)       # Base address of Result array
    sd s2, 32(sp)       # Base address for Stack implementation
    sd s3, 24(sp)       # Value of n
    sd s4, 16(sp)       # Value of top
    sd s5, 8(sp)        # Loop counter
    sd s6, 0(sp)        # Value of a1 (argv)

    addi s3, a0, -1     # s3 = n (argc-1)

    slli t0, s3, 2      # calculating space for an array
    addi t0, t0, 15     # Add 15 to ensure we can round up
    andi t0, t0, -16    # Clear the lower 4 bits (forces 16-byte alignment)
    
    sub sp, sp, t0      # Allocating input array to s0
    addi s0 ,sp, 0

    sub sp, sp, t0      # Allocating result array to s1
    addi s1, sp, 0

    sub sp, sp, t0      # Allocating Stack array to s2
    addi s2, sp, 0

    add s6, a1, zero    # Allocating argv to s6
    li s5, 0            # Initialize loop counter, i=0

input_loop:
    bge s5, s3, init_result_array

    addi t1, s5, 1      # t1=i+1
    slli t1, t1, 3      # Multiply by 8
    add t1, s6, t1      # Add to base address of argv (s6)
    ld a0, 0(t1)        # Load pointer to string into a0
    jal ra, atoi        # Call the atoi function to convert string to int

    slli t1, s5, 2      # Multiply by 4
    add t1, s0, t1      # Add to base address of input array (s0)
    sw a0, 0(t1)        # Save the converted number in the array

    addi s5, s5, 1      # Incrementing i
    beq zero, zero, input_loop

init_result_array:
    li s5, 0

init_result_array_loop:
    bge s5, s3, init_next_greater

    slli t1, s5, 2      # Multiply by 4 (size of word)
    add t1, s1, t1      # Add base address of result array to t1
    li t2, -1           # Load -1 into t2
    sw t2, 0(t1)        # Store -1 as word into address in t1

    addi s5, s5, 1
    beq zero, zero, init_result_array_loop

init_next_greater:
    li s5, 0
    li s4, -1

next_greater_loop:
    bge s5, s3, init_print

    slli t1, s5, 2
    add t1, s0, t1
    lw t0, 0(t1)    # Load current element from input array into t0

stack_while_loop:
    li t1, -1
    beq s4, t1, push_to_stack

    slli t1, s4, 2
    add t1, s2, t1
    lw t2, 0(t1)    # Get top element of stack (index)
    
    slli t3, t2, 2
    add t3, s0, t3      
    lw t4, 0(t3)        # Load value at that index

    ble t0, t4, push_to_stack   # If input[i] <= input[stack[top]], break while loop

    slli t1, t2, 2      # Use the popped index t2
    add t1, s1, t1      
    sw s5, 0(t1)        # result[stack[top]] = input[i]

    addi s4, s4, -1     # Pop the stack
    beq zero, zero, stack_while_loop 

push_to_stack:
    addi s4, s4, 1      # Incrementing top
    slli t1, s4, 2
    add t1, s2, t1
    sw s5, 0(t1)        # Storing the current element at top of stack

    addi s5, s5, 1
    beq zero, zero, next_greater_loop

init_print:
    li s5, 0

print_loop:
    bge s5, s3, finish_exec

    slli t0, s5, 2
    add t0, s1, t0
    lw a1, 0(t0)    # Loading result into a1

    la a0, fmt_int
    jal ra, printf

    addi s5, s5, 1
    beq zero, zero, print_loop

finish_exec:
    la a0, fmt_new_line
    jal ra, printf

    # Since we did 3 allocations of t0 size:
    slli t0, s3, 2
    addi t0, t0, 15
    andi t0, t0, -16
    
    # Move sp back for the three arrays
    add sp, sp, t0      # skip s2   
    add sp, sp, t0      # skip s1
    add sp, sp, t0      # skip s0

    # Restore Saved Registers
    ld s6, 0(sp)
    ld s5, 8(sp)
    ld s4, 16(sp)
    ld s3, 24(sp)
    ld s2, 32(sp)
    ld s1, 40(sp)
    ld s0, 48(sp)
    ld ra, 56(sp)
    addi sp, sp, 64
    
    li a0, 0
    ret
