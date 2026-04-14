.section .data
filename: .string "input.txt"
mode: .string "r"
is_palindrome: .string "Yes\n"
is_not_palindrome: .string "No\n"

.section .text
.globl main

main:       # Stack setup
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    sd s4, 0(sp)

opening_file:
    la a0, filename     # a0 = "input.txt"
    la a1, mode         # a1 = "r"
    jal ra, fopen
    add s0, a0, zero    # allocating space on stack for file's pointer
    beq s0, zero, just_finish

accessing_last_character:

    add a0, s0, zero    # a0 is file pointer
    li a1, 0            # setting offset=0
    li a2, 2            # SEEK_END is defined a 2
    jal ra, fseek       # shifting pointer to end of file

    add a0, s0, zero
    jal ra, ftell       # get the total length of the file
    beq a0, zero, is_palin   # If file is empty, it is a palindrome
    addi s2, a0, -1     # last character = length-1 (right pointer)

    add a0, s0, zero    # a0 is file pointer
    li a1, 0            # setting offset=0
    li a2, 0            # SEEK_SET is defined a 2
    jal ra, fseek       # shifting pointer to start of file
    li s1, 0            # first character = 0 (left pointer)

check_newline:

    add a0, s0, zero    # a0 = file pointer
    add a1, s2, zero    # offset
    li a2, 0            # SEEK_SET
    jal ra, fseek

    add a0, s0, zero
    jal ra, fgetc       # Read the last character
    
    li t0, 10           # 10 is the ASCII code for '\n'
    bne a0, t0, comparison_loop  # If it's NOT a newline, we jump to the comparison_loop
    addi s2, s2, -1     # If it IS a newline, move right pointer left by 1

comparison_loop:

    bgt s1, s2, is_palin # left pointer equal to/crosses right pointer. The input is a palindrome 

    add a0, s0, zero
    add a1, s1, zero
    li a2, 0
    jal ra, fseek       #reading character at left

    add a0, s0, zero
    jal ra, fgetc
    add s3, a0, zero    # s3 = left character

    add a0, s0, zero
    add a1, s2, zero
    li a2, 0
    jal ra, fseek       #reading character at right

    add a0, s0, zero
    jal ra, fgetc
    add s4, a0, zero    # s4 = right character

    bne s3, s4, is_not_palin 

    addi s1, s1, 1
    addi s2, s2, -1
    beq zero, zero, comparison_loop

is_palin:
    la a0, is_palindrome
    jal ra, printf
    beq zero, zero, finish_exec

is_not_palin:
    la a0, is_not_palindrome
    jal ra, printf
    beq zero, zero, finish_exec

finish_exec:
    add a0, s0, zero
    jal ra, fclose      # Closing the file

    ld s4, 0(sp)
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48

    li a0, 0
    ret

just_finish:

    ld s4, 0(sp)
    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48

    li a0, 0
    ret
