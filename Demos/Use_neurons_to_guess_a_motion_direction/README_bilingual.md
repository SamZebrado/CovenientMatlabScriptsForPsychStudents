# 轴向估计演示 / Axis Estimation Demo

本 Demo 展示了如何基于方向神经元的响应，估计其偏好方向的对称轴。
This demo illustrates how to estimate the symmetry axis of a directional neural population response.

## 🚀 使用方法 / How to Use

1. 打开 MATLAB，运行：
1. Open MATLAB and run:
```matlab
fc_demo_axis_from_direction_activation_interactive
```

2. 左侧图为刺激图像，显示：
2. The left panel shows the stimulus scene with:
- 黑点：随机运动点
- Black dots: randomly moving stimulus
- 红线：设定的刺激方向
- Red axis: the ground-truth stimulus axis
- 蓝线：估计的主轴方向
- Blue axis: the estimated axis from neuron activations
- 蓝圈：表示每个神经元方向及其激活强度（圈圈越大，激活越强）
- Blue circles: neuron direction and response (larger = stronger activation)

3. 右侧图为极坐标图，显示神经元的响应分布及估计轴。
3. The right polar plot shows neuron activation and estimated axis.

4. 下方滑块可调节刺激方向、神经元数目、选择性和噪声强度。
4. Sliders below allow adjusting stimulus axis, number of neurons, tuning selectivity, and noise.

## 📘 数学原理 / Mathematical Principle

神经元的激活被表示为：
The neuron activation is modeled as:
$$ a_i = \cos^2(\theta_i - \theta_0)^s + \epsilon $$

- \(\theta_i\)：第 i 个神经元的偏好方向
- \(\theta_i\): preferred direction of the i-th neuron
- \(\theta_0\)：刺激轴方向（对称轴）
- \(\theta_0\): stimulus symmetry axis
- \(s\)：选择性，越大表示方向越敏感
- \(s\): selectivity, larger means sharper tuning
- \(\epsilon\)：噪声项
- \(\epsilon\): noise

利用加权向量投影（scatter matrix）+ 主成分分析，即可估计该对称轴。
We use a scatter matrix + PCA-style method to estimate the dominant axis of symmetry.