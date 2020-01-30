# MIPS32 Rel1 classic Pipe-stage RTL implementation

## Component Overview
![image](https://github.com/HaogeL/MIPSCPU/raw/master/DOC/img/DiagramOverview.png)
## Supported Instructions so far
![image](https://github.com/HaogeL/MIPSCPU/raw/master/DOC/img/InstructionDecodePath.jpg)
![image](https://github.com/HaogeL/MIPSCPU/raw/master/DOC/img/InstructionDecodeTable.jpg)
## Tool-chain
MIPS compiler, linker, etc. are provided in the **ToolChain** directory. They are used to compile program to machine code when in simulation&test, which is demonstrated in the example below.
To compile [AssemblySourceCode](https://github.com/HaogeL/MIPSCPU/blob/master/SIM/test1_ori/AssemblySourceCode),
```sh
$ cd /SIM/test1_ori
$ ../../ToolChain/mips-sde-elf-as -mips32 AssemblySourceCode -o object.o
```
Check **start address** and **size** of text section of _object.o_
```sh
$ ../../ToolChain/mips-sde-elf-readelf -S object.o
Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00000000 000034 000010 00  AX  0   0  4
  [ 2] .data             PROGBITS        00000000 000044 000000 00  WA  0   0  1
  [ 3] .bss              NOBITS          00000000 000044 000000 00  WA  0   0  1
  [ 4] .reginfo          MIPS_REGINFO    00000000 000044 000018 18      0   0  4
  [ 5] .pdr              PROGBITS        00000000 00005c 000000 00      0   0  4
  [ 6] .shstrtab         STRTAB          00000000 00005c 00003a 00      0   0  1
  [ 7] .symtab           SYMTAB          00000000 000200 000070 10      8   6  4
  [ 8] .strtab           STRTAB          00000000 000270 000008 00      0   0  1
```
We read start address(0x34) and size (0x10) of text section from the table above and, implicitly, the end address is 0x43, which means the machine code is stored in the ELF file from address 0x34 to 0x43. Then, open _object.o_ in HEX mode, manually copy data from address 0x34 to 0x43 and paste the content to a text file named **inst_rom.data** in a manner of 4Bytes a line. Testbench will read data from this file line by line and each line corresponds to a single instruction (32bits).
## Test and Simulation
RTL is not verified on block level. Preliminarily, a stupid verification method is to feed machine codes to RTL and manually monitor general purpose register values in simulations. Assembly program and corresponding machine code in HEX are provided in each tests directory [tests](https://github.com/HaogeL/MIPSCPU/tree/master/SIM). Compilation and simulation are simulator-depended and as an example, run.f file for cadence/XCELIUM simulator is in each [tests](https://github.com/HaogeL/MIPSCPU/tree/master/SIM) directory.
For cadence simulator, change directory into a test directory and run
```sh
$ xrun(irun) -f run.f
```
Test bench diagram is shown below  
![image](https://github.com/HaogeL/MIPSCPU/raw/master/DOC/img/tb_topDiagram.png)
## Reference
https://e.jd.com/30344807.html  
https://www.mips.com/products/architectures/mips32-2/
