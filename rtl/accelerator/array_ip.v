module mul_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    input   wire             b_tvalid       ,
    input   wire    [127:0]  b_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   
);
    wire  [3:0]      result_tvalid_r ;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_mul_array
            mul u_mul (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .s_axis_b_tvalid        (b_tvalid),
                .s_axis_b_tdata         (b_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tvalid   (result_tvalid_r[i]),
                .m_axis_result_tdata    (result_tdata[(i+1)*32-1 : i*32])
            );
        end
    endgenerate
    assign result_tvalid = result_tvalid_r[0];

endmodule

module add_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    input   wire             b_tvalid       ,
    input   wire    [127:0]  b_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   
);
    wire  [3:0]      result_tvalid_r ;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_add_array
            add u_add (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .s_axis_b_tvalid        (b_tvalid),
                .s_axis_b_tdata         (b_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tvalid   (result_tvalid_r[i]),
                .m_axis_result_tdata    (result_tdata[(i+1)*32-1 : i*32])
            );
        end
    endgenerate
    assign result_tvalid = result_tvalid_r[0];
endmodule

module acc_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    input   wire             a_tlast        ,
    output  wire             result_tvalid  ,
    output  wire    [31:0]   result_tdata   
);
    wire [127:0] sum_tdata;
    wire  [3:0]  sum_tvalid;
    wire  [3:0]  sum_tlast;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_acc_array
            acc u_acc (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .s_axis_a_tlast         (a_tlast),
                .m_axis_result_tvalid   (sum_tvalid[i]),
                .m_axis_result_tdata    (sum_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tlast    (sum_tlast[i])
            );
        end
    endgenerate
    wire [31:0] sum_tdata1;
    wire [31:0] sum_tdata2;
    wire [31:0] sum_tdata3;
    wire [31:0] sum_tdata4;
    
    assign sum_tdata1 = sum_tdata[31:0];
    assign sum_tdata2 = sum_tdata[63:32];
    assign sum_tdata3 = sum_tdata[95:64];
    assign sum_tdata4 = sum_tdata[127:96];

    wire [31:0] add_tdata1;
    wire        add_tvalid1;
    wire [31:0] add_tdata2;
    wire        add_tvalid2;
    add add1 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum_tlast[0]),
        .s_axis_a_tdata         (sum_tdata1),
        .s_axis_b_tvalid        (sum_tlast[1]),
        .s_axis_b_tdata         (sum_tdata2),
        .m_axis_result_tvalid   (add_tvalid1),
        .m_axis_result_tdata    (add_tdata1)
    );

    add add2 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum_tlast[2]),
        .s_axis_a_tdata         (sum_tdata3),
        .s_axis_b_tvalid        (sum_tlast[3]),
        .s_axis_b_tdata         (sum_tdata4),
        .m_axis_result_tvalid   (add_tvalid2),
        .m_axis_result_tdata    (add_tdata2)
    );
    add add3 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (add_tvalid1),
        .s_axis_a_tdata         (add_tdata1),
        .s_axis_b_tvalid        (add_tvalid2),
        .s_axis_b_tdata         (add_tdata2),
        .m_axis_result_tvalid   (result_tvalid),
        .m_axis_result_tdata    (result_tdata)
    );
endmodule

module exp_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   
);
    wire  [3:0]      result_tvalid_r ;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_exp_array
            exp u_exp (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tvalid   (result_tvalid_r[i]),
                .m_axis_result_tdata    (result_tdata[(i+1)*32-1 : i*32])
            );
        end
    endgenerate
    assign result_tvalid = result_tvalid_r[0];

endmodule

module rec_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   
);
    wire  [3:0]      result_tvalid_r ;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_rec_array
            rec u_rec (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tvalid   (result_tvalid_r[i]),
                .m_axis_result_tdata    (result_tdata[(i+1)*32-1 : i*32])
            );
        end
    endgenerate
    assign result_tvalid = result_tvalid_r[0];
endmodule

module sub_array (
    input   wire             clk            ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    input   wire             b_tvalid       ,
    input   wire    [127:0]  b_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   
);
    wire  [3:0]      result_tvalid_r ;
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : u_sub_array
            sub u_sub (
                .aclk                   (clk),
                .s_axis_a_tvalid        (a_tvalid),
                .s_axis_a_tdata         (a_tdata[(i+1)*32-1 : i*32]),
                .s_axis_b_tvalid        (b_tvalid),
                .s_axis_b_tdata         (b_tdata[(i+1)*32-1 : i*32]),
                .m_axis_result_tvalid   (result_tvalid_r[i]),
                .m_axis_result_tdata    (result_tdata[(i+1)*32-1 : i*32])
            );
        end
    endgenerate
    assign result_tvalid = result_tvalid_r[0];
endmodule

module compare_array (
    input   wire             clk            ,
    input   wire             init_transfer  ,
    input   wire             rst_n          ,
    input   wire             a_tvalid       ,
    input   wire    [127:0]  a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [31:0]   result_tdata   
);
    parameter DATA_NUM = 10'd192;
    reg         max_tvalid;
    reg [9:0]   in0_cnt;
    wire        compare_tvalid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            in0_cnt <= 10'd0;
        else if (in0_cnt == DATA_NUM - 10'd1)
            in0_cnt <= 10'd0;
        else if (a_tvalid) 
            in0_cnt <= in0_cnt + 10'd1;
        else
            in0_cnt <= in0_cnt;
    end
    wire [31:0] a_tdata1;
    wire [31:0] a_tdata2;
    wire [31:0] a_tdata3;
    wire [31:0] a_tdata4;
    assign a_tdata1 = a_tdata[31:0];
    assign a_tdata2 = a_tdata[63:32];
    assign a_tdata3 = a_tdata[95:64];
    assign a_tdata4 = a_tdata[127:96];
    reg  [31:0] max_tdata1;
    reg  [31:0] max_tdata2;
    reg  [31:0] max_tdata3;
    reg  [31:0] max_tdata4;
    wire [7:0]  compare_code1;
    wire [7:0]  compare_code2;
    wire [7:0]  compare_code3;
    wire [7:0]  compare_code4;
    compare_0 u_compare1 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata1),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata1),
        .m_axis_result_tvalid   (compare_tvalid),
        .m_axis_result_tdata    (compare_code1)
    );
    compare_0 u_compare2 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata2),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata2),
        .m_axis_result_tvalid   (compare_tvalid),
        .m_axis_result_tdata    (compare_code2)
    );
    compare_0 u_compare3 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata3),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata3),
        .m_axis_result_tvalid   (compare_tvalid),
        .m_axis_result_tdata    (compare_code3)
    );
    compare_0 u_compare4 (
        .s_axis_a_tvalid        (a_tvalid),
        .s_axis_a_tdata         (a_tdata4),
        .s_axis_b_tvalid        (a_tvalid),
        .s_axis_b_tdata         (max_tdata4),
        .m_axis_result_tvalid   (compare_tvalid),
        .m_axis_result_tdata    (compare_code4)
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata1 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata1 <= a_tdata1;
        else if (compare_code1[0]&&compare_tvalid) 
            max_tdata1 <= a_tdata1;
        else
            max_tdata1 <= max_tdata1;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata2 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata2 <= a_tdata2;
        else if (compare_code2[0]&&compare_tvalid) 
            max_tdata2 <= a_tdata2;
        else
            max_tdata2 <= max_tdata2;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata3 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata3 <= a_tdata3;
        else if (compare_code3[0]&&compare_tvalid) 
            max_tdata3 <= a_tdata3;
        else
            max_tdata3 <= max_tdata3;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata4 <= 32'hff7f0000;
        else if (max_tvalid)
            max_tdata4 <= a_tdata4;
        else if (compare_code4[0]&&compare_tvalid) 
            max_tdata4 <= a_tdata4;
        else
            max_tdata4 <= max_tdata4;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            max_tvalid <= 1'b0;
        else if (in0_cnt == DATA_NUM - 10'd1)
            max_tvalid <= 1'b1;
        else 
            max_tvalid <= 1'b0;
    end
    reg  [31:0] max_tdata5;
    reg  [31:0] max_tdata6;
    reg  [31:0] max_tdata7;
    wire        max_tvalid1;
    wire        max_tvalid2;
    wire [7:0]  compare_code5;
    wire [7:0]  compare_code6;
    wire [7:0]  compare_code7;
    compare_1 u_compare5 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid),
        .s_axis_a_tdata         (max_tdata1),
        .s_axis_b_tvalid        (max_tvalid),
        .s_axis_b_tdata         (max_tdata2),
        .m_axis_result_tvalid   (max_tvalid1),
        .m_axis_result_tdata    (compare_code5)
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata5 <= 32'h0;
        else if (compare_code5[0]&&max_tvalid) 
            max_tdata5 <= max_tdata1;
        else if ((~compare_code5[0])&&max_tvalid) 
            max_tdata5 <= max_tdata2;
        else
            max_tdata5 <= max_tdata5;
    end
    compare_1 u_compare6 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid),
        .s_axis_a_tdata         (max_tdata3),
        .s_axis_b_tvalid        (max_tvalid),
        .s_axis_b_tdata         (max_tdata4),
        .m_axis_result_tvalid   (max_tvalid2),
        .m_axis_result_tdata    (compare_code6)
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata6 <= 32'h0;
        else if (compare_code6[0]&&max_tvalid) 
            max_tdata6 <= max_tdata3;
        else if ((~compare_code6[0])&&max_tvalid) 
            max_tdata6 <= max_tdata4;
        else
            max_tdata6 <= max_tdata6;
    end
    compare_1 u_compare7 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (max_tvalid1),
        .s_axis_a_tdata         (max_tdata5),
        .s_axis_b_tvalid        (max_tvalid2),
        .s_axis_b_tdata         (max_tdata6),
        .m_axis_result_tvalid   (result_tvalid),
        .m_axis_result_tdata    (compare_code7)
    );
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n|| init_transfer)
            max_tdata7 <= 32'h0;
        else if (compare_code7[0]&&max_tvalid1) 
            max_tdata7 <= max_tdata5;
        else if ((~compare_code7[0])&&max_tvalid1) 
            max_tdata7 <= max_tdata6;
        else
            max_tdata7 <= max_tdata7;
    end
    assign result_tdata = max_tdata7;

endmodule