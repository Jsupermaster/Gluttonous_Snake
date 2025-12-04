"""存放各类测试函数"""
import numpy as np
import pandas as pd
import struct
import os
import torch

def calculate_point(error_true):
    ERROR_point= 0
    if error_true <= 1e-3:
        ERROR_point = 1
    elif error_true > 1e-3 and error_true <= 0.1:
        ERROR_point = (np.log(0.1) - np.log(error_true))/np.log(100)
    else:
        ERROR_point = 0
    return ERROR_point

# 计算L2误差
# ε_f = ||Y_fpga,f - Y_ref,f||_2 / (||Y_ref,f||_2 + 10^{-12})

def l2_error(result_ref_path, result_compare_path):
    """
    计算两个数组之间的相对L2误差，增强数值稳定性
    """
    # 使用float64进行计算以避免溢出
    f32_max = np.finfo(np.float32).max
    f32_min = -f32_max

    # 读作 uint16 并 reshape
    output = np.fromfile(result_compare_path, dtype=np.uint16).reshape(64, 768)
    golden = np.fromfile(result_ref_path, dtype=np.uint16).reshape(64, 768)

    if output.shape != golden.shape:
        raise ValueError(f"Shape mismatch: {output.shape} vs {golden.shape}")

    # 先转换为 torch 支持的 dtype（int32），保持 bit pattern 不变
    output_int16 = torch.from_numpy(output.view(np.int16))
    golden_int16 = torch.from_numpy(golden.view(np.int16))

    # 重新解释为 bfloat16
    output_bf16 = output_int16.view(torch.bfloat16)
    golden_bf16 = golden_int16.view(torch.bfloat16)

    # 转换为 float64 便于更稳定的计算
    output_f64 = output_bf16.to(torch.float64).numpy()
    golden_f64 = golden_bf16.to(torch.float64).numpy()

    eps = 1e-12
    BIG_VAL = 1e9  # 减小惩罚值，避免溢出

    # 使用更安全的NaN/Inf处理方式
    output_safe = output_f64.copy()
    golden_safe = golden_f64.copy()

    # 创建掩码
    nan_mask_out = np.isnan(output_safe)
    nan_mask_gold = np.isnan(golden_safe)
    inf_mask_out = np.isinf(output_safe)
    inf_mask_gold = np.isinf(golden_safe)

    # 处理NaN
    both_nan = nan_mask_out & nan_mask_gold
    only_out_nan = nan_mask_out & ~nan_mask_gold
    only_gold_nan = ~nan_mask_out & nan_mask_gold

    output_safe[both_nan] = 0
    golden_safe[both_nan] = 0
    output_safe[only_out_nan] = BIG_VAL
    golden_safe[only_out_nan] = 0
    output_safe[only_gold_nan] = 0
    golden_safe[only_gold_nan] = BIG_VAL

    # 处理Inf
    both_inf = inf_mask_out & inf_mask_gold
    only_out_inf = inf_mask_out & ~inf_mask_gold
    only_gold_inf = ~inf_mask_out & inf_mask_gold

    # 检查Inf符号是否相同
    inf_sign_diff = both_inf & (np.sign(output_safe) != np.sign(golden_safe))
    inf_sign_same = both_inf & (np.sign(output_safe) == np.sign(golden_safe))

    output_safe[inf_sign_same] = 0
    golden_safe[inf_sign_same] = 0
    output_safe[inf_sign_diff] = BIG_VAL
    golden_safe[inf_sign_diff] = 0
    output_safe[only_out_inf] = BIG_VAL
    golden_safe[only_out_inf] = 0
    output_safe[only_gold_inf] = 0
    golden_safe[only_gold_inf] = BIG_VAL

    # 安全的L2范数计算
    with np.errstate(over='ignore', invalid='ignore'):
        # 计算差值
        diff = output_safe - golden_safe

        # 使用更稳定的范数计算方法
        # 避免直接计算大数的平方
        max_abs_val = max(np.max(np.abs(output_safe)), np.max(np.abs(golden_safe)), 1.0)

        # 归一化后再计算范数
        scale_factor = 1.0 / max_abs_val if max_abs_val > 0 else 1.0

        diff_scaled = diff * scale_factor
        golden_scaled = golden_safe * scale_factor

        numerator_all = np.linalg.norm(diff_scaled, ord=2)
        denominator_all = np.linalg.norm(golden_scaled, ord=2) + eps

        # 如果分母仍然为0或极小，使用备选方案
        if denominator_all < eps:
            # 使用绝对误差代替相对误差
            mean_abs_golden = np.mean(np.abs(golden_safe)) + eps
            errors = numerator_all / mean_abs_golden
        else:
            errors = numerator_all / denominator_all

    errors_point = calculate_point(errors)

    print("总误差:", errors)
    print("总评分:", errors_point)

    return errors

# 比较两个fp32格式的numpy数组

def fp32_np_compare(arr1, arr2, report_path=None, threshold=1.1754943508222875e-38):
    """
    比较两个 FP32 NumPy 数组并生成详细报告，可选保存到文本文件

    参数:
        arr1 (np.ndarray): 第一个 FP32 数组 (形状: MxN)
        arr2 (np.ndarray): 第二个 FP32 数组 (形状: MxN)
        report_path (str): 报告保存路径（可选）
        check_nan (bool): 是否检查 NaN 值的一致性
        check_inf (bool): 是否检查 Inf 值的一致性
        check_sign (bool): 是否检查正负零的区别
        only_diff (bool): 是否只显示不一致的记录

    返回:
        pd.DataFrame: 包含四列的测试报告（索引，矩阵1的值，矩阵2的值，差值）

    异常:
        ValueError: 如果数组形状或数据类型不匹配
    """
    # 验证输入类型
    if not (isinstance(arr1, np.ndarray) and isinstance(arr2, np.ndarray)):
        raise ValueError("两个输入都必须是 NumPy 数组")

    # 验证数据类型
    if arr1.dtype != np.float32 or arr2.dtype != np.float32:
        raise ValueError("两个数组都必须是 float32 类型")

    # 验证形状
    if arr1.shape != arr2.shape:
        raise ValueError(f"形状不一致: {arr1.shape} vs {arr2.shape}")

    result = np.zeros_like(arr1)
    rows, cols = arr1.shape

    for i in range(rows):
        for j in range(cols):
            if np.isnan(arr1[i, j]) or np.isnan(arr2[i, j]): # 如果存在nan
                if np.isnan(arr1[i, j]) and np.isnan(arr2[i, j]):
                    result[i, j] = 0
                else:
                    result[i, j] = 1
            elif np.isinf(arr1[i, j]) or np.isinf(arr2[i, j]): # 如果存在inf
                if np.isinf(arr1[i, j]) and np.isinf(arr2[i, j]):
                    if np.signbit(arr1[i, j]) == np.signbit(arr2[i, j]):
                        result[i, j] = 0
                    else:
                        result[i, j] = 1
                else:
                    result[i, j] = 1
            elif arr1[i, j] != arr2[i, j]:
                if np.abs(arr1[i, j] - arr2[i, j]) > threshold:
                    result[i, j] = 1
                else:
                    result[i, j] = 0
            else:
                result[i, j] = 0

    with open(report_path, 'w', encoding='utf-8') as f:  # 添加UTF-8编码
        # 写入标题和摘要
        f.write(f"FP32 数组比较报告\n")
        f.write(f"数组形状: {arr1.shape}\n")
        f.write(f"差异数量: {np.count_nonzero(result == 1)}\n")
        f.write("=" * 80 + "\n\n")

        # 写入列标题
        f.write(f"{'索引':<10} {'矩阵1的值':<25} {'矩阵2的值':<25} {'差值':<25}\n")
        f.write("-" * 85 + "\n")

        for i in range(rows):
            for j in range(cols):
                if result[i, j] == 1:
                    f.write(f"{str((i, j)):<11}\t{arr1[i, j]:<25}\t{arr2[i, j]:<25}\t{arr1[i, j]-arr2[i, j]:<25}\n")


def fp32_np_compare_v2(arr1, arr2, report_path=None):
    """
    直接输出两个 FP32 NumPy 数组的所有值及其差值，不进行比较判断

    参数:
        arr1 (np.ndarray): 第一个 FP32 数组 (形状: MxN)
        arr2 (np.ndarray): 第二个 FP32 数组 (形状: MxN)
        report_path (str): 报告保存路径（可选）

    返回:
        pd.DataFrame: 包含四列的测试报告（索引，矩阵1的值，矩阵2的值，差值）

    异常:
        ValueError: 如果数组形状或数据类型不匹配
    """
    # 验证输入类型
    if not (isinstance(arr1, np.ndarray) and isinstance(arr2, np.ndarray)):
        raise ValueError("两个输入都必须是 NumPy 数组")

    # 验证数据类型
    if arr1.dtype != np.float32 or arr2.dtype != np.float32:
        raise ValueError("两个数组都必须是 float32 类型")

    # 验证形状
    if arr1.shape != arr2.shape:
        raise ValueError(f"形状不一致: {arr1.shape} vs {arr2.shape}")

    rows, cols = arr1.shape
    total_elements = rows * cols

    # 创建DataFrame来存储所有结果
    results = []

    with open(report_path, 'w', encoding='utf-8') as f:
        # 写入标题和摘要
        f.write(f"FP32 数组完整数据报告\n")
        f.write(f"数组形状: {arr1.shape}\n")
        f.write(f"总元素数量: {total_elements}\n")
        f.write("=" * 100 + "\n\n")

        # 写入列标题
        f.write(f"{'索引':<12} {'矩阵1的值':<20} {'矩阵2的值':<20} {'差值':<20} {'备注':<20}\n")
        f.write("-" * 100 + "\n")

        for i in range(rows):
            for j in range(cols):
                val1 = arr1[i, j]
                val2 = arr2[i, j]

                if np.isnan(val1) or np.isnan(val2) or np.isinf(val1) or np.isinf(val2):
                    diff = float('nan')
                else:
                    diff = val1 - val2

                # 添加备注信息
                remark = ""
                if np.isnan(val1) or np.isnan(val2):
                    remark = "包含NaN"
                elif np.isinf(val1) or np.isinf(val2):
                    remark = "包含Inf"
                elif val1 == val2:
                    remark = "值相等"
                else:
                    remark = "值不等"

                # 写入文件
                f.write(f"({i:2d},{j:3d})     {val1:<20.10g} {val2:<20.10g} {diff:<20.10g} {remark:<20}\n")

                # 同时保存到DataFrame
                results.append({
                    'index': f"({i},{j})",
                    'matrix1_value': val1,
                    'matrix2_value': val2,
                    'difference': diff,
                    'remark': remark
                })

        # 添加统计信息
        f.write("\n" + "=" * 100 + "\n")
        f.write("统计信息:\n")

        # 计算基本统计
        valid_mask = np.isfinite(arr1) & np.isfinite(arr2)
        if np.any(valid_mask):
            valid_diff = arr1[valid_mask] - arr2[valid_mask]
            f.write(f"有效差值数量: {np.sum(valid_mask)}\n")
            f.write(f"差值平均值: {np.mean(valid_diff):.10g}\n")
            f.write(f"差值标准差: {np.std(valid_diff):.10g}\n")
            f.write(f"最大差值: {np.max(np.abs(valid_diff)):.10g}\n")
        else:
            f.write("无有效差值可统计（所有值都包含NaN或Inf）\n")

        # NaN和Inf统计
        nan_count1 = np.sum(np.isnan(arr1))
        nan_count2 = np.sum(np.isnan(arr2))
        inf_count1 = np.sum(np.isinf(arr1))
        inf_count2 = np.sum(np.isinf(arr2))

        f.write(f"矩阵1 NaN数量: {nan_count1}\n")
        f.write(f"矩阵2 NaN数量: {nan_count2}\n")
        f.write(f"矩阵1 Inf数量: {inf_count1}\n")
        f.write(f"矩阵2 Inf数量: {inf_count2}\n")

def compare_bin_files(file1_path, file2_path, output_file="differences.txt"):
    """
    比较两个二进制文件，每个文件包含64 * 768个2字节数值。
    按2字节数值进行比较，输出所有不同的位置和数值差异到控制台和TXT文件。

    参数:
        file1_path: 第一个二进制文件的路径
        file2_path: 第二个二进制文件的路径
        output_file: 输出差异的TXT文件路径
    """
    try:
        # 读取两个文件的内容
        with open(file1_path, 'rb') as f1, open(file2_path, 'rb') as f2:
            data1 = f1.read()
            data2 = f2.read()

        # 检查文件大小是否匹配预期
        expected_size = 64 * 768 * 2  # 64 * 768个2字节数值
        if len(data1) != expected_size or len(data2) != expected_size:
            print(f"警告: 文件大小不匹配预期 ({expected_size} 字节)")
            print(f"文件1大小: {len(data1)} 字节")
            print(f"文件2大小: {len(data2)} 字节")

        # 创建输出目录（如果不存在）
        output_dir = os.path.dirname(output_file)
        if output_dir and not os.path.exists(output_dir):
            os.makedirs(output_dir)

        # 打开输出文件
        with open(output_file, 'w', encoding='utf-8') as out_f:
            # 写入文件头信息
            out_f.write(f"比较文件: {file1_path} 和 {file2_path}\n")
            out_f.write(f"文件大小: {len(data1)} vs {len(data2)} 字节\n")
            out_f.write(f"预期大小: {expected_size} 字节\n")
            out_f.write("=" * 80 + "\n\n")

            # 比较两个文件的2字节数值
            differences = []
            total_elements = min(len(data1), len(data2)) // 2

            for i in range(total_elements):
                # 提取2字节数值
                start_idx = i * 2
                end_idx = start_idx + 2

                value1_bytes = data1[start_idx:end_idx]
                value2_bytes = data2[start_idx:end_idx]

                # 将字节转换为数值（小端序）
                value1 = struct.unpack('<H', value1_bytes)[0]
                value2 = struct.unpack('<H', value2_bytes)[0]

                if value1 != value2:
                    # 计算位置信息
                    row = i // 768
                    col = i % 768

                    differences.append({
                        'element_idx': i,
                        'row': row,
                        'col': col,
                        'byte_pos': start_idx,
                        'value1': value1,
                        'value2': value2,
                        'hex1': f"0x{value1_bytes.hex()}",
                        'hex2': f"0x{value2_bytes.hex()}"
                    })

            # 输出结果
            if not differences:
                msg = "两个文件完全相同"
                print(msg)
                out_f.write(msg + "\n")
                return

            # 写入差异摘要
            summary = f"发现 {len(differences)} 处差异 (共 {total_elements} 个元素):\n"
            print(summary)
            out_f.write(summary)

            # 写入差异详情表头
            header = "元素位置 | 数组位置(行,列) | 字节位置 | 文件1数值 | 文件2数值 | 文件1十六进制 | 文件2十六进制\n"
            separator = "-" * 100 + "\n"
            print(header)
            print(separator)
            out_f.write(header)
            out_f.write(separator)

            # 写入每个差异
            for diff in differences:
                line = (f"{diff['element_idx']:8d} | ({diff['row']:3d},{diff['col']:3d}) | "
                        f"{diff['byte_pos']:8d} | "
                        f"{diff['value1']:10d} | {diff['value2']:10d} | "
                        f"{diff['hex1']:12s} | {diff['hex2']:12s}\n")
                print(line, end='')
                out_f.write(line)

            # 如果有超出较短文件长度的额外元素
            if len(data1) != len(data2):
                longer_file = "文件1" if len(data1) > len(data2) else "文件2"
                extra_bytes = abs(len(data1) - len(data2))
                extra_elements = extra_bytes // 2
                msg = f"\n{longer_file} 多出 {extra_elements} 个元素 ({extra_bytes} 字节)\n"
                print(msg)
                out_f.write(msg)

            # 添加统计信息
            stats = f"\n差异统计:\n"
            stats += f"总元素数: {total_elements}\n"
            stats += f"不同元素数: {len(differences)}\n"
            stats += f"差异百分比: {len(differences) / total_elements * 100:.6f}%\n"
            print(stats)
            out_f.write(stats)

        print(f"\n详细差异已保存到: {output_file}")

    except FileNotFoundError as e:
        error_msg = f"错误: 文件未找到 - {e}"
        print(error_msg)
        with open(output_file, 'w', encoding='utf-8') as out_f:
            out_f.write(error_msg + "\n")
    except Exception as e:
        error_msg = f"错误: {e}"
        print(error_msg)
        with open(output_file, 'w', encoding='utf-8') as out_f:
            out_f.write(error_msg + "\n")

# compare_bin_files("fpga_result/fpga_out3.bin", "fpga_result/acc_silu_out.bin")