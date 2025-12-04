from torch.nn.functional import layer_norm

import general
import test_function
import time

def basic_test():
    """
    进行基础功能测试：加法、减法、乘法、e的指数、ln、倒数、根号、根号分之1
    :return:
    测试报告
    """

    # 逐个读取fpga_basic_result文件夹中的数据，一一进行对比。
    ################################################################################################################
    # 仿真结果
    # softmax测试
    # print("SOFTMAX TEST")
    # softmax_fpga_result = general.get_bf16_from_bin("fpga_result/acc_softmax_out.bin", (64, 768))
    #
    # softmax_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_softmax_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(softmax_python_result, softmax_fpga_result, "dif_result/sim_softmax_dif.txt")
    #
    # softmax_L2_error = test_function.l2_error("ref_bin_bf16/ref_softmax_bf16.bin", "fpga_result/acc_softmax_out.bin")
    #
    # print(f"SOFTMAX L2_error = {softmax_L2_error}")
    #
    # layernorm测试
    # print("LAYERNORM TEST")
    # layer_fpga_result = general.get_bf16_from_bin("fpga_result/acc_layer_out.bin", (64, 768))
    #
    # layer_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_layernorm_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(layer_python_result, layer_fpga_result, "dif_result/sim_layer_dif.txt")
    #
    # layer_L2_error = test_function.l2_error("ref_bin_bf16/ref_layernorm_bf16.bin", "fpga_result/acc_layer_out.bin")
    #
    # print(f"LAYER L2_error = {layer_L2_error}")
    # #
    # # rmsnorm测试
    # print("RMSNORM TEST")
    # rms_fpga_result = general.get_bf16_from_bin("fpga_result/acc_rms_out.bin", (64, 768))
    #
    # rms_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_rmsnorm_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(rms_python_result, rms_fpga_result, "dif_result/sim_rms_dif.txt")
    #
    # rms_L2_error = test_function.l2_error("ref_bin_bf16/ref_rmsnorm_bf16.bin", "fpga_result/acc_rms_out.bin")
    #
    # print(f"RMS L2_error = {rms_L2_error}")
    #
    # silu测试
    # print("SILU TEST")
    # silu_fpga_result = general.get_bf16_from_bin("fpga_result/acc_silu_out.bin", (64, 768))
    #
    # silu_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_silu_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(silu_python_result, silu_fpga_result, "dif_result/sim_silu_dif.txt")
    #
    # silu_L2_error = test_function.l2_error("ref_bin_bf16/ref_silu_bf16.bin", "fpga_result/acc_silu_out.bin")
    #
    # print(f"SILU L2_error = {silu_L2_error}")
    # 
    # # gelu测试
    # print("GELU TEST")
    # gelu_fpga_result = general.get_bf16_from_bin("fpga_result/acc_gelu_out.bin", (64, 768))
    # 
    # gelu_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_gelu_bf16.bin", (64, 768))
    # 
    # test_function.fp32_np_compare_v2(gelu_python_result, gelu_fpga_result, "dif_result/sim_gelu_dif.txt")
    # 
    # gelu_L2_error = test_function.l2_error("ref_bin_bf16/ref_gelu_bf16.bin", "fpga_result/acc_gelu_out.bin")
    # 
    # print(f"GELU L2_error = {gelu_L2_error}")
    #
    # # ADD测试
    # print("ADD TEST")
    add_fpga_result = general.get_bf16_from_bin("fpga_result/acc_add_out.bin", (64, 768))

    add_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_add_bf16.bin", (64, 768))

    test_function.fp32_np_compare_v2(add_python_result, add_fpga_result, "dif_result/sim_add_dif.txt")

    add_L2_error = test_function.l2_error("ref_bin_bf16/ref_add_bf16.bin", "fpga_result/acc_add_out.bin")

    print(f"ADD L2_error = {add_L2_error}")

    # # MUL测试
    # print("MUL TEST")
    # mul_fpga_result = general.get_bf16_from_bin("fpga_result/acc_mul_out.bin", (64, 768))
    #
    # mul_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_mul_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(mul_python_result, mul_fpga_result, "dif_result/sim_mul_dif.txt")
    #
    # mul_L2_error = test_function.l2_error("ref_bin_bf16/ref_mul_bf16.bin", "fpga_result/acc_mul_out.bin")
    #
    # print(f"MUL L2_error = {mul_L2_error}")

    ##############################################################################################################
    # 上板结果
    # # softmax测试
    # print("SOFTMAX TEST")
    # softmax_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out0.bin", (64, 768))
    #
    # softmax_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_softmax_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(softmax_python_result, softmax_fpga_result, "dif_result/real_softmax_dif.txt")
    #
    # softmax_L2_error = test_function.l2_error("ref_bin_bf16/ref_softmax_bf16.bin", "fpga_result/fpga_out0.bin")
    #
    # print(f"SOFTMAX L2_error = {softmax_L2_error}")
    #
    # layernorm测试
    # print("LAYERNORM TEST")
    # layer_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out1.bin", (64, 768))
    #
    # layer_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_layernorm_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(layer_python_result, layer_fpga_result, "dif_result/real_layer_dif.txt")
    #
    # layer_L2_error = test_function.l2_error("ref_bin_bf16/ref_layernorm_bf16.bin", "fpga_result/fpga_out1.bin")
    #
    # print(f"LAYER L2_error = {layer_L2_error}")
    # #
    # # rmsnorm测试
    # print("RMSNORM TEST")
    # rms_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out2.bin", (64, 768))
    #
    # rms_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_rmsnorm_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(rms_python_result, rms_fpga_result, "dif_result/real_rms_dif.txt")
    #
    # rms_L2_error = test_function.l2_error("ref_bin_bf16/ref_rmsnorm_bf16.bin", "fpga_result/fpga_out2.bin")
    #
    # print(f"RMS L2_error = {rms_L2_error}")
    # #
    # # silu测试
    # print("SILU TEST")
    # silu_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out3.bin", (64, 768))
    #
    # silu_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_silu_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(silu_python_result, silu_fpga_result, "dif_result/real_silu_dif.txt")
    #
    # silu_L2_error = test_function.l2_error("ref_bin_bf16/ref_silu_bf16.bin", "fpga_result/fpga_out3.bin")
    #
    # print(f"SILU L2_error = {silu_L2_error}")
    # #
    # # gelu测试
    # print("GELU TEST")
    # gelu_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out4.bin", (64, 768))
    #
    # gelu_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_gelu_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(gelu_python_result, gelu_fpga_result, "dif_result/real_gelu_dif.txt")
    #
    # gelu_L2_error = test_function.l2_error("ref_bin_bf16/ref_gelu_bf16.bin", "fpga_result/fpga_out4.bin")
    #
    # print(f"GELU L2_error = {gelu_L2_error}")
    # #
    # # ADD测试
    # print("ADD TEST")
    # add_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out5.bin", (64, 768))
    #
    # add_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_add_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(add_python_result, add_fpga_result, "dif_result/real_add_dif.txt")
    #
    # add_L2_error = test_function.l2_error("ref_bin_bf16/ref_add_bf16.bin", "fpga_result/fpga_out5.bin")
    #
    # print(f"ADD L2_error = {add_L2_error}")
    # #
    # # MUL测试
    # print("MUL TEST")
    # mul_fpga_result = general.get_bf16_from_bin("fpga_result/fpga_out6.bin", (64, 768))
    #
    # mul_python_result = general.get_bf16_from_bin("ref_bin_bf16/ref_mul_bf16.bin", (64, 768))
    #
    # test_function.fp32_np_compare_v2(mul_python_result, mul_fpga_result, "dif_result/real_mul_dif.txt")
    #
    # mul_L2_error = test_function.l2_error("ref_bin_bf16/ref_mul_bf16.bin", "fpga_result/fpga_out6.bin")
    #
    # print(f"MUL L2_error = {mul_L2_error}")

def cpu_test():
    X_bf16 = general.load_bf16_tensor_from_pt("input_data/X_test_tensor_bf16.pt")
    Y_bf16 = general.load_bf16_tensor_from_pt("input_data/Y_test_tensor_bf16.pt")

    softmax_time_begin = time.perf_counter()
    cpu_softmax = general.ref_softmax(X_bf16)
    softmax_time_end = time.perf_counter()
    print(f"Softmax CPU time: {softmax_time_end - softmax_time_begin}")

    layernorm_time_begin = time.perf_counter()
    cpu_layernorm = general.ref_layernorm(X_bf16)
    layernorm_time_end = time.perf_counter()
    print(f"LayerNorm CPU time: {layernorm_time_end - layernorm_time_begin}")

    rmsnorm_time_begin = time.perf_counter()
    cpu_rmsnorm = general.ref_rmsnorm(X_bf16)
    rmsnorm_time_end = time.perf_counter()
    print(f"RMSNorm CPU time: {rmsnorm_time_end - rmsnorm_time_begin}")

    silu_time_begin = time.perf_counter()
    cpu_silu = general.ref_silu(X_bf16)
    silu_time_end = time.perf_counter()
    print(f"SILU CPU time: {silu_time_end - silu_time_begin}")

    gelu_time_begin = time.perf_counter()
    cpu_gelu = general.ref_gelu(X_bf16)
    gelu_time_end = time.perf_counter()
    print(f"GELU CPU time: {gelu_time_end - gelu_time_begin}")

    add_time_begin = time.perf_counter()
    cpu_add = general.ref_add(X_bf16, Y_bf16)
    add_time_end = time.perf_counter()
    print(f"ADD CPU time: {add_time_end - add_time_begin}")

    mul_time_begin = time.perf_counter()
    cpu_mul = general.ref_mul(X_bf16, Y_bf16)
    mul_time_end = time.perf_counter()
    print(f"MUL CPU time: {mul_time_end - mul_time_begin}")

if __name__ == '__main__':
    basic_test()
    # cpu_test()