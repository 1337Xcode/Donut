# 3D Rotating Donut

`donut.asm` when compiled and run in console(80x22) renders a 3D spinning donut using ASCII characters. Each frame calculates the 3D surface of a donut, applies lighting, and displays it as text characters based on brightness.

## Requirements

- Windows
- NASM assembler
- MinGW GCC compiler

## Build and Run

1. **Assemble the source code:**
    ```bash
    nasm.exe -f win32 donut.asm -o donut.obj
    ```

2. **Link the object file to create the executable:**
    ```bash
    gcc.exe donut.obj -o donut.exe -lkernel32 -luser32
    ```

3. **Run the executable:**
    ```bash
    donut.exe
    ```

## How it works

1. Generates 3D points on a donut surface using parametric equations
2. Rotates the donut in 3D space
3. Projects 3D coordinates to 2D screen positions
4. Calculates lighting based on surface normals
5. Maps brightness to ASCII characters (`.,-~:;=!*#$@`)
6. Uses Z-buffering for proper depth handling

## Math

Torus parametric equations:

x = (R + r*cos(θ)) * cos(φ)
y = (R + r*cos(θ)) * sin(φ)
z = r * sin(θ)

- **R**: Distance from the center of the tube to the center of the torus  
- **r**: Radius of the tube  
- **θ, φ**: Angles that parametrize the surface

## Credits

Based on Andy Sloane's donut.c - [donut math explanation](https://www.a1k0n.net/2011/07/20/donut-math.html)
