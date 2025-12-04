"""存放通用的函数及pytorch函数参考实现"""
import torch
import numpy as np
import torch.nn.functional as F
import struct
import os

"""**************官方给出的工具函数和数据处理函数***************"""

def nanmax(x: torch.Tensor, dim=None, keepdim=False):
    # 把 NaN 改为 -inf，再做 max；全 NaN 的切片返回 NaN
    if dim is None:
        if torch.isnan(x).all():
            return torch.tensor(float('nan'), dtype=x.dtype, device=x.device)
        xc = x.clone()
        xc[torch.isnan(xc)] = -float('inf')
        return xc.max()
    else:
        xc = x.clone()
        mask_nan = torch.isnan(xc)
        xc[mask_nan] = -float('inf')
        vals, idx = torch.max(xc, dim=dim, keepdim=keepdim)
        all_nan = mask_nan.all(dim=dim, keepdim=keepdim)
        vals = vals.masked_fill(all_nan, float('nan'))
        return vals

def nansum(x: torch.Tensor, dim=None, keepdim=False):
    xc = x.clone()
    xc[torch.isnan(xc)] = 0.0
    return torch.sum(xc, dim=dim, keepdim=keepdim)

def nanmean(x: torch.Tensor, dim=None, keepdim=False):
    mask = ~torch.isnan(x)
    xc = x.clone()
    xc[~mask] = 0.0
    s = torch.sum(xc, dim=dim, keepdim=keepdim)
    cnt = mask.sum(dim=dim, keepdim=keepdim).clamp(min=1)
    m = s / cnt
    if dim is None:
        return m if mask.any() else torch.tensor(float('nan'), dtype=x.dtype, device=x.device)
    else:
        return m.masked_fill(cnt == 0, float('nan'))


def to_bf16_bits(t_bf16: torch.Tensor) -> np.ndarray:
    """
    将 torch.bfloat16 Tensor 的位模式导出为 numpy.uint16（行主序）。
    """
    assert t_bf16.dtype == torch.bfloat16
    # 通过 float32 过渡到 bf16 的高 16bit：PyTorch 内部已管理好
    # 直接 view 成 uint16 即可得到 bf16 的 16bit 模式
    return t_bf16.view(torch.uint16).cpu().contiguous().numpy()

def from_bf16_bits(bits_u16: np.ndarray, shape) -> torch.Tensor:
    """
    将 numpy.uint16 的 bf16 位模式恢复为 torch.bfloat16 Tensor。
    """
    t = torch.from_numpy(bits_u16.astype(np.uint16)).view(shape)
    return t.view(torch.bfloat16)

def f32_to_bf16(x: torch.Tensor) -> torch.Tensor:
    """
    将 float32 Tensor 舍入为 bfloat16（遵循 PyTorch 的 round-to-nearest-even）。
    """
    assert x.dtype == torch.float32
    return x.to(torch.bfloat16)

def bf16_to_f32(x: torch.Tensor) -> torch.Tensor:
    """
    将 bfloat16 Tensor 提升为 float32（不会增加精度，但便于某些运算）。
    """
    assert x.dtype == torch.bfloat16
    return x.to(torch.float32)

"""**************官方给出的参考实现***************"""

def ref_softmax(x_bf16: torch.Tensor, dim=-1) -> torch.Tensor:
    x = x_bf16.to(torch.float32)
    # 按常规做数值稳定 softmax
    x = x - nanmax(x, dim=dim, keepdim=True)
    y = torch.exp(x)
    denom = nansum(y, dim=dim, keepdim=True)
    out = y / denom
    return out.to(torch.bfloat16)

def ref_layernorm(x_bf16: torch.Tensor, eps=1e-5, D=None) -> torch.Tensor:
    x = x_bf16.to(torch.float32)
    if D is None:
        D = x.shape[-1]
    mean = nanmean(x, dim=-1, keepdim=True)
    var = nanmean((x - mean) ** 2, dim=-1, keepdim=True)
    out = (x - mean) / torch.sqrt(var + eps)
    return out.to(torch.bfloat16)

def ref_rmsnorm(x_bf16: torch.Tensor, eps=1e-5) -> torch.Tensor:
    x = x_bf16.to(torch.float32)
    msq = nanmean(x**2, dim=-1, keepdim=True)
    out = x / torch.sqrt(msq + eps)
    return out.to(torch.bfloat16)

def ref_silu(x_bf16: torch.Tensor) -> torch.Tensor:
    x = x_bf16.to(torch.float32)
    out = x * torch.sigmoid(x)
    return out.to(torch.bfloat16)

def ref_gelu(x_bf16: torch.Tensor, approximate='tanh') -> torch.Tensor:
    x = x_bf16.to(torch.float32)
    # 使用 PyTorch 的近似实现（默认 approximate='tanh'）
    out = F.gelu(x, approximate=approximate)
    return out.to(torch.bfloat16)

def ref_add(x_bf16: torch.Tensor, y_bf16: torch.Tensor) -> torch.Tensor:
    return (x_bf16.to(torch.float32) + y_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_mul(x_bf16: torch.Tensor, y_bf16: torch.Tensor) -> torch.Tensor:
    return (x_bf16.to(torch.float32) * y_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_exp(x_bf16: torch.Tensor) -> torch.Tensor:
    return torch.exp(x_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_ln(x_bf16: torch.Tensor) -> torch.Tensor:
    return torch.log(x_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_reciprocal(x_bf16: torch.Tensor) -> torch.Tensor:
    return torch.reciprocal(x_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_sqrt(x_bf16: torch.Tensor) -> torch.Tensor:
    return torch.sqrt(x_bf16.to(torch.float32)).to(torch.bfloat16)

def ref_rsqrt(x_bf16: torch.Tensor) -> torch.Tensor:
    return torch.rsqrt(x_bf16.to(torch.float32)).to(torch.bfloat16)

"""**************测试数据生成函数/文件读取函数***************"""

def uint16_to_coe(int_data_np, filename):
    """
    使用numpy向量化操作的版本，更高效
    """
    if int_data_np.dtype != np.uint16:
        raise ValueError("输入数组必须是uint16格式")

    # 展平并确保偶数长度
    int_data_np = int_data_np.flatten()
    if len(int_data_np) % 2 != 0:
        int_data_np = np.append(int_data_np, 0)

    # 创建填充数据
    fill_count = 2048
    fill_data_16bit = np.full(fill_count, 0xffff, dtype=np.uint16)

    # 使用numpy的向量化操作组合数据
    # 将填充数据和实际数据连接
    all_16bit = np.concatenate([fill_data_16bit, int_data_np])

    # 确保总长度为偶数
    if len(all_16bit) % 2 != 0:
        all_16bit = np.append(all_16bit, 0)

    # 重塑为2列，然后组合成32位
    reshaped = all_16bit.reshape(-1, 2)
    combined_32bit = (reshaped[:, 0].astype(np.uint32) << 16) | reshaped[:, 1]

    # 写入COE文件
    with open(filename, 'w') as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")

        for i, value in enumerate(combined_32bit):
            hex_value = format(int(value), '08x')
            if i == len(combined_32bit) - 1:
                f.write(f"{hex_value};\n")
            else:
                f.write(f"{hex_value},\n")

def get_bf16_from_bin(file_path, size, row_save=None, output_path=None):
    """
    读取存储uint16格式bfloat16数据的二进制文件，按指定尺寸解析
    返回fp32格式存储的numpy数组，可以指定保存其中的某些行。

    参数:
        file_path (str): 二进制文件的路径
        size (tuple): 矩阵尺寸 (行数, 列数)
        row_save (list): 要提取保存的行索引列表（可选）
        output_path (str): 提取行的输出文件路径（可选）

    返回:
        np.ndarray: 指定尺寸的NumPy矩阵，包含解析后的bfloat16数据
    """
    with open(file_path, 'rb') as f:
        # 读取整个文件内容
        raw_data = f.read()

        # 计算预期文件大小
        rows = size[0]
        cols = size[1]
        expected_size = rows * cols * 2
        if len(raw_data) != expected_size:
            print(f"警告: 文件大小异常 ({len(raw_data)}字节)，预期应为{expected_size}字节")

        # 解析为uint16数组
        num_values = len(raw_data) // 2
        uint16_data = struct.unpack(f'<{num_values}H', raw_data)

        # 重塑为指定尺寸矩阵
        matrix = np.array(uint16_data).reshape(rows, cols)

        # 创建浮点数矩阵
        float_matrix = np.zeros((rows, cols), dtype=np.float32)

        # 转换为bfloat16浮点数
        for i in range(rows):
            for j in range(cols):
                # 将uint16转换为float32
                float_val = struct.unpack('<f', struct.pack('<I', (int(matrix[i, j]) & 0xFFFF) << 16))[0]
                float_matrix[i, j] = float_val

        # 提取并保存指定行
        if row_save is not None and output_path is not None:
            # 验证行索引
            valid_rows = [i for i in row_save if 0 <= i < rows]
            invalid_rows = [i for i in row_save if i not in valid_rows]

            if invalid_rows:
                print(f"警告: 忽略无效行索引 {invalid_rows} (有效范围: 0-{rows - 1})")

            if valid_rows:
                print(f"提取行: {valid_rows}")

                # 创建提取行的uint16数据
                extracted_data = []
                for row_idx in valid_rows:
                    # 获取原始uint16数据
                    row_data = matrix[row_idx]
                    extracted_data.extend(row_data)

                # 转换为字节数据
                byte_data = b''.join(struct.pack('<H', val) for val in extracted_data)

                # 保存到文件
                with open(output_path, 'wb') as out_file:
                    out_file.write(byte_data)

                print(f"成功保存 {len(valid_rows)} 行到 {output_path}")
                print(f"输出文件大小: {len(byte_data)} 字节")
            else:
                print("警告: 没有有效的行可提取")

        return float_matrix

def load_bf16_tensor_from_pt(file_path):
    """
    从 .pt 文件中加载 BF16 格式的张量数据

    参数:
        file_path (str): .pt 文件的路径

    返回:
        torch.Tensor: 包含 BF16 数据的张量

    异常:
        FileNotFoundError: 如果文件不存在
        RuntimeError: 如果文件格式不正确或加载失败
    """
    try:
        # 加载 .pt 文件
        data = torch.load(file_path, map_location=torch.device('cpu'))

        # 验证数据类型
        if not isinstance(data, torch.Tensor):
            raise RuntimeError(f"文件内容不是张量，而是 {type(data)} 类型")

        # 检查是否为 BF16 格式
        if data.dtype != torch.bfloat16:
            print(f"警告: 张量数据类型为 {data.dtype}，不是 torch.bfloat16")

        return data

    except FileNotFoundError:
        raise FileNotFoundError(f"文件未找到: {file_path}")
    except Exception as e:
        raise RuntimeError(f"加载文件失败: {str(e)}")


def bf16_tensor_to_fp32_numpy(tensor):
    """
    将 BF16 格式的 PyTorch 张量转换为 NumPy FP32 数组

    参数:
        tensor (torch.Tensor): BF16 格式的输入张量

    返回:
        np.ndarray: FP32 格式的 NumPy 数组

    异常:
        TypeError: 如果输入不是 PyTorch 张量
        ValueError: 如果张量数据类型不是 BF16
    """
    # 验证输入类型
    if not isinstance(tensor, torch.Tensor):
        raise TypeError(f"输入必须是 torch.Tensor，实际类型为 {type(tensor)}")

    # 验证数据类型
    if tensor.dtype != torch.bfloat16:
        raise ValueError(f"张量数据类型应为 torch.bfloat16，实际为 {tensor.dtype}")

    try:
        # 确保张量在 CPU 上
        if tensor.device.type != 'cpu':
            tensor = tensor.cpu()

        # 转换为 FP32 张量
        fp32_tensor = tensor.to(torch.float32)

        # 转换为 NumPy 数组
        np_array = fp32_tensor.numpy()

        return np_array

    except Exception as e:
        raise RuntimeError(f"转换失败: {str(e)}")


def save_fp32_matrix(matrix, save_path, matrix_name="Matrix"):
    """
    将FP32矩阵的值保存为详细格式的报告

    参数:
        matrix (np.ndarray): 要保存的FP32数组 (形状: MxN)
        save_path (str): 报告保存路径
        matrix_name (str): 矩阵的名称标识

    返回:
        pd.DataFrame: 包含索引和值的DataFrame

    异常:
        ValueError: 如果输入不是NumPy数组或不是float32类型
    """
    # 验证输入类型
    if not isinstance(matrix, np.ndarray):
        raise ValueError("输入必须是 NumPy 数组")

    # 验证数据类型
    if matrix.dtype != np.float32:
        raise ValueError("数组必须是 float32 类型")

    rows, cols = matrix.shape
    total_elements = rows * cols

    # 创建DataFrame来存储所有结果
    results = []

    with open(save_path, 'w', encoding='utf-8') as f:
        # 写入标题和摘要
        f.write(f"FP32 矩阵数据报告 - {matrix_name}\n")
        f.write(f"矩阵形状: {matrix.shape}\n")
        f.write(f"总元素数量: {total_elements}\n")
        f.write(f"数据类型: {matrix.dtype}\n")
        f.write("=" * 80 + "\n\n")

        # 写入列标题
        f.write(f"{'索引':<12} {'值':<25} {'十六进制表示':<20} {'备注':<15}\n")
        f.write("-" * 80 + "\n")

        for i in range(rows):
            for j in range(cols):
                value = matrix[i, j]

                # 获取值的十六进制表示
                hex_repr = ""
                try:
                    # 将float32转换为整数表示，然后转换为十六进制
                    hex_repr = hex(matrix.view(np.uint32)[i, j])
                except:
                    hex_repr = "N/A"

                # 添加备注信息
                remark = ""
                if np.isnan(value):
                    remark = "NaN"
                elif np.isinf(value):
                    remark = "Inf" if value > 0 else "-Inf"
                elif value == 0:
                    if np.signbit(value):
                        remark = "-0"
                    else:
                        remark = "+0"
                else:
                    remark = "正常值"

                # 写入文件
                if np.isfinite(value) and value != 0:
                    f.write(f"({i:2d},{j:3d})     {value:<25.10g} {hex_repr:<20} {remark:<15}\n")
                else:
                    f.write(f"({i:2d},{j:3d})     {value:<25} {hex_repr:<20} {remark:<15}\n")

                # 同时保存到DataFrame
                results.append({
                    'index': f"({i},{j})",
                    'value': value,
                    'hex_representation': hex_repr,
                    'remark': remark
                })

        # 添加统计信息
        f.write("\n" + "=" * 80 + "\n")
        f.write("统计信息:\n")

        # 基本统计（只考虑有限值）
        finite_mask = np.isfinite(matrix)
        finite_values = matrix[finite_mask]

        if len(finite_values) > 0:
            f.write(f"有限值数量: {len(finite_values)}\n")
            f.write(f"平均值: {np.mean(finite_values):.10g}\n")
            f.write(f"标准差: {np.std(finite_values):.10g}\n")
            f.write(f"最小值: {np.min(finite_values):.10g}\n")
            f.write(f"最大值: {np.max(finite_values):.10g}\n")
        else:
            f.write("无有限值可统计\n")

        # 特殊值统计
        nan_count = np.sum(np.isnan(matrix))
        inf_count = np.sum(np.isinf(matrix))
        pos_inf_count = np.sum(matrix == np.inf)
        neg_inf_count = np.sum(matrix == -np.inf)
        zero_count = np.sum(matrix == 0)
        neg_zero_count = np.sum((matrix == 0) & np.signbit(matrix))

        f.write(f"NaN数量: {nan_count}\n")
        f.write(f"Inf数量: {inf_count} (正Inf: {pos_inf_count}, 负Inf: {neg_inf_count})\n")
        f.write(f"零值数量: {zero_count} (负零: {neg_zero_count})\n")

        # 值分布统计（按数量级）
        if len(finite_values) > 0:
            abs_values = np.abs(finite_values)
            abs_values = abs_values[abs_values > 0]  # 排除零值

            if len(abs_values) > 0:
                log_values = np.log10(abs_values)
                f.write(f"值范围: 10^{np.min(log_values):.2f} 到 10^{np.max(log_values):.2f}\n")

                # 按数量级分组统计
                bins = [-np.inf, -10, -1, 0, 1, 10, np.inf]
                bin_labels = ["<-10", "-10~-1", "-1~0", "0~1", "1~10", ">10"]

                for i in range(len(bins) - 1):
                    count = np.sum((finite_values >= bins[i]) & (finite_values < bins[i + 1]))
                    if count > 0:
                        f.write(f"值在{bin_labels[i]}范围内的数量: {count}\n")

if __name__ == '__main__':
    # 将所有的参考结果转换为bin，便于fpga调试

    # # softmax
    # ref_softmax_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_softmax_bf16.pt")
    # ref_softmax_uint16 = to_bf16_bits(ref_softmax_bf16)
    # ref_softmax_uint16.tofile(os.path.join("ref_bin_bf16/ref_softmax_bf16.bin"))
    #
    # # add
    # ref_add_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_add_bf16.pt")
    # ref_add_uint16 = to_bf16_bits(ref_add_bf16)
    # ref_add_uint16.tofile(os.path.join("ref_bin_bf16/ref_add_bf16.bin"))
    #
    # # gelu
    # ref_gelu_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_gelu_bf16.pt")
    # ref_gelu_uint16 = to_bf16_bits(ref_gelu_bf16)
    # ref_gelu_uint16.tofile(os.path.join("ref_bin_bf16/ref_gelu_bf16.bin"))
    #
    # # layernorm
    # ref_layernorm_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_layernorm_bf16.pt")
    # ref_layernorm_uint16 = to_bf16_bits(ref_layernorm_bf16)
    # ref_layernorm_uint16.tofile(os.path.join("ref_bin_bf16/ref_layernorm_bf16.bin"))
    #
    # # mul
    # ref_mul_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_mul_bf16.pt")
    # ref_mul_uint16 = to_bf16_bits(ref_mul_bf16)
    # ref_mul_uint16.tofile(os.path.join("ref_bin_bf16/ref_mul_bf16.bin"))
    #
    # # rmsnorm
    # ref_rmsnorm_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_rmsnorm_bf16.pt")
    # ref_rmsnorm_uint16 = to_bf16_bits(ref_rmsnorm_bf16)
    # ref_rmsnorm_uint16.tofile(os.path.join("ref_bin_bf16/ref_rmsnorm_bf16.bin"))
    #
    # # silu
    # ref_silu_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_silu_bf16.pt")
    # ref_silu_uint16 = to_bf16_bits(ref_silu_bf16)
    # ref_silu_uint16.tofile(os.path.join("ref_bin_bf16/ref_silu_bf16.bin"))

    # 生成e的指数、ln、分数、根号、根号分之1的测试数据

    # X_bf16 = load_bf16_tensor_from_pt("input_data/X_test_tensor_bf16.pt")
    # X_uint16 = to_bf16_bits(X_bf16)
    # uint16_to_coe(X_uint16, "input_data/in0_hex.coe")
    # X_fp32 = bf16_tensor_to_fp32_numpy(X_bf16)
    # save_fp32_matrix(X_fp32, "input_data/in0.txt", "IN 0")
    #
    # Y_bf16 = load_bf16_tensor_from_pt("input_data/Y_test_tensor_bf16.pt")
    # Y_uint16 = to_bf16_bits(Y_bf16)
    # uint16_to_coe(Y_uint16, "input_data/in1_hex.coe")
    # Y_fp32 = bf16_tensor_to_fp32_numpy(Y_bf16)
    # save_fp32_matrix(Y_fp32, "input_data/in1.txt", "IN 1")

    X_bf16 = load_bf16_tensor_from_pt("ref_pt_bf16/ref_add_bf16.pt")
    X_fp32 = bf16_tensor_to_fp32_numpy(X_bf16)
    save_fp32_matrix(X_fp32, "ref_add_bf16.txt", "ref_add_bf16")

    # ref_exp_pt = ref_exp(X_bf16)
    # ref_exp_bf16 = to_bf16_bits(ref_exp_pt)
    # ref_exp_bf16.tofile("ref_bin_bf16/ref_exp_bf16.bin")
    #
    # ref_ln_pt = ref_ln(X_bf16)
    # ref_ln_bf16 = to_bf16_bits(ref_ln_pt)
    # ref_ln_bf16.tofile("ref_bin_bf16/ref_ln_bf16.bin")
    #
    # ref_reciprocal_pt = ref_reciprocal(X_bf16)
    # ref_reciprocal_bf16 = to_bf16_bits(ref_reciprocal_pt)
    # ref_reciprocal_bf16.tofile("ref_bin_bf16/ref_rec_bf16.bin")
    #
    # ref_sqrt_pt = ref_sqrt(X_bf16)
    # ref_sqrt_bf16 = to_bf16_bits(ref_sqrt_pt)
    # ref_sqrt_bf16.tofile("ref_bin_bf16/ref_sqrt_bf16.bin")
    #
    # ref_rsqrt_pt = ref_rsqrt(X_bf16)
    # ref_rsqrt_bf16 = to_bf16_bits(ref_rsqrt_pt)
    # ref_rsqrt_bf16.tofile("ref_bin_bf16/ref_rsqrt_bf16.bin")
    #
    # uint16_to_coe(X_uint16, "in0_hex.coe")
    # uint16_to_coe(Y_uint16, "in1_hex.coe")

