// A basic block has four ports: East, West, South, and North.
// The East and West ports are unidirectional. The East port is used only for data input, while the West port is used only for data output.
// The South and North ports are bidirectional, with each supporting both input and output.
// The block can be configured into one of 7 operational modes: ADD, MUL, SQUARE, EXP, REC, RSR or LN.
// The block_en signal indicates whether the incoming data should be processed by this block. If enabled (block_en=1), the computation is performed; if not, the data is bypassed and output after a two-cycle delay.
// The input_sel signal (3-bit one-hot encoded) selects the data source: 001 for East, 010 for North, and 100 for South.
// The output_sel signal (3-bit one-hot encoded) selects the data destination: 001 for West, 010 for North, and 100 for South.
// The "output_sel" can be used to specify the output ports for the valid data. The three digits represent three ports. If it is 1, the valid signal is output; if it is 0, the input signal delayed by two periods is output. 
// For example, 110 means that the north and south ports output the valid signal, and the west port outputs the delayed input signal.
module basic_block #(
    parameter                   pattern = "ADD"
)
(
    // global control signals
    input                       clk                 ,
    input                       rst_n               ,
    input                       stage_start         ,
    input                       block_en            ,
    input           [2:0]       input_sel_a         ,
    input           [2:0]       input_sel_b         ,
    input           [2:0]       output_sel          ,

    // data signals
    input                       east_in_tvalid      ,
    input           [31:0]      east_in_tdata       ,

    output  reg                 west_out_tvalid     ,
    output  reg     [31:0]      west_out_tdata      ,

    input                       north_in_tvalid     ,
    input           [31:0]      north_in_tdata      ,
    output  reg                 north_out_tvalid    ,
    output  reg     [31:0]      north_out_tdata     ,

    input                       south_in_tvalid     ,
    input           [31:0]      south_in_tdata      ,
    output  reg                 south_out_tvalid    ,
    output  reg     [31:0]      south_out_tdata     
);

    reg     [31:0]      input_atdata     ;
    reg                 input_atvalid    ;
    reg     [31:0]      input_btdata     ;
    reg                 input_btvalid    ;

    wire    [31:0]      result_tdata     ;
    wire                result_tvalid    ;

    // First, we need to determine the source of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            input_atdata <= 32'b0;
            input_atvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                case (input_sel_a)
                    3'b001: begin // east
                        input_atdata  <= east_in_tdata;
                        input_atvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_atdata  <= north_in_tdata;
                        input_atvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_atdata  <= south_in_tdata;
                        input_atvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_atdata <= 32'b0;
                        input_atvalid <= 1'b0;
                    end
                endcase
            end
            else begin
                input_atdata <= 32'b0;
                input_atvalid <= 1'b0;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            input_btdata <= 32'b0;
            input_btvalid <= 1'b0;
        end
        else begin
            if(stage_start) begin
                case (input_sel_b)
                    3'b001: begin // east
                        input_btdata  <= east_in_tdata;
                        input_btvalid <= east_in_tvalid;
                    end
                    3'b010: begin  // north
                        input_btdata  <= north_in_tdata;
                        input_btvalid <= north_in_tvalid;
                    end
                    3'b100: begin // south
                        input_btdata  <= south_in_tdata;
                        input_btvalid <= south_in_tvalid;
                    end
                    default: begin
                        input_btdata <= 32'b0;
                        input_btvalid <= 1'b0;
                    end
                endcase
            end
            else begin
                input_btdata <= 32'b0;
                input_btvalid <= 1'b0;
            end
        end
    end

    generate
        case(pattern)
            "ADD" : begin
            floating_add block_add (
                .aclk                       (clk                ),             
                .s_axis_a_tvalid            (input_atvalid      ),        
                .s_axis_a_tdata             (input_atdata       ),         
                .s_axis_b_tvalid            (input_btvalid      ),        
                .s_axis_b_tdata             (input_btdata       ),         
                .m_axis_result_tvalid       (result_tvalid      ),   
                .m_axis_result_tdata        (result_tdata       )     
            );
            end
            
            "MUL" : begin
            floating_mul block_mul (
                .aclk                       (clk                ), 
                .s_axis_a_tvalid            (input_atvalid      ), 
                .s_axis_a_tdata             (input_atdata       ), 
                .s_axis_b_tvalid            (input_btvalid      ), 
                .s_axis_b_tdata             (input_btdata       ), 
                .m_axis_result_tvalid       (result_tvalid      ), 
                .m_axis_result_tdata        (result_tdata       )  
            );
            end

            "SQUARE" : begin
            floating_mul block_squ (
                .aclk                       (clk                ), 
                .s_axis_a_tvalid            (input_atvalid      ), 
                .s_axis_a_tdata             (input_atdata       ), 
                .s_axis_b_tvalid            (input_atvalid      ), 
                .s_axis_b_tdata             (input_atdata       ), 
                .m_axis_result_tvalid       (result_tvalid      ), 
                .m_axis_result_tdata        (result_tdata       )  
            );
            end

            "EXP" : begin
            floating_exp block_exp (
                .aclk                       (clk                ),
                .s_axis_a_tvalid            (input_atvalid      ),
                .s_axis_a_tdata             (input_atdata       ),
                .m_axis_result_tvalid       (result_tvalid      ),
                .m_axis_result_tdata        (result_tdata       ) 
            );
            end

            "REC" : begin
            floating_rec block_rec (
                .aclk                       (clk                ),
                .s_axis_a_tvalid            (input_atvalid      ),
                .s_axis_a_tdata             (input_atdata       ),
                .m_axis_result_tvalid       (result_tvalid      ),
                .m_axis_result_tdata        (result_tdata       ) 
            );
            end

            "RSR" : begin
            floating_rsr block_rsr (
                .aclk                       (clk                ),
                .s_axis_a_tvalid            (input_atvalid      ),
                .s_axis_a_tdata             (input_atdata       ),
                .m_axis_result_tvalid       (result_tvalid      ),
                .m_axis_result_tdata        (result_tdata       ) 
            );
            end
            
            "LN" : begin
            floating_ln block_ln (
                .aclk                       (clk                ),
                .s_axis_a_tvalid            (input_atvalid      ),
                .s_axis_a_tdata             (input_atdata       ),
                .m_axis_result_tvalid       (result_tvalid      ),
                .m_axis_result_tdata        (result_tdata       ) 
            );
            end
            
            default : begin
            floating_add block_add (
                .aclk                       (clk                ),             
                .s_axis_a_tvalid            (input_atvalid      ),        
                .s_axis_a_tdata             (input_atdata       ),         
                .s_axis_b_tvalid            (input_btvalid      ),        
                .s_axis_b_tdata             (input_btdata       ),         
                .m_axis_result_tvalid       (result_tvalid      ),   
                .m_axis_result_tdata        (result_tdata       )     
            );
            end
        endcase
    endgenerate

    // Finally, we need to determine the destination of the data.
    always @(posedge clk) begin
        if(!rst_n) begin
            west_out_tdata   <= 32'b0;
            west_out_tvalid  <= 1'b0;
            north_out_tdata  <= 32'b0;
            north_out_tvalid <= 1'b0;
            south_out_tdata  <= 32'b0;
            south_out_tvalid <= 1'b0;
        end
        else begin
            if(stage_start && block_en) begin
                west_out_tdata   <= output_sel[0] ? result_tdata  : input_atdata    ;
                west_out_tvalid  <= output_sel[0] ? result_tvalid : input_atvalid   ;
                north_out_tdata  <= output_sel[1] ? result_tdata  : input_atdata    ;
                north_out_tvalid <= output_sel[1] ? result_tvalid : input_atvalid   ;
                south_out_tdata  <= output_sel[2] ? result_tdata  : input_atdata    ;
                south_out_tvalid <= output_sel[2] ? result_tvalid : input_atvalid   ;
            end
            else if(stage_start && ~block_en)begin
                west_out_tdata   <= input_atdata    ;
                west_out_tvalid  <= input_atvalid   ;
                north_out_tdata  <= input_atdata    ;
                north_out_tvalid <= input_atvalid   ;
                south_out_tdata  <= input_atdata    ;
                south_out_tvalid <= input_atvalid   ;
            end
            else begin
                west_out_tdata   <= 32'b0;
                west_out_tvalid  <= 1'b0;
                north_out_tdata  <= 32'b0;
                north_out_tvalid <= 1'b0;
                south_out_tdata  <= 32'b0;
                south_out_tvalid <= 1'b0;
            end
        end
    end

endmodule