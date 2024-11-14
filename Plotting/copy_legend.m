function copy_legend(srcAxes, targetAxes, legendPosition)
    % copy_legend - 从源子图复制 legend 到目标子图
    % copy_legend - Copy legend from source axes to target axes
    %
    % 语法 / Syntax:
    %   copy_legend(srcAxes, targetAxes)
    %   copy_legend(srcAxes, targetAxes, legendPosition)
    %
    % 输入参数 / Input Arguments:
    %   srcAxes (handle): 源子图的句柄 / Handle of the source subplot
    %   targetAxes (handle): 目标子图的句柄 / Handle of the target subplot
    %   legendPosition (optional): legend 的位置，可选。如果不提供，则保持源 legend 的位置
    %
    % 示例 / Example:
    %   fig1 = figure;
    %   subplot(1, 2, 1);
    %   plot(rand(10, 2));
    %   legend('Line 1', 'Line 2');
    %
    %   fig2 = figure;
    %   subplot(1, 2, 1);
    %   plot(rand(10, 2));
    %
    %   copy_legend(findobj(fig1, 'Type', 'axes'), gca); % 复制 legend / Copy legend
    %
    % 作者 / Author: ChatGPT

    % 获取源 legend 信息 / Get source legend information
    srcLegend = findobj(srcAxes, 'Tag', 'legend');
    
    if isempty(srcLegend)
        warning('No legend found in the source axes.');
        return;
    end
    
    % 获取 legend 标签和对象 / Get legend labels and objects
    legendLabels = srcLegend.String;
    legendObjs = findobj(srcAxes, '-regexp', 'DisplayName', '.*'); % 查找显示名称的对象 / Find objects with DisplayName

    % 检查目标子图的对象，确保每个对象的 DisplayName 不为空 / Ensure each object has DisplayName set
    for obj = legendObjs'
        if isempty(obj.DisplayName)
            warning('Some objects do not have DisplayName set. They will be excluded from the legend.');
        end
    end

    % 在目标子图中创建 legend / Create legend in target subplot
    newLegend = legend(targetAxes, legendObjs, legendLabels);
    
    % 设置 legend 位置，如果提供了新的位置参数 / Set legend position, if provided
    if nargin >= 3 && ~isempty(legendPosition)
        newLegend.Position = legendPosition;
    else
        newLegend.Position = srcLegend.Position; % 保持源 legend 位置 / Retain source legend position
    end
end
