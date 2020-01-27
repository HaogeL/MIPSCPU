//common
`define RSTENABLE   1'b1 //reset enable
`define RSTDISABLE  1'b0 //reset disable
`define CHIPDISABLE 1'b0 
`define CHIPENABLE  1'b1 

`define INSTVALID   1'b1 //valid instruction
`define INSTINVALID 1'b0 //invalid instruction

//instruction code
`define EXE_AND  6'b100100      //and
`define EXE_OR   6'b100101      //ori
`define EXE_XOR  6'b100110      //xor
`define EXE_NOR  6'b100111      //nor
`define EXE_ANDI 6'b001100      //andi
`define EXE_ORI  6'b001101      //ori
`define EXE_XORI 6'b001110      //xori
`define EXE_LUI  6'b001111      //lui

`define EXE_SLL  6'b000000      //sll
`define EXE_SLLV 6'b000100     //sllv
`define EXE_SRL  6'b000010      //srl 
`define EXE_SRLV 6'b000110     //srlv
`define EXE_SRA  6'b000011      //sra 
`define EXE_SRAV 6'b000111     //srav
`define EXE_SYNC 6'b001111     //sync
`define EXE_PREF 6'b110011     //pref

`define EXE_MOVZ 6'b001010     //MOVZ
`define EXE_MOVN 6'b001011     //MOVN
`define EXE_MFHI 6'b010000     //MFHI
`define EXE_MFLO 6'b010010     //MFLO
`define EXE_MTHI 6'b010001     //MTHI
`define EXE_MTLO 6'b010011     //MTLO

`define EXE_SLT  6'b101010		//SLT
`define EXE_SLTU  6'b101011		//SLTU
`define EXE_SLTI  6'b001010		//SLTI
`define EXE_SLTIU  6'b001011  //SLTIU
`define EXE_ADD  6'b100000		//ADD
`define EXE_ADDU  6'b100001		//ADDU
`define EXE_SUB  6'b100010		//SUB
`define EXE_SUBU  6'b100011		//SUBU 
`define EXE_ADDI  6'b001000		//ADDI 
`define EXE_ADDIU  6'b001001	//ADDIU
`define EXE_CLZ  6'b100000		//CLZ
`define EXE_CLO  6'b100001		//CLO
`define EXE_MULT  6'b011000		//MULT  
`define EXE_MULTU  6'b011001	//MULTU
`define EXE_MUL  6'b000010		//MUL
`define EXE_SPECIAL2_INST 6'b011100 //special2

`define EXE_MADD  6'b000000 
`define EXE_MADDU 6'b000001 
`define EXE_MSUB  6'b000100 
`define EXE_MSUBU 6'b000101 
`define EXE_DIV   6'b011010
`define EXE_DIVU  6'b011011

`define EXE_NOP 6'b000000  	     //nop
`define SSNOP 32'b00000000000000000000000001000000 //SSNOP

`define EXE_SPECIAL_INST 6'b000000  //special

//ALU width
`define ALUOPBUS       7:0 //ALU operation(aluop) width
`define ALUSELBUS       2:0 //ALU sel(alusel) width
//ALU operation
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   
`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111
`define EXE_NOP_OP 8'b00000000

`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011
`define EXE_RES_MOVE 3'b011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001

`define EXE_MADD_OP  8'b10100110
`define EXE_MADDU_OP  8'b10101000
`define EXE_MSUB_OP  8'b10101010
`define EXE_MSUBU_OP  8'b10101011

`define EXE_DIV_OP   8'b00011010
`define EXE_DIVU_OP  8'b00011011
//ALU sel
`define EXE_RES_LOGIC  3'b001
`define EXE_RES_NOP    3'b000
`define EXE_RES_SHIFT  3'b010
`define EXE_RES_ARITHMETIC 3'b100
`define EXE_RES_MUL 3'b101
//Instruction ROM related
`define INSTADDRBUS 31:0 //ROM address bus
`define INSTBUS     31:0 //ROM data bus


//general purpose register related
`define REGADDRBUS  4:0  //Regfile address bus
`define REGBUS      31:0 //Regfile data bus
`define REGWIDTH    32   //general purpose (gp) register width
`define REGNUM      32   //#. gp registers

`define WRITEENABLE  1'b1
`define WRITEDISABLE 1'b0
`define READENABLE   1'b1
`define READDISABLE  1'b0


//execution unit related
