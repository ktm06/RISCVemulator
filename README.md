**Overview**
This is a RISC-V CPU emulator containing the base RV32IM + Zicsr extension instructions. 

Currently, it runs both hand written programs and compiled C binaries.

To compile C code to .bin file: 
1. Have RISC-V GNU Compiler Toolchain (on linux/wsl:  ```sudo apt install gcc-riscv64-unknown-elf```)
2. Create a filename.c file in src

Run: 
```
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib  -o tests/bins/filename.elf startend.s tests/src/filename.c

riscv64-unknown-elf-objcopy -O binary tests/bins/filename.elf tests/bins/filename.bin
```
**Resources used:**
https://fraserinnovations.com/risc-v/risc-v-instruction-set-explanation/

https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html
