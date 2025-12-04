// The ADD_and_MUL block is for ADD and MUL.(use add_out_sel and mul_out_sel to control).
// ADD and MUL support 1 data/cycle.
// If add_out_sel is 1, add_result will be output; and the same as mul.
// If add_out_sel and mul_out_sel are both 1, add_result will be output; If add_out_sel and mul_out_sel are both 0, input_data will be output.
// If block_en = 001, the block will be normal calculating model, and block_en = 010, the block will be self-calculating model-1, do mul and 2 add, 100 will be self-calculating model-2, do mul and add.
// For self-calculating model, add will be use twice.
// cal_pattern = 0 represent add and cal_pattern = 1 represent epsilon_add
module add_mul_block #(
    parameter                   DATA_NUM = 10'd192
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input           [2:0]       block_en            ,
    input           [2:0]       input_sel_a         ,
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
    input           [127:0]     south_in_tdata      ,

    // signals for self-calculating model
    input                       mul_tvalid          ,
    input           [31:0]      mul_tdata           ,
    input                       add_tvalid          ,
    input           [31:0]      add_tdata           
);

    reg             [127:0]     input_add_atdata            ;
    reg                         input_add_atvalid           ;
    reg             [31:0]      input_mul_atdata            ;
    reg                         input_mul_atvalid           ;
    
    reg             [127:0]     input_add_btdata            ;
    reg                         input_add_btvalid           ;
    reg             [31:0]      input_mul_btdata            ;
    reg                         input_mul_btvalid           ;

    wire            [31:0]      result_add_tdata            ;
    wire                        result_add_tvalid           ;
    reg             [31:0]      result_add_tdata_delay1     ;
    reg                         result_add_tvalid_delay1    ;
    wire            [31:0]      result_mul_tdata            ;
    wire                        result_mul_tvalid           ;
    reg             [31:0]      result_mul_tdata_delay1     ;
    reg                         result_mul_tvalid_delay1    ;
    reg             [31:0]      result_mul_tdata_delay2     ;
    reg                         result_mul_tvalid_delay2    ;
    reg             [31:0]      result_mul_tdata_delay3     ;
    reg                         result_mul_tvalid_delay3    ;

    reg                         cal_pattern                 ;
    reg                         add_en                      ;
    reg             [9:0]       add_cnt                     ;
    reg             [31:0]      add_tdata_out               ;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_add_atdata <= 128'b0;
            input_add_atvalid <= 1'b0;
            cal_pattern       <= 1'b0;
        end
        else begin
            if(block_en[0]) begin
                case (input_sel_a)
                    3'b001: begin // east
                        input_add_atdata  <= east_in_tdata;
                        input_add_atvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_add_atdata  <= north_in_tdata;
                        input_add_atvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_add_atdata  <= south_in_tdata;
                        input_add_atvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_add_atdata <= 128'b0;
                        input_add_atvalid <= 1'b0;
                    end
                endcase
            end
            else if (block_en[1] && ~cal_pattern) begin
                input_add_atdata[127:96]  <= result_mul_tdata_delay3 ;
                input_add_atvalid <= result_mul_tvalid_delay3;
                if (result_add_tvalid) begin
                    cal_pattern <= ~cal_pattern;
                end
                else begin
                    cal_pattern <= cal_pattern;
                end
            end
            else if (block_en[1] && cal_pattern) begin
                input_add_atdata[127:96]  <= result_add_tdata_delay1 ;
                input_add_atvalid <= result_add_tvalid_delay1;
                if (result_add_tvalid) begin
                    cal_pattern <= ~cal_pattern;
                end
                else begin
                    cal_pattern <= cal_pattern;
                end
            end
            else if (block_en[2]) begin
                input_add_atdata[127:96]  <= result_mul_tdata_delay3 ;
                input_add_atvalid <= result_mul_tvalid_delay3;
                cal_pattern <= 1'b1;
            end
            else begin
                case (input_sel_a)
                    3'b001: begin // east
                        input_add_atdata  <= east_in_tdata;
                        input_add_atvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_add_atdata  <= north_in_tdata;
                        input_add_atvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_add_atdata  <= south_in_tdata;
                        input_add_atvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_add_atdata <= 128'b0;
                        input_add_atvalid <= 1'b0;
                    end
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_mul_atdata  <= 32'b0;
            input_mul_atvalid <= 1'b0;
        end
        else begin
            if(block_en[0]) begin
                case (input_sel_a)
                    3'b001: begin // east
                        input_mul_atdata  <= east_in_tdata[127:96];
                        input_mul_atvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_mul_atdata  <= north_in_tdata[127:96];
                        input_mul_atvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_mul_atdata  <= south_in_tdata[127:96];
                        input_mul_atvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_mul_atdata  <= 32'b0;
                        input_mul_atvalid <= 1'b0;
                    end
                endcase
            end
            else if(block_en[1] || block_en[2]) begin // MUL (after SUM)
                input_mul_atdata  <= north_in_tdata[127:96];
                input_mul_atvalid <= north_in_tvalid;
            end
            else begin
                input_mul_atdata <= 32'b0;
                input_mul_atvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_add_btdata <= 128'b0;
            input_add_btvalid <= 1'b0;
        end
        else begin
            if(block_en[0]) begin
                case (input_sel_b)
                    3'b001: begin // east
                        input_add_btdata  <= east_in_tdata;
                        input_add_btvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_add_btdata  <= north_in_tdata;
                        input_add_btvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_add_btdata  <= south_in_tdata;
                        input_add_btvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_add_btdata <= 128'b0;
                        input_add_btvalid <= 1'b0;
                    end
                endcase
            end
            else if (block_en[1] && ~cal_pattern) begin
                input_add_btdata[127:96]  <= {~east_in_tdata[127], east_in_tdata[126:96]} ;
                input_add_btvalid <= east_in_tvalid;
            end
            else if (block_en[1] && cal_pattern) begin
                input_add_btdata[127:96]  <= add_tdata ;
                input_add_btvalid   <= add_tvalid;
            end
            else if (block_en[2]) begin
                input_add_btdata[127:96]  <= add_tdata ;
                input_add_btvalid   <= add_tvalid;
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
            if(block_en[0]) begin
                case (input_sel_b)
                    3'b001: begin // east
                        input_mul_btdata  <= east_in_tdata[127:96];
                        input_mul_btvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_mul_btdata  <= north_in_tdata[127:96];
                        input_mul_btvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_mul_btdata  <= south_in_tdata[127:96];
                        input_mul_btvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_mul_btdata <= 32'b0;
                        input_mul_btvalid <= 1'b0;
                    end
                endcase
            end
            else if (block_en[1] || block_en[2]) begin
                input_mul_btdata  <= mul_tdata;
                input_mul_btvalid <= mul_tvalid;
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
            result_mul_tdata_delay2  <= 32'b0;
            result_mul_tvalid_delay2 <= 1'b0;
            result_mul_tdata_delay3  <= 32'b0;
            result_mul_tvalid_delay3 <= 1'b0;
            result_add_tdata_delay1  <= 32'b0;
            result_add_tvalid_delay1 <= 1'b0;
        end
        else begin
            result_mul_tdata_delay1  <= result_mul_tdata;
            result_mul_tvalid_delay1 <= result_mul_tvalid;
            result_mul_tdata_delay2  <= result_mul_tdata_delay1;
            result_mul_tvalid_delay2 <= result_mul_tvalid_delay1;
            result_mul_tdata_delay3  <= result_mul_tdata_delay2;
            result_mul_tvalid_delay3 <= result_mul_tvalid_delay2;
            result_add_tdata_delay1  <= result_add_tdata;
            result_add_tvalid_delay1 <= result_add_tvalid;
        end
    end

    //============ Broaden the sum signal ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            add_en <= 1'b0;
        else if (result_add_tvalid && cal_pattern)
            add_en <= 1'b1;
        else if ((add_cnt == DATA_NUM - 10'd1)&&((result_add_tvalid && cal_pattern) == 1'b0))
            add_en <= 1'b0;
        else
            add_en <= add_en;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            add_cnt <= 10'd0;
        else if (add_cnt == DATA_NUM - 10'd1)
            add_cnt <= 10'd0;
        else if (add_en) 
            add_cnt <= add_cnt + 10'd1;
        else
            add_cnt <= add_cnt;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            add_tdata_out <= 32'h0;
        else if (result_add_tvalid && cal_pattern)
            add_tdata_out <= result_add_tdata;
        else
            add_tdata_out <= add_tdata_out;
    end

    floating_add block_add (
        .aclk                       (clk                        ),             
        .s_axis_a_tvalid            (input_add_atvalid          ),        
        .s_axis_a_tdata             (input_add_atdata[127:96]   ),         
        .s_axis_b_tvalid            (input_add_btvalid          ),        
        .s_axis_b_tdata             (input_add_btdata[127:96]   ),         
        .m_axis_result_tvalid       (result_add_tvalid          ),   
        .m_axis_result_tdata        (result_add_tdata           )     
    );
    
    floating_mul block_mul (
        .aclk                       (clk                        ), 
        .s_axis_a_tvalid            (input_mul_atvalid          ), 
        .s_axis_a_tdata             (input_mul_atdata           ), 
        .s_axis_b_tvalid            (input_mul_btvalid          ), 
        .s_axis_b_tdata             (input_mul_btdata           ), 
        .m_axis_result_tvalid       (result_mul_tvalid          ), 
        .m_axis_result_tdata        (result_mul_tdata           )  
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
                west_out_tdata   <= add_output_sel[0] ?  {add_tdata_out, add_tdata_out, add_tdata_out, add_tdata_out}  : mul_output_sel[0] ?  {result_mul_tdata, result_mul_tdata, result_mul_tdata, result_mul_tdata}  : input_add_atdata    ;
                west_out_tvalid  <= add_output_sel[0] ?  add_en         : mul_output_sel[0] ?  result_mul_tvalid : input_add_atvalid   ;
                north_out_tdata  <= add_output_sel[1] ?  {add_tdata_out, add_tdata_out, add_tdata_out, add_tdata_out}  : mul_output_sel[1] ?  {result_mul_tdata, result_mul_tdata, result_mul_tdata, result_mul_tdata}  : input_add_atdata    ;
                north_out_tvalid <= add_output_sel[1] ?  add_en         : mul_output_sel[1] ?  result_mul_tvalid : input_add_atvalid   ;
            end
            else if(stage_start && ~(block_en[0] || block_en[1]))begin
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