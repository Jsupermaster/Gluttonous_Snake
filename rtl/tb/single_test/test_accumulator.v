module test();
  reg aclk;
  reg aresetn;
  reg s_axis_a_tvalid;
  reg [31:0] s_axis_a_tdata;
  reg s_axis_a_tlast;
  wire m_axis_result_tvalid;
  // reg m_axis_result_tready; // 非阻塞接口无需ready
  wire [31:0] m_axis_result_tdata;
  wire m_axis_result_tlast;

  // 10个FP32测试数据（1.0~10.0）
  reg [31:0] test_data [0:9];
  reg [31:0] test_data2 [0:9];
  integer i;

  // 时钟生成
  initial aclk = 0;
  always #5 aclk = ~aclk;

  // 初始化FP32数据
  initial begin
    test_data[0] = 32'h3f800000; // 1.0
    test_data[1] = 32'h40000000; // 2.0
    test_data[2] = 32'h40400000; // 3.0
    test_data[3] = 32'h40800000; // 4.0
    test_data[4] = 32'h40a00000; // 5.0
    test_data[5] = 32'h40c00000; // 6.0
    test_data[6] = 32'h40e00000; // 7.0
    test_data[7] = 32'h41000000; // 8.0
    test_data[8] = 32'h41100000; // 9.0
    test_data[9] = 32'h41200000; // 10.0
    // 第二批数据（11.0~20.0）
    test_data2[0] = 32'h41300000; // 11.0
    test_data2[1] = 32'h41400000; // 12.0
    test_data2[2] = 32'h41500000; // 13.0
    test_data2[3] = 32'h41600000; // 14.0
    test_data2[4] = 32'h41700000; // 15.0
    test_data2[5] = 32'h41800000; // 16.0
    test_data2[6] = 32'h41900000; // 17.0
    test_data2[7] = 32'h41a00000; // 18.0
    test_data2[8] = 32'h41b00000; // 19.0
    test_data2[9] = 32'h41c00000; // 20.0
  end

  // 激励过程
  initial begin
    aresetn = 0;
    s_axis_a_tvalid = 0;
    s_axis_a_tdata = 0;
    s_axis_a_tlast = 0;
  // m_axis_result_tready = 1; // 非阻塞接口无需ready
    #20;
    aresetn = 1;
    #20;
    // 第一批数据
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge aclk);
      s_axis_a_tdata <= test_data[i];
      s_axis_a_tvalid <= 1;
      s_axis_a_tlast <= (i == 9) ? 1 : 0;
      @(posedge aclk);
      s_axis_a_tvalid <= 0;
      s_axis_a_tlast <= 0;
    end
    // 等待第一批结果
    wait(m_axis_result_tvalid);
    @(posedge aclk);
    // 第二批数据
    for (i = 0; i < 10; i = i + 1) begin
      @(posedge aclk);
      s_axis_a_tdata <= test_data2[i];
      s_axis_a_tvalid <= 1;
      s_axis_a_tlast <= (i == 9) ? 1 : 0;
      @(posedge aclk);
      s_axis_a_tvalid <= 0;
      s_axis_a_tlast <= 0;
    end
    // 等待第二批结果
    wait(m_axis_result_tvalid);
    @(posedge aclk);
    $finish;
  end
  accumulator your_acc (
  .aclk(aclk),                                  // input wire aclk
  .s_axis_a_tvalid(s_axis_a_tvalid),            // input wire s_axis_a_tvalid
  .s_axis_a_tdata(s_axis_a_tdata),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_a_tlast(s_axis_a_tlast),              // input wire s_axis_a_tlast
  // 非阻塞接口无需ready信号
  .m_axis_result_tvalid(m_axis_result_tvalid),  // output wire m_axis_result_tvalid
  .m_axis_result_tdata(m_axis_result_tdata),    // output wire [31 : 0] m_axis_result_tdata
  .m_axis_result_tlast(m_axis_result_tlast)    // output wire m_axis_result_tlast
  // .m_axis_result_tready(m_axis_result_tready) // 非阻塞接口无需ready
);
endmodule