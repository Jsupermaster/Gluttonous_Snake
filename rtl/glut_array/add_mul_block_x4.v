// The ADD_and_MUL block is for ADD and MUL.(use add_out_sel and mul_out_sel to control).
// ADD support 4 data/cycle, and MUL support 1.
// If add_out_sel is 1, add_result will be output; and the same as mul.
// If add_out_sel and mul_out_sel are both 1, add_result will be output; If add_out_sel and mul_out_sel are both 0, input_data will be output.
// If block_en = 01, the block will be normal calculating model, and block_en = 10, the block will be self-calculating model.
// For self-calculating model, input_add_btdata will be result_mul_tdata and mul will be use to do square.
// cal_pattern = 0 represent MUL and cal_pattern = 1 represent SQUARE
module add_mul_block_x4 #(
    parameter                   DATA_NUM = 10'd192
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input           [1:0]       block_en            ,
    input           [3:0]       input_sel_a         , // 1000 is fifo
    input           [2:0]       input_sel_b         ,
    input           [2:0]       add_output_sel      ,
    input           [2:0]       mul_output_sel      ,

    // data signals
    input                       east_in_tvalid      ,
    input           [127:0]     east_in_tdata       ,

    output  reg                 west_out_tvalid     ,
    output  reg     [127:0]     west_out_tdata      ,

    input                       north_in_tvalid     ,
    input           [127:0]     north_in_tdata      ,
    output  reg                 north_out_tvalid    ,
    output  reg     [127:0]     north_out_tdata     ,

    input                       south_in_tvalid     ,
    input           [127:0]     south_in_tdata      , // cal data

    // signals for self-calculating model
    output                      fifo_read_en        ,
    input                       fifo_in_tvalid      ,
    input           [127:0]     fifo_in_tdata       
);

    reg             [127:0]     input_add_atdata            ;
    reg                         input_add_atvalid           ;
    reg             [31:0]      input_mul_atdata            ;
    reg                         input_mul_atvalid           ;
    
    reg             [127:0]     input_add_btdata            ;
    reg                         input_add_btvalid           ;
    reg             [31:0]      input_mul_btdata            ;
    reg                         input_mul_btvalid           ;

    wire            [127:0]     result_add_tdata            ;
    wire            [3 : 0]     result_add_tvalid           ;
    wire            [31 :0]     result_mul_tdata            ;
    wire                        result_mul_tvalid           ;
    reg             [31 :0]     result_mul_tdata_delay1     ;
    reg                         result_mul_tvalid_delay1    ;

    reg                         cal_pattern                 ;
    reg                         mul_sum_en                  ;
    reg                         mul_sum_en_delay1           ;
    reg             [9:0]       mul_sum_cnt                 ;
    reg             [31:0]      mul_sum_tdata_out           ;
    reg             [31:0]      mul_sum_tdata_out_delay1    ;

    reg                         mul_squ_en                  ;
    reg             [9:0]       mul_squ_cnt                 ;
    reg             [127:0]     mul_squ_tdata_out           ;

    wire            [31:0]      self_mul_data               ;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_add_atdata <= 128'b0;
            input_add_atvalid <= 1'b0;
        end
        else begin
            if(block_en[0]) begin // normal
                if (input_sel_a[1]) begin // north
                    input_add_atdata  <= north_in_tdata;
                    input_add_atvalid <= north_in_tvalid;
                end
                else if (input_sel_a[3]) begin // fifo
                    input_add_atdata  <= fifo_in_tdata ;
                    input_add_atvalid <= fifo_in_tvalid;
                end
                else begin
                    input_add_atdata <= 128'b0;
                    input_add_atvalid <= 1'b0;
                end
            end
            else if (block_en[1]) begin // self
                input_add_atdata  <= fifo_in_tdata ;
                input_add_atvalid <= fifo_in_tvalid;
            end
            else begin // by pass
                input_add_atdata  <= east_in_tdata;
                input_add_atvalid <= east_in_tvalid;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_mul_atdata  <= 32'b0;
            input_mul_atvalid <= 1'b0;
            cal_pattern       <= 1'b0;
        end
        else begin
            if(block_en[1] && cal_pattern) begin // SQUARE
                input_mul_atdata  <= result_mul_tdata_delay1;
                input_mul_atvalid <= result_mul_tvalid_delay1;
                if (result_mul_tvalid) begin
                    cal_pattern <= ~cal_pattern;
                end
                else begin
                    cal_pattern <= cal_pattern;
                end
            end
            else if(block_en[1] && ~cal_pattern) begin // MUL (after SUM)
                input_mul_atdata  <= east_in_tdata[127:96]  ;
                input_mul_atvalid <= east_in_tvalid         ;
                if (result_mul_tvalid) begin
                    cal_pattern <= ~cal_pattern;
                end
                else begin
                    cal_pattern <= cal_pattern;
                end
            end
            else begin
                input_mul_atdata <= 32'b0;
                input_mul_atvalid <= 1'b0;
            end
        end
    end

    assign self_mul_data = {~mul_sum_tdata_out_delay1[31], mul_sum_tdata_out_delay1[30:0]};

    always @(posedge clk) begin
        if(!rst_n) begin
            input_add_btdata <= 128'b0;
            input_add_btvalid <= 1'b0;
        end
        else begin
            if(block_en[0]) begin // normal
                if (input_sel_b[2]) begin // south (cal data)
                    input_add_btdata  <= south_in_tdata;
                    input_add_btvalid <= south_in_tvalid;
                end
                else if (input_sel_b[0]) begin // east
                    input_add_btdata  <= east_in_tdata;
                    input_add_btvalid <= east_in_tvalid;
                end
                else begin
                    input_add_btdata <= 128'b0;
                    input_add_btvalid <= 1'b0;
                end
            end
            else if (block_en[1]) begin // self
                input_add_btdata  <= {self_mul_data, self_mul_data, self_mul_data, self_mul_data};
                input_add_btvalid <= mul_sum_en_delay1;
            end
            else begin
                input_add_btdata <= 128'b0;
                input_add_btvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_mul_btdata <= 32'b0;
            input_mul_btvalid <= 1'b0;
        end
        else begin
            if (block_en[1] && cal_pattern) begin
                input_mul_btdata  <= result_mul_tdata_delay1;
                input_mul_btvalid <= result_mul_tvalid_delay1;
            end
            else if (block_en[1] && ~cal_pattern) begin
                input_mul_btdata  <= south_in_tdata[127:96];
                input_mul_btvalid <= south_in_tvalid;
            end
            else begin
                input_mul_btdata <= 32'b0;
                input_mul_btvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            result_mul_tdata_delay1  <= 32'b0;
            result_mul_tvalid_delay1 <= 1'b0;
            mul_sum_en_delay1        <= 1'b0;
            mul_sum_tdata_out_delay1 <= 32'b0;
        end
        else begin
            result_mul_tdata_delay1  <= result_mul_tdata;
            result_mul_tvalid_delay1 <= result_mul_tvalid;
            mul_sum_en_delay1        <= mul_sum_en;
            mul_sum_tdata_out_delay1 <= mul_sum_tdata_out;
        end
    end

    //============ Broaden the sum signal ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_sum_en <= 1'b0;
        else if (result_mul_tvalid && ~cal_pattern)
            mul_sum_en <= 1'b1;
        else if ((mul_sum_cnt == DATA_NUM - 10'd1)&&((result_mul_tvalid && ~cal_pattern) == 1'b0))
            mul_sum_en <= 1'b0;
        else
            mul_sum_en <= mul_sum_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_sum_cnt <= 10'd0;
        else if (mul_sum_cnt == DATA_NUM - 10'd1)
            mul_sum_cnt <= 10'd0;
        else if (mul_sum_en) 
            mul_sum_cnt <= mul_sum_cnt + 10'd1;
        else
            mul_sum_cnt <= mul_sum_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_sum_tdata_out <= 32'h0;
        else if (result_mul_tvalid && ~cal_pattern)
            mul_sum_tdata_out <= result_mul_tdata;
        else
            mul_sum_tdata_out <= mul_sum_tdata_out;
    end

    //============ Broaden the squ signal ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_squ_en <= 1'b0;
        else if (result_mul_tvalid && cal_pattern)
            mul_squ_en <= 1'b1;
        else if ((mul_squ_cnt == DATA_NUM - 10'd1)&&((result_mul_tvalid && cal_pattern) == 1'b0))
            mul_squ_en <= 1'b0;
        else
            mul_squ_en <= mul_squ_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_squ_cnt <= 10'd0;
        else if (mul_squ_cnt == DATA_NUM - 10'd1)
            mul_squ_cnt <= 10'd0;
        else if (mul_squ_en) 
            mul_squ_cnt <= mul_squ_cnt + 10'd1;
        else
            mul_squ_cnt <= mul_squ_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            mul_squ_tdata_out <= 128'h0;
        else if (result_mul_tvalid && cal_pattern)
            mul_squ_tdata_out <= {result_mul_tdata, result_mul_tdata, result_mul_tdata, result_mul_tdata};
        else
            mul_squ_tdata_out <= mul_squ_tdata_out;
    end

    assign fifo_read_en = mul_sum_en;

    genvar i;

    for (i = 0; i < 4; i = i + 1) begin : block_add_array
        floating_add block_add (
            .aclk                       (clk                                    ),             
            .s_axis_a_tvalid            (input_add_atvalid                      ),        
            .s_axis_a_tdata             (input_add_atdata[((i<<5)+31) : i<<5]   ),         
            .s_axis_b_tvalid            (input_add_btvalid                      ),        
            .s_axis_b_tdata             (input_add_btdata[((i<<5)+31) : i<<5]   ),         
            .m_axis_result_tvalid       (result_add_tvalid[i]                   ),   
            .m_axis_result_tdata        (result_add_tdata[((i<<5)+31) : i<<5]   )     
        );
    end
    
    floating_mul block_mul (
        .aclk                       (clk                    ), 
        .s_axis_a_tvalid            (input_mul_atvalid      ), 
        .s_axis_a_tdata             (input_mul_atdata       ), 
        .s_axis_b_tvalid            (input_mul_btvalid      ), 
        .s_axis_b_tdata             (input_mul_btdata       ), 
        .m_axis_result_tvalid       (result_mul_tvalid      ), 
        .m_axis_result_tdata        (result_mul_tdata       )  
    );

    // Finally, we need to determine the destination of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            west_out_tdata   <= 128'b0;
            west_out_tvalid  <= 1'b0;
            north_out_tdata  <= 128'b0;
            north_out_tvalid <= 1'b0;
        end
        else begin
            if(stage_start && (|block_en)) begin
                west_out_tdata   <= add_output_sel[0] ?  result_add_tdata  : (mul_output_sel[0]) ?  mul_squ_tdata_out   : input_add_atdata    ;
                west_out_tvalid  <= add_output_sel[0] ? &result_add_tvalid : (mul_output_sel[0]) ?  mul_squ_en          : input_add_atvalid   ;
                north_out_tdata  <= add_output_sel[1] ?  result_add_tdata  : (mul_output_sel[1]) ?  mul_squ_tdata_out   : input_add_atdata    ;
                north_out_tvalid <= add_output_sel[1] ? &result_add_tvalid : (mul_output_sel[1]) ?  mul_squ_en          : input_add_atvalid   ;
            end
            else if(stage_start && ~(|block_en))begin
                west_out_tdata   <= input_add_atdata    ;
                west_out_tvalid  <= input_add_atvalid   ;
                north_out_tdata  <= input_add_atdata    ;
                north_out_tvalid <= input_add_atvalid   ;
            end
            else begin
                west_out_tdata   <= 128'b0;
                west_out_tvalid  <= 1'b0;
                north_out_tdata  <= 128'b0;
                north_out_tvalid <= 1'b0;
            end
        end
    end

endmodule