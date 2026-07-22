# Overview

This project combines a [RISC-V ISA](https://www.cse.iitd.ac.in/~srsarangi/archbook/chapters/riscv.pdf) assembler (written in OCaml) and a RISC-V CPU emulator (written in C), containing the base RV32IM + Zicsr extension instructions. 

On a high level, the assembler assembles a ```.txt``` file into binary format, and the emulator will take in that ```.bin``` file and replicates proper RISC-V CPU behavior. By default it will print out the final register states. With debug on, it will also print for each step.

We do not have to use the assembler to feed instruction to the CPU. We can also run binary-compiled C programs on the emulator using a bare-metal cross-compiler, or just pass our own list of [binary instructions](https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html). 

The project was verified using, hand-assembled programs (straight binary inputs), with compiled C programs (using gcc), and compiled assembly programs (using our Assembler). All cases returned expected results.

# Chapter Overview

[1. Assembler](#Assembler)

[2. Emulator](#Emulator)

[3. Installation](#Installation)

&nbsp;&nbsp;&nbsp;&nbsp;[a. Assembler Emulator Wrap-Around](#Assembler-Emulator-Wrap-Around)

&nbsp;&nbsp;&nbsp;&nbsp;[b. Emulating C Programs](#Emulating-C-Programs)

[4. Resources Used](#Resources-Used)

# Assembler
The assembler takes a ```.txt``` file of RISC-V assembly and produces a flat binary the emulator can run. It supports the base RV32IM instructions and uses a two-pass approach: the first pass scans the file and records each label's address into a symbol table, and the second pass encodes each instruction into its 32-bit machine word, resolving label references (for branches and jumps) against the symbol table built in the first pass. The two passes exist so that we can resolve labels that are referenced before they are defined.

Assembly follows standard RISC-V syntax. Labels end in a colon (loop:), comments start with #, and registers can be written as ABI names (t0, sp, a0). Branches and jumps target labels by name, and the assembler computes the offsets for us.

``
main:
    addi t0, zero, 5
    addi t1, zero, 10
    add t2, t0, t1
loop:
    add t2, t2, t1
    addi t1, t1, 1
    blt t1, t0, loop
    ecall
``

Currently, pseudo-instructions, such as ``mv`` are not supported.

# Emulator

The emulator replicates a CPU by executing instructions through the fetch-decode-exeucte loop:

1. Fetch the instruction located at program counter's address in memory

2. Decode the instruction via opcode and determine operation

3. Execute the intruction, and program counter points to the next instruction.

The CPU has 32 general-purpose 32-bit registers. We follow RISC-V convention by hardwiring x0 to 0 and setting x1 to the stack pointer. x10 is used as the main() function return value. We also have a separate, CSR bank, used by our Zicsr extension. 

RISC-V is a Von Neumann architecture, so our instruction and data live in the same memory. Our emulator contains 64KB of memory.

The emulator replicates a RISC-V CPU behaviorally. It is not pipelined or cycle-accurate. 

# Installation

For the entire project, I used the Windows Subsystem for Linux. To install on Windows, run:

```wsl --install```

All the instructions below are in Linux CLI commands.

## Assembler Emulator Wrap-Around
We use a Makefile to build and run both halves at once. This requires make (on linux/wsl: sudo apt install build-essential).
To build both the assembler and the emulator:

```make build```

To assemble a file and run it on the emulator:

```make buildrun PROG=assembler/test1.txt OUT=assembler/results.bin```

PROG is the assembly file to assemble and OUT is the binary to produce and run. Both have defaults, so a bare make buildrun uses ```assembler/test1.txt```. If we only want to run an already-built binary without recompiling the tools, we can use ```make run``` instead.

The assembler and emulator each take their input and output paths as arguments, so we can also run them individually without the Makefile.


## Emulating C Programs

To compile C code to .bin file: 
1. Have RISC-V GNU Compiler Toolchain (on linux/wsl:  ```sudo apt install gcc-riscv64-unknown-elf```)
2. Create a ```filename.c``` file in src

Run: 
```
riscv64-unknown-elf-gcc -march=rv32im -mabi=ilp32 -nostdlib  -o tests/bins/filename.elf startend.s tests/src/filename.c

riscv64-unknown-elf-objcopy -O binary tests/bins/filename.elf tests/bins/filename.bin
```

**Example:**
We have a minimal C program in ```test.c```: 

``` int main() { return 1; }```

and its binary counterpart is in ```test.bin```. Running this binary through our emulator outputs the following register states:

x0=0 x1=4 x2=65532 .... **x10=1** ... x29=0 x30=0 x31=0

In RISC-V architecture, register x10 is used as to hold the primary function return value (aka main). Since out program simply returns integer 1, our program successfully executed the binary counterpart of ```test.c```.

## Resources Used

https://fraserinnovations.com/risc-v/risc-v-instruction-set-explanation/

https://msyksphinz-self.github.io/riscv-isadoc/html/rvi.html

https://riscv-non-isa.github.io/riscv-elf-psabi-doc/

https://www.cse.iitd.ac.in/~srsarangi/archbook/chapters/riscv.pdf
