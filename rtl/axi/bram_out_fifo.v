module bram_out_fifo 
(
    input   wire                    clk     , 
    input   wire   [63:0]           din     , 
    input   wire                    wr_en   , 
    input   wire                    rd_en   , 
    output  reg    [31:0]           dout    
);

    reg [31:0]  data_reg        ;     
    reg         read_counter    ; 

    always @(posedge clk) begin
        if (wr_en) begin
            data_reg <= din[31:0]; 
        end
        else if (rd_en) begin
            data_reg <= data_reg;
        end
        else begin
            data_reg <= 32'b0;
        end
    end
    
    always @(posedge clk) begin
        if (rd_en)
            read_counter <= read_counter + 1;
        else
            read_counter <= 1'b0;
    end
    
    always @(*) begin
        if (~read_counter) begin
            dout = din[63:32];
        end
        else begin
            dout = data_reg;
        end
    end


endmodule