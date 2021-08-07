0x000000000040100c <+0>:     sub    $0x18,%rsp                          # 32bytes on stack
0x0000000000401010 <+4>:     lea    0xc(%rsp),%rcx                      # %rcx = %rsp + 0xc
0x0000000000401015 <+9>:     lea    0x8(%rsp),%rdx                      # %rdx = %rsp + 0x8
0x000000000040101a <+14>:    mov    $0x4025cf,%esi                      # %esi = $0x4025cf // read only %d%d
0x000000000040101f <+19>:    mov    $0x0,%eax                           # %rax = 0
0x0000000000401024 <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>      # sscanf, eax + 1 = numbers
0x0000000000401029 <+29>:    cmp    $0x2,%eax                           # %eax:0x2
0x000000000040102c <+32>:    jne    0x401035 <phase_4+41>               # if eax != 0x2 then goto explode
0x000000000040102e <+34>:    cmpl   $0xe,0x8(%rsp)                      # else (%rsp+8):%0xe
0x0000000000401033 <+39>:    jbe    0x40103a <phase_4+46>               #       if (%rsp+8) <= 0xe goto +46
0x0000000000401035 <+41>:    callq  0x40143a <explode_bomb>             #       else explode
0x000000000040103a <+46>:    mov    $0xe,%edx                           # %edx = 0xe = 14
0x000000000040103f <+51>:    mov    $0x0,%esi                           # %esi = 0
0x0000000000401044 <+56>:    mov    0x8(%rsp),%edi                      # %edi = (%rsp+8) = a[1]
0x0000000000401048 <+60>:    callq  0x400fce <func4>                    # call func4 // <func4>
0x000000000040104d <+65>:    test   %eax,%eax                           # %eax
0x000000000040104f <+67>:    jne    0x401058 <phase_4+76>               # if %eax != 0 goto explode
0x0000000000401051 <+69>:    cmpl   $0x0,0xc(%rsp)                      # (%rsp+12):0 (same as a[1]:0)
0x0000000000401056 <+74>:    je     0x40105d <phase_4+81>               # if (%rsp+12)==0 end safely
0x0000000000401058 <+76>:    callq  0x40143a <explode_bomb>             # else explode
0x000000000040105d <+81>:    add    $0x18,%rsp
0x0000000000401061 <+85>:    retq

%rcx = %rsp + 0xc = *a[1]
%rdx = %rsp + 0x8 = *a[0]
%esi = $0x4025cf
%rax = 0
%eax = read() - 1
if (number_of_ints == 3) {
  if (a[1] <= 14) {
    %edx = 14
	%esi = 0
	%edi = a[0]
	func4()
	if (%eax == 0 && a[1] == 0) end
  }
}

%edx = 14
func4() {
	%eax = %edx - %esi
	%ecx = %eax >> 31
	%eax += %ecx
	%eax >>= 1
	%ecx = %rax + %rsi
	if (%ecx <= %edi) {
	# line 36
		%eax = 0
		if (%ecx < %edi) {
			%esi = %rcx + 1;
			func4();
			%eax = %rax * 2 + 1
		}
	} else {
		%edx = %rcx - 1
		func4()
		%eax <<= 1
	}
	# line 57
}

0x0000000000400fce <+0>:     sub    $0x8,%rsp                           # 8bytes on stack
0x0000000000400fd2 <+4>:     mov    %edx,%eax                           # %eax = %edx
0x0000000000400fd4 <+6>:     sub    %esi,%eax                           # %eax -= %esi
0x0000000000400fd6 <+8>:     mov    %eax,%ecx                           # %ecx = %eax
0x0000000000400fd8 <+10>:    shr    $0x1f,%ecx                          # %ecx >>= 31
0x0000000000400fdb <+13>:    add    %ecx,%eax                           # %eax += %ecx
0x0000000000400fdd <+15>:    sar    %eax                                # %eax >>= 1
0x0000000000400fdf <+17>:    lea    (%rax,%rsi,1),%ecx                  # %ecx = %rax + %rsi
0x0000000000400fe2 <+20>:    cmp    %edi,%ecx                           # %ecx:%edi
0x0000000000400fe4 <+22>:    jle    0x400ff2 <func4+36>                 # if %ecx <= %edi goto +36
0x0000000000400fe6 <+24>:    lea    -0x1(%rcx),%edx                     # else %edx = %rcx - 1
0x0000000000400fe9 <+27>:    callq  0x400fce <func4>                    #      call <func4>
0x0000000000400fee <+32>:    add    %eax,%eax                           #      %eax <<= 1
0x0000000000400ff0 <+34>:    jmp    0x401007 <func4+57>                 #      goto +57
0x0000000000400ff2 <+36>:    mov    $0x0,%eax                           # %eax = 0 
0x0000000000400ff7 <+41>:    cmp    %edi,%ecx                           # %ecx:%edi
0x0000000000400ff9 <+43>:    jge    0x401007 <func4+57>                 # if %ecx >= %edi goto +57
0x0000000000400ffb <+45>:    lea    0x1(%rcx),%esi                      # else %esi = %rcx + 1
0x0000000000400ffe <+48>:    callq  0x400fce <func4>                    # 	   call <func4>
0x0000000000401003 <+53>:    lea    0x1(%rax,%rax,1),%eax               #      %eax = %rax * 2 + 1
0x0000000000401007 <+57>:    add    $0x8,%rsp                           # %rsp += 8
0x000000000040100b <+61>:    retq