module fadd_bf16(
    input wire          clk             ,
    input wire          rst_n           ,
    input wire [15:0]   a               ,
    input wire [15:0]   b               ,
    input wire          a_tvalid        ,
    input wire          b_tvalid        ,
    output reg [15:0]   y               ,
    output reg          result_tvalid   
);

    wire input_valid = a_tvalid & b_tvalid;
    
    wire a_s = a[15];
    wire [7:0] a_e = a[14:7];
    wire b_s = b[15];
    wire [7:0] b_e = b[14:7];

    wire a_is_normal = (a_e != 8'h00);
    wire b_is_normal = (b_e != 8'h00);

    wire a_is_inf = (a_e == 8'hff) && ~(&a[6:0]);
    wire b_is_inf = (b_e == 8'hff) && ~(&b[6:0]);
    wire a_is_nan = (a_e == 8'hff) && (|a[6:0]);
    wire b_is_nan = (b_e == 8'hff) && (|b[6:0]);

    wire [7:0] a_m = a_is_normal ? {1'b1, a[6:0]} : {1'b0, a[6:0]};
    wire [7:0] b_m = b_is_normal ? {1'b1, b[6:0]} : {1'b0, b[6:0]};

    wire larger = (a_e > b_e) ? 1 :
                  ((a_e == b_e) && (a_m > b_m)) ? 1 : 0;
    wire numbers_equal_opposite = (a_e == b_e) && (a_m == b_m) && (a_s != b_s);

    reg l_s, s_s;
    reg [7:0] l_e, s_e;
    reg [7:0] l_m, s_m;
    reg valid_stage0;
    reg special_case_0; // -1 + +1
    reg special_case_nan;
    reg special_case_inf;

    always @(posedge clk) begin
        if (!rst_n) begin
            valid_stage0 <= 1'b0;
            l_s <= 'b0;
            s_s <= 'b0;
            l_e <= 'b0;
            s_e <= 'b0;
            l_m <= 'b0;
            s_m <= 'b0;
            special_case_0 <= 1'b0;
            special_case_nan <= 1'b0;
            special_case_inf <= 1'b0;
        end
        else begin
            if (a_is_nan || b_is_nan) begin
                l_s <= 1'b0;
                s_s <= 1'b0;
                l_e <= 8'b0;
                s_e <= 8'b0;
                l_m <= 8'b0;
                s_m <= 8'b0;
                special_case_nan <= 1'b1;
                special_case_inf <= 1'b0;
            end
            else if (a_is_inf || b_is_inf) begin
                if (a_s ^ b_s) begin
                    l_s <= 1'b0;
                    s_s <= 1'b0;
                    l_e <= 8'b0;
                    s_e <= 8'b0;
                    l_m <= 8'b0;
                    s_m <= 8'b0;
                    special_case_nan <= 1'b1;
                    special_case_inf <= 1'b0;
                end
                else begin
                    l_s <= a_s;
                    s_s <= 1'b0;
                    l_e <= 8'b0;
                    s_e <= 8'b0;
                    l_m <= 8'b0;
                    s_m <= 8'b0;
                    special_case_inf <= 1'b1;
                    special_case_nan <= 1'b0;
                end
            end
            else if (numbers_equal_opposite && input_valid) begin
                l_s <= 1'b0;
                s_s <= 1'b0;
                l_e <= 8'b0;
                s_e <= 8'b0;
                l_m <= 8'b0;
                s_m <= 8'b0;
                special_case_0 <= 1'b1;
                special_case_nan <= 1'b0;
                special_case_inf <= 1'b0;
            end
            else begin
                l_s <= larger ? a_s : b_s;
                s_s <= larger ? b_s : a_s;
                l_e <= larger ? a_e : b_e;
                s_e <= larger ? b_e : a_e;
                l_m <= larger ? a_m : b_m;
                s_m <= larger ? b_m : a_m;
                special_case_0 <= 1'b0;
                special_case_nan <= 1'b0;
                special_case_inf <= 1'b0;
            end
            valid_stage0 <= input_valid;
        end
    end

    wire [7:0] diff = l_e - s_e;
    wire [3:0] diff_e = (diff > 4'd8) ? 4'd8 : diff[3:0];
    wire [7:0] s_m_shift = s_m >> diff_e;

    wire [8:0] m_raw = (s_s ^ l_s) ? ({1'b0, l_m} - {1'b0, s_m_shift}) : 
                                    ({1'b0, l_m} + {1'b0, s_m_shift});
    wire m9 = m_raw[8];

    wire result_is_zero = (m_raw == 9'b0) || special_case_0;

    reg m9_0, l_s_0, valid_stage1, zero_result_0;
    reg special_case_nan_1;
    reg special_case_inf_1;
    reg [8:0] m_raw_0;
    reg [7:0] l_e_0;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            valid_stage1 <= 1'b0;
            m_raw_0 <= 'b0;
            m9_0    <= 'b0;
            l_e_0   <= 'b0;
            l_s_0   <= 'b0;
            zero_result_0 <= 1'b0;
            special_case_nan_1 <= 1'b0;
            special_case_inf_1 <= 1'b0;
        end
        else begin
            m_raw_0 <= m_raw;
            m9_0 <= m9;
            l_e_0 <= l_e;
            l_s_0 <= l_s;
            zero_result_0 <= result_is_zero;
            valid_stage1 <= valid_stage0;
            special_case_nan_1 <=special_case_nan;
            special_case_inf_1 <= special_case_inf;
        end
    end

    wire [2:0] shift_m;
    wire lzc_all_zero;
    LZC_for_bf16 lzc(m_raw_0[7:0], shift_m, lzc_all_zero);

    reg [2:0] shift_m_1;
    reg [7:0] l_e_1;
    reg m9_1, l_s_1, valid_stage2, zero_result_1;
    reg [8:0] m_raw_1;
    reg special_case_nan_2;
    reg special_case_inf_2;
    
    // 新增：舍入位寄存器
    reg guard_bit, round_bit, sticky_bit;
    reg [7:0] m_before_round;
    wire [15:0] m_shift_temp = {m_raw_0[7:0], 8'b0} << shift_m;
    
    always @(posedge clk) begin
        if(!rst_n) begin
            valid_stage2    <= 1'b0;
            l_e_1           <= 'b0;
            m9_1            <= 'b0;
            l_s_1           <= 'b0;
            m_raw_1         <= 'b0;
            shift_m_1       <= 'b0;
            zero_result_1   <= 1'b0;
            special_case_nan_2 <= 1'b0;
            special_case_inf_2 <= 1'b0;
            guard_bit       <= 1'b0;
            round_bit       <= 1'b0;
            sticky_bit      <= 1'b0;
            m_before_round  <= 8'b0;
        end
        else begin
            shift_m_1 <= shift_m;
            l_e_1 <= l_e_0;
            m9_1 <= m9_0;
            l_s_1 <= l_s_0;
            m_raw_1 <= m_raw_0;
            zero_result_1 <= zero_result_0;
            valid_stage2 <= valid_stage1;
            special_case_nan_2 <=special_case_nan_1;
            special_case_inf_2 <= special_case_inf_1;
            
            // 计算舍入位
            if (m9_0) begin
                // 有进位的情况：尾数已经是9位，取适当的位作为舍入位
                guard_bit <= m_raw_0[0];      // 保护位：最低有效位
                round_bit <= 1'b0;           // 舍入位：设为0
                sticky_bit <= 1'b0;          // 粘滞位：设为0
                m_before_round <= m_raw_0[7:1]; // 7位尾数
            end else begin
                // 无进位情况：需要根据移位后的位置确定舍入位
                
                guard_bit <= m_shift_temp[7];     // 保护位：第7位
                round_bit <= m_shift_temp[6];     // 舍入位：第6位
                sticky_bit <= |m_shift_temp[5:0]; // 粘滞位：低6位的或
                m_before_round <= m_shift_temp[14:8]; // 7位尾数
            end
        end
    end

    // 舍入逻辑
    wire round_up;
    assign round_up = (guard_bit & round_bit) | 
                     (guard_bit & ~round_bit & sticky_bit) |
                     (guard_bit & ~round_bit & ~sticky_bit & m_before_round[0]); // 向偶数舍入

    // 应用舍入
    wire [7:0] m_after_round = {1'b0, m_before_round} + round_up;
    wire round_carry = m_after_round[7]; // 检查是否产生进位

    // 最终尾数
    wire [6:0] final_mantissa = round_carry ? 7'b0 : m_after_round[6:0];

    // 指数计算（考虑舍入进位）
    wire [8:0] e_shift = {1'b0, l_e_1} - {5'b0, shift_m_1};
    wire [8:0] e_inc = {1'b0, l_e_1} + 9'b1;
    wire [8:0] e_inc2 = {1'b0, l_e_1} + 9'd2; // 舍入进位时可能需要加2
    
    // 基础指数计算
    wire [8:0] base_e = 
        zero_result_1 ? 9'b0 :
        (m9_1 && e_inc[8]) ? 9'h1FF :
        m9_1 ? e_inc :
        (e_shift[8] ? 9'b0 : e_shift);
    
    // 最终指数（考虑舍入进位）
    wire [8:0] final_e = 
        round_carry ? (base_e + 9'b1) : base_e;
    
    // 检查指数是否溢出
    wire exponent_overflow = (&final_e[7:0]) || final_e[8];
    wire exponent_underflow = (final_e[8:0] == 9'b0) && (final_mantissa != 7'b0);
    
    // 处理非规格化数
    wire [7:0] normalized_e = 
        exponent_underflow ? 8'b0 :
        exponent_overflow ? 8'hFF : final_e[7:0];
    
    wire [6:0] normalized_m =
        exponent_underflow ? 7'b0 :
        exponent_overflow ? 7'b0 : final_mantissa;

    always @ (posedge clk) begin
        if (!rst_n) begin
            y <= 16'b0;
            result_tvalid <= 1'b0;
        end
        else begin
            if (special_case_nan_2) begin
                y <= {1'b0, 8'hff, 7'h40};
            end
            else if (special_case_inf_2) begin
                y <= {l_s_1, 8'hff, 7'h00};
            end
            else if (zero_result_1) begin
                y <= 16'b0;
            end
            else if (exponent_overflow) begin
                y <= {l_s_1, 8'hFF, 7'b0}; // 无穷大
            end
            else if (normalized_e == 8'b0 && normalized_m == 7'b0) begin
                y <= 16'b0; // 零
            end
            else begin
                y <= {l_s_1, normalized_e, normalized_m};
            end
            result_tvalid <= valid_stage2;
        end
    end

endmodule

module LZC_for_bf16(
    input wire [7:0] a,
    output wire [2:0] cnt,
    output wire all_zero
);
    assign all_zero = (a == 8'b0);
    assign cnt =
        a[7] ? 3'b000 :
        a[6] ? 3'b001 :
        a[5] ? 3'b010 :
        a[4] ? 3'b011 :
        a[3] ? 3'b100 :
        a[2] ? 3'b101 :
        a[1] ? 3'b110 :
        3'b111;
endmodule