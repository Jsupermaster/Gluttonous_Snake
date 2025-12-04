`timescale 1ns / 1ps
module test_rms();   
    reg             clk                         ;
    reg             rst_n                       ;
    reg             a_tvalid                    ;
    reg     [31:0]  a_tdata                     ;
    wire            rms_result_tvalid           ;
    wire    [31:0]  rms_result_tdata            ;
    
    // 文件指针声明
    integer file_a;
    integer rms_file_out;
    integer read_a;
    reg [7:0] a_low, a_high;

    // 状态寄存器
    reg        cal_config;
    reg [15:0] in_count;
    reg [15:0] rms_out_count;
    // RMSNORM例化模块
    rmsnorm u_rmsnorm_test(
        .clk                (clk                    ),
        .rst_n              (rst_n                  ),
        .a_tvalid           (a_tvalid               ),
        .a_tdata            (a_tdata                ),
        .result_tvalid      (rms_result_tvalid      ),
        .result_tdata       (rms_result_tdata       )
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        cal_config = 1'b0;
        a_tvalid = 1'b0;
        // 打开文件
        // 输入数据
        file_a = $fopen("D:\\IC_GAME\\FPT_2025\\Python\\input_data\\X_test_tensor_bf16.bin", "rb");
        //rmsnorm输出数据
        rms_file_out = $fopen("D:\\IC_GAME\\FPT_2025\\Python\\fpga_result\\rms_fpga_out.bin", "wb");
        // 等待时钟稳定
        #10;
        rst_n = 1'b1;
    end

   //输入数据 所有模块公用输入数据
always @ (posedge clk) begin
    if(!rst_n) begin
        in_count <= 16'b0;
    end
    else begin
        if(in_count <= 16'd49151) begin
            read_a = $fread(a_high, file_a);
            read_a = $fread(a_low, file_a);
            a_tvalid <= 1'b1;
            a_tdata = {a_low, a_high, 16'b0};
            in_count <= in_count + 1'b1;
        end
        else begin
            a_tvalid <= 1'b0;
            a_tdata = 32'b0;
        end
    end
end

    always @ (posedge clk)begin
        if(!rst_n)begin
            rms_out_count <= 16'b0;
        end
        else begin
            if(rms_out_count <= 16'd49151)begin
                if(rms_result_tvalid == 1'b1)begin
                    $fwrite(rms_file_out, "%c%c", 
                    rms_result_tdata[23:16], // 低字节 (小端序)
                    rms_result_tdata[31:24]  // 高字节 (小端序)
                );
                rms_out_count <= rms_out_count + 1'b1;
                end
            end
            else if (cal_config == 1'b0)begin
                $fclose(rms_file_out);
                $display("rms Test Finished.");
                cal_config <= 1'b1; // rms测试完成
            end
        end
    end

    always @ (posedge clk) begin
        if(cal_config == 1'b1) begin 
            $display("All Tests Finished.");
            $finish; // 停止仿真
        end
    end
endmodule
