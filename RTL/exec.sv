`include "define.sv"
module ex(
  input  logic              clk      ,
  input  logic              rst      ,

  input  logic[`ALUOPBUS]   aluop_i  ,
  input  logic[`ALUSELBUS]  alusel_i ,
  input  logic[`REGBUS]     reg1_i   ,
  input  logic[`REGBUS]     reg2_i   ,
  input  logic[`REGADDRBUS] wd_i     ,
  input  logic              wreg_i   ,
  
  //hi, lo related
  //#value from hilo_reg
  input  logic[`REGBUS]     hi_i       ,
  input  logic[`REGBUS]     lo_i       ,
  //#mem feedback to exe_unit
  input  logic              mem_whi_i  ,
  input  logic              mem_wlo_i  ,
  input  logic[`REGBUS]     mem_hi_i   ,
  input  logic[`REGBUS]     mem_lo_i   ,
  //#wb feedback to exe_unit
  input  logic              wb_whi_i   ,
  input  logic              wb_wlo_i   ,
  input  logic[`REGBUS]     wb_hi_i    ,
  input  logic[`REGBUS]     wb_lo_i    ,
  //#write hilo_reg
  output logic              whi_o      ,
  output logic              wlo_o      ,
  output logic[`REGBUS]     hi_o       ,
  output logic[`REGBUS]     lo_o       ,
  
  output logic[`REGADDRBUS] wd_o       ,
  output logic              wreg_o     ,
  output logic[`REGBUS]     wdata_o    ,
  output logic              stallreg_ex

);
  logic [`REGBUS] logicout;
  logic [`REGBUS] shiftout;
  logic [`REGBUS] moveout;
  logic [`REGBUS] arithmeticout;
  //if there are feedback from mem or wb, use the feedback value
  //otherwise, use input values
  logic[`REGBUS] update_hi;
  logic[`REGBUS] update_lo;
  
  logic cnt_2CC;
  logic [63:0] multi_tmp;
  
  //determine whether to write regfile or not
  logic arithmetic_dont_write_GPR;
  //solve data dependence of hi and lo register
  always_comb begin
    if(mem_whi_i == `WRITEENABLE)
      update_hi = mem_hi_i;
    else if(wb_whi_i == `WRITEENABLE)
      update_hi = wb_hi_i ;
    else
      update_hi = hi_i    ;
  end
  
  always_comb begin
    if(mem_wlo_i == `WRITEENABLE)
      update_lo = mem_lo_i;
    else if(wb_wlo_i == `WRITEENABLE)
      update_lo = wb_lo_i ;
    else
      update_lo = lo_i    ;
  end
  
  always_comb begin: move_aluop
    case(aluop_i)
      `EXE_MFHI_OP:begin
        moveout = update_hi;
      end
      `EXE_MFLO_OP:begin
        moveout = update_lo;
      end
      `EXE_MOVZ_OP:begin
        moveout = reg1_i;
      end
      `EXE_MOVN_OP:begin
        moveout = reg1_i;
      end
      default:begin
        moveout = 'b0;
      end
    endcase
  end: move_aluop
  
  always_comb begin: logic_aluop
    case(aluop_i)
      `EXE_OR_OP: begin
        logicout = reg1_i | reg2_i;
      end
      `EXE_AND_OP: begin
        logicout = reg1_i & reg2_i;
      end
      `EXE_NOR_OP: begin
        logicout = ~(reg1_i | reg2_i);
      end
      `EXE_XOR_OP: begin
        logicout = reg1_i ^ reg2_i;
      end
      default: begin
        logicout = '0;
      end
    endcase
  end: logic_aluop
  
  always_comb begin: shift_aluop
    case(aluop_i)
      `EXE_SLL_OP: begin
        shiftout = reg2_i << reg1_i[4:0];
      end
      `EXE_SRL_OP: begin
        shiftout = reg2_i >> reg1_i[4:0];
      end
      `EXE_SRA_OP: begin
        shiftout = ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]}))|
        (reg2_i>>reg1_i[4:0]);
      end
      default: begin
        shiftout = '0;
      end
    endcase
  end: shift_aluop
  
  always_comb begin: arithmetic_aluop
    //33bits sign-extended operands
    automatic logic signed[`REGWIDTH:0] oprand1_signed_extended_33tmp=
    {reg1_i[`REGWIDTH-1],reg1_i};
    automatic logic signed[`REGWIDTH:0] oprand2_signed_extended_33tmp=
    {reg2_i[`REGWIDTH-1],reg2_i};
    automatic logic signed[`REGWIDTH:0] tmp_32;//33bits
    //64bits sign-extended operands
    automatic logic signed[`REGWIDTH*2-1:0] oprand1_signed_extended_64tmp=
    {{`REGWIDTH{reg1_i[`REGWIDTH-1]}}, reg1_i};
    automatic logic signed[`REGWIDTH*2-1:0] oprand2_signed_extended_64tmp=
    {{`REGWIDTH{reg2_i[`REGWIDTH-1]}}, reg2_i};
    automatic logic signed[`REGWIDTH*2-1:0] tmp_64;//64bits
  
  
    automatic logic unsigned [`REGBUS] reg1_unsigned=reg1_i;//32bits
    automatic logic unsigned [`REGBUS] reg2_unsigned=reg2_i;//32bits
  
    arithmetic_dont_write_GPR = 1'b0;
    arithmeticout = 'b0;
    case(aluop_i)
      `EXE_ADD_OP, `EXE_ADDI_OP: begin
        tmp_32 = oprand1_signed_extended_33tmp+oprand2_signed_extended_33tmp;
        if (tmp_32[`REGWIDTH] == tmp_32[`REGWIDTH-1]) begin
          arithmeticout = tmp_32[`REGWIDTH-1:0];
        end else begin
          arithmetic_dont_write_GPR = 1'b1;
        end
      end
      `EXE_ADDU_OP, `EXE_ADDIU_OP: begin
        tmp_32 = oprand1_signed_extended_33tmp+oprand2_signed_extended_33tmp;
        arithmeticout = tmp_32[`REGWIDTH-1:0];
      end
      `EXE_SUB_OP: begin
        tmp_32 = oprand1_signed_extended_33tmp-oprand2_signed_extended_33tmp;
        if (tmp_32[`REGWIDTH] == tmp_32[`REGWIDTH-1]) begin
          arithmeticout = tmp_32[`REGWIDTH-1:0];
        end else begin
          arithmetic_dont_write_GPR = 1'b1;
        end
      end
      `EXE_SUBU_OP: begin
        tmp_32 = oprand1_signed_extended_33tmp-oprand2_signed_extended_33tmp;
        arithmeticout = tmp_32[`REGWIDTH-1:0];
      end
      `EXE_SLT_OP, `EXE_SLTI_OP: begin
        if(oprand1_signed_extended_33tmp<oprand2_signed_extended_33tmp)
          arithmeticout={{31'b0},1'b1};
        else
          arithmeticout='0;
        tmp_32 = 'b0;
      end
      `EXE_SLTU_OP, `EXE_SLTIU_OP: begin
        if(reg1_unsigned<reg2_unsigned)
          arithmeticout={{31'b0},1'b1};
        else
          arithmeticout='0;
        tmp_32 = 'b0;
      end
      `EXE_CLO_OP: begin
        for(int unsigned i=0; i<`REGWIDTH; i=i+1) begin
          if(reg1_i[31-i]==1'b1)
            tmp_32 = tmp_32+1;
          else
            break;
        end
        arithmeticout = tmp_32;
      end
      `EXE_CLZ_OP: begin
        for(int unsigned i=0; i<`REGWIDTH; i=i+1) begin
          if(reg1_i[31-i]==1'b0)
            tmp_32 = tmp_32+1;
          else
            break;
        end
        arithmeticout = tmp_32;
      end
      `EXE_MUL_OP: begin
        tmp_64=oprand1_signed_extended_64tmp*oprand2_signed_extended_64tmp;
        arithmeticout = tmp_64[`REGWIDTH-1:0];
        tmp_32 = 'b0;
      end
      default: begin
        tmp_32 = 'b0;
      end
    endcase
  end: arithmetic_aluop
  
  always_comb begin:write_hilo_reg
    automatic logic signed[`REGWIDTH*2-1:0] tmp_64;//64bits
    automatic logic signed[`REGWIDTH*2-1:0] oprand1_signed_extended_64tmp=
    {{`REGWIDTH{reg1_i[`REGWIDTH-1]}}, reg1_i};
    automatic logic signed[`REGWIDTH*2-1:0] oprand2_signed_extended_64tmp=
    {{`REGWIDTH{reg2_i[`REGWIDTH-1]}}, reg2_i};
    automatic logic unsigned[`REGWIDTH*2-1:0] tmp_64unsigned;//64bits
    tmp_64 = '0;
    tmp_64unsigned = '0;
    stallreg_ex = 1'b0;
    case(aluop_i)
      `EXE_MTHI_OP: begin
        whi_o = `WRITEENABLE ;
        wlo_o = `WRITEDISABLE;
        hi_o  = reg1_i       ;
        lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
      end
      `EXE_MTLO_OP: begin
        wlo_o = `WRITEENABLE ;
        whi_o = `WRITEDISABLE;
        lo_o  = reg1_i       ;
        hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
      end
      `EXE_MULT_OP: begin
        tmp_64=oprand1_signed_extended_64tmp*oprand2_signed_extended_64tmp;
        wlo_o = `WRITEENABLE  ;
        whi_o = `WRITEENABLE  ;
        hi_o  = tmp_64[`REGWIDTH*2-1:`REGWIDTH];
        lo_o  = tmp_64[`REGWIDTH-1:0];
      end
      `EXE_MULTU_OP: begin
        //the bit size of the right-hand expression of an assignment depends on itself and the size of
        //logic array is treated as unsigned by default
        tmp_64unsigned=reg1_i*reg2_i;
        wlo_o = `WRITEENABLE  ;
        whi_o = `WRITEENABLE  ;
        hi_o  = tmp_64unsigned[`REGWIDTH*2-1:`REGWIDTH];
        lo_o  = tmp_64unsigned[`REGWIDTH-1:0];
      end
      `EXE_MADD_OP: begin
        if(cnt_2CC==1'b1)begin
          tmp_64 = $signed({update_hi, update_lo})+$signed(multi_tmp);
          wlo_o = `WRITEENABLE  ;
          whi_o = `WRITEENABLE  ;
          hi_o  = tmp_64[`REGWIDTH*2-1:`REGWIDTH];
          lo_o  = tmp_64[`REGWIDTH-1:0];
        end else begin //(cnt_2CC==1'b0)
          wlo_o = `WRITEDISABLE;
          whi_o = `WRITEDISABLE;
          lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
          hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
          stallreg_ex = 1'b1;
        end
      end
      `EXE_MADDU_OP: begin
        if(cnt_2CC==1'b1)begin
          tmp_64 = {update_hi, update_lo}+multi_tmp;
          wlo_o = `WRITEENABLE  ;
          whi_o = `WRITEENABLE  ;
          hi_o  = tmp_64[`REGWIDTH*2-1:`REGWIDTH];
          lo_o  = tmp_64[`REGWIDTH-1:0];
        end else begin //(cnt_2CC==1'b0)
          wlo_o = `WRITEDISABLE;
          whi_o = `WRITEDISABLE;
          lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
          hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
          stallreg_ex = 1'b1;
        end
      end
      `EXE_MSUB_OP: begin
        if(cnt_2CC==1'b1)begin
          tmp_64 = $signed({update_hi, update_lo})-$signed(multi_tmp);
          wlo_o = `WRITEENABLE  ;
          whi_o = `WRITEENABLE  ;
          hi_o  = tmp_64[`REGWIDTH*2-1:`REGWIDTH];
          lo_o  = tmp_64[`REGWIDTH-1:0];
        end else begin //(cnt_2CC==1'b0)
          wlo_o = `WRITEDISABLE;
          whi_o = `WRITEDISABLE;
          lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
          hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
          stallreg_ex = 1'b1;
        end
      end
      `EXE_MSUBU_OP: begin
        if(cnt_2CC==1'b1)begin
          tmp_64 = {update_hi, update_lo}-multi_tmp;
          wlo_o = `WRITEENABLE  ;
          whi_o = `WRITEENABLE  ;
          hi_o  = tmp_64[`REGWIDTH*2-1:`REGWIDTH];
          lo_o  = tmp_64[`REGWIDTH-1:0];
        end else begin //(cnt_2CC==1'b0)
          wlo_o = `WRITEDISABLE;
          whi_o = `WRITEDISABLE;
          lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
          hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
          stallreg_ex = 1'b1;
        end
      end
      `EXE_DIV_OP: begin
        wlo_o = `WRITEENABLE  ;
        whi_o = `WRITEENABLE  ;
        lo_o  = $signed(reg1_i)/$signed(reg2_i);
        hi_o  = $signed(reg1_i)%$signed(reg2_i);
      end
      `EXE_DIVU_OP: begin
        wlo_o = `WRITEENABLE  ;
        whi_o = `WRITEENABLE  ;
        lo_o  = reg1_i/reg2_i;
        hi_o  = reg1_i%reg2_i;
      end
      default: begin
        wlo_o = `WRITEDISABLE;
        whi_o = `WRITEDISABLE;
        lo_o  = '0           ; //doesn't matter what the lo_o is, wlo_o is disabled
        hi_o  = '0           ; //doesn't matter what the hi_o is, whi_o is disabled
      end
    endcase
  end: write_hilo_reg
  
  always_comb begin: write_GPR
    wd_o = wd_i;
    wreg_o = wreg_i;
    case(alusel_i)
      `EXE_RES_LOGIC: begin
        wdata_o = logicout;
      end
      `EXE_RES_SHIFT: begin
        wdata_o = shiftout;
      end
      `EXE_RES_MOVE: begin
        wdata_o = moveout;
      end
      `EXE_RES_ARITHMETIC:begin
        wdata_o = arithmeticout;
        if(arithmetic_dont_write_GPR == 1'b1)
          wreg_o = 1'b0;
      end
      default: begin
        wdata_o = '0;
      end
    endcase
  end: write_GPR
  
  always_ff@(posedge clk or posedge rst) begin: multiCC_exe
    if(rst == `RSTENABLE) begin
      cnt_2CC     <= 1'b0;
      multi_tmp   <= '0  ;
    end else if((aluop_i==`EXE_MADD_OP) || (aluop_i==`EXE_MADDU_OP) 
    || (aluop_i==`EXE_MSUB_OP) || (aluop_i==`EXE_MSUBU_OP))begin
      if (cnt_2CC == 1'b0) begin //first CC of multiCC op
        if((aluop_i==`EXE_MADD_OP)||(aluop_i==`EXE_MSUB_OP))begin
          multi_tmp<=$signed(reg1_i)*$signed(reg2_i); 
        end else if((aluop_i==`EXE_MADDU_OP)||(aluop_i==`EXE_MSUBU_OP))begin
          multi_tmp<=reg1_i*reg2_i; 
        end
        cnt_2CC <= 1'b1;
      end else begin // cnt_2CC == 1'b1, second CC of multiCC op
        cnt_2CC     <= 1'b0;
        multi_tmp   <= '0  ;
      end
    end
  end: multiCC_exe

endmodule: ex

module ex_mem(
  input  logic              clk       ,
  input  logic              rst       ,
  //regfile address to write
  input  logic[`REGADDRBUS] ex_wd     ,
  input  logic              ex_wreg   ,
  //data to write to regfile
  input  logic[`REGBUS]     ex_wdata  ,

  //hi, lo related
  input  logic              ex_whi_i  ,
  input  logic              ex_wlo_i  ,
  input  logic[`REGBUS]     ex_hi_i   ,
  input  logic[`REGBUS]     ex_lo_i   ,

  output logic[`REGADDRBUS] mem_wd    ,
  output logic              mem_wreg  ,
  output logic[`REGBUS]     mem_wdata ,

  output logic              mem_whi ,
  output logic              mem_wlo ,
  output logic[`REGBUS]     mem_hi  ,
  output logic[`REGBUS]     mem_lo  
);
  always_ff@(posedge clk or posedge rst) begin
    if(rst == `RSTENABLE) begin
      mem_wd   <='0;
      mem_wreg <='0;
      mem_wdata<='0;
      mem_whi  <='0;
      mem_wlo  <='0;
      mem_hi   <='0;
      mem_lo   <='0;
    end else begin
      mem_wd   <=ex_wd   ;
      mem_wreg <=ex_wreg ;
      mem_wdata<=ex_wdata;
      mem_whi  <=ex_whi_i;
      mem_wlo  <=ex_wlo_i;
      mem_hi   <=ex_hi_i ;
      mem_lo   <=ex_lo_i ;
    end
  end
endmodule: ex_mem

module exec (
  input  logic              clk      ,
  input  logic              rst      ,

  input  logic[`ALUOPBUS]   i_aluop  ,
  input  logic[`ALUSELBUS]  i_alusel ,
  input  logic[`REGBUS]     i_reg1   ,
  input  logic[`REGBUS]     i_reg2   ,
  input  logic[`REGADDRBUS] i_waddr  ,
  input  logic              i_we     ,
  
  //hi, lo related
  //#value from hilo_reg
  input  logic[`REGBUS]     i_hi       ,
  input  logic[`REGBUS]     i_lo       ,
  //#mem feedback to exe_unit
  input  logic              i_self_whi  ,
  input  logic              i_self_wlo  ,
  input  logic[`REGBUS]     i_self_hi   ,
  input  logic[`REGBUS]     i_self_lo   ,
  //#wb feedback to exe_unit
  input  logic              i_mem_whi   ,
  input  logic              i_mem_wlo   ,
  input  logic[`REGBUS]     i_mem_hi    ,
  input  logic[`REGBUS]     i_mem_lo    ,
  //#write hilo_reg
  output logic              o_whi      ,
  output logic              o_wlo      ,
  output logic[`REGBUS]     o_hi       ,
  output logic[`REGBUS]     o_lo       ,
  
  output logic[`REGADDRBUS] o_waddr    ,
  output logic              o_we       ,
  output logic[`REGBUS]     o_wdata    ,
  output logic              o_stall
);
  logic              tmp_whi      ;
  logic              tmp_wlo      ;
  logic[`REGBUS]     tmp_hi       ;
  logic[`REGBUS]     tmp_lo       ;
  
  logic[`REGADDRBUS] tmp_wd       ;
  logic              tmp_wreg     ;
  logic[`REGBUS]     tmp_wdata    ;
  ex ex_i0(
  .clk        (clk          ),
  .rst        (rst          ),
  .aluop_i    (i_aluop      ),
  .alusel_i   (i_alusel     ),
  .reg1_i     (i_reg1       ),
  .reg2_i     (i_reg2       ),
  .wd_i       (i_waddr      ),
  .wreg_i     (i_we         ),
  .hi_i       (i_hi         ),
  .lo_i       (i_lo         ),
  .mem_whi_i  (i_self_whi    ),
  .mem_wlo_i  (i_self_wlo    ),
  .mem_hi_i   (i_self_hi     ),
  .mem_lo_i   (i_self_lo     ),
  .wb_whi_i   (i_mem_whi     ),
  .wb_wlo_i   (i_mem_wlo     ),
  .wb_hi_i    (i_mem_hi      ),
  .wb_lo_i    (i_mem_lo      ),
  .whi_o      (tmp_whi      ),
  .wlo_o      (tmp_wlo      ),
  .hi_o       (tmp_hi       ),
  .lo_o       (tmp_lo       ),
  .wd_o       (tmp_wd       ),
  .wreg_o     (tmp_wreg     ),
  .wdata_o    (tmp_wdata    ),
  .stallreg_ex(o_stall      )
  );
  
  ex_mem ex_mem_i0(
    .clk      (clk       ),  
    .rst      (rst       ),
    .ex_wd    (tmp_wd    ),
    .ex_wreg  (tmp_wreg  ),
    .ex_wdata (tmp_wdata ),
    .ex_whi_i (tmp_whi   ),
    .ex_wlo_i (tmp_wlo   ),
    .ex_hi_i  (tmp_hi    ),
    .ex_lo_i  (tmp_lo    ),
    .mem_wd   (o_waddr    ), 
    .mem_wreg (o_we    ), 
    .mem_wdata(o_wdata ),
    .mem_whi  (o_whi   ),
    .mem_wlo  (o_wlo   ),
    .mem_hi   (o_hi    ),
    .mem_lo   (o_lo    )
  );
endmodule: exec

