`include "define.sv"


module id(
   input  logic [`INSTADDRBUS] pc_i          ,
   input  logic [`INSTBUS]     inst_i        ,

   //data from regfile/gp_register
   input  logic [`REGBUS]      reg1_data_i   ,
   input  logic [`REGBUS]      reg2_data_i   ,

   //exe write register feedback to id
   input logic[`REGADDRBUS] exe_wd_i     ,
   input logic              exe_wreg_i   ,
   input logic[`REGBUS]     exe_wdata_i  ,

   //mem write register feedback to id
   input logic[`REGADDRBUS] mem_wd_i     ,
   input logic              mem_wreg_i   ,
   input logic[`REGBUS]     mem_wdata_i  ,

   //read-cmd to regfile/gp_register
   output logic                reg1_read_o   ,
   output logic                reg2_read_o   ,
   output logic [`REGADDRBUS]  reg1_addr_o   ,
   output logic [`REGADDRBUS]  reg2_addr_o   ,

   //result to exec phase
   output logic [`ALUOPBUS]    aluop_o  ,//ALU
   output logic [`ALUSELBUS]   alusel_o ,//ALU sel
   output logic [`REGBUS]      reg1_o   ,//operand1 to ALU(rs by default)
   output logic [`REGBUS]      reg2_o   ,//operand2 to ALU(rt by default)
   output logic [`REGADDRBUS]  wd_o     ,// regfile address
   output logic                wreg_o   ,// write regfile

   output logic                stallreg_id
);
//tmporary assignment
assign stallreg_id = 1'b0;//so far encode finish in 1CC

//operation type
logic[5:0] op  ;
//logic[4:0] op2 ;
logic[5:0] op3 ;
//logic[4:0] op4 ;
assign op  = inst_i[31:26];
//assign op2 = inst_i[10:6 ];
assign op3 = inst_i[5:0  ];
//assign op4 = inst_i[20:16];

logic[`REGBUS] imm; //instant number

logic instvalid; //to indicate if a instruction valid of not

//decode instruction
always_comb begin:decode_main
   aluop_o     =  `EXE_NOP_OP;
   alusel_o    =  `EXE_RES_NOP;
   wd_o        =  inst_i[15:11];
   wreg_o      =  `WRITEDISABLE;
   instvalid   =  `INSTINVALID;//?only for debug?
   reg1_read_o =  `READDISABLE;
   reg2_read_o =  `READDISABLE;
   //By default, read the first operand on read-port1 of regfile
   reg1_addr_o =  inst_i[25:21];
   //By default, read the second operand on read-port2 of regfile
   reg2_addr_o =  inst_i[20:16];//
   imm         =  'b0;    
/*
see opcode_decode_path.ppt
*/
   //start to decode only when inst_i is not '0
   if(inst_i!='b0)begin 
     if (op == 'b0) begin
       if (inst_i[25:21]=='b0) begin
         case(op3)
           `EXE_SLL: begin
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             imm[4:0]    = inst_i[10:6];//assign as to imm
             aluop_o     = `EXE_SLL_OP ;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_SRL: begin
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             imm[4:0]    = inst_i[10:6];//assign as to imm
             aluop_o     = `EXE_SRL_OP ;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_SRA: begin
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             imm[4:0]    = inst_i[10:6];//assign as to imm
             aluop_o     = `EXE_SRA_OP ;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_SYNC: begin
             //reg2_read_o = `READENABLE; //[TODO]why read rt for SYNC?
             aluop_o     = `EXE_NOP_OP ;
             alusel_o    = `EXE_RES_NOP;
             instvalid   = `INSTVALID;
           end
           `EXE_MFHI: begin
             wreg_o    = `WRITEENABLE ; //write rd
             aluop_o   = `EXE_MFHI_OP ;
             alusel_o  = `EXE_RES_MOVE;
             instvalid =`INSTVALID    ;
           end
           `EXE_MFLO:begin //same as the `EXE_MFLO branch
             wreg_o    = `WRITEENABLE ; //write rd
             aluop_o   = `EXE_MFHI_OP ;
             alusel_o  = `EXE_RES_MOVE;
             instvalid =`INSTVALID    ;
           end
           default: begin
           end
         endcase
       end else begin
         case(op3)
           `EXE_AND: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_AND_OP;
             alusel_o    = `EXE_RES_LOGIC;
             instvalid   = `INSTVALID;
           end
           `EXE_OR: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_OR_OP;
             alusel_o    = `EXE_RES_LOGIC;
             instvalid   = `INSTVALID;
           end
           `EXE_XOR: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_XOR_OP;
             alusel_o    = `EXE_RES_LOGIC;
             instvalid   = `INSTVALID;
           end
           `EXE_NOR: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_NOR_OP;
             alusel_o    = `EXE_RES_LOGIC;
             instvalid   = `INSTVALID;
           end
           `EXE_SLLV: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_SLL_OP;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_SRLV: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_SRL_OP;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_SRAV: begin
             reg1_read_o = `READENABLE ;//read from rs
             reg2_read_o = `READENABLE ;//read from rt
             wreg_o      = `WRITEENABLE;//write to rd
             aluop_o     = `EXE_SRA_OP;
             alusel_o    = `EXE_RES_SHIFT;
             instvalid   = `INSTVALID;
           end
           `EXE_MOVZ:begin
             reg1_read_o = `READENABLE  ;
             reg2_read_o = `READENABLE  ;
             if(reg2_o == 'b0)
               wreg_o    = `WRITEENABLE ;
             else
               wreg_o    = `WRITEDISABLE;
             aluop_o     = `EXE_MOVZ_OP ;
             alusel_o    = `EXE_RES_MOVE;
             instvalid   = `INSTVALID   ;
           end
           `EXE_MOVN:begin
             reg1_read_o = `READENABLE  ;
             reg2_read_o = `READENABLE  ;
             if(reg2_o != 'b0)
               wreg_o    = `WRITEENABLE ;
             else
               wreg_o    = `WRITEDISABLE;
             aluop_o     = `EXE_MOVN_OP ;
             alusel_o    = `EXE_RES_MOVE;
             instvalid   = `INSTVALID   ;
           end
           `EXE_MTHI:begin
             reg1_read_o = `READENABLE  ; //read rs
             wreg_o      = `WRITEDISABLE; //no write to GPR
             aluop_o     = `EXE_MTHI_OP ;
             instvalid   = `INSTVALID   ;
           end
           `EXE_MTLO:begin
             reg1_read_o = `READENABLE  ; //read rs
             wreg_o      = `WRITEDISABLE; //no write to GPR
             aluop_o     = `EXE_MTLO_OP ;
             instvalid   = `INSTVALID   ;
           end
           `EXE_ADD:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_ADD_OP          ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_ADDU:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_ADDU_OP         ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_SUB:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_SUB_OP         ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_SUBU:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_SUBU_OP         ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_SLT:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_SLT_OP          ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_SLTU:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             wreg_o      = `WRITEENABLE         ;//write rd
             aluop_o     = `EXE_SLTU_OP         ;
             alusel_o    = `EXE_RES_ARITHMETIC  ;
             instvalid   = `INSTVALID           ;
           end
           `EXE_MULT:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             aluop_o     = `EXE_MULT_OP         ;
             instvalid   = `INSTVALID           ;
             //alusel_o is NOP see EX unit
           end
           `EXE_MULTU:begin
             reg1_read_o = `READENABLE          ;//read rs
             reg2_read_o = `READENABLE          ;//read rt
             aluop_o     = `EXE_MULTU_OP        ;
             instvalid   = `INSTVALID           ;
             //alusel_o is NOP see EX unit
           end
           `EXE_DIV:begin
             reg1_read_o = `READENABLE         ;//read rs
             reg2_read_o = `READENABLE         ;//read rt
             aluop_o     = `EXE_DIV_OP          ;
             instvalid   = `INSTVALID           ;
             //alusel_o is NOP see EX unit
           end
           `EXE_DIVU:begin
             reg1_read_o = `READENABLE         ;//read rs
             reg2_read_o = `READENABLE         ;//read rt
             aluop_o     = `EXE_DIVU_OP         ;
             instvalid   = `INSTVALID           ;
             //alusel_o is NOP see EX unit
           end
           default: begin
           end
           
         endcase
       end
     end else begin
       case(op)
         `EXE_ANDI: begin
           reg1_read_o = `READENABLE ;//read from rs
           imm[15:0]   = inst_i[15:0];
           wreg_o      = `WRITEENABLE;//write to rt
           wd_o        = reg2_addr_o ;//write to rt
           aluop_o     = `EXE_AND_OP;
           alusel_o    = `EXE_RES_LOGIC;
           instvalid   = `INSTVALID;
         end
         `EXE_ORI: begin
           reg1_read_o = `READENABLE ;//read from rs
           imm[15:0]   = inst_i[15:0];
           wreg_o      = `WRITEENABLE;//write to rt
           wd_o        = reg2_addr_o ;//write to rt
           aluop_o     = `EXE_OR_OP;
           alusel_o    = `EXE_RES_LOGIC;
           instvalid   = `INSTVALID;
         end
         `EXE_XORI: begin
           reg1_read_o = `READENABLE ;//read from rs
           imm[15:0]   = inst_i[15:0];
           wreg_o      = `WRITEENABLE;//write to rt
           wd_o        = reg2_addr_o ;//write to rt
           aluop_o     = `EXE_XOR_OP;
           alusel_o    = `EXE_RES_LOGIC;
           instvalid   = `INSTVALID;
         end
         `EXE_LUI: begin
           reg1_read_o = 1'b1; //operand1 is read from $1 which is '0
           imm[31:16]  = inst_i[15:0];//operand2 is immediate <<16
           wreg_o      = `WRITEENABLE;//write to rt
           wd_o        = reg2_addr_o ;//write to rt
           aluop_o     = `EXE_OR_OP;
           alusel_o    = `EXE_RES_LOGIC;
           instvalid   = `INSTVALID;
         end
         `EXE_PREF: begin
           aluop_o    =  `EXE_NOP_OP ;
           alusel_o   =  `EXE_RES_NOP;
           instvalid  =  `INSTVALID  ; 
         end
         `EXE_ADDI:begin
           wreg_o      =  `WRITEENABLE                    ;
           wd_o        =  reg2_addr_o                     ;//write rt
           reg1_read_o =  `READENABLE                     ;//read rs
           aluop_o     =  `EXE_ADDI_OP                    ;
           alusel_o    =  `EXE_RES_ARITHMETIC             ;
           imm         =  {{16{inst_i[15]}}, inst_i[15:0]};
           instvalid   =  `INSTVALID                      ; 
         end
         `EXE_ADDIU:begin
           wreg_o      =  `WRITEENABLE                    ;
           wd_o        =  reg2_addr_o                     ;//write rt
           reg1_read_o =  `READENABLE                     ;//read rs
           aluop_o     =  `EXE_ADDIU_OP                   ;
           alusel_o    =  `EXE_RES_ARITHMETIC             ;
           imm         =  {{16{inst_i[15]}}, inst_i[15:0]};
           instvalid   =  `INSTVALID                      ; 
         end
         `EXE_SLTI:begin
           wreg_o      =  `WRITEENABLE                    ;
           wd_o        =  reg2_addr_o                     ;//write rt
           reg1_read_o =  `READENABLE                     ;//read rs
           aluop_o     =  `EXE_SLTI_OP                    ;
           alusel_o    =  `EXE_RES_ARITHMETIC             ;
           imm         =  {{16{inst_i[15]}}, inst_i[15:0]};
           instvalid   =  `INSTVALID                      ; 
         end
         `EXE_SLTIU:begin
           wreg_o      =  `WRITEENABLE                    ;
           wd_o        =  reg2_addr_o                     ;//write rt
           reg1_read_o =  `READENABLE                     ;//read rs
           aluop_o     =  `EXE_SLTIU_OP                   ;
           alusel_o    =  `EXE_RES_ARITHMETIC             ;
           imm         =  {{16{inst_i[15]}}, inst_i[15:0]};
           instvalid   =  `INSTVALID                      ; 
         end
         `EXE_SPECIAL2_INST:begin
           case(op3)
             `EXE_CLZ:begin
               wreg_o      =  `WRITEENABLE                    ;//write rd
               reg1_read_o =  `READENABLE                     ;//read rs
               aluop_o     =  `EXE_CLZ_OP                     ;
               alusel_o    =  `EXE_RES_ARITHMETIC             ;
               instvalid   =  `INSTVALID                      ; 
             end
             `EXE_CLO:begin
               wreg_o      =  `WRITEENABLE                    ;//write rd
               reg1_read_o =  `READENABLE                     ;//read rs
               aluop_o     =  `EXE_CLO_OP                     ;
               alusel_o    =  `EXE_RES_ARITHMETIC             ;
               instvalid   =  `INSTVALID                      ; 
             end
             `EXE_MUL:begin
               wreg_o      =  `WRITEENABLE                    ;//write rd
               reg1_read_o =  `READENABLE                     ;//read rs
               reg2_read_o =  `READENABLE                     ;//read rt 
               aluop_o     =  `EXE_MUL_OP                     ;
               alusel_o    =  `EXE_RES_ARITHMETIC             ;
               instvalid   =  `INSTVALID                      ; 
             end
             `EXE_MADD:begin
               wreg_o      = `WRITEDISABLE  ;
               reg1_read_o = `READENABLE    ;
               reg2_read_o = `READENABLE    ;
               aluop_o     =  `EXE_MADD_OP       ;
               alusel_o    =  `EXE_RES_ARITHMETIC;
               instvalid   =  `INSTVALID         ; 
             end
             `EXE_MADDU:begin
               wreg_o      = `WRITEDISABLE  ;
               reg1_read_o = `READENABLE    ;
               reg2_read_o = `READENABLE    ;
               aluop_o     =  `EXE_MADDU_OP      ;
               alusel_o    =  `EXE_RES_ARITHMETIC;
               instvalid   =  `INSTVALID         ; 
             end
             `EXE_MSUB:begin
               wreg_o      = `WRITEDISABLE  ;
               reg1_read_o = `READENABLE    ;
               reg2_read_o = `READENABLE    ;
               aluop_o     =  `EXE_MSUB_OP       ;
               alusel_o    =  `EXE_RES_ARITHMETIC;
               instvalid   =  `INSTVALID         ; 
             end
             `EXE_MSUBU:begin
               wreg_o      = `WRITEDISABLE  ;
               reg1_read_o = `READENABLE    ;
               reg2_read_o = `READENABLE    ;
               aluop_o     =  `EXE_MSUBU_OP      ;
               alusel_o    =  `EXE_RES_ARITHMETIC;
               instvalid   =  `INSTVALID         ; 
             end
           endcase
         end
         default: begin
         end
       endcase
     end
   end
end:decode_main

// sending operand1
always_comb begin
  //if read regfile, then set reg1_o to get data from regfile, reg1_data_i
  //read regfile is comb logic
  if(reg1_read_o == `READENABLE) begin
    if((exe_wreg_i == `WRITEENABLE) && (exe_wd_i==reg1_addr_o))begin
      reg1_o = exe_wdata_i;
    end else if((mem_wreg_i == `WRITEENABLE) && (mem_wd_i==reg1_addr_o))begin
      reg1_o = mem_wdata_i;
    end else
      reg1_o = reg1_data_i;
  //otherwise set it to immediate num
  end else 
    reg1_o = imm;
end

// sending operand2
always_comb begin
  //if read regfile, then set reg2_o to get data from regfile, reg2_data_i
  //read regfile is comb logic
  if(reg2_read_o == `READENABLE) begin
    if ((exe_wreg_i == `WRITEENABLE) && (exe_wd_i==reg2_addr_o)) begin
      reg2_o = exe_wdata_i;
    end else if((mem_wreg_i == `WRITEENABLE) && (mem_wd_i==reg2_addr_o)) begin
      reg2_o = mem_wdata_i;
    end else
      reg2_o = reg2_data_i;
  end
  //otherwise set it to immediate num
  else 
    reg2_o = imm;
end
endmodule: id


module id_ex (
   input logic               clk        ,
   input logic               rst        ,
   //from decode
   //#operation type
   input logic [`ALUOPBUS]   id_aluop   ,
   //#operation sub-type
   input logic [`ALUSELBUS]  id_alusel  ,
   //#operand 1 and operand 2
   input logic [`REGBUS]     id_reg1    ,
   input logic [`REGBUS]     id_reg2    ,
   //#indicate if to write regfile or not
   input logic               id_wreg    ,
   //#regfile address to write
   input logic [`REGADDRBUS] id_wd      ,

   input logic               stall      ,

   //output to execution unit
   //#ALU sel/type to execution unit
   output logic [`ALUSELBUS] ex_alusel,
   //#ALU operation to execution unit
   output logic [`ALUOPBUS]  ex_aluop ,
   //#ALU operand1
   output logic [`REGBUS]    ex_reg1  ,
   //#ALU operand2
   output logic [`REGBUS]    ex_reg2  ,
   //#indicate if to write regfile or not
   output logic              ex_wreg  ,
   //#regfile address to write
   output logic [`REGADDRBUS]ex_wd   
);
always_ff@(posedge clk or posedge rst) begin:ff
   if (rst == 1'b1) begin
     ex_alusel<='b0;
     ex_aluop <='b0; 
     ex_reg1  <='b0;
     ex_reg2  <='b0;
     ex_wreg  <='b0;
     ex_wd    <='b0;
   end else begin
     if (stall==1'b0) begin
       ex_alusel<=id_alusel;
       ex_aluop <=id_aluop ; 
       ex_reg1  <=id_reg1  ;
       ex_reg2  <=id_reg2  ;
       ex_wreg  <=id_wreg  ;
       ex_wd    <=id_wd    ;
     end
   end
end: ff

endmodule: id_ex


module decode(
  input  logic                clk           ,
  input  logic                rst           ,

  input  logic                i_stall       ,

  input  logic [`INSTADDRBUS] i_pc          , //get pc value only for debug
  input  logic [`INSTBUS]     i_inst        ,

  //data from regfile/gp_register
  input  logic [`REGBUS]      i_reg1_data   ,
  input  logic [`REGBUS]      i_reg2_data   ,

  //exe write register feedback/forward to id
  input logic[`REGADDRBUS]    i_exe_wd     ,
  input logic                 i_exe_wreg   ,
  input logic[`REGBUS]        i_exe_wdata  ,

  //mem write register feedback/forward to id
  input logic[`REGADDRBUS]    i_mem_waddr  ,
  input logic                 i_mem_we     ,
  input logic[`REGBUS]        i_mem_wdata  ,

  //read-cmd to regfile/gp_register, valid in the current CC
  output logic                o_reg1_read   ,
  output logic                o_reg2_read   ,
  output logic [`REGADDRBUS]  o_reg1_addr   ,
  output logic [`REGADDRBUS]  o_reg2_addr   ,

  //result to exec phase, valid next CC
  output logic [`ALUOPBUS]    o_aluop  ,//ALU
  output logic [`ALUSELBUS]   o_alusel ,//ALU sel
  output logic [`REGBUS]      o_reg1   ,//operand1 to ALU(rs by default)
  output logic [`REGBUS]      o_reg2   ,//operand2 to ALU(rt by default)
  output logic [`REGADDRBUS]  o_waddr  ,// regfile address
  output logic                o_we     ,// write regfile

  //valid in the current CC
  output logic                o_stall
);

  //result to exec phase
  logic [`ALUOPBUS]    tmp_aluop  ;//ALU
  logic [`ALUSELBUS]   tmp_alusel ;//ALU sel
  logic [`REGBUS]      tmp_reg1   ;//operand1 to ALU(rs by default)
  logic [`REGBUS]      tmp_reg2   ;//operand2 to ALU(rt by default)
  logic [`REGADDRBUS]  tmp_wd     ;// regfile address
  logic                tmp_wreg   ;// write regfile


  id id_i0(
    .pc_i        (i_pc             ),
    .inst_i      (i_inst           ),
    .reg1_data_i (i_reg1_data      ),
    .reg2_data_i (i_reg2_data      ),
    .exe_wd_i    (i_exe_wd         ),
    .exe_wreg_i  (i_exe_wreg       ),
    .exe_wdata_i (i_exe_wdata      ),
    .mem_wd_i    (i_mem_waddr      ),
    .mem_wreg_i  (i_mem_we         ),
    .mem_wdata_i (i_mem_wdata      ),
    .reg1_read_o (o_reg1_read      ), 
    .reg2_read_o (o_reg2_read      ), 
    .reg1_addr_o (o_reg1_addr      ), 
    .reg2_addr_o (o_reg2_addr      ), 
    .aluop_o     (tmp_aluop          ), 
    .alusel_o    (tmp_alusel         ), 
    .reg1_o      (tmp_reg1           ), 
    .reg2_o      (tmp_reg2           ), 
    .wd_o        (tmp_wd             ), 
    .wreg_o      (tmp_wreg           ),
    .stallreg_id (o_stall            )
  );

id_ex id_ex_i0(
  .clk      (clk      ),
  .rst      (rst      ),
  .id_aluop (tmp_aluop  ),  
  .id_alusel(tmp_alusel ),  
  .id_reg1  (tmp_reg1   ),  
  .id_reg2  (tmp_reg2   ),  
  .id_wreg  (tmp_wreg   ),    
  .id_wd    (tmp_wd     ),
  .stall    (i_stall  ),
  .ex_aluop (o_aluop  ), 
  .ex_alusel(o_alusel ),
  .ex_reg1  (o_reg1   ), 
  .ex_reg2  (o_reg2   ), 
  .ex_wreg  (o_we     ), 
  .ex_wd    (o_waddr  ) 
);


endmodule: decode
