`timescale 1ns / 1ps
module fmul_bf16(
        input   wire            clk             ,
        input   wire [15:0]     atdata          ,
        input   wire            a_tvalid        ,
        input   wire [15:0]     btdata          ,
        input   wire            b_tvalid        ,
        output  reg  [15:0]     result_tdata    ,
        output  reg             result_tvalid
    );

    wire            input_valid         ;
    reg             input_valid_delay1  ;
    reg             input_valid_delay2  ;
    reg             input_valid_delay3  ;
    reg             input_valid_delay4  ;
    reg             input_valid_delay5  ;
    reg             input_valid_delay6  ;
    reg             input_valid_delay7  ;
    reg             s1                  ;
    reg             s2                  ;
    reg     [7:0]   e1                  ;
    reg     [7:0]   e2                  ;
    reg     [6:0]   m1                  ;
    reg     [6:0]   m2                  ;
    reg             input_nan           ;
    reg             input_nan_delay1    ;
    reg             sy                  ;
    reg     [9:0]   eyp                 ;
    reg     [9:0]   eypi                ;
    (* use_dsp48 = "yes" *)reg     [15:0]  p1                  ;

    reg     [15:0]  p2                  ;
    reg     [7:0]   e1_delay1           ;
    reg     [7:0]   e2_delay1           ;
    reg     [7:0]   eyp_2, eypi_2       ;
    reg             input_nan_delay2    ;
    reg             underflow           ;
    reg             ovf_f               ;
    reg             sy_delay1           ;

    reg     [15:0]  p3                  ;
    reg             ovf                 ;
    reg             underflow_delay1    ;
    reg             input_nan_delay3    ;
    reg     [7:0]   eyp_3, eypi_3       ;
    reg             sy_delay2           ;

    reg     [7:0]   ey                  ;
    reg     [6:0]   my                  ;
    reg             sy_delay3           ;
    reg             guard_bit           ;
    reg             round_bit           ;
    reg             sticky_bit          ;

    reg             bf16_is_nan         ;
    reg             bf16_is_inf         ;
    reg             bf16_is_zero        ;
    reg             bf16_is_denormal    ;
    reg             round_up            ;
    reg             sy_delay4           ;
    reg     [6:0]   my_2                ;
    reg     [7:0]   ey_2                ;
    
    reg     [15:0]  special_case_bf16   ;
    reg     [7:0]   rounded_frac_extended;
    reg     [7:0]   ey_3                ;
    reg             sy_delay5           ;
    reg             bf16_is_special     ;

    assign input_valid = a_tvalid & b_tvalid;
    
    // input data
    always @ (posedge clk) begin
        if (input_valid)begin
            input_valid_delay1 <= input_valid;
            s1 <= atdata[15];
            s2 <= btdata[15];
            e1 <= atdata[14:7];
            e2 <= btdata[14:7];
            m1 <= atdata[6:0];
            m2 <= btdata[6:0];
        end
        else begin
            input_valid_delay1 <= 1'b0;
        end
    end

    // cal stage1
    always @ (posedge clk) begin
        if (input_valid_delay1)begin
            p1 <=  {1'b1, m1} * {1'b1, m2};
        end
    end
    
    // cal stage1
    always @ (posedge clk) begin
        if (input_valid_delay1)begin
            input_valid_delay2 <= input_valid_delay1;
            e1_delay1 <= e1;
            e2_delay1 <= e2;
            eyp <= e1 + e2 - 9'd127;
            eypi <= e1 + e2 - 9'd126;
            sy <= s1 ^ s2;
            input_nan <= ((e1 == 8'hFF) && (m1 != 0)) || ((e2 == 8'hFF) && (m2 != 0));
        end
        else begin
            input_valid_delay2 <= 1'b0;
        end
    end
    
    //cal stage2
    always @(posedge clk) begin
        if(input_valid_delay2) begin
            input_valid_delay3 <= input_valid_delay2;
            ovf_f <= (~eyp[9] && eyp[8]) || &(eyp[7:0]) || &(e1_delay1) || &(e2_delay1) ? 1 : 0;
            underflow <= eyp[9] || ~(|e1_delay1) || ~(|e2_delay1) ? 1 : 0;
            eyp_2 <= eyp;
            eypi_2 <= eypi;
            input_nan_delay1 <= input_nan;
            p2 <= p1;
            sy_delay1 <= sy;
        end
        else begin
            input_valid_delay3 <= 1'b0;
        end
    end

    //cal stage3
    always @(posedge clk) begin
        if(input_valid_delay3) begin
            input_valid_delay4 <= input_valid_delay3;
            ovf <= ovf_f || (p2[15] && &(eypi_2[7:0]));
            underflow_delay1 <= underflow;
            input_nan_delay2 <= input_nan_delay1;
            eyp_3 <= eyp_2;
            eypi_3 <= eypi_2;
            p3 <= p2;
            sy_delay2 <= sy_delay1;
        end
        else begin
            input_valid_delay4 <= 1'b0;
        end
    end

    //cal stage4
    always @(posedge clk) begin
        if(input_valid_delay4) begin
            input_valid_delay5 <= input_valid_delay4;
            ey <= underflow_delay1 ? 8'b00000000 : ovf ? 8'b11111111 : p3[15] ? eypi_3 : eyp_3;
            my <= (underflow_delay1 || ovf) ? 7'b0 : p3[15] ? p3[14:8] : p3[13:7];
            guard_bit   <=  p3[15] ? p3[7] : p3[6];       
            round_bit   <=  p3[15] ? p3[6] : p3[5];       
            sticky_bit  <=  p3[15] ? |p3[5:0] : |p3[4:0]; 
            input_nan_delay3 <= input_nan_delay2;
            sy_delay3 <= sy_delay2;
        end
        else begin
            input_valid_delay5 <= 1'b0;
        end
    end

    //cal stage5
    always @(posedge clk) begin
        if(input_valid_delay5) begin
            input_valid_delay6 <= input_valid_delay5;
            round_up <= (guard_bit & round_bit) | (guard_bit & ~round_bit & sticky_bit) | (guard_bit & ~round_bit & ~sticky_bit & my[0]);
            bf16_is_nan         <= input_nan_delay3;
            bf16_is_inf         <= (ey == 8'hFF) && (my == 0) && ~input_nan_delay3;
            bf16_is_zero        <= (ey == 0) && (my == 0);
            bf16_is_denormal    <= (ey == 0) && (my != 0);
            sy_delay4 <= sy_delay3;
            my_2 <= my;
            ey_2 <= ey;
        end
        else begin
            input_valid_delay6 <= 1'b0;
        end
    end

    //cal stage6
    always @(posedge clk) begin
        if(input_valid_delay6) begin
            input_valid_delay7 <= input_valid_delay6;
            special_case_bf16 <= bf16_is_nan ? {sy_delay4, 8'hFF, 7'h7F} : bf16_is_inf ? {sy_delay4, 8'hFF, 7'h00} : bf16_is_zero ? {sy_delay4, 8'h00, 7'h00} : {sy_delay4, 8'h00, 7'h00};      
            rounded_frac_extended <= {1'b0, my_2} + round_up;
            bf16_is_special       <= (bf16_is_nan | bf16_is_inf | bf16_is_zero | bf16_is_denormal);
            ey_3 <= ey_2;
            sy_delay5 <= sy_delay4;
        end
        else begin
            input_valid_delay7 <= 1'b0;
        end
    end

    wire [7:0]  final_exp   = ey_3 + rounded_frac_extended[7];
    wire [6:0]  final_frac  = rounded_frac_extended[6:0];
    wire [15:0] normal_bf16 = {sy_delay5, final_exp, final_frac};

    //output data
    always @(posedge clk) begin
        if(input_valid_delay7) begin
            result_tdata <=  bf16_is_special ? special_case_bf16 : normal_bf16;
            result_tvalid <= input_valid_delay7;
        end
        else begin
            result_tdata <= 16'b0;
            result_tvalid <= 1'b0;
        end
    end
endmodule