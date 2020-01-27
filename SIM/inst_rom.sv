//verification only
`include "define.sv"
module inst_rom
//#(
//  parameter NUM_OF_INST_IN_ROM = 2
//)
(
  input  logic               re  ,
  input  logic[`INSTADDRBUS] addr,
  output logic[`INSTBUS]     inst
);

//logic [`INSTBUS] inst_mem [NUM_OF_INST_IN_ROM];
logic [`INSTBUS] inst_mem [$];
logic [`INSTBUS] tmp;
integer  fd;

initial begin
  fd = $fopen("inst_rom.data", "r");
  if(fd) begin
    while(!$feof(fd)) begin
      $display($fscanf(fd, "%h", tmp));
      if($feof(fd)) break;
      inst_mem.push_back(tmp);
    end
  end else
    $error("cannot open instruction files");
  $fclose(fd);
end

always_comb begin
  if (re == `CHIPDISABLE)
    inst = '0;
  else
    //address divided by 4, because of byte addressing
    //inst = inst_mem[addr[$clog2(NUM_OF_INST_IN_ROM)+1:2]];
    inst = inst_mem[addr/4];
    
end
endmodule: inst_rom
