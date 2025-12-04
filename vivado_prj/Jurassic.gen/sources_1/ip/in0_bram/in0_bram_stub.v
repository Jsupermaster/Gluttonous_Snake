// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Mon Oct 27 19:28:54 2025
// Host        : Jonemaster-Mini running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/Study/FPT_2025/vivado_prj/Jurassic.gen/sources_1/ip/in0_bram/in0_bram_stub.v
// Design      : in0_bram
// Purpose     : Stub declaration of top-level module interface
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *)
module in0_bram(clka, wea, addra, dina, clkb, enb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[12:0],dina[31:0],clkb,enb,addrb[13:0],doutb[15:0]" */;
  input clka;
  input [0:0]wea;
  input [12:0]addra;
  input [31:0]dina;
  input clkb;
  input enb;
  input [13:0]addrb;
  output [15:0]doutb;
endmodule
