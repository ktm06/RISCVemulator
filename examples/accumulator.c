#include "../emulator/cpu.h"
#include <stdio.h>


// accumulator example: we prove blt functionality by making accumulator
// program will accumulate in x1, and count in x2
// every loop, x1 + x2 and x2++. we loop as long as x2 < x3 
// 
int main(void) {
    static struct CPU cpu;
    reset(&cpu);

    uint32_t program[] = {
        0x13 | (1<<7), //addi, rd=1, rs1=0, imm=0     
        0x13 | (2<<7) | (1<<20), //addi, rd =2, rs1=0, imm=1
        0x13 | (3<<7) | (100<<20), //addi rd=3 rs1=0 imm=100
        //loopstart
        0x33 | (1<<7) | (1<<15) | (2<<20), //add rd=1, rs1 = 1, rs2 = 1  
        0x13 | (2<<7) | (2<<15) | (1<<20), //addi, rd=2, rs1=2, imm=1
        0x63 | (4<<12) | (2<<15) | (3<<20) | (3<<10)|(1<<7)|(0x3F<<25)|(1<<31), // blt, rs1 =2, rs2 = 3, offset -8
        //loopend
        0x73, //ecall
        0xFFFFFFFF // sentinel
    };

    loadinstr(&cpu, program);
    run(&cpu);
    regview(&cpu);
    return 0;
}