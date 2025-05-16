function fc_demo_axis_from_direction_activation_interactive()
%% fc_demo_axis_from_direction_activation_interactive
% 中文说明：
% 本函数为 GUI 演示程序，用于交互式展示如何通过方向神经元的响应估计对称轴。
% 显示内容包括刺激点阵、真实方向、估计方向，以及神经元响应圈圈。
%
% English description:
% This function is an interactive GUI demo showing how to estimate the symmetry axis
% of neural direction tuning from population activation patterns.
% It displays stimulus dots, ground-truth axis, estimated axis, and neuron activation circles.


f = figure('Name','Axis Estimation Demo / 轴向估计演示','Position',[200 200 1000 600]);

% 参数初始化
param.axis_angle = pi/6;
param.n_neurons = 24;
param.selectivity = 2;
param.noise_level = 0.1;

% 全局状态变量（供多函数共享）
theta_est = nan;            % 模型估计方向
dir_angles = [];            % 神经元方向角列表
activations = [];           % 神经元响应值


% Stimulus 动图变量
n_dots = 200;
n_frames = 5;
motion_per_frame = 0.05;
stim_timer = [];
stim_dots_all = {};
current_frame = 1;

% 图元句柄
h_stim_axis1 = []; h_stim_axis2 = [];
h_est_axis1 = [];  h_est_axis2 = [];
h_dots = []; h_text1 = []; h_text2 = [];
h_neuron_scatter = [];

% 布局：Stimulus 图在左上，UI 在下，模型图在右
ax1 = axes('Parent', f, 'Position', [0.07 0.35 0.38 0.6]);
set(ax1, 'XLim', [-1 1], 'YLim', [-1 1], 'XLimMode', 'manual', ...
    'YLimMode', 'manual', 'DataAspectRatio', [1 1 1], 'PlotBoxAspectRatioMode', 'manual');
axis(ax1, 'off');

ax2 = polaraxes('Parent', f, 'Position', [0.55 0.15 0.40 0.75]);

% -------- 核心模块 -------- %
slider_handles = struct();  % 存储滑块句柄
value_labels = struct();   % 存储滑块值标签

% UI 放到 Stimulus 图下方
add_slider('Stimulus Axis (°)/ 刺激方向（°）', 0, 180, rad2deg(param.axis_angle), [80, 180], 'axis');
add_slider('Num of Neurons / 神经元数量', 6, 48, param.n_neurons, [80, 140], 'neurons');
add_slider('Axis Selectivity / 方向选择性', 0.5, 5, param.selectivity, [80, 100], 'selectivity');
add_slider('Noise Level / 噪声水平', 0, 0.5, param.noise_level, [80, 60], 'noise');

% 初次绘图
update();

% 关闭窗口时清除 timer
set(f, 'CloseRequestFcn', @on_close);



    function add_slider(label, minv, maxv, val, pos, tag)
        uicontrol(f, 'Style', 'text', 'String', label, ...
            'Position', [pos(1), pos(2), 140, 20], 'HorizontalAlignment', 'left');

        slider_handles.(tag) = uicontrol(f, 'Style', 'slider', ...
            'Min', minv, 'Max', maxv, 'Value', val, ...
            'Position', [pos(1)+150, pos(2), 200, 20], ...
            'Tag', tag, 'Callback', @(src,~) on_slider_change(src));

        value_labels.(tag) = uicontrol(f, 'Style', 'text', ...
            'Position', [pos(1)+360, pos(2), 50, 20], ...
            'String', sprintf('%.2f', val), ...
            'HorizontalAlignment', 'left');
    end


    function on_slider_change(src)
        val = get(src, 'Value');
        tag = get(src, 'Tag');

        switch tag
            case 'axis'
                param.axis_angle = deg2rad(val);
            case 'neurons'
                param.n_neurons = round(val);
            case 'selectivity'
                param.selectivity = val;
            case 'noise'
                param.noise_level = val;
        end

        % % % % % 更新右侧数值显示：我不知道为啥这段会导致连续拖动数字更新失败，和GPT聊了好久依然不明白，哈哈哈
        % % % % if isfield(value_labels, tag)
        % % % %     if strcmp(tag, 'neurons')
        % % % %         set(value_labels.(tag), 'String', sprintf('%d', round(val)));
        % % % %     else
        % % % %         set(value_labels.(tag), 'String', sprintf('%.2f', val));
        % % % %     end
        % % % % end
        % 更新右侧数值显示
        if isfield(value_labels, tag)
            switch tag
                case 'axis'
                    val_disp = rad2deg(param.axis_angle);  % ← 从 param 中取值再转为角度
                    set(value_labels.(tag), 'String', sprintf('%.1f', val_disp));
                case 'neurons'
                    set(value_labels.(tag), 'String', sprintf('%d', param.n_neurons));
                case 'selectivity'
                    set(value_labels.(tag), 'String', sprintf('%.2f', param.selectivity));
                case 'noise'
                    set(value_labels.(tag), 'String', sprintf('%.2f', param.noise_level));
            end
        end


        update();
    end


    function reset_display()
        for h = [h_dots, h_text1, h_text2]
            if ~isempty(h) && isgraphics(h)
                delete(h);
            end
        end
        h_dots = []; h_text1 = []; h_text2 = [];
    end

    function update()
        % 生成方向与响应
        dir_angles = linspace(0, 2*pi, param.n_neurons+1)';
        dir_angles(end) = [];
        delta = dir_angles - param.axis_angle;
        activations = cos(delta).^2 .^ param.selectivity;
        activations = activations + param.noise_level * randn(size(activations));
        activations = max(activations, 0);
        theta_est = fc_axis_from_direction_activation(dir_angles, activations);

        prepare_stimulus_frames();
        update_axis_lines();  % 红蓝线一次更新
        current_frame = 1;
        show_stimulus_frame();
        restart_timer();

        % 极坐标图
        polarplot(ax2, [dir_angles; dir_angles(1)], [activations; activations(1)], '-o'); hold(ax2, 'on');
        r_max = max(activations);
        polarplot(ax2, [param.axis_angle, param.axis_angle+pi], [r_max, r_max], 'r-', 'LineWidth', 3);
        polarplot(ax2, [theta_est, theta_est+pi], [r_max, r_max], 'b-', 'LineWidth', 2);
        legend(ax2, {'Activation', 'Stimulus Axis', 'Estimated Axis'}, 'Location', 'southoutside');
        hold(ax2, 'off');
        title(ax2, sprintf('Estimated Axis = %.1f°', rad2deg(mod(theta_est, pi))));

        % --- 初始化神经元圈圈（仅执行一次） ---
        r_circle = 0.9;
        dir_x = r_circle * cos(dir_angles);
        dir_y = r_circle * sin(dir_angles);
        activation_size = 200 * activations / max(activations + 1e-6);
        activation_size = max(activation_size, 1);

        if isempty(h_neuron_scatter) || ~isgraphics(h_neuron_scatter)
            h_neuron_scatter = scatter(ax1, dir_x, dir_y, activation_size, 'b', 'filled', ...
                'MarkerFaceAlpha', 0.3, 'MarkerEdgeAlpha', 0.4);
        else
            set(h_neuron_scatter, ...
                'XData', dir_x, 'YData', dir_y, 'SizeData', activation_size);
        end

    end

    function prepare_stimulus_frames()
        stim_dots_all = cell(n_frames, 1);
        rng(1);
        dots = 2 * (rand(n_dots, 2) - 0.5);
        dir = [cos(param.axis_angle), sin(param.axis_angle)];
        for i = 1:n_frames
            shift = (i-1) * motion_per_frame * dir;
            stim_dots_all{i} = dots + shift;
        end
    end

    function show_stimulus_frame()
        reset_display();
        dots = stim_dots_all{current_frame};
        hold(ax1, 'on');
        h_dots = scatter(ax1, dots(:,1), dots(:,2), 8, 'k', 'filled');
        update_axis_lines();  % 红蓝线方向更新

        h_text1 = text(ax1, -0.9, 0.95, sprintf('Stimulus Axis = %.1f°', rad2deg(param.axis_angle)), ...
            'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
        h_text2 = text(ax1, -0.9, 0.85, sprintf('Stimulus Frame %d', current_frame), ...
            'Color', 'k', 'FontSize', 10);
        drawnow;
        current_frame = mod(current_frame, n_frames) + 1;
    end

    function update_axis_lines()
        % 红线
        stim_dir = [cos(param.axis_angle), sin(param.axis_angle)];
        if isempty(h_stim_axis1) || ~isvalid(h_stim_axis1)
            hold(ax1, 'on');
            h_stim_axis1 = plot(ax1, [0 stim_dir(1)], [0 stim_dir(2)], 'r-', 'LineWidth', 3);
            h_stim_axis2 = plot(ax1, [0 -stim_dir(1)], [0 -stim_dir(2)], 'r--', 'LineWidth', 2);
        else
            set(h_stim_axis1, 'XData', [0 stim_dir(1)], 'YData', [0 stim_dir(2)]);
            set(h_stim_axis2, 'XData', [0 -stim_dir(1)], 'YData', [0 -stim_dir(2)]);
        end

        % 蓝线
        est_dir = [cos(theta_est), sin(theta_est)];
        if isempty(h_est_axis1) || ~isvalid(h_est_axis1)
            h_est_axis1 = plot(ax1, [0 est_dir(1)], [0 est_dir(2)], 'b-', 'LineWidth', 2);
            h_est_axis2 = plot(ax1, [0 -est_dir(1)], [0 -est_dir(2)], 'b--', 'LineWidth', 1.5);
        else
            set(h_est_axis1, 'XData', [0 est_dir(1)], 'YData', [0 est_dir(2)]);
            set(h_est_axis2, 'XData', [0 -est_dir(1)], 'YData', [0 -est_dir(2)]);
        end
    end

    function restart_timer()
        if ~isempty(stim_timer) && isvalid(stim_timer)
            stop(stim_timer); delete(stim_timer);
        end
        stim_timer = timer( ...
            'ExecutionMode', 'fixedRate', ...
            'Period', 0.2, ...
            'TimerFcn', @(~,~) show_stimulus_frame());
        start(stim_timer);
    end

    function on_close(~, ~)
        if ~isempty(stim_timer) && isvalid(stim_timer)
            stop(stim_timer); delete(stim_timer);
        end
        delete(f);
    end
end