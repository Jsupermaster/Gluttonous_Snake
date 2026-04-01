import numpy as np

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

def l2_error(golden, output):
    """
    计算两个数组之间的相对L2误差，增强数值稳定性
    """
    # 使用float64进行计算以避免溢出
    f32_max = np.finfo(np.float32).max
    f32_min = -f32_max

    if output.shape != golden.shape:
        raise ValueError(f"Shape mismatch: {output.shape} vs {golden.shape}")

    # 转换为 float64 便于更稳定的计算
    output_f64 = np.array(output, dtype=np.float64)
    golden_f64 = np.array(golden, dtype=np.float64)

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

    return errors, errors_point