`include "define.sv"
module if_id (
  input  logic                clk      ,
  input  logic                rst      ,
  input  logic [`INSTADDRBUS] i_if_pc  , //pc from TB
  input  logic [`INSTBUS]     i_if_inst, //instruction from TB

  output logic [`INSTADDRBUS] o_id_pc  , //register if_pc and pass to next stage
  output logic [`INSTBUS]     o_id_inst,  //register if_inst, then pass to nxt stage
  
  input  logic                i_stall
);
always_ff@(posedge clk or posedge rst)begin
  if (rst == `RSTENABLE) begin
    o_id_pc   <= '0;
    o_id_inst <= '0;
  end else if(i_stall==1'b0)begin
    o_id_pc   <= i_if_pc  ;
    o_id_inst <= i_if_inst;
  end
end
endmodule: if_id
