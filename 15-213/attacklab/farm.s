
farm.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <start_farm>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   %rbp
   5:	48 89 e5             	mov    %rsp,%rbp
   8:	b8 01 00 00 00       	mov    $0x1,%eax
   d:	5d                   	pop    %rbp
   e:	c3                   	retq   

000000000000000f <getval_142>:
   f:	f3 0f 1e fa          	endbr64 
  13:	55                   	push   %rbp
  14:	48 89 e5             	mov    %rsp,%rbp
  17:	b8 fb 78 90 90       	mov    $0x909078fb,%eax
  1c:	5d                   	pop    %rbp
  1d:	c3                   	retq   

000000000000001e <addval_273>:
  1e:	f3 0f 1e fa          	endbr64 
  22:	55                   	push   %rbp
  23:	48 89 e5             	mov    %rsp,%rbp
  26:	89 7d fc             	mov    %edi,-0x4(%rbp)
  29:	8b 45 fc             	mov    -0x4(%rbp),%eax
  2c:	2d b8 76 38 3c       	sub    $0x3c3876b8,%eax
  31:	5d                   	pop    %rbp
  32:	c3                   	retq   

0000000000000033 <addval_219>:
  33:	f3 0f 1e fa          	endbr64 
  37:	55                   	push   %rbp
  38:	48 89 e5             	mov    %rsp,%rbp
  3b:	89 7d fc             	mov    %edi,-0x4(%rbp)
  3e:	8b 45 fc             	mov    -0x4(%rbp),%eax
  41:	2d af 8c a7 6f       	sub    $0x6fa78caf,%eax
  46:	5d                   	pop    %rbp
  47:	c3                   	retq   

0000000000000048 <setval_237>:
  48:	f3 0f 1e fa          	endbr64 
  4c:	55                   	push   %rbp
  4d:	48 89 e5             	mov    %rsp,%rbp
  50:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  54:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  58:	c7 00 48 89 c7 c7    	movl   $0xc7c78948,(%rax)
  5e:	90                   	nop
  5f:	5d                   	pop    %rbp
  60:	c3                   	retq   

0000000000000061 <setval_424>:
  61:	f3 0f 1e fa          	endbr64 
  65:	55                   	push   %rbp
  66:	48 89 e5             	mov    %rsp,%rbp
  69:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  6d:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  71:	c7 00 54 c2 58 92    	movl   $0x9258c254,(%rax)
  77:	90                   	nop
  78:	5d                   	pop    %rbp
  79:	c3                   	retq   

000000000000007a <setval_470>:
  7a:	f3 0f 1e fa          	endbr64 
  7e:	55                   	push   %rbp
  7f:	48 89 e5             	mov    %rsp,%rbp
  82:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  86:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  8a:	c7 00 63 48 8d c7    	movl   $0xc78d4863,(%rax)
  90:	90                   	nop
  91:	5d                   	pop    %rbp
  92:	c3                   	retq   

0000000000000093 <setval_426>:
  93:	f3 0f 1e fa          	endbr64 
  97:	55                   	push   %rbp
  98:	48 89 e5             	mov    %rsp,%rbp
  9b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  9f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
  a3:	c7 00 48 89 c7 90    	movl   $0x90c78948,(%rax)
  a9:	90                   	nop
  aa:	5d                   	pop    %rbp
  ab:	c3                   	retq   

00000000000000ac <getval_280>:
  ac:	f3 0f 1e fa          	endbr64 
  b0:	55                   	push   %rbp
  b1:	48 89 e5             	mov    %rsp,%rbp
  b4:	b8 29 58 90 c3       	mov    $0xc3905829,%eax
  b9:	5d                   	pop    %rbp
  ba:	c3                   	retq   

00000000000000bb <mid_farm>:
  bb:	f3 0f 1e fa          	endbr64 
  bf:	55                   	push   %rbp
  c0:	48 89 e5             	mov    %rsp,%rbp
  c3:	b8 01 00 00 00       	mov    $0x1,%eax
  c8:	5d                   	pop    %rbp
  c9:	c3                   	retq   

00000000000000ca <add_xy>:
  ca:	f3 0f 1e fa          	endbr64 
  ce:	55                   	push   %rbp
  cf:	48 89 e5             	mov    %rsp,%rbp
  d2:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
  d6:	48 89 75 f0          	mov    %rsi,-0x10(%rbp)
  da:	48 8b 55 f8          	mov    -0x8(%rbp),%rdx
  de:	48 8b 45 f0          	mov    -0x10(%rbp),%rax
  e2:	48 01 d0             	add    %rdx,%rax
  e5:	5d                   	pop    %rbp
  e6:	c3                   	retq   

00000000000000e7 <getval_481>:
  e7:	f3 0f 1e fa          	endbr64 
  eb:	55                   	push   %rbp
  ec:	48 89 e5             	mov    %rsp,%rbp
  ef:	b8 5c 89 c2 90       	mov    $0x90c2895c,%eax
  f4:	5d                   	pop    %rbp
  f5:	c3                   	retq   

00000000000000f6 <setval_296>:
  f6:	f3 0f 1e fa          	endbr64 
  fa:	55                   	push   %rbp
  fb:	48 89 e5             	mov    %rsp,%rbp
  fe:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 102:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 106:	c7 00 99 d1 90 90    	movl   $0x9090d199,(%rax)
 10c:	90                   	nop
 10d:	5d                   	pop    %rbp
 10e:	c3                   	retq   

000000000000010f <addval_113>:
 10f:	f3 0f 1e fa          	endbr64 
 113:	55                   	push   %rbp
 114:	48 89 e5             	mov    %rsp,%rbp
 117:	89 7d fc             	mov    %edi,-0x4(%rbp)
 11a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 11d:	2d 77 31 87 36       	sub    $0x36873177,%eax
 122:	5d                   	pop    %rbp
 123:	c3                   	retq   

0000000000000124 <addval_490>:
 124:	f3 0f 1e fa          	endbr64 
 128:	55                   	push   %rbp
 129:	48 89 e5             	mov    %rsp,%rbp
 12c:	89 7d fc             	mov    %edi,-0x4(%rbp)
 12f:	8b 45 fc             	mov    -0x4(%rbp),%eax
 132:	2d 73 2e df 24       	sub    $0x24df2e73,%eax
 137:	5d                   	pop    %rbp
 138:	c3                   	retq   

0000000000000139 <getval_226>:
 139:	f3 0f 1e fa          	endbr64 
 13d:	55                   	push   %rbp
 13e:	48 89 e5             	mov    %rsp,%rbp
 141:	b8 89 d1 48 c0       	mov    $0xc048d189,%eax
 146:	5d                   	pop    %rbp
 147:	c3                   	retq   

0000000000000148 <setval_384>:
 148:	f3 0f 1e fa          	endbr64 
 14c:	55                   	push   %rbp
 14d:	48 89 e5             	mov    %rsp,%rbp
 150:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 154:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 158:	c7 00 81 d1 84 c0    	movl   $0xc084d181,(%rax)
 15e:	90                   	nop
 15f:	5d                   	pop    %rbp
 160:	c3                   	retq   

0000000000000161 <addval_190>:
 161:	f3 0f 1e fa          	endbr64 
 165:	55                   	push   %rbp
 166:	48 89 e5             	mov    %rsp,%rbp
 169:	89 7d fc             	mov    %edi,-0x4(%rbp)
 16c:	8b 45 fc             	mov    -0x4(%rbp),%eax
 16f:	2d bf b7 76 1f       	sub    $0x1f76b7bf,%eax
 174:	5d                   	pop    %rbp
 175:	c3                   	retq   

0000000000000176 <setval_276>:
 176:	f3 0f 1e fa          	endbr64 
 17a:	55                   	push   %rbp
 17b:	48 89 e5             	mov    %rsp,%rbp
 17e:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 182:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 186:	c7 00 88 c2 08 c9    	movl   $0xc908c288,(%rax)
 18c:	90                   	nop
 18d:	5d                   	pop    %rbp
 18e:	c3                   	retq   

000000000000018f <addval_436>:
 18f:	f3 0f 1e fa          	endbr64 
 193:	55                   	push   %rbp
 194:	48 89 e5             	mov    %rsp,%rbp
 197:	89 7d fc             	mov    %edi,-0x4(%rbp)
 19a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 19d:	2d 77 31 6f 6f       	sub    $0x6f6f3177,%eax
 1a2:	5d                   	pop    %rbp
 1a3:	c3                   	retq   

00000000000001a4 <getval_345>:
 1a4:	f3 0f 1e fa          	endbr64 
 1a8:	55                   	push   %rbp
 1a9:	48 89 e5             	mov    %rsp,%rbp
 1ac:	b8 48 89 e0 c1       	mov    $0xc1e08948,%eax
 1b1:	5d                   	pop    %rbp
 1b2:	c3                   	retq   

00000000000001b3 <addval_479>:
 1b3:	f3 0f 1e fa          	endbr64 
 1b7:	55                   	push   %rbp
 1b8:	48 89 e5             	mov    %rsp,%rbp
 1bb:	89 7d fc             	mov    %edi,-0x4(%rbp)
 1be:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1c1:	2d 77 3d ff 36       	sub    $0x36ff3d77,%eax
 1c6:	5d                   	pop    %rbp
 1c7:	c3                   	retq   

00000000000001c8 <addval_187>:
 1c8:	f3 0f 1e fa          	endbr64 
 1cc:	55                   	push   %rbp
 1cd:	48 89 e5             	mov    %rsp,%rbp
 1d0:	89 7d fc             	mov    %edi,-0x4(%rbp)
 1d3:	8b 45 fc             	mov    -0x4(%rbp),%eax
 1d6:	2d 77 31 c7 3f       	sub    $0x3fc73177,%eax
 1db:	5d                   	pop    %rbp
 1dc:	c3                   	retq   

00000000000001dd <setval_248>:
 1dd:	f3 0f 1e fa          	endbr64 
 1e1:	55                   	push   %rbp
 1e2:	48 89 e5             	mov    %rsp,%rbp
 1e5:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 1e9:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 1ed:	c7 00 81 ce 08 db    	movl   $0xdb08ce81,(%rax)
 1f3:	90                   	nop
 1f4:	5d                   	pop    %rbp
 1f5:	c3                   	retq   

00000000000001f6 <getval_159>:
 1f6:	f3 0f 1e fa          	endbr64 
 1fa:	55                   	push   %rbp
 1fb:	48 89 e5             	mov    %rsp,%rbp
 1fe:	b8 89 d1 38 c9       	mov    $0xc938d189,%eax
 203:	5d                   	pop    %rbp
 204:	c3                   	retq   

0000000000000205 <addval_110>:
 205:	f3 0f 1e fa          	endbr64 
 209:	55                   	push   %rbp
 20a:	48 89 e5             	mov    %rsp,%rbp
 20d:	89 7d fc             	mov    %edi,-0x4(%rbp)
 210:	8b 45 fc             	mov    -0x4(%rbp),%eax
 213:	2d 38 76 1f 3c       	sub    $0x3c1f7638,%eax
 218:	5d                   	pop    %rbp
 219:	c3                   	retq   

000000000000021a <addval_487>:
 21a:	f3 0f 1e fa          	endbr64 
 21e:	55                   	push   %rbp
 21f:	48 89 e5             	mov    %rsp,%rbp
 222:	89 7d fc             	mov    %edi,-0x4(%rbp)
 225:	8b 45 fc             	mov    -0x4(%rbp),%eax
 228:	2d 77 3d 7b 3f       	sub    $0x3f7b3d77,%eax
 22d:	5d                   	pop    %rbp
 22e:	c3                   	retq   

000000000000022f <addval_201>:
 22f:	f3 0f 1e fa          	endbr64 
 233:	55                   	push   %rbp
 234:	48 89 e5             	mov    %rsp,%rbp
 237:	89 7d fc             	mov    %edi,-0x4(%rbp)
 23a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 23d:	2d b8 76 1f 38       	sub    $0x381f76b8,%eax
 242:	5d                   	pop    %rbp
 243:	c3                   	retq   

0000000000000244 <getval_272>:
 244:	f3 0f 1e fa          	endbr64 
 248:	55                   	push   %rbp
 249:	48 89 e5             	mov    %rsp,%rbp
 24c:	b8 99 d1 08 d2       	mov    $0xd208d199,%eax
 251:	5d                   	pop    %rbp
 252:	c3                   	retq   

0000000000000253 <getval_155>:
 253:	f3 0f 1e fa          	endbr64 
 257:	55                   	push   %rbp
 258:	48 89 e5             	mov    %rsp,%rbp
 25b:	b8 89 c2 c4 c9       	mov    $0xc9c4c289,%eax
 260:	5d                   	pop    %rbp
 261:	c3                   	retq   

0000000000000262 <setval_299>:
 262:	f3 0f 1e fa          	endbr64 
 266:	55                   	push   %rbp
 267:	48 89 e5             	mov    %rsp,%rbp
 26a:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 26e:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 272:	c7 00 48 89 e0 91    	movl   $0x91e08948,(%rax)
 278:	90                   	nop
 279:	5d                   	pop    %rbp
 27a:	c3                   	retq   

000000000000027b <addval_404>:
 27b:	f3 0f 1e fa          	endbr64 
 27f:	55                   	push   %rbp
 280:	48 89 e5             	mov    %rsp,%rbp
 283:	89 7d fc             	mov    %edi,-0x4(%rbp)
 286:	8b 45 fc             	mov    -0x4(%rbp),%eax
 289:	2d 77 31 6d 3c       	sub    $0x3c6d3177,%eax
 28e:	5d                   	pop    %rbp
 28f:	c3                   	retq   

0000000000000290 <getval_311>:
 290:	f3 0f 1e fa          	endbr64 
 294:	55                   	push   %rbp
 295:	48 89 e5             	mov    %rsp,%rbp
 298:	b8 89 d1 08 db       	mov    $0xdb08d189,%eax
 29d:	5d                   	pop    %rbp
 29e:	c3                   	retq   

000000000000029f <setval_167>:
 29f:	f3 0f 1e fa          	endbr64 
 2a3:	55                   	push   %rbp
 2a4:	48 89 e5             	mov    %rsp,%rbp
 2a7:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 2ab:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2af:	c7 00 89 d1 91 c3    	movl   $0xc391d189,(%rax)
 2b5:	90                   	nop
 2b6:	5d                   	pop    %rbp
 2b7:	c3                   	retq   

00000000000002b8 <setval_328>:
 2b8:	f3 0f 1e fa          	endbr64 
 2bc:	55                   	push   %rbp
 2bd:	48 89 e5             	mov    %rsp,%rbp
 2c0:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 2c4:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2c8:	c7 00 81 c2 38 d2    	movl   $0xd238c281,(%rax)
 2ce:	90                   	nop
 2cf:	5d                   	pop    %rbp
 2d0:	c3                   	retq   

00000000000002d1 <setval_450>:
 2d1:	f3 0f 1e fa          	endbr64 
 2d5:	55                   	push   %rbp
 2d6:	48 89 e5             	mov    %rsp,%rbp
 2d9:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 2dd:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 2e1:	c7 00 09 ce 08 c9    	movl   $0xc908ce09,(%rax)
 2e7:	90                   	nop
 2e8:	5d                   	pop    %rbp
 2e9:	c3                   	retq   

00000000000002ea <addval_358>:
 2ea:	f3 0f 1e fa          	endbr64 
 2ee:	55                   	push   %rbp
 2ef:	48 89 e5             	mov    %rsp,%rbp
 2f2:	89 7d fc             	mov    %edi,-0x4(%rbp)
 2f5:	8b 45 fc             	mov    -0x4(%rbp),%eax
 2f8:	2d f8 76 1f 6f       	sub    $0x6f1f76f8,%eax
 2fd:	5d                   	pop    %rbp
 2fe:	c3                   	retq   

00000000000002ff <addval_124>:
 2ff:	f3 0f 1e fa          	endbr64 
 303:	55                   	push   %rbp
 304:	48 89 e5             	mov    %rsp,%rbp
 307:	89 7d fc             	mov    %edi,-0x4(%rbp)
 30a:	8b 45 fc             	mov    -0x4(%rbp),%eax
 30d:	05 89 c2 c7 3c       	add    $0x3cc7c289,%eax
 312:	5d                   	pop    %rbp
 313:	c3                   	retq   

0000000000000314 <getval_169>:
 314:	f3 0f 1e fa          	endbr64 
 318:	55                   	push   %rbp
 319:	48 89 e5             	mov    %rsp,%rbp
 31c:	b8 88 ce 20 c0       	mov    $0xc020ce88,%eax
 321:	5d                   	pop    %rbp
 322:	c3                   	retq   

0000000000000323 <setval_181>:
 323:	f3 0f 1e fa          	endbr64 
 327:	55                   	push   %rbp
 328:	48 89 e5             	mov    %rsp,%rbp
 32b:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 32f:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 333:	c7 00 48 89 e0 c2    	movl   $0xc2e08948,(%rax)
 339:	90                   	nop
 33a:	5d                   	pop    %rbp
 33b:	c3                   	retq   

000000000000033c <addval_184>:
 33c:	f3 0f 1e fa          	endbr64 
 340:	55                   	push   %rbp
 341:	48 89 e5             	mov    %rsp,%rbp
 344:	89 7d fc             	mov    %edi,-0x4(%rbp)
 347:	8b 45 fc             	mov    -0x4(%rbp),%eax
 34a:	2d 77 3d 9f 2d       	sub    $0x2d9f3d77,%eax
 34f:	5d                   	pop    %rbp
 350:	c3                   	retq   

0000000000000351 <getval_472>:
 351:	f3 0f 1e fa          	endbr64 
 355:	55                   	push   %rbp
 356:	48 89 e5             	mov    %rsp,%rbp
 359:	b8 8d ce 20 d2       	mov    $0xd220ce8d,%eax
 35e:	5d                   	pop    %rbp
 35f:	c3                   	retq   

0000000000000360 <setval_350>:
 360:	f3 0f 1e fa          	endbr64 
 364:	55                   	push   %rbp
 365:	48 89 e5             	mov    %rsp,%rbp
 368:	48 89 7d f8          	mov    %rdi,-0x8(%rbp)
 36c:	48 8b 45 f8          	mov    -0x8(%rbp),%rax
 370:	c7 00 48 89 e0 90    	movl   $0x90e08948,(%rax)
 376:	90                   	nop
 377:	5d                   	pop    %rbp
 378:	c3                   	retq   

0000000000000379 <end_farm>:
 379:	f3 0f 1e fa          	endbr64 
 37d:	55                   	push   %rbp
 37e:	48 89 e5             	mov    %rsp,%rbp
 381:	b8 01 00 00 00       	mov    $0x1,%eax
 386:	5d                   	pop    %rbp
 387:	c3                   	retq   
