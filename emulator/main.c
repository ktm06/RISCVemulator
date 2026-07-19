#include "cpu.h"
#include <stdio.h>
#include <string.h>

int main(int argc, char* argv[]) {
    static struct CPU cpu;
    char* infile;

    if (argc > 1) {
        infile = argv[1];
    } else {
        infile = "../assembler/results.bin";
    }

    reset(&cpu);

    loadfile(&cpu, infile);
    run(&cpu);
    regview(&cpu);
    return 0;
}