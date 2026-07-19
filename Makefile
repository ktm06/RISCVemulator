PROG ?= assembler/test1.txt
OUT ?= assembler/results.bin

build:
	cd assembler && dune build 
	cd emulator && clang components.c main.c

run: 
	./assembler/_build/default/assembler.exe $(PROG) $(OUT)
	./emulator/a.out $(OUT)

buildrun:
	cd assembler && dune build 
	cd emulator && clang components.c main.c
	./assembler/_build/default/assembler.exe $(PROG) $(OUT)
	./emulator/a.out $(OUT)

