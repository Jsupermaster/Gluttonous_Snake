// This module converts serial input data into parallel output data.

module DIN_TRANS #(
    parameter integer DATA_NUM = 9'd384
)
(
    // Global Signals
    input  wire         axi_ACLK                ,
    input  wire         axi_ARESETN             ,
    input  wire         stage_start             ,
    // AXI4-FULL Read DATA Channel
    input  wire [31:0]  axi_RDATA               ,
    input  wire         axi_RLAST               ,
    input  wire         axi_SHAKE               ,
    // BRAM Write DATA Port0
    output wire         bram_wea       [15:0]   ,
    output wire [13:0]  bram_addra     [15:0]   ,
    output wire [63:0]  bram_dina      [15:0]   ,
    output wire         bram_wdone     [15:0]              
);

    reg     [8:0]       data_in_counter;
    reg     [4:0]       bram_sel;
    reg     [6:0]       row_num;

    wire init_transfer;

    reg init_txn_ff;

    assign init_transfer = ~init_txn_ff & stage_start;

    always @(posedge axi_ACLK) begin                                                                        
        // Initiates AXI transaction delay    
        if (axi_ARESETN == 0) begin                                                                    
            init_txn_ff <= 1'b0;    
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    always @(posedge axi_ACLK) begin
        if(!axi_ARESETN || init_transfer) begin
            data_in_counter <= 9'd0;
            row_num <= 7'b0;
        end
        else if(data_in_counter == DATA_NUM - 9'd1)begin
            data_in_counter <= 9'd0;
            row_num <= row_num + 1'b1;
        end
        else if(axi_SHAKE) 
            data_in_counter <= data_in_counter + 9'd1;
        else
            data_in_counter <= data_in_counter;
    end

    always @(posedge axi_ACLK) begin
        if(!axi_ARESETN || init_transfer)
            bram_sel <= 4'd0;
        else if(row_num < 7'd4)
            bram_sel <= 4'd0;
        else if((row_num >= 7'd4) && (row_num < 7'd8))
            bram_sel <= 4'd1;
        else if((row_num >= 7'd8) && (row_num < 7'd12))
            bram_sel <= 4'd2;
        else if((row_num >= 7'd12) && (row_num < 7'd16))
            bram_sel <= 4'd3;
        else if((row_num >= 7'd16) && (row_num < 7'd20))
            bram_sel <= 4'd4;
        else if((row_num >= 7'd20) && (row_num < 7'd24))
            bram_sel <= 4'd5;
        else if((row_num >= 7'd24) && (row_num < 7'd28))
            bram_sel <= 4'd6;
        else if((row_num >= 7'd28) && (row_num < 7'd32))
            bram_sel <= 4'd7;
        else if((row_num >= 7'd32) && (row_num < 7'd36))
            bram_sel <= 4'd8;
        else if((row_num >= 7'd36) && (row_num < 7'd40))
            bram_sel <= 4'd9;
        else if((row_num >= 7'd40) && (row_num < 7'd44))
            bram_sel <= 4'd10;
        else if((row_num >= 7'd44) && (row_num < 7'd48))
            bram_sel <= 4'd11;
        else if((row_num >= 7'd48) && (row_num < 7'd52))
            bram_sel <= 4'd12;
        else if((row_num >= 7'd52) && (row_num < 7'd56))
            bram_sel <= 4'd13;
        else if((row_num >= 7'd56) && (row_num < 7'd60))
            bram_sel <= 4'd14;
        else if((row_num >= 7'd60) && (row_num < 7'd64))
            bram_sel <= 4'd15;
        else
            bram_sel <= bram_sel;
    end

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin: gen_bram_interface
            AR2BW bram0_AR2BW(
            .axi_ACLK           (axi_ACLK                                   ),
            .axi_ARESETN        (axi_ARESETN                                ),
            .stage_start        (stage_start                                ),
            .axi_RDATA          (axi_RDATA                                  ),
            .axi_RLAST          (axi_RLAST                                  ),
            .axi_SHAKE          (axi_SHAKE && (bram_sel == i)               ),
            .bram_wea           (bram_wea[i]                                ),
            .bram_addra         (bram_addra[i]                              ),
            .bram_dina          (bram_dina[i]                               ),
            .bram_wdone         (bram_wdone[i]                              )
        );
        end
    endgenerate


endmodule