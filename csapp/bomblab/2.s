0x0000000000400efc <phase_2>:
0x0000000000400efc <+0>:     push   %rbp
0x0000000000400efd <+1>:     push   %rbx                        # %rdi: first char's position in memory
0x0000000000400efe <+2>:     sub    $0x28,%rsp                  # stack pointer -= 40byte(5q) // malloc space for six ints
0x0000000000400f02 <+6>:     mov    %rsp,%rsi                   # %rsi stores current stack pointer // for <read_six_numbers>
0x0000000000400f05 <+9>:     callq  0x40145c <read_six_numbers> # ints stored in (%rsp) to (%rsp) + 4 * 5
0x0000000000400f0a <+14>:    cmpl   $0x1,(%rsp)                 # (%rsp):1 // a_0:1
0x0000000000400f0e <+18>:    je     0x400f30 <phase_2+52>       # if (%rsp) == 1 goto +52 // a_0 = 1
0x0000000000400f10 <+20>:    callq  0x40143a <explode_bomb>     # fail
0x0000000000400f15 <+25>:    jmp    0x400f30 <phase_2+52>       #
0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax             # %eax = (%rbx - 4) // = a_{i-1}
0x0000000000400f1a <+30>:    add    %eax,%eax                   # %eax *= 2 // 2 * a_{i-1}
0x0000000000400f1c <+32>:    cmp    %eax,(%rbx)                 # int (%rbx):%eax
0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41>       # if (%rbx) == %eax goto +41  // must jump
0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb>     # fail
0x0000000000400f25 <+41>:    add    $0x4,%rbx                   # %rbx += 4 // point to the next int
0x0000000000400f29 <+45>:    cmp    %rbp,%rbx                   # %rbx:%rbp
0x0000000000400f2c <+48>:    jne    0x400f17 <phase_2+27>       # if %rbx != %rbp goto +27
0x0000000000400f2e <+50>:    jmp    0x400f3c <phase_2+64>       # goto +64 // must visit
0x0000000000400f30 <+52>:    lea    0x4(%rsp),%rbx              # %rbx = (%rsp) + 4 // point to a_{i+1}
0x0000000000400f35 <+57>:    lea    0x18(%rsp),%rbp             # %rbp = (%rsp) + 24 // point to a + 6, sets the finishing position
0x0000000000400f3a <+62>:    jmp    0x400f17 <phase_2+27>       # goto +27
0x0000000000400f3c <+64>:    add    $0x28,%rsp                  # stack pointer back in place
0x0000000000400f40 <+68>:    pop    %rbx
0x0000000000400f41 <+69>:    pop    %rbp
0x0000000000400f42 <+70>:    retq
