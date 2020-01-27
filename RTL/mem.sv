`include "define.sv"
module mem(
  input logic               clk      ,
  input logic               rst      ,

  //result of mem access
  input logic[`REGADDRBUS]  i_mem_waddr,
  input logic               i_mem_we   ,
  input logic[`REGBUS]      i_mem_wdata,
  //#hi,low related
  input  logic              i_mem_whi,
  input  logic              i_mem_wlo,
  input  logic[`REGBUS]     i_mem_hi ,
  input  logic[`REGBUS]     i_mem_lo ,

  //signal to write back
  output logic[`REGADDRBUS] o_wb_waddr ,
  output logic              o_wb_we    ,
  output logic[`REGBUS]     o_wb_wdata ,
  //#hi,low related
  output logic              o_whi   ,
  output logic              o_wlo   ,
  output logic[`REGBUS]     o_hi    ,
  output logic[`REGBUS]     o_lo    
);
  always_ff@(posedge clk or posedge rst) begin
    if (rst == 1'b1) begin;
      o_wb_waddr<= '0;
      o_wb_we   <= '0;
      o_wb_wdata<= '0;
      o_whi     <= '0; 
      o_wlo     <= '0;
      o_hi      <= '0;
      o_lo      <= '0;
    end else begin
      o_wb_waddr<= i_mem_waddr;
      o_wb_we   <= i_mem_we   ;
      o_wb_wdata<= i_mem_wdata;

      o_whi   <= i_mem_whi ; 
      o_wlo   <= i_mem_wlo ;
      o_hi    <= i_mem_hi  ;
      o_lo    <= i_mem_lo  ;
    end
  end
endmodule: mem
