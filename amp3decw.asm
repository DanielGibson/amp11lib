ifdef FDCTDEXT

.386
.387

fdctd18 = `W?fdctd18$:ampegdecoder$n(pnbpnb)v`
fdctd6 = `W?fdctd6$:ampegdecoder$n(pnbpnb)v`
cos18 = `W?cos18$:ampegdecoder$n[]b`
sec36 = `W?sec36$:ampegdecoder$n[]b`
sec72winl = `W?sec72winl$:ampegdecoder$n[]b`
cos6 = `W?cos6$:ampegdecoder$n[]b`
sec12 = `W?sec12$:ampegdecoder$n[]b`
sec24wins = `W?sec24wins$:ampegdecoder$n[]b`

extrn cos18:byte
extrn sec36:byte
extrn sec72winl:byte
extrn cos6:byte
extrn sec12:byte
extrn sec24wins:byte

bf18a macro i,j
  fld  dword ptr [eax+i*4]
  fadd dword ptr [eax+j*4]
  fld  dword ptr [eax+i*4]
  fsub dword ptr [eax+j*4]
  fxch st(1)
  fstp dword ptr [eax+i*4]
  fstp dword ptr [eax+j*4]
endm

bf18 macro i
  fld  dword ptr [eax+(17-i)*4]
  fmul dword ptr ds:sec36[i*4]
  fld  st
  fadd dword ptr [eax+i*4]
  fxch st(1)
  fsub dword ptr [eax+i*4]
  fxch st(1)
  fmul dword ptr ds:sec72winl[i*4]
  fxch st(1)
  fmul dword ptr ds:sec72winl[(17-i)*4]
  fxch st(1)
  fstp dword ptr [eax+i*4]
  fstp dword ptr [eax+(17-i)*4]
endm

bf6 macro i
  fld  dword ptr [eax+(5-i)*4]
  fmul dword ptr ds:sec12[i*4]
  fld  st
  fadd dword ptr [eax+i*4]
  fxch st(1)
  fsub dword ptr [eax+i*4]
  fxch st(1)
  fmul dword ptr ds:sec24wins[i*4]
  fxch st(1)
  fmul dword ptr ds:sec24wins[(5-i)*4]
  fxch st(1)
  fstp dword ptr [eax+i*4]
  fstp dword ptr [eax+(5-i)*4]
endm

add18a macro i
  fld dword ptr [edx+4*(i+1)]
  fadd dword ptr [edx+4*i]
  fstp dword ptr [edx+4*(i+1)]
endm

add18b macro i
  fld dword ptr [edx+4*(i+2)]
  fadd dword ptr [edx+4*i]
  fstp dword ptr [edx+4*(i+2)]
endm

_TEXT segment para public use32 'CODE'
ASSUME CS:_TEXT

public fdctd18
fdctd18 proc
  add18a  16
  add18a  15
  add18a  14
  add18a  13
  add18a  12
  add18a  11
  add18a  10
  add18a   9
  add18a   8
  add18a   7
  add18a   6
  add18a   5
  add18a   4
  add18a   3
  add18a   2
  add18a   1
  add18a   0
  add18b  15
  add18b  13
  add18b  11
  add18b   9
  add18b   7
  add18b   5
  add18b   3
  add18b   1

  push ebp
  sub esp,8
  lea ebp,[esp+4]
    fld       dword ptr [edx+10H]
    fadd      dword ptr [edx+20H]
    fld       dword ptr ds:cos18+8H
    fxch      st(1)
    fmul      st,st(1)
    fstp      dword ptr [ebp]
    fld       dword ptr [edx+10H]
    fadd      dword ptr [edx+40H]
    fmul      dword ptr ds:cos18+10H
    fld       dword ptr ds:cos18+18H
    fld       st
    fmul      dword ptr [edx+30H]
    fadd      dword ptr [edx]
    fld       dword ptr [edx+40H]
    fsub      dword ptr [edx+20H]
    fmul      dword ptr ds:cos18+20H
    fld       st(1)
    fadd      dword ptr [ebp]
    fadd      st,st(1)
    fstp      dword ptr [eax]
    fld       st(1)
    fadd      st,st(4)
    fsub      dword ptr [ebp]
    fstp      dword ptr [eax+8H]
    fld       st(1)
    fsub      st,st(1)
    fsub      st,st(4)
    fstp      dword ptr [eax+0cH]
    fld       dword ptr [edx+20H]
    fadd      dword ptr [edx+40H]
    fsub      dword ptr [edx+10H]
    fstp      dword ptr [ebp]
    fld       dword ptr [edx]
    fsub      dword ptr [edx+30H]
    fstp      st(4)
    fld       dword ptr [ebp]
    fmulp     st(3),st
    fxch      st(2)
    fsubr     st,st(3)
    fstp      dword ptr [eax+4H]
    fld       st(2)
    fadd      dword ptr [ebp]
    fstp      dword ptr [eax+10H]
    fld       dword ptr [edx+8H]
    fadd      dword ptr [edx+28H]
    fmul      dword ptr ds:cos18+4H
    fstp      dword ptr [ebp]
    fld       dword ptr ds:cos18+0cH
    fld       st
    fmul      dword ptr [edx+18H]
    fstp      st(4)
    fld       dword ptr [edx+38H]
    fadd      dword ptr [edx+8H]
    fmul      dword ptr ds:cos18+14H
    fstp      st(2)
    fld       dword ptr [edx+38H]
    fsub      dword ptr [edx+28H]
    fmul      dword ptr ds:cos18+1cH
    fstp      st(3)
    fld       st(3)
    fchs      
    fsub      st,st(2)
    fadd      dword ptr [ebp]
    fstp      dword ptr [eax+14H]
    fld       st(2)
    fsub      st,st(4)
    faddp     st(2),st
    fxch      st(1)
    fstp      dword ptr [eax+18H]
    fxch      st(2)
    fadd      dword ptr [ebp]
    faddp     st(1),st
    fstp      dword ptr [eax+20H]

    fld       dword ptr [edx+8H]
    fsub      dword ptr [edx+28H]
    fsub      dword ptr [edx+38H]
    fmulp     st(1),st
    fstp      dword ptr [eax+1cH]

    fld       dword ptr [edx+14H]
    fadd      dword ptr [edx+24H]
    fmulp     st(1),st
    fstp      dword ptr [ebp]
    fld       dword ptr [edx+14H]
    fadd      dword ptr [edx+44H]
    fmul      dword ptr ds:cos18+10H
    fld       dword ptr ds:cos18+18H
    fld       st
    fmul      dword ptr [edx+34H]
    fadd      dword ptr [edx+4H]
    fld       dword ptr [edx+44H]
    fsub      dword ptr [edx+24H]
    fmul      dword ptr ds:cos18+20H
    fld       st(1)
    fsub      dword ptr [ebp]
    fadd      st,st(4)
    fstp      dword ptr [eax+3cH]
    fld       st(1)
    fadd      st,st(1)
    fadd      dword ptr [ebp]
    fstp      dword ptr [eax+44H]
    fld       st(1)
    fsub      st,st(4)
    fsub      st,st(1)
    fstp      dword ptr [eax+38H]
    fld       dword ptr [edx+24H]
    fadd      dword ptr [edx+44H]
    fsub      dword ptr [edx+14H]
    fstp      dword ptr [ebp]
    fld       dword ptr [edx+4H]
    fsub      dword ptr [edx+34H]
    fstp      st(4)
    fld       dword ptr [ebp]
    fmulp     st(3),st
    fxch      st(2)
    fsubr     st,st(3)
    fstp      dword ptr [eax+40H]
    fld       st(2)
    fadd      dword ptr [ebp]
    fstp      dword ptr [eax+34H]
    fld       dword ptr [edx+0cH]
    fadd      dword ptr [edx+2cH]
    fmul      dword ptr ds:cos18+4H
    fstp      dword ptr [ebp]
    fld       dword ptr ds:cos18+0cH
    fld       st
    fmul      dword ptr [edx+1cH]
    fstp      st(4)
    fld       dword ptr [edx+0cH]
    fadd      dword ptr [edx+3cH]
    fmul      dword ptr ds:cos18+14H
    fstp      st(2)
    fld       dword ptr [edx+3cH]
    fsub      dword ptr [edx+2cH]
    fmul      dword ptr ds:cos18+1cH
    fstp      st(3)
    fld       st(3)
    fchs
    fsub      st,st(2)
    fadd      dword ptr [ebp]
    fstp      dword ptr [eax+30H]
    fld       st(2)
    fsub      st,st(4)
    faddp     st(2),st
    fxch      st(1)
    fstp      dword ptr [eax+2cH]
    fxch      st(2)
    fadd      dword ptr [ebp]
    faddp     st(1),st
    fstp      dword ptr [eax+24H]

    fld       dword ptr [edx+0cH]
    fsub      dword ptr [edx+2cH]
    fsub      dword ptr [edx+3cH]
    fmulp     st(1),st
    fstp      dword ptr [eax+28H]

  add esp,8
  pop ebp

  bf18a  0, 8
  bf18a  1, 7
  bf18a  2, 6
  bf18a  3, 5

  bf18a 17, 9
  bf18a 16,10
  bf18a 15,11
  bf18a 14,12

  bf18 0
  bf18 1
  bf18 2
  bf18 3
  bf18 4
  bf18 5
  bf18 6
  bf18 7
  bf18 8

  ret
fdctd18 endp

public fdctd6
fdctd6 proc
  fld   dword ptr [edx+4*12]
  fadd  dword ptr [edx+3*12]
  fsubr dword ptr [edx+0*12]
  fstp dword ptr [eax+1*4]
  fld   dword ptr [edx+1*12]
  fadd  dword ptr [edx+2*12]
  fmul dword ptr ds:cos6[1*4]
  fld   dword ptr [edx+4*12]
  fadd  dword ptr [edx+3*12]
  fmul dword ptr ds:cos6[2*4]
  fadd  dword ptr [edx+0*12]
  fld st
  fadd st,st(2)
  fstp dword ptr [eax+0*4]
  fsubrp st(1),st
  fstp dword ptr [eax+2*4]

  fld   dword ptr [edx+0*12]
  fadd  dword ptr [edx+1*12]
  fld   dword ptr [edx+2*12]
  fadd  dword ptr [edx+3*12]
  fld st
  fadd  dword ptr [edx+4*12]
  fadd  dword ptr [edx+5*12]
  fst st(3)
  fsubr st,st(2)
  fstp dword ptr [eax+4*4]
  fadd st,st(1)
  fmul dword ptr ds:cos6[1*4]
  fxch st(2)
  fmul dword ptr ds:cos6[2*4]
  faddp st(1),st
  fld st(1)
  fadd st,st(1)
  fstp dword ptr [eax+5*4]
  fsubrp st(1),st
  fstp dword ptr [eax+3*4]

  bf6 0
  bf6 1
  bf6 2

  ret
fdctd6 endp

_TEXT ends

endif

end
