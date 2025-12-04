module SOFTMAX(
    input   wire            clk             ,
    input   wire            rst_n           ,
    input   wire            stage_start     ,
    input   wire            a_tvalid        ,
    input   wire    [63:0]  a_tdata         ,
    output  wire            result_tvalid   ,
    output  wire    [127:0] result_tdata    ,
    output  wire    [127:0] fifo_din1       ,
    output  wire            fifo_wr_en1     ,
    input   wire    [127:0] fifo_dout1      ,
    output  wire            fifo_rd_en1     ,
    output  wire    [127:0] fifo_din2       ,
    output  wire            fifo_wr_en2     ,
    input   wire    [127:0] fifo_dout2      ,
    output  wire            fifo_rd_en2     
);
    parameter DATA_NUM = 8'd192;

    reg             in0_softmax_tvalid;
    reg     [63:0]  in0_softmax_tdata;
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
            in0_softmax_tvalid <= 1'b0;
            in0_softmax_tdata  <= 64'd0;
        end 
        else begin
            if (stage_start) begin
                in0_softmax_tvalid <= a_tvalid;
                in0_softmax_tdata  <= a_tdata;
            end
            else begin
                in0_softmax_tvalid <= in0_softmax_tvalid;
                in0_softmax_tdata  <= in0_softmax_tdata;
            end
        end
    end
    wire [31:0] in0_softmax_tdata1;
    wire [31:0] in0_softmax_tdata2;
    wire [31:0] in0_softmax_tdata3;
    wire [31:0] in0_softmax_tdata4;
    assign in0_softmax_tdata1 = {in0_softmax_tdata[15:0],16'b0};
    assign in0_softmax_tdata2 = {in0_softmax_tdata[31:16],16'b0};
    assign in0_softmax_tdata3 = {in0_softmax_tdata[47:32],16'b0};
    assign in0_softmax_tdata4 = {in0_softmax_tdata[63:48],16'b0};

    wire[31:0]  max_tdata;
    wire        max_tvalid;
    reg         max_tvalid_r1;
    reg         max_tvalid_r2;
    
    compare_array softmax_compare(
        .clk           (clk),
        .init_transfer (init_transfer),
        .rst_n         (rst_n),
        .a_tvalid      (in0_softmax_tvalid),
        .a_tdata       ({in0_softmax_tdata4,in0_softmax_tdata3,in0_softmax_tdata2,in0_softmax_tdata1}),
        .result_tvalid (max_tvalid),
        .result_tdata  (max_tdata)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            max_tvalid_r1 <= 1'b0;
            max_tvalid_r2 <= 1'b0;
        end
        else begin
            max_tvalid_r1 <= max_tvalid;
            max_tvalid_r2 <= max_tvalid_r1;
        end
    end

    reg         fifo_rd_valid1;
    reg [7:0]   batch_cnt1;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid1 <= 1'b0;
        else if (max_tvalid) 
            fifo_rd_valid1 <= 1'b1;
        else if ((batch_cnt1 == DATA_NUM - 8'd1)&&(max_tvalid == 1'b0))
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
    reg [31:0]  max_valid_data_r1;
    reg [31:0]  max_valid_data_r2;
    reg [31:0]  max_valid_data_r3;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_valid_data_r1 <= 32'b0;
            max_valid_data_r2 <= 32'b0;
        end
        else begin
            max_valid_data_r1 <= max_tdata;
            max_valid_data_r2 <= max_valid_data_r1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_valid_data_r3 <= 32'b0;
        end
        else if(max_tvalid_r2)begin
            max_valid_data_r3 <= max_valid_data_r2;
        end
    end
    assign fifo_wr_en1 = in0_softmax_tvalid;
    assign fifo_din1 = {in0_softmax_tdata4,in0_softmax_tdata3,in0_softmax_tdata2,in0_softmax_tdata1};
    assign fifo_rd_en1 = fifo_rd_valid1;

    wire [127:0]sub1_tdata;
    wire        sub1_tvalid;
    wire [31:0] sub1_tdata1 = sub1_tdata[31:0];
    wire [31:0] sub1_tdata2 = sub1_tdata[63:32];
    wire [31:0] sub1_tdata3 = sub1_tdata[97:64];
    wire [31:0] sub1_tdata4 = sub1_tdata[127:96];
    sub_array softmax_sub1(
        .clk            (clk),
        .a_tvalid       (fifo_rd_valid1_r2),
        .a_tdata        (fifo_dout1),
        .b_tvalid       (fifo_rd_valid1_r2),
        .b_tdata        ({max_valid_data_r3,max_valid_data_r3,max_valid_data_r3,max_valid_data_r3}),
        .result_tvalid  (sub1_tvalid),
        .result_tdata   (sub1_tdata)
    );
    wire         exp_tvalid;
    wire [127:0] exp_tdata;
    wire [31:0] exp_tdata1 = exp_tdata[31:0];
    wire [31:0] exp_tdata2 = exp_tdata[63:32];
    wire [31:0] exp_tdata3 = exp_tdata[97:64];
    wire [31:0] exp_tdata4 = exp_tdata[127:96];

    exp_array softmax_exp1 (
        .clk             (clk),
        .a_tvalid        (sub1_tvalid),
        .a_tdata         (sub1_tdata),
        .result_tvalid   (exp_tvalid),
        .result_tdata    (exp_tdata)
    );
    
    reg         exp_tlast;
    reg [7:0]   exp_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            exp_cnt <= 8'd0;
            exp_tlast   <= 1'b0;
        end 
        else if (exp_tvalid) begin
            if (exp_cnt == DATA_NUM - 8'd2) begin
                exp_tlast   <= 1'b1;
                exp_cnt <= exp_cnt + 8'd1;
            end 
            else if (exp_cnt == DATA_NUM - 8'd1) begin
                exp_tlast   <= 1'b0;
                exp_cnt <= 8'd0;
            end 
            else begin
                exp_tlast   <= 1'b0;
                exp_cnt <= exp_cnt + 8'd1;
            end
        end
        else begin
            exp_cnt <= exp_cnt;
            exp_tlast <= exp_tlast;
        end
    end
    wire [31:0] sum_tdata;
    wire        sum_tvalid;
    acc_array softmax_accumulate (
        .clk             (clk),
        .a_tvalid        (exp_tvalid),
        .a_tdata         (exp_tdata),
        .a_tlast         (exp_tlast),
        .result_tvalid   (sum_tvalid),
        .result_tdata    (sum_tdata)
    );
    wire [31:0] ln_tdata;
    wire        ln_tvalid;
    ln softmax_ln (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum_tvalid),
        .s_axis_a_tdata         (sum_tdata),
        .m_axis_result_tvalid   (ln_tvalid),
        .m_axis_result_tdata    (ln_tdata)
    );

    reg         fifo_rd_valid2;
    reg         fifo_rd_valid2_r1;
    reg         fifo_rd_valid2_r2;
    reg [7:0]   batch_cnt2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid2 <= 1'b0;
        else if (ln_tvalid) 
            fifo_rd_valid2 <= 1'b1;
        else if ((batch_cnt2 == DATA_NUM - 8'd1)&&(ln_tvalid == 1'b0))
            fifo_rd_valid2 <= 1'b0;
        else
            fifo_rd_valid2 <= fifo_rd_valid2;
    end
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

    assign fifo_wr_en2 = sub1_tvalid;
    assign fifo_din2 = sub1_tdata;
    assign fifo_rd_en2 = fifo_rd_valid2;

    reg [31:0]  ln_valid_data;
    reg [31:0]  ln_valid_data_r1;
    reg [31:0]  ln_valid_data_r2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            ln_valid_data <= 32'b0;
        else if (ln_tvalid)
            ln_valid_data <= ln_tdata;
        else
            ln_valid_data <= ln_valid_data;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ln_valid_data_r1 <= 32'b0;
            ln_valid_data_r2 <= 32'b0;
        end
        else begin
            ln_valid_data_r1 <= ln_valid_data;
            ln_valid_data_r2 <= ln_valid_data_r1;
        end
    end
    wire [127:0] sub2_tdata;
    wire         sub2_tvalid;
    wire [31:0] sub2_tdata1 = sub2_tdata[31:0];
    wire [31:0] sub2_tdata2 = sub2_tdata[63:32];
    wire [31:0] sub2_tdata3 = sub2_tdata[97:64];
    wire [31:0] sub2_tdata4 = sub2_tdata[127:96];
    sub_array softmax_sub2(
        .clk           (clk),
        .a_tvalid      (fifo_rd_valid2_r2),
        .a_tdata       (fifo_dout2),
        .b_tvalid      (fifo_rd_valid2_r2),
        .b_tdata       ({ln_valid_data_r2,ln_valid_data_r2,ln_valid_data_r2,ln_valid_data_r2}),
        .result_tvalid (sub2_tvalid),
        .result_tdata  (sub2_tdata)
    );
    exp_array softmax_exp2(
        .clk           (clk),
        .a_tvalid      (sub2_tvalid),
        .a_tdata       (sub2_tdata),
        .result_tvalid (result_tvalid),
        .result_tdata  (result_tdata)
    );

endmodule