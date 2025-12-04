import numpy as np
from typing import Tuple, Dict, Optional
import general


def handle_nan_values(matrix: np.ndarray, nan_strategy: str = "zero",
                      custom_value: Optional[float] = None) -> np.ndarray:
    """
    处理矩阵中的NaN值

    参数:
        matrix: 输入矩阵
        nan_strategy: NaN处理策略
            - "zero": 用0替换NaN
            - "mean": 用行的均值替换NaN
            - "median": 用行的中位数替换NaN
            - "custom": 用自定义值替换NaN
        custom_value: 自定义替换值（仅在nan_strategy="custom"时使用）

    返回:
        处理后的矩阵
    """
    if not np.isnan(matrix).any():
        return matrix.copy()

    result = matrix.copy()
    num_nans = np.isnan(matrix).sum()
    print(f"检测到 {num_nans} 个NaN值，使用策略 '{nan_strategy}' 处理")

    if nan_strategy == "zero":
        result[np.isnan(result)] = 0.0
    elif nan_strategy == "mean":
        for i in range(result.shape[0]):
            row = result[i]
            if np.isnan(row).any():
                row_mean = np.nanmean(row)
                row[np.isnan(row)] = row_mean if not np.isnan(row_mean) else 0.0
                result[i] = row
    elif nan_strategy == "median":
        for i in range(result.shape[0]):
            row = result[i]
            if np.isnan(row).any():
                row_median = np.nanmedian(row)
                row[np.isnan(row)] = row_median if not np.isnan(row_median) else 0.0
                result[i] = row
    elif nan_strategy == "custom" and custom_value is not None:
        result[np.isnan(result)] = custom_value
    else:
        # 默认用0替换
        result[np.isnan(result)] = 0.0

    return result


def analyze_row_range(matrix_row: np.ndarray) -> Dict:
    """
    分析单行的数据范围特征，处理NaN值
    """
    # 创建不含NaN的副本
    row_no_nan = matrix_row[~np.isnan(matrix_row)]

    if len(row_no_nan) == 0:
        # 全行都是NaN
        return {
            'min_val': 0,
            'max_val': 0,
            'abs_max': 0,
            'has_data': False,
            'nan_count': len(matrix_row),
            'valid_count': 0
        }

    abs_max = np.max(np.abs(row_no_nan)) if len(row_no_nan) > 0 else 0
    min_val = np.min(row_no_nan) if len(row_no_nan) > 0 else 0
    max_val = np.max(row_no_nan) if len(row_no_nan) > 0 else 0

    return {
        'min_val': min_val,
        'max_val': max_val,
        'abs_max': abs_max,
        'has_data': len(row_no_nan) > 0,
        'dynamic_range': max_val - min_val if len(row_no_nan) > 0 else 0,
        'nan_count': np.isnan(matrix_row).sum(),
        'valid_count': len(row_no_nan)
    }


def calculate_row_scale_params(row_stats: Dict, target_range: Tuple[float, float] = (-15, 15)) -> Dict:
    """
    计算单行的缩放参数，处理NaN和无效数据
    """
    target_min, target_max = target_range
    target_span = target_max - target_min

    if not row_stats['has_data'] or row_stats['abs_max'] == 0:
        # 全NaN行或全零行
        return {
            'scale': 1.0,
            'zero_point': 0.0,
            'original_span': 0,
            'target_min': target_min,
            'target_max': target_max,
            'is_valid': False
        }

    # 计算线性缩放参数
    original_span = row_stats['max_val'] - row_stats['min_val']
    if original_span == 0:
        # 所有有效元素相同但非零
        # 避免除以零
        if row_stats['abs_max'] > 0:
            scale = target_span / (2 * row_stats['abs_max'])  # 对称缩放
        else:
            scale = 1.0
        zero_point = target_min - row_stats['min_val'] * scale
    else:
        scale = target_span / original_span
        zero_point = target_min - row_stats['min_val'] * scale

    return {
        'scale': scale,
        'zero_point': zero_point,
        'original_span': original_span,
        'target_min': target_min,
        'target_max': target_max,
        'is_valid': True
    }


def normalize_row(matrix_row: np.ndarray, scale_params: Dict) -> np.ndarray:
    """
    对单行进行归一化，处理NaN值
    """
    normalized = np.zeros_like(matrix_row)

    # 创建掩码，标识有效（非NaN）位置
    valid_mask = ~np.isnan(matrix_row)

    if not scale_params.get('is_valid', True):
        # 无效行，返回全零
        return normalized

    # 只对有效数据进行归一化
    normalized[valid_mask] = matrix_row[valid_mask] * scale_params['scale'] + scale_params['zero_point']

    # 裁剪到目标范围
    if 'target_min' in scale_params and 'target_max' in scale_params:
        normalized[valid_mask] = np.clip(
            normalized[valid_mask],
            scale_params['target_min'],
            scale_params['target_max']
        )

    return normalized


def float_to_fixed_point(normalized_float: float, total_bits: int = 16, frac_bits: int = 11) -> int:
    """
    将归一化后的浮点数转换为定点数，处理NaN和无穷大
    """
    # 检查是否为NaN或无穷大
    if np.isnan(normalized_float) or np.isinf(normalized_float):
        # 对于无效值，返回0
        return 0

    # 计算缩放因子
    scale_factor = 2 ** frac_bits

    # 转换为定点表示
    try:
        fixed_value = int(round(normalized_float * scale_factor))
    except (OverflowError, ValueError):
        # 处理溢出或无效值
        fixed_value = 0

    # 检查溢出（对于1:4:11格式，范围是-16到15.96875）
    max_fixed = (1 << (total_bits - 1)) - 1  # 32767 for 16-bit
    min_fixed = -(1 << (total_bits - 1))  # -32768 for 16-bit

    fixed_value = np.clip(fixed_value, min_fixed, max_fixed)

    return fixed_value


def dynamic_scale_quantize_matrix(matrix: np.ndarray,
                                  target_range: Tuple[float, float] = (-15, 15),
                                  total_bits: int = 16,
                                  frac_bits: int = 11,
                                  nan_strategy: str = "zero",
                                  custom_nan_value: Optional[float] = None) -> Dict:
    """
    主函数：对矩阵的每一行进行动态缩放和定点量化，处理NaN值

    参数:
        matrix: 输入矩阵
        target_range: 目标归一化范围
        total_bits: 总位数
        frac_bits: 小数位数
        nan_strategy: NaN处理策略 ("zero", "mean", "median", "custom")
        custom_nan_value: 自定义NaN替换值
    """
    # 首先处理NaN值
    processed_matrix = handle_nan_values(matrix, nan_strategy, custom_nan_value)

    num_rows, num_cols = processed_matrix.shape

    # 存储结果
    quantized_matrix = np.zeros((num_rows, num_cols), dtype=np.int16)
    scale_params_list = []
    row_stats_list = []

    print(f"开始处理 {num_rows}×{num_cols} 矩阵的量化...")
    print(f"目标范围: {target_range}, 定点格式: 1:{total_bits - 1 - frac_bits}:{frac_bits}")
    print(f"NaN处理策略: {nan_strategy}")

    nan_count_per_row = []

    for i in range(num_rows):
        # 1. 分析当前行的范围
        row_stats = analyze_row_range(processed_matrix[i])
        row_stats_list.append(row_stats)
        nan_count_per_row.append(row_stats['nan_count'])

        # 2. 计算缩放参数
        scale_params = calculate_row_scale_params(row_stats, target_range)
        scale_params_list.append(scale_params)

        # 3. 归一化当前行
        normalized_row = normalize_row(processed_matrix[i], scale_params)

        # 4. 转换为定点数
        for j in range(num_cols):
            quantized_matrix[i, j] = float_to_fixed_point(normalized_row[j], total_bits, frac_bits)

        # 进度显示
        if (i + 1) % 10 == 0 or (i + 1) == num_rows:
            valid_rows = sum(1 for params in scale_params_list if params.get('is_valid', False))
            print(f"已完成第 {i + 1}/{num_rows} 行处理，有效行: {valid_rows}/{i + 1}")

    # 统计信息
    total_nans = sum(nan_count_per_row)
    valid_rows = sum(1 for params in scale_params_list if params.get('is_valid', False))

    print(f"\n处理完成统计:")
    print(f"总NaN值: {total_nans}")
    print(f"有效行数: {valid_rows}/{num_rows}")
    print(f"NaN行数: {num_rows - valid_rows}")

    return {
        'quantized_matrix': quantized_matrix,
        'scale_params': scale_params_list,
        'row_stats': row_stats_list,
        'target_range': target_range,
        'total_bits': total_bits,
        'frac_bits': frac_bits,
        'processed_matrix': processed_matrix,  # 保存处理后的矩阵用于验证
        'nan_strategy': nan_strategy
    }


def verify_quantization(original_matrix: np.ndarray, quant_result: Dict) -> Dict:
    """
    验证量化精度，处理NaN值
    """
    num_rows, num_cols = original_matrix.shape
    reconstructed_matrix = np.zeros_like(original_matrix)
    errors = np.zeros_like(original_matrix)

    total_error = 0
    max_error = 0
    valid_count = 0  # 有效数据点计数

    for i in range(num_rows):
        for j in range(num_cols):
            # 跳过NaN位置
            if np.isnan(original_matrix[i, j]):
                errors[i, j] = np.nan
                continue

            # 反量化
            reconstructed_matrix[i, j] = fixed_point_to_float(
                quant_result['quantized_matrix'][i, j],
                quant_result['scale_params'][i],
                quant_result['frac_bits']
            )

            # 计算误差
            error = abs(original_matrix[i, j] - reconstructed_matrix[i, j])
            errors[i, j] = error
            total_error += error
            max_error = max(max_error, error)
            valid_count += 1

    if valid_count > 0:
        avg_error = total_error / valid_count
    else:
        avg_error = 0

    return {
        'reconstructed': reconstructed_matrix,
        'errors': errors,
        'avg_error': avg_error,
        'max_error': max_error,
        'mse': np.nanmean(errors ** 2),  # 忽略NaN计算MSE
        'valid_count': valid_count,
        'nan_count': num_rows * num_cols - valid_count
    }


def fixed_point_to_float(fixed_value: int, scale_params: Dict, frac_bits: int = 11) -> float:
    """
    将定点数转换回浮点数（用于验证）
    """
    # 先将定点数转回归一化浮点数
    scale_factor = 2 ** frac_bits
    normalized_float = fixed_value / scale_factor

    # 再将归一化浮点数转回原始范围
    # original = (normalized - zero_point) / scale
    original_float = (normalized_float - scale_params['zero_point']) / scale_params['scale']

    return original_float


# 示例使用
if __name__ == "__main__":
    X_bf16 = general.load_bf16_tensor_from_pt("input_data/X_test_tensor_bf16.pt")
    X_fp32 = general.bf16_tensor_to_fp32_numpy(X_bf16)

    print("原始矩阵统计:")
    print(f"全局范围: [{np.nanmin(X_fp32):.3f}, {np.nanmax(X_fp32):.3f}]")
    print(f"绝对值最大值: {np.nanmax(np.abs(X_fp32)):.3f}")
    print(f"NaN数量: {np.isnan(X_fp32).sum()}")
    print()

    # 执行动态缩放量化
    quant_result = dynamic_scale_quantize_matrix(X_fp32, nan_strategy="zero")

    # 验证精度
    verification = verify_quantization(X_fp32, quant_result)

    print(f"\n量化验证结果 (仅非NaN位置):")
    print(f"有效数据点: {verification['valid_count']}/{X_fp32.size}")
    print(f"平均绝对误差: {verification['avg_error']:.6f}")
    print(f"最大绝对误差: {verification['max_error']:.6f}")
    print(f"均方误差: {verification['mse']:.6f}")

    # 显示前几行的缩放参数
    print("\n前5行的缩放参数:")
    for i in range(5):
        params = quant_result['scale_params'][i]
        stats = quant_result['row_stats'][i]
        print(f"行 {i}: 原始范围[{stats['min_val']:.3f}, {stats['max_val']:.3f}] -> "
              f"缩放因子={params['scale']:.6f}, 零点偏移={params['zero_point']:.3f}")