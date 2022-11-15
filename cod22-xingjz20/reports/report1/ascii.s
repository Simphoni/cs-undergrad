        .text
        .globl _start
WRITE_SERIAL:
	li t0, 0x10000000
.TESTW:
	lb t1, 5(t0)
	andi t1, t1, 0x20
	beq t1, zero, .TESTW
.WSERIAL:
	sb a0, 0(t0)
	jr ra
_start:
        li t2, 0x20
        li t3, 0x7e
        mv t4, ra
loop:
        addi t2, t2, 1
        mv a0, t2
        jal ra, WRITE_SERIAL
        bne t2, t3, loop
        mv ra, t4
        jr ra
