// this module is for BRAM to AXI-FULL write data channel
// It read data from BRAM and output to AXI-FULL write data channel

module BR2AW #(
    parameter integer TOTAL_NUM = 1536
)
(
    // Global Signals
    input   wire            axi_ACLK        ,
    input   wire            axi_ARESETN     ,
    input   wire            stage_start     ,
    // AXI4-FULL Write DATA Channel
    output  wire    [31:0]  write_data      ,
    output  wire            write_enable    ,
    input   wire            write_ready     ,
    // BRAM Write DATA Port
    output  wire    [0:0]   bram_enb        ,
    output  wire    [13:0]  bram_addrb      ,
    input   wire    [63:0]  bram_doutb      
);

    reg     [13:0]  addr_counter    ;   // BRAM addr counter
    wire            init_transfer   ;
    reg             init_txn_ff     ;
    reg             stage_start_reg ;
    reg             stage_start_reg2;

    reg             fifo_wr_en      ;
    reg             fifo_wr_en_reg  ;
    reg             fifo_rd_en      ;
    reg             fifo_rd_en_reg  ;
    wire    [31:0]  fifo_dout       ; 
    reg             fifo_counter    ;

    reg     [63:0]  bram_doutb_reg  ;

    always @(posedge axi_ACLK) begin                                                                        
        // Initiates AXI transaction delay    
        if (axi_ARESETN == 0) begin                                                                    
            init_txn_ff <= 1'b0;                                                                          
        end                                                                               
        else begin  
            init_txn_ff <= stage_start;                                                          
        end                                                                      
	end

    assign init_transfer = ~init_txn_ff & stage_start;

    always@(posedge axi_ACLK) begin
        if (!axi_ARESETN) begin
            stage_start_reg <= 1'b0;
            stage_start_reg2 <= 1'b0;
        end 
        else begin
            stage_start_reg <= stage_start;
            stage_start_reg2 <= stage_start_reg;
        end
    end

    always@(posedge axi_ACLK) begin
        if (!axi_ARESETN) begin
            bram_doutb_reg <= 64'b0;
        end 
        else begin
            bram_doutb_reg <= bram_doutb;
        end
    end

    always @(posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            fifo_counter <= 1'b0;
        end
        else begin
            if (stage_start_reg && write_ready)
                fifo_counter <= fifo_counter + 1;
            else
                fifo_counter <= 1'b0;
        end
    end

    bram_out_fifo data_64_32
    (
        .clk     (axi_ACLK             ), 
        .din     (bram_doutb           ), 
        .wr_en   (fifo_wr_en_reg       ), 
        .rd_en   (fifo_rd_en_reg       ), 
        .dout    (fifo_dout            )
    );

    always @ (posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            fifo_wr_en <= 1'b0;
            fifo_rd_en <= 1'b0;
            fifo_wr_en_reg <= 1'b0;
            fifo_rd_en_reg <= 1'b0;
        end
        else begin
            fifo_wr_en <= stage_start_reg && write_ready && ~fifo_counter && (addr_counter <= TOTAL_NUM - 1);
            fifo_wr_en_reg <= fifo_wr_en;
            fifo_rd_en <= stage_start_reg && write_ready && (addr_counter <= TOTAL_NUM - 1);
            fifo_rd_en_reg <= fifo_rd_en;
        end
    end

    // addr counter
    always @(posedge axi_ACLK) begin
        if (!axi_ARESETN || init_transfer) begin
            addr_counter <= 14'b0;
        end 
        else begin
            if(addr_counter <= TOTAL_NUM - 1) begin
                if (stage_start_reg && write_ready) begin
                    addr_counter <= addr_counter + 1;
                end
            end
            else begin
                addr_counter <= addr_counter;
            end
        end
    end

    assign write_data = fifo_dout;
    assign write_enable = fifo_rd_en_reg;

    assign bram_addrb = addr_counter >> 1;
    assign bram_enb = stage_start_reg && (addr_counter <= TOTAL_NUM - 1) && write_ready && ~fifo_counter;

endmodule