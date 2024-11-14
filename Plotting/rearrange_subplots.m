function tgtFigHandle = rearrange_subplots(tbl_SrcFigureFile_SrcSubplot_TgtLocation, SourceLayout, TargetLayout, CopyMode, FigureSourceType, qHighlightProcess)
    % rearrange_subplots - 从指定的源图中提取指定的子图，并重新按新布局排列
    % rearrange_subplots - Extract specified subplots from source figures and rearrange them into a new layout
    %
    % 作者 / Authors: ChatGPT, Sam Zebrado
    %
    % 输入参数 / Input Arguments:
    %   tbl_SrcFigureFile_SrcSubplot_TgtLocation (cell array): 包含源文件名/句柄、源子图位置和目标位置的元数据表
    %       (Metadata table containing source figure file/handle, source subplot positions, and target locations)
    %   SourceLayout (vector): 源图的布局，以 [行数, 列数] 格式指定
    %       (Layout of the source figure, specified as [rows, columns])
    %   TargetLayout (vector): 新图窗的布局，以 [行数, 列数] 格式指定
    %       (Layout of the target figure, specified as [rows, columns])
    %   CopyMode (char): 拷贝模式，'IndexBased' 表示索引模式，'LayoutRowCol' 表示行列模式
    %       (Copy mode, 'IndexBased' for index mode, 'LayoutRowCol' for row-column mode)
    %   FigureSourceType (char): 指定 sourceFigures 是 'FileName' 还是 'FigureHandle'
    %       (Specify if sourceFigures are 'FileName' or 'FigureHandle')
    %   qHighlightProcess (logical): 如果为 true，逐步演示拷贝过程，显示源图和目标图的边框
    %       (If true, highlight the source and target axes during the copy process)

    % 设置默认值 / Set default values if not provided
    if nargin < 4, CopyMode = 'IndexBased'; end
    if nargin < 5, FigureSourceType = 'FileName'; end
    if nargin < 6, qHighlightProcess = false; end

    % 创建新的图窗 / Create a new figure window
    tgtFigHandle = figure;
    numSubplots = size(tbl_SrcFigureFile_SrcSubplot_TgtLocation, 1);

    for k = 1:numSubplots
        srcFile = tbl_SrcFigureFile_SrcSubplot_TgtLocation{k, 1};
        srcSubplots = tbl_SrcFigureFile_SrcSubplot_TgtLocation{k, 2};
        tgtLocations = tbl_SrcFigureFile_SrcSubplot_TgtLocation{k, 3};

        % 加载源图像 / Load source figure
        if strcmp(FigureSourceType, 'FileName')
            srcFigHandle = openfig(srcFile, 'invisible');  % 打开 .fig 文件，不显示 / Open .fig file invisibly
        else
            srcFigHandle = srcFile;  % 如果是句柄则直接使用 / Directly use the handle if provided
        end

        % 获取源图的子图句柄 / Get all subplot handles in the source figure
        srcAxesAll = flipud(findobj(srcFigHandle, 'Type', 'axes'));

        for j = 1:length(srcSubplots(:))
            % 选择源子图 / Select the source subplot
            if strcmp(CopyMode, 'LayoutRowCol')
                % 使用 [row, column] 模式选择子图 / Use [row, column] mode
                srcRow = srcSubplots{j}(1);
                srcCol = srcSubplots{j}(2);
                subplotIdx = (srcRow - 1) * SourceLayout(2) + srcCol;
            else
                % 使用索引模式选择子图 / Use index-based selection
                subplotIdx = srcSubplots{j}(1);
            end

            % 获取指定子图句柄 / Get the specified subplot handle
            selectedAxes = srcAxesAll(subplotIdx);

            % 创建目标子图布局 / Create target subplot layout
            if strcmp(CopyMode, 'LayoutRowCol')
                % 使用 [row, column] 指定目标位置 / Use [row, column] for target position
                tgtRow = tgtLocations{j}(1);
                tgtCol = tgtLocations{j}(2);
                tgtIdx = (tgtRow - 1) * TargetLayout(2) + tgtCol;
            else
                % 使用索引指定目标位置 / Use index-based target position
                tgtIdx = tgtLocations{j}(1);
            end

            % 在新图中创建子图布局 / Create subplot layout in the new figure
            newAxes = subplot(TargetLayout(1), TargetLayout(2), tgtIdx, 'Parent', tgtFigHandle);

            % 可选：高亮拷贝过程中的源和目标子图 / Optionally highlight source and target axes during the copy process
            if qHighlightProcess
                figure(srcFigHandle)
                % 在源子图上添加黑色方框 / Add black box to source axes
                srcHighlight = annotation(srcFigHandle, 'rectangle', getAxesPositionInFig(selectedAxes), 'Color', 'k', 'LineWidth', 1.5);
                pause(1);
                
                figure(tgtFigHandle)
                % 在目标子图上添加蓝色方框 / Add blue box to target axes
                tgtHighlight = annotation(tgtFigHandle, 'rectangle', getAxesPositionInFig(newAxes), 'Color', 'b', 'LineWidth', 1.5);
                
                pause(1);  % 暂停以便观察 / Pause to observe
            end

            % 复制子图内容到新子图中 / Copy subplot content to new subplot
            copyobj(allchild(selectedAxes), newAxes);

            % 复制轴标签和标题 / Copy axis labels and title
            title(newAxes, get(get(selectedAxes, 'Title'), 'String'));  % 确保标题被正确复制 / Ensure the title is copied
            xlabel(newAxes, get(get(selectedAxes, 'XLabel'), 'String'));
            ylabel(newAxes, get(get(selectedAxes, 'YLabel'), 'String'));

            % 设置 x 和 y 轴范围 / Set x and y limits
            set(newAxes, 'XLim', get(selectedAxes, 'XLim'));
            set(newAxes, 'YLim', get(selectedAxes, 'YLim'));

            % 移除方框以继续拷贝下一个子图 / Remove the highlight boxes after copying
            if qHighlightProcess
                delete(srcHighlight);
                delete(tgtHighlight);
                pause(1);  % 暂停以便观察 / Pause to observe
            end
        end

        % 关闭源图（如果是从文件加载的） / Close the source figure if it was loaded from a file
        if strcmp(FigureSourceType, 'FileName')
            close(srcFigHandle);
        end
    end
end

function pos = getAxesPositionInFig(axesHandle)
    % 获取指定 axes 在 figure 中的归一化位置
    % Get the normalized position of the axes within the figure
    axPos = get(axesHandle, 'Position');  % axes 的相对坐标 / Axes relative position within parent container
    figPos = get(ancestor(axesHandle, 'figure'), 'Position');  % 获取 figure 大小 / Figure size in screen units

    % 将 axes 位置转换为 figure 归一化坐标 / Normalize axes position to figure coordinates
    pos = [axPos(1) * figPos(3), axPos(2) * figPos(4), axPos(3) * figPos(3), axPos(4) * figPos(4)];
    pos = pos ./ [figPos(3), figPos(4), figPos(3), figPos(4)];  % 归一化 / Normalize to [0, 1]
end
