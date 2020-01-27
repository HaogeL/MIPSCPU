//verification only
`include "define.sv"
module inst_rom
#(
  parameter NUM_OF_INST_IN_ROM = 2
)
(
  input  logic               re  ,
  input  logic[`INSTADDRBUS] addr,
  output logic[`INSTBUS]     inst
);

logic [`INSTBUS] inst_mem [NUM_OF_INST_IN_ROM];

initial begin
  $readmemh("inst_rom.data", inst_mem);
end

always_comb begin
  if (re == `CHIPDISABLE)
    inst = '0;
  else
    //address divided by 4, because of byte addressing
    inst = inst_mem[addr[$clog2(NUM_OF_INST_IN_ROM)+1:2]];
    
end
endmodule: inst_rom
