function summary_viewer_gui_bilingual()
% SUMMARY_VIEWER_GUI_BILINGUAL - 多图像条件筛选与显示工具
% SUMMARY_VIEWER_GUI_BILINGUAL - GUI tool for condition-based image selection and display
%
% 此函数提供一个可扩展的多图像浏览界面。
% This function provides an extensible multi-panel image viewer GUI.
%
% 支持根据子文件夹名中的 token 进行条件筛选（例如 subject, condition 等）。
% Supports condition-based filtering by parsing tokens in folder names (e.g., subject, condition).
%
% 使用正则表达式和 token 名称定义解析规则。
% Defines parsing rules using a regular expression and token names.
%
% 每组控件允许选择路径、筛选条件、文件并显示图像。
% Each control block allows selecting a path, filtering by tokens, choosing a file, and displaying the image.
%
% 用户可以点击“设置 Tokens”自定义 token 名称与正则表达式，并可设为默认。
% Users can click "Token Settings" to customize token names and regex, and save them as default.
%
% 界面支持分页跳转、配置保存/加载以及配置复制功能。
% GUI supports pagination, configuration saving/loading, and duplicating settings across panels.
%
% 所需图像结构如下（文件夹名将被解析为 token 值）：
% Expected folder structure (folder names are parsed into token values):
% e.g.,  u001_Morning_task1_r1/
%        u001_Morning_task1_r2/
%        u002_Evening_task2_r1/
%
% 示例 tokenNames: {'user','session','task','rep'}
% Example tokenNames: {'user','session','task','rep'}
% 示例 tokenPattern: '^(\w+)_([A-Za-z]+)_(task\d+)_r(\d+)$'
% Example tokenPattern: '^(\w+)_([A-Za-z]+)_(task\d+)_r(\d+)$'
%
% 默认初始路径设置为 defaultRootPath，可在函数中修改。
% Default root folder is set by defaultRootPath, can be modified inside the function.
%
% 图像文件需为 PNG 格式，显示区域自动居中。
% Image files should be in PNG format; display area is auto-centered.
%
% Created by: ChatGPT & Captain Sam
% Updated: 2025


% ==== 用户可在此修改 token 名称与正则规则 ====
defaultTokenNames = {'user','session','task','rep'};
defaultTokenPattern = '^(\w+)_([A-Za-z]+)_(task\d+)_r(\d+)$';

% 若有保存的默认设置，加载它
if exist('token_config.mat', 'file')
    S = load('token_config.mat');
    if isfield(S, 'tokenNames')
        defaultTokenNames = S.tokenNames;
    end
    if isfield(S, 'tokenPattern')
        defaultTokenPattern = S.tokenPattern;
    end
end

defaultRootPath = './DemoData';

% 初始化图像窗口
% Initialize the image display window
figImg = figure('Name','Image Display','Units','normalized','OuterPosition',[0 0 1 1], ...
    'Tag','figImg');

mainFigWidth = 1120;

% 新的主窗口（包含滚动支持）
mainFig = figure('Name','VR Summary Controls (Scrollable)', ...
    'Position',[100 100 mainFigWidth 450], ...
    'NumberTitle','off','MenuBar','none','Resize','on');

% 用于放置控件组的滚动面板
scrollPanel = uipanel('Parent', mainFig, 'Units','pixels', ...
    'Position', [0 0 mainFigWidth 420], 'Tag', 'scrollPanel','BorderType', 'none');

% 将 figCtrl 定义为 scrollPanel
figCtrl = scrollPanel;

% 初始化数据
% Initialize shared data
data.rootPath = defaultRootPath;
data.entries = [];
data.ctrlCount = 0;
data.figImg = figImg;
data.tokenNames = defaultTokenNames;  % <== 这一行是你遗漏的关键
data.tokenPattern = defaultTokenPattern;  % 同样推荐也加上这个
guidata(figCtrl, data);

% ==== 构建初始控件块 ====
buildControlBlock(figCtrl, 1);


blockWidth = 360;
% ==== 左侧分页与配置按钮 ====
uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '保存配置 / Save', ...
    'Position', [10, 420, 100, 25], ...
    'Callback', @(~,~) saveConfigToJson(figCtrl, 'my_config.json'));

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '加载配置 / Load', ...
    'Position', [115, 420, 100, 25], ...
    'Callback', @(~,~) ...
    loadConfigFromJson(mainFig, figCtrl, ...
    fullfile(uigetdir(pwd, '选择配置文件夹'), 'my_config.json')));

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '« 首页 / First', ...
    'Position', [220, 420, 80, 25], ...
    'Tag', 'firstPageBtn', ...
    'Callback', @(~,~) jumpToPageNum(mainFig, figCtrl, blockWidth, 1));

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '← 上一页 / Prev', ...
    'Position', [305, 420, 80, 25], ...
    'Tag', 'prevPageBtn', ...
    'Callback', @(~,~) scrollPanelLeft(mainFig, figCtrl, blockWidth));

uicontrol(mainFig, 'Style', 'text', ...
    'Position', [390, 425, 20, 20], ...
    'String', '第', 'HorizontalAlignment', 'right');

uicontrol(mainFig, 'Style', 'edit', ...
    'Position', [410, 420, 40, 25], ...
    'Tag', 'pageJumpInput', ...
    'String', '', ...
    'TooltipString', '输入页码按回车或点击跳转 / Press Enter or click Go', ...
    'KeyPressFcn', @(src,event) ...
    strcmp(event.Key, 'return') && jumpToPage(mainFig, figCtrl, blockWidth));

uicontrol(mainFig, 'Style', 'text', ...
    'Position', [455, 425, 20, 20], ...
    'String', '/', 'HorizontalAlignment', 'center');

uicontrol(mainFig, 'Style', 'text', ...
    'Position', [475, 425, 50, 20], ...
    'String', '1 页', ...
    'Tag', 'pageTotalText', ...
    'HorizontalAlignment', 'left');

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'Position', [530, 420, 60, 25], ...
    'String', '跳转 / Go', ...
    'Callback', @(~,~) jumpToPage(mainFig, figCtrl, blockWidth));

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '下一页 / Next →', ...
    'Position', [595, 420, 80, 25], ...
    'Tag', 'nextPageBtn', ...
    'Callback', @(~,~) scrollPanelRight(mainFig, figCtrl, blockWidth));

uicontrol(mainFig, 'Style', 'pushbutton', ...
    'String', '末页 / Last »', ...
    'Position', [680, 420, 80, 25], ...
    'Tag', 'lastPageBtn', ...
    'Callback', @(~,~) jumpToPageNum(mainFig, figCtrl, blockWidth, Inf));

% 灰色分隔线
uicontrol(mainFig, 'Style', 'text', ...
    'Position', [0, 415, 800, 1], ...
    'BackgroundColor', [0.6 0.6 0.6], ...
    'ForegroundColor', [0.6 0.6 0.6], ...
    'String', '', ...
    'Enable', 'off', ...
    'HorizontalAlignment', 'left');

% ==== 右侧 Token 设置控件 ====
uicontrol(mainFig, 'Style', 'pushbutton', ...
    'Position', [885, 420, 200, 25], ...
    'String', '设置 Tokens / Token Settings', ...
    'Callback', @(~,~) openTokenSettingsDialog(mainFig, figCtrl));

%% 构建控件块函数
% Function to build control block
    function buildControlBlock(figCtrl, idx, copyFromIdx)
        % 如果未传 idx，自动获取下一个可用编号
        if nargin < 2 || isempty(idx)
            idx = fc_next_idx_available(figCtrl);
        end

        if nargin < 3
            copyFromIdx = [];
        end

        data = guidata(figCtrl);
        blockWidth = 360;
        offsetX = (idx - 1) * blockWidth;
        baseY = 400;

        % 自动扩展窗口宽度
        figPos = get(figCtrl, 'Position');
        requiredWidth = offsetX + blockWidth;
        if figPos(3) < requiredWidth
            figPos(3) = requiredWidth;
            set(figCtrl, 'Position', figPos);
        end

        % 获取复制对象的状态（若提供 copyFromIdx）
        if nargin < 3
            copyFromIdx = [];
        end

        % 默认继承的数据
        inheritedPath = data.rootPath;
        inheritedEntries = data.entries;
        tokenNames = guidata(figCtrl).tokenNames;
        inheritedSelections = struct();
        for i = 1:length(tokenNames)
            inheritedSelections.(tokenNames{i}) = 1;
        end
        inheritedSelections.file = '';

        if ~isempty(copyFromIdx)
            % 路径
            pathBox = findobj(figCtrl, 'Tag', sprintf('path_%d', copyFromIdx));
            inheritedPath = get(pathBox, 'String');

            % 获取共享 token 列表
            data = guidata(figCtrl);  % 确保 data 中已有 tokenNames 字段
            tokenNames = data.tokenNames;

            % dropdown 状态
            for i = 1:length(tokenNames)
                field = tokenNames{i};
                popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, copyFromIdx));
                inheritedSelections.(field) = get(popup, 'Value');
            end

            % file name
            group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', copyFromIdx));
            selectedBtn = findobj(group, 'Style', 'radiobutton', 'Value', 1);
            if ~isempty(selectedBtn)
                inheritedSelections.file = get(selectedBtn, 'String');
            end
        end


        % 添加分隔线
        if idx > 1
            uipanel(figCtrl, 'BackgroundColor', [0.8 0.8 0.8], ...
                'Position', [offsetX-5 0 2 figPos(4)]);
        end

        % 设置共享数据
        data.ctrlCount = max(data.ctrlCount, idx);
        data.entries = inheritedEntries;
        data.rootPath = inheritedPath;
        guidata(figCtrl, data);

        % 路径输入
        uicontrol(figCtrl, 'Style','text','Position',[offsetX+10 baseY-30 80 20],'String','Path');
        uicontrol(figCtrl,'Style','edit','Position',[offsetX+90 baseY-30 250 20], ...
            'String', inheritedPath, 'Tag', sprintf('path_%d', idx));

        % Apply Path
        uicontrol(figCtrl,'Style','pushbutton','String','Apply Path', ...
            'Position',[offsetX+90 baseY-60 250 25], ...
            'Callback', @(src, event) onApplyPathClicked(figCtrl, idx));

        % 下拉菜单
        for i = 1:length(data.tokenNames)
            tag = data.tokenNames{i};
            uicontrol(figCtrl,'Style','popupmenu', ...
                'Position',[offsetX+10 baseY-90-30*(i-1) 330 25], ...
                'String', {'(no data)'}, ...
                'Tag', sprintf('%s_%d', tag, idx));

            % 加入 label
            uicontrol(figCtrl,'Style','text', ...
                'Position', [offsetX+10 baseY-90-30*(i-1)+25 330 15], ...
                'String', tag, ...
                'HorizontalAlignment','left');
        end


        % 文件选择面板
        scrollPanel = uipanel(figCtrl, 'Title', 'File to Show', ...
            'Units', 'pixels', 'Position', [offsetX+10 60 330 100], ...
            'Tag', sprintf('chkPanel_%d', idx));
        buildRadioButtons(scrollPanel, '', idx);

        % 显示图像 / Show按钮
        uicontrol(figCtrl,'Style','pushbutton','Position',[offsetX+10 25 160 25],'String','显示图像 / Show',...
            'Callback',@(src,evt) renderImages(figCtrl, idx));

        % 复制配置 / Copy按钮
        uicontrol(figCtrl,'Style','pushbutton','Position',[offsetX+180 25 160 25], 'String','复制配置 / Copy', ...
            'Callback', @(src,evt) insertControlCopy(figCtrl, idx));

        % 应用 Path 并恢复原状态（自动刷新菜单）
        onApplyPathClicked(figCtrl, idx);
        pause(0.01); % 等控件加载完

        % 恢复选择状态
        tokenNames = guidata(figCtrl).tokenNames;
        for i = 1:length(tokenNames)
            field = tokenNames{i};
            popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, idx));
            try
                set(popup, 'Value', inheritedSelections.(field));
            end
        end

        % 恢复文件名
        if ~isempty(inheritedSelections.file)
            group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', idx));
            buttons = findall(group, 'Style','radiobutton');
            for b = buttons'
                if strcmp(get(b, 'String'), inheritedSelections.file)
                    set(b, 'Value', 1);
                    break;
                end
            end
        end
        % 自动扩展 scrollPanel 宽度以容纳所有控件
        allPopups = findall(figCtrl, 'Style', 'popupmenu');
        maxRight = 0;
        for i = 1:length(allPopups)
            pos = get(allPopups(i), 'Position');
            maxRight = max(maxRight, pos(1) + pos(3));
        end
        panelPos = get(figCtrl, 'Position');
        panelPos(3) = max(maxRight + 40, panelPos(3));
        set(figCtrl, 'Position', panelPos);
    end

%% 点击 Apply Path 时的回调
% Callback when Apply Path is clicked
    function onApplyPathClicked(figCtrl, idx)
        % 获取路径
        pathEdit = findobj(figCtrl,'Tag',sprintf('path_%d',idx));
        folder = get(pathEdit, 'String');

        if ~isfolder(folder)
            errordlg('该路径不存在','路径错误 / Invalid Path');
            return;
        end

        % 读取 token 设置
        data = guidata(figCtrl);
        tokenNames = data.tokenNames;
        tokenPattern = data.tokenPattern;

        % 调用统一解析函数（注意这里需将此函数放到本文件末尾）
        [entryList, valuesByToken] = fc_parse_folder_tokens(folder, tokenNames, tokenPattern);

        % 存入共享数据
        data = guidata(figCtrl);
        data.rootPath = folder;
        data.entries = entryList;
        data.tokenNames = tokenNames;
        data.valuesByToken = valuesByToken;
        data.tokenPattern = tokenPattern;
        guidata(figCtrl, data);

        % 刷新 dropdown 菜单
        rebuildControlOptions(figCtrl, idx);

        % 刷新文件选择区域
        chkPanel = findobj(figCtrl, 'Tag', sprintf('chkPanel_%d', idx));
        if ~isempty(chkPanel) && ~isempty(entryList)
            exampleFolder = fullfile(folder, entryList(1).folder);
            buildRadioButtons(chkPanel, exampleFolder, idx);
        end
    end

%% 构建单选按钮列表
% Build radiobutton list
    function buildRadioButtons(parentPanel, folderPath, idx)
        delete(allchild(parentPanel));

        if isempty(folderPath) || ~isfolder(folderPath)
            fileNames = {};
        else
            fileList = dir(fullfile(folderPath, '*.png')); % 可拓展支持 *.jpg, *.bmp 等
            fileNames = {fileList.name};
        end
        n_files = length(fileNames);
        panelHeight = 100;
        itemHeight = 20;
        totalHeight = (n_files + 1) * itemHeight;
        panelHeight = max(panelHeight, totalHeight);  % 自动调整

        buttonGroup = uibuttongroup('Parent', parentPanel, ...
            'Units', 'pixels', ...
            'Position', [0 0 330 panelHeight], ...
            'Tag', sprintf('radioGroup_%d', idx));

        for i = 1:n_files
            ypos = panelHeight - itemHeight*(i+1);
            uicontrol(buttonGroup, 'Style', 'radiobutton', ...
                'String', fileNames{i}, ...
                'Units','pixels','Position', [10 ypos 280 itemHeight]);
        end
    end

%% 更新下拉菜单
% Update dropdowns
    function rebuildControlOptions(figCtrl, idx)
        data = guidata(figCtrl);
        tokenNames = data.tokenNames;
        valuesByToken = data.valuesByToken;

        for i = 1:length(tokenNames)
            field = tokenNames{i};
            values = valuesByToken.(field);
            popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, idx));
            if ~isempty(popup)
                set(popup, 'String', values);
            end
        end
    end


%% 显示图像 / Show
% Display selected image
    function renderImages(figCtrl, idx)
        data = guidata(figCtrl);
        % 假设你已经获取了当前各个 token 的选中值
        tokenNames = data.tokenNames;
        folderPattern = data.tokenPattern;  % '^(\w+)_([A-Za-z]+)_([\d\.]+)_g(\d+)$' 只是一个例子

        % 获取对应 entry
        matches = data.entries;
        for i = 1:length(tokenNames)
            tag = tokenNames{i};
            list = get(findobj(figCtrl, 'Tag', sprintf('%s_%d', tag, idx)), 'String');
            val  = get(findobj(figCtrl, 'Tag', sprintf('%s_%d', tag, idx)), 'Value');
            selectedTokens.(tag) = list{val};
        end

        % 找到 entries 中符合所有 token 的那个
        found = '';
        for i = 1:length(matches)
            ok = true;
            for j = 1:length(tokenNames)
                if ~strcmp(matches(i).(tokenNames{j}), selectedTokens.(tokenNames{j}))
                    ok = false; break;
                end
            end
            if ok
                found = matches(i).folder;
                break;
            end
        end

        % 构建路径
        if ~isempty(found)
            fullFolder = fullfile(data.rootPath, found);
        else
            errordlg('未找到匹配的 folder','错误 / Match Error');
            return;
        end

        group = findobj(figCtrl,'Tag',sprintf('radioGroup_%d',idx));
        selectedBtn = findobj(group,'Style','radiobutton','Value',1);

        figImg = data.figImg;
        delete(findall(figImg, 'Type', 'axes'));

        if ~isempty(selectedBtn)
            fname = get(selectedBtn, 'String');
            fpath = fullfile(fullFolder, fname);
            if exist(fpath, 'file')
                img = imread(fpath);
                ax = axes(figImg, 'Units', 'normalized', ...
                    'Position', [0.05, 0.05, 0.9, 0.9]);  % 上方留出 15% 空间

                imshow(img, 'Parent', ax);
                axis(ax, 'off');
                % 设置窗口标题为当前文件名
                set(figImg, 'Name', sprintf('Image Display - %s', fname));

                % 或者在图片左上角加文字标注
                text(ax, -50, -45, fpath, 'Color','w', 'FontSize',14, 'FontWeight','bold', ...
                    'BackgroundColor','k', 'Margin', 4, 'Interpreter','none');
            else
                warning('文件不存在 / File not found: %s', fpath);
            end
        else
            msgbox('请选择一个图像文件。 / Please select one.','提示 / Notice');
        end
    end


    function saveConfigToJson(figCtrl, filename)
        data = struct;
        idx = 1;
        tokenNames = guidata(figCtrl).tokenNames;
        while true
            pathBox = findobj(figCtrl, 'Tag', sprintf('path_%d', idx));
            if isempty(pathBox)
                break;
            end
            data(idx).path = get(pathBox, 'String');
            for i = 1:length(tokenNames)
                field = tokenNames{i};
                popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, idx));
                data(idx).(field) = get(popup, 'Value');
            end
            group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', idx));
            sel = findobj(group, 'Style', 'radiobutton', 'Value', 1);
            if ~isempty(sel)
                data(idx).file = get(sel, 'String');
            else
                data(idx).file = '';
            end
            idx = idx + 1;
        end
        jsonStr = jsonencode(data);
        fid = fopen(filename, 'w');
        fwrite(fid, jsonStr, 'char');
        fclose(fid);
    end



    function loadConfigFromJson(mainFig, figCtrl, filename)
        % 从 JSON 文件中加载配置 / Load
        % Load configuration from JSON
        if isempty(filename)
            [filename, pathname] = uigetfile('*.json', '选择配置文件');
            if isequal(filename, 0), return; end
            filename = fullfile(pathname, filename);
        end
        % 读取文件内容
        fid = fopen(filename, 'r');
        raw = fread(fid, inf, '*char')';
        fclose(fid);
        config = jsondecode(raw);

        % 每页宽度（与 buildControlBlock 一致）
        blockWidth = 360;
        % 获取下一个控件组序号
        nextIdx = fc_next_idx_available(figCtrl);
        tokenNames = guidata(figCtrl).tokenNames;
        % 逐个构建控件块
        for i = 1:length(config)
            curIdx = nextIdx + i - 1;
            buildControlBlock(figCtrl, curIdx);

            % 设置路径等值
            set(findobj(figCtrl, 'Tag', sprintf('path_%d', curIdx)), 'String', config(i).path);

            for j = 1:length(tokenNames)
                field = tokenNames{j};
                popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field,curIdx));
                set(popup, 'Value', config(i).(field));
            end

            if ~isempty(config(i).file)
                group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', curIdx));
                buttons = findall(group, 'Style','radiobutton');
                for b = buttons'
                    if strcmp(get(b, 'String'), config(i).file)
                        set(b, 'Value', 1);
                        break;
                    end
                end
            end

            % 滚动过去显示该组控件
            offset = (curIdx - 1) * 360;
            panelPos = get(figCtrl, 'Position');
            panelPos(1) = -offset;
            set(figCtrl, 'Position', panelPos);
            setappdata(mainFig, 'scrollOffsetX', offset);
        end

    end

    function scrollPanelLeft(mainFig, figCtrl, blockWidth)
        offset = getappdata(mainFig, 'scrollOffsetX');
        offset = max(0, offset - blockWidth);
        panelPos = get(figCtrl, 'Position');
        panelPos(1) = -offset;
        set(figCtrl, 'Position', panelPos);
        % 更新页码显示
        panelWidth = get(figCtrl, 'Position');
        totalPages = ceil(panelWidth(3) / blockWidth);
        currentPage = round(offset / blockWidth) + 1;
        txt = findobj(mainFig, 'Tag', 'pageDisplayText');
        if isgraphics(txt)
            set(txt, 'String', sprintf('Page %d / %d', currentPage, totalPages));
        end

        setappdata(mainFig, 'scrollOffsetX', offset);
    end

    function scrollPanelRight(mainFig, figCtrl, blockWidth)
        offset = getappdata(mainFig, 'scrollOffsetX');
        offset = offset + blockWidth;
        panelPos = get(figCtrl, 'Position');
        panelPos(1) = -offset;
        set(figCtrl, 'Position', panelPos);
        % 更新页码显示
        panelWidth = get(figCtrl, 'Position');
        totalPages = ceil(panelWidth(3) / blockWidth);
        currentPage = round(offset / blockWidth) + 1;
        txt = findobj(mainFig, 'Tag', 'pageDisplayText');
        if isgraphics(txt)
            set(txt, 'String', sprintf('Page %d / %d', currentPage, totalPages));
        end

        setappdata(mainFig, 'scrollOffsetX', offset);
    end

    function insertControlCopy(figCtrl, copyFromIdx)
        % 将后面所有控件往右推
        shiftControlBlocksRight(figCtrl, copyFromIdx+1);
        % 插入新控件在 copyFromIdx+1 处
        buildControlBlock(figCtrl, copyFromIdx+1, copyFromIdx);
    end

    function shiftControlBlocksRight(figCtrl, startIdx)
        blockWidth = 360;

        tokenNames = guidata(figCtrl).tokenNames;
        % 从最大 idx 开始向前移动，避免覆盖
        idx = startIdx;
        while ~isempty(findobj(figCtrl, 'Tag', sprintf('path_%d', idx)))
            idx = idx + 1;
        end
        maxIdx = idx - 1;

        backup = struct();
        for i = startIdx:maxIdx
            backup(i).path = '';
            pathEdit = findobj(figCtrl, 'Tag', sprintf('path_%d', i));
            if ~isempty(pathEdit)
                backup(i).path = get(pathEdit, 'String');
            end
            data = guidata(figCtrl);  % 确保拿到最新 tokenNames
            tokenNames = data.tokenNames;

            for t = 1:length(tokenNames)
                field = tokenNames{t};
                popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, i));
                if ~isempty(popup)
                    backup(i).(field) = get(popup, 'Value');
                end
            end
            group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', i));
            selectedBtn = findobj(group, 'Style', 'radiobutton', 'Value', 1);
            if ~isempty(selectedBtn)
                backup(i).file = get(selectedBtn, 'String');
            else
                backup(i).file = '';
            end
        end

        data = guidata(figCtrl);
        tokenNames = data.tokenNames;
        fields = [{'path'}, tokenNames, {'radioGroup','chkPanel'}];  % 动态拼接字段名

        for i = maxIdx:-1:startIdx
            for j = 1:length(fields)
                f = fields{j};
                objs = findobj(figCtrl, 'Tag', sprintf('%s_%d', f, i));
                for o = objs'
                    % 修改 Tag
                    set(o, 'Tag', sprintf('%s_%d', f, i+1));
                    % 向右移动控件位置
                    pos = get(o, 'Position');
                    pos(1) = pos(1) + blockWidth;
                    set(o, 'Position', pos);
                end
            end

            newIdx = i + 1;
            baseX = (newIdx - 1) * blockWidth;
            baseY = 400;

            % 删除原按钮（如存在）
            delete(findobj(figCtrl, 'Tag', sprintf('applyBtn_%d', newIdx)));
            delete(findobj(figCtrl, 'Tag', sprintf('showBtn_%d', newIdx)));
            delete(findobj(figCtrl, 'Tag', sprintf('copyBtn_%d', newIdx)));

            % 重建 Apply Path 按钮
            uicontrol(figCtrl, 'Style','pushbutton', ...
                'Position', [baseX + 90, baseY - 60, 250, 25], ...
                'String', 'Apply Path', ...
                'Tag', sprintf('applyBtn_%d', newIdx), ...
                'Callback', @(src, event) onApplyPathClicked(figCtrl, newIdx));

            % 重建 显示图像 / Show 按钮
            uicontrol(figCtrl,'Style','pushbutton', ...
                'Position', [baseX + 10, 25, 160, 25], ...
                'String','显示图像 / Show', ...
                'Tag', sprintf('showBtn_%d', newIdx), ...
                'Callback', @(src,evt) renderImages(figCtrl, newIdx));

            % 重建 复制配置 / Copy 按钮
            uicontrol(figCtrl,'Style','pushbutton', ...
                'Position', [baseX + 180, 25, 160, 25], ...
                'String','复制配置 / Copy', ...
                'Tag', sprintf('copyBtn_%d', newIdx), ...
                'Callback', @(src,evt) insertControlCopy(figCtrl, newIdx));
            % 删除旧的文件选择区域（整个面板 + group）
            delete(findobj(figCtrl, 'Tag', sprintf('chkPanel_%d', newIdx)));
            delete(findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', newIdx)));

            % 重建文件选择面板
            scrollPanel = uipanel(figCtrl, 'Title', 'File to Show', ...
                'Units', 'pixels', 'Position', [baseX+10 60 330 100], ...
                'Tag', sprintf('chkPanel_%d', newIdx));
            buildRadioButtons(scrollPanel, '', newIdx);

            % 应用 path 并刷新 dropdown + 文件列表
            onApplyPathClicked(figCtrl, newIdx);
            pause(0.01);  % 等控件更新完

            % 恢复 dropdown 选中项
            for t = 1:length(tokenNames)
                field = tokenNames{t};
                popup = findobj(figCtrl, 'Tag', sprintf('%s_%d', field, newIdx));
                if ~isempty(popup) && isfield(backup(i), field)
                    try
                        set(popup, 'Value', backup(i).(field));
                    end
                end
            end

            % 恢复 radiobutton 文件选择
            group = findobj(figCtrl, 'Tag', sprintf('radioGroup_%d', newIdx));
            buttons = findall(group, 'Style','radiobutton');
            for b = buttons'
                if strcmp(get(b, 'String'), backup(i).file)
                    set(b, 'Value', 1);
                    break;
                end
            end

        end

    end
    function idx = fc_next_idx_available(figCtrl)
        % 获取下一个可用的控件编号
        % Return the next available unique control index

        idx = 1;
        while true
            % 检查是否已经存在 path_%d 控件
            probe = findobj(figCtrl, 'Tag', sprintf('path_%d', idx));
            if isempty(probe)
                return; % 找到空位
            end
            idx = idx + 1;
        end
    end
    function jumpToPage(mainFig, figCtrl, blockWidth)
        % 获取用户输入页码
        inputBox = findobj(mainFig, 'Tag', 'pageJumpInput');
        str = get(inputBox, 'String');
        pageNum = str2double(str);
        if isnan(pageNum) || pageNum < 1
            msgbox('请输入有效的页码数字 / Enter a valid page number','无效输入 / Invalid Input');
            return;
        end

        % 获取最大页数
        panelWidth = get(figCtrl, 'Position');
        totalPages = ceil(panelWidth(3) / blockWidth);

        % 限制页码在合法范围内
        pageNum = min(pageNum, totalPages);

        % 跳转 / Go
        offset = (pageNum - 1) * blockWidth;
        panelPos = get(figCtrl, 'Position');
        panelPos(1) = -offset;
        set(figCtrl, 'Position', panelPos);
        setappdata(mainFig, 'scrollOffsetX', offset);

        % 更新页码显示
        txt = findobj(mainFig, 'Tag', 'pageDisplayText');
        if isgraphics(txt)
            set(txt, 'String', sprintf('Page %d / %d', pageNum, totalPages));
        end
    end
    function [entries, valuesByToken] = fc_parse_folder_tokens(folderPath, tokenNames, tokenRegex)
        % 从子文件夹名称中提取 token 信息
        % Extract tokens from folder names using regex

        % 获取子文件夹列表
        dirList = dir(folderPath);
        subfolders = dirList([dirList.isdir] & ~startsWith({dirList.name}, '.'));
        folderNames = {subfolders.name};

        % 初始化
        entries = struct([]);
        valuesByToken = struct();
        nTokens = length(tokenNames);

        % 逐个解析
        for i = 1:length(folderNames)
            tokens = regexp(folderNames{i}, tokenRegex, 'tokens');
            if isempty(tokens), continue; end
            tokens = tokens{1};

            % 构建 entry
            entries(end+1).folder = folderNames{i}; %#ok<AGROW>
            for t = 1:nTokens
                entries(end).(tokenNames{t}) = tokens{t};
            end
        end

        % 获取每个 token 字段的 unique 值
        for t = 1:nTokens
            if isempty(entries)
                valuesByToken.(tokenNames{t}) = {'(no data)'};
            else
                values = {entries.(tokenNames{t})};
                valuesByToken.(tokenNames{t}) = unique(values);
            end
        end
    end

    function applyTokenSettings(figCtrl, mainFig)
        % 获取用户设置的 token 名称
        nameStr = get(findobj(mainFig, 'Tag', 'tokenNamesInput'), 'String');
        patternStr = get(findobj(mainFig, 'Tag', 'tokenPatternInput'), 'String');

        % 去除空格并分割为 cell 数组
        tokenNames = strsplit(strrep(nameStr, ' ', ''), ',');

        if isempty(tokenNames) || any(cellfun(@isempty, tokenNames))
            errordlg('Token 名称无效，请用英文逗号分隔','无效设置');
            return;
        end

        % 保存到共享数据
        data = guidata(figCtrl);
        data.tokenNames = tokenNames;
        data.tokenPattern = patternStr;
        guidata(figCtrl, data);

        msgbox('设置已更新。下次点击 “Apply Path” 会使用新设置','成功 / Success');
    end
    function saveTokenSettingsAsDefault(mainFig)
        nameStr = get(findobj(mainFig, 'Tag', 'tokenNamesInput'), 'String');
        patternStr = get(findobj(mainFig, 'Tag', 'tokenPatternInput'), 'String');
        tokenNames = strsplit(strrep(nameStr, ' ', ''), ',');

        save('token_config.mat', 'tokenNames', 'tokenPattern');
        msgbox('默认设置已保存，下次启动将自动加载','成功 / Saved');
    end

function openTokenSettingsDialog(mainFig, figCtrl)
    data = guidata(figCtrl);
    currentNames = data.tokenNames;
    currentPattern = data.tokenPattern;

    dlg = dialog('Name', 'Token Settings', 'Position', [500 400 400 200]);

    uicontrol(dlg, 'Style', 'text', ...
        'Position', [20 140 100 20], ...
        'String', 'Token Names:', 'HorizontalAlignment', 'left');
    nameEdit = uicontrol(dlg, 'Style', 'edit', ...
        'Position', [130 140 250 25], ...
        'String', strjoin(currentNames, ','));

    uicontrol(dlg, 'Style', 'text', ...
        'Position', [20 100 100 20], ...
        'String', 'Regex Pattern:', 'HorizontalAlignment', 'left');
    patternEdit = uicontrol(dlg, 'Style', 'edit', ...
        'Position', [130 100 250 25], ...
        'String', currentPattern);

    uicontrol(dlg, 'Style', 'pushbutton', ...
        'Position', [130 40 120 30], ...
        'String', '应用 / Apply', ...
        'Callback', @(~,~) applySettings());

        uicontrol(dlg, 'Style', 'pushbutton', ...
        'Position', [260 40 120 30], ...
        'String', '设为默认 / Save as Default', ...
        'Callback', @saveAsDefault);

    function saveAsDefault(~,~)
        % 临时更新主界面中的隐藏控件值（为了复用函数）
        set(findobj(mainFig, 'Tag', 'tokenNamesInput'), 'String', get(nameEdit, 'String'));
        set(findobj(mainFig, 'Tag', 'tokenPatternInput'), 'String', get(patternEdit, 'String'));

        % 调用已有的保存函数
        saveTokenSettingsAsDefault(mainFig);

        % 可选：自动关闭弹窗
        delete(dlg);
    end


    function applySettings()
        newNames = strsplit(strrep(get(nameEdit, 'String'), ' ', ''), ',');
        newPattern = get(patternEdit, 'String');

        if isempty(newNames) || any(cellfun(@isempty, newNames))
            errordlg('无效 Token 名称，请检查输入。', '错误');
            return;
        end

        data.tokenNames = newNames;
        data.tokenPattern = newPattern;
        guidata(figCtrl, data);
        delete(dlg);
        msgbox('设置已更新，下次点击 Apply Path 时生效。', '成功');
        set(findobj(mainFig, 'Tag', 'tokenNamesInput'), 'String', strjoin(newNames, ','));
set(findobj(mainFig, 'Tag', 'tokenPatternInput'), 'String', newPattern);  % 若保留隐藏字段

    end
end

end