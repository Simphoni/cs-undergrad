0x0000000000400f43 <+0>:     sub    $0x18,%rsp                          # %rsp -= 24
0x0000000000400f47 <+4>:     lea    0xc(%rsp),%rcx                      # %rcx = %rsp + 12
0x0000000000400f4c <+9>:     lea    0x8(%rsp),%rdx                      # %rdx = %rsp + 8
0x0000000000400f51 <+14>:    mov    $0x4025cf,%esi                      # %esi = 0x4025cf
0x0000000000400f56 <+19>:    mov    $0x0,%eax                           # %eax = 0
0x0000000000400f5b <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>      # %eax + 1 = number of elements
0x0000000000400f60 <+29>:    cmp    $0x1,%eax                           # %eax:1
0x0000000000400f63 <+32>:    jg     0x400f6a <phase_3+39>               # if %eax > 1 then goto +39 (number of ints > 2)
0x0000000000400f65 <+34>:    callq  0x40143a <explode_bomb>             # else explode
0x0000000000400f6a <+39>:    cmpl   $0x7,0x8(%rsp)                      # (%rsp+8):7 // begin of switch, FLAGS maintains
0x0000000000400f6f <+44>:    ja     0x400fad <phase_3+106>              # default: explode
0x0000000000400f71 <+46>:    mov    0x8(%rsp),%eax                      # %eax = (%rsp+8) // important: the first number is in mem[%rsp+8]
0x0000000000400f75 <+50>:    jmpq   *0x402470(,%rax,8)                  # goto 0x402470[%rax] // long long array[]
0x0000000000400f7c <+57>:    mov    $0xcf,%eax                          # 0x42470[0]
0x0000000000400f81 <+62>:    jmp    0x400fbe <phase_3+123>              
0x0000000000400f83 <+64>:    mov    $0x2c3,%eax                         # 0x42470[2]
0x0000000000400f88 <+69>:    jmp    0x400fbe <phase_3+123>
0x0000000000400f8a <+71>:    mov    $0x100,%eax                         # 0x42470[3]
0x0000000000400f8f <+76>:    jmp    0x400fbe <phase_3+123>
0x0000000000400f91 <+78>:    mov    $0x185,%eax                         # 0x42470[4]
0x0000000000400f96 <+83>:    jmp    0x400fbe <phase_3+123>
0x0000000000400f98 <+85>:    mov    $0xce,%eax                          # 0x42470[5]
0x0000000000400f9d <+90>:    jmp    0x400fbe <phase_3+123>
0x0000000000400f9f <+92>:    mov    $0x2aa,%eax                         # 0x42470[6]
0x0000000000400fa4 <+97>:    jmp    0x400fbe <phase_3+123>
0x0000000000400fa6 <+99>:    mov    $0x147,%eax                         # 0x42470[7]
0x0000000000400fab <+104>:   jmp    0x400fbe <phase_3+123>
0x0000000000400fad <+106>:   callq  0x40143a <explode_bomb>
0x0000000000400fb2 <+111>:   mov    $0x0,%eax
0x0000000000400fb7 <+116>:   jmp    0x400fbe <phase_3+123>
0x0000000000400fb9 <+118>:   mov    $0x137,%eax                         # 0x42470[1]
0x0000000000400fbe <+123>:   cmp    0xc(%rsp),%eax                      # %eax:(%rsp+12) // important: what is %rsp+12
0x0000000000400fc2 <+127>:   je     0x400fc9 <phase_3+134>              # if %eax == (%rsp+12) exit safely
0x0000000000400fc4 <+129>:   callq  0x40143a <explode_bomb>
0x0000000000400fc9 <+134>:   add    $0x18,%rsp
0x0000000000400fcd <+138>:   retq
