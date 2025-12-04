`timescale  1ns / 1ps

module uram_top
(
    input            rst_n  ,
    input            clk    ,
    input  [63 : 0]  dina   ,
    input  [13 : 0]  addra  ,
    input            wea    ,
    input  [13 : 0]  addrb  ,
    output [63 : 0]  doutb  ,
    input            enb
);

    parameter ADDR_WIDTH =  12      ;
    parameter DATA_WIDTH =  64      ;
    parameter DATA_DEPTH =  3100    ;

   xpm_memory_sdpram #(
      .ADDR_WIDTH_A(ADDR_WIDTH),      
      .ADDR_WIDTH_B(ADDR_WIDTH),      
      .AUTO_SLEEP_TIME(0), 
      .BYTE_WRITE_WIDTH_A(DATA_WIDTH), 
      .CASCADE_HEIGHT(0),             
      .CLOCKING_MODE("common_clock"), 
      .ECC_MODE("no_ecc"),            
      .MEMORY_INIT_FILE("none"),      
      .MEMORY_INIT_PARAM("0"),        
      .MEMORY_OPTIMIZATION("true"),   
      .MEMORY_PRIMITIVE("ultra"),     
      .MEMORY_SIZE(198400),          
      .MESSAGE_CONTROL(0),           
      .READ_DATA_WIDTH_B(DATA_WIDTH), 
      .READ_LATENCY_B(2),             
      .READ_RESET_VALUE_B("0"),       
      .RST_MODE_A("SYNC"),            
      .RST_MODE_B("SYNC"),            
      .SIM_ASSERT_CHK(0),             
      .USE_EMBEDDED_CONSTRAINT(0),    
      .USE_MEM_INIT(1),               
      .WAKEUP_TIME("disable_sleep"),  
      .WRITE_DATA_WIDTH_A(DATA_WIDTH), 
      .WRITE_MODE_B("read_first") 
   )
   xpm_memory_sdpram_inst (
      .dbiterrb( ),             
      .doutb(doutb),                   
      .sbiterrb( ),             
      .addra(addra),                
      .addrb(addrb),                
      .clka(clk),                   
      .clkb(clk),               
      .dina(dina),                  
      .ena(1'b1),                   
      .enb(enb),                    
      .injectdbiterra(1'b0), 
      .injectsbiterra(1'b0), 
      .regceb(1'b1),                
      .rstb(1'b0),                  
      .sleep(1'b0),                 
      .wea(wea)                     
   );

endmodule
