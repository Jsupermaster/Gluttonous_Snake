// this module is for AXI-Stream to BRAM write data
// It gets data from AXI-Stream interface (FROM ACCELERATOR) and writes to BRAM interface

module AS2BW #(
    parameter integer TOTAL_NUM = 768
)
(
    input   wire                clk             ,
    input   wire                rst_n           ,
    input   wire                stage_start     ,

    // AXI-Stream interface
    input   wire    [63:0]      a_tdata         ,
    input   wire                a_tvalid        ,

    // BRAM interface
    output  reg                 out_bram_wea    ,
    output  wire    [13:0]      out_bram_addra  ,
    output  reg     [63:0]      out_bram_dina   ,
    output  wire                stage_done
);

    wire                init_transfer       ;
    reg                 init_txn_ff         ;
    reg     [13:0]      addr_counter        ;
    reg                 stage_start_reg     ;
    reg                 stage_start_reg2    ;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge clk) begin                                                                            
        if (rst_n == 0) begin                                                                    
            init_txn_ff <= 1'b0;                                                                                      
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    always @(posedge clk) begin                                                                         
        if (rst_n == 0) begin                                                                    
            stage_start_reg <= 1'b0;     
            stage_start_reg2 <= 1'b0;                                                                 
        end                                                                               
        else begin  
            stage_start_reg <= stage_start;   
            stage_start_reg2 <= stage_start_reg;                                                 
        end                                                                      
	end

    always@(posedge clk) begin
        if (!rst_n || init_transfer) begin
            out_bram_wea <= 1'b0;
            out_bram_dina  <= 32'd0;
        end 
        else begin
            if (stage_start_reg && a_tvalid) begin
                out_bram_wea <= 1'b1;
                out_bram_dina <= a_tdata;
            end
            else begin
                out_bram_wea <= 1'b0;
                out_bram_dina  <= 32'd0;
            end
        end
    end

    always@(posedge clk) begin
        if (!rst_n || init_transfer) begin
            addr_counter <= 14'd0;
        end 
        else begin
            if (out_bram_wea) begin
                addr_counter <= addr_counter + 1;
            end
            else begin
                addr_counter <= addr_counter;
            end
        end
    end

    assign stage_done = stage_start_reg2 && (addr_counter == TOTAL_NUM);
    assign out_bram_addra = addr_counter;

endmodule