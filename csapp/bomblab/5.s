0x0000000000401062 <+0>:     push   %rbx                        # stores %rbx
0x0000000000401063 <+1>:     sub    $0x20,%rsp                  # %rsp -= 32 4 bytes, 1 for canary, 3 byte free
0x0000000000401067 <+5>:     mov    %rdi,%rbx                   # %rbx = %rdi = &string[0]
0x000000000040106a <+8>:     mov    %fs:0x28,%rax               # Retrieve canary
0x0000000000401073 <+17>:    mov    %rax,0x18(%rsp)             # Store at STACK[24-31]
0x0000000000401078 <+22>:    xor    %eax,%eax                   # %eax = 0
0x000000000040107a <+24>:    callq  0x40131b <string_length>    # %rdi = &string[0]
0x000000000040107f <+29>:    cmp    $0x6,%eax
0x0000000000401082 <+32>:    je     0x4010d2 <phase_5+112>      # string length must be 6
0x0000000000401084 <+34>:    callq  0x40143a <explode_bomb>
0x0000000000401089 <+39>:    jmp    0x4010d2 <phase_5+112>
0x000000000040108b <+41>:    movzbl (%rbx,%rax,1),%ecx          # %ecx = (char)string[%rax]     (1->4)
0x000000000040108f <+45>:    mov    %cl,(%rsp)                  # M[%rsp] = %rcx                (1->1)
0x0000000000401092 <+48>:    mov    (%rsp),%rdx                 # %rdx = M[%rsp] // STACK[0]
0x0000000000401096 <+52>:    and    $0xf,%edx                   # %rdx &= 15
0x0000000000401099 <+55>:    movzbl 0x4024b0(%rdx),%edx         # %rdx = M[%rdx + 0x4024b0]     (4)
0x00000000004010a0 <+62>:    mov    %dl,0x10(%rsp,%rax,1)       # STACK[%rax + 16] = %dl
0x00000000004010a4 <+66>:    add    $0x1,%rax                   # %rax ++
0x00000000004010a8 <+70>:    cmp    $0x6,%rax                   # %rax:6
0x00000000004010ac <+74>:    jne    0x40108b <phase_5+41>       # loop check
0x00000000004010ae <+76>:    movb   $0x0,0x16(%rsp)             # STACK[22-23] = 00
0x00000000004010b3 <+81>:    mov    $0x40245e,%esi              # %rsi = 0x40245e
0x00000000004010b8 <+86>:    lea    0x10(%rsp),%rdi             # %rdi = &STACK[16]
0x00000000004010bd <+91>:    callq  0x401338 <strings_not_equal> # %rdi ? %rsi
0x00000000004010c2 <+96>:    test   %eax,%eax                   # if %eax == 0 (equal)
0x00000000004010c4 <+98>:    je     0x4010d9 <phase_5+119>      # don't explode, over
0x00000000004010c6 <+100>:   callq  0x40143a <explode_bomb>
0x00000000004010cb <+105>:   nopl   0x0(%rax,%rax,1)
0x00000000004010d0 <+110>:   jmp    0x4010d9 <phase_5+119>
0x00000000004010d2 <+112>:   mov    $0x0,%eax                   # %eax = 0
0x00000000004010d7 <+117>:   jmp    0x40108b <phase_5+41>
0x00000000004010d9 <+119>:   mov    0x18(%rsp),%rax             # Retrieve canary
0x00000000004010de <+124>:   xor    %fs:0x28,%rax               # checks
0x00000000004010e7 <+133>:   je     0x4010ee <phase_5+140>      # ok, equal
0x00000000004010e9 <+135>:   callq  0x400b30 <__stack_chk_fail@plt>
0x00000000004010ee <+140>:   add    $0x20,%rsp
0x00000000004010f2 <+144>:   pop    %rbx
0x00000000004010f3 <+145>:   retq