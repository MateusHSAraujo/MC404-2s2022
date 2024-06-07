/*  FUNCIONAM
.data
str: .string "oi!\n"
.text
.globl main
main:
    li a0 , 1
    la a1, str
    li a2 , 4 
    li a7, 18
    ecall
    li a7, -1


.text
.globl main
main:
    li a0 , 'o'
    li a1, 'i'
    li a2, '\n'
    sb a0, 0(sp) 
    sb a1, 1(sp) 
    sb a2, 2(sp) 
    li a0, 1
    mv a1, sp
    li a2, 3
    li a7, 18
    ecall
    addi a0, a0, 1

.data
str: .string "oi!"
.text
.globl main
main:
    la a0, str
    jal puts
    li a7, -1
    ecall

*/

.data
str: .string "oi!"
.text
.globl main
main:           ### OPERAÇÃO 4
    
    li a0, 5000
    jal sleep
    
    la a0, str
    jal puts
    li a7, -1
    ecall
ret