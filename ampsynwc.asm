ifdef FDCTBEXT

.386
.387

fdctb8 = `W?fdctb8$:ampegdecoder$n(pnbpnbpnb)v`
fdctb16 = `W?fdctb16$:ampegdecoder$n(pnbpnbpnb)v`
fdctb32 = `W?fdctb32$:ampegdecoder$n(pnbpnbpnb)v`
sectab = `W?sectab$:ampegdecoder$n[]b`

extrn sectab:byte

_TEXT segment para public use32 'CODE'
assume cs:_TEXT

bf macro a,b,c,d,e
  fld  dword ptr [ebx+4*(a)]
  fsub dword ptr [ebx+4*(b)]
  fld  dword ptr [ebx+4*(a)]
  fadd dword ptr [ebx+4*(b)]
  fxch st(1)
  fmul dword ptr ds:sectab[4*(c)]
  fxch st(1)
  fstp dword ptr [ebx+4*(d)]
  fstp dword ptr [ebx+4*(e)]
endm

bfa macro a,b,c
if (b and 1) eq 0
  bf b*2*a+c,(b+1)*2*a-1-c,a+c,b*2*a+c,(b+1)*2*a-1-c
else
  bf (b+1)*2*a-1-c,b*2*a+c,a+c,b*2*a+c,(b+1)*2*a-1-c
endif
endm

bf1 macro a
  fld  dword ptr [ebx+8*a+  0]
  fsub dword ptr [ebx+8*a+  4]
  fld  dword ptr [ebx+8*a+  0]
  fadd dword ptr [ebx+8*a+  4]
  fxch st(1)
  fmul dword ptr ds:sectab[4]
  fxch st(1)
  fstp dword ptr [ebx+8*a+  0]
  fstp dword ptr [ebx+8*a+  4]

  fld  dword ptr [ebx+8*a+ 12]
  fsub dword ptr [ebx+8*a+  8]
  fld  dword ptr [ebx+8*a+ 12]
  fadd dword ptr [ebx+8*a+  8]
  fxch st(1)
  fmul dword ptr ds:sectab[4]
  fadd st(1),st
  fstp dword ptr [ebx+8*a+ 12]
  fstp dword ptr [ebx+8*a+  8]

  fld  dword ptr [ebx+8*a+ 16]
  fsub dword ptr [ebx+8*a+ 20]
  fld  dword ptr [ebx+8*a+ 16]
  fadd dword ptr [ebx+8*a+ 20]
  fxch st(1)
  fmul dword ptr ds:sectab[4]

  fld  dword ptr [ebx+8*a+ 28]
  fsub dword ptr [ebx+8*a+ 24]
  fld  dword ptr [ebx+8*a+ 28]
  fadd dword ptr [ebx+8*a+ 24]
  fxch st(1)
  fmul dword ptr ds:sectab[4]
  fxch st(1)
  fadd st,st(1)
  fadd st(3),st
  fadd st,st(2)
  fxch st(1)
  fadd st(2),st
  fstp dword ptr [ebx+8*a+ 28]
  fstp dword ptr [ebx+8*a+ 24]
  fstp dword ptr [ebx+8*a+ 20]
  fstp dword ptr [ebx+8*a+ 16]
endm

sm32 macro a,b,c,d,e,g,i,l,f
  mov ecx,dword ptr [ebx+a*4]
  fld     dword ptr [ebx+b*4]
  fadd    dword ptr [ebx+c*4]
  fld     dword ptr [ebx+d*4]
  fadd    dword ptr [ebx+e*4]
  mov  dword ptr [l+(f+0)*64],ecx
  fld st(1)
  fadd    dword ptr [ebx+g*4]
  fxch st(1)
  fstp dword ptr [l+(f+2)*64]
  fxch st(1)
  fadd    dword ptr [ebx+i*4]
  fxch st(1)
  fstp dword ptr [l+(f+1)*64]
  fstp dword ptr [l+(f+3)*64]
endm

sm32a macro a,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+f*64],ecx
endm

sm32b macro c,b,d,a,l,f
  fld     dword ptr [ebx+a*4]
  fadd    dword ptr [ebx+b*4]
  fstp dword ptr [l+(f+1)*64]
  mov ecx,dword ptr [ebx+c*4]
  mov  dword ptr [l+(f+0)*64],ecx
  mov ecx,dword ptr [ebx+d*4]
  mov  dword ptr [l+(f+2)*64],ecx
  mov ecx,dword ptr [ebx+b*4]
  mov  dword ptr [l+(f+3)*64],ecx
endm

sm16 macro a,b,c,l,f
  mov ecx,dword ptr [ebx+a*4]
  fld     dword ptr [ebx+b*4]
  fadd    dword ptr [ebx+c*4]
  mov  dword ptr [l+(f+0)*64],ecx
  fstp dword ptr [l+(f+1)*64]
endm

sm16a macro a,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+f*64],ecx
endm

sm16b macro a,b,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+(f+0)*64],ecx
  mov ecx,dword ptr [ebx+b*4]
  mov  dword ptr [l+(f+1)*64],ecx
endm

sm8 macro a,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+f*64],ecx
endm

sm8a macro a,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+f*64],ecx
endm

sm8b macro a,l,f
  mov ecx,dword ptr [ebx+a*4]
  mov  dword ptr [l+f*64],ecx
endm


public fdctb8
fdctb8 proc
  push ecx

  bfa  4, 0, 0
  bfa  4, 0, 1
  bfa  4, 0, 2
  bfa  4, 0, 3

  bfa  2, 0, 0
  bfa  2, 0, 1
  bfa  2, 1, 0
  bfa  2, 1, 1

  bf1  0

  sm8  1,eax,0
  sm8  6,eax,1
  sm8  2,eax,2
  sm8  4,eax,3
  sm8a 0,eax,4
  sm8  1,edx,0
  sm8  5,edx,1
  sm8  3,edx,2
  sm8b 7,edx,3

  pop ecx
  ret
fdctb8 endp

public fdctb16
fdctb16 proc
  push ecx

  bfa  8, 0, 0
  bfa  8, 0, 1
  bfa  8, 0, 2
  bfa  8, 0, 3
  bfa  8, 0, 4
  bfa  8, 0, 5
  bfa  8, 0, 6
  bfa  8, 0, 7

  bfa  4, 0, 0
  bfa  4, 0, 1
  bfa  4, 0, 2
  bfa  4, 0, 3
  bfa  4, 1, 0
  bfa  4, 1, 1
  bfa  4, 1, 2
  bfa  4, 1, 3

  bfa  2, 0, 0
  bfa  2, 0, 1
  bfa  2, 1, 0
  bfa  2, 1, 1
  bfa  2, 2, 0
  bfa  2, 2, 1
  bfa  2, 3, 0
  bfa  2, 3, 1

  bf1  0
  bf1  4

  sm16   1,14, 9,eax,0
  sm16   6,10,14,eax,2
  sm16   2,12,10,eax,4
  sm16   4, 8,12,eax,6
  sm16a  0,      eax,8
  sm16   1, 9,13,edx,0
  sm16   5,13,11,edx,2
  sm16   3,11,15,edx,4
  sm16b  7,15,   edx,6

  pop ecx
  ret
fdctb16 endp


public fdctb32
fdctb32 proc
  push ecx

  bfa 16, 0, 0
  bfa 16, 0, 1
  bfa 16, 0, 2
  bfa 16, 0, 3
  bfa 16, 0, 4
  bfa 16, 0, 5
  bfa 16, 0, 6
  bfa 16, 0, 7
  bfa 16, 0, 8
  bfa 16, 0, 9
  bfa 16, 0,10
  bfa 16, 0,11
  bfa 16, 0,12
  bfa 16, 0,13
  bfa 16, 0,14
  bfa 16, 0,15

  bfa  8, 0, 0
  bfa  8, 0, 1
  bfa  8, 0, 2
  bfa  8, 0, 3
  bfa  8, 0, 4
  bfa  8, 0, 5
  bfa  8, 0, 6
  bfa  8, 0, 7
  bfa  8, 1, 0
  bfa  8, 1, 1
  bfa  8, 1, 2
  bfa  8, 1, 3
  bfa  8, 1, 4
  bfa  8, 1, 5
  bfa  8, 1, 6
  bfa  8, 1, 7

  bfa  4, 0, 0
  bfa  4, 0, 1
  bfa  4, 0, 2
  bfa  4, 0, 3
  bfa  4, 1, 0
  bfa  4, 1, 1
  bfa  4, 1, 2
  bfa  4, 1, 3
  bfa  4, 2, 0
  bfa  4, 2, 1
  bfa  4, 2, 2
  bfa  4, 2, 3
  bfa  4, 3, 0
  bfa  4, 3, 1
  bfa  4, 3, 2
  bfa  4, 3, 3

  bfa  2, 0, 0
  bfa  2, 0, 1
  bfa  2, 1, 0
  bfa  2, 1, 1
  bfa  2, 2, 0
  bfa  2, 2, 1
  bfa  2, 3, 0
  bfa  2, 3, 1
  bfa  2, 4, 0
  bfa  2, 4, 1
  bfa  2, 5, 0
  bfa  2, 5, 1
  bfa  2, 6, 0
  bfa  2, 6, 1
  bfa  2, 7, 0
  bfa  2, 7, 1

  bf1  0
  bf1  4
  bf1  8
  bf1 12

  sm32   1,25,30, 9,14,17,22,eax, 0
  sm32   6,26,30,10,14,22,18,eax, 4
  sm32   2,26,28,10,12,18,20,eax, 8
  sm32   4,24,28, 8,12,20,16,eax,12
  sm32a  0,                  eax,16
  sm32   1,25,29, 9,13,17,21,edx, 0
  sm32   5,27,29,11,13,21,19,edx, 4
  sm32   3,27,31,11,15,19,23,edx, 8
  sm32b  7,   31,   15,23,   edx,12

  pop ecx
  ret
fdctb32 endp

_TEXT ends

endif

end
