#include <stdint.h>
#define mem_size (1024 * 1024) // 1MB memory allocation


// CPU structure: 32 registers, pc starting @ 0, 1MB memory
struct CPU {
    uint32_t registers[32];
    uint32_t pc;
    uint8_t memory[mem_size];
};

struct CPU reset(void) {
    // 0 initialize struct
    struct CPU cpu = {0};
    return cpu;
}

uint8_t byte_read(struct CPU *cpu, uint32_t addr) {
    if (addr < mem_size) {
        return cpu->memory[addr];
    }
    // fail condition
    return 0;
}

void byte_write(struct CPU *cpu, uint32_t addr, uint8_t value) {
    if (addr < mem_size) {
        cpu->memory[addr] = value;
    }
}

// 4 byte per word in little endian style

uint32_t word_read(struct CPU *cpu, uint32_t addr) {
    uint32_t word = 0;
    // bit shift & OR
    if (addr + 3 < mem_size) {
        // prevent overflow
        word |= (uint32_t)byte_read(cpu, addr+3) << 24;
        word |= (uint32_t)byte_read(cpu, addr+2) << 16;
        word |= (uint32_t)byte_read(cpu, addr+1) << 8;
        word |= (uint32_t)byte_read(cpu, addr);
    }
    return word;
}

void word_write(struct CPU *cpu, uint32_t addr, uint32_t value) {
    if (addr + 3 < mem_size) {
        // mask with last 8 bits
        byte_write(cpu, addr, value & 0xFF);
        byte_write(cpu, addr+1, (value >> 8) & 0xFF);
        byte_write(cpu, addr+2, (value >> 16) & 0xFF);
        byte_write(cpu, addr+3, (value >> 24) & 0xFF);
    }
}

// cpu fetch execute cycle

void step(struct CPU *cpu) {
    uint32_t instruction = word_read(cpu, cpu->pc);
    cpu->pc += 4;
    // mask to extract opcode
    uint32_t opcode = instruction & 0x7F;
    switch (opcode) {
        case 0b1100111: //JALR
            break;
        case 0b0000011: //LOAD
            break; 
        case 0b0010011: //ITYPE
            break;
        case 0b0100011: //STYPE
            break;
        case 0b1100011: //SBTYPE
            break;
        case 0b0110111: //UTYPE1
            break;
        case 0b0010111: //UTYPE2
            break;
        case 0b1101111: //JTYPE
            break;
        case 0b0110011: //RTYPE
            break;
        default:
        break;
    }
}



uint32_t exec_r(struct CPU *cpu, uint32_t instruction) {
    uint32_t rd = instruction >> 7 & 0x1F;
    uint32_t funct3 = instruction >> 12 & 0x07;
    uint32_t rs1= instruction >> 15 & 0x1F;
    uint32_t rs2 = instruction >> 20 & 0x1F;
    uint32_t funct7 = instruction >> 25 & 0x7F;
}