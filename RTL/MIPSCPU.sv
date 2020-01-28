`include "define.sv"
module MIPSCPU(
  input  logic clk                      ,
  input  logic rst                      ,

  input  logic [`REGBUS]      i_rom_data, //connected
  output logic [`INSTADDRBUS] o_rom_addr, //connected
  output logic                o_rom_ce    //connected
);

  //pc_reg_i0
  logic [`INSTADDRBUS] o_pc__pc_reg_i0;
  assign o_rom_addr = o_pc__pc_reg_i0;

  //if_id_i0
  logic [`INSTADDRBUS] o_id_pc__if_id_i0;
  logic [`INSTBUS]     o_id_inst__if_id_i0;

  //decode_i0
  logic                o_reg1_read__decode_i0 ;  
  logic                o_reg2_read__decode_i0 ;  
  logic [`REGADDRBUS]  o_reg1_addr__decode_i0 ;  
  logic [`REGADDRBUS]  o_reg2_addr__decode_i0 ;  
  logic [`ALUOPBUS]    o_aluop__decode_i0     ;
  logic [`ALUSELBUS]   o_alusel__decode_i0    ;
  logic [`REGBUS]      o_reg1__decode_i0      ;
  logic [`REGBUS]      o_reg2__decode_i0      ;
  logic [`REGADDRBUS]  o_waddr__decode_i0        ;
  logic                o_we__decode_i0      ;
  logic                o_stall__decode_i0     ;

  //gprfile_i0
  logic [`REGBUS]     o_rdata1__gprfile_i0    ; 
  logic [`REGBUS]     o_rdata2__gprfile_i0    ; 

  //exec_i0
  logic              o_whi__exec_i0           ;      
  logic              o_wlo__exec_i0           ;      
  logic[`REGBUS]     o_hi__exec_i0            ;      
  logic[`REGBUS]     o_lo__exec_i0            ;      
  logic[`REGADDRBUS] o_waddr__exec_i0         ;      
  logic              o_we__exec_i0            ;      
  logic[`REGBUS]     o_wdata__exec_i0         ;      
  logic[`REGADDRBUS] o_backward_waddr__exec_i0;      
  logic              o_backward_we__exec_i0   ;      
  logic[`REGBUS]     o_backward_wdata__exec_i0;      
  logic              o_stall__exec_i0         ;

  //mem_i0
  logic[`REGADDRBUS] o_wb_waddr__mem_i0      ;
  logic              o_wb_we__mem_i0         ;
  logic[`REGBUS]     o_wb_wdata__mem_i0      ;
  logic[`REGADDRBUS] o_backward_waddr__mem_i0;
  logic              o_backward_we__mem_i0   ;
  logic[`REGBUS]     o_backward_wdata__mem_i0;
  logic              o_backward_whi__mem_i0  ;
  logic              o_backward_wlo__mem_i0  ;
  logic[`REGBUS]     o_backward_hi__mem_i0   ;
  logic[`REGBUS]     o_backward_lo__mem_i0   ;
  logic              o_whi__mem_i0           ;
  logic              o_wlo__mem_i0           ;
  logic[`REGBUS]     o_hi__mem_i0            ;
  logic[`REGBUS]     o_lo__mem_i0            ;

  //hilo_reg_i0
  logic[`REGBUS]     o_hi__hilo_reg_i0;
  logic[`REGBUS]     o_lo__hilo_reg_i0;
  
  //stall_ctrl_i0
  logic o_stall_pc__stall_ctrl_i0    ;
  logic o_stall_if__stall_ctrl_i0    ;
  logic o_stall_decode__stall_ctrl_i0;

  pc_reg pc_reg_i0(
    .clk      (clk                      ),   
    .rst      (rst                      ),
    .i_stall  (o_stall_pc__stall_ctrl_i0), 
    .o_pc     (o_pc__pc_reg_i0          ),
    .o_ce     (o_rom_ce                 )
  );

  if_id if_id_i0(
    .clk      (clk                      ),
    .rst      (rst                      ),
    .i_if_pc  (o_pc__pc_reg_i0          ), 
    .i_if_inst(i_rom_data               ), 
    .o_id_pc  (o_id_pc__if_id_i0        ), 
    .o_id_inst(o_id_inst__if_id_i0      ), 
    .i_stall  (o_stall_if__stall_ctrl_i0) //not_connected
  );
  decode decode_i0(
    .clk                 (clk                          ),
    .rst                 (rst                          ),
    .i_stall             (o_stall_decode__stall_ctrl_i0),
    .i_pc                (o_id_pc__if_id_i0            ), 
    .i_inst              (o_id_inst__if_id_i0          ),
    .i_reg1_data         (o_rdata1__gprfile_i0         ),
    .i_reg2_data         (o_rdata2__gprfile_i0         ),

    .i_exe_wd            (o_backward_waddr__exec_i0    ),
    .i_exe_wreg          (o_backward_we__exec_i0       ),
    .i_exe_wdata         (o_backward_wdata__exec_i0    ),
  
    .i_mem_waddr         (o_backward_waddr__mem_i0     ),
    .i_mem_we            (o_backward_we__mem_i0        ),
    .i_mem_wdata         (o_backward_wdata__mem_i0     ),
  
    .o_reg1_read         (o_reg1_read__decode_i0       ),
    .o_reg2_read         (o_reg2_read__decode_i0       ),
    .o_reg1_addr         (o_reg1_addr__decode_i0       ),
    .o_reg2_addr         (o_reg2_addr__decode_i0       ),
    .o_aluop             (o_aluop__decode_i0           ),
    .o_alusel            (o_alusel__decode_i0          ),
    .o_reg1              (o_reg1__decode_i0            ),
    .o_reg2              (o_reg2__decode_i0            ),
    .o_waddr             (o_waddr__decode_i0           ),
    .o_we                (o_we__decode_i0              ),       
    .o_stall             (o_stall__decode_i0           ) 
  );
  gprfile gprfile_i0(
    .clk     (clk                   ),
    .rst     (rst                   ),
    .i_we    (o_wb_we__mem_i0       ),
    .i_waddr (o_wb_waddr__mem_i0    ), 
    .i_wdata (o_wb_wdata__mem_i0    ), 
    .i_re1   (o_reg1_read__decode_i0), 
    .i_raddr1(o_reg1_addr__decode_i0), 
    .o_rdata1(o_rdata1__gprfile_i0  ), 
    .i_re2   (o_reg2_read__decode_i0), 
    .i_raddr2(o_reg2_addr__decode_i0), 
    .o_rdata2(o_rdata2__gprfile_i0  ) 
  );
  exec exec_i0(
    .clk             (clk                      ),
    .rst             (rst                      ),
    .i_aluop         (o_aluop__decode_i0       ),
    .i_alusel        (o_alusel__decode_i0      ),
    .i_reg1          (o_reg1__decode_i0        ),
    .i_reg2          (o_reg2__decode_i0        ),
    .i_waddr         (o_waddr__decode_i0       ),
    .i_we            (o_we__decode_i0          ),
    .i_hi            (o_hi__hilo_reg_i0        ),
    .i_lo            (o_lo__hilo_reg_i0        ),
    .i_mem_whi       (o_backward_whi__mem_i0   ),
    .i_mem_wlo       (o_backward_wlo__mem_i0   ),
    .i_mem_hi        (o_backward_hi__mem_i0    ),
    .i_mem_lo        (o_backward_lo__mem_i0    ),
    .i_wb_whi        (o_whi__mem_i0            ),
    .i_wb_wlo        (o_wlo__mem_i0            ),
    .i_wb_hi         (o_hi__mem_i0             ),
    .i_wb_lo         (o_lo__mem_i0             ),
    .o_whi           (o_whi__exec_i0           ),
    .o_wlo           (o_wlo__exec_i0           ),
    .o_hi            (o_hi__exec_i0            ),
    .o_lo            (o_lo__exec_i0            ),
    .o_waddr         (o_waddr__exec_i0         ),
    .o_we            (o_we__exec_i0            ),
    .o_wdata         (o_wdata__exec_i0         ),
    .o_backward_waddr(o_backward_waddr__exec_i0),
    .o_backward_we   (o_backward_we__exec_i0   ),
    .o_backward_wdata(o_backward_wdata__exec_i0),
    .o_stall         (o_stall__exec_i0         )
  );
  mem mem_i0(
    .clk             (clk                     ),
    .rst             (rst                     ),
    .i_mem_waddr     (o_waddr__exec_i0        ),
    .i_mem_we        (o_we__exec_i0           ),
    .i_mem_wdata     (o_wdata__exec_i0        ),
    .i_mem_whi       (o_whi__exec_i0          ),
    .i_mem_wlo       (o_wlo__exec_i0          ),
    .i_mem_hi        (o_hi__exec_i0           ),
    .i_mem_lo        (o_lo__exec_i0           ),
    .o_backward_waddr(o_backward_waddr__mem_i0),
    .o_backward_we   (o_backward_we__mem_i0   ),
    .o_backward_wdata(o_backward_wdata__mem_i0),
    .o_wb_waddr      (o_wb_waddr__mem_i0      ),
    .o_wb_we         (o_wb_we__mem_i0         ),
    .o_wb_wdata      (o_wb_wdata__mem_i0      ),
    .o_backward_whi  (o_backward_whi__mem_i0  ),
    .o_backward_wlo  (o_backward_wlo__mem_i0  ),
    .o_backward_hi   (o_backward_hi__mem_i0   ),
    .o_backward_lo   (o_backward_lo__mem_i0   ),
    .o_whi           (o_whi__mem_i0           ),
    .o_wlo           (o_wlo__mem_i0           ),
    .o_hi            (o_hi__mem_i0            ),
    .o_lo            (o_lo__mem_i0            )
  );
  hilo_reg hilo_reg_i0(
    .clk     (clk              ),
    .rst     (rst              ),
    .i_we_hi (o_whi__mem_i0    ),
    .i_we_lo (o_wlo__mem_i0    ),
    .i_hi    (o_hi__mem_i0     ),
    .i_lo    (o_lo__mem_i0     ),
    .o_hi    (o_hi__hilo_reg_i0),
    .o_lo    (o_lo__hilo_reg_i0)
  );
  stall_ctrl stall_ctrl_i0(
    .i_stallreg_from_id(o_stall__decode_i0           ), 
    .i_stallreg_from_ex(o_stall__exec_i0             ), 
    .o_stall_pc        (o_stall_pc__stall_ctrl_i0    ),
    .o_stall_if        (o_stall_if__stall_ctrl_i0    ),
    .o_stall_decode    (o_stall_decode__stall_ctrl_i0)
  );
endmodule: MIPSCPU
