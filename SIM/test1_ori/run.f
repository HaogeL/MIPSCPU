-timescale 1ns/1ps
-access +rwc
-xprop F
-gui

#include path
-incdir ../../

#RTL
../../RTL/decode.sv
../../RTL/exec.sv
../../RTL/gprfile.sv
../../RTL/hilo_reg.sv
../../RTL/if_id.sv
../../RTL/mem.sv
../../RTL/pc_reg.sv
../../RTL/stall_ctrl.sv

../../RTL/MIPSCPU.sv

#TB
../inst_rom.sv
../tb_top.sv
