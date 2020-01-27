`include "define.sv"
module pc_reg(
   input  logic                 clk   ,
   input  logic                 rst   ,
   input  logic                i_stall, 
   output logic [`INSTADDRBUS] o_pc   , 
   output logic                o_ce //enable
);

always_ff@(posedge clk or posedge rst) begin
  if (rst == `RSTENABLE) begin
    o_ce <= `CHIPDISABLE;
  end else begin
    o_ce <= `CHIPENABLE;
  end
end

always_ff@(posedge clk or posedge rst) begin
  if (rst == `RSTENABLE) begin
    o_pc <= '0;
  end else if (o_ce == `CHIPDISABLE)begin
    o_pc <= '0;
  end else if (i_stall == 1'b0) begin
    o_pc <= o_pc + 4;
  end
end
endmodule: pc_reg
