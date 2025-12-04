module bram_in_fifo 
(
    input   wire                    clk     , 
    input   wire   [31:0]           din     , 
    input   wire                    wr_en   , 
    input   wire                    rd_en   , 
    output  reg    [63:0]           dout    
);

    reg [31:0]  data_reg            ;     
    reg         write_counter       ; 

    always @(posedge clk) begin
        if (wr_en) begin
            if(~write_counter)begin
                data_reg  <= din  ;
            end
            else begin
                data_reg  <=  data_reg  ;
            end
        end
        else if (rd_en) begin
            data_reg <= data_reg;
        end
        else begin
            data_reg <= 32'b0;
        end
    end
    
    always @(posedge clk) begin
        if (wr_en)
            write_counter <= write_counter + 1;
        else
            write_counter <= 1'b0;
    end
    
    always @(*) begin
        if(rd_en)begin
            dout = {data_reg, din};
        end
        else begin
            dout = 64'b0;
        end
    end

endmodule