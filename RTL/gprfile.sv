`include "define.sv"
module gprfile(
  input logic               clk       ,
  input logic               rst       ,
  //write port
  input logic               i_we        ,
  input logic [`REGADDRBUS] i_waddr     , //write address
  input logic [`REGBUS]     i_wdata     , //write data

  //read port 1
  input logic               i_re1       , //read1 enable
  input logic [`REGADDRBUS] i_raddr1    , //read1 address
  output logic [`REGBUS]    o_rdata1    , //read1 data

  //read port 2
  input logic               i_re2       , //read2 enable
  input logic [`REGADDRBUS] i_raddr2    , //read2 address
  output logic [`REGBUS]    o_rdata2     //read2 data
);

//definition
logic [`REGBUS] regs[`REGNUM-1:0];

//write 1CC to write regs
always_ff@(posedge clk or posedge rst) begin: write
  if(rst == `RSTENABLE) begin
    regs <= '{default:0};
  end else begin
    //if we is enabled, write_addr is not 0, then write the gp_register
    //MIPS requires $0 is 0 and read-only
    if ((i_we == `WRITEENABLE) && (i_waddr!='b0))
      regs[i_waddr] <= i_wdata;
  end
end: write
//read1 
always_comb begin: read1 //data can be read out immediately
  if (i_re1 == `READENABLE) begin
    //if read and write the same address at the same time 
    //then just assignmen the wdata to rdata
    if ((i_we == `WRITEENABLE) && (i_waddr == i_raddr1)) 
      o_rdata1 <= i_wdata; 
    else 
      o_rdata1 <= regs[i_raddr1];
  end else
    o_rdata1 <= 'b0;
end: read1
//read2 
always_comb begin: read2 //data can be read out immediately
  if (i_re2 == `READENABLE) begin
    //if read and write the same address at the same time 
    //then just assignmen the wdata to rdata
    if ((i_we == `WRITEENABLE) && (i_waddr == i_raddr2)) 
      o_rdata2 <= i_wdata; 
    else 
      o_rdata2 <= regs[i_raddr2];
  end else
    o_rdata2 <= 'b0;
end: read2

endmodule: gprfile
