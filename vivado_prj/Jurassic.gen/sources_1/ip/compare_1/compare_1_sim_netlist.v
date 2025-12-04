// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Tue Nov  4 20:10:54 2025
// Host        : Jonemaster-Mini running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/Study/FPT_2025/vivado_prj/Jurassic.gen/sources_1/ip/compare_1/compare_1_sim_netlist.v
// Design      : compare_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "compare_1,floating_point_v7_1_15,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "floating_point_v7_1_15,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module compare_1
   (aclk,
    s_axis_a_tvalid,
    s_axis_a_tdata,
    s_axis_b_tvalid,
    s_axis_b_tdata,
    m_axis_result_tvalid,
    m_axis_result_tdata);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk_intf CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk_intf, ASSOCIATED_BUSIF S_AXIS_OPERATION:M_AXIS_RESULT:S_AXIS_C:S_AXIS_B:S_AXIS_A, ASSOCIATED_RESET aresetn, ASSOCIATED_CLKEN aclken, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TVALID" *) input s_axis_a_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_A, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_a_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_B TVALID" *) input s_axis_b_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_B TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_B, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_b_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TVALID" *) output m_axis_result_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_RESULT, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [7:0]m_axis_result_tdata;

  wire \<const0> ;
  wire aclk;
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
  (* C_LATENCY = "1" *) 
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
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  compare_1_floating_point_v7_1_15 inst
       (.aclk(aclk),
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
AiGrLcxLmT5pAZSLxkCGMJQoUgSYKOGTFX3rClG5JlHpjElvcNrf+TCLpClPrQxjpmWJ/LLh41uh
mPb4Ne4Lh0adbwvYnBkXbmQdWaCOnejNWDmAp0Mm+wATX60bP9AQgDJVohMUvbZaA5vDJV062xF2
KLOVANSbDE0mDDSVb5jYjOUrwawnHk4E0Efdb+G+SOZzAC+9DF3sRVPgAgZFdKAeZRRd+M1sq95o
y8ycgcO6hWlQzobqqKn3Kql1qOC73PLDUQ7oBNjEb1YSiR2wHdMxpdv0F7E+xyM6XQotnvyUs+o7
EQMOcVsKMUFUdWqv9vjn0bC7JAN2J8KG49b+Gw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oeSolokW0FebAdeT/y90VRfOO+8HCdc5lEQwm6U6RZGR5B2JGh5kTtzDhHkkITVhkcpEllbCjpw+
DOBs5p/r9zI76vnM7RAaztSvvC1OU+YmK/lGxBZYWaXioxsYjeDI6AsZ8JDRJaU9s0WdWMAjDoqf
T2wNLiO1Y18dSTmxkZESsC/Sb27xWqirTjUXeCJwTnNgrixMg2LBJEjK/ZJ8Y3xnP5Zn5v6CGTsS
9IWavdYjKGeJkwEXDH7DTKDIs6BhTujzeIK+zK1mAZLPxgScSzlQAPgAlkbupLhrs9ZQE3q6hBPR
XIE2DKrEYLbM1Xp6mh8PokXYRF4v+wX4o1xvqQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 54848)
`pragma protect data_block
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
sNJM2Ic35zEcSrSSKfU=
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
