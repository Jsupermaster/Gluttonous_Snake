// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Thu Oct 23 21:27:11 2025
// Host        : Jonemaster-Mini running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Study/FPT_2025/vivado_prj/Jurassic.gen/sources_1/ip/ram/ram_sim_netlist.v
// Design      : ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ram,blk_mem_gen_v8_4_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module ram
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;

  wire [9:0]addra;
  wire clka;
  wire [31:0]dina;
  wire [31:0]douta;
  wire ena;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_doutb_UNCONNECTED;
  wire [9:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [9:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "10" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     1.613139 mW" *) 
  (* C_FAMILY = "zynquplus" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "ram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "1024" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "1024" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  ram_blk_mem_gen_v8_4_5 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[31:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[9:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[9:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VHPlDkoDlWlBfBMvPBmGYmaek3s9hXXhjF28kllYPnaNm3TSnzzpXHWHc8Ye9/2L2yiQfJ1hTWou
Ia/zeQ8h9/dtr6QB5YkyW4wlb/LbMgXb+DGIXPSllNl0IMsRQIcQDbcQm1bO/nlhb+2pjxiuaQrl
DbvxoDwPs7z3LunRxsg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
lmIhoX8hXuc7tNV1sXY1K2/gXL7Y7Hq73qQF7+x03UWWTRd3uhGmVQtOMVbhIW+66UkWUHiD26zL
fzqGor8bgSNGpSFyS11k4TwLQT4OfAMGO8C9Qmmh4+VENBnpS9TW+wHzCv8oUwht7xYtYRZvOvYK
F3fMppz2sBkUd1lciw98ZE/UmNkhqBuMfIYF43j45DEJ55PBhOZNg91Ls4v3qBHyBAaYPFFoMry3
d5Fw1PZyFQSEOSSpwgyds2aN0g6oIwl7zm0LJrM9VDAOxBUE50hk+oHr4jj8J8UhHQJnlEHm1Idm
rvxKygNKRvfSpa90NYxZJFYgqnrMYg+19+9aZA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
VkyCjO2onoeZWEoYQ/4ue7X5mkHyTYVW9xjdoTsGS4GdP/Q64VaCZL/jr6R8DVDXPMnH7tRMrDpo
jpYBnyzSgOkfgqM+96ioC2fDyAaG4gYgGLmrBR6qK3/mxXwAZZX+GJ9R/eWXkc9h8xN+gsSSX6/M
jIQCgeT6q7PB4dWT6KY=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Iub91V+TnhVlZCSLu6iKmFjix71y6/l83OPTs8uewWvkE7WcqYxEKi9fonXEkzAtWzuKwEUqnOlN
VBsNJqPUdKcd22q523mrdt89mpdosWD+hvZdO7ELhJniY5u9h49FFkubpN2JiUTcIcKEYxVNlds4
wyvaYUqbPVH5v2ooJwDdimS4GVn9HerCOgPwfshvQDNlMTxLcYju4v8BHMc5Rub9Q/ihvpQU74v2
ouZ9XIwA+C6pBLwvaqS8jE7HXOokgqJilaX/W/t+KEgiFry/txRTMU9WMD7tCN7lcfjCydmS3Lq+
3u6Hsr0S8BwNjcaDpZDnBTygUJd4JSqREnk33w==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
U46EWFmKmpZGaWfyL+dokyQtJtaOYsa7HCW/+fdtw9/yHKTWFpmqKBZngBj5rPkNhtTDDCJkqsYj
tUXg1j4tgIBaCQn9B0q/aG+B3gPLrudp9hLL25mVbsfiTzdekiV2hJMmhuMoavKKPJHC6zyW7kZi
80er82OQy8h+Df/fe6TRjH9xEt3/b80tRKUMbxkLfnnkAyyf1KfOhB6/uyI4mwXuQR+DsAbzybKR
YtXpOiW72tGrXTFlzcwbHamWZefqsilVpBw6V5dh33vYKGx50xwWpj76maAkpQrOpB7zufeldJe4
W1UOEN84AZdRTLkVSxamWo/wp8nP9fiGS/ItRw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qczgIJYpE/SzErzK7eWJBGcDFEzDLm8cKbwJbPXuM6YnJxx44W+E60R3war7K2QGFAkOoCDUtDC7
SghJGF32btaDLzeKm0tQ669sBtQmMIaBrlt7I9QBkNM8zN9GL92qxNC9o3UVWMOYy5BmH8nUPgcE
O6lRubeltlrTuDe7UJQ2nEPHcXjpUJJ8dxktyW+LovBy1OxW8g4GRAsmEJsoOEg0HuDdWcc4IshJ
PvwPJ7LblELAKsdkSt65y9VaklaEm7MlH4ImlgIa74TgRmutLUbWxM1QYhGE5rAzFhGU5i3RJOdx
L3N7GGGvLMW2z9NSHbIFX+/eNII9fNJ9nZbgLA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ti1NUgDv8YPk90APMwfu/mRr38QYwAxZfv0T6zQ89YS55t2EquEGVqrEafYX6rTydLOw8le1Oucv
f2oERpSSSTih/ScZneSZmuPE/Zh2BU1Ajv0j+/+0uEWXU+5lLPbDJjnapTmJXih1MYPf0SHpZZmE
BKj2IEBI9MPZlh6bxpa5BWJnyPdAvHf+UNaMXU9+pmbtrzUVebql4mFJu45Z3+ehmFY4FBW3zXMF
44C4TlHACLwL3vHVMCVfeKhgdVDbpE+/IFhTStz7mZ9h9RKGanQcs6YDVM1R+2RKA1QT1fX4FiQc
1V+FGmrm1ujxmFGXwpfNKByVlfCY0oWhRJCYYQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
HuEXFK0NXt09xU2yxxjng1OLsT+ZEM4EhqBgpr9D2ljw2vDaMBrqEsRQTc2B9soDq3ewDduHJXBd
OGYxkPnoN6LhjULtB2nTgjcH6NxA4puZ1ZNcndDndVBo8rTW5W1OqHq6InAG0CqPpTIkuqz3ECPl
EysI++MCDfH6tIzlekxJFIJ1McJsTq5rFuLzMMcrmkBxgcayDpOcCFuzZzCczxmt/cCCIKmDybwT
OQXmOcLJoYLP4sFu6R9c6xO8i6p++crv2N3eIxZHKbek9xBBZqQM9EYuEtsbkqAs9XZpa16i5njR
BDFxTKcP6r7JgFALJE89AZhBbate5JXWp0v4ECZD18aEL17CipwcWPutNMdG1apzSPP5y59n7rMG
yxBPz1gKHc3Emkl4WcO0hjICxqmO6dMXoY8JvBSf6ry2l0sH9Ihr3Bq5WWmlhPHnoaNr5jl//vNe
KfToWtn97eoVSt1LnmXXnSpdigbHr0UIg8AdkpdkuNRaWdVicDdgSo49

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mokwst2bn6UxD6V9UdIgCIG1QQ/d0FiJqYGOTI2eHPV6YElaLjnJ8DnQmZnGS95o3x93FDOoa58C
RwYsX1fVoVtXkj1LuZq0k7q9vEe4T8xMjpkeYtIHY9k0Xhy1Lq/xRlfzGAf9fvf9e+f4r7aR/Sb/
uCZxxugG5niTwLENY1n3NthYL0jvo8Fmdw4Qg0nTCGWlVCws+09K0g9/lx6I9EcuHHemcHO3fOZG
lMc4NaPNozKwnyDMoWUkwiVxyFEPFaQLNYqzjvR+CqrWfhFLo96JWhL+eaDoNuZoBVYQtNH5ZwBL
BoO27Pw10lgcReGlZBz3BLO7T4ddynCx0+eSnw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PiP7AjOQqqouyQMoBQqgWIDhUSViq94rIvGiIJ/UKMDspM/yXw1caE8AhWHTjYckC4yLpPAz5P6s
1Z6flzDPrzVwg4e59X2cc4IMCHhedna0rDO804njcc6amRDTeLsMLTkWfvomB4xwszm2AgT+PRnB
WHd09ZUDVFjiBXT+Oa9AicgGJHrX3w823yBPuAa704kje/SzgtiDpcTU1eLmLhLW7LpEd9KIHd9s
ER7Uk9Orws0Kq9PMTqMX4hMn5K5mFakOeOURiEbUjdv5RiIJ2g/PlQXSItM8fHsBTQa6fOaJwQTI
vHwK3a8ZBHpfT1YH+n7wNiNUZwD4SFXm1QVx4g==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Ul5ZfTHJwMctaNhYRortUZizYMPYRef7uYqPSuMkxsArnxI/cjGh+KRMwzV86hyp/6TXSJIjm5ec
2wX2UONdPN+DOJ84jYC4JbgJQrPnTj7ioD8uLX/WlyPcQzyF5keqFgj5eR5s13FskVWCuAWf5m9w
mhFEKFjVXDAr7gVgAJh/hL8P6Psrnf+LGfiM8JhnDepsHEYykGlpD3fzru2BGgqHWqPqFMcnyVGl
vysaIXiJz/eYKvO8RGcgd3DJAM/wPm9A0m/DWcmSnczOgTjoqkHcBg2H5uJMLvufzmjImi6LYEqq
v04ESDEN31cSUzqUYcayvMFOnI/WNsWbFIa5+Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 29600)
`pragma protect data_block
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
3ZyY/lFYROGNzMdrDYhPS7E=
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
