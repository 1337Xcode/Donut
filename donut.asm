; donut.asm
; Rotating donut animation for Windows using NASM

section .data
    A       dd  0.0
    B       dd  0.0
    theta   dd  0.0
    phi     dd  0.0
    c       dd  0.0
    d       dd  0.0
    e       dd  0.0
    f       dd  0.0
    g       dd  0.0
    h       dd  0.0
    D       dd  0.0
    l       dd  0.0
    m       dd  0.0
    n       dd  0.0
    t       dd  0.0
    x       dd  0.0
    y       dd  0.0
    L       dd  0.0
    x_int   dd  0
    y_int   dd  0

    zbuffer times 1760 dd 0.0
    output  times 1760 db ' '
    esc_seq db  1Bh, '[', 'H'

    TWO_PI  dd  6.28
    STEP_T  dd  0.07
    STEP_P  dd  0.02
    INC_A   dd  0.04
    INC_B   dd  0.02
    FIVE    dd  5.0
    TWO     dd  2.0
    EIGHT   dd  8.0
    THIRTY  dd  30.0
    FORTY   dd  40.0
    FIFTEEN dd  15.0
    TWELVE  dd  12.0
    ZERO    dd  0.0
    chars   db  ".,-~:;=!*#$@", 0
    WIDTH   dd  80
    HEIGHT  dd  22
    SLEEP_MS dd 50

    hConsole      dd  0
    bytesWritten  dd  0

section .text
    extern _GetStdHandle@4
    extern _WriteConsoleA@20
    extern _Sleep@4
    extern _ExitProcess@4
    global _main

_main:
    push -11
    call _GetStdHandle@4
    mov [hConsole], eax

main_loop:
    ; clear buffers
    mov edi, output
    mov ecx, 1760
    mov al, ' '
    rep stosb
    mov edi, zbuffer
    mov ecx, 1760
    xor eax, eax
    rep stosd

    ; cursor to top-left
    mov eax, output
    mov byte [eax], 1Bh
    mov byte [eax+1], '['
    mov byte [eax+2], 'H'

    mov eax, [ZERO]
    mov [theta], eax

outer_loop:
    fld dword [theta]
    fcomp dword [TWO_PI]
    fstsw ax
    sahf
    jae end_outer

    mov eax, [ZERO]
    mov [phi], eax

inner_loop:
    fld dword [phi]
    fcomp dword [TWO_PI]
    fstsw ax
    sahf
    jae end_inner

    ; trig calculations for donut surface
    fld dword [phi]
    fsin
    fstp dword [c]

    fld dword [theta]
    fcos
    fstp dword [d]

    fld dword [A]
    fsin
    fstp dword [e]

    fld dword [theta]
    fsin
    fstp dword [f]

    fld dword [A]
    fcos
    fstp dword [g]

    fld dword [d]
    fadd dword [TWO]
    fstp dword [h]

    ; distance from camera
    fld dword [c]
    fmul dword [h]
    fmul dword [e]
    fld dword [f]
    fmul dword [g]
    faddp
    fadd dword [FIVE]
    fld1
    fdivrp
    fstp dword [D]

    fld dword [phi]
    fcos
    fstp dword [l]

    fld dword [B]
    fcos
    fstp dword [m]

    fld dword [B]
    fsin
    fstp dword [n]

    fld dword [c]
    fmul dword [h]
    fmul dword [g]
    fld dword [f]
    fmul dword [e]
    fsubp
    fstp dword [t]

    ; screen coordinates
    fld dword [l]
    fmul dword [h]
    fmul dword [m]
    fld dword [t]
    fmul dword [n]
    fsubp
    fmul dword [D]
    fmul dword [THIRTY]
    fadd dword [FORTY]
    fstp dword [x]

    fld dword [l]
    fmul dword [h]
    fmul dword [n]
    fld dword [t]
    fmul dword [m]
    faddp
    fmul dword [D]
    fmul dword [FIFTEEN]
    fadd dword [TWELVE]
    fstp dword [y]

    fld dword [x]
    fistp dword [x_int]
    fld dword [y]
    fistp dword [y_int]

    ; bounds check
    mov eax, [x_int]
    cmp eax, 0
    jl skip_point
    cmp eax, 80
    jge skip_point
    mov ebx, [y_int]
    cmp ebx, 0
    jl skip_point
    cmp ebx, 22
    jge skip_point

    mov eax, ebx
    mov ebx, [WIDTH]
    mul ebx
    add eax, [x_int]
    mov esi, eax

    ; depth test
    fld dword [D]
    fcomp dword [zbuffer + esi*4]
    fstsw ax
    sahf
    jbe skip_point

    fld dword [D]
    fstp dword [zbuffer + esi*4]

    ; lighting calculation
    fld dword [f]
    fmul dword [e]
    fld dword [c]
    fmul dword [d]
    fmul dword [g]
    faddp
    fmul dword [m]
    fld dword [c]
    fmul dword [d]
    fmul dword [e]
    fsubp
    fld dword [f]
    fmul dword [g]
    fsubp
    fld dword [l]
    fmul dword [d]
    fmul dword [n]
    fsubp
    fmul dword [EIGHT]
    fstp dword [L]

    ; pick character based on brightness
    fld dword [L]
    fcomp dword [ZERO]
    fstsw ax
    sahf
    jae L_positive
    xor eax, eax
    jmp L_store
L_positive:
    fld dword [L]
    fistp dword [x_int]
    mov eax, [x_int]
    cmp eax, 11
    jle L_clamped
    mov eax, 11
L_clamped:
L_store:
    mov bl, [chars + eax]
    mov [output + esi], bl

skip_point:
    fld dword [phi]
    fadd dword [STEP_P]
    fstp dword [phi]
    jmp inner_loop

end_inner:
    fld dword [theta]
    fadd dword [STEP_T]
    fstp dword [theta]
    jmp outer_loop

end_outer:
    push 0
    push bytesWritten
    push 1760
    push output
    push dword [hConsole]
    call _WriteConsoleA@20

    push dword [SLEEP_MS]
    call _Sleep@4

    ; rotation angles for next frame
    fld dword [A]
    fadd dword [INC_A]
    fstp dword [A]
    fld dword [B]
    fadd dword [INC_B]
    fstp dword [B]

    jmp main_loop

    push 0
    call _ExitProcess@4
