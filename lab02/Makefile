lab2.o: lab2.s

	clang-12 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab2.s -c -o lab2.o -g

lab2.x: lab2.o

	ld.lld-12 lab2.o -o lab2.x -g

