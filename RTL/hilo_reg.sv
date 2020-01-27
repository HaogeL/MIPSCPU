`include "define.sv"
module hilo_reg(
  input  logic          clk  ,
  input  logic          rst  ,
  //write port
  input  logic          i_we_hi,
  input  logic          i_we_lo,
  input  logic[`REGBUS] i_hi ,
  input  logic[`REGBUS] i_lo ,
  
  //read port
  output logic[`REGBUS] o_hi,
  output logic[`REGBUS] o_lo
);
  always_ff@(posedge clk or posedge rst) begin
    if(rst==`RSTENABLE)begin
      o_hi<='0;
      o_lo<='0;
    end else begin
      if(i_we_hi==`WRITEENABLE)begin
        o_hi<=i_hi;
      end
      if(i_we_lo==`WRITEENABLE)begin
        o_lo<=i_lo;
      end
    end
  end
endmodule: hilo_reg

