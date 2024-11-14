% demo_rearrange_subplots - 演示如何使用 rearrange_subplots 函数
% demo_rearrange_subplots - Demonstrates usage of rearrange_subplots function

% 创建源图 1，包含多个子图 / Create Source Figure 1 with multiple subplots
fig1 = figure('Name', 'Source Figure 1');
for i = 1:6
    subplot(2, 3, i);
    plot(rand(1, 10) * i); % 示例数据 / Example data
    title(sprintf('Source 1 - Subplot %d', i));
end

% 保存源图 1 / Save Source Figure 1
saveas(fig1, 'source_fig1.fig');
close(fig1);

% 创建源图 2，包含多个子图 / Create Source Figure 2 with multiple subplots
fig2 = figure('Name', 'Source Figure 2');
for i = 1:6
    subplot(2, 3, i);
    plot(rand(1, 10) * (7 - i)); % 示例数据 / Example data
    title(sprintf('Source 2 - Subplot %d', i));
end

% 保存源图 2 / Save Source Figure 2
saveas(fig2, 'source_fig2.fig');
close(fig2);

% 准备源和目标布局及子图信息 / Prepare layout and subplot information
SourceLayout = [2, 3]; % 源图布局 / Source figure layout (2x3)
TargetLayout = [2, 4]; % 目标图布局 / Target figure layout (2x4)

% 定义子图提取和位置信息 / Define subplot extraction and target positions
tbl_SrcFigureFile_SrcSubplot_TgtLocation = {
    'source_fig1.fig', {[1, 2], [2, 1]}, {[1, 1], [1, 2]};
    'source_fig1.fig', {[1, 3], [2, 2]}, {[1, 3], [1, 4]};
    'source_fig2.fig', {[1, 1], [2, 1]}, {[2, 1], [2, 2]};
    'source_fig2.fig', {[1, 2], [2, 2]}, {[2, 3], [2, 4]};
};

% 调用函数重新排列子图，并启用高亮过程 / Call function to rearrange subplots with highlighting
rearrange_subplots(tbl_SrcFigureFile_SrcSubplot_TgtLocation, SourceLayout, TargetLayout, 'LayoutRowCol', 'FileName', true);

% 清理临时保存的源文件 / Clean up saved source files
delete('source_fig1.fig');
delete('source_fig2.fig');

