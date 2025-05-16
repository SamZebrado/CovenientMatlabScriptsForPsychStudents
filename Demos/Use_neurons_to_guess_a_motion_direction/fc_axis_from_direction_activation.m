function theta_axis = fc_axis_from_direction_activation(dir_angles, activations)
%% fc_axis_from_direction_activation
% 中文说明：
% 根据一组方向角和对应响应值，计算主轴方向（估计的对称轴方向）。
% 算法核心是计算散度矩阵并提取最大特征值对应的方向。
%
% English description:
% Given a set of direction angles and response values, this function estimates
% the axis of symmetry by computing the scatter matrix and extracting the principal eigenvector.
%
% 输入（Inputs）:
% - dir_angles: [n x 1] 方向角（弧度）
% - activations: [n x 1] 对应的神经元响应
%
% 输出（Output）:
% - theta_axis: 主轴方向（弧度），取值范围为 [-π, π]

% dir_angles: [n_dirs x 1], activation angles in radians
% activations: [n_dirs x 1], scalar responses

% Step 1: Convert to Cartesian points
X = activations .* cos(dir_angles);
Y = activations .* sin(dir_angles);

% Step 2: Stack as Nx2 matrix
V = [X, Y];  % each row = a point

% Step 3: Compute 2x2 scatter matrix (uncentered covariance)
S = V' * V;

% Step 4: Solve eigenvector of S manually (avoid PCA)
% Eigenvector u of S satisfies S*u = lambda*u
% We'll solve the eigen decomposition explicitly

[eigvecs, eigvals] = eig(S);

% Step 5: Choose eigenvector with largest eigenvalue
[~, idx] = max(diag(eigvals));
u = eigvecs(:, idx);  % principal axis

% Step 6: Convert to angle
theta_axis = atan2(u(2), u(1));  % ∈ (-π, π]
end
