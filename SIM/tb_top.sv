`timescale 1ns/1ps
`include "define.sv"
module tb_top();
localparam CLK_PERIOD = 10;
logic clk;
logic rst;
initial begin
  clk = 1'b0;
  rst = `RSTENABLE;
  fork
    forever #CLK_PERIOD clk = ~clk;
    #200 rst = `RSTDISABLE;
  join
end

logic               re  ;
logic[`INSTADDRBUS] addr;
logic[`INSTBUS]     inst;

inst_rom 
#(
  .NUM_OF_INST_IN_ROM (7)//fill it with the number of instructions
)
inst_rom_i0
(
  .re  (re  ),
  .addr(addr),
  .inst(inst)
);

MIPSCPU MIPSCPU_i0
(
  .clk        (clk ),
  .rst        (rst ),
  .i_rom_data (inst),
  .o_rom_addr (addr),
  .o_rom_ce   (re  )
);
endmodule: tb_top
