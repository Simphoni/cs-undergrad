.section .text
.globl _start
_start:
        li t0,1
        li t1,1
        li t2,0
        li t3,0x80400000
        li t5,10
loop:
        sw t0,(t3)
        add t4,t0,t1
        mv t0,t1
        mv t1,t4
        addi t2,t2,1
        addi t3,t3,4
        bne t2,t5,loop
        jr ra
