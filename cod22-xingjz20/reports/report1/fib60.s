        .section .text
        .globl _start
_start:
        li s2, 1
        li s3, 60
        li t2, 1
        li t3, 0
        li t4, 1
        li t5, 0
loop:
        add t0, t2, t4
        sltu t6, t0, t2
        add t1, t3, t5
        add t1, t1, t6
        mv t4, t2
        mv t5, t3
        mv t2, t0
        mv t3, t1
        addi s2, s2, 1
        bne s2, s3, loop
        li s4, 0x80400000
        sw t4, (s4)
        addi s4, s4, 4
        sw t5, (s4)
        jr ra
