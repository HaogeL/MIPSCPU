`include "define.sv"
module stall_ctrl(
  input  logic i_stallreg_from_id, //stall cmd from id stage
  input  logic i_stallreg_from_ex, //stall cmd from ex stage
  output logic o_stall_pc        ,
  output logic o_stall_if        ,
  output logic o_stall_decode        
);
  always_comb begin
    if (i_stallreg_from_ex == 1'b1) begin
      o_stall_pc     = 1'b1;
      o_stall_if     = 1'b1;
      o_stall_decode = 1'b1;
    end else if (i_stallreg_from_id == 1'b1) begin
      o_stall_pc     = 1'b1;
      o_stall_if     = 1'b1;
      o_stall_decode = 1'b0;
    end else begin
      o_stall_pc     = 1'b0;
      o_stall_if     = 1'b0;
      o_stall_decode = 1'b0;
    end
  end
endmodule: stall_ctrl
