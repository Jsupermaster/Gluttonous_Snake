module LAYERNORM(
    input   wire             clk            ,
    input   wire             rst_n          ,
    input   wire             stage_start    ,
    input   wire             a_tvalid       ,
    input   wire    [63:0]   a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   ,
    output  wire    [127:0]  fifo_din1      ,
    output  wire             fifo_wr_en1    ,
    input   wire    [127:0]  fifo_dout1     ,
    output  wire             fifo_rd_en1    ,
    output  wire    [127:0]  fifo_din2      ,
    output  wire             fifo_wr_en2    ,
    input   wire    [127:0]  fifo_dout2     ,
    output  wire             fifo_rd_en2     
);
    parameter DATA_NUM = 8'd192;

    reg             in0_layernorm_tvalid;
    reg     [63:0]  in0_layernorm_tdata;
    wire            init_transfer;
    reg             init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            init_txn_ff <= 1'b0;
        end 
        else begin
            init_txn_ff <= stage_start;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            in0_layernorm_tvalid <= 1'b0;
            in0_layernorm_tdata  <= 64'd0;
        end 
        else begin
            if (stage_start) begin
                in0_layernorm_tvalid <= a_tvalid;
                in0_layernorm_tdata  <= a_tdata;
            end
            else begin
                in0_layernorm_tvalid <= in0_layernorm_tvalid;
                in0_layernorm_tdata  <= in0_layernorm_tdata;
            end
        end
    end
    assign fifo_wr_en1 = in0_layernorm_tvalid;
    wire [31:0] in0_layernorm_tdata1;
    wire [31:0] in0_layernorm_tdata2;
    wire [31:0] in0_layernorm_tdata3;
    wire [31:0] in0_layernorm_tdata4;
    assign in0_layernorm_tdata1 = {in0_layernorm_tdata[15:0],16'b0};
    assign in0_layernorm_tdata2 = {in0_layernorm_tdata[31:16],16'b0};
    assign in0_layernorm_tdata3 = {in0_layernorm_tdata[47:32],16'b0};
    assign in0_layernorm_tdata4 = {in0_layernorm_tdata[63:48],16'b0};
    reg [7:0]   in0_cnt;
    reg         in0_tlast;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            in0_cnt <= 8'd0;
            in0_tlast     <= 1'b0;
        end 
        else if (in0_layernorm_tvalid) begin
            if (in0_cnt == DATA_NUM - 8'd2) begin
                in0_tlast     <= 1'b1;
                in0_cnt <= in0_cnt + 8'd1;
            end 
            else if (in0_cnt == DATA_NUM - 8'd1) begin
                in0_tlast     <= 1'b0;
                in0_cnt <= 8'd0;
            end 
            else begin
                in0_tlast     <= 1'b0;
                in0_cnt <= in0_cnt + 8'd1;
            end
        end
        else begin
            in0_cnt <= in0_cnt;
            in0_tlast     <= in0_tlast;
        end
    end

    wire [31:0] sum1_tdata;
    wire        sum1_tvalid;
    acc_array layer_accumulate1 (
        .clk             (clk),
        .a_tvalid        (in0_layernorm_tvalid),
        .a_tdata         ({in0_layernorm_tdata4,in0_layernorm_tdata3,in0_layernorm_tdata2,in0_layernorm_tdata1}),
        .a_tlast         (in0_tlast),
        .result_tvalid   (sum1_tvalid),
        .result_tdata    (sum1_tdata)
    );

    wire [31:0] mul1_tdata;
    wire        mul1_tvalid;
    wire [31:0] n1 = 32'h3aaaaaab;  // 1/768

    mul layer_mul_n1 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum1_tvalid),
        .s_axis_a_tdata         (sum1_tdata),
        .s_axis_b_tvalid        (sum1_tvalid),
        .s_axis_b_tdata         (n1),
        .m_axis_result_tvalid   (mul1_tvalid),
        .m_axis_result_tdata    (mul1_tdata)
    );

    reg         fifo_rd_valid1;
    reg [7:0]   batch_cnt1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid1 <= 1'b0;
        else if (mul1_tvalid) 
            fifo_rd_valid1 <= 1'b1;
        else if ((batch_cnt1 == DATA_NUM -8'd1)&&(mul1_tvalid==1'b0))
            fifo_rd_valid1 <= 1'b0;
        else
            fifo_rd_valid1 <= fifo_rd_valid1;
    end
    reg         fifo_rd_valid1_r1;
    reg         fifo_rd_valid1_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_rd_valid1_r1 <= 1'b0;
            fifo_rd_valid1_r2 <= 1'b0;
        end
        else begin
            fifo_rd_valid1_r1 <= fifo_rd_valid1;
            fifo_rd_valid1_r2 <= fifo_rd_valid1_r1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            batch_cnt1 <= 8'd0;
        else if (batch_cnt1 == DATA_NUM - 8'd1)
            batch_cnt1 <= 8'd0;
        else if (fifo_rd_valid1) 
            batch_cnt1 <= batch_cnt1 + 8'd1;
        else
            batch_cnt1 <= batch_cnt1;
    end
    reg [31:0]  mul1_valid_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul1_valid_data <= 32'h0;
        else if (mul1_tvalid)
            mul1_valid_data <= mul1_tdata;
        else
            mul1_valid_data <= mul1_valid_data;
    end
    reg [31:0]  mul1_valid_data_r1;
    reg [31:0]  mul1_valid_data_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul1_valid_data_r1 <= 32'b0;
            mul1_valid_data_r2 <= 32'b0;
        end
        else begin
            mul1_valid_data_r1 <= mul1_valid_data;
            mul1_valid_data_r2 <= mul1_valid_data_r1;
        end
    end
    assign fifo_wr_en1 = in0_layernorm_tvalid;
    assign fifo_din1 = {in0_layernorm_tdata4,in0_layernorm_tdata3,in0_layernorm_tdata2,in0_layernorm_tdata1};
    assign fifo_rd_en1 = fifo_rd_valid1;

    wire [127:0] sub2_tdata;
    wire         sub2_tvalid;
    sub_array layer_sub2 (
        .clk             (clk),
        .a_tvalid        (fifo_rd_valid1),
        .a_tdata         (fifo_dout1),
        .b_tvalid        (fifo_rd_valid1),
        .b_tdata         ({mul1_valid_data_r2,mul1_valid_data_r2,mul1_valid_data_r2,mul1_valid_data_r2}),
        .result_tvalid   (sub2_tvalid),
        .result_tdata    (sub2_tdata)
    );

    wire        square1_tvalid;
    wire [31:0] square1_tdata;
    
    mul layer_square1 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (mul1_tvalid),
        .s_axis_a_tdata         (mul1_tdata),
        .s_axis_b_tvalid        (mul1_tvalid),
        .s_axis_b_tdata         (mul1_tdata),
        .m_axis_result_tvalid   (square1_tvalid),
        .m_axis_result_tdata    (square1_tdata)
    );

    wire        square2_tvalid;
    wire [127:0]square2_tdata;
    reg         square2_tlast;
    reg  [7:0]  square2_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            square2_cnt <= 8'd0;
            square2_tlast   <= 1'b0;
        end 
        else if (square2_tvalid) begin
            if (square2_cnt == DATA_NUM - 8'd2) begin
                square2_tlast   <= 1'b1;
                square2_cnt <= square2_cnt + 8'd1;
            end 
            else if (square2_cnt == DATA_NUM - 8'd1) begin
                square2_tlast   <= 1'b0;
                square2_cnt <= 8'd0;
            end 
            else begin
                square2_tlast   <= 1'b0;
                square2_cnt <= square2_cnt + 8'd1;
            end
        end
        else begin
            square2_cnt <= square2_cnt;
            square2_tlast   <= square2_tlast;
        end
    end

    mul_array layer_square2 (
        .clk             (clk),
        .a_tvalid        (in0_layernorm_tvalid),
        .a_tdata         ({in0_layernorm_tdata4,in0_layernorm_tdata3,in0_layernorm_tdata2,in0_layernorm_tdata1}),
        .b_tvalid        (in0_layernorm_tvalid),
        .b_tdata         ({in0_layernorm_tdata4,in0_layernorm_tdata3,in0_layernorm_tdata2,in0_layernorm_tdata1}),
        .result_tvalid   (square2_tvalid),
        .result_tdata    (square2_tdata)
    );

    wire [31:0] sum2_tdata;
    wire        sum2_tvalid;

    acc_array layer_accumulate2 (
        .clk             (clk),
        .a_tvalid        (square2_tvalid),
        .a_tdata         (square2_tdata),
        .a_tlast         (square2_tlast),
        .result_tvalid   (sum2_tvalid),
        .result_tdata    (sum2_tdata)
    );

    wire [31:0] mul2_tdata;
    wire        mul2_tvalid;
    wire [31:0] n2 = 32'h3aaaaaab;  // 1/768
    
    mul layer_mul_n2 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum2_tvalid),
        .s_axis_a_tdata         (sum2_tdata),
        .s_axis_b_tvalid        (sum2_tvalid),
        .s_axis_b_tdata         (n2),
        .m_axis_result_tvalid   (mul2_tvalid),
        .m_axis_result_tdata    (mul2_tdata)
    );

    wire [31:0] sub1_tdata;
    wire        sub1_tvalid;
    
    sub layer_sub1 (
        .aclk                   (clk),
        .s_axis_a_tvalid        (mul2_tvalid),
        .s_axis_a_tdata         (mul2_tdata),
        .s_axis_b_tvalid        (square1_tvalid),
        .s_axis_b_tdata         (square1_tdata),
        .m_axis_result_tvalid   (sub1_tvalid),
        .m_axis_result_tdata    (sub1_tdata)
    );

    wire [31:0] add_tdata;
    wire        add_tvalid;
    wire [31:0] epsilon = 32'h3727c5ac;  // 10的-6次方

    add layer_add_epsilon (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sub1_tvalid),
        .s_axis_a_tdata         (sub1_tdata),
        .s_axis_b_tvalid        (sub1_tvalid),
        .s_axis_b_tdata         (epsilon),
        .m_axis_result_tvalid   (add_tvalid),
        .m_axis_result_tdata    (add_tdata)
    );

    wire [31:0] rsqrt_tdata;
    wire        rsqrt_tvalid;
    
    rsqrt_root layer_rsquart_root (
        .aclk                   (clk),
        .s_axis_a_tvalid        (add_tvalid),
        .s_axis_a_tdata         (add_tdata),
        .m_axis_result_tvalid   (rsqrt_tvalid),
        .m_axis_result_tdata    (rsqrt_tdata)
    );

    reg         fifo_rd_valid2;
    reg [7:0]   batch_cnt2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid2 <= 1'b0;
        else if (rsqrt_tvalid) 
            fifo_rd_valid2 <= 1'b1;
        else if ((batch_cnt2 == DATA_NUM -8'd1)&&(rsqrt_tvalid==1'b0))
            fifo_rd_valid2 <= 1'b0;
        else
            fifo_rd_valid2 <= fifo_rd_valid2;
    end
    reg         fifo_rd_valid2_r1;
    reg         fifo_rd_valid2_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_rd_valid2_r1 <= 1'b0;
            fifo_rd_valid2_r2 <= 1'b0;
        end
        else begin
            fifo_rd_valid2_r1 <= fifo_rd_valid2;
            fifo_rd_valid2_r2 <= fifo_rd_valid2_r1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            batch_cnt2 <= 8'd0;
        else if (batch_cnt2 == DATA_NUM - 8'd1)
            batch_cnt2 <= 8'd0;
        else if (fifo_rd_valid2) 
            batch_cnt2 <= batch_cnt2 + 8'd1;
        else
            batch_cnt2 <= batch_cnt2;
    end

    reg [31:0]  rsqrt_valid_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            rsqrt_valid_data <= 32'h0;
        else if (rsqrt_tvalid)
            rsqrt_valid_data <= rsqrt_tdata;
        else
            rsqrt_valid_data <= rsqrt_valid_data;
    end
    reg [31:0]  rsqrt_valid_data_r1;
    reg [31:0]  rsqrt_valid_data_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rsqrt_valid_data_r1 <= 32'b0;
            rsqrt_valid_data_r2 <= 32'b0;
        end
        else begin
            rsqrt_valid_data_r1 <= rsqrt_valid_data;
            rsqrt_valid_data_r2 <= rsqrt_valid_data_r1;
        end
    end
    assign fifo_wr_en2 = sub2_tvalid;
    assign fifo_din2 = sub2_tdata;
    assign fifo_rd_en2 = fifo_rd_valid2;

    mul_array layer_mul (
        .clk             (clk),
        .a_tvalid        (fifo_rd_valid2_r2),
        .a_tdata         (fifo_dout2),
        .b_tvalid        (fifo_rd_valid2_r2),
        .b_tdata         ({rsqrt_valid_data_r2,rsqrt_valid_data_r2,rsqrt_valid_data_r2,rsqrt_valid_data_r2}),
        .result_tvalid   (result_tvalid),
        .result_tdata    (result_tdata)
    );
endmodule