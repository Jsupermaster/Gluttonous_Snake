// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Tue Nov  4 20:10:11 2025
// Host        : Jonemaster-Mini running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Study/FPT_2025/vivado_prj/Jurassic.gen/sources_1/ip/compare_0/compare_0_sim_netlist.v
// Design      : compare_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "compare_0,floating_point_v7_1_15,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "floating_point_v7_1_15,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module compare_0
   (s_axis_a_tvalid,
    s_axis_a_tdata,
    s_axis_b_tvalid,
    s_axis_b_tdata,
    m_axis_result_tvalid,
    m_axis_result_tdata);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TVALID" *) input s_axis_a_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_A, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_a_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_B TVALID" *) input s_axis_b_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_B TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_B, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_b_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TVALID" *) output m_axis_result_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_RESULT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [7:0]m_axis_result_tdata;

  wire \<const0> ;
  wire [0:0]\^m_axis_result_tdata ;
  wire m_axis_result_tvalid;
  wire [31:0]s_axis_a_tdata;
  wire s_axis_a_tvalid;
  wire [31:0]s_axis_b_tdata;
  wire s_axis_b_tvalid;
  wire NLW_inst_m_axis_result_tlast_UNCONNECTED;
  wire NLW_inst_s_axis_a_tready_UNCONNECTED;
  wire NLW_inst_s_axis_b_tready_UNCONNECTED;
  wire NLW_inst_s_axis_c_tready_UNCONNECTED;
  wire NLW_inst_s_axis_operation_tready_UNCONNECTED;
  wire [7:1]NLW_inst_m_axis_result_tdata_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_result_tuser_UNCONNECTED;

  assign m_axis_result_tdata[7] = \<const0> ;
  assign m_axis_result_tdata[6] = \<const0> ;
  assign m_axis_result_tdata[5] = \<const0> ;
  assign m_axis_result_tdata[4] = \<const0> ;
  assign m_axis_result_tdata[3] = \<const0> ;
  assign m_axis_result_tdata[2] = \<const0> ;
  assign m_axis_result_tdata[1] = \<const0> ;
  assign m_axis_result_tdata[0] = \^m_axis_result_tdata [0];
  GND GND
       (.G(\<const0> ));
  (* C_ACCUM_INPUT_MSB = "32" *) 
  (* C_ACCUM_LSB = "-31" *) 
  (* C_ACCUM_MSB = "32" *) 
  (* C_A_FRACTION_WIDTH = "24" *) 
  (* C_A_TDATA_WIDTH = "32" *) 
  (* C_A_TUSER_WIDTH = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_BRAM_USAGE = "0" *) 
  (* C_B_FRACTION_WIDTH = "24" *) 
  (* C_B_TDATA_WIDTH = "32" *) 
  (* C_B_TUSER_WIDTH = "1" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_COMPARE_OPERATION = "4" *) 
  (* C_C_FRACTION_WIDTH = "24" *) 
  (* C_C_TDATA_WIDTH = "32" *) 
  (* C_C_TUSER_WIDTH = "1" *) 
  (* C_C_WIDTH = "32" *) 
  (* C_FIXED_DATA_UNSIGNED = "0" *) 
  (* C_HAS_ABSOLUTE = "0" *) 
  (* C_HAS_ACCUMULATOR_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_S = "0" *) 
  (* C_HAS_ACCUMULATOR_S = "0" *) 
  (* C_HAS_ACCUM_INPUT_OVERFLOW = "0" *) 
  (* C_HAS_ACCUM_OVERFLOW = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ADD = "0" *) 
  (* C_HAS_ARESETN = "0" *) 
  (* C_HAS_A_TLAST = "0" *) 
  (* C_HAS_A_TUSER = "0" *) 
  (* C_HAS_B = "1" *) 
  (* C_HAS_B_TLAST = "0" *) 
  (* C_HAS_B_TUSER = "0" *) 
  (* C_HAS_C = "0" *) 
  (* C_HAS_COMPARE = "1" *) 
  (* C_HAS_C_TLAST = "0" *) 
  (* C_HAS_C_TUSER = "0" *) 
  (* C_HAS_DIVIDE = "0" *) 
  (* C_HAS_DIVIDE_BY_ZERO = "0" *) 
  (* C_HAS_EXPONENTIAL = "0" *) 
  (* C_HAS_FIX_TO_FLT = "0" *) 
  (* C_HAS_FLT_TO_FIX = "0" *) 
  (* C_HAS_FLT_TO_FLT = "0" *) 
  (* C_HAS_FMA = "0" *) 
  (* C_HAS_FMS = "0" *) 
  (* C_HAS_INVALID_OP = "0" *) 
  (* C_HAS_LOGARITHM = "0" *) 
  (* C_HAS_MULTIPLY = "0" *) 
  (* C_HAS_OPERATION = "0" *) 
  (* C_HAS_OPERATION_TLAST = "0" *) 
  (* C_HAS_OPERATION_TUSER = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_RECIP = "0" *) 
  (* C_HAS_RECIP_SQRT = "0" *) 
  (* C_HAS_RESULT_TLAST = "0" *) 
  (* C_HAS_RESULT_TUSER = "0" *) 
  (* C_HAS_SQRT = "0" *) 
  (* C_HAS_SUBTRACT = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_A = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_S = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ADD = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_SUB = "0" *) 
  (* C_LATENCY = "0" *) 
  (* C_MULT_USAGE = "0" *) 
  (* C_OPERATION_TDATA_WIDTH = "8" *) 
  (* C_OPERATION_TUSER_WIDTH = "1" *) 
  (* C_OPTIMIZATION = "1" *) 
  (* C_PART = "xck26-sfvc784-2LV-c" *) 
  (* C_RATE = "1" *) 
  (* C_RESULT_FRACTION_WIDTH = "0" *) 
  (* C_RESULT_TDATA_WIDTH = "8" *) 
  (* C_RESULT_TUSER_WIDTH = "1" *) 
  (* C_RESULT_WIDTH = "1" *) 
  (* C_THROTTLE_SCHEME = "3" *) 
  (* C_TLAST_RESOLUTION = "0" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  compare_0_floating_point_v7_1_15 inst
       (.aclk(1'b0),
        .aclken(1'b1),
        .aresetn(1'b1),
        .m_axis_result_tdata({NLW_inst_m_axis_result_tdata_UNCONNECTED[7:1],\^m_axis_result_tdata }),
        .m_axis_result_tlast(NLW_inst_m_axis_result_tlast_UNCONNECTED),
        .m_axis_result_tready(1'b0),
        .m_axis_result_tuser(NLW_inst_m_axis_result_tuser_UNCONNECTED[0]),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_a_tlast(1'b0),
        .s_axis_a_tready(NLW_inst_s_axis_a_tready_UNCONNECTED),
        .s_axis_a_tuser(1'b0),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_b_tdata(s_axis_b_tdata),
        .s_axis_b_tlast(1'b0),
        .s_axis_b_tready(NLW_inst_s_axis_b_tready_UNCONNECTED),
        .s_axis_b_tuser(1'b0),
        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_c_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_c_tlast(1'b0),
        .s_axis_c_tready(NLW_inst_s_axis_c_tready_UNCONNECTED),
        .s_axis_c_tuser(1'b0),
        .s_axis_c_tvalid(1'b0),
        .s_axis_operation_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_operation_tlast(1'b0),
        .s_axis_operation_tready(NLW_inst_s_axis_operation_tready_UNCONNECTED),
        .s_axis_operation_tuser(1'b0),
        .s_axis_operation_tvalid(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mmOvRnJo0hx7+PqMGu3YoWxrEBYAxAdZi1zk+yzEFiZIJMjePV38Oa31uE0BaogpqUs7AS9njISN
GZXX2Xcd9eCF9tXyfpnThXpwLDha12v0ZRAsGKJHWGpBuDMZg6FXSDy2oeRxKIQMa0luoKI0vLk0
yZbC4dlqmTYczcsfIuQ=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
fc8cpYYv5vI/H3z7pnHmVqePZADreJdu3RKVQcBi8nZYms7mT9oN5x0NgM+DUuXRd1Z7x8HYKYeE
kFyxlHaCo/HIJiqVA+2bOXqsng8BbIFNN+FiN3UgJaewkE9dTJVd/ROEVhqxJON57Tx6IVhV0WmJ
cWPYhMeEYFid4FpJ0H3xsk+KcoW4L+xz+/UK9Z+xiowEJep7aUN038Ga9jglCTb40A35B8+G1HZS
h9D3sOXIpp8/2ejcwVIcjIhUkppN+xHEnunW6OkL9vh91/NWQS/u+lphwOKOX+WDuHIngd1xnvKt
+i5AmVHnptjvzDMKlW6nFgNnkugxOVQma/k9HQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
DUm+EfBkI7e/sY7EMLDsRVZLuEfIgjt3sfz7ShHtswxkS45dBAv5l/yiKPu9/6DM/iz80pGT45/K
2/hjeTM9CVgsalBokhtLjhdSW6RJFxVp6ZKD9jR7RvDnnrEaAJd+02jPK9YzTdRbTzm0sMHn5mLU
ztqja0MbixEZImt/93U=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L0pKmZTGbWTdrIwcHYZ2dWbmD42xIJQXnGlG8XhayhBFtlOYgMREvK9vlHyPS4Isiz6mTW2yh6Qv
OPeDuapEOxbUo7SjK03RgNomPPKnMz5ZpZ4FfhJ56GCAA426m/cAckB5Ni0EugOisw15S0O3/HKb
qWmEcBkcQksqvkCitstRfS8T9LvOXQXTpDNIeo+gEPlQmIe7mfCp8xAJ5TzZDXLLRsK7lSeDj6qp
FCzCOerPsmRxTazCLJBRiRlMrDyjDjq2SYXmTSicf939s/rv31mpdYo4WdsKpJp1c9z8BxTjK1/x
pFKn1uL9i5TBnnp2PTTzxJgbND1J9nSw36/6CQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
4qHn9m5I5jLdIM/fNCqj608HG58k8mMnLL06oke1tI/TPvZ4Kl/RtSd3S+PLIQKxCTyojQBz/kAO
QIzZweo20v/r7iTHLCrsHEXDtFvI78WHwMbz9lg9BDszKLVO+U7VGTdmQrQC9aeYX/M0r/2qDSi1
WycGOpmo3WneDM6hA+pcMjs+byYGYKKNcRISNPkEblobug+u53AdSy7+DOQmJrXef1lUjI6L7/HK
hUtNHd3Qx/d5CwEC58xLAeM2kn57vUXKlTSUsUjVVEol3T7lv84kKHb5yrrcb8lHxV2IojdMO2o1
n9v7EbOJK/7G3Osc9osF+JcJad6wPIsa46INFw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ETbRXS7YQk/Ygxv+Qi9wEi7T+hk+MEMZI95u/c2eFw/pb27fXDUGP48hiMfCyAWlfuwwUH3fQPbz
khlm0LIUo6Xael/yAbJaAcaV66Am02ja53+YiCngXT9RVFQyefaIP/7YcAcFRYW3SxQK5rpXQeBK
Mj9avK2LlvOh+LjIUDQUUQnoZ0qftB72dPfopDt7GDpONMtf8aFY7I2aMTiQLt6NDkPJ5avK+R1b
rLXyWH898NyGxmRWkl0zw0637JVrYNxDIRPMv0uA3ujUDE5JX4TnBweHtgPk6MyO2/pikczw2iP3
l9uU2u8K1wHGqYv32+CcE2yLLNDxLF+4zBT/8g==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DGTJq6GIxpJpCyrcF3lPti11wrEojytsyrjbNsuQDbI/UwSi2ip7dvKR7MkXC8HGDqQ5vPbQSOuR
UY3Xniav28PBFc2qZMK07SKE02Z5QhaTju1tIy6ACa8GVuTGGquCC58NNupc4u/zPB+HeQTXDlrW
r3YrSeCS3VSSwjICQ8HL9+z9e4LSbJtq65BiAlS8V7qn/ENrhwkPWY5FPdBs9Y+C3UdMV/xI5IAA
a8hqPWQswv9vZDRxH/dXI+eklyMbwzbwRZCV1KTx5P5t5VUhFXDehns8OcYJoO7M8kmK7MIpsw2P
2diAjrDolQU/urY1X7gEiYnz3/3fdkLF9ARawQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
MqYYWpi5cUKxeqegUOZ/FE71PbGIeBKRaebYLZrsAQMHxp7rX2HLBfghj8DkaLpBvFZsRe3QHQKz
7J1EMjkJRnAZ99lDMCh1BUBj9yoG3aflK5SgQS3f8wlsLqzxJQbBRYVv77/LYvZT2OjIBhwl+6FU
aRzgPT7kw+CouWg5nRmaPHQpuF7RDIGYw3iAEgHi5JqIhbys9ADrgHdVkby+d1nfJ1QzimhoiEDF
nR2tfpELYmQO6yMjac1NMKwqamfGQ7sv7BCChIwYRvW9l2fN2Yp+2i05nuVSfAyEHC9Z7nSdSPmO
kwN5VI8z8fnBCE/0cAwavWW8BKo3rvlv6KOQXDuNYHOmb8oArzgg3a5htizGcx9BfdyK/+3Pd7u5
iNn4SGpLSWsRwMYQcGbNHsXPsWpEiVtHxs06Tc1S9Arn09eWIggn++2/3CDDG+nYQrcSlMaKtTmX
rbG7zsJpirzPDalNQh3HiAK+ZU+lVyaiMY86sPq6VhY43uq9Z78kF01R

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j8OUn7H0onPT0+ubA7jLFo+cW7C6hcKI39ZZ2/bHcowL1pbZqDp3KOJxwRqSNOB7aXQ3QKJvcel+
COdVz2X4+AsoLGzifagtsIFiRDNQ2ivmE7jUyJmsfO8F1cLTi2Ezd8szMAP9Q4wvU8Vazm4bGNLk
NceiyiGaMhtt4pPVY4RvuoRdCt3Ic9/usyfgfyjZSgIqc+oT36/FtQPznhXEiWcoc3P3rILT1LfZ
lFz11X3JH70rU3hNTPjhbmy4OtvUpx0hqViwWvMIOHoDuS1aqZegrgD/qnOb+XPD4U3gzoaEu1oj
KOFl4N48DoB8AvG8tlxSJLWw7OYcwucfAsGsGw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ilySVjN8y6u8ujjDFlpgcnWH4mzITp1tD08bdzFzXCJYiGNcjTE5PDN2myE3T7KqtgdSyz2gZL+M
pcHAWOh65lESNe9pzaIsRKUckYo0qRoU1mCJ29y83vmBbgWgHvhxaMKebLSnyNpAl/02jPiSUIwP
99x98AQi0D0wHSth6EqOib7up4ULQmCmqhYLa64ajY7dV4iGj/uzazddbwWjnDNwzkAnPM4k6fsm
xq3Vn4j0bJSvBZRgw2wOtnF+cfss6DIZ03gQloOi1tkTqq/OhTCMk2lMP1odZgjGBGW1r2DNAuiW
LV+ylmjwzjnsFoNiydS3eAWbGOycX8iSCaS2+A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
uG8bqCObvROCvHBr2WtnITJzwsgsIiHZCPjZqZFdV7Xp5EmAedxs9I9waInO5euX6KLt+a+w89AX
vhcjymGQkOqK/k/50cLPI0CZ54ZwW1YUOc/e9EgBClJf8nu3r9sfOF7p5dXy3vppYocJON0sVKxM
1Q8gYovIgvhaIYGjNOWHgVdhzdsI/PpSzYs6cB45Na6+NmTdar0bkD54mVG8RkNjrkXNhaU56dHi
+leknHljtUnmTyfmNa7t2iOrTJ8EL+Qlvgq23CFI3GTc2nMyBymUckNAIK996CCwflhxLfIBadKX
sRWLYAj+lJU2+rDgfMG41WrL5XfId18TRbX9vA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52496)
`pragma protect data_block
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
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
