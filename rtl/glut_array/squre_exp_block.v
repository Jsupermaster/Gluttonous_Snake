// The SQUARE_and_EXP block is for ADD and MUL.(use add_out_sel and mul_out_sel to control).
// SQUARE and EXP support 4 data/cycle.
// If squ_out_sel is 1, squ_result will be output; and the same as exp.
// If block_en = 01, the block will be normal calculating model, and block_en = 10, the block will be self-calculating model.
// For self-calculating model, the block will do mul and then exp.
module squre_exp_block
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input           [1:0]       block_en            ,
    input           [2:0]       input_sel_a         ,
    input           [2:0]       input_sel_b         ,
    input           [2:0]       squ_output_sel      ,
    input           [2:0]       exp_output_sel      ,

    // data signals
    input                       east_in_tvalid      ,
    input           [127:0]     east_in_tdata       ,

    input                       mul_tvalid          ,
    input           [127:0]     mul_tdata           ,

    output  reg                 west_out_tvalid     ,
    output  reg     [127:0]     west_out_tdata      ,

    output  reg                 north_out_tvalid    ,
    output  reg     [127:0]     north_out_tdata     ,

    input                       south_in_tvalid     ,
    input           [127:0]     south_in_tdata      ,
    output  reg                 south_out_tvalid    ,
    output  reg     [127:0]     south_out_tdata     

);

    reg             [127:0]     input_mul_atdata    ;
    reg                         input_mul_atvalid   ;
    reg             [127:0]     input_mul_btdata    ;
    reg                         input_mul_btvalid   ;
    reg             [127:0]     input_exp_tdata     ;
    reg                         input_exp_tvalid    ;

    wire            [127:0]     result_mul_tdata    ;
    wire            [3 : 0]     result_mul_tvalid   ;
    wire            [127:0]     result_exp_tdata    ;
    wire            [3 : 0]     result_exp_tvalid   ;

    wire            [127:0]    shared_selected_data;
    wire                       shared_selected_valid;
    wire            [1:0]      global_sel_state = {stage_start, |block_en};
    reg             [1:0]      west_sel, north_sel, south_sel;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_mul_atdata <= 128'b0;
            input_mul_atvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                if(input_sel_a[0]) begin
                    input_mul_atdata  <= east_in_tdata;
                    input_mul_atvalid <= east_in_tvalid;
                end
                else begin
                    input_mul_atdata  <= south_in_tdata;
                    input_mul_atvalid <= south_in_tvalid;
                end
            end
            else begin
                input_mul_atdata <= 32'b0;
                input_mul_atvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_mul_btdata <= 128'b0;
            input_mul_btvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                if(block_en[0]) begin
                    if(input_sel_b[0]) begin
                        input_mul_btdata  <= east_in_tdata;
                        input_mul_btvalid <= east_in_tvalid;
                    end
                    else begin
                        input_mul_btdata  <= south_in_tdata;
                        input_mul_btvalid <= south_in_tvalid;
                    end
                end
                else if(block_en[1]) begin
                    input_mul_btdata  <= mul_tdata  ;
                    input_mul_btvalid <= mul_tvalid ;
                end
                else begin
                    input_mul_btdata <= 32'b0;
                    input_mul_btvalid <= 1'b0;
                end
            end
            else begin
                input_mul_btdata <= 32'b0;
                input_mul_btvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_exp_tdata <= 128'b0;
            input_exp_tvalid <= 1'b0;
        end
        else begin
            if(block_en[0]) begin
                input_exp_tdata  <= south_in_tdata;
                input_exp_tvalid <= south_in_tvalid;
            end
            else if (block_en[1]) begin
                input_exp_tdata  <= result_mul_tdata;
                input_exp_tvalid <= &result_mul_tvalid;
            end
            else begin
                input_exp_tdata <= 128'b0;
                input_exp_tvalid <= 1'b0;
            end
        end
    end

    genvar i;

    for (i = 0; i < 4; i = i + 1) begin : block_squ_array
        floating_mul block_squ (
            .aclk                       (clk                                        ), 
            .s_axis_a_tvalid            (input_mul_atvalid                          ), 
            .s_axis_a_tdata             (input_mul_atdata[((i<<5)+31) : i<<5]       ), 
            .s_axis_b_tvalid            (input_mul_btvalid                          ), 
            .s_axis_b_tdata             (input_mul_btdata[((i<<5)+31) : i<<5]       ), 
            .m_axis_result_tvalid       (result_mul_tvalid[i]                       ), 
            .m_axis_result_tdata        (result_mul_tdata[((i<<5)+31) : i<<5]       )  
        );
    end

    for (i = 0; i < 4; i = i + 1) begin : block_exp_array
        floating_exp block_exp (
            .aclk                       (clk                                        ),
            .s_axis_a_tvalid            (input_exp_tvalid                           ),
            .s_axis_a_tdata             (input_exp_tdata[((i<<5)+31) : i<<5]        ),
            .m_axis_result_tvalid       (result_exp_tvalid[i]                       ),
            .m_axis_result_tdata        (result_exp_tdata[((i<<5)+31) : i<<5]       ) 
        );
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            west_sel  <= 2'b00;
            north_sel <= 2'b00;
            south_sel <= 2'b00;
        end else if (stage_start) begin
            west_sel  <= {squ_output_sel[0], exp_output_sel[0]};
            north_sel <= {squ_output_sel[1], exp_output_sel[1]};
            south_sel <= {squ_output_sel[2], exp_output_sel[2]};
        end
    end

    assign shared_selected_data = 
        (global_sel_state == 2'b11) ?  // stage_start && |block_en
            ((|squ_output_sel) ? result_mul_tdata : 
             (|exp_output_sel) ? result_exp_tdata : input_mul_atdata)
        : (global_sel_state == 2'b10) ? // stage_start && ~|block_en
            input_mul_atdata
        : 128'b0;
    
    assign shared_selected_valid = 
        (global_sel_state == 2'b11) ?
            ((|squ_output_sel) ? &result_mul_tvalid :
             (|exp_output_sel) ? &result_exp_tvalid : input_mul_atvalid)
        : (global_sel_state == 2'b10) ?
            input_mul_atvalid
        : 1'b0;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            west_out_tdata   <= 128'b0;
            west_out_tvalid  <= 1'b0;
            north_out_tdata  <= 128'b0;  
            north_out_tvalid <= 1'b0;
            south_out_tdata  <= 128'b0;
            south_out_tvalid <= 1'b0;
        end else begin
            west_out_tdata   <= shared_selected_data;
            north_out_tdata  <= shared_selected_data;
            south_out_tdata  <= shared_selected_data;
            
            west_out_tvalid  <= shared_selected_valid;
            north_out_tvalid <= shared_selected_valid; 
            south_out_tvalid <= shared_selected_valid;
        end
    end

    // // Finally, we need to determine the destination of the data.
    // always @(posedge clk) begin
    //     if(!rst_n) begin
    //         west_out_tdata   <= 128'b0;
    //         west_out_tvalid  <= 1'b0;
    //         north_out_tdata  <= 128'b0;
    //         north_out_tvalid <= 1'b0;
    //         south_out_tdata  <= 128'b0;
    //         south_out_tvalid <= 1'b0;
    //     end
    //     else begin
    //         if(stage_start && (|block_en)) begin
    //             west_out_tdata   <= squ_output_sel[0] ?   result_mul_tdata  : exp_output_sel[0] ?   result_exp_tdata  : input_mul_atdata    ;
    //             west_out_tvalid  <= squ_output_sel[0] ?  &result_mul_tvalid : exp_output_sel[0] ?  &result_exp_tvalid : input_mul_atvalid   ;
    //             north_out_tdata  <= squ_output_sel[1] ?   result_mul_tdata  : exp_output_sel[1] ?   result_exp_tdata  : input_mul_atdata    ;
    //             north_out_tvalid <= squ_output_sel[1] ?  &result_mul_tvalid : exp_output_sel[1] ?  &result_exp_tvalid : input_mul_atvalid   ;
    //             south_out_tdata  <= squ_output_sel[2] ?   result_mul_tdata  : exp_output_sel[2] ?   result_exp_tdata  : input_mul_atdata    ;
    //             south_out_tvalid <= squ_output_sel[2] ?  &result_mul_tvalid : exp_output_sel[2] ?  &result_exp_tvalid : input_mul_atvalid   ;
    //         end
    //         else if(stage_start && ~(|block_en))begin
    //             west_out_tdata   <= input_mul_atdata    ;
    //             west_out_tvalid  <= input_mul_atvalid   ;
    //             north_out_tdata  <= input_mul_atdata    ;
    //             north_out_tvalid <= input_mul_atvalid   ;
    //             south_out_tdata  <= input_mul_atdata    ;
    //             south_out_tvalid <= input_mul_atvalid   ;
    //         end
    //         else begin
    //             west_out_tdata   <= 128'b0;
    //             west_out_tvalid  <= 1'b0;
    //             north_out_tdata  <= 128'b0;
    //             north_out_tvalid <= 1'b0;
    //             south_out_tdata  <= 128'b0;
    //             south_out_tvalid <= 1'b0;
    //         end
    //     end
    // end

endmodule