import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# 设置论文级别的图表样式
plt.rcParams['font.family'] = 'Times New Roman'
plt.rcParams['font.size'] = 14
plt.rcParams['axes.labelsize'] = 14
plt.rcParams['axes.titlesize'] = 16
plt.rcParams['xtick.labelsize'] = 12
plt.rcParams['ytick.labelsize'] = 12
plt.rcParams['legend.fontsize'] = 12
plt.rcParams['figure.titlesize'] = 18

# 数据
data = {
    'Operation': ['SOFTMAX', 'LAYERNORM', 'RMSNORM', 'SILU', 'GELU', 'EADD', 'EMUL'],
    'Dual Cortex-A53': [0.016559, 0.003172, 0.002253, 0.00098, 0.004774, 0.000555, 0.000449],
    'AMD Ryzen7 7840HS': [0.002883, 0.000538, 0.000165, 0.000102, 0.000077, 0.0000429, 0.000033],
    'Nvidia RTX3090': [0.001139, 0.002259, 0.001068, 0.000293, 0.000243, 0.000286, 0.000282],
    'HLS Baseline': [0.0022, 0.0011, 0.0012, 0.0011, 0.0011, 0.0011, 0.0022],
    'Our Accelerator': [0.00002067, 0.00001997, 0.00002007, 0.00002067, 0.00002034, 0.00002024, 0.00002027]
}

df = pd.DataFrame(data)
df.set_index('Operation', inplace=True)

# 创建组合图表：对数刻度柱状图 + 折线图
fig, ax = plt.subplots(figsize=(16, 8))  # 调整图表尺寸

# 设置对数刻度
ax.set_yscale('log')

# 柱状图参数 - 减小组间距离
x = np.arange(len(df.index))
width = 0.15  # 柱子宽度

# 科研风高级感配色方案
colors = ["#003f5c", "#2f4b7c", "#665191", "#a05195", "#d45087"]

# 绘制柱状图
bars = []
for i, column in enumerate(df.columns):
    bar = ax.bar(x + i*width, df[column], width, label=column,
                color=colors[i], alpha=0.85, edgecolor='white', linewidth=1.2)
    bars.append(bar)

# 绘制折线图（叠加在柱状图上）
markers = ['o', 's', '^', 'D', 'v']
marker_sizes = [6, 6, 6, 6, 6]
line_styles = ['-', '--', '-.', ':', '-']
line_widths = [2.0, 2.0, 2.0, 2.0, 2.0]

for i, column in enumerate(df.columns):
    # 计算每个硬件在每个操作上的x坐标（柱状图中心位置）
    line_x = x + i*width + width/2
    ax.plot(line_x, df[column],
            marker=markers[i],
            markersize=marker_sizes[i],
            linestyle=line_styles[i],
            linewidth=line_widths[i],
            color=colors[i],
            alpha=0.9,
            markerfacecolor='white',
            markeredgecolor=colors[i],
            markeredgewidth=1.5)

# 为我们的加速器添加时间标注
our_accelerator_index = 4  # Our Accelerator在数据中的索引
for i, op in enumerate(df.index):
    time_val = df.loc[op, 'Our Accelerator']
    bar_center_x = x[i] + our_accelerator_index * width + width / 2
    # 在对数坐标下，标注位置稍微高于柱子
    y_pos = time_val * 1.3
    # 格式化时间显示为科学计数法
    time_str = f"{time_val:.2e}"
    ax.text(bar_center_x, y_pos, time_str,
            ha='center', va='bottom', fontsize=18, rotation=0,
            fontweight='bold', color=colors[our_accelerator_index],
            bbox=dict(boxstyle="round,pad=0.2", facecolor='white',
                     edgecolor=colors[our_accelerator_index], alpha=0.8))

# 设置图表属性
ax.set_xlabel('', fontweight='bold', fontsize=20)
ax.set_ylabel('', fontweight='bold', fontsize=18)
ax.set_title('',
             fontweight='bold', pad=20, fontsize=16)

# 设置x轴刻度和标签
ax.set_xticks(x + width*2)
ax.set_xticklabels(df.index, rotation=0, ha='center', fontsize=18)

# 添加网格
ax.grid(True, alpha=0.2, which='both', linestyle='-', linewidth=0.5)
ax.set_axisbelow(True)  # 将网格放在数据后面

# 添加图例到图内部，调整位置使其更紧凑
ax.legend(loc='upper right', frameon=True,
          fancybox=True, shadow=True, ncol=1,
          framealpha=0.95, edgecolor='gray',
          bbox_to_anchor=(0.99, 1), fontsize=18)  # 调整图例位置使其更紧凑

# 设置y轴范围，留出一些空间给图例
ax.set_ylim(bottom=1e-5, top=2e-2)

# 设置x轴范围，使图表更紧凑
ax.set_xlim(-0.3, len(df.index) - 0.1)

# 调整布局
plt.tight_layout()

# 保存为高分辨率图片
plt.savefig('combined_performance_comparison.png', dpi=300, bbox_inches='tight')
plt.savefig('combined_performance_comparison.pdf', bbox_inches='tight')  # 矢量图版本，适合论文

plt.show()