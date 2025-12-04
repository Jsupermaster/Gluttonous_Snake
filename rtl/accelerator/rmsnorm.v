module RMSNORM(
    input   wire             clk            ,
    input   wire             rst_n          ,
    input   wire             stage_start    ,
    input   wire             a_tvalid       ,
    input   wire    [63:0]   a_tdata        ,
    output  wire             result_tvalid  ,
    output  wire    [127:0]  result_tdata   ,
    output  wire    [127:0]  fifo_din1       ,
    output  wire             fifo_wr_en1     ,
    input   wire    [127:0]  fifo_dout1      ,
    output  wire             fifo_rd_en1     
);
    parameter DATA_NUM = 8'd192;

    reg             in0_rmsnorm_tvalid;
    reg     [63:0]  in0_rmsnorm_tdata;
    wire            init_transfer;
    reg             init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            init_txn_ff <= 1'b0;
        end else begin
            init_txn_ff <= stage_start;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || init_transfer) begin
            in0_rmsnorm_tvalid <= 1'b0;
            in0_rmsnorm_tdata  <= 64'd0;
        end else begin
            if (stage_start) begin
                in0_rmsnorm_tvalid <= a_tvalid;
                in0_rmsnorm_tdata  <= a_tdata;
            end
            else begin
                in0_rmsnorm_tvalid <= in0_rmsnorm_tvalid;
                in0_rmsnorm_tdata  <= in0_rmsnorm_tdata;
            end
        end
    end
    wire [31:0] in0_rmsnorm_tdata1;
    wire [31:0] in0_rmsnorm_tdata2;
    wire [31:0] in0_rmsnorm_tdata3;
    wire [31:0] in0_rmsnorm_tdata4;
    assign in0_rmsnorm_tdata1 = {in0_rmsnorm_tdata[15:0],16'b0};
    assign in0_rmsnorm_tdata2 = {in0_rmsnorm_tdata[31:16],16'b0};
    assign in0_rmsnorm_tdata3 = {in0_rmsnorm_tdata[47:32],16'b0};
    assign in0_rmsnorm_tdata4 = {in0_rmsnorm_tdata[63:48],16'b0};
    wire        square_tvalid;
    wire [127:0]square_tdata;
    reg         square_tlast;
    reg [7:0]   square_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            square_cnt <= 8'd0;
            square_tlast   <= 1'b0;
        end 
        else if (square_tvalid) begin
            if (square_cnt == DATA_NUM - 8'd2) begin
                square_tlast   <= 1'b1;
                square_cnt <= square_cnt + 8'd1;
            end 
            else if (square_cnt == DATA_NUM - 8'd1) begin
                square_tlast   <= 1'b0;
                square_cnt <= 8'd0;
            end 
            else begin
                square_tlast   <= 1'b0;
                square_cnt <= square_cnt + 8'd1;
            end
        end
        else begin
            square_cnt <= square_cnt;
            square_tlast   <= square_tlast;
        end
    end

    mul_array rms_square(
        .clk            (clk),
        .a_tvalid       (in0_rmsnorm_tvalid),
        .a_tdata        ({in0_rmsnorm_tdata4,in0_rmsnorm_tdata3,in0_rmsnorm_tdata2,in0_rmsnorm_tdata1}),
        .b_tvalid       (in0_rmsnorm_tvalid),
        .b_tdata        ({in0_rmsnorm_tdata4,in0_rmsnorm_tdata3,in0_rmsnorm_tdata2,in0_rmsnorm_tdata1}),
        .result_tvalid  (square_tvalid),
        .result_tdata   (square_tdata)
    );

    wire [31:0]  sum_tdata;
    wire         sum_tvalid;

    acc_array rms_accumulate(
        .clk            (clk),
        .a_tvalid       (square_tvalid),
        .a_tdata        (square_tdata),
        .a_tlast        (square_tlast),
        .result_tvalid  (sum_tvalid),
        .result_tdata   (sum_tdata)
    );
    wire [31:0] mul_tdata;
    wire        mul_tvalid;
    wire [31:0] n_1 = 32'h3aaaaaab;
    
    mul rms_mul_n (
        .aclk                   (clk),
        .s_axis_a_tvalid        (sum_tvalid),
        .s_axis_a_tdata         (sum_tdata),
        .s_axis_b_tvalid        (sum_tvalid),
        .s_axis_b_tdata         (n_1),
        .m_axis_result_tvalid   (mul_tvalid),
        .m_axis_result_tdata    (mul_tdata)
    );

    wire [31:0] add_tdata;
    wire        add_tvalid;
    wire [31:0] epsilon = 32'h3727c5ac;

    add rms_add_epsilon (
        .aclk                   (clk),
        .s_axis_a_tvalid        (mul_tvalid),
        .s_axis_a_tdata         (mul_tdata),
        .s_axis_b_tvalid        (mul_tvalid),
        .s_axis_b_tdata         (epsilon),
        .m_axis_result_tvalid   (add_tvalid),
        .m_axis_result_tdata    (add_tdata)
    );

    wire [31:0] rsqrt_tdata;
    wire        rsqrt_tvalid;
    
    rsqrt_root rms_rsquart_root (
        .aclk                   (clk),
        .s_axis_a_tvalid        (add_tvalid),
        .s_axis_a_tdata         (add_tdata),
        .m_axis_result_tvalid   (rsqrt_tvalid),
        .m_axis_result_tdata    (rsqrt_tdata)
    );

    reg         fifo_rd_valid;
    reg [7:0]   batch_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            fifo_rd_valid <= 1'b0;
        else if (rsqrt_tvalid) 
            fifo_rd_valid <= 1'b1;
        else if ((batch_cnt == DATA_NUM - 8'd1)&&(rsqrt_tvalid==1'b0))
            fifo_rd_valid <= 1'b0;
        else
            fifo_rd_valid <= fifo_rd_valid;
    end
    reg         fifo_rd_valid_r1;
    reg         fifo_rd_valid_r2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fifo_rd_valid_r1 <= 1'b0;
            fifo_rd_valid_r2 <= 1'b0;
        end
        else begin
            fifo_rd_valid_r1 <= fifo_rd_valid;
            fifo_rd_valid_r2 <= fifo_rd_valid_r1;
        end
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            batch_cnt <= 8'd0;
        else if (batch_cnt == DATA_NUM - 8'd1)
            batch_cnt <= 8'd0;
        else if (fifo_rd_valid) 
            batch_cnt <= batch_cnt + 8'd1;
        else
            batch_cnt <= batch_cnt;
    end

    assign fifo_wr_en1 = in0_rmsnorm_tvalid;
    assign fifo_din1 = {in0_rmsnorm_tdata4,in0_rmsnorm_tdata3,in0_rmsnorm_tdata2,in0_rmsnorm_tdata1};
    assign fifo_rd_en1 = fifo_rd_valid;

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
    mul_array rms_multiply (
        .clk             (clk),
        .a_tvalid        (fifo_rd_valid_r2),
        .a_tdata         ({rsqrt_valid_data_r2,rsqrt_valid_data_r2,rsqrt_valid_data_r2,rsqrt_valid_data_r2}),
        .b_tvalid        (fifo_rd_valid_r2),
        .b_tdata         (fifo_dout1),
        .result_tvalid   (result_tvalid),
        .result_tdata    (result_tdata)
    );

endmodule